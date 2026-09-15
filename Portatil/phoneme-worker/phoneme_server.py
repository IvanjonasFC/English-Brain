"""
English Brain — Phoneme Scoring Worker (wav2vec2 IPA)
=====================================================
Servicio ligero para tu PORTÁTIL con GPU (RTX 2060). Reconoce los FONEMAS
reales (IPA) de un audio con wav2vec2, para scoring de pronunciación fonema
a fonema. El backend FastAPI llama a este endpoint; si no está disponible,
el backend usa su propio respaldo.

Requiere ffmpeg en el PATH (para decodificar webm/m4a/wav).

Arranque:
    pip install -r requirements.txt
    uvicorn phoneme_server:app --host 0.0.0.0 --port 8100
"""
import io
import subprocess
import logging
from functools import lru_cache

import numpy as np
import torch
from fastapi import FastAPI, File, UploadFile, HTTPException
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("phoneme-worker")

MODEL_ID = "facebook/wav2vec2-lv-60-espeak-cv-ft"  # salida en fonemas IPA
app = FastAPI(title="English Brain Phoneme Worker")


@lru_cache(maxsize=1)
def _load():
    device = "cuda" if torch.cuda.is_available() else "cpu"
    logger.info(f"Cargando {MODEL_ID} en {device} ...")
    processor = Wav2Vec2Processor.from_pretrained(MODEL_ID)
    model = Wav2Vec2ForCTC.from_pretrained(MODEL_ID).to(device)
    model.eval()
    logger.info("Modelo de fonemas listo.")
    return processor, model, device


def _decode_to_16k_mono(audio_bytes: bytes) -> np.ndarray:
    """Decodifica cualquier formato (webm/m4a/wav) a float32 mono 16 kHz con ffmpeg."""
    proc = subprocess.run(
        ["ffmpeg", "-i", "pipe:0", "-f", "f32le", "-ac", "1", "-ar", "16000", "pipe:1"],
        input=audio_bytes, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=True,
    )
    return np.frombuffer(proc.stdout, dtype=np.float32).copy()


@app.get("/health")
async def health():
    try:
        _, _, device = _load()
        return {"status": "online", "model": MODEL_ID, "device": device}
    except Exception as e:
        return {"status": "error", "error": str(e)}


@app.post("/phoneme-score")
async def phoneme_score(file: UploadFile = File(...)):
    raw = await file.read()
    if not raw:
        raise HTTPException(status_code=400, detail="empty audio")
    try:
        audio = _decode_to_16k_mono(raw)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"decode failed (ffmpeg?): {e}")
    if audio.size < 800:  # < ~50ms => no hay voz
        return {"phonemes": "", "device": _load()[2]}
    processor, model, device = _load()
    inputs = processor(audio, sampling_rate=16000, return_tensors="pt", padding=True)
    with torch.no_grad():
        logits = model(inputs.input_values.to(device)).logits
    pred_ids = torch.argmax(logits, dim=-1)
    phonemes = processor.batch_decode(pred_ids)[0].strip()
    return {"phonemes": phonemes, "device": device}
