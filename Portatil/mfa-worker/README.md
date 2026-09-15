# MFA Worker — Alineación forzada (Fase 2)

Montreal Forced Aligner alinea tu audio con el texto objetivo y su diccionario
de pronunciación → devuelve los **fonemas esperados con tiempos** (dónde y en qué
tramo falló). El backend lo **fusiona** con la señal acústica (wav2vec2/allosaurus)
para un score con **confianza honesta** (si ambas coinciden → alta; si divergen →
baja y no corrige de forma dura).

## Dónde corre
En tu **portátil** (o donde instales MFA por conda). El backend lo llama por HTTP.
Si no está disponible, se usa solo la señal acústica; si tampoco, Whisper+heurística.

## Instalación (Windows/conda)
```bash
:: 1) MFA por conda (Kaldi incluido)
conda create -n mfa -c conda-forge montreal-forced-aligner -y
conda activate mfa

:: 2) Modelos acústico + diccionario (inglés US ARPABET)
mfa model download acoustic english_us_arpa
mfa model download dictionary english_us_arpa

:: 3) Dependencias del servidor + ffmpeg
pip install fastapi "uvicorn[standard]" praatio python-multipart
winget install Gyan.FFmpeg   :: si no lo tienes

:: 4) Arrancar (mismo portátil que wav2vec2)
uvicorn mfa_server:app --host 0.0.0.0 --port 8200
```
Comprueba: `http://IP_PORTATIL:8200/health` → `"mfa": true`.

## Backend (PC)
En el `.env` (o variables de entorno):
```
MFA_WORKER_URL=http://192.168.0.66:8200
MFA_ENABLED=true
```
(por defecto ya apunta a `192.168.0.66:8200`). Reinicia uvicorn.

## Qué devuelve /align
`{ aligned, phones:[{phone,start,end,dur}], total_phones, dropped, short, duration_score }`
- `dropped`: fonemas con duración ~0 → probablemente no pronunciados.
- `duration_score`: fracción de fonemas con duración razonable.
- `aligned:false`: la palabra no encajó con el texto esperado (posible error o OOV).

## Nota
MFA da **alineación/timing**, no una nota de “bien/mal” por sí solo. La corrección
real sale de **fusionarlo** con el reconocedor acústico (lo hace el backend en
`services/pron_eval.py`). Palabras fuera del diccionario (OOV) pueden no alinear;
para vocabulario común `english_us_arpa` cubre la mayoría.
