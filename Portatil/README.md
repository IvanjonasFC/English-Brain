# Portátil RTX 2060 — Worker GPU (acelerador opcional)

Este portátil es el **acelerador GPU opcional** de la app. El **NAS DS224+ sigue siendo el núcleo** (FastAPI + PostgreSQL/SQLite + TTS + contenido). El portátil solo aporta velocidad: **STT rápido (faster-whisper CUDA)** y **feedback inteligente (Ollama)**. Si está apagado, la app sigue funcionando en modo estándar (degradación elegante).

## Cómo funciona (ya implementado en el backend del NAS)
El backend enruta cada trabajo por una capa de proveedores (`backend/app/providers/`):

- **STT**: `GpuWhisperProvider` (este portátil, vía Speaches/faster-whisper) → si offline, `LocalCpuWhisperProvider` (whisper.cpp del NAS o placeholder).
- **Feedback**: `OllamaFeedbackProvider` (este portátil) → si offline, `RuleBasedFeedbackProvider` (reglas en el NAS, sin LLM).

El NAS comprueba si el portátil está vivo con `WorkerHealthMonitor` (heartbeat con caché TTL de 15s) mirando:
- `OLLAMA_URL/api/tags` (LLM)
- `SPEACHES_URL/models` (STT)

La respuesta de cada turno incluye `engine_used`: `"fast"` (GPU), `"standard"` (CPU) o `"hybrid"`. La app lo muestra de forma discreta.

```
Móvil (offline-first)  ──sync──►  NAS DS224+ (SIEMPRE ON)
                                   • FastAPI  • DB  • Piper TTS
                                   • whisper.cpp (fallback)
                                        │ health + jobs
                                        ▼
                                 Portátil RTX 2060 (OPCIONAL)
                                   • Speaches / faster-whisper CUDA
                                   • Ollama (phi4-mini / qwen3:4b)
```

## Qué tienes que hacer aquí (resumen)
1. Instalar drivers NVIDIA + Docker + NVIDIA Container Toolkit (ver `SETUP.md`).
2. Levantar `docker-compose.yml` (Ollama + Speaches con GPU).
3. Descargar modelos: `ollama pull phi4-mini` y `ollama pull qwen3:4b`.
4. Configurar el NAS para que apunte a este portátil (ver `nas.env.example`).
5. (Opcional) Registrar el worker al arrancar (`register-worker.ps1`).
6. (Opcional) Wake-on-LAN + límite de carga de batería (60-80%).

> **Regla de oro:** este portátil NO guarda datos únicos. Solo modelos y caché. La verdad vive en el NAS.

Archivos:
- `SETUP.md` — pasos detallados.
- `ANTIGRAVITY.md` — el prompt exacto para Antigravity en el portátil.
- `docker-compose.yml` + `.env.example` — stack GPU.
- `nas.env.example` — variables a poner en el `.env` del backend del NAS.
- `register-worker.ps1` / `register-worker.sh` — aviso de arranque al NAS.
