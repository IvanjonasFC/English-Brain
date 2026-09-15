# Phoneme Scoring Worker (wav2vec2 IPA) — Portátil GPU

Scoring fonético REAL de pronunciación: reconoce los fonemas (IPA) de tu voz
con wav2vec2 y el backend los compara con los fonemas objetivo de la palabra.

## Qué corre dónde

- **Portátil (RTX 2060)**: este worker (wav2vec2 en GPU) — PRIMARIO, el correcto.
- **PC (backend FastAPI)**: G2P del objetivo (`g2p_en`) + alineación + consejo LLM.
  Opcional: respaldo local por CPU con `allosaurus`.
- Si el portátil está apagado y no hay respaldo → cae a Whisper + similitud fonética
  (lo que ya tenías). Nunca se rompe.

## 1) Portátil — arrancar el worker

Requisitos: Python 3.10+, **ffmpeg** en el PATH, y (opcional pero recomendado) CUDA.

```bash
cd Portatil/phoneme-worker
python -m venv .venv && .venv\Scripts\activate        # Windows
pip install -r requirements.txt
# torch con CUDA (RTX 2060). Ajusta a tu versión de CUDA:
pip install torch --index-url https://download.pytorch.org/whl/cu121
uvicorn phoneme_server:app --host 0.0.0.0 --port 8100
```

La primera vez descarga el modelo `facebook/wav2vec2-lv-60-espeak-cv-ft` (~1 GB).
Comprueba: abre http://IP_DEL_PORTATIL:8100/health → debe decir `"device":"cuda"`.

ffmpeg en Windows: `winget install Gyan.FFmpeg` (o choco/scoop) y reinicia la terminal.

## 2) PC (backend) — habilitar el uso del worker

En el venv del backend:

```bash
pip install g2p_en        # G2P del objetivo (necesario para el scoring fonético)
```

Configura la URL del worker (IP del portátil). En el `.env` del backend o variable de entorno:

```
PHONEME_WORKER_URL=http://192.168.0.66:8100
```

(por defecto ya apunta a `http://192.168.0.66:8100`, cámbialo si tu portátil tiene otra IP).

Reinicia uvicorn. Listo: al probar pronunciación verás el score fonético real y el
consejo de la IA indicando qué sonidos mejorar.

## 3) (Opcional) Respaldo local por CPU en el backend

Si quieres que funcione aunque el portátil esté apagado:

```bash
pip install allosaurus        # reconocedor de fonemas por CPU
# y ffmpeg también en el PC (winget install Gyan.FFmpeg)
```

Con `PHONEME_LOCAL_FALLBACK=true` (por defecto), el backend usa allosaurus si el
worker del portátil no responde.

## Cómo se calcula el score

1. Objetivo: `g2p_en` convierte la palabra a fonemas (ARPABET→IPA aproximado).
2. Tu audio: wav2vec2 (portátil) o allosaurus (PC) → fonemas IPA.
3. Alineación Needleman-Wunsch objetivo vs tu voz → % de aciertos y qué fonemas fallaste.
4. El LLM (Ollama) convierte esos fonemas fallados en un consejo concreto en español.
