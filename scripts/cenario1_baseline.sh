#!/bin/bash

# Cenário 1: Baseline com Autoscaling (JÁ EXECUTADO)
# - 1 réplica inicial
# - HPA habilitado (CPU 50%, Memory 70%)
# - Carga: 10→50→100 usuários

set -e

echo "=================================================="
echo "  Cenário 1: Baseline com Autoscaling"
echo "=================================================="
echo ""
echo "Configuração:"
echo "  - Réplicas iniciais: 1"
echo "  - HPA: Habilitado (CPU 50%, Mem 70%)"
echo "  - Carga: 10→50→100 usuários graduais"
echo ""

# Garantir que está no estado correto
echo "[1/3] Resetando para configuração baseline..."
kubectl scale deployment gateway service-a service-b -n pspd-lab --replicas=1
kubectl apply -f k8s/hpa.yaml

echo "Aguardando estabilização..."
sleep 10

echo ""
echo "[2/3] Status inicial:"
kubectl get hpa -n pspd-lab
kubectl get pods -n pspd-lab
echo ""

read -p "Gateway deve estar exposto em localhost:8080. Pressione Enter para continuar..."

echo ""
echo "[3/3] Executando teste de carga..."
BASE_URL=http://localhost:8080 k6 run scripts/load-test.js | tee scripts/results/load-tests/cenario1-baseline-$(date +%Y%m%d_%H%M%S).txt

echo ""
echo "=================================================="
echo "✅ Cenário 1 concluído!"
echo "=================================================="
kubectl get hpa -n pspd-lab
kubectl get pods -n pspd-lab
