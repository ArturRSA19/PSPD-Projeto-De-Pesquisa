# Projeto de Pesquisa PSPD - Monitoramento e Observabilidade em Clusters Kubernetes

## Integrantes
- **Artur Rodrigues Sousa Alves** - 211043638
- **Guilherme Soares Rocha** - 211039789  
- **Pedro Augusto Dourado Izarias** - 200062620

## Objetivo do Projeto de Pesquisa
Este projeto explora **estratégias de monitoramento e observabilidade** de aplicações baseadas em microserviços em ambiente Kubernetes, com foco em métricas de desempenho. O objetivo é compreender como aplicações containerizadas se adaptam a diferentes demandas de uso através de mecanismos de elasticidade e autoscaling.

## Aplicação Base - Arquitetura gRPC
A pesquisa utiliza uma aplicação distribuída baseada nos módulos colaborativos P-A-B:

- **P (Gateway/WEB API)**: Node.js + Express + Cliente gRPC
- **A (Serviço de Usuários)**: Python gRPC Server  
- **B (Serviço de Estatísticas)**: Go gRPC Server

### Fluxo de Requisições
1. **Entrada**: Requisições HTTP chegam ao módulo P (Gateway)
2. **Processamento**: Interação colaborativa entre P → A e P → B via gRPC
3. **Consolidação**: Resultado final baseado na combinação das interações gRPC

### Padrões gRPC Implementados
| Padrão | Método | Serviço | Descrição |
|--------|--------|---------|-----------|
| Unary | GetUser | UserService (A) | Retorna um usuário pelo ID |
| Server Streaming | ListUsers | UserService (A) | Envia lista de usuários em fluxo |
| Client Streaming | CreateUsers | UserService (A) | Envia vários usuários e recebe resumo |
| Bidirectional Streaming | UserChat | UserService (A) | Canal de chat multi-cliente |
| Unary | GetScore | StatsService (B) | Calcula/retorna score de um usuário |
| Bidirectional Streaming | StreamScores | StatsService (B) | Cálculo incremental de métricas |

## Infraestrutura de Pesquisa

### Cluster Kubernetes Multi-Node
- **Topologia**: 1 nó control-plane + 2 worker nodes (Minikube)
- **Interface Web**: Dashboard Kubernetes habilitado
- **Autoscaling**: HPA (Horizontal Pod Autoscaler) configurado
- **Métricas**: Metrics Server habilitado

### Stack de Monitoramento e Observabilidade
- **Prometheus**: Coleta de métricas personalizadas e do sistema
- **Grafana**: Visualização de dashboards e alertas
- **ServiceMonitors**: Configuração automática de targets
- **Métricas Expostas**:
  - HTTP: `http_requests_total`, `http_request_duration_seconds`
  - gRPC: `grpc_requests_total`, `grpc_request_duration_seconds`
  - Sistema: CPU, Memória, Network, Pods, Réplicas

### Ferramenta de Teste de Carga
- **k6**: Ferramenta escolhida para stress testing
- **Cenários**: 4 cenários comparativos de performance
- **Métricas Avaliadas**: Latência, Throughput, Escalabilidade, Uso de recursos

## Metodologia de Pesquisa

### Cenários de Teste Implementados
1. **Baseline (HPA Normal)**: Configuração base com autoscaling padrão
2. **Pré-escalado**: Comparação com réplicas fixas vs autoscaling
3. **HPA Agressivo**: Thresholds mais baixos para escalamento rápido
4. **Stress Test**: Identificação de limites máximos do sistema

### Resultados da Pesquisa
- **Performance Ótima**: HPA Normal (111 req/s, 432ms P95)
- **Descoberta**: Autoscaling superou pré-escalamento fixo
- **Limite Testado**: 200 usuários simultâneos (0% erros, latência degradada)
- **Recomendação**: HPA CPU 50%, 2-5 réplicas para produção

## Estrutura do Projeto de Pesquisa

```
📁 PSPD-Projeto-De-Pesquisa/
├── 📄 README.md                       # Visão geral do projeto de pesquisa
├── 📄 Relatorio.md                    # Relatório principal da pesquisa
│
├── 📁 Assets/                         # Screenshots e evidências visuais
│
├── 📁 k8s/                            # Manifests Kubernetes
│
├── 📁 scripts/                        # Automações da pesquisa
│
├── 📁 gateway-node/                   # Módulo P (Gateway HTTP → gRPC)
│
├── 📁 service-a-python/               # Módulo A (gRPC Users Python)
│
├── 📁 service-b-go/                   # Módulo B (gRPC Stats Go)
│
├── 📁 proto/                          # Contratos gRPC
│
└── 📁 rest-version/                   # Versão alternativa REST
    ├── README.md                      # Documentação REST
    ├── service-a-rest/                # Service A em REST (Python)
    └── service-b-rest/                # Service B em REST (Go)
```

## Reprodução da Pesquisa
### Pré-requisitos de Software
- **Minikube** ≥ v1.31.2
- **Kubernetes** ≥ v1.28.3  
- **Docker** ≥ 24.0.6
- **kubectl** (cliente Kubernetes)
- **k6** (ferramenta de teste de carga)
- **Node.js** 20.x LTS, **Python** ≥ 3.10, **Go** ≥ 1.22

### Setup Completo da Pesquisa

#### 1. Preparação do Cluster Multi-Node
```bash
# Criar cluster com 1 control-plane + 2 workers
./scripts/setup_cluster.sh

# Verificar nodes criados
kubectl get nodes
```

#### 2. Instalação do Stack de Observabilidade
```bash
# Instalar Prometheus + Grafana
./scripts/setup_prometheus.sh

# Verificar instalação
kubectl get pods -n monitoring
```

#### 3. Deploy da Aplicação de Pesquisa
```bash
# Build e load das imagens no Minikube
./scripts/build_and_load_images.sh

# Deploy completo dos serviços com métricas
./scripts/deploy.sh

# Verificar pods rodando
kubectl get pods,svc -n pspd-lab
```

#### 4. Execução dos Cenários de Teste

```bash
# Terminal 1: Expor gateway localmente
./scripts/expose_gateway.sh

# Terminal 2: Executar cenários de teste
./scripts/run_load_test.sh

# Terminal 3: Monitorar HPA em tempo real
watch -n 5 'kubectl get hpa -n pspd-lab'
```

#### 5. Acessar Dashboards de Monitoramento

```bash
# Prometheus (métricas)
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Acesse: http://localhost:9090

# Grafana (dashboards)  
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Acesse: http://localhost:3000 (admin/admin)
```

### Execução Local (Desenvolvimento)
Para desenvolvimento e testes locais da aplicação base:
```bash
# Iniciar todos os serviços localmente
./scripts/run_all_local.sh

# Ou manualmente:
# Terminal 1: Service A (Python)
cd service-a-python && python server.py

# Terminal 2: Service B (Go)  
cd service-b-go && go run server.go

# Terminal 3: Gateway (Node.js)
cd gateway-node && npm start
```

**Acessar aplicação**: http://localhost:8080

**Teste rápido**: `./scripts/smoke_tests.sh`

## Documentação da Pesquisa

### Arquivo Principal
- **[`RELATORIO.md`](RELATORIO.md)**: Relatório completo da pesquisa

### Scripts de Automação
- **Setup**: `setup_cluster.sh`, `setup_prometheus.sh`
- **Build/Deploy**: `build_and_load_images.sh`, `deploy.sh`
- **Testes**: `run_load_test.sh`, `smoke_tests.sh`
- **Monitoramento**: `expose_gateway.sh`

## Principais Descobertas da Pesquisa

### 🏆 Configuração Recomendada
- **HPA Normal**: CPU 50%, Memory 70%
- **Réplicas**: Min 2, Max 5
- **Carga Sustentável**: 80-100 usuários simultâneos
- **Throughput Esperado**: ~110 req/s

### 📊 Resultados Comparativos

| Cenário | Throughput | Latência P95 | Escalabilidade | Eficiência |
|---------|------------|--------------|----------------|------------|
| **Baseline (HPA)** | 111 req/s | **432ms** 🏆 | Dinâmica | **Alta** 🏆 |
| Pré-escalado | 110 req/s | 484ms | Fixa | Baixa |
| HPA Agressivo | 111 req/s | 482ms | Excessiva | Média |
| **Stress Test** | **131 req/s** 🏆 | 2,210ms ⚠️ | Máxima | Degradada |

### 🔍 Insights Principais
1. **Autoscaling > Pré-escalamento**: HPA dinâmico superou réplicas fixas
2. **Conservador > Agressivo**: HPA 50% CPU mais eficiente que 30%
3. **Gateway = Gargalo**: Componente que mais escala (até 10 réplicas)
4. **Sistema Resiliente**: 0% erros até 200 usuários simultâneos

## Referências e Documentação

### Tecnologias Utilizadas
- **Kubernetes**: [kubernetes.io](https://kubernetes.io)
- **Prometheus**: [prometheus.io](https://prometheus.io)
- **Grafana**: [grafana.com](https://grafana.com)
- **k6**: [k6.io](https://k6.io)
- **gRPC**: [grpc.io](https://grpc.io)

### Recursos do Projeto
- **Repositório**: GitHub - PSPD-Projeto-De-Pesquisa
- **Scripts**: Diretório [`scripts/`](scripts/)
- **Manifests K8s**: Diretório [`k8s/`](k8s/)


