# Mejorar Fonética — Setup del portátil (scoring de pronunciación)

Este paquete deja funcionando el **scoring fonético real** de English Brain.
Corre en tu **PORTÁTIL** (el que tiene la RTX 2060 y Ollama). El **backend**
(en tu PC de escritorio) los llama por HTTP. Todo degrada: si un worker está
apagado, el backend usa el siguiente; si ninguno, cae a Whisper + heurística.

```
   PORTÁTIL (192.168.0.66)                 PC ESCRITORIO
   ├─ Ollama            :11434  ─────┐     backend FastAPI :8000
   ├─ phoneme (wav2vec2):8100   ◄────┤     (llama a los 3 por HTTP)
   └─ MFA (alineación)  :8200   ◄────┘
```

## Capas de evaluación (de mejor a peor, con fusión)
1. **MFA** (alineación forzada) → dónde/timing, sonidos caídos.
2. **wav2vec2** (fonemas IPA acústicos) → qué sonó realmente.
3. **Fusión** MFA + wav2vec2 → score + **confianza** (si coinciden, alta; si
   divergen mucho, baja y no corrige duro).
4. Respaldo: allosaurus (CPU) → y si nada, Whisper + similitud fonética.
5. **Consejo** breve con el LLM (Ollama) usando los fonemas fallados.

---

## 1) Requisitos previos (portátil)
- **Miniconda/Anaconda** instalado.
- **ffmpeg** en el PATH:  `winget install Gyan.FFmpeg`  (reinicia la terminal).
- GPU NVIDIA con drivers CUDA (RTX 2060).

## 2) Crear el entorno (una sola vez)
```bat
conda create -n fonetica -c conda-forge montreal-forced-aligner python=3.10 -y
conda activate fonetica

:: Modelos de MFA (inglés US, ARPABET)
mfa model download acoustic english_us_arpa
mfa model download dictionary english_us_arpa

:: Dependencias de los workers
pip install -r requirements.txt

:: PyTorch con CUDA (ajusta cuXXX a tu versión de CUDA; cu121 suele valer)
pip install torch --index-url https://download.pytorch.org/whl/cu121
```
La primera vez, el worker de fonemas descargará el modelo wav2vec2 (~1 GB).

## 3) Arrancar los dos workers
```bat
conda activate fonetica
run_all.bat
```
(o `run_phoneme.bat` y `run_mfa.bat` por separado)

Comprueba en el navegador del portátil:
- http://localhost:8100/health → `{"status":"online","device":"cuda"}`
- http://localhost:8200/health → `{"status":"online","mfa":true}`

Y desde el PC (cambia la IP): http://192.168.0.66:8100/health

> Si el firewall de Windows pregunta, permite el acceso en **red privada**.

## 4) Configurar el backend (PC de escritorio)
Copia el contenido de `backend.env.example` al archivo `.env` del backend
(`C:\Users\IvN\Desktop\Ingles\backend\.env`), con la IP de tu portátil.
Luego reinicia uvicorn:
```bat
cd C:\Users\IvN\Desktop\Ingles\backend
uvicorn app.main:app --host 0.0.0.0 --port 8000
```
El backend necesita además `g2p_en` (fonemas objetivo):
```bat
pip install g2p_en
```
(opcional, respaldo CPU en el PC si el portátil está apagado: `pip install allosaurus` + ffmpeg en el PC)

## 5) Probar
En la app → Vocabulario → "Probar mi pronunciación". Verás:
- **precisión** real,
- **semáforo de confianza** (🟢/🟡/🔴),
- **consejo IA** con los sonidos a revisar,
- y queda guardado en tu perfil (historial + progreso por término).

## Diagnóstico rápido
- `/health` de cada worker debe responder desde el PC.
- Si `device` sale `cpu` en el phoneme worker → PyTorch sin CUDA (reinstala torch cu121).
- Si MFA da `aligned:false` con palabras raras → OOV (fuera de diccionario); es normal, se usa la señal acústica.
- Backend log: verás `engine_used` = `mfa+acoustic` / `wav2vec2-gpu` / `allosaurus-cpu` / `standard`.

## Arranque automático (opcional)
Crea accesos directos a `run_all.bat` en la carpeta Inicio de Windows
(`shell:startup`) para que los workers arranquen con el portátil.
