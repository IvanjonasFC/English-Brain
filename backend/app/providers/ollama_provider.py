"""
RobustOllamaClient — Patron Circuit Breaker + Cache TTL.
"""
import re
import json
import time
import logging
from typing import Optional, Dict, Any, AsyncIterator
import httpx

logger = logging.getLogger(__name__)

# phi4-mini: sin thinking mode, responde en espanol directamente. ~61 tok/s.
# qwen3:4b: thinking mode (extended reasoning). Mas potente pero respuesta inline larga.
# lito-fast: Modelfile personalizado de qwen3:4b. Pendiente de fix con 'PARAMETER think false'.
DEFAULT_MODEL = "phi4-mini:latest"
BACKUP_MODEL = "qwen3:4b"
ADVANCED_MODEL = "lito-fast:latest"
FALLBACK_MODEL = "phi4-mini:latest"  # Siempre disponible como ultimo recurso

# Regex para eliminar bloques de razonamiento interno de qwen3/lito-fast
_THINK_RE = re.compile(r"<think>.*?</think>", re.DOTALL | re.IGNORECASE)


def _clean_response(text: str) -> str:
    """Elimina bloques <think>...</think> y limpia el texto resultante."""
    return _THINK_RE.sub("", text).strip()


class RobustOllamaClient:
    def __init__(self, base_url: str, model: str = DEFAULT_MODEL, timeout: float = 4.0,
                 gen_timeout: float = 90.0, keep_alive: str = "30m", health_ttl: int = 15,
                 fallback_url: str = ""):
        self._primary = base_url.rstrip("/")
        self._fallback = (fallback_url or "").rstrip("/")
        self.base_url = self._primary
        self.model = model
        self.timeout = timeout            # salud / /api/tags (corto)
        self.gen_timeout = gen_timeout    # generacion / chat (largo)
        self.keep_alive = keep_alive      # modelo residente en VRAM entre llamadas
        self.health_ttl = health_ttl
        self._is_online: bool = False
        self._last_health_check: float = 0.0
        self._available_models: list = []
        # El cliente usa por defecto el timeout LARGO (generacion). Las llamadas de
        # salud pasan un timeout corto explicito para degradar rapido si el worker cae.
        self._client = httpx.AsyncClient(
            timeout=httpx.Timeout(gen_timeout, connect=1.5),
            limits=httpx.Limits(max_keepalive_connections=10, max_connections=20),
        )

    async def is_available(self) -> bool:
        now = time.time()
        if (now - self._last_health_check) < self.health_ttl:
            return self._is_online
        self._is_online = False
        self._loaded_model = None
        # Failover: prueba primario (.65 cable) y luego fallback;
        # se queda con el primero que responda y tenga modelos disponibles.
        candidates = [u for u in (self._primary, self._fallback) if u]
        for candidate in candidates:
            try:
                # 1) Consultar qué modelo está realmente cargado en VRAM/memoria activa
                try:
                    ps_resp = await self._client.get(f"{candidate}/api/ps", timeout=self.timeout)
                    if ps_resp.status_code == 200:
                        ps_data = ps_resp.json()
                        ps_models = [m.get("name", "") or m.get("model", "") for m in ps_data.get("models", [])]
                        if ps_models:
                            self._loaded_model = ps_models[0]
                            logger.info(f"Ollama modelo activo en VRAM ({candidate}): {self._loaded_model}")
                except Exception as ps_err:
                    logger.debug(f"Ollama /api/ps error: {ps_err}")

                # 2) Comprobar modelos instalados
                resp = await self._client.get(f"{candidate}/api/tags", timeout=self.timeout)
                if resp.status_code != 200:
                    continue
                data = resp.json()
                models = [m.get("name", "") for m in data.get("models", [])]
                if models:
                    self._available_models = models
                    self.base_url = candidate
                    self._is_online = True
                    break
            except Exception as exc:
                logger.warning(f"Worker Ollama en {candidate} no disponible: {exc}")
                continue
        self._last_health_check = now
        return self._is_online

    async def get_available_models(self) -> list:
        await self.is_available()
        return self._available_models

    def _resolve_model(self) -> str:
        # 1) Si hay un modelo ya cargado en VRAM (/api/ps), usarlo DIRECTAMENTE en 1 solo intento
        if getattr(self, "_loaded_model", None):
            return self._loaded_model

        av = self._available_models
        if not av:
            return self.model

        # 2) Priorizar modelos rápidos del portátil en orden
        for preferred in ("lito-fast:latest", "lito-fast", self.model, "phi4-mini:latest", "phi4-mini", "qwen3:4b"):
            for m in av:
                if preferred == m or preferred in m or m in preferred:
                    return m

        return av[0]

    async def generate_feedback(self, prompt: str, system_prompt: str, temperature: float = 0.25, fmt: Optional[str] = None, num_ctx: int = 2048, num_predict: int = 256) -> Optional[Dict[str, Any]]:
        if not await self.is_available():
            return None
        model = self._resolve_model()
        t0 = time.perf_counter()
        try:
            payload = {"model": model, "prompt": prompt, "system": system_prompt, "stream": False, "think": False, "keep_alive": self.keep_alive, "options": {"temperature": temperature, "top_p": 0.9, "num_ctx": num_ctx, "num_predict": num_predict, "repeat_penalty": 1.1}}
            if fmt:
                payload["format"] = fmt  # "json" -> Ollama garantiza JSON valido
            resp = await self._client.post(f"{self.base_url}/api/generate", json=payload)
            resp.raise_for_status()
            data = resp.json()
            latency_ms = (time.perf_counter() - t0) * 1000.0
            eval_count = data.get("eval_count", 0)
            eval_sec = (data.get("eval_duration", 1) or 1) / 1e9
            return {"response": _clean_response(data.get("response", "")), "model_used": model, "latency_ms": round(latency_ms, 1), "eval_count": eval_count, "eval_duration_sec": round(eval_sec, 3), "tokens_per_sec": round(eval_count / eval_sec, 1) if eval_sec > 0 else 0.0, "engine_used": "fast"}
        except (httpx.TimeoutException, httpx.ConnectError) as exc:
            logger.error(f"Fallo conexion GPU Ollama ({exc}). Degradando.")
            self._is_online = False
            return None
        except Exception as exc:
            logger.error(f"Error inesperado Ollama: {exc}")
            return None

    async def generate_content_batch(self, system_prompt: str, user_prompt: str, model: Optional[str] = None, temperature: float = 0.7, max_tokens: int = 2000) -> Optional[Dict[str, Any]]:
        if not await self.is_available():
            return None
        effective_model = model or self._resolve_model()
        t0 = time.perf_counter()
        try:
            payload = {"model": effective_model, "prompt": user_prompt, "system": system_prompt, "stream": False, "think": False, "keep_alive": self.keep_alive, "options": {"temperature": temperature, "top_p": 0.95, "num_predict": max_tokens}}
            resp = await self._client.post(f"{self.base_url}/api/generate", json=payload)
            resp.raise_for_status()
            data = resp.json()
            latency_ms = (time.perf_counter() - t0) * 1000.0
            eval_count = data.get("eval_count", 0)
            eval_sec = (data.get("eval_duration", 1) or 1) / 1e9
            return {"response": data.get("response", "").strip(), "model_used": effective_model, "latency_ms": round(latency_ms, 1), "eval_count": eval_count, "tokens_per_sec": round(eval_count / eval_sec, 1) if eval_sec > 0 else 0.0, "engine_used": "fast"}
        except (httpx.TimeoutException, httpx.ConnectError) as exc:
            logger.error(f"Timeout generando contenido Ollama: {exc}")
            self._is_online = False
            return None

    async def chat(self, messages: list, model: Optional[str] = None, temperature: float = 0.3, fmt: Optional[str] = None, num_ctx: int = 3072, num_predict: int = 512) -> Optional[Dict[str, Any]]:
        if not await self.is_available():
            return None
        effective_model = model or self._resolve_model()
        t0 = time.perf_counter()
        try:
            payload = {"model": effective_model, "messages": messages, "stream": False, "think": False, "keep_alive": self.keep_alive, "options": {"temperature": temperature, "num_ctx": num_ctx, "num_predict": num_predict, "repeat_penalty": 1.1}}
            if fmt:
                payload["format"] = fmt  # "json" -> Ollama garantiza JSON valido
            resp = await self._client.post(f"{self.base_url}/api/chat", json=payload)
            resp.raise_for_status()
            data = resp.json()
            latency_ms = (time.perf_counter() - t0) * 1000.0
            eval_count = data.get("eval_count", 0)
            eval_sec = (data.get("eval_duration", 1) or 1) / 1e9
            content = _clean_response(data.get("message", {}).get("content", ""))  # quita <think> de modelos thinking
            return {"response": content, "model_used": effective_model, "latency_ms": round(latency_ms, 1), "eval_count": eval_count, "tokens_per_sec": round(eval_count / eval_sec, 1) if eval_sec > 0 else 0.0, "engine_used": "fast"}
        except (httpx.TimeoutException, httpx.ConnectError) as exc:
            logger.error(f"Timeout chat Ollama: {exc}")
            self._is_online = False
            return None

    async def chat_stream(
        self,
        messages: list,
        model: Optional[str] = None,
        temperature: float = 0.4,
        num_ctx: int = 2048,
        num_predict: int = 220,
    ) -> AsyncIterator[Dict[str, Any]]:
        """Generador asincrono para STREAMING de /api/chat de Ollama.

        Emite dicts:
          {"delta": <trozo de texto>}   por cada chunk generado
          {"done": True, "model_used": ..., "tokens_per_sec": ..., "latency_ms": ...}  al final

        Si el worker GPU no esta disponible, no emite nada (el caller degrada).
        Ante un fallo de conexion a mitad, marca offline y relanza la excepcion
        para que el caller haga fallback al flujo no-streaming.
        """
        if not await self.is_available():
            return
        effective_model = model or self._resolve_model()
        payload = {
            "model": effective_model,
            "messages": messages,
            "stream": True,
            "think": False,
            "keep_alive": self.keep_alive,
            "options": {
                "temperature": temperature,
                "num_ctx": num_ctx,
                "num_predict": num_predict,
                "repeat_penalty": 1.1,
            },
        }
        t0 = time.perf_counter()
        try:
            async with self._client.stream(
                "POST", f"{self.base_url}/api/chat", json=payload
            ) as resp:
                resp.raise_for_status()
                async for line in resp.aiter_lines():
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        data = json.loads(line)
                    except Exception:
                        continue
                    chunk = (data.get("message") or {}).get("content", "")
                    if chunk:
                        yield {"delta": chunk}
                    if data.get("done"):
                        eval_count = data.get("eval_count", 0) or 0
                        eval_sec = (data.get("eval_duration", 1) or 1) / 1e9
                        yield {
                            "done": True,
                            "model_used": effective_model,
                            "tokens_per_sec": round(eval_count / eval_sec, 1) if eval_sec > 0 else 0.0,
                            "latency_ms": round((time.perf_counter() - t0) * 1000.0, 1),
                        }
                        return
        except (httpx.TimeoutException, httpx.ConnectError) as exc:
            logger.error(f"chat_stream fallo de conexion Ollama: {exc}. Degradando.")
            self._is_online = False
            raise

    async def close(self):
        await self._client.aclose()


_ollama_client: Optional[RobustOllamaClient] = None

def get_ollama_client() -> RobustOllamaClient:
    global _ollama_client
    if _ollama_client is None:
        from app.config import settings
        url = settings.GPU_WORKER_URL or settings.OLLAMA_URL
        model = getattr(settings, "OLLAMA_MODEL", DEFAULT_MODEL)
        _ollama_client = RobustOllamaClient(base_url=url, model=model, timeout=settings.GPU_WORKER_TIMEOUT, gen_timeout=getattr(settings, "OLLAMA_GEN_TIMEOUT", 90.0), keep_alive=getattr(settings, "OLLAMA_KEEP_ALIVE", "30m"), health_ttl=settings.GPU_WORKER_HEALTH_TTL, fallback_url=getattr(settings, "OLLAMA_FALLBACK_URL", ""))
        logger.info(f"RobustOllamaClient inicializado -> {url} (modelo: {model})")
    return _ollama_client
