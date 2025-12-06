#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/service-a-deployment.yaml
kubectl apply -f k8s/service-b-deployment.yaml
kubectl apply -f k8s/gateway-deployment.yaml
kubectl apply -f k8s/service-a-service.yaml
kubectl apply -f k8s/service-b-service.yaml
kubectl apply -f k8s/gateway-service.yaml
if [ -f k8s/ingress.yaml ]; then
  kubectl apply -f k8s/ingress.yaml
fi

echo "Acompanhar pods: kubectl get pods -n pspd-lab -w"
