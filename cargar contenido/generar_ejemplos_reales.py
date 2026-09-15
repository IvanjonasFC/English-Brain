#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador de Plantillas y Ejemplos Reales — English Brain
Extrae ejemplos representativos de los seeds actuales para usarlos como guía.
"""

import json
import os
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
BACKEND_SEED_DIR = os.path.join(PROJECT_ROOT, "backend", "app", "seed")


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if isinstance(data, dict):
        return data.get("items", [])
    return data if isinstance(data, list) else []


def save_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def main():
    # 1. Vocabulario (General y Tech)
    vocab = load_json(os.path.join(BACKEND_SEED_DIR, "vocab.json"))
    if vocab:
        save_json(
            os.path.join(SCRIPT_DIR, "01_vocabulario", "EJEMPLO_REAL_PACK_TECH.json"),
            [vocab[0]],
        )
        # Buscar uno general
        gen_pack = next((p for p in vocab if "General" in p.get("level", "")), None)
        if gen_pack:
            save_json(
                os.path.join(SCRIPT_DIR, "01_vocabulario", "EJEMPLO_REAL_PACK_GENERAL.json"),
                [gen_pack],
            )

    # 2. Gramática
    grammar = load_json(os.path.join(BACKEND_SEED_DIR, "grammar.json"))
    if grammar:
        save_json(
            os.path.join(SCRIPT_DIR, "02_gramatica", "EJEMPLO_REAL_UNIDAD_GRAMATICA.json"),
            [grammar[0]],
        )

    # 3. Inmersión / Comprensión
    comp = load_json(os.path.join(BACKEND_SEED_DIR, "comprehension_seed.json"))
    if comp:
        gen_story = next((s for s in comp if s.get("domain") == "general"), comp[0])
        tech_story = next((s for s in comp if s.get("domain") == "tech"), comp[-1])
        save_json(
            os.path.join(SCRIPT_DIR, "03_inmersion", "EJEMPLO_REAL_LECTURA_GENERAL.json"),
            [gen_story],
        )
        save_json(
            os.path.join(SCRIPT_DIR, "03_inmersion", "EJEMPLO_REAL_LECTURA_TECH.json"),
            [tech_story],
        )

    # 4. Entrevistas
    questions = load_json(os.path.join(BACKEND_SEED_DIR, "questions.json"))
    if questions:
        save_json(
            os.path.join(SCRIPT_DIR, "04_entrevistas", "EJEMPLO_REAL_PREGUNTA_ENTREVISTA.json"),
            questions[:2],
        )

    print("✅ Ejemplos reales generados con éxito en las carpetas 01 a 04.")


if __name__ == "__main__":
    main()
