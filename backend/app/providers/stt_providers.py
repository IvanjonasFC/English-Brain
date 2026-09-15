"""STT providers: GPU worker (Speaches/faster-whisper) and NAS CPU fallback."""
import logging
import httpx

from app.config import settings
from app.services.stt import stt_service
from .base import STTProvider, ENGINE_FAST, ENGINE_STANDARD

logger = logging.getLogger("english_brain.providers.stt")


class GpuWhisperProvider(STTProvider):
    """faster-whisper on the GPU laptop, via the OpenAI-compatible Speaches API."""
    engine = ENGINE_FAST

    async def transcribe(self, audio_bytes: bytes, filename: str = "answer.m4a") -> str:
        text = await stt_service.transcribe_audio(audio_bytes, filename=filename)
        if not text:
            raise RuntimeError("Speaches STT returned empty or unreachable")
        return text


class LocalCpuWhisperProvider(STTProvider):
    """NAS fallback. Uses a local whisper.cpp HTTP server if configured
    (LOCAL_WHISPER_URL), otherwise returns a graceful placeholder so the
    pipeline never blocks the user."""
    engine = ENGINE_STANDARD

    async def transcribe(self, audio_bytes: bytes, filename: str = "answer.m4a") -> str:
        if settings.LOCAL_WHISPER_URL:
            try:
                endpoint = f"{settings.LOCAL_WHISPER_URL}/audio/transcriptions"
                async with httpx.AsyncClient(timeout=60.0) as client:
                    files = {"file": (filename, audio_bytes, "audio/m4a")}
                    data = {"model": "base.en"}
                    resp = await client.post(endpoint, files=files, data=data)
                    resp.raise_for_status()
                    return (resp.json().get("text") or "").strip()
            except Exception as exc:  # noqa: BLE001
                logger.warning("Local whisper.cpp fallback failed: %s", exc)
        # Sin STT real (todo offline): cadena vacía. Nunca inventamos una
        # transcripción que luego se puntúe como si el alumno la hubiera dicho.
        return ""
