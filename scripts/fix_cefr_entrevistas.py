# -*- coding: utf-8 -*-
"""
Arregla el CEFR de las preguntas de Entrevista.

Problema: las 215 preguntas tenian el campo `cefr` casi todo en "B1"/"B2", asi
que las pildoras de nivel (A1-A2 / B1-B2 / B2-C1 / C1) de la ventana Entrevistas
no repartian nada. Cada pregunta SI tiene un `difficulty` correcto
(junior/mid/senior), asi que derivamos el `cefr` de ahi:

    junior -> "A2"      (banda A1-A2)
    mid    -> "B1"      (banda B1-B2)
    senior -> "B2-C1"   (banda B2-C1)
    senior en categorias avanzadas -> "C1"  (para poblar la pildora C1)
    strategic/staff/lead/principal -> "C1"

Idempotente: puedes relanzarlo. Actualiza el seed del backend y el de deploy-nas
y luego sincroniza los assets offline de la app (tools/sync_offline_seeds.py).

Uso:
    python scripts/fix_cefr_entrevistas.py            # aplica y sincroniza
    python scripts/fix_cefr_entrevistas.py --dry-run  # solo muestra el reparto
"""
import json, os, sys, subprocess
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGETS = [
    os.path.join(ROOT, "backend", "app", "seed", "questions.json"),
    os.path.join(ROOT, "deploy-nas", "backend", "app", "seed", "questions.json"),
]
SYNC = os.path.join(ROOT, "tools", "sync_offline_seeds.py")

# Categorias donde una pregunta "senior" ya es de nivel C1 (arquitectura/estrategia).
ADVANCED = {"system_design", "cloud_arch", "ai_ml", "security"}


def cefr_for(item):
    diff = str(item.get("difficulty", "")).lower().strip()
    cat = str(item.get("category", "")).lower().strip()
    if diff in ("strategic", "staff", "lead", "principal", "exec", "executive"):
        return "C1"
    if diff == "senior":
        return "C1" if cat in ADVANCED else "B2-C1"
    if diff == "mid":
        return "B1"
    if diff == "junior":
        return "A2"
    return item.get("cefr") or "B1"  # desconocido: no romper


def load(path):
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    return d


def main():
    dry = "--dry-run" in sys.argv
    # Usar el primer target existente como fuente de verdad.
    src = next((t for t in TARGETS if os.path.exists(t)), None)
    if not src:
        print("No encuentro questions.json en:", TARGETS)
        sys.exit(1)
    data = load(src)
    items = data.get("items", data) if isinstance(data, dict) else data

    before = Counter(q.get("cefr") for q in items)
    changed = 0
    for q in items:
        new = cefr_for(q)
        if q.get("cefr") != new:
            changed += 1
        q["cefr"] = new
    after = Counter(q.get("cefr") for q in items)

    print("CEFR antes:", dict(before))
    print("CEFR ahora:", dict(after))
    print("Preguntas modificadas:", changed, "de", len(items))

    if dry:
        print("(dry-run) No se ha escrito nada.")
        return

    for t in TARGETS:
        if not os.path.exists(os.path.dirname(t)):
            print("  (aviso) no existe carpeta destino, salto:", t)
            continue
        out = data if isinstance(data, dict) else items
        with open(t, "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
        print("  escrito:", t)

    if os.path.exists(SYNC):
        print("Sincronizando assets offline de la app...")
        r = subprocess.run([sys.executable, SYNC], cwd=ROOT)
        print("  sync OK" if r.returncode == 0 else "  sync FALLO (revisa tools/sync_offline_seeds.py)")
    else:
        print("  (aviso) no encuentro tools/sync_offline_seeds.py; ejecuta el sync a mano.")

    print("Listo. Ahora rebuild del backend en el NAS (docker) y, si quieres offline, shorebird patch.")


if __name__ == "__main__":
    main()
