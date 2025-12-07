#!/bin/bash

# Script para instalar e configurar Prometheus + Grafana no Kubernetes usando Helm

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo "  Setup Prometheus + Grafana no Kubernetes"
echo "=================================================="
echo ""

# Verificar se Helm está instalado
echo -e "${YELLOW}[1/6] Verificando Helm...${NC}"
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm não está instalado.${NC}"
    echo "Instale com: brew install helm"
    exit 1
fi
HELM_VERSION=$(helm version --short)
echo -e "${GREEN}✓ Helm instalado: $HELM_VERSION${NC}"
echo ""

# Adicionar repositório do Prometheus
echo -e "${YELLOW}[2/6] Adicionando repositório Prometheus Community...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo -e "${GREEN}✓ Repositório adicionado${NC}"
echo ""

# Criar namespace para monitoring
echo -e "${YELLOW}[3/6] Criando namespace monitoring...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace criado/verificado${NC}"
echo ""

# Instalar kube-prometheus-stack
echo -e "${YELLOW}[4/6] Instalando kube-prometheus-stack...${NC}"
echo "⏱️  Isso pode levar 2-5 minutos..."
echo ""

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin \
  --wait \
  --timeout 10m

echo ""
echo -e "${GREEN}✓ kube-prometheus-stack instalado${NC}"
echo ""

# Aguardar pods ficarem prontos
echo -e "${YELLOW}[5/6] Aguardando pods ficarem prontos...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
echo -e "${GREEN}✓ Pods prontos${NC}"
echo ""

# Verificar instalação
echo -e "${YELLOW}[6/6] Verificando instalação...${NC}"
echo ""
kubectl get pods -n monitoring
echo ""

echo "=================================================="
echo -e "${GREEN}✅ Prometheus + Grafana instalados com sucesso!${NC}"
echo "=================================================="
echo ""
echo "📊 Informações importantes:"
echo ""
echo "Prometheus:"
echo "  - Namespace: monitoring"
echo "  - Service: prometheus-kube-prometheus-prometheus"
echo "  - Port: 9090"
echo ""
echo "Grafana:"
echo "  - Service: prometheus-grafana"
echo "  - Port: 80"
echo "  - Username: admin"
echo "  - Password: admin"
echo ""
echo "=================================================="
echo "Acessar interfaces:"
echo "=================================================="
echo ""
echo "1. Prometheus:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "   Acesse: http://localhost:9090"
echo ""
echo "2. Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   Acesse: http://localhost:3000"
echo "   Login: admin / admin"
echo ""
echo "3. AlertManager:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
echo "   Acesse: http://localhost:9093"
echo ""
echo "=================================================="
echo "Próximos passos:"
echo "=================================================="
echo ""
echo "1. Instrumentar aplicação com métricas"
echo "2. Criar ServiceMonitors para os serviços"
echo "3. Configurar dashboards no Grafana"
echo "4. Configurar HPA baseado em métricas customizadas"
echo ""
