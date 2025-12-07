#!/usr/bin/env bash
set -euo pipefail

# Build and load images directly to Minikube nodes (multi-node compatible)

echo "=================================================="
echo "  Building Docker Images for Minikube Multi-Node"
echo "=================================================="
echo ""

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Build images localmente
echo "🔨 Building images locally..."
echo ""

# Build Service A (Python)
echo "📦 [1/3] Building service-a (Python)..."
pushd "$ROOT_DIR/service-a-python" > /dev/null
docker build -t service-a:local .
popd > /dev/null
echo "✅ service-a built"
echo ""

# Build Service B (Go)
echo "📦 [2/3] Building service-b (Go)..."
pushd "$ROOT_DIR/service-b-go" > /dev/null
docker build -t service-b:local .
popd > /dev/null
echo "✅ service-b built"
echo ""

# Build Gateway (Node.js)
echo "📦 [3/3] Building gateway (Node.js)..."
pushd "$ROOT_DIR/gateway-node" > /dev/null
docker build -t gateway:local .
popd > /dev/null
echo "✅ gateway built"
echo ""

# Carregar imagens nos nós do Minikube
echo "=================================================="
echo "📤 Loading images to Minikube nodes..."
echo "=================================================="
echo ""

# Pegar lista de nós
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

for image in service-a:local service-b:local gateway:local; do
    echo "Loading ${image}..."
    minikube image load ${image}
    echo "✅ ${image} loaded to all nodes"
done

echo ""
echo "=================================================="
echo "✅ All images built and loaded successfully!"
echo "=================================================="
echo ""

# Verificar imagens
echo "Images in Minikube:"
minikube ssh -- docker images | grep -E 'service-a|service-b|gateway' || true
echo ""
