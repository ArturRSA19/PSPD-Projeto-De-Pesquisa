#!/usr/bin/env bash
set -euo pipefail

# Helper script to run the Python gRPC UserService with automatic venv setup.
# Usage:
#   ./service-a-python/run_service_a.sh            # default port 50051
#   USER_PORT=60000 ./service-a-python/run_service_a.sh
#   PYTHON=python3.12 ./service-a-python/run_service_a.sh
#
# Creates .venv on first run, installs requirements, then starts server.

cd "$(dirname "$0")"
PYTHON_BIN=${PYTHON:-python3}
PORT=${USER_PORT:-50051}

if [ ! -d .venv ]; then
  echo "[setup] creating virtualenv (.venv) with $PYTHON_BIN" >&2
  "$PYTHON_BIN" -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

# Minimal install/update (quiet but informative on errors)
if [ -f requirements.txt ]; then
  echo "[deps] installing requirements" >&2
  pip install --upgrade --quiet pip
  pip install --quiet -r requirements.txt
fi

echo "[run] starting UserService on :$PORT" >&2
export USER_PORT="$PORT"
exec python server.py
