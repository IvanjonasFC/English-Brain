import os
import uuid
import json
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Session, Turn, Question, Mistake, Card
from app.schemas import SessionCreate, SessionOut, TurnOut, QuestionOut, LLMEvaluationResult, PronunciationFeedback
from app.providers.router import provider_router
from app.services.tts import tts_service
from app.services.llm import llm_service
from app.services.memory_service import memory_service
from app.routers.auth import get_current_user
from app.config import settings

router = APIRouter(prefix="/sessions", tags=["sessions"])

@router.post("", response_model=SessionOut)
async def create_session(
    body: Optional[SessionCreate] = None,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    session_id = str(uuid.uuid4())
    new_session = Session(
        id=session_id,
        user_id=current_user,
        status="active"
    )
    db.add(new_session)

    # Select initial question
    initial_q = None
    initial_audio_url = None

    if body and body.initial_question_id:
        res = await db.execute(select(Question).where(Question.id == body.initial_question_id))
        initial_q = res.scalar_one_or_none()
    
    CATEGORY_ALIASES = {
        "general": "hr",
        "daily": "teamwork",
        "workplace": "portfolio",
        "tech": "technical",
        "systems_design": "system_design",
        "systemsdesign": "system_design",
        "ai": "ai_ml",
        "aiml": "ai_ml",
        "cloud": "cloud_arch",
        "cloudarch": "cloud_arch",
    }
    DIFFICULTY_ALIASES = {
        "strategic": "senior",
        "staff": "senior",
        "lead": "senior",
        "entry": "junior",
    }

    if not initial_q:
        raw_category = body.category if body and body.category else "technical"
        c_low = raw_category.lower().strip()
        norm_cat = CATEGORY_ALIASES.get(c_low, c_low)

        norm_diff = None
        if body and getattr(body, "difficulty", None):
            d_low = str(body.difficulty).lower().strip()
            norm_diff = DIFFICULTY_ALIASES.get(d_low, d_low)

        q_stmt = select(Question).where(Question.category == norm_cat)
        if norm_diff:
            q_stmt = q_stmt.where(Question.difficulty == norm_diff)
        
        res = await db.execute(q_stmt.limit(1))
        initial_q = res.scalar_one_or_none()

        if not initial_q:
            res = await db.execute(select(Question).where(Question.category == norm_cat).limit(1))
            initial_q = res.scalar_one_or_none()

    if not initial_q:
        # Fallback to any question
        res = await db.execute(select(Question).limit(1))
        initial_q = res.scalar_one_or_none()

    await db.commit()
    await db.refresh(new_session)

    if initial_q:
        # Precalentar el audio TTS en segundo plano sin bloquear la respuesta HTTP
        import asyncio
        import urllib.parse
        asyncio.create_task(tts_service.synthesize(initial_q.text))
        initial_audio_url = f"/api/tts?text={urllib.parse.quote(initial_q.text)}&voice=en-US-GuyNeural"

    return SessionOut(
        id=new_session.id,
        user_id=new_session.user_id,
        started_at=new_session.started_at,
        completed_at=new_session.completed_at,
        status=new_session.status,
        initial_question=QuestionOut.model_validate(initial_q) if initial_q else None,
        initial_audio_url=initial_audio_url
    )

@router.post("/{session_id}/answer", response_model=TurnOut)
async def submit_answer(
    session_id: str,
    file: UploadFile = File(..., description="Audio file of the candidate's spoken response"),
    question_id: Optional[int] = Form(None),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    # Verify session
    s_res = await db.execute(select(Session).where(Session.id == session_id))
    session = s_res.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Read audio content
    audio_bytes = await file.read()
    if not audio_bytes:
        raise HTTPException(status_code=400, detail="Empty audio file provided")

    # Save audio copy
    os.makedirs(settings.AUDIO_CACHE_DIR, exist_ok=True)
    audio_filename = f"user_{session_id}_{uuid.uuid4().hex[:8]}.m4a"
    audio_filepath = os.path.join(settings.AUDIO_CACHE_DIR, audio_filename)
    with open(audio_filepath, "wb") as f:
        f.write(audio_bytes)

    # 1. STT Speech to Text
    transcript, stt_engine = await provider_router.transcribe(audio_bytes, file.filename or "answer.m4a")

    # HONESTO: si el STT no devolvió texto real (Speaches offline / audio inaudible),
    # NO puntuamos ni generamos tarjetas: eso fabricaría una nota y correcciones falsas.
    if not (transcript or "").strip():
        honest = LLMEvaluationResult(
            interviewer_reply="I couldn't hear your answer clearly. Please check your microphone and connection, then try again.",
            grammar_corrections=[],
            vocabulary_suggestions=[],
            overall_score=0,
            fluency_feedback=(
                "No se pudo transcribir el audio (reconocedor de voz no disponible o audio inaudible). "
                "No se ha puntuado la respuesta para no inventar una nota. Revisa el micrófono/conexión y repite."
            ),
            pronunciation_feedback=PronunciationFeedback(
                score=0, clarity="Unavailable",
                mispronounced_or_difficult_words=[], phonetic_tips=[], filler_words_detected=[],
            ),
        )
        turn = Turn(
            session_id=session_id, question_id=question_id, audio_path=audio_filepath,
            transcript="", ai_reply_text=honest.interviewer_reply, ai_reply_audio_path=None,
            feedback_json=honest.model_dump_json(), created_at=datetime.now(timezone.utc),
        )
        db.add(turn); await db.commit(); await db.refresh(turn)
        return TurnOut(
            id=turn.id, session_id=turn.session_id, question_id=turn.question_id,
            transcript="", ai_reply_text=turn.ai_reply_text, ai_reply_audio_url=None,
            evaluation=honest, engine_used="unavailable", created_at=turn.created_at,
        )

    # Get question text
    question_text = "Tell me about your technical background and experience."
    if question_id:
        q_res = await db.execute(select(Question).where(Question.id == question_id))
        q = q_res.scalar_one_or_none()
        if q:
            question_text = q.text

    # Retrieve previous turns for conversational context
    turns_res = await db.execute(
        select(Turn).where(Turn.session_id == session_id).order_by(Turn.created_at.asc())
    )
    previous_turns = turns_res.scalars().all()
    history = []
    for pt in previous_turns[-4:]:
        history.append({"role": "user", "content": pt.transcript})
        history.append({"role": "assistant", "content": pt.ai_reply_text})

    # 2. LLM Evaluation — usa RobustOllamaClient via llm_service (con log automatico)
    evaluation, feedback_engine = await provider_router.evaluate(
        question_text=question_text,
        user_transcript=transcript,
        conversation_history=history,
    )
    # Registrar en LlmInteractionLog (si el provider_router usa llm_service internamente)
    # El log ya se hace dentro de llm_service.evaluate_turn cuando se pasa db
    if stt_engine == feedback_engine:
        engine_used = stt_engine
    else:
        engine_used = "hybrid"

    # 3. TTS Speech Synthesis for Interviewer reply
    ai_audio_filename = await tts_service.synthesize(evaluation.interviewer_reply)
    ai_reply_audio_url = f"/audio/{ai_audio_filename}" if ai_audio_filename else None

    # 4. Persist Turn and Mistakes
    turn = Turn(
        session_id=session_id,
        question_id=question_id,
        audio_path=audio_filepath,
        transcript=transcript,
        ai_reply_text=evaluation.interviewer_reply,
        ai_reply_audio_path=ai_audio_filename,
        feedback_json=evaluation.model_dump_json(),
        created_at=datetime.now(timezone.utc)
    )
    db.add(turn)
    await db.flush()  # to obtain turn.id

    # Create Mistakes and corresponding FSRS Flashcards
    for g_err in evaluation.grammar_corrections:
        mistake = Mistake(
            turn_id=turn.id,
            category="grammar",
            original=g_err.original,
            correction=g_err.correction,
            explanation=g_err.explanation,
            timestamp=datetime.now(timezone.utc)
        )
        db.add(mistake)
        await db.flush()

        # FSRS Flashcard (initial state=0 New)
        card = Card(
            mistake_id=mistake.id,
            front=g_err.original,
            back=f"{g_err.correction}\n\nExplanation: {g_err.explanation}",
            state=0,  # New
            difficulty=0.0,
            stability=0.0,
            due_date=datetime.now(timezone.utc),
            reps=0,
            lapses=0,
            user_id=current_user,
            source_type="interview_mistake",
            item_type="sentence_correction",
            skill="speaking",
        )
        db.add(card)

    await db.commit()
    await db.refresh(turn)

    # Memoria Progresiva Vectorial (asíncrono en segundo plano)
    if current_user and evaluation.grammar_corrections:
        for g_err in evaluation.grammar_corrections:
            background_tasks.add_task(
                memory_service.record_weakness,
                user_id=current_user,
                flaw_type="grammar_error",
                text=g_err.original,
                details=f"Corrección: {g_err.correction}. {g_err.explanation}",
                weight=1.0,
            )

    return TurnOut(
        id=turn.id,
        session_id=turn.session_id,
        question_id=turn.question_id,
        transcript=turn.transcript,
        ai_reply_text=turn.ai_reply_text,
        ai_reply_audio_url=ai_reply_audio_url,
        evaluation=evaluation,
        engine_used=engine_used,
        created_at=turn.created_at
    )

@router.post("/{session_id}/complete")
async def complete_session(
    session_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    res = await db.execute(select(Session).where(Session.id == session_id))
    session = res.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    session.status = "completed"
    session.completed_at = datetime.now(timezone.utc)
    await db.commit()
    return {"status": "completed", "session_id": session_id}
