# Despliegue en el NAS (English Brain)

Esta carpeta contiene todo lo necesario para desplegar el stack completo de **English Brain** en tu servidor NAS doméstico mediante Docker Compose.

---

## Estructura de Servicios

| Contenedor | Imagen | Puerto Host | Descripción |
|---|---|---|---|
| `english_coach_backend` | `./backend` | `8000` | Orquestador FastAPI (JWT, FSRS, Sesiones, Logs) |
| `english_coach_speaches` | `speaches-ai/speaches` | `8001` | Whisper (STT) + Piper (TTS) acelerado |
| `english_coach_ollama` | `ollama/ollama` | `11434` | Servidor LLM local (Qwen 2.5 7B) |
| `english_coach_caddy` *(opcional)* | `caddy:2-alpine` | `80, 443` | Reverse proxy con SSL automático Let's Encrypt |

---

## 1. Preparación en el NAS

1. **Copiar archivos al NAS:**
   Transfiere las carpetas `nas/` y `backend/` a una ruta de tu NAS (por ejemplo `/volume1/docker/ingles/`):
   ```
   /volume1/docker/ingles/
   ├── backend/
   └── nas/
       ├── docker-compose.yml
       ├── Caddyfile
       └── .env.example
   ```

2. **Crear archivo de entorno:**
   ```bash
   cd /volume1/docker/ingles/nas
   cp .env.example .env
   # Edita .env con tus claves seguras personalizadas
   ```

---

## 2. Puesta en Marcha

Desde la carpeta `nas/`:

```bash
# 1. Levantar los contenedores en segundo plano
docker compose up -d

# 2. Descargar el modelo de IA en Ollama (solo la primera vez)
docker compose exec ollama ollama pull qwen2.5:7b

# 3. Comprobar que todos los servicios estén sanos (healthy)
docker compose ps
```

---

## 3. Modos de Conexión desde la App Móvil

Configura la URL en la pantalla de **Login / Ajustes** de la app según cómo te conectes:

### Opción A: En Casa por Red Local (LAN)
- **URL en la App:** `http://192.168.1.X:8000` *(IP de tu NAS en tu router)*
- **Nota Android:** La app en modo `debug` ya cuenta con `network_security_config.xml` para permitir HTTP en red privada local.

### Opción B: Fuera de Casa con Túnel WireGuard (Máxima Privacidad)
- Conéctate a la VPN WireGuard de tu NAS desde tu teléfono.
- **URL en la App:** `http://10.X.X.X:8000` *(IP de la interfaz WireGuard del NAS)*
- El tráfico viaja 100% cifrado dentro de tu propio túnel sin exponer puertos a internet.

### Opción C: Dominio Público con Caddy (HTTPS)
- Descomenta el bloque `caddy` en `docker-compose.yml`.
- Pon tu dominio en `Caddyfile`.
- **URL en la App:** `https://ingles.tudominio.com` *(con certificado SSL Let's Encrypt automático)*.

---

## 4. Diagnóstico, Observabilidad y Logs

- **Verificar Health Check completo en vivo:**
  ```bash
  curl http://localhost:8000/api/health
  ```
  Devuelve el estado de la API, latencia y disponibilidad real de Ollama y Speaches.

- **Ver logs estructurados en tiempo real:**
  ```bash
  docker compose logs -f backend
  ```

- **Inspeccionar archivo persistente de logs JSON:**
  Los logs se rotan automáticamente (10 MB por archivo, 5 backups) en:
  ```bash
  docker compose exec backend tail -f /data/logs/app.log
  ```
