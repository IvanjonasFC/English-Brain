#!/usr/bin/env bash
# Avisa al NAS de que este worker GPU está disponible (Linux).
NAS="http://192.168.1.50:8000"   # <-- IP del NAS
WORKER="http://192.168.1.60"     # <-- IP de este portátil
curl -s -X POST "$NAS/api/worker/register" \
  -H "Content-Type: application/json" \
  -d "{\"url\":\"$WORKER\",\"models\":[\"phi4-mini\",\"qwen3:4b\"]}" \
  && echo "Worker registrado en el NAS." || echo "No se pudo registrar (NAS apagado?)."
