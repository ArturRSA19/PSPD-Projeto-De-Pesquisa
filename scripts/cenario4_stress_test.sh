#!/bin/bash

# Cenário 4: Stress Test
# - HPA habilitado (normal ou agressivo)
# - Carga extrema: até 200 usuários concorrentes

set -e

echo "=================================================="
echo "  Cenário 4: Stress Test"
echo "=================================================="
echo ""
echo "Configuração:"
echo "  - Réplicas iniciais: 1"
echo "  - HPA: Normal (você pode trocar para agressivo)"
echo "  - Carga EXTREMA: 50→150→200 usuários"
echo "  - Duração: 9 minutos"
echo ""
echo "Objetivo: Identificar limites da aplicação e cluster"
echo ""

# Escolher tipo de HPA
echo "Qual HPA deseja usar?"
echo "  1) Normal (CPU 50%, Mem 70%, max 5 réplicas)"
echo "  2) Agressivo (CPU 30%, Mem 50%, max 10 réplicas)"
read -p "Escolha (1 ou 2): " hpa_choice

# Resetar
echo ""
echo "[1/3] Resetando configuração..."
kubectl delete hpa --all -n pspd-lab 2>/dev/null || true
kubectl scale deployment gateway service-a service-b -n pspd-lab --replicas=1

# Aplicar HPA escolhido
if [ "$hpa_choice" = "2" ]; then
    echo "[2/3] Aplicando HPA AGRESSIVO..."
    kubectl apply -f k8s/hpa-agressivo.yaml
else
    echo "[2/3] Aplicando HPA NORMAL..."
    kubectl apply -f k8s/hpa.yaml
fi

echo "Aguardando estabilização..."
sleep 10

echo ""
echo "Status inicial:"
kubectl get hpa -n pspd-lab
kubectl get pods -n pspd-lab
echo ""

read -p "Gateway deve estar exposto em localhost:8080. Pressione Enter para continuar..."

echo ""
echo "[3/3] Executando STRESS TEST..."
echo "⚠️  ATENÇÃO: Teste pesado! Monitorar recursos do sistema."
echo ""

BASE_URL=http://localhost:8080 k6 run scripts/load-test-stress.js | tee scripts/results/load-tests/cenario4-stress-test-$(date +%Y%m%d_%H%M%S).txt

echo ""
echo "=================================================="
echo "✅ Cenário 4 concluído!"
echo "=================================================="
kubectl get hpa -n pspd-lab
kubectl get pods -n pspd-lab

echo ""
echo "⚠️  Verificar se houve pods com OOMKilled ou CrashLoopBackOff"
kubectl get pods -n pspd-lab | grep -E "Error|OOMKilled|CrashLoop" || echo "✓ Nenhum pod com erro"
