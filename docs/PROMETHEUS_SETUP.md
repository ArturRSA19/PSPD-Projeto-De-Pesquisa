# Prometheus + Grafana - Monitoramento e Observabilidade

## Visão Geral

O projeto utiliza o **kube-prometheus-stack**, que inclui:
- **Prometheus**: Coleta e armazena métricas
- **Grafana**: Visualização de métricas via dashboards
- **AlertManager**: Gerenciamento de alertas
- **Node Exporter**: Métricas dos nós do cluster
- **kube-state-metrics**: Métricas dos recursos Kubernetes

## Instalação

A instalação foi feita via Helm usando o script:

```bash
./scripts/setup_prometheus.sh
```

### Componentes Instalados

```bash
kubectl get pods -n monitoring
```

Saída esperada:
- `alertmanager-*`: Gerenciamento de alertas
- `prometheus-*`: Servidor Prometheus
- `prometheus-grafana-*`: Interface Grafana
- `prometheus-kube-state-metrics-*`: Métricas K8s
- `prometheus-node-exporter-*`: Métricas dos nós (1 por nó)
- `prometheus-operator-*`: Operador do Prometheus

## Métricas da Aplicação

### Instrumentação

Cada serviço foi instrumentado para expor métricas Prometheus:

#### 1. Gateway (Node.js)
- **Biblioteca**: `prom-client`
- **Endpoint**: `/metrics` (porta 9090)
- **Métricas customizadas**:
  - `http_requests_total`: Total de requisições HTTP
  - `http_request_duration_seconds`: Duração das requisições HTTP
  - `grpc_request_duration_seconds`: Duração das chamadas gRPC
- **Métricas default**: CPU, memória, event loop, etc.

#### 2. Service A (Python)
- **Biblioteca**: `prometheus-client`
- **Endpoint**: `/metrics` (porta 9090)
- **Métricas customizadas**:
  - `grpc_requests_total`: Total de requisições gRPC
  - `grpc_request_duration_seconds`: Duração das requisições gRPC
- **Métricas default**: Process metrics, GC, etc.

#### 3. Service B (Go)
- **Biblioteca**: Pode ser instrumentado com `prometheus/client_golang`
- **Endpoint**: `/metrics` (porta 9090)

### ServiceMonitors

ServiceMonitors conectam o Prometheus aos serviços:

```bash
kubectl get servicemonitors -n pspd-lab
```

Os ServiceMonitors instruem o Prometheus a coletar métricas dos endpoints `/metrics` de cada serviço.

## Acessando Interfaces

### 1. Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Acesse: http://localhost:9090

**Queries úteis**:

```promql
# Taxa de requisições HTTP por segundo (Gateway)
rate(http_requests_total[1m])

# Duração média de requisições HTTP
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Taxa de requisições gRPC (Service A)
rate(grpc_requests_total[1m])

# Uso de CPU dos pods
rate(container_cpu_usage_seconds_total{namespace="pspd-lab"}[5m])

# Uso de memória dos pods
container_memory_usage_bytes{namespace="pspd-lab"}

# Número de replicas por deployment
kube_deployment_status_replicas{namespace="pspd-lab"}
```

### 2. Grafana

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Acesse: http://localhost:3000
- **Username**: admin
- **Password**: admin

#### Dashboards Incluídos

O kube-prometheus-stack vem com vários dashboards pré-configurados:

1. **Kubernetes / Compute Resources / Cluster**
   - Visão geral do cluster
   - CPU, memória, rede

2. **Kubernetes / Compute Resources / Namespace (Pods)**
   - Métricas por namespace
   - Use namespace: `pspd-lab`

3. **Kubernetes / Compute Resources / Pod**
   - Detalhes de pods individuais

4. **Node Exporter / Nodes**
   - Métricas detalhadas dos nós

#### Criar Dashboard Customizado para a Aplicação

1. Acesse Grafana → Dashboards → New → Import
2. Crie painéis com as queries acima
3. Exemplo de painéis úteis:
   - Taxa de requisições HTTP (Gateway)
   - Latência P95/P99
   - Taxa de erros
   - Uso de recursos por serviço
   - Número de replicas (para acompanhar autoscaling)

### 3. AlertManager

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

Acesse: http://localhost:9093

## Verificando Métricas

### Testar endpoint de métricas diretamente:

```bash
# Gateway
kubectl port-forward -n pspd-lab svc/gateway 9090:9090
curl http://localhost:9090/metrics

# Service A
kubectl port-forward -n pspd-lab svc/service-a 9090:9090
curl http://localhost:9090/metrics

# Service B
kubectl port-forward -n pspd-lab svc/service-b 9090:9090
curl http://localhost:9090/metrics
```

### Verificar se Prometheus está coletando:

1. Acesse Prometheus UI
2. Status → Targets
3. Procure por `pspd-lab/gateway-metrics`, `pspd-lab/service-a-metrics`, `pspd-lab/service-b-metrics`
4. Status deve ser **UP**

## Métricas para Observabilidade

### Método RED (para serviços)

- **Rate**: Taxa de requisições
- **Errors**: Taxa de erros
- **Duration**: Latência das requisições

### Método USE (para recursos)

- **Utilization**: % de uso do recurso
- **Saturation**: Quantidade de trabalho em fila
- **Errors**: Taxa de erros

## Troubleshooting

### ServiceMonitor não está funcionando

```bash
# Verificar labels do ServiceMonitor
kubectl describe servicemonitor gateway-metrics -n pspd-lab

# Verificar se o Prometheus tem permissão para ler o namespace
kubectl get prometheuses -n monitoring -o yaml | grep serviceMonitorSelector
```

### Métricas não aparecem no Prometheus

```bash
# Verificar endpoints
kubectl get endpoints -n pspd-lab

# Verificar logs do Prometheus
kubectl logs -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -c prometheus

# Testar endpoint manualmente
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://gateway.pspd-lab:9090/metrics
```

### Grafana não conecta ao Prometheus

O datasource já vem configurado automaticamente. Verifique em:
Configuration → Data Sources → Prometheus

## Próximos Passos

1. ✅ Prometheus instalado
2. ✅ Métricas instrumentadas
3. ✅ ServiceMonitors configurados
4. ⬜ Configurar HPA baseado em métricas
5. ⬜ Executar testes de carga
6. ⬜ Analisar comportamento sob stress
7. ⬜ Documentar cenários e resultados

## Referências

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
