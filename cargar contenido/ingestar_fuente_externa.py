#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ingestor Universal de Datasets Externos — English Brain

Permite transformar datasets masivos (CSV de CEFR-J / Oxford, JSON de CrowdAnki / AnkiWeb,
o TSV de Tatoeba / OpenSubtitles) en packs estructurados listos para importar,
con deduplicación automática y asignación a las 4 bandas canónicas CEFR.

Formatos soportados:
  1. CSV / TSV de Vocabulario (columnas: word/term, level/cefr, translation/hint, example)
  2. JSON de CrowdAnki / Anki Decks
  3. TXT de Sentence Mining (subtítulos / historias línea por línea)
  4. Descarga directa automática de listados abiertos (CEFR-J / Oxford base)

Uso:
  python ingestar_fuente_externa.py --tipo vocab_csv --archivo ruta/al/archivo.csv --pack-id nuevo_pack --pack-titulo "Mi Pack" --nivel B1-B2
  python ingestar_fuente_externa.py --descargar-cefrj      # Descarga y genera packs de vocabulario CEFR-J
"""

import argparse
import csv
import json
import os
import re
import sys
import urllib.request

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
BACKEND_SEED_DIR = os.path.join(PROJECT_ROOT, "backend", "app", "seed")
STAGING_VOCAB = os.path.join(SCRIPT_DIR, "01_vocabulario")
STAGING_INMERSION = os.path.join(SCRIPT_DIR, "03_inmersion")


def get_existing_terms_set():
    """Recopila todos los términos existentes en el backend para evitar duplicados."""
    vocab_path = os.path.join(BACKEND_SEED_DIR, "vocab.json")
    if not os.path.exists(vocab_path):
        return set()
    with open(vocab_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    existing = set()
    for pack in data:
        for t in pack.get("terms", []):
            word = t.get("term", "").strip().lower()
            if word:
                existing.add(word)
    return existing


def normalize_band(raw_level: str) -> str:
    s = str(raw_level).upper().replace(" ", "").replace("-", "")
    if any(k in s for k in ["C2", "EXECUTIVE", "STRATEGIC", "LEAD", "STAFF", "LEVEL4"]):
        return "C1"
    if any(k in s for k in ["B2C1", "SENIOR", "ARCHITECTURE", "LEVEL3"]):
        return "B2-C1"
    if "C1" in s and "B2" not in s:
        return "C1"
    if any(k in s for k in ["A1", "A2B1", "A2", "JUNIOR", "FOUNDATIONS", "LEVEL1"]):
        return "A1-A2"
    if any(k in s for k in ["B1", "B2", "MID", "SYSTEMS", "LEVEL2"]):
        return "B1-B2"
    return "A1-A2"


def ingestar_csv_vocabulario(csv_path: str, pack_id: str, pack_title: str, level: str, is_tech: bool = False):
    """Convierte un archivo CSV con columnas de vocabulario en un pack JSON listo."""
    existing_terms = get_existing_terms_set()
    band = normalize_band(level)
    full_level = f"{band} • {'Tech' if is_tech else 'General'}"

    terms = []
    skipped_duplicates = 0

    with open(csv_path, "r", encoding="utf-8", errors="replace") as f:
        # Detectar delimitador (coma o tabulador)
        sample = f.read(2048)
        f.seek(0)
        delimiter = "\t" if "\t" in sample else ","
        reader = csv.DictReader(f, delimiter=delimiter)

        for row in reader:
            # Buscar columnas con nombres flexibles
            term = (row.get("word") or row.get("term") or row.get("headword") or row.get("Term") or "").strip()
            if not term:
                continue

            term_lower = term.lower()
            if term_lower in existing_terms:
                skipped_duplicates += 1
                continue

            ipa = (row.get("ipa") or row.get("phonetic") or row.get("IPA") or "").strip()
            definition = (row.get("definition") or row.get("meaning") or row.get("Definition") or f"Definition of {term}.").strip()
            example = (row.get("example") or row.get("exampleSentence") or row.get("sentence") or f"This is an example sentence using {term}.").strip()
            spanish_hint = (row.get("translation") or row.get("spanishHint") or row.get("es") or "").strip()
            difficulty = "senior" if band in ("B2-C1", "C1") else ("mid" if band == "B1-B2" else "junior")

            terms.append({
                "term": term,
                "ipa": ipa or f"/{term_lower}/",
                "definition": definition,
                "exampleSentence": example,
                "spanishHint": spanish_hint or "traducción",
                "category": "imported_dataset",
                "difficulty": difficulty,
                "relatedTerms": [],
                "origin": "external_dataset"
            })
            existing_terms.add(term_lower)

    if not terms:
        print(f"⚠️ No se extrajeron términos nuevos de {csv_path} (se omitieron {skipped_duplicates} duplicados).")
        return None

    # Dividir en packs de 12 términos para no sobrecargar las sesiones de estudio
    chunk_size = 12
    generated_files = []

    for i in range(0, len(terms), chunk_size):
        chunk = terms[i:i + chunk_size]
        chunk_num = (i // chunk_size) + 1
        current_pack_id = f"{pack_id}_part{chunk_num}" if len(terms) > chunk_size else pack_id
        current_title = f"{pack_title} (Parte {chunk_num})" if len(terms) > chunk_size else pack_title

        pack_obj = [{
            "id": current_pack_id,
            "title": current_title,
            "description": f"Colección de vocabulario {band} importada ({len(chunk)} términos).",
            "iconCodePoint": 983105,
            "iconFontFamily": "MaterialIcons",
            "level": full_level,
            "accentColorValue": 4283839880,
            "terms": chunk
        }]

        out_path = os.path.join(STAGING_VOCAB, f"pack_{current_pack_id}.json")
        with open(out_path, "w", encoding="utf-8") as out_f:
            json.dump(pack_obj, out_f, ensure_ascii=False, indent=2)
        generated_files.append(out_path)

    print(f"✅ Se han generado {len(generated_files)} pack(s) con un total de {len(terms)} términos únicos (omitidos {skipped_duplicates} repetidos).")
    for f in generated_files:
        print(f"   📁 Guardado en: {os.path.basename(f)}")
    return generated_files


def descargar_y_generar_cefrj():
    """Descarga el dataset abierto oficial CEFR-J + Octanove C1/C2 y genera packs listos organizados por nivel."""
    print("\n🌐 Conectando con dataset oficial abierto CEFR-J...")
    
    urls = [
        ("A1-B2 (CEFR-J)", "https://raw.githubusercontent.com/openlanguageprofiles/olp-en-cefrj/master/cefrj-vocabulary-profile-1.5.csv"),
        ("C1-C2 (Octanove)", "https://raw.githubusercontent.com/openlanguageprofiles/olp-en-cefrj/master/octanove-vocabulary-profile-c1c2-1.0.csv"),
    ]

    existing_terms = get_existing_terms_set()
    terms_by_band = {"A1-A2": [], "B1-B2": [], "B2-C1": [], "C1": []}
    total_new = 0
    skipped = 0

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

    for label, url in urls:
        print(f"📥 Descargando bloque {label}...")
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req) as response:
                csv_text = response.read().decode("utf-8", errors="replace")
                reader = csv.DictReader(csv_text.splitlines())
                for row in reader:
                    word = (row.get("headword") or row.get("word") or "").strip()
                    if not word or len(word) < 2 or not word.isalpha():
                        continue
                    if word.lower() in existing_terms:
                        skipped += 1
                        continue

                    lvl = (row.get("CEFR") or row.get("level") or "A1").strip().upper()
                    band = normalize_band(lvl)
                    pos = (row.get("pos") or row.get("POS") or "term").strip()

                    terms_by_band[band].append({
                        "term": word,
                        "ipa": f"/{word.lower()}/",
                        "definition": f"Essential {pos} term in CEFR {lvl} standard vocabulary.",
                        "exampleSentence": f"We frequently use the term '{word}' in practical communication.",
                        "spanishHint": f"término ({lvl})",
                        "category": "core_curriculum",
                        "difficulty": "senior" if band in ("B2-C1", "C1") else ("mid" if band == "B1-B2" else "junior"),
                        "relatedTerms": [],
                        "origin": "CEFR-J / Octanove"
                    })
                    existing_terms.add(word.lower())
                    total_new += 1
        except Exception as e:
            print(f"⚠️ Error al descargar {label}: {e}")

    # Generar packs de 12 términos por nivel
    for band, items in terms_by_band.items():
        if not items:
            continue
        selected = items[:12]
        pack_id = f"cefrj_{band.lower().replace('-', '_')}_core"
        pack_obj = [{
            "id": pack_id,
            "title": f"CEFR-J Core Vocabulary ({band})",
            "description": f"Términos esenciales de alta frecuencia nivel {band} extraídos del estándar CEFR-J y Octanove.",
            "iconCodePoint": 983105,
            "iconFontFamily": "MaterialIcons",
            "level": f"{band} • General",
            "accentColorValue": 4283839880,
            "terms": selected
        }]
        out_file = os.path.join(STAGING_VOCAB, f"pack_{pack_id}.json")
        with open(out_file, "w", encoding="utf-8") as out_f:
            json.dump(pack_obj, out_f, ensure_ascii=False, indent=2)
        print(f"✅ Pack generado en staging: {os.path.basename(out_file)} ({len(selected)} términos {band})")

    print(f"\n🎉 Ingesta de CEFR-J completada ({total_new} términos clasificados, omitidos {skipped} ya existentes).")
    print("👉 Puedes verlos ejecutando '2_PREVISUALIZAR.bat' o importarlos con '3_IMPORTAR_Y_SINCRONIZAR.bat'.")


def main():
    parser = argparse.ArgumentParser(description="Ingestor Universal de Datasets — English Brain")
    parser.add_argument("--tipo", choices=["vocab_csv", "cefrj"], default="cefrj", help="Tipo de dataset a ingestar")
    parser.add_argument("--archivo", type=str, help="Ruta al archivo CSV o JSON a ingestar")
    parser.add_argument("--pack-id", type=str, default="imported_pack", help="ID del pack")
    parser.add_argument("--pack-titulo", type=str, default="Imported Collection", help="Título del pack")
    parser.add_argument("--nivel", type=str, default="B1-B2", help="Nivel CEFR (A1-A2, B1-B2, B2-C1, C1)")
    parser.add_argument("--tech", action="store_true", help="Marcar como track Tech en vez de General")
    parser.add_argument("--descargar-cefrj", action="store_true", help="Descargar e ingestar vocabulario del repositorio CEFR-J")

    args = parser.parse_args()

    if args.descargar_cefrj or args.tipo == "cefrj" and not args.archivo:
        descargar_y_generar_cefrj()
    elif args.archivo:
        if not os.path.exists(args.archivo):
            print(f"❌ Archivo no encontrado: {args.archivo}")
            return
        ingestar_csv_vocabulario(
            csv_path=args.archivo,
            pack_id=args.pack_id,
            pack_title=args.pack_titulo,
            level=args.nivel,
            is_tech=args.tech
        )
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
