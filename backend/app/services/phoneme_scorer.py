"""
Scoring fonético de pronunciación (GOP aproximado, open-source).

Flujo:
  1) Fonemas OBJETIVO de la palabra  -> g2p_en (ARPABET) -> inventario grueso.
  2) Fonemas del AUDIO del alumno:
        a) primario: worker wav2vec2 (IPA) en el portátil GPU
        b) respaldo: allosaurus local (CPU) si está instalado
  3) Alineación (Needleman-Wunsch) objetivo vs alumno -> score + fonemas fallados.

Todo degrada con gracia: si no hay G2P ni reconocedor de fonemas, score()
devuelve None y el endpoint usa su heurística de texto/fonética + LLM.
"""
import logging
import re
from typing import Optional

import httpx

from app.config import settings, live_chain, mark_worker_up, mark_worker_down

logger = logging.getLogger("english_brain.phoneme")

# ── ARPABET -> símbolo grueso (IPA aproximado) ────────────────────────────────
_ARPA = {
    "B": "b", "CH": "tʃ", "D": "d", "DH": "ð", "F": "f", "G": "g", "HH": "h",
    "JH": "dʒ", "K": "k", "L": "l", "M": "m", "N": "n", "NG": "ŋ", "P": "p",
    "R": "r", "S": "s", "SH": "ʃ", "T": "t", "TH": "θ", "V": "v", "W": "w",
    "Y": "j", "Z": "z", "ZH": "ʒ",
    "AA": "ɑ", "AE": "æ", "AH": "ə", "AO": "ɔ", "AW": "aʊ", "AY": "aɪ",
    "EH": "ɛ", "ER": "r", "EY": "eɪ", "IH": "ɪ", "IY": "i", "OW": "oʊ",
    "OY": "ɔɪ", "UH": "ʊ", "UW": "u",
}

# ── Vocales IPA -> clase gruesa (agrupamos calidades cercanas) ─────────────────
_IPA_VOWEL = {
    "ɑ": "ɑ", "a": "ɑ", "ɒ": "ɔ", "ɔ": "ɔ", "æ": "æ", "ʌ": "ə", "ə": "ə",
    "ɐ": "ə", "ɛ": "ɛ", "e": "eɪ", "eɪ": "eɪ", "ɪ": "ɪ", "i": "i", "iː": "i",
    "ɨ": "ɪ", "oʊ": "oʊ", "o": "oʊ", "ʊ": "ʊ", "u": "u", "uː": "u", "ɜ": "r",
    "ɚ": "r", "ɝ": "r", "aɪ": "aɪ", "aʊ": "aʊ", "ɔɪ": "ɔɪ",
}


def _clean_ipa_token(t: str) -> str:
    # quita acentos, longitud y diacríticos comunes
    return re.sub(r"[ˈˌːˑ̃ʰʷʲ̩̯̀͡-ͯ]", "", t).strip().lower()


def _ipa_to_coarse(seq: str) -> list[str]:
    out = []
    for tok in seq.replace("_", " ").split():
        tok = _clean_ipa_token(tok)
        if not tok:
            continue
        if tok in _IPA_VOWEL:
            out.append(_IPA_VOWEL[tok])
        elif tok[0] in _IPA_VOWEL:
            out.append(_IPA_VOWEL[tok[0]])
        else:
            out.append(tok)
    return out


_G2P_CACHE: dict[str, Optional[list[str]]] = {}


def _target_coarse(word: str) -> Optional[list[str]]:
    normalized = word.strip().lower()
    if normalized in _G2P_CACHE:
        return _G2P_CACHE[normalized]

    try:
        from g2p_en import G2p  # lazy
    except Exception:
        return None
    try:
        g2p = _get_g2p()
        arpa = g2p(word)
        out = []
        for p in arpa:
            p = p.strip()
            if not p or not p[0].isalpha():
                continue
            base = re.sub(r"\d", "", p).upper()
            out.append(_ARPA.get(base, base.lower()))
        res = out or None
        if len(_G2P_CACHE) < 10000:
            _G2P_CACHE[normalized] = res
        return res
    except Exception as e:
        logger.warning(f"G2P falló: {e}")
        return None


_G2P_SINGLETON = None


def _get_g2p():
    global _G2P_SINGLETON
    if _G2P_SINGLETON is None:
        from g2p_en import G2p
        _G2P_SINGLETON = G2p()
    return _G2P_SINGLETON


def _align(target: list[str], hyp: list[str]) -> tuple[float, list[str]]:
    """Needleman-Wunsch. Devuelve (ratio 0..1, fonemas objetivo fallados)."""
    n, m = len(target), len(hyp)
    if n == 0:
        return 0.0, []
    dp = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            match = dp[i - 1][j - 1] + (1 if target[i - 1] == hyp[j - 1] else 0)
            dp[i][j] = max(match, dp[i - 1][j], dp[i][j - 1])
    # backtrack para marcar fallos
    i, j, wrong, matches = n, m, [], 0
    while i > 0 and j > 0:
        if target[i - 1] == hyp[j - 1] and dp[i][j] == dp[i - 1][j - 1] + 1:
            matches += 1
            i -= 1; j -= 1
        elif dp[i - 1][j] >= dp[i][j - 1]:
            wrong.append(target[i - 1]); i -= 1
        else:
            j -= 1
    while i > 0:
        wrong.append(target[i - 1]); i -= 1
    ratio = (2 * matches) / (n + m) if (n + m) else 0.0
    # dedup preservando orden
    seen, uniq = set(), []
    for w in reversed(wrong):
        if w not in seen:
            seen.add(w); uniq.append(w)
    return ratio, uniq


from app.services.ai_client import ai_client, gpu_semaphore

async def _remote_phonemes(audio_bytes: bytes, filename: str) -> Optional[str]:
    # Solo el portatil (.65) tiene wav2vec2; sin fallback (el NAS no lo tiene).
    # live_chain salta la URL si esta en cooldown por caida reciente -> sin lag.
    urls = live_chain(settings.PHONEME_WORKER_URL,
                      getattr(settings, "PHONEME_WORKER_FALLBACK_URL", ""))
    for url in urls:
        try:
            async with gpu_semaphore:
                files = {"file": (filename or "audio.wav", audio_bytes, "application/octet-stream")}
                r = await ai_client.post(f"{url}/phoneme-score", files=files, timeout=settings.PHONEME_WORKER_TIMEOUT)
                if r.status_code == 200:
                    mark_worker_up(url)
                    return (r.json().get("phonemes") or "").strip()
        except (httpx.ConnectError, httpx.ConnectTimeout) as e:
            mark_worker_down(url)  # portatil apagado: no reintentar 30s
            logger.info(f"Worker de fonemas {url} caido (cooldown): {e}")
            continue
        except Exception as e:
            logger.info(f"Worker de fonemas {url} error: {e}")
            continue
    return None


def _local_phonemes(audio_bytes: bytes, filename: str) -> Optional[str]:
    if not settings.PHONEME_LOCAL_FALLBACK:
        return None
    try:
        import tempfile, os, subprocess
        from allosaurus.app import read_recognizer  # lazy
    except Exception:
        return None
    try:
        rec = _get_allosaurus()
        with tempfile.TemporaryDirectory() as d:
            src = os.path.join(d, filename or "in.audio")
            wav = os.path.join(d, "out.wav")
            with open(src, "wb") as f:
                f.write(audio_bytes)
            subprocess.run(["ffmpeg", "-y", "-i", src, "-ac", "1", "-ar", "16000", wav],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
            return rec.recognize(wav, lang_id="eng").strip()
    except Exception as e:
        logger.info(f"Allosaurus local no disponible: {e}")
        return None


_ALLO_SINGLETON = None


def _get_allosaurus():
    global _ALLO_SINGLETON
    if _ALLO_SINGLETON is None:
        from allosaurus.app import read_recognizer
        _ALLO_SINGLETON = read_recognizer()
    return _ALLO_SINGLETON


async def score(audio_bytes: bytes, word: str, filename: str = "audio.wav") -> Optional[dict]:
    """Devuelve {score, target_ipa, heard_ipa, wrong, source} o None si no hay motor."""
    target = _target_coarse(word)
    if not target:
        return None  # sin G2P no podemos comparar
    heard_raw = await _remote_phonemes(audio_bytes, filename)
    source = "wav2vec2-gpu"
    if not heard_raw:
        heard_raw = _local_phonemes(audio_bytes, filename)
        source = "allosaurus-cpu"
    if not heard_raw:
        return None  # ningún reconocedor de fonemas disponible
    hyp = _ipa_to_coarse(heard_raw)
    if not hyp:
        return {"score": 0, "target_ipa": " ".join(target), "heard_ipa": heard_raw,
                "wrong": target, "source": source}
    ratio, wrong = _align(target, hyp)
    return {
        "score": int(round(ratio * 100)),
        "target_ipa": " ".join(target),
        "heard_ipa": " ".join(hyp),
        "wrong": wrong,
        "source": source,
    }
