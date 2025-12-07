# Guia de Testes de Carga e Autoscaling

## Visão Geral

Este documento descreve como executar testes de carga na aplicação e observar o comportamento do autoscaling (HPA) no Kubernetes.

## Pré-requisitos

- Cluster Kubernetes multi-node configurado
- Aplicação deployada (Gateway + Service A + Service B)
- Prometheus + Grafana instalados
- HPA configurado
- k6 instalado (`brew install k6`)

## Configuração do HPA

O HPA (Horizontal Pod Autoscaler) foi configurado para todos os serviços com os seguintes parâmetros:

### Limites de Réplicas
- **Mínimo**: 1 pod
- **Máximo**: 5 pods

### Métricas de Escalonamento
- **CPU**: Escala quando uso > 50%
- **Memória**: Escala quando uso > 70%

### Comportamento de Escalonamento

**Scale Up (Aumentar pods):**
- Sem janela de estabilização (responde imediatamente)
- Pode aumentar até 100% dos pods atuais por vez
- Ou adicionar 2 pods de uma vez
- Usa a política mais agressiva (Max)

**Scale Down (Reduzir pods):**
- Janela de estabilização de 60 segundos
- Pode reduzir até 50% dos pods por vez
- Período de avaliação: 15 segundos

## Teste de Carga com k6

### Configuração do Teste

O teste simula carga crescente:

```
Fase 1: 30s → 10 usuários (warm up)
Fase 2: 1m  → 10 usuários (baseline)
Fase 3: 30s → 50 usuários (ramp up)
Fase 4: 2m  → 50 usuários (stress)
Fase 5: 30s → 100 usuários (peak)
Fase 6: 2m  → 100 usuários (sustained peak)
Fase 7: 30s → 0 usuários (ramp down)
```

**Duração total**: ~6.5 minutos

### Endpoints Testados

1. **GET /healthz** - Health check
2. **GET /users/:id** - Unary RPC (GetUser)
3. **GET /users** - Server Streaming (ListUsers)
4. **GET /stats/:id** - Unary RPC via Service B (GetScore)
5. **POST /users/bulk** - Client Streaming (CreateUsers)

### Thresholds (Limites Aceitáveis)

- **Latência P95**: < 500ms
- **Taxa de erro**: < 10%

## Executar Teste de Carga

### 1. Garantir que o Gateway está exposto

Em um terminal separado, execute:
```bash
./scripts/expose_gateway.sh
```

### 2. Executar o teste

```bash
chmod +x scripts/run_load_test.sh
./scripts/run_load_test.sh
```

O script irá:
- Verificar conectividade com o gateway
- Monitorar HPA a cada 10 segundos
- Executar teste de carga com k6
- Salvar resultados em `scripts/results/load-tests/`

### 3. Teste manual com k6

Se quiser rodar apenas o k6:
```bash
BASE_URL=http://localhost:8080 k6 run scripts/load-test.js
```

## Monitoramento Durante os Testes

### Comando 1: Monitorar HPA
```bash
watch -n 5 'kubectl get hpa -n pspd-lab'
```

### Comando 2: Monitorar Pods
```bash
watch -n 5 'kubectl get pods -n pspd-lab'
```

### Comando 3: Ver métricas em tempo real
```bash
kubectl top pods -n pspd-lab
```

## Acessar Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Acesse: http://localhost:9090

### Queries Úteis no Prometheus

```promql
# Requests por segundo no Gateway
rate(http_requests_total[1m])

# Latência P95 HTTP
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Taxa de erro
rate(http_requests_total{status_code=~"5.."}[1m]) / rate(http_requests_total[1m])

# CPU usage dos pods
rate(container_cpu_usage_seconds_total{namespace="pspd-lab"}[5m])

# Número de réplicas
kube_deployment_status_replicas{namespace="pspd-lab"}
```

## Acessar Grafana

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Acesse: http://localhost:3000
- **Username**: admin
- **Password**: admin

### Dashboards Pré-configurados

1. **Kubernetes / Compute Resources / Namespace (Pods)**
   - Uso de CPU/Memória por pod
   
2. **Kubernetes / Compute Resources / Workload**
   - Métricas por deployment
   
3. **Node Exporter / USE Method / Node**
   - Métricas dos nós do cluster

## Cenários de Teste Sugeridos

### Cenário 1: Baseline (Configuração Base)
- **Réplicas**: 1 pod cada serviço
- **Carga**: 10 usuários concorrentes
- **Objetivo**: Estabelecer métricas base

### Cenário 2: Stress Test (Teste de Estresse)
- **Réplicas**: Iniciar com 1, permitir autoscaling
- **Carga**: 50-100 usuários concorrentes
- **Objetivo**: Observar comportamento do HPA

### Cenário 3: Pré-escalado
- **Réplicas**: 3 pods cada serviço (escalar manualmente)
- **Carga**: 100 usuários concorrentes
- **Objetivo**: Comparar performance com mais recursos

### Cenário 4: Distribuição de Carga
- **Configuração**: Usar nodeAffinity para distribuir pods em workers diferentes
- **Carga**: 50 usuários concorrentes
- **Objetivo**: Avaliar impacto da distribuição física

## Métricas a Documentar

Para cada cenário, anote:

1. **Performance**
   - Tempo médio de resposta
   - P95 latência
   - Requests por segundo (throughput)
   - Taxa de erro

2. **Recursos**
   - Uso de CPU por pod
   - Uso de memória por pod
   - Número de réplicas durante o teste

3. **Autoscaling**
   - Tempo para escalar up
   - Tempo para escalar down
   - Número máximo de réplicas alcançado

4. **Observações**
   - Comportamento anômalo
   - Gargalos identificados
   - Sugestões de otimização

## Escalar Manualmente (Para Testes)

```bash
# Escalar gateway para 3 réplicas
kubectl scale deployment gateway -n pspd-lab --replicas=3

# Escalar service-a para 2 réplicas
kubectl scale deployment service-a -n pspd-lab --replicas=2

# Verificar
kubectl get pods -n pspd-lab
```

## Desabilitar HPA Temporariamente

```bash
# Deletar HPAs
kubectl delete hpa --all -n pspd-lab

# Recriar depois
kubectl apply -f k8s/hpa.yaml
```

## Troubleshooting

### HPA não está escalando

1. Verificar se metrics-server está rodando:
```bash
kubectl get pods -n kube-system | grep metrics-server
```

2. Verificar métricas disponíveis:
```bash
kubectl top nodes
kubectl top pods -n pspd-lab
```

3. Ver detalhes do HPA:
```bash
kubectl describe hpa gateway-hpa -n pspd-lab
```

### Teste de carga não conecta

1. Verificar se o port-forward está ativo
2. Testar manualmente:
```bash
curl http://localhost:8080/healthz
```

### Pods com OOMKilled (Out of Memory)

Aumentar limites de memória nos deployments:
```yaml
resources:
  limits:
    memory: 512Mi
```

## Limpeza

```bash
# Remover HPAs
kubectl delete -f k8s/hpa.yaml

# Resetar réplicas para 1
kubectl scale deployment --all -n pspd-lab --replicas=1
```

## Próximos Passos

1. Executar os 4 cenários de teste
2. Documentar resultados no relatório
3. Criar gráficos comparativos
4. Analisar trade-offs (custo vs performance)
5. Sugerir configuração ótima para produção
