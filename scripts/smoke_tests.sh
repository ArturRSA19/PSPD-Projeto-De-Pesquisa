#!/usr/bin/env bash
set -euo pipefail

# Simple smoke test script for gateway + services.
# Assumes services already running locally (gateway on $GATEWAY, python/grpc service-a, go service-b)

GATEWAY_HOST=${GATEWAY_HOST:-localhost}
GATEWAY_PORT=${GATEWAY_PORT:-8081}
BASE="http://$GATEWAY_HOST:$GATEWAY_PORT"
OUT_DIR=${OUT_DIR:-scripts/results}
mkdir -p "$OUT_DIR"
LOG="$OUT_DIR/smoke_$(date +%Y%m%d_%H%M%S).log"

echo "[SMOKE] Iniciando testes contra $BASE" | tee -a "$LOG"

step() { echo -e "\n== $1 ==" | tee -a "$LOG"; }

curl_j() { url="$1"; step "GET $url"; curl -sf "$url" | tee -a "$LOG"; echo >> "$LOG"; }

step "Health"
curl -sf "$BASE/healthz" | tee -a "$LOG"; echo >> "$LOG"

step "Unary GetUser (id=1)"
curl -sf "$BASE/users/1" | tee -a "$LOG"; echo >> "$LOG"

step "Bulk Create (ids 10,11)"
curl -sf -X POST "$BASE/users/bulk" -H 'Content-Type: application/json' -d '{"users":[{"id":"10","name":"Eva","age":22},{"id":"11","name":"Frank","age":35}]}' | tee -a "$LOG"; echo >> "$LOG"

step "Verify GetUser (id=10)"
curl -sf "$BASE/users/10" | tee -a "$LOG"; echo >> "$LOG"

step "Server streaming aggregated (/users)"
curl -sf "$BASE/users" | tee -a "$LOG"; echo >> "$LOG"

step "Stats GetScore (id=10)"
curl -sf "$BASE/scores/10" | tee -a "$LOG"; echo >> "$LOG"

echo "[SMOKE] Concluído. Log em $LOG" | tee -a "$LOG"

exit 0