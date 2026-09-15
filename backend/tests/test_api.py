import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from app.main import (
    app,
    seed_questions_if_needed,
    _migrate_pedagogy_columns,
    _migrate_pronunciation_columns,
    _migrate_user_profiles_columns,
)
from app.database import engine, Base
from app.config import settings

@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        await conn.run_sync(_migrate_pedagogy_columns)
        await conn.run_sync(_migrate_pronunciation_columns)
        await conn.run_sync(_migrate_user_profiles_columns)
    await seed_questions_if_needed()
    yield

@pytest.mark.asyncio
async def test_health_and_root():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.get("/health")
        assert res.status_code == 200
        assert res.json()["status"] in ["ok", "healthy", "degraded"]

        res_root = await client.get("/")
        assert res_root.status_code == 200

@pytest.mark.asyncio
async def test_auth_login():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        # Invalid key
        res_fail = await client.post("/api/auth/login", json={"api_key": "wrong"})
        assert res_fail.status_code == 401

        # Valid key
        res_ok = await client.post("/api/auth/login", json={"api_key": settings.API_KEY})
        assert res_ok.status_code == 200
        token = res_ok.json()
        assert "access_token" in token
        assert token["token_type"] == "bearer"

@pytest.mark.asyncio
async def test_stats_and_questions():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res_stats = await client.get("/api/stats")
        assert res_stats.status_code == 200
        stats = res_stats.json()
        assert "total_sessions" in stats
        assert "weekly_activity" in stats
        assert isinstance(stats["weekly_activity"], list)
        assert len(stats["weekly_activity"]) == 7

        res_report = await client.get("/api/stats/weekly-report")
        assert res_report.status_code == 200
        report = res_report.json()
        assert "markdown_report" in report
        assert "Informe Semanal de Progreso - English Brain" in report["markdown_report"]
        assert "mistakes_this_week" in report
        assert "mistakes_last_week" in report

@pytest.mark.asyncio
async def test_tts_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.get("/api/tts", params={"text": "Idempotency", "voice": "en-US-GuyNeural"})
        assert res.status_code == 200
        assert res.headers["content-type"] in ["audio/mpeg", "audio/mp3", "application/octet-stream"]
        assert len(res.content) > 0

@pytest.mark.asyncio
async def test_pronunciation_endpoint():
    import io
    transport = ASGITransport(app=app)
    fake_audio = b"RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00D\xac\x00\x00\x88X\x01\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
    files = {"file": ("test_term.m4a", io.BytesIO(fake_audio), "audio/m4a")}
    data = {"expected_term": "cache", "expected_ipa": "/k\u00e6\u0283/"}

    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.post("/api/pronunciation/check", files=files, data=data)
        assert res.status_code == 200
        result = res.json()
        assert "score" in result
        assert "feedback" in result
        assert result["expected_term"] == "cache"


