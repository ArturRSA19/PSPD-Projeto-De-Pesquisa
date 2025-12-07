#!/bin/bash

# Script para configurar cluster Minikube multi-node conforme requisitos do projeto PSPD
# Requisitos: 1 control-plane + 2 workers

set -e

echo "=================================================="
echo "  Setup Cluster Kubernetes Multi-Node (Minikube)"
echo "=================================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se Docker está rodando
echo -e "${YELLOW}[1/6] Verificando Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker não está rodando. Por favor, inicie o Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker está rodando${NC}"
echo ""

# Verificar se Minikube está instalado
echo -e "${YELLOW}[2/6] Verificando Minikube...${NC}"
if ! command -v minikube &> /dev/null; then
    echo -e "${RED}❌ Minikube não está instalado.${NC}"
    echo "Instale com: brew install minikube"
    exit 1
fi
MINIKUBE_VERSION=$(minikube version --short)
echo -e "${GREEN}✓ Minikube instalado: $MINIKUBE_VERSION${NC}"
echo ""

# Verificar se kubectl está instalado
echo -e "${YELLOW}[3/6] Verificando kubectl...${NC}"
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl não está instalado.${NC}"
    echo "Instale com: brew install kubectl"
    exit 1
fi
KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | head -n1)
echo -e "${GREEN}✓ kubectl instalado: $KUBECTL_VERSION${NC}"
echo ""

# Perguntar se deve deletar cluster existente
echo -e "${YELLOW}[4/6] Verificando clusters existentes...${NC}"
if minikube status > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Cluster Minikube já existe.${NC}"
    read -p "Deseja deletar e recriar? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Deletando cluster existente..."
        minikube delete
        echo -e "${GREEN}✓ Cluster deletado${NC}"
    else
        echo -e "${YELLOW}Mantendo cluster existente. Verifique se atende aos requisitos (3 nós).${NC}"
        kubectl get nodes
        exit 0
    fi
else
    echo -e "${GREEN}✓ Nenhum cluster existente${NC}"
fi
echo ""

# Criar cluster multi-node
echo -e "${YELLOW}[5/6] Criando cluster Minikube (3 nós: 1 control-plane + 2 workers)...${NC}"
echo "⏱️  Isso pode levar 5-10 minutos..."
echo ""

minikube start \
  --nodes 3 \
  --cpus 2 \
  --memory 4096 \
  --driver docker \
  --kubernetes-version stable

echo ""
echo -e "${GREEN}✓ Cluster criado com sucesso!${NC}"
echo ""

# Habilitar addons necessários
echo -e "${YELLOW}[6/6] Habilitando addons necessários...${NC}"

echo "  → Habilitando metrics-server (necessário para HPA)..."
minikube addons enable metrics-server

echo "  → Habilitando dashboard (interface web)..."
minikube addons enable dashboard

echo ""
echo -e "${GREEN}✓ Addons habilitados${NC}"
echo ""

# Aguardar pods do sistema ficarem prontos
echo "Aguardando pods do sistema ficarem prontos..."
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=120s

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Cluster configurado com sucesso!${NC}"
echo "=================================================="
echo ""

# Exibir informações do cluster
echo "📊 Status do Cluster:"
echo ""
minikube status
echo ""

echo "📦 Nós do Cluster:"
echo ""
kubectl get nodes -o wide
echo ""

echo "🔧 Addons Habilitados:"
echo ""
minikube addons list | grep enabled
echo ""

echo "=================================================="
echo "Próximos passos:"
echo "=================================================="
echo ""
echo "1. Ver dashboard:"
echo "   minikube dashboard"
echo ""
echo "2. Verificar métricas dos nós:"
echo "   kubectl top nodes"
echo ""
echo "3. Deploy da aplicação:"
echo "   cd /Users/izarias/Documents/Projects/PSPD3/PSPD_Trabalho1"
echo "   ./scripts/deploy.sh"
echo ""
echo "4. Ver logs do cluster:"
echo "   minikube logs"
echo ""
