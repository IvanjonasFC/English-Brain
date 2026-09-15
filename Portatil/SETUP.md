# Setup del worker GPU (portátil RTX 2060)

## 1. Prerrequisitos
- Windows 10/11 (o Linux) en el portátil.
- Drivers NVIDIA actualizados (soporte CUDA para la 2060).
- Docker Desktop con backend WSL2 (Windows) o Docker Engine (Linux).
- **NVIDIA Container Toolkit** para que Docker vea la GPU:
  - Windows/WSL2: instala Docker Desktop + activa GPU en WSL (guía NVIDIA "CUDA on WSL").
  - Linux: `nvidia-ctk runtime configure` + reinicia Docker.
- Comprueba GPU en Docker:
  `docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi`

## 2. Levantar el stack
Desde esta carpeta `Portatil/`:
```
docker compose up -d
docker compose logs -f
```

## 3. Descargar modelos LLM (Ollama)
6 GB de VRAM → punto dulce 3-4B en Q4:
```
docker exec -it eng-ollama ollama pull phi4-mini      # ~2.8GB, recomendado
docker exec -it eng-ollama ollama pull qwen3:4b        # alternativa
# opcional para código:
docker exec -it eng-ollama ollama pull qwen2.5-coder:3b
```
Verifica: `curl http://localhost:11434/api/tags`

## 4. Verificar STT (Speaches)
`curl http://localhost:8001/v1/models`  (debe responder 200)

## 5. Conectar el NAS al portátil
1. Averigua la IP del portátil en la LAN (fíjala por DHCP reservado si puedes).
2. En el `.env` del backend del NAS, pon las variables de `nas.env.example` con esa IP.
3. Reinicia el backend del NAS.
4. Comprueba desde el NAS: `GET http://<NAS>:8000/api/worker/status`
   - Debe devolver `"llm_online": true, "stt_online": true`.

## 6. (Opcional) Registro automático al arrancar
Ejecuta `register-worker.ps1` (Windows) o `register-worker.sh` (Linux) al iniciar
sesión, o como tarea programada, para avisar al NAS de que el worker está vivo.

## 7. (Opcional) Encendido bajo demanda — Wake-on-LAN
Si no quieres el portátil 24/7:
- Activa WoL en BIOS y en el adaptador de red.
- El NAS puede enviar el "magic packet" antes de encolar un job (añade 1-2 min de arranque).

## 8. Salud del portátil (importante para 24/7)
- **Batería:** limita la carga al 60-80% (Lenovo Vantage / MyASUS / Dell Power Manager / BIOS) para evitar degradación/hinchazón.
- **Consumo:** GPU en espera ~30-60W (~5-9 €/mes a 0,20 €/kWh). El NAS ~10-25W.
- **Térmicas:** limpia el polvo; si el ventilador molesta, usa modelos 3B (menos calor) o limita la GPU.
- **Fiabilidad:** sin RAID → nunca guardes datos únicos aquí. Solo modelos y caché.

## 9. Prueba end-to-end
Con el worker arriba: haz una entrevista en la app → el turno debe volver con
`engine_used: "fast"` y feedback rico + STT en ~1-2s. Apaga el worker → repite:
debe seguir funcionando con `engine_used: "standard"` (reglas), sin bloquear.
