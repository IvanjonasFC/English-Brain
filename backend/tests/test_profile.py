import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from app.main import app
from app.database import Base, get_db
from app.config import settings

from sqlalchemy.pool import StaticPool

TEST_DB_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture(scope="function")
async def profile_test_db():
    engine = create_async_engine(
        TEST_DB_URL,
        echo=False,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async def override_get_db():
        async with async_session() as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db

    yield async_session

    app.dependency_overrides.pop(get_db, None)
    await engine.dispose()


@pytest.mark.asyncio
async def test_list_and_create_users(profile_test_db):
    headers = {"X-API-Key": settings.API_KEY}
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. List default users (only Ivan)
        res = await client.get("/api/profile/users", headers=headers)
        assert res.status_code == 200
        users = res.json()
        assert len(users) == 1
        assert users[0]["id"] == "user-ivan"
        assert users[0]["display_name"] == "Iván"

        # 2. Create a new user profile
        new_user_payload = {
            "id": "user-marcos",
            "display_name": "Marcos",
            "target_level": "B2",
            "role_title": "DevOps Engineer",
            "daily_goal_minutes": 25,
        }
        res_create = await client.post("/api/profile/users", json=new_user_payload, headers=headers)
        assert res_create.status_code == 200
        created = res_create.json()
        assert created["id"] == "user-marcos"
        assert created["display_name"] == "Marcos"
        assert created["daily_goal_minutes"] == 25


@pytest.mark.asyncio
async def test_profile_summary(profile_test_db):
    headers = {"X-API-Key": settings.API_KEY}
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.get("/api/profile/summary?user_id=user-ivan", headers=headers)
        assert res.status_code == 200
        data = res.json()

        # Check structure
        assert "profile" in data
        assert data["profile"]["id"] == "user-ivan"
        assert data["profile"]["display_name"] == "Iván"
        assert data["total_xp"] == 0
        assert data["streak_days"] == 0

        # Check skills
        assert "skills" in data
        skills = data["skills"]
        assert skills["grammar_score"] == 0
        assert skills["speaking_score"] == 0
        assert skills["listening_score"] == 0

        # Check achievements (all at 0 progress)
        assert "achievements" in data
        assert len(data["achievements"]) >= 5
        first_badge = data["achievements"][0]
        assert "badge_key" in first_badge
        assert "title" in first_badge
        assert first_badge["progress"] == 0.0
        assert first_badge["is_unlocked"] is False

        # Check activity (clean 0 baseline)
        assert "activity_30d" in data
        assert "weekly_activity" in data
        assert len(data["weekly_activity"]) == 7


@pytest.mark.asyncio
async def test_multi_user_isolation(profile_test_db):
    headers = {"X-API-Key": settings.API_KEY}
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Create user Marcos
        await client.post(
            "/api/profile/users",
            json={"id": "user-marcos", "display_name": "Marcos", "target_level": "B2"},
            headers=headers,
        )

        res_ivan = await client.get("/api/profile/summary?user_id=user-ivan", headers=headers)
        assert res_ivan.status_code == 200
        ivan_data = res_ivan.json()

        res_marcos = await client.get("/api/profile/summary?user_id=user-marcos", headers=headers)
        assert res_marcos.status_code == 200
        marcos_data = res_marcos.json()

        assert ivan_data["profile"]["id"] != marcos_data["profile"]["id"]
        assert ivan_data["profile"]["display_name"] == "Iván"
        assert marcos_data["profile"]["display_name"] == "Marcos"


@pytest.mark.asyncio
async def test_profile_sub_endpoints(profile_test_db):
    headers = {"X-API-Key": settings.API_KEY}
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # /skills
        res_skills = await client.get("/api/profile/skills?user_id=user-ivan", headers=headers)
        assert res_skills.status_code == 200
        skills = res_skills.json()
        assert "grammar_score" in skills
        assert "speaking_score" in skills

        # /achievements
        res_ach = await client.get("/api/profile/achievements?user_id=user-ivan", headers=headers)
        assert res_ach.status_code == 200
        achievements = res_ach.json()
        assert isinstance(achievements, list)
        assert len(achievements) >= 5

        # /activity
        res_act = await client.get("/api/profile/activity?user_id=user-ivan", headers=headers)
        assert res_act.status_code == 200
        activity = res_act.json()
        assert isinstance(activity, list)
