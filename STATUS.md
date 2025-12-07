# Status do Projeto PSPD - Trabalho 3

## ✅ Completado

### 1. Cluster Kubernetes Multi-Node
- ✅ 1 control-plane + 2 workers (Minikube)
- ✅ Metrics-server habilitado
- ✅ Dashboard habilitado
- 📄 Documentação: `docs/CLUSTER_SETUP.md`
- 🔧 Script: `scripts/setup_cluster.sh`

### 2. Aplicação Deployada
- ✅ Gateway (Node.js + Express + gRPC client)
- ✅ Service A (Python + gRPC server)
- ✅ Service B (Go + gRPC server)
- ✅ Todos os padrões gRPC implementados:
  - Unary RPC
  - Server Streaming
  - Client Streaming
  - Bidirectional Streaming
- 🔧 Scripts:
  - `scripts/build_and_load_images.sh`
  - `scripts/deploy.sh`
  - `scripts/smoke_tests.sh`

### 3. Prometheus + Grafana
- ✅ Prometheus instalado (namespace monitoring)
- ✅ Grafana instalado (admin/admin)
- ✅ Métricas instrumentadas em todos os serviços
- ✅ ServiceMonitors configurados
- ✅ Métricas customizadas:
  - http_requests_total
  - http_request_duration_seconds
  - grpc_requests_total
  - grpc_request_duration_seconds
- 📄 Documentação: `docs/PROMETHEUS_SETUP.md`
- 🔧 Script: `scripts/setup_prometheus.sh`

### 4. Autoscaling (HPA)
- ✅ HPA configurado para todos os serviços
- ✅ Métricas: CPU (50%) e Memória (70%)
- ✅ Min: 1 réplica, Max: 5 réplicas
- ✅ Políticas de scale up/down configuradas
- 📄 Config: `k8s/hpa.yaml`

### 5. Testes de Carga
- ✅ k6 instalado
- ✅ Script de teste criado (`scripts/load-test.js`)
- ✅ Teste com 6 fases (10→50→100 usuários)
- ✅ Monitoramento automático de HPA
- 📄 Documentação: `docs/LOAD_TESTING.md`
- 🔧 Script: `scripts/run_load_test.sh`

## 📋 Para Executar os Testes

### Teste Rápido (verificar que tudo funciona)
```bash
# Terminal 1: Expor gateway
./scripts/expose_gateway.sh

# Terminal 2: Smoke tests
GATEWAY_HOST=localhost GATEWAY_PORT=8080 ./scripts/smoke_tests.sh
```

### Teste de Carga Completo
```bash
# Terminal 1: Expor gateway
./scripts/expose_gateway.sh

# Terminal 2: Teste de carga
./scripts/run_load_test.sh
```

### Monitorar HPA em Tempo Real
```bash
watch -n 5 'kubectl get hpa -n pspd-lab'
```

### Acessar Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Acesse: http://localhost:9090
```

### Acessar Grafana
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Acesse: http://localhost:3000 (admin/admin)
```

## 📊 Cenários de Teste Sugeridos

### Cenário 1: Baseline
- 1 réplica de cada serviço
- 10 usuários concorrentes
- Medir: latência base, throughput

### Cenário 2: Autoscaling
- Iniciar com 1 réplica
- 50-100 usuários concorrentes
- Observar: comportamento do HPA

### Cenário 3: Pré-escalado
- 3 réplicas de cada serviço
- 100 usuários concorrentes
- Comparar com Cenário 2

### Cenário 4: Stress Test
- Carga crescente até limites
- Identificar gargalos
- Testar resiliência

## 📁 Estrutura de Arquivos Importantes

```
PSPD_Trabalho1/
├── docs/
│   ├── CLUSTER_SETUP.md       # Setup do cluster K8s
│   ├── PROMETHEUS_SETUP.md    # Setup do Prometheus/Grafana
│   └── LOAD_TESTING.md        # Guia de testes de carga
├── k8s/
│   ├── namespace.yaml
│   ├── *-deployment.yaml      # Deployments dos serviços
│   ├── *-service.yaml         # Services
│   ├── servicemonitors.yaml   # ServiceMonitors do Prometheus
│   ├── hpa.yaml               # Horizontal Pod Autoscalers
│   └── ingress.yaml
├── scripts/
│   ├── setup_cluster.sh       # Setup completo do cluster
│   ├── setup_prometheus.sh    # Instalar Prometheus/Grafana
│   ├── build_and_load_images.sh   # Build e load de imagens
│   ├── deploy.sh              # Deploy da aplicação
│   ├── redeploy_with_metrics.sh   # Redeploy com métricas
│   ├── expose_gateway.sh      # Expor gateway localmente
│   ├── smoke_tests.sh         # Testes básicos
│   ├── run_load_test.sh       # Executar teste de carga
│   └── load-test.js           # Script k6
├── gateway-node/              # Gateway (P)
├── service-a-python/          # Service A
└── service-b-go/              # Service B
```

## 🎯 Próximas Ações para o Relatório

1. **Executar os 4 cenários de teste**
   - Documentar configuração de cada cenário
   - Capturar screenshots do Grafana
   - Salvar logs e métricas

2. **Análise Comparativa**
   - Criar tabelas com resultados
   - Gráficos de latência vs carga
   - Gráficos de throughput vs réplicas
   - Análise de custo-benefício

3. **Documentação**
   - Descrever setup do cluster
   - Explicar configuração do Prometheus
   - Detalhar cenários testados
   - Apresentar conclusões

4. **Screenshots Importantes**
   - Cluster (3 nós)
   - Pods rodando
   - HPA escalando
   - Dashboards do Grafana
   - Métricas do Prometheus
   - Resultados do k6

## 🔍 Queries Prometheus Úteis

```promql
# Requests por segundo
rate(http_requests_total[1m])

# Latência P95
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# CPU dos pods
rate(container_cpu_usage_seconds_total{namespace="pspd-lab"}[5m])

# Número de réplicas
kube_deployment_status_replicas{namespace="pspd-lab"}

# Taxa de erro
rate(http_requests_total{status_code=~"5.."}[1m]) / rate(http_requests_total[1m])
```

## ⚠️ Observações Importantes

- **Port-forward**: Sempre manter `expose_gateway.sh` rodando durante testes
- **Métricas**: Aguardar ~2 minutos após deploy para métricas estabilizarem
- **HPA**: Scale down tem delay de 60s (estabilização)
- **Resultados**: Salvos em `scripts/results/load-tests/`

## 🚀 Comandos Úteis

```bash
# Ver todos os recursos
kubectl get all -n pspd-lab

# Logs de um pod
kubectl logs -f <pod-name> -n pspd-lab

# Ver eventos
kubectl get events -n pspd-lab --sort-by='.lastTimestamp'

# Escalar manualmente
kubectl scale deployment gateway -n pspd-lab --replicas=3

# Restart deployment
kubectl rollout restart deployment/gateway -n pspd-lab

# Ver métricas
kubectl top pods -n pspd-lab
kubectl top nodes
```

## 📚 Referências

- Kubernetes HPA: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- Prometheus: https://prometheus.io/docs/
- k6 Documentation: https://k6.io/docs/
- gRPC Performance: https://grpc.io/docs/guides/performance/
