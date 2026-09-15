# -*- coding: utf-8 -*-
r"""
Precarga TTS "blindada frente a la app".

Genera los mp3 EN ESTE PC (.21, con edge-tts + internet) y los deja directamente
en la carpeta bind-mounted del NAS (W:\App Ingles\audio_cache) con el NOMBRE-HASH
EXACTO que calcula el backend. El contenedor los sirve tal cual (FileResponse) sin
sintetizar nada -> no depende del TLS saliente del NAS (roto) ni del portátil .65.

Reutilizable: al añadir contenido a los seeds (o pares mínimos al Dart), re-ejecuta.
Idempotente: salta lo que ya existe (>100 bytes).

Mapa app -> texto (rastreado sept-2026), IDÉNTICO a lo que manda playTts():
  Vocabulario  : term (+0% y -20%), exampleSentence (+0%)
  Comprensión  : body (+0% y -20%)
  Gramática    : _phrasesForGrammar(q) x4 (+0% y -20%)  [audioText + correctAnswer]
  Fonética HVPT: MinimalPairItem.wordA / .wordB (+0%)

Requisitos en este PC:  pip install edge-tts   (ya presente: 7.2.8)
Uso:                     python tools\prefetch_tts.py
"""
import asyncio, hashlib, io, json, os, re, sys
import edge_tts

SEED_DIR  = r"W:\App Ingles\backend\app\seed"
DART_PHON = r"C:\Users\IvN\Desktop\Ingles\app\lib\features\phonetics\models\phonetic_models.dart"
CACHE_DIR = r"W:\App Ingles\audio_cache"
VOICE     = "en-US-GuyNeural"          # default de la app
ENGINE_TAG = "edge_neural_v1"          # el contenedor tiene edge-tts -> este tag
CONCURRENCY = 8

# ── Réplica EXACTA del hashing del backend (services/tts.py) ──
def backend_filename(text, rate):
    cleaned = (text or "").strip()
    rate_str = str(rate).strip().replace("%25", "%")
    if not rate_str.endswith("%"):
        rate_str = rate_str + "%"
    if not (rate_str.startswith("+") or rate_str.startswith("-")):
        rate_str = "+" + rate_str
    h = hashlib.sha256(("%s_%s_%s_%s" % (cleaned, VOICE, rate_str, ENGINE_TAG)).encode("utf-8")).hexdigest()[:18]
    return "tts_%s.mp3" % h, cleaned, rate_str

# ── Recolectar (texto, rate) EXACTOS de la app ──
items, seen = [], set()
def add(text, rate):
    if not (text or "").strip():
        return
    fn, cleaned, rate_str = backend_filename(text, rate)
    if fn in seen:
        return
    seen.add(fn)
    items.append((fn, cleaned, rate_str))

def load(name):
    return json.load(io.open(os.path.join(SEED_DIR, name), encoding="utf-8"))

try:
    for pack in load("vocab.json"):
        for t in pack.get("terms", []):
            w = t.get("term", "")
            add(w, "+0%"); add(w, "-20%")
            add(t.get("exampleSentence", ""), "+0%")
except Exception as e:
    print("VOCAB ERROR", e)

try:
    comp = load("comprehension_seed.json")
    for it in (comp.get("items", []) if isinstance(comp, dict) else comp):
        add(it.get("body", ""), "+0%"); add(it.get("body", ""), "-20%")
except Exception as e:
    print("COMP ERROR", e)

def phrases_for_grammar(audio_text, correct_answer):
    base = (audio_text or "").strip(); ans = (correct_answer or "").strip()
    nq = base.replace('"', '')
    return [base,
            'In the incident report, I wrote: "%s"' % nq,
            'Could you give an example using %s in a STAR answer?' % ans,
            'During the post-mortem, the team agreed: "%s"' % nq]
try:
    gr = load("grammar.json")
    units = gr if isinstance(gr, list) else gr.get("units", gr.get("items", []))
    for u in units:
        for q in u.get("questions", []):
            for ph in phrases_for_grammar(q.get("audioText", ""), q.get("correctAnswer", "")):
                add(ph, "+0%"); add(ph, "-20%")
except Exception as e:
    print("GRAMMAR ERROR", e)

try:
    dart = io.open(DART_PHON, encoding="utf-8").read()
    for w in re.findall(r"wordA:\s*'([^']*)'", dart) + re.findall(r"wordB:\s*'([^']*)'", dart):
        add(w, "+0%")
except Exception as e:
    print("PHONETICS ERROR", e)

os.makedirs(CACHE_DIR, exist_ok=True)
todo = [(fn, txt, rs) for (fn, txt, rs) in items
        if not (os.path.exists(os.path.join(CACHE_DIR, fn)) and os.path.getsize(os.path.join(CACHE_DIR, fn)) > 100)]
print("TOTAL=%d  YA_CACHEADOS=%d  A_GENERAR=%d" % (len(items), len(items) - len(todo), len(todo)))
sys.stdout.flush()

done = {"ok": 0, "err": 0}
async def gen_one(sem, fn, text, rate_str):
    async with sem:
        path = os.path.join(CACHE_DIR, fn)
        try:
            c = edge_tts.Communicate(text, VOICE, rate=rate_str)
            await c.save(path)
            if os.path.exists(path) and os.path.getsize(path) > 100:
                done["ok"] += 1
            else:
                done["err"] += 1
                if os.path.exists(path):
                    os.remove(path)
        except Exception as e:
            done["err"] += 1
            try:
                if os.path.exists(path):
                    os.remove(path)
            except Exception:
                pass
        n = done["ok"] + done["err"]
        if n % 50 == 0:
            print("  ...%d/%d (ok=%d err=%d)" % (n, len(todo), done["ok"], done["err"])); sys.stdout.flush()

async def main():
    sem = asyncio.Semaphore(CONCURRENCY)
    await asyncio.gather(*[gen_one(sem, fn, txt, rs) for (fn, txt, rs) in todo])

if todo:
    asyncio.run(main())
print("DONE generados=%d errores=%d  (total_en_cache~%d)" % (
    done["ok"], done["err"], len(items) - len(todo) + done["ok"]))
