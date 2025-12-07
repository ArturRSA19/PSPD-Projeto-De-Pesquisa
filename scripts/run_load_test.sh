#!/bin/bash

# Script para executar testes de carga e monitorar o autoscaling

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

GATEWAY_URL=${GATEWAY_URL:-http://localhost:8080}
RESULTS_DIR="scripts/results/load-tests"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="${RESULTS_DIR}/load-test-${TIMESTAMP}.txt"

mkdir -p "$RESULTS_DIR"

echo "=================================================="
echo "  Teste de Carga com K6 + Monitoramento HPA"
echo "=================================================="
echo ""
echo "Gateway URL: $GATEWAY_URL"
echo "Results: $RESULTS_FILE"
echo ""

# Verificar se o gateway está acessível
echo -e "${YELLOW}[1/4] Verificando conectividade...${NC}"
if ! curl -sf "$GATEWAY_URL/healthz" > /dev/null; then
    echo -e "${RED}❌ Gateway não está acessível em $GATEWAY_URL${NC}"
    echo "Execute: ./scripts/expose_gateway.sh"
    exit 1
fi
echo -e "${GREEN}✓ Gateway acessível${NC}"
echo ""

# Verificar HPA antes do teste
echo -e "${YELLOW}[2/4] Status inicial do HPA:${NC}"
kubectl get hpa -n pspd-lab | tee -a "$RESULTS_FILE"
echo ""

# Iniciar monitoramento em background
echo -e "${YELLOW}[3/4] Iniciando monitoramento do HPA...${NC}"
echo "Monitorando HPA durante o teste (Ctrl+C para parar)" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# Função para monitorar HPA
monitor_hpa() {
    while true; do
        echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$RESULTS_FILE"
        kubectl get hpa -n pspd-lab --no-headers | tee -a "$RESULTS_FILE"
        kubectl get pods -n pspd-lab --no-headers | grep -E 'gateway|service-a|service-b' | tee -a "$RESULTS_FILE"
        echo "" | tee -a "$RESULTS_FILE"
        sleep 10
    done
}

# Iniciar monitoramento em background
monitor_hpa &
MONITOR_PID=$!

# Executar teste de carga
echo -e "${YELLOW}[4/4] Executando teste de carga com K6...${NC}"
echo "" | tee -a "$RESULTS_FILE"
echo "=================================================" | tee -a "$RESULTS_FILE"
echo "K6 Load Test Results" | tee -a "$RESULTS_FILE"
echo "=================================================" | tee -a "$RESULTS_FILE"

BASE_URL=$GATEWAY_URL k6 run scripts/load-test.js | tee -a "$RESULTS_FILE"

# Parar monitoramento
kill $MONITOR_PID 2>/dev/null || true

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Teste concluído!${NC}"
echo "=================================================="
echo ""
echo "Status final do HPA:"
kubectl get hpa -n pspd-lab
echo ""
echo "Pods finais:"
kubectl get pods -n pspd-lab | grep -E 'NAME|gateway|service-a|service-b'
echo ""
echo "Resultados salvos em: $RESULTS_FILE"
echo ""
echo "Para visualizar métricas no Prometheus:"
echo "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "  Acesse: http://localhost:9090"
echo ""
echo "Para visualizar no Grafana:"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  Acesse: http://localhost:3000 (admin/admin)"
echo ""
