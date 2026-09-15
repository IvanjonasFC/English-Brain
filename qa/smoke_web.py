"""
Smoke test web para English Brain (Flutter web) con Playwright.

Abre la app, espera a que Flutter pinte, saca captura y vuelca los errores
de consola / red / excepciones de pagina. Sale con codigo != 0 si hubo errores.

Uso:
    # 1) arranca la app web en una terminal (puerto fijo para no adivinarlo):
    #    cd app; flutter run -d chrome --web-port 8080
    #    (o: flutter build web  y sirvela en :8080)
    #
    # 2) en otra terminal:
    #    python smoke_web.py                      # usa http://localhost:8080
    #    python smoke_web.py http://localhost:5000
    #    python smoke_web.py --headed             # ver el navegador
    #
    # Requiere: pip install playwright  (navegadores ya en cache)
"""

import sys
from datetime import datetime
from pathlib import Path
from playwright.sync_api import sync_playwright

URL = "http://localhost:8080"
WAIT_MS = 6000  # margen para que CanvasKit termine de renderizar

# --- args minimos -----------------------------------------------------------
headed = "--headed" in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith("--")]
if args:
    URL = args[0]

out_dir = Path(__file__).parent / "salidas"
out_dir.mkdir(exist_ok=True)
stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
shot = out_dir / f"smoke-{stamp}.png"

errores = []  # (tipo, texto)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=not headed)
    page = browser.new_page(viewport={"width": 1280, "height": 800})

    # capturar todo lo que huela a fallo
    page.on("console", lambda m: errores.append(("console", m.text))
            if m.type in ("error", "warning") else None)
    page.on("pageerror", lambda e: errores.append(("pageerror", str(e))))
    page.on("requestfailed",
            lambda r: errores.append(("request", f"{r.url} -> {r.failure}")))

    print(f"[smoke] abriendo {URL}")
    try:
        page.goto(URL, wait_until="load", timeout=30000)
    except Exception as e:
        print(f"[smoke] NO carga la pagina: {e}")
        browser.close()
        sys.exit(2)

    # Flutter pinta en <canvas>; esperamos a que exista + un margen
    try:
        page.wait_for_selector("flt-glass-pane, canvas", timeout=15000)
    except Exception:
        errores.append(("flutter", "no aparecio el canvas de Flutter (flt-glass-pane/canvas)"))
    page.wait_for_timeout(WAIT_MS)

    page.screenshot(path=str(shot), full_page=False)
    print(f"[smoke] captura -> {shot}")
    browser.close()

# --- resumen ----------------------------------------------------------------
if errores:
    print(f"\n[smoke] {len(errores)} problema(s):")
    for tipo, txt in errores:
        print(f"  - [{tipo}] {txt}")
    sys.exit(1)

print("\n[smoke] OK: sin errores de consola ni red.")
