"""
Orquestador de evaluación de pronunciación (V2 robusta).

Combina:
  - G2P del objetivo (fonemas esperados)
  - MFA: alineación forzada audio↔texto (dónde/timing, sonidos caídos)
  - Reconocedor acústico: wav2vec2 (GPU) o allosaurus (CPU) -> fonemas oídos
  - Fusión de confianza: si ambas señales coinciden, alta confianza; si divergen
    mucho, baja confianza y NO se corrige de forma dura (honestidad pedagógica).

Devuelve None si no hay ninguna señal fonética (el endpoint cae a heurística STT).
"""
import asyncio
import logging
from typing import Optional

from app.services import phoneme_scorer as ph
from app.services import mfa_scorer

logger = logging.getLogger("english_brain.pron_eval")


def _arpa_to_coarse(labels):
    out = []
    for l in labels:
        base = str(l).upper()
        out.append(ph._ARPA.get(base, base.lower()))
    # dedup preservando orden
    seen, uniq = set(), []
    for x in out:
        if x not in seen:
            seen.add(x); uniq.append(x)
    return uniq


async def evaluate(audio_bytes: bytes, word: str, filename: str = "audio.wav",
                   use_mfa: bool = True) -> Optional[dict]:
    target = ph._target_coarse(word)
    if not target:
        return None  # sin G2P no hay evaluación fonética -> caller usa STT heurístico

    # ── Señal acústica (wav2vec2) y MFA EN PARALELO (no en serie) ──
    async def _acoustic():
        return await ph._remote_phonemes(audio_bytes, filename)

    tasks = [_acoustic()]
    if use_mfa:
        tasks.append(mfa_scorer.align(audio_bytes, word, filename))
    results = await asyncio.gather(*tasks, return_exceptions=True)

    heard_raw = results[0] if not isinstance(results[0], Exception) else None
    acoustic_source = "wav2vec2-gpu"
    if not heard_raw:
        heard_raw = ph._local_phonemes(audio_bytes, filename)  # respaldo CPU (raro)
        acoustic_source = "allosaurus-cpu"
    ph_acc = None
    ph_wrong: list = []
    heard_ipa = None
    if heard_raw:
        hyp = ph._ipa_to_coarse(heard_raw)
        heard_ipa = " ".join(hyp)
        if hyp:
            ratio, wrong = ph._align(target, hyp)
            ph_acc, ph_wrong = ratio, wrong
        else:
            ph_acc, ph_wrong = 0.0, list(target)
    else:
        acoustic_source = None

    # ── Señal de alineación forzada (MFA), ya lanzada en paralelo ──
    mfa = results[1] if (use_mfa and len(results) > 1 and not isinstance(results[1], Exception)) else None
    mfa_aligned = bool(mfa and mfa.get("aligned"))
    mfa_dur = float(mfa.get("duration_score", 0.0)) if mfa_aligned else None
    mfa_dropped = _arpa_to_coarse(mfa.get("dropped", [])) if mfa_aligned else []

    # ── Fusión ──
    sources = []
    if acoustic_source:
        sources.append(acoustic_source)
    if mfa_aligned:
        sources.append("mfa")

    if ph_acc is not None and mfa_aligned:
        acc = 0.6 * ph_acc + 0.4 * mfa_dur
        wrong = ph_wrong[:]
        for d in mfa_dropped:
            if d not in wrong:
                wrong.append(d)
        div = abs(ph_acc - mfa_dur)
        confidence = 0.9 if div < 0.2 else (0.7 if div < 0.4 else 0.45)
        engine = "mfa+acoustic"
    elif mfa_aligned and ph_acc is None:
        acc = mfa_dur
        wrong = mfa_dropped
        confidence = 0.65
        engine = "mfa"
    elif ph_acc is not None and (mfa is not None and not mfa_aligned):
        # MFA no alineó (posible OOV/desajuste): usamos acústica pero bajamos confianza
        acc = ph_acc
        wrong = ph_wrong
        confidence = 0.5
        engine = acoustic_source or "acoustic"
    elif ph_acc is not None:
        acc = ph_acc
        wrong = ph_wrong
        confidence = 0.85 if acoustic_source == "wav2vec2-gpu" else 0.7
        engine = acoustic_source or "acoustic"
    else:
        return None  # ninguna señal fonética disponible

    return {
        "score": int(round(acc * 100)),
        "confidence": round(confidence, 2),
        "wrong": wrong,
        "engine": engine,
        "sources": sources,
        "target_ipa": " ".join(target),
        "heard_ipa": heard_ipa,
        "mfa_aligned": mfa_aligned,
    }
