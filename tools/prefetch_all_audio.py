#!/usr/bin/env python3
"""
Worker / Script de Prefetch Nocturno de Audios TTS.
Pre-genera el audio de todo el contenido del sistema (preguntas, packs de vocabulario, frases de ejemplo y pares mínimos)
para garantizar 0 ms de latencia en la primera reproducción del alumno.
"""
import os
import sys
import json
import asyncio
import logging

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app.services.tts import tts_service

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("audio_prefetch")


def collect_texts_to_prefetch() -> list[dict]:
    items_to_cache = []
    seen = set()

    def _add(txt: str, voice: str = "en-US-GuyNeural", rate: str = "+0%"):
        t = (txt or "").strip()
        if not t or len(t) < 2:
            return
        key = f"{t}_{voice}_{rate}"
        if key not in seen:
            seen.add(key)
            items_to_cache.append({"text": t, "voice": voice, "rate": rate})

    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

    # 1. Questions
    questions_file = os.path.join(base_dir, "backend", "app", "seed", "questions.json")
    if os.path.exists(questions_file):
        try:
            with open(questions_file, "r", encoding="utf-8") as f:
                q_list = json.load(f)
                for q in q_list:
                    _add(q.get("text", ""))
                    _add(q.get("title", ""))
            logger.info(f"Loaded questions from {questions_file}")
        except Exception as e:
            logger.warning(f"Error reading questions: {e}")

    # 2. Vocabulary Packs in flutter assets / seeds
    vocab_assets_dir = os.path.join(base_dir, "app", "assets", "content")
    if os.path.exists(vocab_assets_dir):
        for fname in os.listdir(vocab_assets_dir):
            if fname.endswith(".json"):
                fpath = os.path.join(vocab_assets_dir, fname)
                try:
                    with open(fpath, "r", encoding="utf-8") as f:
                        data = json.load(f)
                        if isinstance(data, list):
                            for it in data:
                                if isinstance(it, dict):
                                    _add(it.get("term", ""))
                                    _add(it.get("example_sentence", "") or it.get("exampleSentence", ""))
                                    # Modo lento para fonética
                                    _add(it.get("term", ""), rate="-20%")
                        elif isinstance(data, dict):
                            items = data.get("items", [])
                            for it in items:
                                _add(it.get("term", ""))
                                _add(it.get("example_sentence", "") or it.get("exampleSentence", ""))
                                _add(it.get("term", ""), rate="-20%")
                except Exception as e:
                    logger.warning(f"Error reading {fpath}: {e}")

    # 3. Comprehension Stories & Listening Pieces
    comp_file = os.path.join(base_dir, "backend", "app", "seed", "comprehension_seed.json")
    if os.path.exists(comp_file):
        try:
            with open(comp_file, "r", encoding="utf-8") as f:
                c_data = json.load(f)
                c_items = c_data.get("items", []) if isinstance(c_data, dict) else c_data
                for c in c_items:
                    if isinstance(c, dict):
                        _add(c.get("body", ""))
                        _add(c.get("title", ""))
            logger.info(f"Loaded comprehension pieces from {comp_file}")
        except Exception as e:
            logger.warning(f"Error reading comprehension seeds: {e}")

    return items_to_cache


async def main():
    logger.info("=== Iniciando Prefetch por Lotes de Audio TTS ===")
    items = collect_texts_to_prefetch()
    logger.info(f"Total de fragmentos de audio a pre-procesar: {len(items)}")

    if not items:
        logger.info("No hay items que procesar.")
        return

    result = await tts_service.prefetch_batch(items, max_concurrency=4)
    logger.info("=== Resumen de Prefetch ===")
    logger.info(f"Total items evaluados: {result['total_items']}")
    logger.info(f"Ya en caché (0 ms): {result['already_cached']}")
    logger.info(f"Sintetizados ahora: {result['synthesized_now']}")
    logger.info(f"Errores: {result['errors']}")
    logger.info(f"Estadísticas de caché: {json.dumps(result['cache_stats'], indent=2)}")


if __name__ == "__main__":
    asyncio.run(main())
