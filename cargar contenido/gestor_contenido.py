#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gestor de Contenido y Pipeline de Ingesta — English Brain

Permite auditar el contenido activo en el backend/NAS, previsualizar borradores
en las carpetas de staging y fusionar/sincronizar nuevo contenido de forma 100% segura.

Uso:
  python gestor_contenido.py --status            # Ver inventario actual y borradores
  python gestor_contenido.py --preview           # Validar y previsualizar lo que se va a cargar
  python gestor_contenido.py --import            # Importar borradores a backend y deploy-nas
  python gestor_contenido.py --sync              # Sincronizar assets offline de la app
  python gestor_contenido.py --all               # Importar + Sincronizar en un solo paso
"""

import argparse
import glob
import json
import os
import shutil
import subprocess
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
BACKEND_SEED_DIR = os.path.join(PROJECT_ROOT, "backend", "app", "seed")
NAS_SEED_DIR = os.path.join(PROJECT_ROOT, "deploy-nas", "backend", "app", "seed")
SYNC_TOOL = os.path.join(PROJECT_ROOT, "tools", "sync_offline_seeds.py")

STAGING_DIRS = {
    "vocabulario": os.path.join(SCRIPT_DIR, "01_vocabulario"),
    "gramatica": os.path.join(SCRIPT_DIR, "02_gramatica"),
    "inmersion": os.path.join(SCRIPT_DIR, "03_inmersion"),
    "entrevistas": os.path.join(SCRIPT_DIR, "04_entrevistas"),
}

CANONICAL_BANDS = ["A1-A2", "B1-B2", "B2-C1", "C1"]


def normalize_band(raw_level: str) -> str:
    if not raw_level:
        return "A1-A2"
    s = str(raw_level).upper()
    if "•" in s:
        s = s.split("•")[0]
    s = s.replace(" ", "").replace("-", "")
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


def load_json(file_path: str):
    if not os.path.exists(file_path):
        return []
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if isinstance(data, dict):
        return data.get("items", [])
    return data if isinstance(data, list) else []


def save_json(file_path: str, data):
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def get_current_inventory():
    vocab_packs = load_json(os.path.join(BACKEND_SEED_DIR, "vocab.json"))
    grammar_units = load_json(os.path.join(BACKEND_SEED_DIR, "grammar.json"))
    comprehension_stories = load_json(os.path.join(BACKEND_SEED_DIR, "comprehension_seed.json"))
    interview_questions = load_json(os.path.join(BACKEND_SEED_DIR, "questions.json"))

    return {
        "vocab": vocab_packs,
        "grammar": grammar_units,
        "comprehension": comprehension_stories,
        "interview": interview_questions,
    }


def print_status():
    inv = get_current_inventory()
    print("\n" + "═" * 78)
    print(" 📊 INVENTARIO ACTUAL DE CONTENIDO — ENGLISH BRAIN (BACKEND & NAS)")
    print("═" * 78)

    # Resumen por ventana
    print(f"{'Ventana':<24} | {'Total Items':<12} | {'A1 - A2':<10} | {'B1 - B2':<10} | {'B2 - C1':<10} | {'C1 Exec':<10}")
    print("─" * 78)

    sections = [
        ("Vocabulario (Packs)", inv["vocab"], lambda x: normalize_band(x.get("level", ""))),
        ("Gramática (Unidades)", inv["grammar"], lambda x: normalize_band(x.get("tag", ""))),
        ("Inmersión (Historias)", inv["comprehension"], lambda x: normalize_band(x.get("band", ""))),
        ("Entrevista (Preguntas)", inv["interview"], lambda x: normalize_band(x.get("cefr", ""))),
    ]

    for name, items, band_fn in sections:
        counts = {b: 0 for b in CANONICAL_BANDS}
        for it in items:
            b = band_fn(it)
            if b in counts:
                counts[b] += 1
            else:
                counts["A1-A2"] += 1
        print(f"{name:<24} | {len(items):<12} | {counts['A1-A2']:<10} | {counts['B1-B2']:<10} | {counts['B2-C1']:<10} | {counts['C1']:<10}")

    print("─" * 78)

    # Borradores en staging
    print("\n 📥 BORRADORES PENDIENTES EN CARPETAS DE CARGA:")
    found_drafts = False
    for section_name, path in STAGING_DIRS.items():
        files = glob.glob(os.path.join(path, "*.json"))
        # Excluir plantillas y ejemplos
        files = [
            f
            for f in files
            if not os.path.basename(f).startswith("plantilla_")
            and not os.path.basename(f).startswith("EJEMPLO_")
        ]
        if files:
            found_drafts = True
            print(f"  • {section_name.upper()}: {len(files)} archivo(s) listo(s)")
            for f in files:
                print(f"    - {os.path.basename(f)}")
        else:
            print(f"  • {section_name.upper()}: (Sin borradores nuevos)")

    if not found_drafts:
        print("\n 💡 Para añadir contenido, copia un archivo de ejemplo, renómbralo (ej. 'mi_pack.json')")
        print("    y edita su contenido. Luego ejecuta la opción 2 (Previsualizar) o 3 (Importar).")
    print("═" * 78 + "\n")


def collect_drafts():
    drafts = {"vocab": [], "grammar": [], "comprehension": [], "interview": []}

    mapping = {
        "vocabulario": "vocab",
        "gramatica": "grammar",
        "inmersion": "comprehension",
        "entrevistas": "interview",
    }

    for folder_key, draft_key in mapping.items():
        folder_path = STAGING_DIRS[folder_key]
        for file_path in glob.glob(os.path.join(folder_path, "*.json")):
            basename = os.path.basename(file_path)
            if basename.startswith("plantilla_") or basename.startswith("EJEMPLO_"):
                continue
            try:
                content = load_json(file_path)
                items = content if isinstance(content, list) else [content]
                for item in items:
                    if isinstance(item, dict):
                        item["_source_file"] = file_path
                        drafts[draft_key].append(item)
            except Exception as e:
                print(f"❌ Error leyendo {file_path}: {e}")

    return drafts


def validate_drafts(drafts):
    errors = []
    warnings = []
    inv = get_current_inventory()

    # 1. Chequeo de IDs duplicados
    for key, current_items in inv.items():
        existing_ids = {str(it.get("id")) for it in current_items if it.get("id") is not None}
        for d in drafts[key]:
            d_id = str(d.get("id"))
            if not d.get("id"):
                errors.append(f"[{key}] Ítem sin ID en {d.get('_source_file')}")
            elif d_id in existing_ids:
                errors.append(f"[{key}] ID duplicado '{d_id}' ya existe en el backend.")
            else:
                existing_ids.add(d_id)

    # 2. Chequeo de palabras duplicadas en Vocabulario (evitar términos repetidos)
    existing_terms = {}
    for pack in inv["vocab"]:
        p_id = pack.get("id", "pack")
        for t in pack.get("terms", []):
            word = t.get("term", "").strip().lower()
            if word:
                existing_terms[word] = p_id

    for d in drafts["vocab"]:
        p_id = d.get("id", "draft_pack")
        for t in d.get("terms", []):
            word = t.get("term", "").strip().lower()
            if not word:
                errors.append(f"[vocab] Término vacío en pack '{p_id}'")
            elif word in existing_terms:
                warnings.append(f"[vocab] Término repetido '{word}' (ya existe en pack '{existing_terms[word]}').")
            else:
                existing_terms[word] = p_id

    # 3. Chequeo de preguntas o enunciados repetidos en Entrevistas
    existing_questions = {q.get("text", "").strip().lower() for q in inv["interview"] if q.get("text")}
    for q in drafts["interview"]:
        txt = q.get("text", "").strip().lower()
        if txt and txt in existing_questions:
            warnings.append(f"[interview] Pregunta ya existente: '{q.get('title') or txt[:40]}...'")
        elif txt:
            existing_questions.add(txt)

    return errors, warnings


def preview_drafts():
    drafts = collect_drafts()
    total_drafts = sum(len(v) for v in drafts.values())

    print("\n" + "═" * 78)
    print(" 🔍 PREVISUALIZACIÓN DETALLADA Y CONTROL DE CALIDAD DE CONTENIDO")
    print("═" * 78)

    if total_drafts == 0:
        print(" (No se encontraron archivos nuevos en las carpetas de staging).")
        print(" Coloca archivos .json (sin el prefijo 'plantilla_' ni 'EJEMPLO_') para importarlos.")
        print("═" * 78 + "\n")
        return

    errors, warnings = validate_drafts(drafts)

    if warnings:
        print(" ⚠️ ADVERTENCIAS (Términos o preguntas repetidas detectadas):")
        for w in warnings:
            print(f"   • {w}")
        print()

    if errors:
        print(" ❌ SE ENCONTRARON ERRORES BLOQUEANTES:")
        for err in errors:
            print(f"   • {err}")
        print("\n Corrige estos errores antes de ejecutar --import.")
        print("═" * 78 + "\n")
        return

    print(" ✅ BORRADORES VALIDADOS — DESGLOSE EXACTO DE DESTINO Y CONTENIDO:\n")

    section_destinations = {
        "vocab": "📖 VENTANA VOCABULARIO",
        "grammar": "📐 VENTANA GRAMÁTICA",
        "comprehension": "🎧 VENTANA INMERSIÓN / LECTURA",
        "interview": "🎙️ VENTANA ENTREVISTA STAR",
    }

    for key, items in drafts.items():
        if not items:
            continue

        header_title = section_destinations.get(key, key.upper())
        print("┌" + "─" * 76 + "┐")
        print(f"│  {header_title:<72} │")
        print("└" + "─" * 76 + "┘")

        for idx, it in enumerate(items, start=1):
            level_str = it.get("level") or it.get("tag") or it.get("band") or it.get("cefr") or "A1-A2"
            band = normalize_band(level_str)
            is_tech = "Tech" in level_str or it.get("domain") == "tech" or "it" in it.get("id", "").lower()
            track_name = "Tech / IT Executive" if is_tech else "Inglés General"
            title = it.get("title") or it.get("term") or it.get("id")
            pack_id = it.get("id")

            print(f"\n  [{idx}] PACK / UNIDAD: {title}")
            print(f"      • ID:        {pack_id}")
            print(f"      • Destino:   Pestaña {key.capitalize()} -> Segmento '{track_name}' -> Píldora '{band}'")
            print(f"      • Archivo:   {os.path.basename(it.get('_source_file', ''))}")

            # 1. Detalle de Vocabulario
            if key == "vocab" and "terms" in it:
                terms_list = it.get("terms", [])
                print(f"      • Palabras incluidas ({len(terms_list)} términos):")
                for t in terms_list:
                    w = t.get("term", "")
                    ipa = t.get("ipa", "")
                    hint = t.get("spanishHint", "")
                    print(f"        - {w:<20} {ipa:<18} → {hint}")

            # 2. Detalle de Gramática
            elif key == "grammar":
                subtitle = it.get("subtitle", "")
                rule = it.get("ruleSummary", "")
                questions = it.get("questions", [])
                print(f"      • Subtítulo: {subtitle}")
                print(f"      • Regla:     {rule[:80]}...")
                print(f"      • Preguntas: {len(questions)} ejercicios de práctica")

            # 3. Detalle de Inmersión
            elif key == "comprehension":
                body = it.get("body", "")
                body_es = it.get("bodyEs", "")
                questions = it.get("questions", [])
                word_count = len(body.split())
                print(f"      • Longitud:  {word_count} palabras (~{it.get('estMinutes', 4)} min)")
                print(f"      • Inicio EN: \"{body[:90]}...\"")
                print(f"      • Inicio ES: \"{body_es[:90]}...\"")
                print(f"      • Preguntas: {len(questions)} preguntas de comprensión")

            # 4. Detalle de Entrevistas
            elif key == "interview":
                txt = it.get("text", "")
                txt_es = it.get("text_es", "")
                print(f"      • Pregunta EN: \"{txt[:85]}...\"")
                if txt_es:
                    print(f"      • Pregunta ES: \"{txt_es[:85]}...\"")

        print("\n" + "─" * 78)

    print(" 💡 Si todo está a tu gusto, ejecuta '3_IMPORTAR_Y_SINCRONIZAR.bat' para publicarlo.")
    print("═" * 78 + "\n")


def import_drafts():
    drafts = collect_drafts()
    total_drafts = sum(len(v) for v in drafts.values())
    if total_drafts == 0:
        print("⚠️ No hay borradores nuevos para importar.")
        return

    errors, warnings = validate_drafts(drafts)
    if errors:
        print("❌ Importación cancelada. Hay errores de validación:")
        for err in errors:
            print(f"   • {err}")
        return

    if warnings:
        print("⚠️ Advertencias encontradas durante la validación:")
        for w in warnings:
            print(f"   • {w}")

    files_to_update = {
        "vocab": "vocab.json",
        "grammar": "grammar.json",
        "comprehension": "comprehension_seed.json",
        "interview": "questions.json",
    }

    processed_files = set()

    for key, filename in files_to_update.items():
        new_items = drafts[key]
        if not new_items:
            continue

        backend_target = os.path.join(BACKEND_SEED_DIR, filename)
        nas_target = os.path.join(NAS_SEED_DIR, filename)

        current = load_json(backend_target)
        for it in new_items:
            src = it.pop("_source_file", None)
            if src:
                processed_files.add(src)
            current.append(it)

        # Guardar en backend y en deploy-nas
        save_json(backend_target, current)
        save_json(nas_target, current)
        print(f"✅ Añadidos {len(new_items)} ítems a {filename} (backend y deploy-nas).")

    # Mover archivos procesados a carpeta cargados/
    archive_dir = os.path.join(SCRIPT_DIR, "cargados")
    os.makedirs(archive_dir, exist_ok=True)
    for f in processed_files:
        dest = os.path.join(archive_dir, os.path.basename(f))
        shutil.move(f, dest)
        print(f"📦 Archivado borrador procesado: {os.path.basename(f)} -> cargados/")

    print("\n🎉 Importación completada con éxito.")


def run_sync():
    print("\n🔄 Sincronizando con los assets offline de la app...")
    res = subprocess.run([sys.executable, SYNC_TOOL], cwd=PROJECT_ROOT)
    if res.returncode == 0:
        print("✅ Assets offline y seeds sincronizados al 100%.")
    else:
        print("❌ Error en tools/sync_offline_seeds.py")


def main():
    parser = argparse.ArgumentParser(description="Gestor de Contenido y Pipeline de Ingesta — English Brain")
    parser.add_argument("--status", action="store_true", help="Ver inventario actual de contenido y borradores")
    parser.add_argument("--preview", action="store_true", help="Validar y previsualizar contenido en staging")
    parser.add_argument("--import", dest="do_import", action="store_true", help="Importar borradores a los seeds del backend")
    parser.add_argument("--sync", action="store_true", help="Sincronizar assets offline con tools/sync_offline_seeds.py")
    parser.add_argument("--all", action="store_true", help="Previsualizar, importar y sincronizar todo")

    args = parser.parse_args()

    if args.all:
        preview_drafts()
        import_drafts()
        run_sync()
    elif args.do_import:
        import_drafts()
        if args.sync:
            run_sync()
    elif args.sync:
        run_sync()
    elif args.preview:
        preview_drafts()
    else:
        print_status()


if __name__ == "__main__":
    main()
