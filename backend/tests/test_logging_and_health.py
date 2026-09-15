import os
import json
import uuid
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
async def test_x_request_id_generation():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.get("/")
        assert res.status_code == 200
        assert "X-Request-ID" in res.headers
        req_id = res.headers["X-Request-ID"]
        # Verify valid UUID
        parsed_uuid = uuid.UUID(req_id)
        assert str(parsed_uuid) == req_id

@pytest.mark.asyncio
async def test_custom_x_request_id_preserved():
    transport = ASGITransport(app=app)
    custom_id = "test-custom-correlation-12345"
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.get("/", headers={"X-Request-ID": custom_id})
        assert res.status_code == 200
        assert res.headers.get("X-Request-ID") == custom_id

@pytest.mark.asyncio
async def test_expanded_health_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        # Test /api/health
        res = await client.get("/api/health")
        assert res.status_code == 200
        data = res.json()
        assert "status" in data
        assert "version" in data

        # Test /api/ready (readiness check with services diagnostics)
        res_ready = await client.get("/api/ready")
        assert res_ready.status_code == 200
        ready_data = res_ready.json()
        assert "status" in ready_data
        assert "version" in ready_data
        assert "services" in ready_data
        assert "llm" in ready_data["services"]
        assert "speaches" in ready_data["services"]

        # Test /health alias
        res_alias = await client.get("/health")
        assert res_alias.status_code == 200
        assert res_alias.json()["version"] == data["version"]

@pytest.mark.asyncio
async def test_log_file_written():
    log_file = settings.LOG_FILE_PATH
    assert log_file is not None
    assert os.path.exists(log_file)

    transport = ASGITransport(app=app)
    marker_id = f"test-marker-{uuid.uuid4().hex}"
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.get("/api/questions", headers={"X-Request-ID": marker_id})
        assert res.status_code == 200

    # Read log file and ensure JSON lines with marker_id
    with open(log_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    found_marker = False
    for line in reversed(lines):
        try:
            record = json.loads(line)
            if record.get("request_id") == marker_id:
                found_marker = True
                assert record.get("method") == "GET"
                assert record.get("path") == "/api/questions"
                assert record.get("status_code") == 200
                assert "duration_ms" in record
                assert "Authorization" not in record
                assert "X-API-Key" not in record
                break
        except json.JSONDecodeError:
            continue
    assert found_marker, f"Marker {marker_id} not found in structured log file"
