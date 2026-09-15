# Prompt para Antigravity (en el portátil)

Pégale esto a Antigravity trabajando EN EL PORTÁTIL. El backend del NAS ya tiene
la capa híbrida (proveedores STT/Feedback + heartbeat + degradación + `engine_used`).
Aquí solo montamos el worker GPU y verificamos el circuito.

---
Contexto: este portátil (RTX 2060, 6GB) es el acelerador GPU OPCIONAL de mi app de
inglés. El núcleo es un NAS Synology DS224+ (siempre encendido) con FastAPI +
PostgreSQL/SQLite + Piper TTS. El backend ya enruta STT y feedback a este worker
cuando está online, y degrada a CPU/reglas cuando está offline.

OBJETIVO
Dejar el worker GPU funcionando y verificado, sin tocar datos del NAS.

TAREAS
1. Verificar prerrequisitos GPU:
   - Drivers NVIDIA + Docker + NVIDIA Container Toolkit.
   - `docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi` funciona.
2. Levantar el stack de `Portatil/docker-compose.yml`:
   - Ollama (11434) + Speaches faster-whisper CUDA (8001 -> 8000).
   - Confirmar que ambos usan GPU (`nvidia-smi` muestra los procesos).
3. Descargar modelos: `phi4-mini` y `qwen3:4b` (Q4). Medir tokens/s (esperado 55-90).
4. Exponer y probar:
   - `curl http://localhost:11434/api/tags` (LLM)
   - `curl http://localhost:8001/v1/models` (STT)
5. Conectar con el NAS:
   - Fijar IP LAN del portátil (DHCP reservado).
   - Poner en el `.env` del NAS las variables de `Portatil/nas.env.example` con esa IP.
   - Reiniciar backend NAS y comprobar `GET /api/worker/status` => llm_online/stt_online true.
6. Registro automático al arrancar (opcional): `register-worker.ps1` como tarea programada.
7. Salud del portátil: limitar carga de batería a 60-80%, revisar térmicas, WoL opcional.
8. Prueba de degradación: con worker ON el turno vuelve `engine_used:"fast"`; con worker
   OFF vuelve `engine_used:"standard"` y la app no se bloquea.

ENTREGABLES
- Stack GPU corriendo como servicio (restart unless-stopped).
- Modelos descargados y medidos.
- NAS conectado y `worker/status` en verde.
- Notas de despliegue y de fallback (GPU online/offline).
- Parar al terminar para revisión.
---
