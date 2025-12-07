#!/bin/bash

# Script para expor o gateway localmente

echo "🌐 Expondo gateway na porta 8080..."
echo ""
echo "Acesse: http://localhost:8080"
echo ""
echo "Endpoints disponíveis:"
echo "  - http://localhost:8080/healthz"
echo "  - http://localhost:8080/users/1"
echo "  - http://localhost:8080/users"
echo "  - http://localhost:8080/stats/1"
echo ""
echo "Pressione Ctrl+C para parar"
echo ""

kubectl port-forward -n pspd-lab svc/gateway 8080:80
