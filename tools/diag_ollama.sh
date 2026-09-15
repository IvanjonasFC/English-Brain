#!/bin/sh
# ==========================================================================
# Diagnostico English Brain (ejecutar en la NAS):  sh diag_ollama.sh
# Mide: estado de servicios, latencia Ollama (cold/warm), concurrencia 2
# usuarios, telemetria por ventana (SQLite) y errores recientes del log.
# Overrides:  BASE=... OLLAMA=... MODEL=... CONTAINER=... N=... sh diag_ollama.sh
# ==========================================================================
BASE="${BASE:-http://localhost:8092}"
OLLAMA="${OLLAMA:-http://192.168.0.66:11434}"
# Modelo EFECTIVO segun el backend (evita probar un tag que no existe):
MODEL="${MODEL:-$(curl -s "$BASE/api/ai/status" | sed -n 's/.*"model_active":"\([^"]*\)".*/\1/p')}"
MODEL="${MODEL:-qwen2.5:7b-instruct-q4_K_M}"
CONTAINER="${CONTAINER:-english_coach_backend}"
N="${N:-10}"

echo "############ 1. ESTADO DE SERVICIOS ############"
echo "--- /api/ready ---"
curl -s "$BASE/api/ready" | docker exec -i "$CONTAINER" python -c "import sys,json;d=json.load(sys.stdin);s=d['services'];print('overall:',d['status']);print('llm  :',s['llm']['ready'],s['llm']['model'],'| models=',s['llm'].get('available_models'));print('stt  :',s['speaches']['ready'])" 2>/dev/null || echo "  (backend no responde)"
echo "--- /api/worker/status ---"; curl -s "$BASE/api/worker/status"; echo
echo "--- /api/ai/status ---";     curl -s "$BASE/api/ai/status"; echo

echo "############ 2. LATENCIA OLLAMA (cold vs warm = efecto keep_alive) ############"
docker exec -i "$CONTAINER" env OLLAMA="$OLLAMA" MODEL="$MODEL" python - <<'PY'
import os,time,json,urllib.request
U=os.environ["OLLAMA"];M=os.environ["MODEL"]
def call(p):
    body=json.dumps({"model":M,"prompt":p,"stream":False,"think":False,"keep_alive":"30m","options":{"temperature":0.2}}).encode()
    r=urllib.request.Request(U+"/api/generate",body,{"Content-Type":"application/json"})
    t=time.perf_counter()
    try: d=json.load(urllib.request.urlopen(r,timeout=120))
    except Exception as e: print("  ERROR:",e); return
    dt=time.perf_counter()-t; load=d.get("load_duration",0)/1e9
    ev=(d.get("eval_duration",1) or 1)/1e9; ec=d.get("eval_count",0)
    print(f"  total={dt:5.1f}s  load(cold)={load:4.1f}s  gen={ev:4.1f}s  tokens={ec:4d}  tok/s={ec/ev:5.1f}")
print("1a (posible cold start):"); call("Explain the English word scalable")
print("2a (warm, keep_alive)  :"); call("Explain the English word robust")
PY

echo "############ 3. CONCURRENCIA 2 USUARIOS ############"
docker exec -i "$CONTAINER" env OLLAMA="$OLLAMA" MODEL="$MODEL" python - <<'PY'
import os,time,json,urllib.request,threading
U=os.environ["OLLAMA"];M=os.environ["MODEL"];res={}
def call(i):
    body=json.dumps({"model":M,"prompt":f"User {i}: explain the word latency","stream":False,"think":False,"keep_alive":"30m","options":{"temperature":0.2}}).encode()
    r=urllib.request.Request(U+"/api/generate",body,{"Content-Type":"application/json"})
    t=time.perf_counter()
    try: urllib.request.urlopen(r,timeout=120).read(); res[i]=time.perf_counter()-t
    except Exception as e: res[i]=-1; print("  ERROR u%d: %s"%(i,e))
t=time.perf_counter()
ths=[threading.Thread(target=call,args=(i,)) for i in (1,2)]
[x.start() for x in ths]; [x.join() for x in ths]
wall=time.perf_counter()-t
print(f"  usuario1={res.get(1,0):.1f}s  usuario2={res.get(2,0):.1f}s  WALL(2 en paralelo)={wall:.1f}s")
print("  wall ~= u1+u2  -> Ollama SERIALIZA (OLLAMA_NUM_PARALLEL=1, por defecto).")
print("  wall ~= max(u1,u2) -> hay paralelismo real.")
PY

echo "############ 4. TELEMETRIA POR VENTANA (SQLite) ############"
docker exec -i "$CONTAINER" env N="$N" python - <<'PY'
import os,sqlite3
db=os.environ.get("DB_PATH","/data/coach.db");N=int(os.environ["N"])
try: c=sqlite3.connect(db)
except Exception as e: print("  no DB:",e); raise SystemExit
print(f"--- Ultimas {N} evaluaciones LLM (intent | model | engine | latency_ms | tok/s) ---")
for r in c.execute("select detected_intent,model_name,engine_used,latency_ms,tokens_per_second,created_at from llm_interaction_logs order by id desc limit ?",(N,)):
    print("  ",r)
print(f"--- Ultimos {N} intentos PRONUNCIACION (term | score | engine | conf | stage_failed) ---")
for r in c.execute("select term,score,engine_used,confidence,processing_stage_failed,created_at from pronunciation_attempts order by id desc limit ?",(N,)):
    print("  ",r)
print("--- Reparto por engine (fast=GPU vs standard=fallback) en LLM ---")
for r in c.execute("select engine_used,count(*) from llm_interaction_logs group by engine_used"):
    print("  ",r)
PY

echo "############ 5. ERRORES RECIENTES EN LOG ############"
docker exec -i "$CONTAINER" sh -c 'tail -n 300 /data/logs/app.log 2>/dev/null | grep -iE "error|timeout|degrad|unavailable|fallback|no disponible" | tail -n 30 || echo "  (sin app.log o sin errores)"'
echo "############ FIN ############"
