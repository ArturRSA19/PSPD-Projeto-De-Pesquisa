#!/bin/bash

# Cenário 2: Pré-escalado (Sem Autoscaling)
# - 3 réplicas fixas
# - HPA desabilitado
# - Mesma carga do Cenário 1

set -e

echo "=================================================="
echo "  Cenário 2: Pré-escalado (Sem Autoscaling)"
echo "=================================================="
echo ""
echo "Configuração:"
echo "  - Réplicas fixas: 3 de cada serviço"
echo "  - HPA: Desabilitado"
echo "  - Carga: 10→50→100 usuários graduais"
echo ""
echo "Objetivo: Comparar performance com recursos pré-alocados"
echo ""

# Desabilitar HPA
echo "[1/4] Desabilitando HPA..."
kubectl delete hpa --all -n pspd-lab 2>/dev/null || true

# Escalar para 3 réplicas
echo "[2/4] Escalando para 3 réplicas..."
kubectl scale deployment gateway -n pspd-lab --replicas=3
kubectl scale deployment service-a -n pspd-lab --replicas=3
kubectl scale deployment service-b -n pspd-lab --replicas=3

echo "Aguardando pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=gateway -n pspd-lab --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-a -n pspd-lab --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-b -n pspd-lab --timeout=120s

echo ""
echo "[3/4] Status inicial:"
kubectl get pods -n pspd-lab
echo ""

read -p "Gateway deve estar exposto em localhost:8080. Pressione Enter para continuar..."

echo ""
echo "[4/4] Executando teste de carga..."
BASE_URL=http://localhost:8080 k6 run scripts/load-test.js | tee scripts/results/load-tests/cenario2-pre-escalado-$(date +%Y%m%d_%H%M%S).txt

echo ""
echo "=================================================="
echo "✅ Cenário 2 concluído!"
echo "=================================================="
kubectl get pods -n pspd-lab

# Restaurar HPA
echo ""
read -p "Deseja restaurar HPA para próximos testes? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    kubectl apply -f k8s/hpa.yaml
    kubectl scale deployment gateway service-a service-b -n pspd-lab --replicas=1
    echo "HPA restaurado e réplicas resetadas para 1"
fi
