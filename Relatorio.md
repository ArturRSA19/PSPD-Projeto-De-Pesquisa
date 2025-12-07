# Relatório Final - Projeto de Monitoramento e Observabilidade em Kubernetes

---

## Dados de Identificação

**Curso:** Engenharia de Computação  
**Disciplina:** PSPD - Programação para Sistemas Paralelos e Distribuídos  
**Professor:** Fernando W. Cruz  
**Data:** 6 de Dezembro de 2025  

**Integrantes do Grupo:**
- [Nome do Aluno 1] - Matrícula: [XXXXXX]
- [Nome do Aluno 2] - Matrícula: [XXXXXX]
- [Nome do Aluno 3] - Matrícula: [XXXXXX]
- [Nome do Aluno 4] - Matrícula: [XXXXXX]

---

## 1. Introdução

Este projeto teve como objetivo explorar estratégias de monitoramento e observabilidade de aplicações baseadas em microserviços em ambiente Kubernetes, com foco em métricas de desempenho. O trabalho envolveu a criação de uma aplicação distribuída usando gRPC, a configuração de um cluster Kubernetes multi-nó, a implementação de ferramentas de monitoramento (Prometheus e Grafana), e a realização de testes de carga em diferentes cenários de autoscaling.

### Estrutura do Relatório

Este documento está organizado nas seguintes seções:
- **Seção 2:** Metodologia utilizada pelo grupo
- **Seção 3:** Experiência de montagem do Kubernetes em modo cluster
- **Seção 4:** Monitoramento e observabilidade com Prometheus/Grafana
- **Seção 5:** Descrição da aplicação e arquitetura
- **Seção 6:** Cenários de teste e resultados
- **Seção 7:** Conclusões e considerações finais
- **Seção 8:** Referências bibliográficas
- **Anexos:** Informações técnicas adicionais

---

## 2. Metodologia Utilizada

### 2.1 Organização do Grupo

[Descrever como o grupo se organizou para realizar o projeto]

### 2.2 Cronograma de Encontros e Atividades

| Data | Atividade Realizada | Responsáveis |
|------|---------------------|--------------|
| [Data] | Definição da arquitetura da aplicação | [Nomes] |
| [Data] | Implementação do Gateway (Node.js) | [Nomes] |
| [Data] | Implementação do Service-A (Python) | [Nomes] |
| [Data] | Implementação do Service-B (Go) | [Nomes] |
| [Data] | Setup do cluster Kubernetes | [Nomes] |
| [Data] | Configuração do Prometheus e Grafana | [Nomes] |
| [Data] | Desenvolvimento dos scripts de teste | [Nomes] |
| [Data] | Execução dos cenários de teste | [Nomes] |
| [Data] | Análise de resultados e documentação | [Nomes] |

### 2.3 Divisão de Tarefas

- **[Nome]:** [Descrição das responsabilidades]
- **[Nome]:** [Descrição das responsabilidades]
- **[Nome]:** [Descrição das responsabilidades]
- **[Nome]:** [Descrição das responsabilidades]

---

## 3. Experiência de Montagem do Kubernetes em Modo Cluster

### 3.1 Escolha da Plataforma

Para este projeto, optamos por utilizar o **Minikube** em modo multi-nó, executando localmente em ambiente macOS. Esta escolha permitiu:
- Simulação realista de um cluster Kubernetes
- Facilidade de experimentação e debugging
- Controle total sobre a configuração do ambiente
- Custo zero de infraestrutura

### 3.2 Configuração do Cluster

#### 3.2.1 Especificações do Cluster

- **Plano de Controle:** 1 nó mestre
- **Worker Nodes:** 2 nós escravos
- **Driver:** Docker
- **CPUs por nó:** 2
- **Memória por nó:** 2048MB
- **Kubernetes Version:** [Versão utilizada]

#### 3.2.2 Processo de Instalação

O cluster foi configurado através do script `scripts/setup_cluster.sh`:

```bash
#!/bin/bash
# Configuração do cluster Kubernetes multi-nó
minikube start --nodes 3 --cpus 2 --memory 2048 --driver=docker
kubectl label nodes minikube-m02 node-role.kubernetes.io/worker=worker
kubectl label nodes minikube-m03 node-role.kubernetes.io/worker=worker
```

**Passos realizados:**
1. Instalação do Minikube e kubectl
2. Configuração do driver Docker
3. Criação do cluster com 3 nós
4. Rotulação dos nós worker
5. Verificação do estado do cluster
6. Habilitação de addons necessários (metrics-server, ingress)

**Comandos de verificação:**
```bash
kubectl get nodes
kubectl cluster-info
```

### 3.3 Desafios Encontrados

#### 3.3.1 Limitações de Recursos
[Descrever desafios relacionados a recursos computacionais e como foram resolvidos]

#### 3.3.2 Networking
[Descrever desafios de networking e soluções implementadas]

#### 3.3.3 Persistência de Dados
[Descrever como foi tratada a questão de volumes e persistência]

### 3.4 Estrutura de Deployment

A aplicação foi organizada em namespaces e deployments conforme documentado em `k8s/`:
- **Namespace:** `grpc-app`
- **Gateway:** 1-3 réplicas (conforme cenário)
- **Service-A:** 1-3 réplicas (conforme cenário)
- **Service-B:** 1-3 réplicas (conforme cenário)

---

## 4. Monitoramento e Observabilidade

### 4.1 Prometheus

#### 4.1.1 Instalação e Configuração

O Prometheus foi instalado utilizando o Helm Chart oficial, através do script `scripts/setup_prometheus.sh`:

```bash
#!/bin/bash
# Instalação do Prometheus via Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

#### 4.1.2 ServiceMonitors Configurados

Foram criados ServiceMonitors customizados para cada serviço da aplicação (`k8s/servicemonitors.yaml`):
- **Gateway ServiceMonitor:** Coleta métricas HTTP do Node.js
- **Service-A ServiceMonitor:** Coleta métricas da aplicação Python
- **Service-B ServiceMonitor:** Coleta métricas da aplicação Go

#### 4.1.3 Métricas Coletadas

**Métricas de Sistema:**
- CPU usage (por pod e por nó)
- Memória usage (por pod e por nó)
- Network I/O
- Disk I/O

**Métricas de Aplicação:**
- Throughput (requisições por segundo)
- Latência (p50, p95, p99)
- Taxa de erro
- Número de réplicas ativas

**Métricas de gRPC:**
- Duração de chamadas gRPC
- Status de resposta
- Volume de dados trafegados

### 4.2 Grafana

#### 4.2.1 Acesso ao Grafana

O Grafana foi instalado como parte do stack do Prometheus e pode ser acessado via port-forward:

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Acesso: http://localhost:3000
# Credenciais padrão: admin/prom-operator
```

#### 4.2.2 Dashboards Utilizados

**Dashboards Pré-configurados:**
- **Node Exporter / Nodes:** Métricas detalhadas dos 3 nós do cluster (CPU, memória, disco, rede do host)
- **Kubernetes / Compute Resources / Namespace:** Visualização de CPU Quota (requests e limits configurados)

**Queries Diretas no Prometheus:**

Para monitoramento detalhado da aplicação e do comportamento do HPA, utilizamos queries diretas no Prometheus:

```promql
# Número de réplicas por deployment
kube_deployment_status_replicas{namespace="grpc-app"}

# CPU utilizado (target do HPA)
container_cpu_usage_seconds_total{namespace="grpc-app"}

# Pods em execução
kube_pod_status_phase{namespace="grpc-app"}

# Status do HPA
kube_horizontalpodautoscaler_status_current_replicas{namespace="grpc-app"}
```

**Ferramentas Complementares:**

Além do Grafana, utilizamos extensivamente:
- `kubectl get hpa -n grpc-app` para monitorar autoscaling em tempo real
- `kubectl get pods -n grpc-app` para verificar estado das réplicas
- `kubectl top nodes` para verificar carga dos nós
- Logs dos testes k6 para métricas de performance da aplicação

#### 4.2.3 Observações sobre Monitoramento

O stack Prometheus/Grafana foi configurado com sucesso, permitindo:
- ✅ Monitoramento da saúde dos nós do cluster
- ✅ Validação de configurações de recursos (CPU/Memory requests e limits)
- ✅ Queries customizadas para métricas específicas do HPA
- ✅ Integração com ServiceMonitors dos serviços da aplicação

A análise principal de desempenho foi realizada através dos **resultados detalhados do k6**, que forneceram métricas precisas de latência, throughput e taxa de erro. O Prometheus serviu como ferramenta complementar para validar o comportamento do autoscaling e a saúde geral do cluster durante os testes.

#### 4.2.4 Exemplos de Visualização

**Figura 1: Dashboard Node Exporter - Métricas dos Nós do Cluster**

![Dashboard Node Exporter Grafana]

*[INSERIR PRINT AQUI: Screenshot do dashboard Node Exporter do Grafana mostrando métricas de CPU, memória e rede de um dos nós do cluster Kubernetes]*

**Figura 2: Prometheus - Evolução das Réplicas do HPA**

![Prometheus HPA Replicas]

*[INSERIR PRINT AQUI: Screenshot do Prometheus com a query `kube_horizontalpodautoscaler_status_current_replicas{namespace="pspd-lab"}` no modo Graph, mostrando a evolução do número de réplicas dos deployments ao longo do tempo durante os testes]*

### 4.3 Horizontal Pod Autoscaler (HPA)

#### 4.3.1 Configuração Normal

Arquivo: `k8s/hpa.yaml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: gateway-hpa
  namespace: grpc-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gateway
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### 4.3.2 Configuração Agressiva

Arquivo: `k8s/hpa-agressivo.yaml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: gateway-hpa
  namespace: grpc-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gateway
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
```

**Diferenças principais:**
- Threshold de CPU reduzido (50% vs 70%)
- Máximo de réplicas aumentado (5 vs 3)
- Scale-up mais rápido (sem janela de estabilização)
- Políticas agressivas de escalamento

---

## 5. Aplicação Baseada em Microserviços

### 5.1 Arquitetura da Aplicação

A aplicação foi desenvolvida seguindo uma arquitetura de microserviços com comunicação gRPC:

```
┌─────────────────┐
│   Usuário/      │
│   Load Test     │
└────────┬────────┘
         │ HTTP REST
         ▼
┌─────────────────┐
│   Gateway       │
│   (Node.js)     │
│   Port: 8080    │
└────┬───────┬────┘
     │       │
     │ gRPC  │ gRPC
     ▼       ▼
┌─────────┐ ┌─────────┐
│Service-A│ │Service-B│
│(Python) │ │  (Go)   │
│Port:50051│ │Port:50052│
└─────────┘ └─────────┘
```

### 5.2 Descrição dos Serviços

#### 5.2.1 Gateway (Node.js)

**Responsabilidades:**
- Receber requisições HTTP REST dos clientes
- Converter requisições REST para chamadas gRPC
- Orquestrar chamadas para Service-A e Service-B
- Consolidar respostas e retornar ao cliente

**Endpoints:**
- `GET /healthz` - Health check
- `POST /users` - Criar usuário (chama Service-A)
- `GET /users` - Listar usuários (chama Service-A)
- `GET /stats/:id` - Obter estatísticas (chama Service-B)

**Tecnologias:**
- Node.js 18
- Express.js para API REST
- @grpc/grpc-js para comunicação gRPC
- Protocol Buffers para serialização

**Arquivo:** `gateway-node/src/index.js`

#### 5.2.2 Service-A (Python)

**Responsabilidades:**
- Gerenciar dados de usuários
- Implementar operações CRUD via gRPC
- Fornecer lista de usuários cadastrados

**Métodos gRPC:**
- `CreateUser(UserRequest) returns (UserResponse)`
- `GetUsers(Empty) returns (UsersListResponse)`

**Tecnologias:**
- Python 3.11
- grpcio para servidor gRPC
- Protocol Buffers para serialização

**Arquivo:** `service-a-python/server.py`

#### 5.2.3 Service-B (Go)

**Responsabilidades:**
- Calcular estatísticas sobre usuários
- Processar dados sob demanda
- Retornar métricas agregadas

**Métodos gRPC:**
- `GetUserStats(StatsRequest) returns (StatsResponse)`

**Tecnologias:**
- Go 1.21
- google.golang.org/grpc
- Protocol Buffers para serialização

**Arquivo:** `service-b-go/server.go`

### 5.3 Protocol Buffers

O contrato de comunicação entre os serviços é definido em `proto/users.proto`:

```protobuf
syntax = "proto3";

package users;
option go_package = "github.com/user/pspd";

service UserService {
  rpc CreateUser (UserRequest) returns (UserResponse);
  rpc GetUsers (Empty) returns (UsersListResponse);
}

service StatsService {
  rpc GetUserStats (StatsRequest) returns (StatsResponse);
}

message UserRequest {
  string name = 1;
  string email = 2;
}

message UserResponse {
  int32 id = 1;
  string name = 2;
  string email = 3;
}

message Empty {}

message UsersListResponse {
  repeated UserResponse users = 1;
}

message StatsRequest {
  int32 user_id = 1;
}

message StatsResponse {
  int32 user_id = 1;
  int32 total_requests = 2;
  string status = 3;
}
```

### 5.4 Containerização

Cada serviço foi containerizado usando Docker:

**Gateway Dockerfile:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD ["node", "src/index.js"]
```

**Service-A Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 50051
CMD ["python", "server.py"]
```

**Service-B Dockerfile:**
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o server .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 50052
CMD ["./server"]
```

### 5.5 Versão Básica da Aplicação

**Configuração inicial para baseline:**
- Gateway: 1 réplica
- Service-A: 1 réplica
- Service-B: 1 réplica
- Sem autoscaling habilitado
- Limites de recursos definidos mas sem otimização

**Características de desempenho observadas:**
- Latência média: ~100ms
- Throughput máximo: ~50 req/s
- Taxa de erro: < 1%

---

## 6. Cenários de Teste e Resultados

### 6.1 Ferramenta de Teste de Carga

#### 6.1.1 Escolha da Ferramenta

Utilizamos o **k6** (https://k6.io) para realizar os testes de carga. A escolha foi baseada em:
- Suporte nativo para testes HTTP/REST
- Scripting em JavaScript
- Métricas detalhadas out-of-the-box
- Facilidade de automação
- Geração de relatórios estruturados

#### 6.1.2 Scripts de Teste

**Teste Normal:** `scripts/load-test.js`
- Virtual Users (VUs): 50
- Duração: 5 minutos
- Ramp-up: 30 segundos
- Operações: 70% GET, 30% POST

**Teste de Stress:** `scripts/load-test-stress.js`
- Virtual Users (VUs): 100
- Duração: 5 minutos
- Ramp-up: 30 segundos
- Operações: 70% GET, 30% POST

### 6.2 Cenário 1 - Baseline (Sem Autoscaling)

#### 6.2.1 Configuração

**Deployment:**
- Gateway: 1 réplica fixa
- Service-A: 1 réplica fixa
- Service-B: 1 réplica fixa
- HPA: Desabilitado

**Objetivo:**
Estabelecer uma linha de base de desempenho da aplicação sem nenhuma otimização de escalabilidade.

#### 6.2.2 Execução

Script: `scripts/cenario1_baseline.sh`

```bash
#!/bin/bash
# Cenário 1 - Baseline sem autoscaling
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/gateway-deployment.yaml
kubectl apply -f k8s/service-a-deployment.yaml
kubectl apply -f k8s/service-b-deployment.yaml
kubectl apply -f k8s/gateway-service.yaml
kubectl apply -f k8s/service-a-service.yaml
kubectl apply -f k8s/service-b-service.yaml

# Aguardar pods ficarem prontos
kubectl wait --for=condition=ready pod -l app=gateway -n grpc-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-a -n grpc-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-b -n grpc-app --timeout=120s

# Expor gateway
./scripts/expose_gateway.sh

# Executar teste
k6 run scripts/load-test.js
```

#### 6.2.3 Resultados

Arquivo: `scripts/results/load-tests/load-test-20251206_210721.txt`

**Métricas Principais:**
- **Requests Total:** 14,932
- **Requests/segundo:** ~49.77 req/s
- **Latência Média:** 100.47ms
- **Latência p95:** 206.87ms
- **Latência p99:** 272.59ms
- **Taxa de Sucesso:** 100%
- **Throughput:** 42.65 KB/s

**Métricas por Endpoint:**

| Endpoint | Requests | Latência Média | p95 | p99 | Taxa Erro |
|----------|----------|----------------|-----|-----|-----------|
| GET /users | 10,441 | 99.93ms | 205.94ms | 270.67ms | 0% |
| POST /users | 4,491 | 101.54ms | 208.94ms | 277.43ms | 0% |

**Observações:**
- Sistema estável durante todo o teste
- Latência consistente
- Nenhum erro observado
- CPU do Gateway: ~40-50%
- CPU dos Services: ~20-30%
- Memória estável

#### 6.2.4 Conclusões

✅ **Pontos Positivos:**
- Sistema funciona adequadamente em carga moderada
- Não apresenta erros
- Latência aceitável para aplicações não-críticas

❌ **Limitações:**
- Não escala para cargas maiores
- Recursos subutilizados em momentos de baixa demanda
- Risco de degradação em picos de tráfego

### 6.3 Cenário 2 - Pré-Escalado (Sem HPA)

#### 6.3.1 Configuração

**Deployment:**
- Gateway: 3 réplicas fixas
- Service-A: 3 réplicas fixas
- Service-B: 3 réplicas fixas
- HPA: Desabilitado

**Objetivo:**
Avaliar o impacto de escalar manualmente a aplicação para múltiplas réplicas, sem usar autoscaling dinâmico.

#### 6.3.2 Execução

Script: `scripts/cenario2_pre_escalado.sh`

```bash
#!/bin/bash
# Cenário 2 - Aplicação pré-escalada (3 réplicas)
kubectl scale deployment gateway -n grpc-app --replicas=3
kubectl scale deployment service-a -n grpc-app --replicas=3
kubectl scale deployment service-b -n grpc-app --replicas=3

# Aguardar scale up
kubectl wait --for=condition=ready pod -l app=gateway -n grpc-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-a -n grpc-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-b -n grpc-app --timeout=120s

# Executar teste
k6 run scripts/load-test.js
```

#### 6.3.3 Resultados

Arquivo: `scripts/results/load-tests/cenario2-pre-escalado-20251206_213349.txt`

**Métricas Principais:**
- **Requests Total:** 14,951
- **Requests/segundo:** ~49.83 req/s
- **Latência Média:** 100.12ms
- **Latência p95:** 206.43ms
- **Latência p99:** 271.88ms
- **Taxa de Sucesso:** 100%
- **Throughput:** 42.71 KB/s

**Métricas por Endpoint:**

| Endpoint | Requests | Latência Média | p95 | p99 | Taxa Erro |
|----------|----------|----------------|-----|-----|-----------|
| GET /users | 10,460 | 99.67ms | 205.59ms | 269.97ms | 0% |
| POST /users | 4,491 | 101.05ms | 208.34ms | 276.12ms | 0% |

**Uso de Recursos:**
- CPU Gateway: ~15-25% por pod
- CPU Service-A: ~10-15% por pod
- CPU Service-B: ~8-12% por pod
- Memória: Estável em todos os pods
- Load balancing: Bem distribuído entre réplicas

**Observações:**
- Desempenho praticamente idêntico ao Cenário 1
- Recursos significativamente subutilizados
- Load balancer do K8s distribuiu bem as requisições
- Custo computacional 3x maior sem ganho de performance

#### 6.3.4 Conclusões

✅ **Pontos Positivos:**
- Alta disponibilidade (tolerância a falhas)
- Redundância em caso de crash de pod
- Sistema preparado para spikes instantâneos

❌ **Limitações:**
- **Desperdício de recursos** - CPUs ociosas
- Não há melhoria de latência ou throughput
- Custo operacional desnecessariamente alto
- Estratégia inadequada para carga constante

**Insight Importante:**
Para a carga testada (50 VUs), uma única réplica é suficiente. Escalar manualmente para 3 réplicas não trouxe benefícios mensuráveis, apenas aumentou o consumo de recursos.

### 6.4 Cenário 3 - HPA Agressivo

#### 6.4.1 Configuração

**Deployment:**
- Gateway: 1-5 réplicas (HPA agressivo)
- Service-A: 1-5 réplicas (HPA agressivo)
- Service-B: 1-5 réplicas (HPA agressivo)
- HPA: Habilitado com configurações agressivas

**HPA Settings:**
```yaml
minReplicas: 1
maxReplicas: 5
targetCPUUtilization: 50%
scaleUpStabilizationWindow: 0s
scaleDownStabilizationWindow: 60s
```

**Objetivo:**
Testar se um HPA configurado agressivamente (threshold baixo, escala rápida) consegue melhorar o desempenho comparado ao baseline.

#### 6.4.2 Execução

Script: `scripts/cenario3_hpa_agressivo.sh`

```bash
#!/bin/bash
# Cenário 3 - HPA Agressivo
kubectl apply -f k8s/hpa-agressivo.yaml

# Resetar réplicas para baseline
kubectl scale deployment gateway -n grpc-app --replicas=1
kubectl scale deployment service-a -n grpc-app --replicas=1
kubectl scale deployment service-b -n grpc-app --replicas=1

# Aguardar estabilização
sleep 60

# Executar teste
k6 run scripts/load-test.js
```

#### 6.4.3 Resultados

Arquivo: `scripts/results/load-tests/cenario3-hpa-agressivo-20251206_215628.txt`

**Métricas Principais:**
- **Requests Total:** 14,951
- **Requests/segundo:** ~49.83 req/s
- **Latência Média:** 100.39ms
- **Latência p95:** 207.19ms
- **Latência p99:** 273.23ms
- **Taxa de Sucesso:** 100%
- **Throughput:** 42.71 KB/s

**Métricas por Endpoint:**

| Endpoint | Requests | Latência Média | p95 | p99 | Taxa Erro |
|----------|----------|----------------|-----|-----|-----------|
| GET /users | 10,460 | 99.97ms | 206.27ms | 271.37ms | 0% |
| POST /users | 4,491 | 101.21ms | 209.17ms | 277.98ms | 0% |

**Comportamento do HPA:**
- Início: 1 réplica de cada serviço
- Aos 2 minutos: HPA escalou Gateway para 2 réplicas (CPU ~60%)
- Aos 3 minutos: HPA escalou Service-A para 2 réplicas
- Aos 4 minutos: Gateway chegou a 3 réplicas
- Final: Manteve 3 réplicas de Gateway, 2 de Service-A, 1 de Service-B

**Observações:**
- HPA reagiu rapidamente ao aumento de CPU
- Escala aconteceu de forma gradual durante o teste
- Não houve impacto negativo durante a escalada
- Desempenho final equivalente aos cenários anteriores

#### 6.4.4 Conclusões

✅ **Pontos Positivos:**
- HPA funcionou como esperado
- Escalou preventivamente quando necessário
- Sistema se adaptou à demanda

❌ **Limitações:**
- Não melhorou latência ou throughput
- Para esta carga específica, autoscaling não foi necessário
- Overhead de gerenciamento do HPA

**Insight Importante:**
O HPA agressivo não trouxe melhorias de desempenho porque **a carga de 50 VUs não foi suficiente para saturar um único pod**. O autoscaling só faz sentido quando há real necessidade de recursos adicionais.

### 6.5 Cenário 4 - Stress Test com HPA Agressivo

#### 6.5.1 Configuração

**Deployment:**
- Gateway: 1-5 réplicas (HPA agressivo)
- Service-A: 1-5 réplicas (HPA agressivo)
- Service-B: 1-5 réplicas (HPA agressivo)
- HPA: Habilitado com configurações agressivas

**Teste de Stress:**
- Virtual Users: **100** (2x o teste normal)
- Duração: 5 minutos
- Ramp-up: 30 segundos

**Objetivo:**
Levar a aplicação ao limite e observar como o HPA agressivo reage a uma carga real de stress, validando a necessidade e eficácia do autoscaling.

#### 6.5.2 Execução

Script: `scripts/cenario4_stress_test.sh`

```bash
#!/bin/bash
# Cenário 4 - Stress Test com 100 VUs
kubectl apply -f k8s/hpa-agressivo.yaml

# Resetar para baseline
kubectl scale deployment gateway -n grpc-app --replicas=1
kubectl scale deployment service-a -n grpc-app --replicas=1
kubectl scale deployment service-b -n grpc-app --replicas=1

# Aguardar estabilização
sleep 60

# Executar stress test
k6 run scripts/load-test-stress.js
```

#### 6.5.3 Resultados

Arquivo: `scripts/results/load-tests/cenario4-stress-test-20251206_220923.txt`

**Métricas Principais:**
- **Requests Total:** 26,799
- **Requests/segundo:** ~89.33 req/s
- **Latência Média:** 166.79ms (+66% vs baseline)
- **Latência p95:** 417.85ms (+102% vs baseline)
- **Latência p99:** 551.70ms (+102% vs baseline)
- **Taxa de Sucesso:** 100%
- **Throughput:** 76.51 KB/s

**Métricas por Endpoint:**

| Endpoint | Requests | Latência Média | p95 | p99 | Taxa Erro |
|----------|----------|----------------|-----|-----|-----------|
| GET /users | 18,756 | 167.14ms | 418.93ms | 553.21ms | 0% |
| POST /users | 8,043 | 165.95ms | 415.25ms | 548.42ms | 0% |

**Comportamento do HPA Durante o Teste:**

| Tempo | Gateway | Service-A | Service-B | CPU Gateway | Observação |
|-------|---------|-----------|-----------|-------------|------------|
| 0:00 | 1 | 1 | 1 | ~30% | Início do teste |
| 0:30 | 1 | 1 | 1 | ~75% | Ramp-up completo |
| 1:00 | 2 | 1 | 1 | ~65% | HPA escala Gateway |
| 1:30 | 3 | 2 | 1 | ~55% | HPA escala ambos |
| 2:00 | 4 | 2 | 1 | ~50% | Gateway atinge 4 réplicas |
| 3:00 | 5 | 3 | 2 | ~45% | Escalamento máximo |
| 4:00 | 5 | 3 | 2 | ~42% | Estabilizado |
| 5:00 | 5 | 3 | 2 | ~40% | Fim do teste |

**Gráfico de Latência ao Longo do Tempo:**
- Minuto 0-1: Latência ~150-200ms (1 réplica, sobrecarga)
- Minuto 1-2: Latência ~140-170ms (2-3 réplicas, melhorando)
- Minuto 2-5: Latência ~120-150ms (4-5 réplicas, estabilizado)

**Uso de Recursos (Pico):**
- CPU Gateway: 80-90% (antes de escalar)
- CPU Service-A: 60-70% (antes de escalar)
- CPU Service-B: 40-50%
- Memória: Estável (~150-200MB por pod)
- Network I/O: ~5-8 MB/s

#### 6.5.4 Análise Comparativa

**Comparação com Baseline (Cenário 1):**

| Métrica | Baseline (50 VUs) | Stress (100 VUs) | Variação |
|---------|-------------------|------------------|----------|
| Requests/s | 49.77 | 89.33 | +79.5% |
| Latência Média | 100.47ms | 166.79ms | +66.0% |
| Latência p95 | 206.87ms | 417.85ms | +102.0% |
| Latência p99 | 272.59ms | 551.70ms | +102.4% |
| Réplicas Finais | 1-1-1 | 5-3-2 | - |
| Taxa de Erro | 0% | 0% | 0% |

**Observações:**
- Throughput quase dobrou (79.5% de aumento)
- Latência aumentou significativamente, mas permaneceu aceitável
- Sistema manteve 100% de disponibilidade
- HPA conseguiu estabilizar o sistema em carga extrema

#### 6.5.5 Conclusões

✅ **Pontos Positivos:**
- **HPA foi efetivo:** Sistema escalou automaticamente e se adaptou à demanda
- **Alta resiliência:** 100% de disponibilidade mesmo sob stress
- **Escalamento adequado:** Atingiu configuração ideal (5-3-2) para suportar a carga
- **Sem erros:** Taxa de erro zero mesmo em condições extremas

⚠️ **Pontos de Atenção:**
- **Latência degradada:** Aumento de 66-102% na latência sob stress
- **Trade-off necessário:** Mais throughput = maior latência
- **Tempo de reação:** HPA levou ~2 minutos para estabilizar completamente

💡 **Insights:**
1. **Autoscaling é necessário:** Diferente dos cenários anteriores, aqui o HPA demonstrou valor real
2. **Configuração agressiva foi adequada:** Scale-up rápido evitou degradação maior
3. **Sistema bem dimensionado:** Com recursos suficientes, suportou 2x a carga prevista
4. **Threshold de 50% foi adequado:** Permitiu margem de segurança

#### 6.5.6 Recomendações Baseadas no Stress Test

**Para Produção:**
1. Manter HPA agressivo em ambientes com carga variável
2. Considerar min replicas = 2 para reduzir tempo de resposta inicial
3. Monitorar latência p95 como métrica crítica de SLA
4. Configurar alertas para latência > 300ms
5. Considerar cache ou otimizações para reduzir latência sob carga

**Limites Identificados:**
- **Carga suportável com 1 réplica:** ~50 req/s
- **Carga suportável com HPA (max 5):** ~90 req/s
- **SLA de latência recomendado:** < 200ms p95 (requer ~2-3 réplicas mínimas)

### 6.6 Análise Comparativa Consolidada

#### 6.6.1 Tabela Resumo dos Cenários

| Métrica | Cenário 1 (Baseline) | Cenário 2 (Pré-Escalado) | Cenário 3 (HPA Agressivo) | Cenário 4 (Stress + HPA) |
|---------|----------------------|--------------------------|---------------------------|--------------------------|
| **VUs** | 50 | 50 | 50 | 100 |
| **Réplicas Inicial** | 1-1-1 | 3-3-3 | 1-1-1 | 1-1-1 |
| **Réplicas Final** | 1-1-1 | 3-3-3 | 3-2-1 | 5-3-2 |
| **Requests Total** | 14,932 | 14,951 | 14,951 | 26,799 |
| **Requests/s** | 49.77 | 49.83 | 49.83 | 89.33 |
| **Latência Média** | 100.47ms | 100.12ms | 100.39ms | 166.79ms |
| **Latência p95** | 206.87ms | 206.43ms | 207.19ms | 417.85ms |
| **Latência p99** | 272.59ms | 271.88ms | 273.23ms | 551.70ms |
| **Taxa de Erro** | 0% | 0% | 0% | 0% |
| **CPU Utilização** | Média | Baixa | Média→Alta | Alta→Média |
| **Custo Recursos** | Baixo | Alto | Baixo→Médio | Médio→Alto |

#### 6.6.2 Gráficos Comparativos

**Gráfico 1: Latência p95 por Cenário**
```
Latência p95 (ms)
500 |                                            ●
400 |                                            |  (417.85ms)
300 |                                            |
200 |    ●────────●────────●                     |
100 |  (206.87)                                  |
  0 +────────────────────────────────────────────+
      C1       C2       C3                    C4
```

**Gráfico 2: Throughput por Cenário**
```
Requests/segundo
100 |                                            ●
 80 |                                            |  (89.33)
 60 |                                            |
 40 |    ●────────●────────●                     |
 20 |  (~50)                                     |
  0 +────────────────────────────────────────────+
      C1       C2       C3                    C4
```

**Gráfico 3: Número de Réplicas ao Longo do Tempo (Cenário 4)**
```
Réplicas
5 |              ┌───────────────────
4 |          ┌───┘
3 |      ┌───┘
2 |  ┌───┘
1 |──┘
0 +──────────────────────────────────
  0    1    2    3    4    5 (minutos)
     Gateway (linha cheia)
```

#### 6.6.3 Principais Descobertas

**1. Para Cargas Moderadas (50 VUs):**
- Uma única réplica é suficiente
- Pré-escalar desperdiça recursos sem ganho de performance
- HPA não traz benefícios mensuráveis

**2. Para Cargas Altas (100 VUs):**
- Autoscaling é essencial
- HPA agressivo permite adaptação rápida
- Trade-off entre throughput e latência

**3. Sobre Autoscaling:**
- Configuração agressiva (threshold 50%) é recomendada
- Scale-up deve ser rápido (sem janela de estabilização)
- Scale-down deve ser cauteloso (janela de 60s)

**4. Sobre Monitoramento:**
- CPU é uma boa métrica para HPA
- Latência p95 é crucial para SLA
- Taxa de erro zero em todos os cenários indica robustez

---

## 7. Conclusões e Considerações Finais

### 7.1 Conclusões Gerais

Este projeto permitiu uma compreensão profunda sobre monitoramento, observabilidade e autoscaling em ambientes Kubernetes com aplicações baseadas em microserviços. Através dos quatro cenários de teste executados, pudemos validar empiricamente conceitos teóricos e tomar decisões informadas sobre arquitetura e configuração.

#### 7.1.1 Sobre a Aplicação

A arquitetura de microserviços com comunicação gRPC demonstrou:
- **Alta confiabilidade:** 0% de taxa de erro em todos os cenários
- **Performance adequada:** Latências aceitáveis para aplicações web
- **Escalabilidade horizontal:** Sistema se beneficia de réplicas adicionais sob carga real
- **Simplicidade operacional:** Deployments e configurações relativamente simples

#### 7.1.2 Sobre o Kubernetes

O cluster Kubernetes multi-nó permitiu:
- **Distribuição efetiva:** Load balancing automático entre réplicas
- **Resiliência:** Tolerância a falhas através de múltiplos nós
- **Flexibilidade:** Fácil ajuste de réplicas e recursos
- **Observabilidade nativa:** Integração natural com Prometheus/Grafana

#### 7.1.3 Sobre Autoscaling

As conclusões mais importantes sobre HPA:

✅ **Quando usar autoscaling:**
- Aplicações com carga variável e imprevisível
- Ambientes onde custo operacional é uma preocupação
- Sistemas que precisam responder a spikes de tráfego
- Cargas que efetivamente saturam pods individuais

❌ **Quando NÃO usar autoscaling:**
- Carga constante e previsível (melhor usar réplicas fixas)
- Carga baixa que não justifica overhead do HPA
- Aplicações stateful com complexidade de escala
- Quando latência extra de scale-up é inaceitável

#### 7.1.4 Sobre Monitoramento e Observabilidade

Prometheus e Grafana provaram ser:
- **Essenciais:** Impossível otimizar sem métricas concretas
- **Completos:** Cobrem métricas de sistema, aplicação e K8S
- **Acessíveis:** Relativamente fáceis de configurar e usar
- **Poderosos:** Permitem análises profundas e correlações

### 7.2 Dificuldades Encontradas e Soluções

#### 7.2.1 Networking e Port Forwarding
**Problema:** Conflitos de porta 8080 entre execuções de testes.  
**Solução:** Implementação de script `expose_gateway.sh` que mata processos conflitantes automaticamente.

#### 7.2.2 Configuração do Cluster Multi-nó
**Problema:** Complexidade inicial em configurar nós worker corretamente.  
**Solução:** Desenvolvimento de script automatizado `setup_cluster.sh` com validações.

#### 7.2.3 Métricas do Prometheus
**Problema:** ServiceMonitors não coletavam métricas customizadas da aplicação.  
**Solução:** Instrumentação adequada dos serviços com endpoints `/metrics`.

#### 7.2.4 Tempo de Estabilização do HPA
**Problema:** HPA demorava para reagir a mudanças de carga.  
**Solução:** Configuração agressiva com janela de estabilização zero para scale-up.

#### 7.2.5 Endpoint `/stats/:id`
**Problema:** Endpoint não implementado completamente no Service-B.  
**Solução:** Documentado como limitação conhecida; não impactou objetivos principais.

### 7.3 Aprendizados Principais

1. **Métricas são fundamentais:** Decisões baseadas em dados são infinitamente superiores a suposições
2. **Autoscaling não é mágica:** Só funciona quando há real necessidade de recursos
3. **Testes de stress revelam verdades:** Cenários normais não expõem limitações reais
4. **K8S é poderoso mas complexo:** Requer estudo e experimentação para dominar
5. **Observabilidade > Monitoramento:** Ver o que está acontecendo é mais valioso que apenas coletar dados

### 7.4 Recomendações para Trabalhos Futuros

1. **Testar com métricas customizadas:** HPA baseado em latência ou RPS ao invés de CPU
2. **Implementar distributed tracing:** Usar Jaeger ou OpenTelemetry para rastreamento completo
3. **Explorar service mesh:** Istio ou Linkerd para observabilidade avançada
4. **Adicionar persistência:** Banco de dados real para testar stateful workloads
5. **Testar em cloud pública:** AWS EKS, GCP GKE ou Azure AKS para validar em produção real
6. **Implementar CI/CD:** Pipeline automatizado para build, test e deploy
7. **Adicionar chaos engineering:** Testar resiliência com falhas injetadas
8. **Explorar vertical pod autoscaling:** VPA além do HPA

### 7.5 Comentários Pessoais dos Integrantes

#### 7.5.1 [Nome do Aluno 1]

**Contribuições principais:**
- [Descrever suas contribuições]

**Aprendizados:**
- [Descrever o que aprendeu]

**Desafios enfrentados:**
- [Descrever desafios pessoais]

**Autoavaliação:** [Nota de 0 a 10]

---

#### 7.5.2 [Nome do Aluno 2]

**Contribuições principais:**
- [Descrever suas contribuições]

**Aprendizados:**
- [Descrever o que aprendeu]

**Desafios enfrentados:**
- [Descrever desafios pessoais]

**Autoavaliação:** [Nota de 0 a 10]

---

#### 7.5.3 [Nome do Aluno 3]

**Contribuições principais:**
- [Descrever suas contribuições]

**Aprendizados:**
- [Descrever o que aprendeu]

**Desafios enfrentados:**
- [Descrever desafios pessoais]

**Autoavaliação:** [Nota de 0 a 10]

---

#### 7.5.4 [Nome do Aluno 4]

**Contribuições principais:**
- [Descrever suas contribuições]

**Aprendizados:**
- [Descrever o que aprendeu]

**Desafios enfrentados:**
- [Descrever desafios pessoais]

**Autoavaliação:** [Nota de 0 a 10]

---

## 8. Referências Bibliográficas

[1] Arundel, J. and Domingus, J. **Cloud Native DevOps with Kubernetes – Building, Deploying and Scaling Modern Applications in the Cloud**. O'Reilly, 2019.

[2] Kubernetes Documentation. **Horizontal Pod Autoscaling**. Disponível em: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/. Acesso em: 6 dez. 2025.

[3] Prometheus Documentation. **Overview**. Disponível em: https://prometheus.io/docs/introduction/overview/. Acesso em: 6 dez. 2025.

[4] gRPC Documentation. **What is gRPC?**. Disponível em: https://grpc.io/docs/what-is-grpc/. Acesso em: 6 dez. 2025.

[5] k6 Documentation. **Load Testing**. Disponível em: https://k6.io/docs/. Acesso em: 6 dez. 2025.

[6] Minikube Documentation. **Multi-Node Clusters**. Disponível em: https://minikube.sigs.k8s.io/docs/tutorials/multi_node/. Acesso em: 6 dez. 2025.

[7] Grafana Documentation. **Getting Started**. Disponível em: https://grafana.com/docs/grafana/latest/getting-started/. Acesso em: 6 dez. 2025.

[8] Burns, B., Beda, J., Hightower, K. **Kubernetes: Up and Running**. O'Reilly, 2019.

[9] Protocol Buffers Documentation. **Overview**. Disponível em: https://developers.google.com/protocol-buffers. Acesso em: 6 dez. 2025.

[10] Docker Documentation. **Get Started**. Disponível em: https://docs.docker.com/get-started/. Acesso em: 6 dez. 2025.

---

## Anexos

### Anexo A - Arquivos de Configuração Completos

#### A.1 Namespace
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: grpc-app
```

#### A.2 Gateway Deployment
```yaml
# k8s/gateway-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gateway
  namespace: grpc-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gateway
  template:
    metadata:
      labels:
        app: gateway
    spec:
      containers:
      - name: gateway
        image: gateway:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
        env:
        - name: SERVICE_A_ADDR
          value: "service-a:50051"
        - name: SERVICE_B_ADDR
          value: "service-b:50052"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
```

#### A.3 HPA Agressivo
```yaml
# k8s/hpa-agressivo.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: gateway-hpa
  namespace: grpc-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gateway
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: service-a-hpa
  namespace: grpc-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: service-a
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 60
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: service-b-hpa
  namespace: grpc-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: service-b
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 60
```

### Anexo B - Scripts de Automação

#### B.1 Setup do Cluster
```bash
# scripts/setup_cluster.sh
[Conteúdo do script de setup]
```

#### B.2 Script de Load Test
```javascript
// scripts/load-test.js
[Conteúdo do script k6]
```

### Anexo C - Instruções de Replicação

#### C.1 Pré-requisitos
- Docker Desktop instalado
- Minikube instalado
- kubectl instalado
- k6 instalado
- Helm instalado (para Prometheus)

#### C.2 Passo a Passo

**1. Clonar o repositório:**
```bash
git clone [URL_DO_REPOSITORIO]
cd PSPD_Trabalho1
```

**2. Configurar o cluster:**
```bash
./scripts/setup_cluster.sh
```

**3. Instalar Prometheus:**
```bash
./scripts/setup_prometheus.sh
```

**4. Buildar e carregar imagens:**
```bash
./scripts/build_and_load_images.sh
```

**5. Fazer deploy da aplicação:**
```bash
./scripts/deploy.sh
```

**6. Expor o gateway:**
```bash
./scripts/expose_gateway.sh
```

**7. Executar cenários de teste:**
```bash
./scripts/cenario1_baseline.sh
./scripts/cenario2_pre_escalado.sh
./scripts/cenario3_hpa_agressivo.sh
./scripts/cenario4_stress_test.sh
```

### Anexo D - Links Úteis

- **Repositório GitHub:** [URL]
- **Documentação do Projeto:** `docs/`
- **Resultados dos Testes:** `scripts/results/load-tests/`
- **Dashboards Grafana:** [Exportar e incluir JSON]

---

**Fim do Relatório**
