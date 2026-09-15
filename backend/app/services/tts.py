import asyncio
import os
import hashlib
import logging
import httpx
from app.config import settings, live_chain, mark_worker_up, mark_worker_down, worker_is_down

logger = logging.getLogger(__name__)

# Try importing edge-tts
try:
    import edge_tts
    HAS_EDGE_TTS = True
except ImportError:
    HAS_EDGE_TTS = False


class TTSService:
    def __init__(self):
        self.endpoint = f"{settings.SPEACHES_URL}/audio/speech"
        self.cache_dir = settings.AUDIO_CACHE_DIR
        os.makedirs(self.cache_dir, exist_ok=True)
        self._cache_hits = 0
        self._cache_misses = 0
        self._total_requests = 0

    def get_audio_path(self, filename: str) -> str:
        return os.path.join(self.cache_dir, filename)

    def get_cache_stats(self) -> dict:
        total = self._total_requests
        hits = self._cache_hits
        misses = self._cache_misses
        hit_rate = round((hits / total * 100), 2) if total > 0 else 100.0

        file_count = 0
        total_size_bytes = 0
        try:
            for f in os.scandir(self.cache_dir):
                if f.is_file():
                    file_count += 1
                    total_size_bytes += f.stat().st_size
        except Exception:
            pass

        return {
            "total_requests": total,
            "cache_hits": hits,
            "cache_misses": misses,
            "hit_rate_pct": hit_rate,
            "cached_files_count": file_count,
            "cache_size_mb": round(total_size_bytes / (1024 * 1024), 2),
            "engine": "edge_neural_v1" if HAS_EDGE_TTS else "speaches_kokoro_v1",
        }

    # Voces Kokoro soportadas (English). La app puede pedir cualquiera; si no
    # existe en el worker, se degrada a am_michael (no a Piper).
    _KOKORO_VOICES = {
        "am_michael", "am_adam", "am_echo", "am_eric", "am_liam", "am_onyx",
        "af_heart", "af_bella", "af_nicole", "af_sarah",
        "bf_emma", "bf_alice", "bf_lily",
        "bm_fable", "bm_george", "bm_lewis",
    }

    def _resolve_edge_voice(self, voice: str) -> str:
        """Mapea la voz (Kokoro o alias) a una voz valida de Edge Neural,
        conservando acento US/UK. Evita el error 'Invalid voice' en el fallback."""
        v = (voice or "").strip()
        low = v.lower()
        if v.endswith("Neural"):
            return v
        if low in ("female", "jenny", "en-us-jenny"):
            return "en-US-JennyNeural"
        if low in ("male", "guy", "en-us-guy"):
            return "en-US-GuyNeural"
        if low.startswith("bf_"):
            return "en-GB-SoniaNeural"   # UK female (Emma)
        if low.startswith("bm_"):
            return "en-GB-RyanNeural"    # UK male (Fable)
        if low.startswith("af_"):
            return "en-US-JennyNeural"   # US female
        return "en-US-GuyNeural"         # US male (am_michael y por defecto)

    def _resolve_kokoro_voice(self, voice: str) -> str:
        v = (voice or "").strip()
        if v in self._KOKORO_VOICES:
            return v
        low = v.lower()
        if low in ("en-us-jennyneural", "female", "jenny"):
            return "bf_emma"
        return "am_michael"

    async def synthesize(
        self,
        text: str,
        voice: str = "en-US-GuyNeural",
        rate: str = "+0%",
    ) -> str:
        """
        Synthesizes speech using Microsoft Edge Neural TTS as primary high-quality engine,
        with fallback to Speaches (Piper/Kokoro) and local cache.
        Returns the filename stored in the audio cache.
        """
        if not text:
            return ""

        self._total_requests += 1

        # Normalize text and rate parameter
        cleaned_text = text.strip()
        rate_str = str(rate).strip().replace("%25", "%")
        if not rate_str.endswith("%"):
            rate_str = f"{rate_str}%"
        if not (rate_str.startswith("+") or rate_str.startswith("-")):
            rate_str = f"+{rate_str}"

        engine_tag = "edge_neural_v1" if HAS_EDGE_TTS else "speaches_kokoro_v1"
        text_hash = hashlib.sha256(f"{cleaned_text}_{voice}_{rate_str}_{engine_tag}".encode("utf-8")).hexdigest()[:18]
        filename = f"tts_{text_hash}.mp3"
        filepath = os.path.join(self.cache_dir, filename)

        if os.path.exists(filepath) and os.path.getsize(filepath) > 100:
            self._cache_hits += 1
            return filename

        # Red de seguridad del NAS: audio "provisional" (voz Piper, peor calidad)
        # que se genera SOLO cuando el portatil esta caido. Nunca sustituye a la
        # cache buena del portatil: en cuanto el .65 vuelve, el siguiente miss
        # regenera el canonico y borra el provisional.
        prov_name = f"tts_{text_hash}.nas.mp3"
        prov_path = os.path.join(self.cache_dir, prov_name)
        _primary_url = (getattr(settings, "SPEACHES_URL", "") or "").rstrip("/")
        # Si el portatil sigue en cooldown (caido) y ya hay provisional, servirlo
        # sin volver a machacar al NAS en cada peticion.
        if (_primary_url and worker_is_down(_primary_url)
                and os.path.exists(prov_path) and os.path.getsize(prov_path) > 100):
            self._cache_misses += 1
            return prov_name

        self._cache_misses += 1
        # Métrica: alertar si el hit-rate baja de 90% tras 50 peticiones
        if self._total_requests > 50:
            current_rate = (self._cache_hits / self._total_requests) * 100.0
            if current_rate < 90.0:
                logger.warning(
                    f"[TTS Cache Warning] Hit-rate cayó a {current_rate:.1f}% (<90%). "
                    f"Revisa posibles invalidaciones de claves o cambios de parámetros."
                )

        # Trocea en frases <=220 chars (mejor prosodia, evita cortes del motor).
        sentences = [s.strip() for s in cleaned_text.replace("\n", " ").split(".") if s.strip()]
        if not sentences:
            sentences = [cleaned_text]
        chunks, current = [], ""
        for s in sentences:
            if len(current) + len(s) < 220:
                current = f"{current}. {s}" if current else s
            else:
                if current:
                    chunks.append(current)
                current = s
        if current:
            chunks.append(current)

        # 1. Motor PRINCIPAL: Speaches por LAN (sin TLS saliente).
        #    Primario portatil .65 (Kokoro GPU) -> fallback Speaches del NAS (Piper).
        #    Por endpoint se prueba el payload Kokoro y, si no lo sirve, el de Piper.
        # live_chain salta las bases en cooldown por caida reciente (mismo
        # circuit breaker que usa el STT). Puede quedar solo el fallback del NAS.
        bases = live_chain(getattr(settings, "SPEACHES_URL", ""),
                           getattr(settings, "SPEACHES_FALLBACK_URL", ""))
        if not bases:
            # Todo en cooldown: probamos igual el primario para reavivarlo.
            bases = [b for b in [getattr(settings, "SPEACHES_URL", ""),
                                 getattr(settings, "SPEACHES_FALLBACK_URL", "")] if b]
        if not bases:
            bases = [self.endpoint.rsplit("/audio/speech", 1)[0]]

        # Voz Kokoro pedida por la app. Reintento a am_michael si no existe, y
        # Piper (lessac) como ultimo recurso LAN.
        _kokoro_voice = self._resolve_kokoro_voice(voice)
        _payloads = [
            {"model": "speaches-ai/Kokoro-82M-v1.0-ONNX", "voice": _kokoro_voice, "response_format": "mp3"},
            {"model": "speaches-ai/Kokoro-82M-v1.0-ONNX", "voice": "am_michael", "response_format": "mp3"},
            {"model": "tts-1", "voice": "en_US-lessac-medium", "response_format": "mp3"},
        ]
        from app.services.ai_client import ai_client, gpu_semaphore

        # Timeout con CONNECT corto: si un endpoint esta caido (p.ej. Speaches del
        # .65 apagado), falla en ~2.5s en vez de colgarse 15s por payload. El READ
        # es amplio porque Kokoro en GPU puede tardar en frases largas.
        _tts_timeout = httpx.Timeout(30.0, connect=3.0, read=30.0)

        for base in bases:
            ep = f"{base.rstrip('/')}/audio/speech"
            audio_bytes = bytearray()
            ok = True
            endpoint_dead = False
            try:
                async with gpu_semaphore:
                    for chunk in chunks:
                        got = False
                        for base_p in _payloads:
                            p = dict(base_p); p["input"] = chunk
                            try:
                                r = await ai_client.post(ep, json=p, timeout=_tts_timeout)
                            except (httpx.ConnectError, httpx.ConnectTimeout, httpx.PoolTimeout) as ce:
                                # Endpoint inalcanzable: no reintentamos los demas
                                # payloads contra el mismo endpoint muerto.
                                logger.warning(f"[TTS] {ep} INALCANZABLE: {ce!r}")
                                mark_worker_down(base)
                                endpoint_dead = True
                                break
                            except Exception as rex:
                                logger.warning(f"[TTS] {ep} error de red: {rex!r}")
                                continue
                            if r.status_code == 200 and len(r.content) > 50:
                                audio_bytes.extend(r.content); got = True; break
                            else:
                                snippet = ""
                                try:
                                    snippet = r.text[:180]
                                except Exception:
                                    pass
                                logger.warning(
                                    f"[TTS] {ep} HTTP {r.status_code} "
                                    f"voz={p.get('voice')} model={p.get('model')} -> {snippet}"
                                )
                        if endpoint_dead:
                            ok = False; break
                        if not got:
                            ok = False; break
                if ok and len(audio_bytes) > 100:
                    mark_worker_up(base)
                    is_primary = (not _primary_url) or (base.rstrip("/") == _primary_url)
                    if is_primary:
                        # Voz BUENA del portatil (.65) -> cache CANONICA permanente.
                        with open(filepath, "wb") as f:
                            f.write(audio_bytes)
                        try:
                            if os.path.exists(prov_path):
                                os.remove(prov_path)  # el canonico manda: fuera provisional
                        except Exception:
                            pass
                        logger.info(f"[TTS] .65 sintetizo CANONICO {filename} ({len(audio_bytes)} bytes)")
                        return filename
                    # Voz del NAS (Piper): PROVISIONAL, no contamina la cache buena.
                    with open(prov_path, "wb") as f:
                        f.write(audio_bytes)
                    logger.info(f"[TTS] NAS sintetizo PROVISIONAL {prov_name} ({len(audio_bytes)} bytes)")
                    return prov_name
            except Exception as exc:
                logger.warning(f"[TTS] Fallo inesperado en {ep}: {exc!r}")

        # 2. Fallbacks de NUBE (Edge / Google): requieren TLS saliente que el NAS
        #    normalmente NO tiene, asi que anaden ~7s de latencia y SIEMPRE fallan.
        #    Desactivados por defecto. Actívalos con ALLOW_CLOUD_TTS=true SOLO si el
        #    NAS tiene salida real a internet.
        allow_cloud = bool(getattr(settings, "ALLOW_CLOUD_TTS", False))
        if allow_cloud and HAS_EDGE_TTS:
            try:
                edge_voice = self._resolve_edge_voice(voice)
                communicate = edge_tts.Communicate(cleaned_text, edge_voice, rate=rate_str)
                await asyncio.wait_for(communicate.save(filepath), timeout=3.5)
                if os.path.exists(filepath) and os.path.getsize(filepath) > 100:
                    logger.info(f"Edge TTS synthesized {filepath}")
                    return filename
            except Exception as exc:
                logger.warning(f"Edge TTS failed: {exc}")

        # 3. Ultimo recurso de nube: Google TTS HTTP directo (tambien requiere salida).
        if allow_cloud:
            try:
                import urllib.parse
                clean_q = cleaned_text.replace('"', '').replace('“', '').replace('”', '').strip()
                gtts_url = f"https://translate.google.com/translate_tts?ie=UTF-8&q={urllib.parse.quote(clean_q[:300])}&tl=en&client=tw-ob"
                async with httpx.AsyncClient(timeout=httpx.Timeout(3.0)) as client:
                    gresp = await client.get(gtts_url, headers={"User-Agent": "Mozilla/5.0"})
                    if gresp.status_code == 200 and len(gresp.content) > 100:
                        with open(filepath, "wb") as f:
                            f.write(gresp.content)
                        logger.info(f"Google TTS sintetizo {filepath}")
                        return filename
            except Exception as gerr:
                logger.debug(f"Google TTS error: {gerr}")

        # Ultima red: si hay un provisional del NAS de antes, servirlo (mejor eso
        # que la voz nativa del movil) mientras el portatil no vuelva.
        if os.path.exists(prov_path) and os.path.getsize(prov_path) > 100:
            logger.info(f"[TTS] Sirvo PROVISIONAL previo {prov_name}")
            return prov_name

        # 4. Si todo falla, devolver string vacio
        return ""

    async def prefetch_batch(self, items: list[dict], max_concurrency: int = 4) -> dict:
        """
        Pre-genera audios en lote con límite de concurrencia.
        Cada item en items: {"text": str, "voice": Optional[str], "rate": Optional[str]}
        """
        sem = asyncio.Semaphore(max_concurrency)
        total = len(items)
        synthesized_count = 0
        already_cached_count = 0
        error_count = 0

        async def _process_item(it: dict):
            nonlocal synthesized_count, already_cached_count, error_count
            txt = it.get("text", "").strip()
            if not txt:
                return
            v = it.get("voice", "en-US-GuyNeural")
            r = it.get("rate", "+0%")

            engine_tag = "edge_neural_v1" if HAS_EDGE_TTS else "speaches_kokoro_v1"
            text_hash = hashlib.sha256(f"{txt}_{v}_{r}_{engine_tag}".encode("utf-8")).hexdigest()[:18]
            fname = f"tts_{text_hash}.mp3"
            fpath = os.path.join(self.cache_dir, fname)

            if os.path.exists(fpath) and os.path.getsize(fpath) > 100:
                already_cached_count += 1
                return

            async with sem:
                try:
                    res = await self.synthesize(text=txt, voice=v, rate=r)
                    if res:
                        synthesized_count += 1
                    else:
                        error_count += 1
                except Exception as exc:
                    logger.warning(f"Prefetch failed for '{txt[:20]}': {exc}")
                    error_count += 1

        tasks = [_process_item(item) for item in items]
        await asyncio.gather(*tasks, return_exceptions=True)

        return {
            "total_items": total,
            "already_cached": already_cached_count,
            "synthesized_now": synthesized_count,
            "errors": error_count,
            "cache_stats": self.get_cache_stats(),
        }


tts_service = TTSService()


