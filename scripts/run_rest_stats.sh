#!/usr/bin/env bash
set -euo pipefail

DETACH=0
for arg in "$@"; do
  case "$arg" in
    --detach|-d) DETACH=1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="${SCRIPT_DIR}/../rest-version/service-b-rest"
cd "${SERVICE_DIR}"

# Ensure dependencies are present
if [ ! -f go.sum ]; then
  echo "[INFO] go.sum not found. Running 'go mod tidy' to resolve dependencies..."
  go mod tidy
fi

export REST_STATS_PORT="${REST_STATS_PORT:-9002}"
echo "[RUN] REST Stats service launching on :${REST_STATS_PORT} (GET /scores/{userId}?base=10)"
if [ "$DETACH" = "1" ]; then
  nohup go run . >/tmp/rest-stats.log 2>&1 &
  PID=$!
  echo "[DETACHED] PID=$PID logs: tail -f /tmp/rest-stats.log"
  exit 0
else
  exec go run .
fi
