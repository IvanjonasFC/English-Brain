"""Extraccion de F0 (curva de tono / entonacion) y comparacion alumno vs nativo.

Robusto y ligero: decodifica el audio con ffmpeg (cualquier formato del movil:
m4a/opus/webm/wav/mp3) y calcula el F0 por autocorrelacion con numpy. No usa
librosa/numba (evita builds fragiles). Todo con imports y llamadas protegidas:
si faltan numpy o ffmpeg, devuelve disponible=False y la app sigue funcionando.
"""
import io
import os
import wave
import shutil
import tempfile
import subprocess
import logging

logger = logging.getLogger("english_brain.pitch")

try:
    import numpy as np
    HAS_NUMPY = True
except Exception:  # pragma: no cover
    HAS_NUMPY = False

# N de puntos de la curva normalizada (mismo largo para alumno y nativo).
CURVE_POINTS = 64


def is_available() -> bool:
    return HAS_NUMPY and (shutil.which("ffmpeg") is not None)


def _decode_pcm(audio_bytes: bytes, sr: int = 16000):
    """Decodifica bytes de audio (cualquier formato) a mono float32 [-1,1] via ffmpeg."""
    if not audio_bytes or not HAS_NUMPY:
        return None
    tmp_in = None
    try:
        with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
            f.write(audio_bytes)
            tmp_in = f.name
        proc = subprocess.run(
            ["ffmpeg", "-nostdin", "-v", "error", "-i", tmp_in,
             "-ac", "1", "-ar", str(sr), "-f", "wav", "pipe:1"],
            capture_output=True, timeout=20,
        )
        if proc.returncode != 0 or not proc.stdout:
            return None
        with wave.open(io.BytesIO(proc.stdout), "rb") as w:
            frames = w.readframes(w.getnframes())
            sw = w.getsampwidth()
        if sw == 2:
            data = np.frombuffer(frames, dtype=np.int16).astype(np.float32) / 32768.0
        elif sw == 1:
            data = (np.frombuffer(frames, dtype=np.uint8).astype(np.float32) - 128.0) / 128.0
        else:
            data = np.frombuffer(frames, dtype=np.int32).astype(np.float32) / 2147483648.0
        return data
    except Exception as e:
        logger.warning(f"decode audio fallo: {e}")
        return None
    finally:
        if tmp_in and os.path.exists(tmp_in):
            try:
                os.remove(tmp_in)
            except Exception:
                pass


def _extract_f0(x, sr=16000, frame_ms=40.0, hop_ms=10.0, fmin=70.0, fmax=400.0):
    """F0 por autocorrelacion normalizada. Devuelve array (0.0 = no sonoro)."""
    frame = int(sr * frame_ms / 1000.0)
    hop = int(sr * hop_ms / 1000.0)
    if x is None or len(x) < frame:
        return np.array([])
    min_lag = max(1, int(sr / fmax))
    max_lag = int(sr / fmin)
    out = []
    for start in range(0, len(x) - frame, hop):
        seg = x[start:start + frame]
        seg = seg - seg.mean()
        energy = float(np.sqrt(np.mean(seg ** 2)))
        if energy < 0.01:
            out.append(0.0)
            continue
        ac = np.correlate(seg, seg, mode="full")[len(seg) - 1:]
        if ac[0] <= 0:
            out.append(0.0)
            continue
        acn = ac / ac[0]
        hi = min(max_lag, len(acn) - 1)
        if hi <= min_lag:
            out.append(0.0)
            continue
        window = acn[min_lag:hi]
        peak = int(np.argmax(window)) + min_lag
        if acn[peak] < 0.3:  # periodicidad debil -> no sonoro
            out.append(0.0)
            continue
        out.append(sr / peak)
    return np.array(out)


def _pattern(f0, n=CURVE_POINTS):
    """Curva de entonacion normalizada (forma), independiente del tono absoluto.
    Interpola huecos no sonoros, pasa a escala log (semitonos) y z-normaliza."""
    if f0 is None or len(f0) == 0:
        return None
    voiced = f0 > 0
    if int(voiced.sum()) < 4:
        return None
    idx = np.arange(len(f0))
    vi = idx[voiced]
    vv = f0[voiced]
    span = np.arange(vi[0], vi[-1] + 1)
    interp = np.interp(span, vi, vv)
    interp = np.log2(np.clip(interp, 1e-6, None))
    xs = np.linspace(0, len(interp) - 1, n)
    res = np.interp(xs, np.arange(len(interp)), interp)
    mu = float(res.mean())
    sd = float(res.std())
    if sd < 1e-6:
        sd = 1e-6
    return (res - mu) / sd


def _similarity(a, b):
    """Correlacion de formas con busqueda de pequenos desfases; 0..100."""
    if a is None or b is None:
        return None
    best = -1.0
    for shift in range(-6, 7):
        if shift < 0:
            aa = a[-shift:]
            bb = b[:len(aa)]
        elif shift > 0:
            bb = b[shift:]
            aa = a[:len(bb)]
        else:
            aa, bb = a, b
        m = min(len(aa), len(bb))
        if m < 8:
            continue
        aa = aa[:m]
        bb = bb[:m]
        if aa.std() < 1e-6 or bb.std() < 1e-6:
            continue
        c = float(np.corrcoef(aa, bb)[0, 1])
        if c != c:  # NaN
            continue
        best = max(best, c)
    if best <= -1.0:
        return None
    return round(max(0.0, (best + 1.0) / 2.0) * 100.0, 1)


def compute_pattern(audio_bytes: bytes, n: int = CURVE_POINTS):
    """Curva de entonacion normalizada (lista) desde bytes de audio, o None.
    Se usa para precalcular y cachear la curva nativa de cada frase fija."""
    if not is_available():
        return None
    pat = _pattern(_extract_f0(_decode_pcm(audio_bytes)), n)
    if pat is None:
        return None
    return [round(float(v), 3) for v in pat]


def analyze_user_vs_ref(user_bytes: bytes, ref_pattern, n: int = CURVE_POINTS) -> dict:
    """Como analyze() pero con la curva nativa YA precalculada (lista): evita
    re-sintetizar y re-analizar la referencia en cada peticion (mucho mas rapido)."""
    if not is_available():
        return {"ok": False, "available": False}
    user_pat = _pattern(_extract_f0(_decode_pcm(user_bytes)), n)
    if user_pat is None:
        return {"ok": False, "available": True, "reason": "no_voice"}
    ref_pat = None
    if ref_pattern:
        try:
            ref_pat = np.asarray(ref_pattern, dtype=np.float32)
            if ref_pat.size == 0:
                ref_pat = None
        except Exception:
            ref_pat = None
    sim = _similarity(user_pat, ref_pat) if ref_pat is not None else None
    return {
        "ok": True,
        "available": True,
        "n": n,
        "similarity": sim,
        "user_curve": [round(float(v), 3) for v in user_pat],
        "ref_curve": [round(float(v), 3) for v in ref_pat] if ref_pat is not None else [],
        "ref_cached": True,
    }


def analyze(user_bytes: bytes, ref_bytes: bytes = None, n: int = CURVE_POINTS) -> dict:
    """Analiza la entonacion del alumno y, si hay referencia, la compara.
    Devuelve curvas normalizadas listas para pintar y una puntuacion de similitud."""
    if not is_available():
        return {"ok": False, "available": False}
    user_pat = _pattern(_extract_f0(_decode_pcm(user_bytes)), n)
    if user_pat is None:
        return {"ok": False, "available": True, "reason": "no_voice"}
    ref_pat = None
    if ref_bytes:
        ref_pat = _pattern(_extract_f0(_decode_pcm(ref_bytes)), n)
    sim = _similarity(user_pat, ref_pat) if ref_pat is not None else None
    return {
        "ok": True,
        "available": True,
        "n": n,
        "similarity": sim,
        "user_curve": [round(float(v), 3) for v in user_pat],
        "ref_curve": [round(float(v), 3) for v in ref_pat] if ref_pat is not None else [],
    }
