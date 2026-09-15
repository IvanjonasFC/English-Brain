"""
Router /api/ai — Endpoints de inferencia LLM para toda la app.

Endpoints:
  GET  /api/ai/status          — Estado del worker GPU (modelo, tok/s, online)
  POST /api/ai/grammar-check   — Correccion gramatical de una frase
  POST /api/ai/vocabulary      — Definicion pedagogica de una palabra
  POST /api/ai/analyze-audio   — STT + analisis LLM de audio grabado
  POST /api/ai/feedback        — Feedback general texto → LLM
  POST /api/ai/feedback/{id}/score — Registrar feedback 👍/👎 del usuario
"""
import uuid
import json
import asyncio
import logging
import urllib.parse
from typing import Optional, Literal

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.routers.auth import get_current_user
from app.services.llm import llm_service
from app.providers.ollama_provider import get_ollama_client
from app.services.worker_health import worker_health

logger = logging.getLogger("english_brain.ai")
router = APIRouter(prefix="/ai", tags=["ai"])

# ──────────────────────────────────────────────────────────────────────────────
# Streaming de Free Talk (SSE) — ADITIVO. No altera /free-talk (no streaming),
# que sigue siendo la red de seguridad si esto falla o el proxy no hace flush.
# ──────────────────────────────────────────────────────────────────────────────

# Limita cuantos turnos LLM en streaming corren a la vez (1 GPU -> cola ordenada
# en vez de saturar la VRAM). Ajustable; 2 es conservador para una RTX 2060.
_FREE_TALK_STREAM_SEM = asyncio.Semaphore(2)

# Prompt de conversacion (texto plano, respuesta corta -> menos latencia).
FREE_TALK_STREAM_SYSTEM = (
    "You are Lito, a warm, sharp senior tech lead and English coach. "
    "You are having a spoken conversation about '{topic}' with a CEFR {target_level} learner. "
    "Reply in 2-3 short, natural spoken sentences and end with one engaging follow-up question. "
    "Plain conversational text only: no markdown, no bullet points, no JSON, no headings."
)


def _sse(event: str, data: dict) -> str:
    """Formatea un evento Server-Sent Events."""
    return f"event: {event}\ndata: {json.dumps(data, ensure_ascii=False)}\n\n"


async def _free_talk_feedback(user_transcript: str, target_level: str) -> dict:
    """Feedback pedagogico (JSON) del turno, en una llamada corta aparte.

    Se ejecuta DESPUES de la respuesta hablada, mientras el alumno ya la escucha.
    Nunca lanza: ante cualquier fallo devuelve {} (el turno sigue siendo valido).
    """
    try:
        ollama = get_ollama_client()
        system = (
            "You are an English coach. Analyse ONLY the student's utterance and return STRICT JSON "
            "with keys: grammar_corrections (list of {original, correction, explanation}), "
            "vocabulary_suggestions (list of {term, explanation, c1Alternative}), "
            "pronunciation_tips (list of strings), fluency_score (integer 0-100). "
            f"Target CEFR level {target_level}. If there are no issues, use empty lists. "
            "Explanations in Spanish."
        )
        res = await ollama.chat(
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user_transcript},
            ],
            temperature=0.2,
            fmt="json",
            num_ctx=1536,
            num_predict=300,
        )
        if not res or not res.get("response"):
            return {}
        return json.loads(res["response"])
    except Exception as exc:  # noqa: BLE001
        logger.warning("free-talk feedback fallo (no bloqueante): %s", exc)
        return {}


# ──────────────────────────────────────────────────────────────────────────────
# Request / Response schemas
# ──────────────────────────────────────────────────────────────────────────────

class GrammarCheckRequest(BaseModel):
    sentence: str = Field(..., min_length=2, max_length=1000)

class VocabularyRequest(BaseModel):
    word: str = Field(..., min_length=1, max_length=100)

class FeedbackRequest(BaseModel):
    text: str = Field(..., min_length=2, max_length=2000)
    context: str = Field(default="general", description="grammar|vocabulary|interview|general")

class FeedbackScoreRequest(BaseModel):
    score: int = Field(..., ge=-1, le=1, description="-1 confuso | 0 neutral | 1 util")
    error_tag: Optional[str] = Field(None, max_length=64)
    notes: Optional[str] = Field(None, max_length=500)

class AiStatusResponse(BaseModel):
    gpu_online: bool
    model_active: str
    ollama_url: str
    available_models: list[str]

class GrammarCheckResponse(BaseModel):
    has_errors: bool
    original: str
    corrected: Optional[str] = None
    error_type: Optional[str] = None
    explanation: Optional[str] = None
    example_correct: Optional[str] = None
    cefr_level: Optional[str] = None
    engine_used: str = "fast"
    latency_ms: Optional[float] = None

class VocabularyResponse(BaseModel):
    word: str
    ipa: Optional[str] = None
    translation: str
    cefr_level: Optional[str] = None
    definition: str
    examples: list[str] = []
    synonyms: list[str] = []
    collocations: list[str] = []
    memory_tip: Optional[str] = None
    engine_used: str = "fast"

class AudioAnalysisResponse(BaseModel):
    transcript: str
    grammar_errors: list[dict] = []
    pronunciation_issues: list[str] = []
    fluency_score: int = 70
    vocabulary_level: Optional[str] = None
    feedback: str = ""
    strengths: list[str] = []
    improvements: list[str] = []
    engine_used: str = "fast"


class FreeTalkResponse(BaseModel):
    user_transcript: str
    ai_reply_text: str
    ai_reply_audio_url: Optional[str] = None
    grammar_corrections: list[dict] = []
    vocabulary_suggestions: list[dict] = []
    pronunciation_tips: list[dict] = []
    fluency_score: int = 80
    engine_used: str = "fast"


# ──────────────────────────────────────────────────────────────────────────────
# Endpoints
# ──────────────────────────────────────────────────────────────────────────────

@router.get("/status", response_model=AiStatusResponse)
async def ai_status():
    """Estado del worker GPU: modelo activo, modelos disponibles, online/offline."""
    ollama = get_ollama_client()
    from app.config import settings
    gpu_online = await ollama.is_available()
    return AiStatusResponse(
        gpu_online=gpu_online,
        model_active=settings.OLLAMA_MODEL,
        ollama_url=settings.GPU_WORKER_URL or settings.OLLAMA_URL,
        available_models=ollama._available_models if gpu_online else [],
    )


@router.post("/grammar-check", response_model=GrammarCheckResponse)
async def grammar_check(
    body: GrammarCheckRequest,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Corrige un error gramatico en una frase inglesa. Respuesta en espanol."""
    result = await llm_service.check_grammar(
        sentence=body.sentence, db=db, user_id=current_user
    )

    if result is None:
        # Fallback offline: sin corrección LLM
        return GrammarCheckResponse(
            has_errors=False, original=body.sentence,
            explanation="Worker GPU offline. Conéctate para obtener corrección detallada.",
            engine_used="standard",
        )

    return GrammarCheckResponse(
        has_errors=result.get("has_errors", False),
        original=result.get("original", body.sentence),
        corrected=result.get("corrected"),
        error_type=result.get("error_type"),
        explanation=result.get("explanation"),
        example_correct=result.get("example_correct"),
        cefr_level=result.get("cefr_level"),
        engine_used="fast",
    )


@router.post("/vocabulary", response_model=VocabularyResponse)
async def vocabulary_lookup(
    body: VocabularyRequest,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Devuelve definicion pedagogica, IPA, ejemplos y truco mnemotecnico de una palabra."""
    result = await llm_service.explain_vocabulary(
        word=body.word, db=db, user_id=current_user
    )

    if result is None:
        return VocabularyResponse(
            word=body.word, translation="(sin conexión GPU)",
            definition="Worker GPU offline. Conéctate para obtener definición detallada.",
            engine_used="standard",
        )

    return VocabularyResponse(
        word=result.get("word", body.word),
        ipa=result.get("ipa"),
        translation=result.get("translation", ""),
        cefr_level=result.get("cefr_level"),
        definition=result.get("definition", ""),
        examples=result.get("examples", []),
        synonyms=result.get("synonyms", []),
        collocations=result.get("collocations", []),
        memory_tip=result.get("memory_tip"),
        engine_used="fast",
    )


@router.post("/analyze-audio", response_model=AudioAnalysisResponse)
async def analyze_audio(
    file: UploadFile = File(...),
    context_type: str = Form(default="speaking"),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """
    Recibe un audio, lo transcribe (STT) y lo analiza pedagogicamente con LLM.
    context_type: speaking | dictation | shadowing | pronunciation
    """
    audio_bytes = await file.read()
    if not audio_bytes:
        raise HTTPException(status_code=400, detail="Audio vacio")

    # STT
    from app.providers.router import provider_router
    transcript, stt_engine = await provider_router.transcribe(
        audio_bytes, file.filename or "audio.m4a"
    )
    if not transcript:
        transcript = "(Audio inaudible)"

    # Analisis LLM
    analysis = await llm_service.analyze_transcript(
        transcript=transcript, context_type=context_type,
        db=db, user_id=current_user,
    )

    engine = "fast" if stt_engine == "fast" else "standard"

    if analysis is None:
        return AudioAnalysisResponse(
            transcript=transcript,
            feedback="Transcripcion obtenida. Conéctate al worker GPU para analisis detallado.",
            engine_used=engine,
        )

    return AudioAnalysisResponse(
        transcript=transcript,
        grammar_errors=analysis.get("grammar_errors", []),
        pronunciation_issues=analysis.get("pronunciation_issues", []),
        fluency_score=analysis.get("fluency_score", 0),
        vocabulary_level=analysis.get("vocabulary_level"),
        feedback=analysis.get("feedback", ""),
        strengths=analysis.get("strengths", []),
        improvements=analysis.get("improvements", []),
        engine_used=engine,
    )


@router.post("/feedback")
async def ai_feedback(
    body: FeedbackRequest,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Feedback general: texto libre → analisis LLM segun contexto."""
    system_map = {
        "grammar": "Eres Lito, tutor de ingles. Analiza el texto del alumno y da feedback gramatical en espanol.",
        "vocabulary": "Eres un profesor de ingles. Sugiere vocabulario mas avanzado para el texto dado. Responde en espanol.",
        "interview": "Eres un coach de entrevistas. Da feedback sobre claridad y estructura del texto. Responde en espanol.",
        "general": "Eres Lito, tutor de ingles. Da feedback pedagogico util en espanol sobre el texto del alumno.",
    }
    system_prompt = system_map.get(body.context, system_map["general"])

    ollama = get_ollama_client()
    result = await ollama.generate_feedback(
        prompt=body.text, system_prompt=system_prompt, temperature=0.25,
        num_ctx=1536, num_predict=140,
    )

    if not result:
        return {"feedback": "Worker GPU offline. Practica y vuelve a intentarlo.", "engine_used": "standard"}

    return {
        "feedback": result.get("response", ""),
        "engine_used": result.get("engine_used", "fast"),
        "tokens_per_sec": result.get("tokens_per_sec"),
        "latency_ms": result.get("latency_ms"),
        "model_used": result.get("model_used"),
    }


@router.post("/feedback/{log_id}/score")
async def rate_feedback(
    log_id: int,
    body: FeedbackScoreRequest,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Registra puntuacion 👍/👎 del usuario en LlmInteractionLog para el bucle de auto-aprendizaje."""
    from sqlalchemy import select
    from app.models import LlmInteractionLog
    res = await db.execute(select(LlmInteractionLog).where(LlmInteractionLog.id == log_id))
    log = res.scalar_one_or_none()
    if not log:
        raise HTTPException(status_code=404, detail="Log no encontrado")
    log.user_feedback_score = body.score
    log.error_tag = body.error_tag
    log.notes = body.notes
    await db.commit()
    return {"ok": True, "log_id": log_id, "score": body.score}


@router.post("/free-talk", response_model=FreeTalkResponse)
async def free_talk_turn(
    file: Optional[UploadFile] = File(None),
    user_text: Optional[str] = Form(None),
    conversation_history_json: Optional[str] = Form(None),
    topic: str = Form(default="General Tech & Architecture"),
    target_level: str = Form(default="B2"),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """
    Turno de conversacion libre (Free Talk) con orbe interactivo:
    Acepta audio (STT) o texto directo, genera respuesta con LLM Lito,
    consejos gramaticales sutiles, sugerencias de vocabulario y audio TTS.
    """
    import json
    import urllib.parse
    from app.providers.router import provider_router

    user_transcript = ""
    stt_engine = "fast"

    if file is not None:
        audio_bytes = await file.read()
        if audio_bytes:
            t, eng = await provider_router.transcribe(audio_bytes, file.filename or "speech.m4a")
            user_transcript = t or ""
            stt_engine = eng

    if not user_transcript and user_text:
        user_transcript = user_text.strip()

    if not user_transcript:
        user_transcript = "Hello Lito! Let's practice some English for tech interviews."

    history = []
    if conversation_history_json:
        try:
            history = json.loads(conversation_history_json)
        except Exception:
            history = []

    res = await llm_service.free_talk_turn(
        user_transcript=user_transcript,
        conversation_history=history,
        topic=topic,
        target_level=target_level,
        db=db,
        user_id=current_user,
    )

    reply_text = res.get("reply", "")
    tts_url = f"/api/tts?text={urllib.parse.quote(reply_text)}" if reply_text else None

    return FreeTalkResponse(
        user_transcript=user_transcript,
        ai_reply_text=reply_text,
        ai_reply_audio_url=tts_url,
        grammar_corrections=res.get("grammar_corrections", []),
        vocabulary_suggestions=res.get("vocabulary_suggestions", []),
        pronunciation_tips=res.get("pronunciation_tips", []),
        fluency_score=res.get("fluency_score", 80),
        engine_used=res.get("engine_used", stt_engine),
    )


@router.post("/free-talk/stream")
async def free_talk_stream(
    file: Optional[UploadFile] = File(None),
    user_text: Optional[str] = Form(None),
    conversation_history_json: Optional[str] = Form(None),
    topic: str = Form(default="General Tech & Architecture"),
    target_level: str = Form(default="B2"),
    current_user: str = Depends(get_current_user),
):
    """
    Free Talk en STREAMING (SSE). ADITIVO: si el worker GPU esta offline o algo
    falla, emite un evento `fallback` y el cliente reintenta con /free-talk normal.

    Eventos emitidos (text/event-stream):
      transcript  -> {"user_transcript", "stt_engine"}   (lo que dijiste)
      delta       -> {"t"}                                (trozo de respuesta)
      reply_done  -> {"reply", "tokens_per_sec"}          (respuesta completa)
      audio       -> {"tts_url"}                          (URL para reproducir)
      feedback    -> {"grammar_corrections", "vocabulary_suggestions",
                      "pronunciation_tips", "fluency_score"}
      done        -> {"engine_used"}
      fallback    -> {"reason"}                           (usar /free-talk normal)
    """
    # STT ANTES del generador (leemos el UploadFile aqui, no dentro del stream).
    from app.providers.router import provider_router

    user_transcript = ""
    stt_engine = "fast"
    if file is not None:
        audio_bytes = await file.read()
        if audio_bytes:
            try:
                t, eng = await provider_router.transcribe(
                    audio_bytes, file.filename or "speech.m4a"
                )
                user_transcript = t or ""
                stt_engine = eng
            except Exception as exc:  # noqa: BLE001
                logger.warning("STT stream fallo: %s", exc)

    if not user_transcript and user_text:
        user_transcript = user_text.strip()
    if not user_transcript:
        user_transcript = "Hello Lito! Let's practice some English for tech interviews."

    history = []
    if conversation_history_json:
        try:
            history = json.loads(conversation_history_json)
        except Exception:
            history = []

    async def event_gen():
        yield _sse("transcript", {"user_transcript": user_transcript, "stt_engine": stt_engine})

        ollama = get_ollama_client()
        # Sin GPU no hay conversacion real -> que el cliente use el flujo normal.
        if not await ollama.is_available():
            yield _sse("fallback", {"reason": "gpu_offline"})
            return

        system_prompt = FREE_TALK_STREAM_SYSTEM.format(topic=topic, target_level=target_level)
        messages = [{"role": "system", "content": system_prompt}]
        if history:
            messages.extend(history[-6:])
        messages.append({"role": "user", "content": user_transcript})

        full_reply = ""
        try:
            async with _FREE_TALK_STREAM_SEM:
                async for ev in ollama.chat_stream(
                    messages=messages, temperature=0.5, num_ctx=2048, num_predict=200
                ):
                    if "delta" in ev:
                        full_reply += ev["delta"]
                        yield _sse("delta", {"t": ev["delta"]})
                    elif ev.get("done"):
                        yield _sse(
                            "reply_done",
                            {"reply": full_reply.strip(), "tokens_per_sec": ev.get("tokens_per_sec")},
                        )
        except Exception as exc:  # noqa: BLE001
            logger.warning("free-talk stream LLM fallo: %s", exc)
            if not full_reply.strip():
                yield _sse("fallback", {"reason": "stream_error"})
                return

        reply_text = full_reply.strip()
        if not reply_text:
            yield _sse("fallback", {"reason": "empty_reply"})
            return

        tts_url = f"/api/tts?text={urllib.parse.quote(reply_text)}"
        yield _sse("audio", {"tts_url": tts_url})

        feedback = await _free_talk_feedback(user_transcript, target_level)
        yield _sse(
            "feedback",
            {
                "grammar_corrections": feedback.get("grammar_corrections", []),
                "vocabulary_suggestions": feedback.get("vocabulary_suggestions", []),
                "pronunciation_tips": feedback.get("pronunciation_tips", []),
                "fluency_score": feedback.get("fluency_score", 80),
            },
        )
        yield _sse("done", {"engine_used": "fast"})

    return StreamingResponse(
        event_gen(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",  # pista para proxies (nginx); en Caddy usar flush_interval -1
            "Connection": "keep-alive",
        },
    )

