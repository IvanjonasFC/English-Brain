import os
import logging
import httpx
from app.config import settings, live_chain, mark_worker_up, mark_worker_down
from app.services.ai_client import ai_client, gpu_semaphore

logger = logging.getLogger("english_brain.stt")


class STTService:
    def __init__(self):
        self._cached_model = None

    def _bases(self) -> list[str]:
        """Cadena de STT: portatil (.65, GPU, mejor modelo) primario y el
        contenedor speaches del NAS (siempre encendido) como respaldo REAL.
        live_chain salta el portatil si esta en cooldown por caida reciente."""
        return live_chain(settings.SPEACHES_URL,
                          getattr(settings, "SPEACHES_FALLBACK_URL", ""))

    async def _models_for(self, base: str) -> list[str]:
        models = []
        if self._cached_model:
            models.append(self._cached_model)
        try:
            res = await ai_client.get(f"{base}/models", timeout=2.0)
            if res.status_code == 200:
                data = res.json().get("data", [])
                for item in data:
                    mid = item.get("id")
                    if mid and mid not in models:
                        models.append(mid)
        except Exception as e:
            logger.debug(f"Speaches models probe {base}: {e}")

        # Si el endpoint /models ya nos dio los modelos instalados, usarlos directamente
        if models:
            return models

        # Solo si no respondió /models, usar un fallback acotado (máximo 2 intentos)
        return ["Systran/faster-whisper-base", "base", "whisper-1"]

    async def transcribe_audio(self, audio_bytes: bytes, filename: str = "audio.m4a") -> str:
        """
        Envia el audio a Speaches / faster-whisper (endpoint OpenAI-compatible).
        Prueba el portatil por cable (.65) y, si no responde, el Speaches del NAS.
        connect corto + circuit breaker para descartar rapido un backend caido.
        """
        if not audio_bytes or len(audio_bytes) < 500:
            return ""

        mime = "audio/mp4" if filename.endswith((".m4a", ".mp4")) else ("audio/wav" if filename.endswith(".wav") else "audio/aac")
        timeout_val = getattr(settings, "WHISPER_TIMEOUT", 5.0)

        for base in self._bases():
            endpoint = f"{base}/audio/transcriptions"
            models_to_try = await self._models_for(base)
            base_down = False
            for model_name in models_to_try:
                try:
                    async with gpu_semaphore:
                        files = {"file": (filename, audio_bytes, mime)}
                        data = {"model": model_name, "language": "en"}
                        response = await ai_client.post(endpoint, files=files, data=data, timeout=timeout_val)

                        if response.status_code == 200:
                            res_data = response.json()
                            text = (res_data.get("text") or "").strip()
                            if text:
                                mark_worker_up(base)
                                self._cached_model = model_name
                                logger.info(f"STT transcribed ({model_name}@{base}): {text}")
                                return text
                except (httpx.ConnectError, httpx.ConnectTimeout) as e:
                    mark_worker_down(base)  # backend caido: saltarlo 30s (va al NAS)
                    base_down = True
                    logger.debug(f"STT base {base} caido (cooldown): {e}")
                    break
                except Exception as e:
                    logger.debug(f"STT attempt {model_name}@{base} failed: {e}")
            if base_down:
                continue

        return ""


stt_service = STTService()
