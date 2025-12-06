#!/usr/bin/env bash
set -euo pipefail
DETACH=0
for arg in "$@"; do
  case "$arg" in
    --detach|-d) DETACH=1 ;;
  esac
done
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="${SCRIPT_DIR}/../rest-version/service-a-rest"
cd "$SERVICE_DIR"

export REST_USERS_PORT="${REST_USERS_PORT:-9001}"

if [ ! -d .venv ]; then
  echo "[INFO] Creating virtualenv..."
  python3 -m venv .venv
fi
source .venv/bin/activate
pip install -q -r requirements.txt

CMD="uvicorn main:app --port ${REST_USERS_PORT} --host 0.0.0.0"

echo "[RUN] REST Users service launching on :${REST_USERS_PORT} (GET /users, /users/{id})"
if [ "$DETACH" = "1" ]; then
  nohup $CMD >/tmp/rest-users.log 2>&1 &
  PID=$!
  echo "[DETACHED] PID=$PID logs: tail -f /tmp/rest-users.log"
  exit 0
else
  exec $CMD
fi
