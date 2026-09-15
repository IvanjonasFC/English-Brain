"""
Test E2E de conexion y latencia con el Cluster GPU (RTX 2060 - 192.168.0.65).
Valida los 4 microservicios nativos:
  1) Ollama LLM (:11434) -> lito-fast:latest / qwen3:4b
  2) Speaches STT (:8001) -> Faster-Whisper Base
  3) Worker Fonemas (:8100) -> wav2vec2 IPA
  4) Worker MFA (:8200) -> torchaudio forced-align
Ejecutar desde el backend: python test_worker_e2e.py
"""
import asyncio
import httpx
import time

GPU_HOST = "192.168.0.65"
OLLAMA_URL = f"http://{GPU_HOST}:11434"
SPEACHES_URL = f"http://{GPU_HOST}:8001/v1"
PHONEME_URL = f"http://{GPU_HOST}:8100"
MFA_URL = f"http://{GPU_HOST}:8200"

MODEL_PRIMARY = "lito-fast:latest"
MODEL_FALLBACK = "qwen3:4b"


async def test_full_cluster():
    print()
    print("=" * 65)
    print(f"  TEST E2E: Cluster GPU Nativo RTX 2060 ({GPU_HOST})")
    print("=" * 65)

    limits = httpx.Limits(max_keepalive_connections=20, max_connections=50)
    async with httpx.AsyncClient(limits=limits, timeout=httpx.Timeout(90.0, connect=2.0)) as client:

        # ── 1. Microservicio Ollama LLM (:11434) ───────────────────────
        print()
        print("[1/4] Comprobando Ollama LLM (:11434)...")
        t0 = time.perf_counter()
        try:
            health = await client.get(f"{OLLAMA_URL}/api/tags", timeout=4.0)
            assert health.status_code == 200, f"HTTP {health.status_code}"
            latency_ms = (time.perf_counter() - t0) * 1000
            models_raw = health.json().get("models", [])
            model_names = [m["name"] for m in models_raw]
            print(f"  [OK] Ollama respondio en {latency_ms:.1f}ms con {len(model_names)} modelos:")
            for m in model_names:
                marker = " <-- MODELO C1 RESIDENTE" if "lito-fast" in m else (" <-- BACKUP" if "qwen3:4b" in m else "")
                print(f"       - {m}{marker}")

            model_to_use = MODEL_PRIMARY if any("lito-fast" in m for m in model_names) else MODEL_FALLBACK
            print(f"  [*] Probando inferencia con {model_to_use}...")
            t_inf = time.perf_counter()
            gen_res = await client.post(
                f"{OLLAMA_URL}/api/generate",
                json={
                    "model": model_to_use,
                    "prompt": "She don't know nothing about the cloud deployment.",
                    "system": "Eres Lito, tutor de ingles C1. Corrige en 1 frase en español.",
                    "stream": False,
                    "think": False,
                    "options": {"temperature": 0.2, "num_ctx": 2048, "num_predict": 120}
                },
                timeout=20.0
            )
            if gen_res.status_code == 200:
                gen_data = gen_res.json()
                eval_count = gen_data.get("eval_count", 0)
                eval_sec = gen_data.get("eval_duration", 1) / 1e9
                tps = eval_count / eval_sec if eval_sec > 0 else 0
                inf_ms = (time.perf_counter() - t_inf) * 1000
                print(f"  [OK] Respuesta en {inf_ms:.0f}ms ({tps:.1f} tok/s):")
                print(f'       "{gen_data.get("response", "").strip()}"')
        except Exception as e:
            print(f"  [WARN] Ollama no respondio o fallo: {e}")

        # ── 2. Microservicio Speaches STT (:8001) ───────────────────────
        print()
        print("[2/4] Comprobando Speaches STT / Faster-Whisper (:8001)...")
        t0 = time.perf_counter()
        try:
            stt_health = await client.get(f"{SPEACHES_URL}/models", timeout=4.0)
            latency_ms = (time.perf_counter() - t0) * 1000
            if stt_health.status_code == 200:
                models = stt_health.json().get("data", [])
                m_ids = [m.get("id") for m in models if m.get("id")]
                print(f"  [OK] Speaches online en {latency_ms:.1f}ms. Modelos activos: {m_ids}")
            else:
                print(f"  [WARN] Speaches respondio HTTP {stt_health.status_code}")
        except Exception as e:
            print(f"  [WARN] Speaches (:8001) no disponible: {e}")

        # ── 3. Worker Fonemas wav2vec2 (:8100) ──────────────────────────
        print()
        print("[3/4] Comprobando Worker Fonemas wav2vec2 (:8100)...")
        t0 = time.perf_counter()
        try:
            ph_health = await client.get(f"{PHONEME_URL}/health", timeout=4.0)
            latency_ms = (time.perf_counter() - t0) * 1000
            if ph_health.status_code == 200:
                print(f"  [OK] Worker Fonemas online en {latency_ms:.1f}ms: {ph_health.json()}")
            else:
                print(f"  [WARN] Worker Fonemas respondio HTTP {ph_health.status_code}")
        except Exception as e:
            print(f"  [WARN] Worker Fonemas (:8100) no disponible: {e}")

        # ── 4. Worker MFA torchaudio (:8200) ───────────────────────────
        print()
        print("[4/4] Comprobando Worker MFA Forced Aligner (:8200)...")
        t0 = time.perf_counter()
        try:
            mfa_health = await client.get(f"{MFA_URL}/health", timeout=4.0)
            latency_ms = (time.perf_counter() - t0) * 1000
            if mfa_health.status_code == 200:
                print(f"  [OK] Worker MFA online en {latency_ms:.1f}ms: {mfa_health.json()}")
            else:
                print(f"  [WARN] Worker MFA respondio HTTP {mfa_health.status_code}")
        except Exception as e:
            print(f"  [WARN] Worker MFA (:8200) no disponible: {e}")

    print()
    print("=" * 65)
    print("  VERIFICACION DE CLUSTER GPU COMPLETADA")
    print("=" * 65)
    print()


if __name__ == "__main__":
    asyncio.run(test_full_cluster())
