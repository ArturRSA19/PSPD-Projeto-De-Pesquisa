#!/usr/bin/env bash
set -euo pipefail

# Build images with minikube docker env
echo "Loading minikube docker-env"
eval "$(minikube docker-env)"

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

pushd "$ROOT_DIR/service-a-python"
docker build -t service-a:local .
popd

pushd "$ROOT_DIR/service-b-go"
docker build -t service-b:local .
popd

pushd "$ROOT_DIR/gateway-node"
docker build -t gateway:local .
popd

echo "Images built:"
docker images | grep -E 'service-a|service-b|gateway'
