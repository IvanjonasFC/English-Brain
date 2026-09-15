import io
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
async def test_session_answer_sacred_contract():
    """
    Validates field-by-field the sacred JSON contract expected by the Flutter app.
    POST /api/sessions/{id}/answer
    """
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        # 1. Create session
        res_session = await client.post("/api/sessions", json={"category": "tech"})
        assert res_session.status_code == 200, res_session.text
        session_data = res_session.json()
        assert "id" in session_data
        session_id = session_data["id"]

        # 2. Prepare mock audio multipart payload
        fake_audio_bytes = b"RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00D\xac\x00\x00\x88X\x01\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
        files = {
            "file": ("user_test_voice.m4a", io.BytesIO(fake_audio_bytes), "audio/m4a")
        }
        init_q = session_data.get("initial_question") or {}
        data = {
            "question_id": str(init_q.get("id", 1))
        }

        # 3. Post answer to session
        res_answer = await client.post(f"/api/sessions/{session_id}/answer", files=files, data=data)
        assert res_answer.status_code == 200, res_answer.text
        turn = res_answer.json()

        # 4. Strict Field-by-Field Contract Verification
        assert "id" in turn and isinstance(turn["id"], int)
        assert turn["session_id"] == session_id
        assert "transcript" in turn and isinstance(turn["transcript"], str)
        assert "ai_reply_text" in turn and isinstance(turn["ai_reply_text"], str)
        assert len(turn["ai_reply_text"]) > 0
        assert "ai_reply_audio_url" in turn
        
        evaluation = turn["evaluation"]
        assert isinstance(evaluation, dict)
        assert "interviewer_reply" in evaluation and isinstance(evaluation["interviewer_reply"], str)
        assert "overall_score" in evaluation and isinstance(evaluation["overall_score"], int)
        assert 0 <= evaluation["overall_score"] <= 10
        assert "fluency_feedback" in evaluation and isinstance(evaluation["fluency_feedback"], str)

        # Grammar Corrections
        assert "grammar_corrections" in evaluation and isinstance(evaluation["grammar_corrections"], list)
        if len(evaluation["grammar_corrections"]) > 0:
            gc = evaluation["grammar_corrections"][0]
            assert "original" in gc and isinstance(gc["original"], str)
            assert "correction" in gc and isinstance(gc["correction"], str)
            assert "explanation" in gc and isinstance(gc["explanation"], str)

        # Vocabulary Suggestions
        assert "vocabulary_suggestions" in evaluation and isinstance(evaluation["vocabulary_suggestions"], list)
        if len(evaluation["vocabulary_suggestions"]) > 0:
            vs = evaluation["vocabulary_suggestions"][0]
            assert "term" in vs and isinstance(vs["term"], str)
            assert "context" in vs and isinstance(vs["context"], str)
            assert "alternatives" in vs and isinstance(vs["alternatives"], list)

        # 5. Verify that cards were generated for the FSRS review deck
        res_cards = await client.get("/api/cards")
        assert res_cards.status_code == 200
        cards = res_cards.json()
        assert len(cards) >= 1
        assert "state" in cards[0]
        assert "difficulty" in cards[0]
        assert "stability" in cards[0]
