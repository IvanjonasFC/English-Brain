"""
Script de precarga y pre-caching de audios Kokoro HD / Edge TTS para Verbos Irregulares y Phrasal Verbs.
Envía todas las frases y formas verbales al endpoint de prefetch del backend para asegurar 0 ms de latencia.
"""
import re
import os
import sys
import json
import httpx
import asyncio

BACKEND_URL = os.environ.get("BACKEND_URL", "http://localhost:8000")
if not BACKEND_URL.endswith("/api"):
    API_URL = f"{BACKEND_URL.rstrip('/')}/api/tts/prefetch"
else:
    API_URL = f"{BACKEND_URL}/tts/prefetch"

IRREGULAR_DATA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "app", "lib", "features", "irregular_verbs", "data", "irregular_verbs_data.dart"
)
PHRASAL_DATA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "app", "lib", "features", "phrasal_verbs", "data", "phrasal_verbs_data.dart"
)


def extract_phrases_from_file(filepath: str) -> set[str]:
    phrases = set()
    if not os.path.exists(filepath):
        print(f"Advertencia: Archivo no encontrado: {filepath}")
        return phrases

    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Extraer campos de texto comunes
    patterns = [
        r"v1:\s*'([^']+)'",
        r"v2:\s*'([^']+)'",
        r"v3:\s*'([^']+)'",
        r"examplePastSentence:\s*'([^']+)'",
        r"exampleParticipleSentence:\s*'([^']+)'",
        r"fullPhrase:\s*'([^']+)'",
        r"dailySyncExample:\s*'([^']+)'",
        r"workplaceExample:\s*'([^']+)'",
    ]

    for pat in patterns:
        matches = re.findall(pat, content)
        for m in matches:
            cleaned = m.strip()
            if cleaned and len(cleaned) > 1:
                phrases.add(cleaned)

    return phrases


async def main():
    print("=== Extrayendo frases de Verbos Irregulares y Phrasal Verbs ===")
    irreg_phrases = extract_phrases_from_file(IRREGULAR_DATA_PATH)
    phrasal_phrases = extract_phrases_from_file(PHRASAL_DATA_PATH)

    all_phrases = irreg_phrases.union(phrasal_phrases)
    print(f"Total de frases/formas extraídas: {len(all_phrases)} ({len(irreg_phrases)} irregulares, {len(phrasal_phrases)} phrasals)")

    # Crear items tanto para velocidad normal (+0%) como lenta (-20%)
    items = []
    for p in all_phrases:
        items.append({"text": p, "voice": "en-US-GuyNeural", "rate": "+0%"})
        items.append({"text": p, "voice": "en-US-GuyNeural", "rate": "-20%"})

    print(f"Total de variantes de audio a verificar/sintetizar: {len(items)}")
    print(f"Enviando lote al backend: {API_URL}")

    # Enviar en bloques de 100 items
    chunk_size = 100
    total_synthesized = 0
    total_already_cached = 0

    async with httpx.AsyncClient(timeout=120.0) as client:
        for i in range(0, len(items), chunk_size):
            chunk = items[i : i + chunk_size]
            payload = {"items": chunk, "max_concurrency": 4}
            try:
                resp = await client.post(API_URL, json=payload)
                if resp.status_code == 200:
                    data = resp.json()
                    cached = data.get("already_cached", 0)
                    synth = data.get("synthesized_now", 0)
                    total_already_cached += cached
                    total_synthesized += synth
                    print(f"Bloque {i//chunk_size + 1}/{(len(items)+chunk_size-1)//chunk_size}: {cached} en caché, {synth} sintetizados.")
                else:
                    print(f"Error en bloque {i//chunk_size + 1}: HTTP {resp.status_code} - {resp.text[:100]}")
            except Exception as e:
                print(f"Excepción al conectar con el backend: {e}")
                print("Asegúrate de que el backend esté en ejecución en el puerto especificado.")
                break

    print("\n=== Resumen de Precarga ===")
    print(f"Audios ya en caché: {total_already_cached}")
    print(f"Audios nuevos generados: {total_synthesized}")
    print("Precarga finalizada con éxito.")


if __name__ == "__main__":
    asyncio.run(main())
