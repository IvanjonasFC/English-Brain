# Guía de Despliegue en el NAS (Manual)

Esta guía documenta los pasos para cuando decidas transferir y levantar el contenedor en tu NAS personal.

---

## 1. Transferencia al NAS

Copia la carpeta del proyecto a tu NAS (vía `rsync`, `scp` o tu gestor de archivos):
```bash
rsync -avz --exclude '.venv' --exclude 'app/build' ./ usuario@ip-del-nas:/volume1/docker/english-coach/
```

---

## 2. Puesta en Marcha Inicial (Docker Compose)

En la terminal del NAS, accede al directorio:
```bash
cd /volume1/docker/english-coach
docker compose up -d
```

Comprueba el estado de los contenedores:
```bash
docker compose ps
```

---

## 3. Descarga del Modelo en Ollama

Para el LLM entrevistador y corrector, se recomienda `qwen2.5:7b` (o `llama3.1:8b` si cuentas con más VRAM/RAM):
```bash
docker compose exec ollama ollama pull qwen2.5:7b
```

Verifica la descarga con:
```bash
docker compose exec ollama ollama list
```

---

## 4. Verificación de Endpoints desde la Terminal

Puedes probar los tres servicios con `curl`:

1. **Ollama Chat**:
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5:7b",
  "messages": [{"role": "user", "content": "Say hello in one word."}],
  "stream": false
}'
```

2. **Speaches (STT OpenAI-Compatible)**:
```bash
curl http://localhost:8001/v1/models
```

3. **Backend Health Check**:
```bash
curl http://localhost:8000/health
```

---

## 5. Activar Caddy con tu Dominio (Fase Final de Producción)

Cuando desees publicar la app o acceder desde el exterior:
1. Abre `docker-compose.yml` y descomenta el bloque del servicio `caddy` y los volúmenes `caddy_data` y `caddy_config`.
2. Edita `Caddyfile` y reemplaza `ingles.tudominio.com` con tu dominio real configurado hacia la IP pública de tu router (con puertos 80 y 443 reenviados al NAS).
3. Reinicia el stack:
```bash
docker compose up -d
```
Caddy aprovisionará certificados SSL Let's Encrypt automáticamente.
