#!/bin/bash

# Script para rebuild e redeploy da aplicação com métricas

set -e

echo "=================================================="
echo "  Rebuild e Redeploy com Prometheus Metrics"
echo "=================================================="
echo ""

# Rebuild images
echo "📦 [1/4] Rebuilding images..."
./scripts/build_and_load_images.sh
echo ""

# Apply service changes (add metrics ports)
echo "🔄 [2/4] Updating services..."
kubectl apply -f k8s/service-a-service.yaml
kubectl apply -f k8s/service-b-service.yaml
kubectl apply -f k8s/gateway-service.yaml
echo ""

# Restart deployments to pick up new images
echo "🔄 [3/4] Restarting deployments..."
kubectl rollout restart deployment/gateway -n pspd-lab
kubectl rollout restart deployment/service-a -n pspd-lab
kubectl rollout restart deployment/service-b -n pspd-lab

# Wait for rollout
kubectl rollout status deployment/gateway -n pspd-lab --timeout=120s
kubectl rollout status deployment/service-a -n pspd-lab --timeout=120s
kubectl rollout status deployment/service-b -n pspd-lab --timeout=120s
echo ""

# Apply ServiceMonitors
echo "📊 [4/4] Applying ServiceMonitors..."
kubectl apply -f k8s/servicemonitors.yaml
echo ""

echo "=================================================="
echo "✅ Redeploy concluído!"
echo "=================================================="
echo ""
echo "Verificar pods:"
echo "  kubectl get pods -n pspd-lab"
echo ""
echo "Verificar ServiceMonitors:"
echo "  kubectl get servicemonitors -n pspd-lab"
echo ""
echo "Testar métricas:"
echo "  kubectl port-forward -n pspd-lab svc/gateway 9090:9090"
echo "  curl http://localhost:9090/metrics"
echo ""
