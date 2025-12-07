#!/usr/bin/env bash
set -euo pipefail

# Build and push images to Minikube registry (multi-node compatible)
# O registry está disponível em localhost:52569 (porta do Minikube)

echo "=================================================="
echo "  Building Docker Images for Minikube Multi-Node"
echo "=================================================="
echo ""

# Registry port do Minikube
REGISTRY_PORT=52569
REGISTRY="localhost:${REGISTRY_PORT}"

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

echo "🔨 Building images and pushing to registry ${REGISTRY}..."
echo ""

# Build Service A (Python)
echo "📦 [1/3] Building service-a (Python)..."
pushd "$ROOT_DIR/service-a-python" > /dev/null
docker build -t service-a:local .
docker tag service-a:local ${REGISTRY}/service-a:local
docker push ${REGISTRY}/service-a:local
popd > /dev/null
echo "✅ service-a built and pushed"
echo ""

# Build Service B (Go)
echo "📦 [2/3] Building service-b (Go)..."
pushd "$ROOT_DIR/service-b-go" > /dev/null
docker build -t service-b:local .
docker tag service-b:local ${REGISTRY}/service-b:local
docker push ${REGISTRY}/service-b:local
popd > /dev/null
echo "✅ service-b built and pushed"
echo ""

# Build Gateway (Node.js)
echo "📦 [3/3] Building gateway (Node.js)..."
pushd "$ROOT_DIR/gateway-node" > /dev/null
docker build -t gateway:local .
docker tag gateway:local ${REGISTRY}/gateway:local
docker push ${REGISTRY}/gateway:local
popd > /dev/null
echo "✅ gateway built and pushed"
echo ""

echo "=================================================="
echo "✅ All images built and pushed successfully!"
echo "=================================================="
echo ""
echo "Images in registry:"
echo "  - ${REGISTRY}/service-a:local"
echo "  - ${REGISTRY}/service-b:local"
echo "  - ${REGISTRY}/gateway:local"
echo ""
