"""Tracks availability of the optional GPU worker (RTX 2060 laptop) with a
short TTL cache so hot paths don't pay a network round-trip every request."""
import time
import logging
import httpx

from app.config import settings

logger = logging.getLogger("english_brain.worker_health")


class WorkerHealthMonitor:
    def __init__(self):
        self._cache = {}  # key -> (expires_monotonic, value)
        self._registered_url = None
        self._last_register_ts = 0.0

    def _cached(self, key):
        v = self._cache.get(key)
        if v and v[0] > time.monotonic():
            return v[1]
        return None

    def _store(self, key, value):
        self._cache[key] = (time.monotonic() + settings.GPU_WORKER_HEALTH_TTL, value)

    async def _reachable(self, url: str) -> bool:
        try:
            async with httpx.AsyncClient(timeout=settings.GPU_WORKER_TIMEOUT) as client:
                resp = await client.get(url)
                return resp.status_code < 500
        except Exception:  # noqa: BLE001
            return False

    async def llm_online(self) -> bool:
        if not settings.GPU_WORKER_ENABLED:
            return False
        cached = self._cached("llm")
        if cached is not None:
            return cached
        ok = await self._reachable(f"{settings.OLLAMA_URL}/api/tags")
        self._store("llm", ok)
        return ok

    async def stt_online(self) -> bool:
        if not settings.GPU_WORKER_ENABLED:
            return False
        cached = self._cached("stt")
        if cached is not None:
            return cached
        ok = await self._reachable(f"{settings.SPEACHES_URL}/models")
        if not ok:
            ok = await self._reachable(settings.SPEACHES_URL)
        self._store("stt", ok)
        return ok

    def register(self, url: str) -> None:
        """A worker announces itself on startup; clears cache to force a recheck."""
        self._registered_url = url
        self._last_register_ts = time.time()
        self._cache.clear()

    def invalidate(self) -> None:
        self._cache.clear()

    async def status(self) -> dict:
        return {
            "gpu_worker_enabled": settings.GPU_WORKER_ENABLED,
            "llm_online": await self.llm_online(),
            "stt_online": await self.stt_online(),
            "ollama_url": settings.OLLAMA_URL,
            "speaches_url": settings.SPEACHES_URL,
            "registered_url": self._registered_url,
            "last_register_ts": self._last_register_ts,
        }


worker_health = WorkerHealthMonitor()
