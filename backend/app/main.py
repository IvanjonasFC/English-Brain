import os
import json
import logging
import asyncio
import time
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import select, func
import httpx

from app.config import settings
from app.database import engine, Base, AsyncSessionLocal
from app.models import Question
from app.routers import auth, questions, sessions, mistakes, cards, export, stats, tts, resources, profile, pronunciation, packs
from app.routers import comprehension
from app.routers import measurements
from app.routers import pitch
from app.routers import ai as ai_router
from app.middleware import LoggingMiddleware
from app.routers import worker
from app.routers import content
from app.routers import client_log
from app.providers.ollama_provider import get_ollama_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("english_brain")

async def check_service_status(url: str, probe_path: str = "", timeout: float = 3.0) -> dict:
    target = f"{url.rstrip('/')}/{probe_path.lstrip('/')}".rstrip('/')
    start = time.perf_counter()
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(timeout, connect=1.5)) as client:
            res = await client.get(target)
            latency_ms = round((time.perf_counter() - start) * 1000, 1)
            if res.status_code < 500:
                return {"status": "online", "url": url, "latency_ms": latency_ms, "http_status": res.status_code}
            return {"status": "error", "url": url, "latency_ms": latency_ms, "http_status": res.status_code}
    except Exception as exc:
        return {"status": "unreachable", "url": url, "error": str(exc)}

async def check_ollama() -> bool:
    try:
        ollama = get_ollama_client()
        is_ok = await ollama.is_available()
        if is_ok:
            models = await ollama.get_available_models()
            logger.info(f"[LLM / GPU Worker] Conectado en {settings.OLLAMA_URL} — Modelos: {models}")
            return True
        return False
    except Exception as exc:
        logger.debug(f"[LLM] Check error: {exc}")
        return False

async def check_speaches() -> bool:
    try:
        res = await check_service_status(settings.SPEACHES_URL, "models", timeout=3.0)
        return res.get("status") == "online"
    except Exception as exc:
        logger.debug(f"[Speaches] Check error: {exc}")
        return False

async def warm_up(name: str, check_fn, app: FastAPI, timeout: float = 8.0):
    delay = 2.0
    while True:
        try:
            if asyncio.iscoroutinefunction(check_fn):
                res = await asyncio.wait_for(check_fn(), timeout=timeout)
            else:
                res = await asyncio.wait_for(asyncio.to_thread(check_fn), timeout=timeout)
            
            if res:
                setattr(app.state, f"{name}_ready", True)
                logger.info(f"[{name.upper()}]: listo y operativo")
                return
            else:
                setattr(app.state, f"{name}_ready", False)
                logger.warning(f"[{name.upper()}]: no disponible; reintento en {delay:.0f}s")
        except asyncio.CancelledError:
            logger.info(f"[{name.upper()}]: tarea de warm-up cancelada")
            raise
        except Exception as e:
            setattr(app.state, f"{name}_ready", False)
            logger.warning(f"[{name.upper()}]: no disponible ({e}); reintento en {delay:.0f}s")
        
        await asyncio.sleep(delay)
        delay = min(delay * 2, 120.0)

async def seed_questions_if_needed():
    seed_file = os.path.join(os.path.dirname(__file__), "seed", "questions.json")
    if os.path.exists(seed_file):
        with open(seed_file, "r", encoding="utf-8") as f:
            q_data = json.load(f)
        async with AsyncSessionLocal() as db:
            res = await db.execute(select(func.count(Question.id)))
            count = res.scalar() or 0
            if count < len(q_data):
                logger.info(f"Seeding database with expanded questions from {seed_file} (current count: {count}, target: {len(q_data)})")
                from sqlalchemy import delete
                await db.execute(delete(Question))
                for item in q_data:
                    q = Question(
                        category=item.get("category", "tech"),
                        difficulty=item.get("difficulty", "junior"),
                        title=item.get("title", ""),
                        text=item.get("text", ""),
                        model_answer=item.get("model_answer", ""),
                        tips=item.get("tips", "")
                    )
                    db.add(q)
                await db.commit()
                logger.info(f"Successfully seeded {len(q_data)} interview questions!")

def _migrate_pedagogy_columns(sync_conn):
    """Idempotently add pedagogy columns to existing SQLite tables."""
    def existing(table):
        rows = sync_conn.exec_driver_sql(f"PRAGMA table_info({table})").fetchall()
        return {r[1] for r in rows}
    card_cols = existing("cards")
    for name, ddl in [
        ("user_id", "TEXT DEFAULT 'user-ivan'"),
        ("source_type", "TEXT DEFAULT 'interview_mistake'"),
        ("item_type", "TEXT DEFAULT 'sentence_correction'"),
        ("unit_id", "TEXT"),
        ("skill", "TEXT DEFAULT 'speaking'"),
    ]:
        if name not in card_cols:
            sync_conn.exec_driver_sql(f"ALTER TABLE cards ADD COLUMN {name} {ddl}")
    q_cols = existing("questions")
    for name, ddl in [
        ("track", "TEXT"), ("scenario", "TEXT"),
        ("objective_id", "TEXT"), ("difficulty_band", "TEXT"),
    ]:
        if name not in q_cols:
            sync_conn.exec_driver_sql(f"ALTER TABLE questions ADD COLUMN {name} {ddl}")


def _migrate_pronunciation_columns(sync_conn):
    """Idempotently add Fase-1 columns to pronunciation_attempts if it pre-exists."""
    rows = sync_conn.exec_driver_sql("PRAGMA table_info(pronunciation_attempts)").fetchall()
    if not rows:
        return  # tabla nueva -> create_all ya la crea completa
    cols = {r[1] for r in rows}
    for name, ddl in [
        ("category", "TEXT"), ("exercise_type", "TEXT DEFAULT 'single_word'"),
        ("target_ipa", "TEXT"), ("heard_ipa", "TEXT"), ("wrong_phonemes", "TEXT"),
        ("confidence", "REAL DEFAULT 0.0"), ("processing_stage_failed", "TEXT"),
        ("audio_hash", "TEXT"), ("audio_ms", "INTEGER"),
        ("text_score", "INTEGER DEFAULT 0"), ("phonetic_score", "INTEGER DEFAULT 0"),
        ("is_match", "BOOLEAN DEFAULT 0"), ("engine_used", "TEXT DEFAULT 'standard'"),
    ]:
        if name not in cols:
            sync_conn.exec_driver_sql(f"ALTER TABLE pronunciation_attempts ADD COLUMN {name} {ddl}")


def _migrate_user_profiles_columns(sync_conn):
    """Idempotently add UserProfile columns if they don't exist in older SQLite DBs."""
    rows = sync_conn.exec_driver_sql("PRAGMA table_info(user_profiles)").fetchall()
    if not rows:
        return
    cols = {r[1] for r in rows}
    for name, ddl in [
        ("email", "TEXT"),
        ("avatar_url", "TEXT"),
        ("target_level", "TEXT DEFAULT 'B2'"),
        ("role_title", "TEXT DEFAULT 'Software Engineer'"),
        ("learning_goal", "TEXT DEFAULT 'interview_prep'"),
        ("daily_goal_minutes", "INTEGER DEFAULT 20"),
        ("total_xp", "INTEGER DEFAULT 0"),
        ("streak_days", "INTEGER DEFAULT 0"),
        ("pin_hash", "TEXT"),
        ("last_active_date", "DATETIME"),
        ("created_at", "DATETIME"),
    ]:
        if name not in cols:
            sync_conn.exec_driver_sql(f"ALTER TABLE user_profiles ADD COLUMN {name} {ddl}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1. Local y crítico: SQLite y tablas (no depende de red externa)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        await conn.run_sync(_migrate_pedagogy_columns)
        await conn.run_sync(_migrate_pronunciation_columns)
        await conn.run_sync(_migrate_user_profiles_columns)
    
    # 2. Local y crítico: seed si hace falta
    await seed_questions_if_needed()

    # 3. Estado inicial no bloqueante de servicios externos
    app.state.llm_ready = False
    app.state.speaches_ready = False
    app.state.warmup = [
        asyncio.create_task(warm_up("llm", check_ollama, app)),
        asyncio.create_task(warm_up("speaches", check_speaches, app)),
    ]

    yield

    # Shutdown ordenado: cancelar tareas de warm_up y cerrar conexiones
    for t in getattr(app.state, "warmup", []):
        t.cancel()
    await asyncio.gather(*getattr(app.state, "warmup", []), return_exceptions=True)

    ollama = get_ollama_client()
    await ollama.close()
    from app.services.ai_client import ai_client
    await ai_client.aclose()
    await engine.dispose()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="English Brain Backend - Orchestrator for STT, Ollama LLM, TTS and FSRS Spaced Repetition",
    lifespan=lifespan
)

# Logging & Correlation ID Middleware
app.add_middleware(LoggingMiddleware)

# CORS configuration for Web and Mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static audio cache mount
os.makedirs(settings.AUDIO_CACHE_DIR, exist_ok=True)
app.mount("/audio", StaticFiles(directory=settings.AUDIO_CACHE_DIR), name="audio")

# Include Routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(questions.router, prefix=settings.API_V1_STR)
app.include_router(sessions.router, prefix=settings.API_V1_STR)
app.include_router(mistakes.router, prefix=settings.API_V1_STR)
app.include_router(cards.router, prefix=settings.API_V1_STR)
app.include_router(export.router, prefix=settings.API_V1_STR)
app.include_router(stats.router, prefix=settings.API_V1_STR)
app.include_router(tts.router, prefix=settings.API_V1_STR)
app.include_router(resources.router)
app.include_router(profile.router)
app.include_router(pronunciation.router, prefix=settings.API_V1_STR)
app.include_router(worker.router, prefix=settings.API_V1_STR)
app.include_router(content.router, prefix=settings.API_V1_STR)
app.include_router(client_log.router, prefix=settings.API_V1_STR)
app.include_router(packs.router, prefix=settings.API_V1_STR)
app.include_router(comprehension.router, prefix=settings.API_V1_STR)
app.include_router(measurements.router, prefix=settings.API_V1_STR)
app.include_router(pitch.router, prefix=settings.API_V1_STR)
app.include_router(ai_router.router, prefix=settings.API_V1_STR)

@app.get("/api/health")
@app.get("/health")
async def health():
    """Liveness check para Docker/Caddy: SIEMPRE 200 si el proceso FastAPI sirve peticiones."""
    return {"status": "ok", "app": "English Brain API", "version": settings.VERSION}

@app.get("/api/ready")
@app.get("/ready")
async def ready(request: Request):
    """Readiness check: diagnóstico del estado real de dependencias externas."""
    llm_ready = getattr(request.app.state, "llm_ready", False)
    speaches_ready = getattr(request.app.state, "speaches_ready", False)
    ollama_client = get_ollama_client()
    gpu_models = getattr(ollama_client, "_available_models", []) if llm_ready else []

    overall = "ready" if (llm_ready and speaches_ready) else ("degraded" if settings.MOCK_SERVICES_IF_UNAVAILABLE else "waiting")

    return {
        "status": overall,
        "version": settings.VERSION,
        "services": {
            "database": {"status": "online"},
            "llm": {
                "ready": llm_ready,
                "url": settings.GPU_WORKER_URL or settings.OLLAMA_URL,
                "model": settings.OLLAMA_MODEL,
                "available_models": gpu_models,
            },
            "speaches": {
                "ready": speaches_ready,
                "url": settings.SPEACHES_URL,
            }
        }
    }

@app.get("/")
async def root():
    return {
        "app": "English Brain API",
        "docs": "/docs",
        "status": "operational"
    }

