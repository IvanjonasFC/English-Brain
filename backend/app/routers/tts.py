import os
from typing import Optional
from fastapi import APIRouter, HTTPException, Query, BackgroundTasks
from pydantic import BaseModel
from fastapi.responses import FileResponse
from app.services.tts import tts_service

router = APIRouter(prefix="/tts", tags=["TTS"])


class PrefetchItem(BaseModel):
    text: str
    voice: Optional[str] = "en-US-GuyNeural"
    rate: Optional[str] = "+0%"


class PrefetchBatchIn(BaseModel):
    items: list[PrefetchItem]
    max_concurrency: int = 4


@router.get("")
async def get_tts_audio(
    text: str = Query(..., min_length=1, max_length=1500, description="Text to synthesize"),
    voice: str = Query("en-US-GuyNeural", description="Neural voice (en-US-GuyNeural or en-US-JennyNeural)"),
    rate: str = Query("+0%", description="Speech rate adjustment (e.g. +0% or -20% for slow phonetic mode)"),
):
    """
    Synthesizes speech using Microsoft Edge Neural TTS with local caching.
    Returns the MP3 audio directly as a streamable file.
    """
    filename = await tts_service.synthesize(text=text, voice=voice, rate=rate)
    if not filename:
        raise HTTPException(status_code=500, detail="Failed to synthesize speech")

    filepath = tts_service.get_audio_path(filename)
    if not os.path.exists(filepath):
        raise HTTPException(status_code=404, detail="Audio file not found")

    return FileResponse(
        filepath,
        media_type="audio/mpeg",
        content_disposition_type="inline",
        headers={"Cache-Control": "public, max-age=86400"},
    )


@router.get("/stats")
async def get_tts_stats():
    """
    Retorna métricas de hit-rate y estado de la caché de audio.
    Alerta si el hit-rate cae del 90%.
    """
    return tts_service.get_cache_stats()


@router.post("/prefetch")
async def prefetch_tts_batch(body: PrefetchBatchIn):
    """
    Pre-genera en lote el audio de nuevo contenido (preguntas, packs de vocabulario, etc.)
    para que la latencia en primera reproducción de los alumnos sea de 0 ms.
    """
    items_dicts = [{"text": it.text, "voice": it.voice, "rate": it.rate} for it in body.items]
    res = await tts_service.prefetch_batch(items_dicts, max_concurrency=body.max_concurrency)
    return res


