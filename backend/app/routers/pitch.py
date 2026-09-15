"""Endpoint del Comparador de Entonacion (Pitch F0).

POST /api/pitch/analyze  (multipart)
  file  : audio grabado por el alumno (m4a/opus/webm/wav)
  text  : (opcional) texto objetivo -> se sintetiza la voz nativa como referencia
  voice : (opcional) voz TTS de referencia

Devuelve dos curvas de entonacion normalizadas (alumno + nativo) y una similitud 0..100.
Si no hay 'text' (p.ej. respuesta libre de entrevista), devuelve solo la curva del alumno.
"""
import os
import json
import hashlib
import logging
from typing import Optional

from fastapi import APIRouter, File, Form, UploadFile
from pydantic import BaseModel
from app.config import settings

from app.services import pitch as pitch_service
from app.services.tts import tts_service

logger = logging.getLogger("english_brain.pitch_router")
router = APIRouter(prefix="/pitch", tags=["pitch"])


def _pitch_cache_path(text: str, voice: str) -> str:
    key = hashlib.sha256(f"{text.strip()}_{voice}_pitchpat_v1".encode("utf-8")).hexdigest()[:18]
    d = os.path.join(settings.AUDIO_CACHE_DIR, "pitch")
    os.makedirs(d, exist_ok=True)
    return os.path.join(d, f"pf_{key}.json")


async def _get_native_pattern(text: str, voice: str):
    """Curva de entonacion nativa cacheada en disco (misma para TODOS los usuarios).
    Se calcula una sola vez por frase; despues se reutiliza."""
    p = _pitch_cache_path(text, voice)
    if os.path.exists(p):
        try:
            with open(p, "r") as f:
                return json.load(f)
        except Exception:
            pass
    try:
        fname = await tts_service.synthesize(text=text.strip(), voice=voice, rate="+0%")
        if not fname:
            return None
        fpath = tts_service.get_audio_path(fname)
        if not fpath or not os.path.exists(fpath):
            return None
        with open(fpath, "rb") as f:
            pat = pitch_service.compute_pattern(f.read())
        if pat is not None:
            try:
                with open(p, "w") as f:
                    json.dump(pat, f)
            except Exception:
                pass
        return pat
    except Exception as e:
        logger.warning(f"native pitch fallo: {e}")
        return None


class PitchPrefetchIn(BaseModel):
    items: list[str]
    voice: str = "am_michael"


@router.post("/prefetch")
async def prefetch_pitch(body: PitchPrefetchIn):
    """Precalcula la curva de entonacion nativa de cada frase fija (para todos los
    usuarios). Asi /analyze solo procesa la grabacion del alumno."""
    computed = 0
    cached = 0
    err = 0
    seen = set()
    for t in body.items:
        t = (t or "").strip()
        if not t or t.lower() in seen:
            continue
        seen.add(t.lower())
        if os.path.exists(_pitch_cache_path(t, body.voice)):
            cached += 1
            continue
        pat = await _get_native_pattern(t, body.voice)
        if pat is not None:
            computed += 1
        else:
            err += 1
    return {"total": len(seen), "computed_now": computed, "already_cached": cached, "errors": err}




@router.get("/status")
async def pitch_status():
    return {"available": pitch_service.is_available()}


@router.post("/analyze")
async def analyze_pitch(
    file: UploadFile = File(...),
    text: Optional[str] = Form(None),
    voice: str = Form("en-US-GuyNeural"),
):
    user_bytes = await file.read()
    if not user_bytes:
        return {"ok": False, "available": pitch_service.is_available(), "reason": "empty"}

    if text and text.strip() and pitch_service.is_available():
        ref_pat = await _get_native_pattern(text.strip(), voice)
        if ref_pat is not None:
            return pitch_service.analyze_user_vs_ref(user_bytes, ref_pat)

    return pitch_service.analyze(user_bytes, None)
