# Especificación de Integración: Worker GPU (RTX 2060) & Pipeline Híbrido de la App de Inglés

> **Destinatario:** Agente de IA / Ingeniero encargado del Backend (FastAPI en NAS Synology DS224+) y la App de Inglés.  
> **Objetivo:** Conectar el backend con el clúster de inferencia GPU acelerado (Portátil RTX 2060), registrar telemetría completa de interacciones y asegurar redundancia local con fallback continuo.

---

## 1. Estado Actual de la Arquitectura (Portátil GPU + NAS Synology)

El portátil funciona como un **nodo de aceleración GPU (stateless)** de alta velocidad conectado por Ethernet.

| Servicio | Puerto | Hardware / Motor | Función en la App |
| :--- | :--- | :--- | :--- |
| **Ollama LLM** | `11434` | RTX 2060 (`phi4-mini`, `qwen3:4b`) | Corrección gramatical, explicaciones y tutor pedagógico |
| **Speaches GPU** | `8001` | CUDA (`faster-whisper-small` + `Kokoro-82M`) | Transcripción STT ultra rápida y síntesis de voz neural |
| **Worker Fonemas** | `8100` | CUDA (`facebook/wav2vec2-lv-60-espeak-cv-ft`) | Extracción de fonemas IPA reales para scoring de pronunciación |
| **Worker MFA** | `8200` | Kaldi / MFA (`english_us_arpa`) | Alineación forzada fonética a nivel de milisegundo |

| Parámetro | Valor Configurado |
| :--- | :--- |
| **IP del Portátil (Ethernet LAN)** | `TU_GPU_IP` (Fijada en DHCP del router) |
| **IP del NAS Synology (Pesoz)** | `TU_NAS_IP:8092` (Backend FastAPI en Docker) |
| **Modo de Red en NAS** | Bridge MTU 1400 (Compilación con `DOCKER_BUILDKIT=0 docker build --network=host`) |
| **Resiliencia / Fallback** | Si el portátil está apagado, el backend degrada a heurísticas y algoritmos locales sin romperse |

---

## 2. Exposición de Red y Endpoints Disponibles

Todos los servicios del portátil escuchan en `0.0.0.0` y admiten tráfico directo desde la subred local `tu subred LAN`.

### 2.1. Endpoints del Portátil (`TU_GPU_IP`)

| Endpoint | Método | Worker | Uso |
| :--- | :--- | :--- | :--- |
| `http://TU_GPU_IP:11434/api/tags` | `GET` | Ollama | Health check y lista de modelos activos |
| `http://TU_GPU_IP:11434/api/generate` | `POST` | Ollama | Corrección gramatical estructurada |
| `http://TU_GPU_IP:8001/v1/models` | `GET` | Speaches | Verificación de Whisper y Kokoro cargados |
| `http://TU_GPU_IP:8001/v1/audio/transcriptions` | `POST` | Speaches | STT de voz del usuario a texto |
| `http://TU_GPU_IP:8001/v1/audio/speech` | `POST` | Speaches | Síntesis TTS Kokoro-82M en MP3 |
| `http://TU_GPU_IP:8100/health` | `GET` | Fonemas | Estado del modelo Wav2Vec2 (`device: cuda`) |
| `http://TU_GPU_IP:8200/health` | `GET` | MFA | Estado del alineador acústico |

---

## 3. Pruebas de Flujo y Conectividad (Desde el NAS)

El agente o desarrollador en el NAS puede verificar el circuito en menos de 1 minuto con estos pasos secuenciales:

### Paso 1: Comprobar conectividad básica y modelos disponibles
Ejecutar en la terminal del NAS (o contenedor Docker del backend):
```bash
curl -s http://TU_GPU_IP:11434/api/tags | jq .
```
**Respuesta esperada:** Un JSON con código HTTP 200 listando `qwen3:4b` y `phi4-mini:latest`.

### Paso 2: Probar inferencia en caliente y medir velocidad
```bash
curl -s http://TU_GPU_IP:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3:4b",
    "prompt": "Corrige esta frase de un alumno de inglés: \"She do not likes apples\". Responde en 2 líneas.",
    "stream": false
  }' | jq '{response: .response, tokens_sec: (.eval_count / (.eval_duration / 1000000000))}'
```
**Resultado esperado:**
- Corrección pedagógica instantánea.
- `tokens_sec`: entre **55 y 65 tokens/segundo**.

### Paso 3: Script Python de Validación Automatizada (Para incluir en los tests del Backend)
Guarda este script en el NAS como `test_worker_e2e.py` para validar la conexión desde el entorno de FastAPI:

```python
import asyncio
import httpx
import time

WORKER_URL = "http://TU_GPU_IP:11434"
MODEL = "qwen3:4b"

async def test_full_flow():
    print(f"[*] 1. Conectando con Worker GPU en {WORKER_URL}...")
    async with httpx.AsyncClient(timeout=4.0) as client:
        # 1. Health check
        t0 = time.perf_counter()
        health = await client.get(f"{WORKER_URL}/api/tags")
        assert health.status_code == 200, f"Error en health check: {health.status_code}"
        models = [m["name"] for m in health.json().get("models", [])]
        print(f"[OK] Health check exitoso en {(time.perf_counter()-t0)*1000:.1f}ms")
        print(f"[OK] Modelos activos en worker: {models}")
        assert any(MODEL in m for m in models), f"Modelo {MODEL} no encontrado en worker"

        # 2. Generación pedagógica
        print(f"[*] 2. Probando inferencia pedagógica con {MODEL}...")
        t0 = time.perf_counter()
        payload = {
            "model": MODEL,
            "system": "Eres un tutor de inglés. Corrige el error en 1 frase en español.",
            "prompt": "I have 20 years old and I live in Madrid.",
            "stream": False,
            "options": {"temperature": 0.2}
        }
        res = await client.post(f"{WORKER_URL}/api/generate", json=payload)
        assert res.status_code == 200, f"Error en inferencia: {res.status_code}"
        data = res.json()
        latency = (time.perf_counter() - t0) * 1000
        
        eval_count = data.get("eval_count", 0)
        eval_sec = data.get("eval_duration", 1) / 1e9
        tps = eval_count / eval_sec if eval_sec > 0 else 0
        
        print(f"[OK] Respuesta recibida en {latency:.1f}ms:")
        print(f"     \"{data.get('response', '').strip()}\"")
        print(f"[OK] Rendimiento GPU: {tps:.1f} tokens/segundo ({eval_count} tokens)")

if __name__ == "__main__":
    asyncio.run(test_full_flow())
```

---

## 4. Configuración en el Backend del NAS

### 4.1. Variables de Entorno (`.env` del Backend en el NAS)
Coloca estos parámetros en el archivo `.env` del backend FastAPI (IP detectada del NAS: `TU_NAS_IP`):

```env
# Integración Worker GPU
GPU_WORKER_ENABLED=true
OLLAMA_URL=http://TU_GPU_IP:11434
OLLAMA_MODEL=qwen3:4b
GPU_WORKER_TIMEOUT=4.0
GPU_WORKER_HEALTH_TTL=15

# (Opcional) Registro de fallbacks
LOCAL_WHISPER_URL=http://localhost:9000/v1
```

### 4.2. Cliente Robusto en FastAPI (Patrón Circuit Breaker + Cache TTL)
Para evitar penalizar al usuario si el portátil está suspendido o la red parpadea, implementar este cliente en `backend/app/providers/ollama_provider.py`:

```python
import httpx
import time
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

class RobustOllamaClient:
    def __init__(self, base_url: str, model: str, timeout: float = 4.0, health_ttl: int = 15):
        self.base_url = base_url.rstrip("/")
        self.model = model
        self.timeout = timeout
        self.health_ttl = health_ttl
        self._is_online = False
        self._last_health_check = 0.0
        self._client = httpx.AsyncClient(
            timeout=httpx.Timeout(timeout, connect=1.5),
            limits=httpx.Limits(max_keepalive_connections=10, max_connections=20)
        )

    async def is_available(self) -> bool:
        """Verifica salud con caché TTL para no saturar la red."""
        now = time.time()
        if (now - self._last_health_check) < self.health_ttl:
            return self._is_online

        try:
            resp = await self._client.get(f"{self.base_url}/api/tags")
            if resp.status_code == 200:
                models = [m.get("name", "") for m in resp.json().get("models", [])]
                self._is_online = any(self.model in m for m in models)
            else:
                self._is_online = False
        except Exception as e:
            logger.warning(f"Ollama worker en {self.base_url} no disponible: {e}")
            self._is_online = False

        self._last_health_check = now
        return self._is_online

    async def generate_feedback(self, prompt: str, system_prompt: str) -> Optional[Dict[str, Any]]:
        """Intenta inferencia en GPU. Si falla o da timeout, retorna None para degradación inmediata."""
        if not await self.is_available():
            return None

        t0 = time.perf_counter()
        try:
            payload = {
                "model": self.model,
                "prompt": prompt,
                "system": system_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.25,
                    "top_p": 0.9
                }
            }
            resp = await self._client.post(f"{self.base_url}/api/generate", json=payload)
            resp.raise_for_status()
            data = resp.json()

            latency_ms = (time.perf_counter() - t0) * 1000.0
            eval_count = data.get("eval_count", 0)
            eval_sec = (data.get("eval_duration", 1) or 1) / 1e9
            tps = round(eval_count / eval_sec, 1) if eval_sec > 0 else 0.0

            return {
                "response": data.get("response", "").strip(),
                "latency_ms": round(latency_ms, 1),
                "eval_count": eval_count,
                "eval_duration_sec": eval_sec,
                "tokens_per_sec": tps,
                "engine_used": "fast"
            }
        except (httpx.TimeoutException, httpx.ConnectError) as exc:
            logger.error(f"Fallo de conexión con worker GPU Ollama ({exc}). Activando degradación.")
            self._is_online = False # Invalidar caché de salud
            return None
```

---

## 5. Arquitectura del Pipeline de Auto-Aprendizaje y Auto-Mejora

### 5.1. Principio Fundamental
- **El Portátil (GPU):** Es **stateless**; computa inferencia pura. Nunca debe almacenar la base de datos de usuarios ni los registros históricos para evitar pérdida de datos si se apaga.
- **El NAS (DS224+):** Es la **fuente de la verdad persistente**. Almacena la base de datos (PostgreSQL/SQLite), audios, transcripciones, métricas y feedback de los alumnos.

```
                    ┌──────────────────────────────────────────────────────┐
                    │                   APP DE INGLÉS                      │
                    └──────────────────────────┬───────────────────────────┘
                                               │ Turno de conversación + Feedback (👍/👎)
                                               ▼
                    ┌──────────────────────────────────────────────────────┐
                    │              BACKEND FASTAPI (EN EL NAS)             │
                    │                                                      │
                    │  1. Inyecta Perfil de Errores del Alumno             │
                    │  2. Envía Prompt a Ollama                            │
                    │  3. Guarda Telemetría, Tiempos y Tokens/s            │
                    │  4. Actualiza Historial de Debilidades del Alumno    │
                    └──────────────┬───────────────────────▲───────────────┘
                     Petición HTTP │                       │ Inferencia
                     POST generate │                       │ ~58 tokens/s
                                   ▼                       │
                    ┌──────────────────────────────────────┴───────────────┐
                    │             WORKER GPU (PORTÁTIL RTX 2060)           │
                    │                  Ollama (qwen3:4b)                   │
                    └──────────────────────────────────────────────────────┘
```

---

## 6. Esquema de Logging y Depuración Estructurada (Para el Backend)

Para depurar con precisión y construir el dataset de aprendizaje, el backend debe registrar cada interacción en una tabla SQL dedicada.

### 6.1. Definición de la Tabla `llm_interaction_logs` (SQLAlchemy / PostgreSQL)

```sql
CREATE TABLE llm_interaction_logs (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(64) NOT NULL,
    turn_id INTEGER NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Entrada del usuario
    user_transcript TEXT NOT NULL,
    detected_intent VARCHAR(64),
    
    -- Contexto enviado al LLM
    system_prompt_used TEXT NOT NULL,
    user_prompt_used TEXT NOT NULL,
    model_name VARCHAR(32) NOT NULL,
    
    -- Respuesta y Métricas del Worker (Capturadas por RobustOllamaClient)
    response_text TEXT NOT NULL,
    engine_used VARCHAR(16) NOT NULL, -- 'fast' (GPU) o 'standard' (CPU/Reglas)
    latency_ms FLOAT NOT NULL,
    eval_count INTEGER,               -- Total tokens generados por Ollama
    eval_duration_sec FLOAT,          -- Tiempo de generación en segundos
    tokens_per_second FLOAT,          -- Calculado: eval_count / eval_duration_sec
    
    -- Calidad y Feedback del Alumno (Bucle de Aprendizaje)
    user_feedback_score INTEGER,      -- 1 (Muy útil) a -1 (Confuso / Incorrecto)
    user_repeated_prompt BOOLEAN DEFAULT FALSE,
    error_tag VARCHAR(64),            -- ej. 'grammar_preposition', 'verb_tense'
    notes TEXT
);

CREATE INDEX idx_llm_logs_user ON llm_interaction_logs(user_id);
CREATE INDEX idx_llm_logs_quality ON llm_interaction_logs(user_feedback_score);
```

---

## 7. El Bucle de Auto-Aprendizaje (Implementación Recomendada)

### Fase 1: Memoria Dinámica de Errores (In-Context Learning Inmediato)
No es necesario reentrenar el modelo diariamente. El backend mantiene un perfil del estudiante:
1. En cada turno, si el feedback detecta un error (ej. confusión entre *make* vs *do*), el backend incrementa el contador de ese `error_tag` en la tabla `user_learning_profile`.
2. En las sesiones siguientes, el backend inyecta dinámicamente en el `system_prompt`:
   ```text
   [PERFIL DEL ALUMNO]
   - Nivel estimado: B1
   - Puntos débiles recurrentes: Preposiciones dependientes ("depend on"), 3ª persona singular ("she walks").
   - Instrucción pedagógica: Si el alumno incurre en alguno de estos fallos, prioriza explicárselo con un ejemplo mnemotécnico corto antes de continuar la conversación.
   ```

### Fase 2: Curación de Dataset de Ejemplos Óptimos (Few-Shot Dinámico)
1. Filtrar las filas de `llm_interaction_logs` donde `user_feedback_score == 1` y la explicación fue concisa (< 60 palabras).
2. Crear un almacén de **Few-Shot Examples** en el NAS.
3. El backend inyecta los 2 mejores ejemplos correspondientes a la temática actual en el prompt de Ollama para guiar el estilo de respuesta.

### Fase 3: Modelfile Personalizado en Ollama / Fine-Tuning LoRA
Cuando se disponga de más de 500 interacciones de alta calidad:
1. **Paso A (Inmediato con Modelfile):** Compilar un modelo especializado en el portátil ejecutando:
   ```dockerfile
   # Modelfile-tutor
   FROM qwen3:4b
   PARAMETER temperature 0.25
   PARAMETER stop "<|im_end|>"
   SYSTEM """Eres Lito, el tutor interactivo de inglés de la app. Tu misión es corregir de forma amable, precisa y en menos de 2 frases los errores gramaticales del alumno, explicando el motivo en español y proponiendo el uso natural en inglés."""
   ```
   Crear en Ollama: `ollama create lito-tutor -f ./Modelfile-tutor`
2. **Paso B (Avanzado con LoRA):** Exportar el dataset JSONL curado desde el NAS y entrenar un adaptador LoRA en la GPU RTX 2060 para congelar la metodología de la app en los pesos del modelo.

---

## 8. Procedimiento para Probar el Flujo Completo (Checklist del Agente)

Sigue estos 4 pasos para verificar que todo el circuito está activo y degradando correctamente:

1. **Test A (Conectividad Básica):** Desde el NAS, correr `curl -s http://TU_GPU_IP:11434/api/tags`. Debe devolver HTTP 200 con `qwen3:4b`.
2. **Test B (Script E2E):** Ejecutar en el backend `python test_worker_e2e.py` (código en Sección 3). Debe retornar una respuesta pedagógica en < 1 segundo a > 55 tokens/s.
3. **Test C (App en Vivo con GPU):** Realizar un turno de prueba en la app móvil. El turno debe registrarse en `llm_interaction_logs` con `engine_used: "fast"`.
4. **Test D (Prueba de Resiliencia / Degradación Elegante):** Suspender temporalmente el portátil o desconectar el Wi-Fi. Realizar otro turno en la app: debe responder sin demoras ni errores con `engine_used: "standard"` (reglas locales del NAS). Volver a encender el portátil y comprobar que se recupera automáticamente en < 15 segundos sin reiniciar el backend.

