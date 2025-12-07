#!/bin/bash

# Cenário 3: HPA Agressivo
# - 1 réplica inicial
# - HPA mais agressivo (CPU 30%, Memory 50%)
# - Escala mais rápido (até 10 réplicas)

set -e

echo "=================================================="
echo "  Cenário 3: HPA Agressivo"
echo "=================================================="
echo ""
echo "Configuração:"
echo "  - Réplicas iniciais: 1"
echo "  - HPA Agressivo:"
echo "    * CPU threshold: 30% (antes 50%)"
echo "    * Memory threshold: 50% (antes 70%)"
echo "    * Max réplicas: 10 (antes 5)"
echo "    * Scale up: 200% ou +4 pods (antes 100% ou +2)"
echo "  - Carga: 10→50→100 usuários graduais"
echo ""
echo "Objetivo: Verificar se autoscaling mais rápido melhora performance"
echo ""

# Resetar para 1 réplica
echo "[1/3] Resetando para 1 réplica..."
kubectl delete hpa --all -n pspd-lab 2>/dev/null || true
kubectl scale deployment gateway service-a service-b -n pspd-lab --replicas=1

# Aplicar HPA agressivo
echo "[2/3] Aplicando HPA agressivo..."
kubectl apply -f k8s/hpa-agressivo.yaml

echo "Aguardando estabilização..."
sleep 10

echo ""
echo "Status inicial:"
kubectl get hpa -n pspd-lab
kubectl get pods -n pspd-lab
echo ""

read -p "Gateway deve estar exposto em localhost:8080. Pressione Enter para continuar..."

echo ""
echo "[3/3] Executando teste de carga..."
BASE_URL=http://localhost:8080 k6 run scripts/load-test.js | tee scripts/results/load-tests/cenario3-hpa-agressivo-$(date +%Y%m%d_%H%M%S).txt

echo ""
echo "=================================================="
echo "✅ Cenário 3 concluído!"
echo "=================================================="
kubectl get hpa -n pspd-lab
kubectl get pods -n pspd-lab

# Restaurar HPA normal
echo ""
read -p "Deseja restaurar HPA normal? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    kubectl apply -f k8s/hpa.yaml
    kubectl scale deployment gateway service-a service-b -n pspd-lab --replicas=1
    echo "HPA normal restaurado"
fi
