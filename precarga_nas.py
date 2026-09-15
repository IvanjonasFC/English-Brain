# -*- coding: utf-8 -*-
"""
Precarga DEFINITIVA en el NAS: AUDIO (voz am_michael) + ENTONACION.

Que hace, de forma robusta:
  1) Recorre TODO el contenido de la app:
       - ficheros .dart  (phrasal verbs, verbos irregulares, conectores, etc.)
       - ficheros JSON de assets/seed (vocabulario, gramatica, comprension...)
     y extrae SOLO el texto en ingles que la app llega a reproducir en voz
     (term, exampleSentence, audioText, body, modelAnswer, fullPhrase, v1/v2/v3,
      wordA/wordB, phrase, connectedSpeechChunk). Ignora campos en espanol
     (spanishHint, spanishExplanation, tip, *Es, definition, prompt con huecos...).
  2) Pre-genera el AUDIO en la cache del NAS con la MEJOR voz (am_michael),
     en velocidad normal y lenta (los dos rates que usa la app).
  3) Precalcula la CURVA DE ENTONACION nativa de cada frase, para que al
     practicar la app solo tenga que analizar TU grabacion (rapido y consistente).

Es idempotente: lo ya cacheado se salta, asi que puedes relanzarlo sin miedo.
Cada lote reintenta 1 vez ante un fallo de red puntual y, pase lo que pase,
continua con el resto (un lote roto nunca aborta la precarga).

Requisitos: Python 3 (solo stdlib). Ejecutar desde el PC que alcanza el NAS
por LAN, con el portatil .65 encendido (workers de voz).
"""
import os, re, json, sys, time, urllib.request, urllib.error

# --- Configuracion ---
NAS   = "http://192.168.0.200:8092"             # backend del NAS
LIB   = r"C:\Users\IvN\Desktop\Ingles\app\lib"  # codigo de la app (contenido .dart)
# assets/seed vive al lado de lib/ (…\app\assets\seed). Se deduce solo:
SEED  = os.path.join(os.path.dirname(LIB), "assets", "seed")
VOICE = "am_michael"                            # voz unica de la app (la mejor)
RATES = ["+0%", "-20%"]                          # normal y lenta (boton slow)
# Kokoro va por CPU en el portatil: la sintesis en PARALELO lo tumba. Por eso
# la precarga va SUAVE -> 1 sintesis a la vez y lotes pequenos. Mas lento pero
# no revienta el servidor nativo del .65. (Sube CONCURRENCY solo si compruebas
# que el portatil aguanta.)
CONCURRENCY = 1                                  # sintesis simultaneas en el backend
BATCH  = 8                                       # frases por peticion de audio
PBATCH = 8                                       # frases por peticion de entonacion
RETRIES = 1                                      # reintentos por lote ante fallo de red

# Campos que la app REPRODUCE en voz (ingles). Se usan tanto para el regex de
# los .dart como para el recorrido de los JSON. NO se incluye definition,
# prompt, correctAnswer, wrong/right ni nada en espanol: la app no los habla.
SPEAK_FIELDS = [
    "term", "exampleSentence", "audioText", "body", "modelAnswer",
    "fullPhrase", "phrase", "v1", "v2", "v3", "wordA", "wordB",
    "connectedSpeechChunk",
]
SPEAK_SET = set(SPEAK_FIELDS)

# Filtro anti-espanol (por si un campo permitido trae texto en espanol): las
# frases inglesas de la app no llevan estos caracteres.
_ES_CHARS = set("¿¡ñÑáéíóúÁÉÍÓÚüÜ")

_dart_pat = re.compile(
    r'\b(?:' + '|'.join(SPEAK_FIELDS) + r')\s*:\s*'
    r'(?:"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\')'
)


def _ok_text(v: str) -> bool:
    """Ingles plausible: longitud razonable, tiene letras latinas y sin
    caracteres propios del espanol."""
    if not (2 <= len(v) <= 2000):
        return False
    if not re.search(r"[A-Za-z]", v):
        return False
    if any(c in _ES_CHARS for c in v):
        return False
    return True


def _clean(v: str) -> str:
    return v.replace("\\n", " ").replace("\\t", " ").replace("\n", " ").strip()


def collect_dart():
    texts = set()
    if not os.path.isdir(LIB):
        return texts
    for root, _dirs, files in os.walk(LIB):
        for fn in files:
            if not fn.endswith(".dart"):
                continue
            try:
                s = open(os.path.join(root, fn), encoding="utf-8", errors="ignore").read()
            except Exception:
                continue
            for m in _dart_pat.finditer(s):
                v = _clean(m.group(1) or m.group(2) or "")
                if _ok_text(v):
                    texts.add(v)
    return texts


def _walk_json(o, out):
    if isinstance(o, dict):
        for k, v in o.items():
            if isinstance(v, str) and k in SPEAK_SET:
                vv = _clean(v)
                if _ok_text(vv):
                    out.add(vv)
            else:
                _walk_json(v, out)
    elif isinstance(o, list):
        for x in o:
            _walk_json(x, out)


def collect_json():
    texts = set()
    if not os.path.isdir(SEED):
        print("  (aviso) no encuentro assets/seed en:", SEED)
        print("          se precargara solo el contenido de los .dart")
        return texts
    for fn in os.listdir(SEED):
        if not fn.endswith(".json"):
            continue
        try:
            data = json.load(open(os.path.join(SEED, fn), encoding="utf-8"))
        except Exception as e:
            print("  (aviso) no pude leer %s: %s" % (fn, e))
            continue
        before = len(texts)
        _walk_json(data, texts)
        print("    %-26s -> %d frases" % (fn, len(texts) - before))
    return texts


def _post(path, obj, timeout=600):
    data = json.dumps(obj).encode("utf-8")
    last = None
    for attempt in range(RETRIES + 1):
        try:
            req = urllib.request.Request(
                NAS + path, data=data,
                headers={"Content-Type": "application/json"},
            )
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception as e:
            last = e
            if attempt < RETRIES:
                time.sleep(2)
    raise last


def main():
    print("Extrayendo contenido de la app...")
    print("  .dart :", LIB)
    dart = collect_dart()
    print("  .dart -> %d frases" % len(dart))
    print("  json  :", SEED)
    js = collect_json()
    texts = sorted(dart | js)
    print("-" * 60)
    print("Frases/palabras unicas en ingles (dart + json):", len(texts))
    if not texts:
        print("No se extrajo contenido. Revisa la ruta LIB al principio del script.")
        sys.exit(1)
    print("Voz unica:", VOICE, "| NAS:", NAS)

    # ---- 1) AUDIO (normal + lento) ----
    items = [{"text": t, "voice": VOICE, "rate": r} for t in texts for r in RATES]
    total = len(items)
    print("-" * 60)
    print("[1/2] AUDIO -> %d clips (%d frases x %d velocidades)" % (total, len(texts), len(RATES)))
    syn = cached = err = 0
    nb = (total + BATCH - 1) // BATCH
    for i in range(0, total, BATCH):
        n = i // BATCH + 1
        try:
            res = _post("/api/tts/prefetch", {"items": items[i:i + BATCH], "max_concurrency": CONCURRENCY})
            syn    += res.get("synthesized_now", 0)
            cached += res.get("already_cached", 0)
            err    += res.get("errors", 0)
            print("  audio %d/%d -> +%d nuevos | %d cache | %d err"
                  % (n, nb, res.get("synthesized_now", 0),
                     res.get("already_cached", 0), res.get("errors", 0)))
        except Exception as e:
            print("  audio %d/%d FALLO: %s" % (n, nb, e))
    print("  AUDIO total -> nuevos: %d | cache: %d | err: %d" % (syn, cached, err))

    # ---- 2) ENTONACION (curva nativa por frase, comun a todos los usuarios) ----
    print("-" * 60)
    print("[2/2] ENTONACION -> curva nativa de %d frases" % len(texts))
    pc = pcached = perr = 0
    pnb = (len(texts) + PBATCH - 1) // PBATCH
    for i in range(0, len(texts), PBATCH):
        n = i // PBATCH + 1
        try:
            res = _post("/api/pitch/prefetch", {"items": texts[i:i + PBATCH], "voice": VOICE})
            pc      += res.get("computed_now", 0)
            pcached += res.get("already_cached", 0)
            perr    += res.get("errors", 0)
            print("  entonacion %d/%d -> +%d nuevas | %d cache | %d err"
                  % (n, pnb, res.get("computed_now", 0),
                     res.get("already_cached", 0), res.get("errors", 0)))
        except Exception as e:
            print("  entonacion %d/%d FALLO: %s" % (n, pnb, e))
    print("  ENTONACION total -> nuevas: %d | cache: %d | err: %d" % (pc, pcached, perr))

    print("-" * 60)
    if err or perr:
        print("Nota: si hay errores, revisa que el Speaches del .65 este arriba (chequeo_65.bat)")
        print("      y NO relances mientras siga caido (solo llenaria de fallos).")
    print("Listo. La app sonara instantanea, con la misma voz, y la entonacion")
    print("solo tendra que analizar tu grabacion. Precargado para todos los usuarios.")


if __name__ == "__main__":
    main()
