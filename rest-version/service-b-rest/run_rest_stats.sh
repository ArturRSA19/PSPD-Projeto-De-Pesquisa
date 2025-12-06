#!/usr/bin/env bash
set -euo pipefail
# Helper launcher for REST Stats service (Go)
# Features:
#  - Select port via REST_STATS_PORT (default 9002)
#  - Detect if port is in use and show owning process
#  - Optional FORCE=1 to kill the existing process automatically
# Usage:
#   ./rest-version/service-b-rest/run_rest_stats.sh
#   REST_STATS_PORT=9102 ./rest-version/service-b-rest/run_rest_stats.sh
#   FORCE=1 ./rest-version/service-b-rest/run_rest_stats.sh

cd "$(dirname "$0")"
PORT=${REST_STATS_PORT:-9002}
FORCE=${FORCE:-0}

is_in_use() {
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print}'
}

if OUT=$(is_in_use); then
  if [ -n "$OUT" ]; then
    echo "[warn] Porta $PORT está em uso:" >&2
    echo "$OUT" >&2
    if [ "$FORCE" = "1" ]; then
      echo "$OUT" | awk '{print $2}' | sort -u | xargs -r kill || true
      sleep 0.7
      if OUT2=$(is_in_use); then
        if [ -n "$OUT2" ]; then
          echo "[error] Ainda em uso após tentativa de kill. Abortando." >&2
          exit 1
        fi
      fi
      echo "[info] Porta liberada." >&2
    else
      echo "[info] Use FORCE=1 para matar o(s) processo(s) ou escolha outra porta: REST_STATS_PORT=9102" >&2
      exit 2
    fi
  fi
fi

echo "[run] Iniciando REST Stats na porta :$PORT" >&2
exec env REST_STATS_PORT="$PORT" go run .
