import os
import time
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    PROJECT_NAME: str = "English Brain API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api"

    # Services URLs
    # Portatil por cable Ethernet (.65). SIN fallback .66: es el mismo portatil
    # (no da resiliencia, solo lag). El unico con fallback real es el STT (-> NAS).
    OLLAMA_URL: str = Field(default="http://192.168.0.65:11434", validation_alias="OLLAMA_URL")
    OLLAMA_FALLBACK_URL: str = Field(default="", validation_alias="OLLAMA_FALLBACK_URL")
    # lito-fast:latest (base Phi-4 Mini 3.8B sin thinking, optimizado C1 profesional).
    OLLAMA_MODEL: str = Field(default="lito-fast:latest", validation_alias="OLLAMA_MODEL")
    OLLAMA_FALLBACK_MODEL: str = Field(default="qwen3:4b", validation_alias="OLLAMA_FALLBACK_MODEL")
    # Timeout de GENERACION (largo): un 7B produciendo JSON tarda 8-30s. Separado del
    # de salud/tags (GPU_WORKER_TIMEOUT, corto) para no cortar cada evaluacion a los 4s.
    OLLAMA_GEN_TIMEOUT: float = Field(default=90.0, validation_alias="OLLAMA_GEN_TIMEOUT")
    # Mantiene el modelo residente en VRAM entre llamadas (evita arranque en frio
    # en cada pestaña). Formato Ollama: "30m", "1h", "-1" = para siempre.
    OLLAMA_KEEP_ALIVE: str = Field(default="30m", validation_alias="OLLAMA_KEEP_ALIVE")
    # STT/TTS Speaches: primario portatil (.65, GPU, modelo mejor); respaldo el
    # contenedor speaches del propio stack de la NAS (CPU, siempre encendido).
    SPEACHES_URL: str = Field(default="http://192.168.0.65:8001/v1", validation_alias="SPEACHES_URL")
    SPEACHES_FALLBACK_URL: str = Field(default="http://speaches:8000/v1", validation_alias="SPEACHES_FALLBACK_URL")
    WHISPER_TIMEOUT: float = Field(default=5.0, validation_alias="WHISPER_TIMEOUT")
    ANKI_CONNECT_URL: str = Field(default="http://localhost:8765", validation_alias="ANKI_CONNECT_URL")

    # Storage paths
    DB_PATH: str = Field(default="./data/coach.db", validation_alias="DB_PATH")
    AUDIO_CACHE_DIR: str = Field(default="./audio_cache", validation_alias="AUDIO_CACHE_DIR")

    # Security
    API_KEY: str = Field(default="super-secret-coach-key-123", validation_alias="API_KEY")
    JWT_SECRET: str = Field(default="super-secret-jwt-key-xyz-789-secure-token", validation_alias="JWT_SECRET")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200  # 30 days

    # Observability & Logging
    LOG_LEVEL: str = Field(default="INFO", validation_alias="LOG_LEVEL")
    LOG_FILE_PATH: str = Field(default="./data/logs/app.log", validation_alias="LOG_FILE_PATH")

    # Mocks for tests / local development without live GPU services
    MOCK_SERVICES_IF_UNAVAILABLE: bool = True

    # Hybrid architecture: optional GPU worker laptop (RTX 2060).
    # OLLAMA_URL and SPEACHES_URL point at the worker when it is online.
    GPU_WORKER_ENABLED: bool = Field(default=True, validation_alias="GPU_WORKER_ENABLED")
    GPU_WORKER_URL: str = Field(default="", validation_alias="GPU_WORKER_URL")
    GPU_WORKER_TIMEOUT: float = Field(default=4.0, validation_alias="GPU_WORKER_TIMEOUT")
    GPU_WORKER_HEALTH_TTL: int = Field(default=15, validation_alias="GPU_WORKER_HEALTH_TTL")
    # Optional NAS-local whisper.cpp HTTP server for STT fallback (OpenAI-compatible).
    LOCAL_WHISPER_URL: str = Field(default="", validation_alias="LOCAL_WHISPER_URL")

    # ── Scoring fonético de pronunciación (wav2vec2 en el portátil GPU) ──
    # Solo existe en el portatil (.65). Sin fallback (el NAS no tiene wav2vec2).
    PHONEME_WORKER_URL: str = Field(default="http://192.168.0.65:8100", validation_alias="PHONEME_WORKER_URL")
    PHONEME_WORKER_FALLBACK_URL: str = Field(default="", validation_alias="PHONEME_WORKER_FALLBACK_URL")
    PHONEME_WORKER_TIMEOUT: float = Field(default=5.0, validation_alias="PHONEME_WORKER_TIMEOUT")
    PHONEME_LOCAL_FALLBACK: bool = Field(default=True, validation_alias="PHONEME_LOCAL_FALLBACK")

    # ── Forced alignment (Montreal Forced Aligner) — Fase 2 ──
    # Solo existe en el portatil (.65). Sin fallback (el NAS no tiene MFA).
    MFA_WORKER_URL: str = Field(default="http://192.168.0.65:8200", validation_alias="MFA_WORKER_URL")
    MFA_WORKER_FALLBACK_URL: str = Field(default="", validation_alias="MFA_WORKER_FALLBACK_URL")
    MFA_WORKER_TIMEOUT: float = Field(default=6.0, validation_alias="MFA_WORKER_TIMEOUT")
    MFA_ENABLED: bool = Field(default=True, validation_alias="MFA_ENABLED")

    model_config = {
        "env_file": ".env",
        "extra": "allow"
    }


def url_chain(*urls: str) -> list[str]:
    """Ordena URLs de worker (primario, fallback) quitando vacios y duplicados."""
    seen: set[str] = set()
    out: list[str] = []
    for u in urls:
        cleaned = (u or "").rstrip("/")
        if cleaned and cleaned not in seen:
            seen.add(cleaned)
            out.append(cleaned)
    return out


# ── Circuit breaker por worker ────────────────────────────────────────────────
# Tras un fallo de CONEXION (worker/portatil apagado) marcamos esa URL "caida"
# durante _WORKER_COOLDOWN segundos y no la reintentamos: la degradacion es
# instantanea (sin gastar el connect-timeout en cada intento). Se reactiva sola
# al expirar el cooldown, o antes si otra llamada la ve viva (mark_worker_up).
_worker_down: dict[str, float] = {}
_WORKER_COOLDOWN = 30.0  # segundos


def worker_is_down(url: str) -> bool:
    exp = _worker_down.get((url or "").rstrip("/"))
    return exp is not None and time.time() < exp


def mark_worker_down(url: str) -> None:
    _worker_down[(url or "").rstrip("/")] = time.time() + _WORKER_COOLDOWN


def mark_worker_up(url: str) -> None:
    _worker_down.pop((url or "").rstrip("/"), None)


def live_chain(*urls: str) -> list[str]:
    """url_chain saltando las URLs en cooldown por una caida de conexion reciente.
    Puede devolver lista VACIA (todo caido) -> el caller degrada sin lag."""
    return [u for u in url_chain(*urls) if not worker_is_down(u)]


settings = Settings()

# Ensure directories exist
os.makedirs(os.path.dirname(settings.DB_PATH) or ".", exist_ok=True)
os.makedirs(settings.AUDIO_CACHE_DIR, exist_ok=True)
if settings.LOG_FILE_PATH:
    try:
        os.makedirs(os.path.dirname(settings.LOG_FILE_PATH) or ".", exist_ok=True)
    except Exception:
        pass
