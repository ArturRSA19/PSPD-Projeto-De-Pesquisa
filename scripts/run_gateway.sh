#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$ROOT_DIR/gateway-node"
[ -f package.json ] || { echo "package.json não encontrado"; exit 1; }
if [ ! -d node_modules ]; then
  echo "Instalando dependências Node..."
  npm install --no-audit --no-fund
fi
npm start
