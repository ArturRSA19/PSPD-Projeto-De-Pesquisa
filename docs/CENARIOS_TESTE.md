# Guia de Execução dos Cenários de Teste

## Preparação

Antes de executar qualquer cenário:

1. **Gateway exposto** (terminal separado):
```bash
./scripts/expose_gateway.sh
```

2. **Monitoramento opcional** (outro terminal):
```bash
watch -n 5 'kubectl get hpa -n pspd-lab && echo "" && kubectl get pods -n pspd-lab'
```

## Cenários

### Cenário 1: Baseline com Autoscaling ✅ JÁ EXECUTADO

**Objetivo**: Estabelecer métricas base

```bash
chmod +x scripts/cenario1_baseline.sh
./scripts/cenario1_baseline.sh
```

**Configuração**:
- 1 réplica inicial
- HPA: CPU 50%, Mem 70%
- Max: 5 réplicas
- Carga: 10→50→100 usuários

**Resultado esperado**:
- Gateway: ~5 réplicas
- Service-A: ~3 réplicas
- Latência P95: < 500ms

---

### Cenário 2: Pré-escalado (Sem Autoscaling)

**Objetivo**: Comparar com recursos pré-alocados

```bash
chmod +x scripts/cenario2_pre_escalado.sh
./scripts/cenario2_pre_escalado.sh
```

**Configuração**:
- 3 réplicas fixas de cada serviço
- HPA: Desabilitado
- Carga: 10→50→100 usuários (igual ao Cenário 1)

**Hipótese**: 
- Menor latência inicial (recursos já prontos)
- Maior uso de recursos (3 réplicas ociosas no início)
- Performance mais estável

---

### Cenário 3: HPA Agressivo

**Objetivo**: Verificar se escalamento mais rápido melhora performance

```bash
chmod +x scripts/cenario3_hpa_agressivo.sh
./scripts/cenario3_hpa_agressivo.sh
```

**Configuração**:
- 1 réplica inicial
- HPA Agressivo:
  - CPU: 30% (antes 50%)
  - Mem: 50% (antes 70%)
  - Max: 10 réplicas (antes 5)
  - Scale up: +4 pods ou 200% (antes +2 ou 100%)
- Carga: 10→50→100 usuários

**Hipótese**:
- Escala mais rápido
- Pode ter mais réplicas que o necessário
- Latência potencialmente menor durante ramp-up

---

### Cenário 4: Stress Test

**Objetivo**: Identificar limites do sistema

```bash
chmod +x scripts/cenario4_stress_test.sh
./scripts/cenario4_stress_test.sh
```

**Configuração**:
- Escolha entre HPA normal ou agressivo
- Carga EXTREMA: 50→150→200 usuários
- Duração: 9 minutos

**Observar**:
- Limites de escalamento
- OOMKilled ou CrashLoopBackOff
- Degradação de performance
- Ponto de saturação

---

## Comparação dos Resultados

### Métricas a Coletar de Cada Cenário:

1. **Performance**:
   - Throughput (req/s)
   - Latência média
   - P95 latência
   - Taxa de erro

2. **Recursos**:
   - Número de réplicas alcançado
   - Tempo para escalar
   - Uso de CPU/Memória
   - Custo de recursos (réplicas × tempo)

3. **Autoscaling**:
   - Tempo de reação (0→max réplicas)
   - Estabilidade (oscilações)
   - Eficiência (recursos × performance)

### Tabela Comparativa (Preencher após testes):

| Métrica | Cenário 1 | Cenário 2 | Cenário 3 | Cenário 4 |
|---------|-----------|-----------|-----------|-----------|
| **Throughput (req/s)** | 111 | ? | ? | ? |
| **Latência Média** | 125ms | ? | ? | ? |
| **P95 Latência** | 432ms | ? | ? | ? |
| **Taxa Erro** | 0% | ? | ? | ? |
| **Max Réplicas Gateway** | 5 | 3 | ? | ? |
| **Max Réplicas Service-A** | 3 | 3 | ? | ? |
| **Tempo p/ Escalar** | ~2min | N/A | ? | ? |
| **Custo Recursos*** | Médio | Alto | ? | ? |

*Custo = Soma(réplicas × tempo ativo)

## Análise Recomendada

Para cada cenário, documentar:

1. **Setup inicial**: Screenshot dos pods/HPA antes do teste
2. **Durante o teste**: Screenshots do Grafana/Prometheus
3. **Resultado k6**: Copiar output do terminal
4. **Estado final**: Screenshot dos pods/HPA após teste
5. **Observações**: Problemas, comportamentos inesperados

## Grafana

Para visualizar em tempo real:

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Acesse: http://localhost:3000 (admin/admin)

**Dashboards recomendados**:
- Kubernetes / Compute Resources / Namespace (Pods)
- Kubernetes / Compute Resources / Workload

## Limpeza

Após todos os testes:

```bash
# Resetar para estado inicial
kubectl apply -f k8s/hpa.yaml
kubectl scale deployment --all -n pspd-lab --replicas=1
```

## Troubleshooting

### OOMKilled no Stress Test
Aumentar limites de memória nos deployments

### HPA não escala
Verificar metrics-server: `kubectl top pods -n pspd-lab`

### Teste muito lento
Reduzir duração ou usuários nos scripts de teste
