"""Cliente del worker MFA (alineación forzada). Devuelve la alineación fonema
a fonema con timings, o None si el worker no está disponible."""
import logging
from typing import Optional

import httpx

from app.services.ai_client import ai_client, gpu_semaphore
from app.config import settings, live_chain, mark_worker_up, mark_worker_down

logger = logging.getLogger("english_brain.mfa")


async def align(audio_bytes: bytes, text: str, filename: str = "audio.wav") -> Optional[dict]:
    if not settings.MFA_ENABLED:
        return None
    # Solo el portatil (.65) tiene MFA; sin fallback (el NAS no lo tiene).
    # live_chain salta la URL si esta en cooldown por caida reciente -> sin lag.
    urls = live_chain(settings.MFA_WORKER_URL,
                      getattr(settings, "MFA_WORKER_FALLBACK_URL", ""))
    for url in urls:
        try:
            async with gpu_semaphore:
                files = {"file": (filename or "audio.wav", audio_bytes, "application/octet-stream")}
                r = await ai_client.post(f"{url}/align", files=files, data={"text": text}, timeout=settings.MFA_WORKER_TIMEOUT)
                if r.status_code == 200:
                    mark_worker_up(url)
                    return r.json()
        except (httpx.ConnectError, httpx.ConnectTimeout) as e:
            mark_worker_down(url)  # portatil apagado: no reintentar 30s
            logger.info(f"MFA worker {url} caido (cooldown): {e}")
            continue
        except Exception as e:
            logger.info(f"MFA worker {url} error: {e}")
            continue
    return None
