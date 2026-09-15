import pytest
import json
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import declarative_base

from app.main import app
from app.database import get_db, Base
from app.resources.pipeline import parse_markdown, normalize_resources, review_publish, snapshot_export
from app.models import ExternalResource, ResourceCollection, UnitResourceLink, PublishedSnapshot

TEST_SQLALCHEMY_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

test_engine = create_async_engine(
    TEST_SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = async_sessionmaker(
    bind=test_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

async def override_get_db():
    async with TestingSessionLocal() as session:
        yield session


@pytest.fixture(autouse=True)
async def prepare_test_db():
    app.dependency_overrides[get_db] = override_get_db
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    app.dependency_overrides.pop(get_db, None)


SAMPLE_MARKDOWN = """
# Awesome English

## Listening
### Podcasts
* [Software Engineering Daily](https://softwareengineeringdaily.com/) - Technical interviews with engineers about architecture and distributed systems.
* [Syntax.fm](https://syntax.fm/) - A tasty treats podcast for web developers.

## Speaking
### Pronunciation
* [YouGlish](https://youglish.com/) - Search English words used in real YouTube videos by native speakers.
"""


@pytest.mark.asyncio
async def test_parse_markdown():
    parsed = parse_markdown("test-source", SAMPLE_MARKDOWN)
    assert len(parsed) == 3
    assert parsed[0]["title"] == "Software Engineering Daily"
    assert parsed[0]["url"] == "https://softwareengineeringdaily.com/"
    assert "architecture" in parsed[0]["description"]
    assert parsed[2]["title"] == "YouGlish"


@pytest.mark.asyncio
async def test_normalize_resources():
    parsed = parse_markdown("awesome-english", SAMPLE_MARKDOWN)
    normalized = normalize_resources(parsed)

    assert len(normalized) == 3
    sed = next(r for r in normalized if r["title"] == "Software Engineering Daily")
    assert sed["domain"] == "tech_english"
    assert sed["skill"] == "listening"
    assert sed["resource_type"] == "podcast"

    yg = next(r for r in normalized if r["title"] == "YouGlish")
    assert yg["skill"] == "speaking"
    assert yg["resource_type"] == "tool"


@pytest.mark.asyncio
async def test_review_publish_and_snapshot_export():
    async with TestingSessionLocal() as db:
        parsed = parse_markdown("awesome-english", SAMPLE_MARKDOWN)
        normalized = normalize_resources(parsed)
        pub_result = await review_publish(db, normalized)

        assert pub_result["published_count"] > 0

        # Snapshot export
        snap_result = await snapshot_export(db)
        assert snap_result["resource_count"] > 0
        assert snap_result["collection_count"] > 0
        assert len(snap_result["sha256_hash"]) == 64


@pytest.mark.asyncio
async def test_resources_api_endpoints():
    async with TestingSessionLocal() as db:
        parsed = parse_markdown("awesome-english", SAMPLE_MARKDOWN)
        normalized = normalize_resources(parsed)
        await review_publish(db, normalized)
        await snapshot_export(db)

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Test /sync/snapshot
        res = await ac.get("/api/resources/sync/snapshot")
        assert res.status_code == 200
        data = res.json()
        assert "resources" in data
        assert "collections" in data
        assert len(data["resources"]) > 0

        # 2. Test /collections
        res = await ac.get("/api/resources/collections")
        assert res.status_code == 200
        cols = res.json()
        assert len(cols) >= 5

        # 3. Test list resources
        res = await ac.get("/api/resources")
        assert res.status_code == 200
        items = res.json()
        assert len(items) > 0

        # 4. Test usage logging
        usage_payload = {
            "resource_id": items[0]["id"],
            "unit_id": "unit-1-junior",
            "event_type": "open",
            "duration_seconds": 45,
            "user_id": "test_dev",
        }
        res = await ac.post("/api/resources/usage", json=usage_payload)
        assert res.status_code == 200
        assert res.json()["status"] == "logged"
