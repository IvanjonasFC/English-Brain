"""
English Brain — MFA Worker (Montreal Forced Aligner)
====================================================
Alineación forzada audio↔texto con diccionario de pronunciación: devuelve los
fonemas ESPERADOS con sus tiempos (start/end). Sirve para saber DÓNDE y en qué
tramo falló la pronunciación (fonemas con duración ~0 = sonidos que faltaron, o
alineación fallida = la palabra no se dijo como se esperaba).

Corre en el PORTÁTIL (o donde tengas MFA instalado por conda). Requiere:
  - conda + montreal-forced-aligner
  - modelos: acoustic `english_us_arpa` y dictionary `english_us_arpa`
  - ffmpeg en el PATH

Arranque:
  mfa model download acoustic english_us_arpa
  mfa model download dictionary english_us_arpa
  pip install fastapi "uvicorn[standard]" praatio python-multipart
  uvicorn mfa_server:app --host 0.0.0.0 --port 8200
"""
import os
import re
import shutil
import subprocess
import tempfile
import logging

from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from praatio import textgrid as tgio

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("mfa-worker")

app = FastAPI(title="English Brain MFA Worker")

ACOUSTIC = os.environ.get("MFA_ACOUSTIC", "english_us_arpa")
DICTIONARY = os.environ.get("MFA_DICTIONARY", "english_us_arpa")
_SIL = {"", "sil", "sp", "spn", "<eps>"}


def _to_wav_16k(src_bytes: bytes, dst: str):
    subprocess.run(
        ["ffmpeg", "-y", "-i", "pipe:0", "-ac", "1", "-ar", "16000", dst],
        input=src_bytes, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True,
    )


def _parse_phones(tg_path: str):
    tg = tgio.openTextgrid(tg_path, includeEmptyIntervals=False)
    phone_tier = None
    for name in tg.tierNames:
        if "phone" in name.lower():
            phone_tier = tg.getTier(name)
            break
    if phone_tier is None:
        return []
    out = []
    for entry in phone_tier.entries:
        start, end, label = entry.start, entry.end, entry.label
        base = re.sub(r"\d", "", label).strip()
        if base.lower() in _SIL or not base:
            continue
        out.append({"phone": base, "start": round(start, 3),
                    "end": round(end, 3), "dur": round(end - start, 3)})
    return out


@app.get("/health")
async def health():
    ok = shutil.which("mfa") is not None
    return {"status": "online" if ok else "error",
            "mfa": ok, "acoustic": ACOUSTIC, "dictionary": DICTIONARY}


@app.post("/align")
async def align(file: UploadFile = File(...), text: str = Form(...)):
    raw = await file.read()
    if not raw:
        raise HTTPException(status_code=400, detail="empty audio")
    text = text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="empty text")

    workdir = tempfile.mkdtemp(prefix="mfa_")
    corpus = os.path.join(workdir, "corpus")
    out = os.path.join(workdir, "out")
    os.makedirs(corpus, exist_ok=True)
    try:
        wav = os.path.join(corpus, "utt.wav")
        try:
            _to_wav_16k(raw, wav)
        except Exception as e:
            return {"aligned": False, "error": f"decode failed (ffmpeg?): {e}", "phones": []}
        with open(os.path.join(corpus, "utt.lab"), "w", encoding="utf-8") as f:
            f.write(text)

        cmd = ["mfa", "align", "--clean", "--overwrite", "--single_speaker",
               "--quiet", "--output_format", "long_textgrid",
               corpus, DICTIONARY, ACOUSTIC, out]
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        tg_path = os.path.join(out, "utt.TextGrid")
        if proc.returncode != 0 or not os.path.exists(tg_path):
            return {"aligned": False,
                    "error": (proc.stderr or proc.stdout or "align failed")[-400:],
                    "phones": []}

        phones = _parse_phones(tg_path)
        if not phones:
            return {"aligned": False, "error": "no phones parsed", "phones": []}

        total = len(phones)
        dropped = [p["phone"] for p in phones if p["dur"] < 0.02]
        short = [p["phone"] for p in phones if 0.02 <= p["dur"] < 0.035]
        good = sum(1 for p in phones if p["dur"] >= 0.035)
        duration_score = round(good / total, 3) if total else 0.0
        return {
            "aligned": True,
            "phones": phones,
            "total_phones": total,
            "dropped": dropped,          # duración ~0 -> probablemente no se pronunció
            "short": short,              # muy breve -> poco claro
            "duration_score": duration_score,
        }
    finally:
        shutil.rmtree(workdir, ignore_errors=True)
