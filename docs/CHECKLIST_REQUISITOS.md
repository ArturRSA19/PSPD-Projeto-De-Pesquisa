# Checklist de Requisitos do Projeto PSPD

**Data de Verificação**: 6 de dezembro de 2025  
**Documento Base**: OpenL-2512061746.md

---

## 📋 Seção 2: Requisitos para Alcançar o Objetivo Proposto

### ✅ (i) Aplicação Baseada em Microserviços

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Arquitetura baseada em gRPC | ✅ Completo | Gateway (P) + Service-A (A) + Service-B (B) |
| WEB API recebe requisições | ✅ Completo | Gateway Node.js/Express na porta 8080 |
| Módulo P interage com A e B via gRPC | ✅ Completo | Gateway faz chamadas gRPC para ambos |
| Consolidação de resultados | ✅ Completo | Endpoints retornam dados consolidados |
| Padrões gRPC implementados | ✅ Completo | Unary, Server/Client/Bi-directional Streaming |

**Observação**: Aplicação documentada em `README.md` e arquitetura descrita.

---

### ✅ (ii) Cluster Kubernetes

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Modo cluster | ✅ Completo | Minikube 3 nodes |
| 1 nó mestre (control-plane) | ✅ Completo | `minikube` node |
| Pelo menos 2 workers | ✅ Completo | `minikube-m02` e `minikube-m03` |
| Interface web de monitoramento | ✅ Completo | Kubernetes Dashboard habilitado |
| Recursos de autoscaling | ✅ Completo | HPA v2 configurado |
| Documentação dos passos | ✅ Completo | `docs/CLUSTER_SETUP.md` |
| Script automatizado | ✅ Completo | `scripts/setup_cluster.sh` |

**Observação**: Cluster criado com Minikube, documentação completa dos comandos.

---

### ✅ Prometheus Instalado

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Prometheus instalado no K8S | ✅ Completo | kube-prometheus-stack via Helm |
| Configurado para monitorar aplicação | ✅ Completo | ServiceMonitors criados |
| Documentação de instalação | ✅ Completo | `docs/PROMETHEUS_SETUP.md` |
| Coleta de métricas customizadas | ✅ Completo | prom-client (Node.js), prometheus-client (Python) |

**Observação**: Prometheus + Grafana + AlertManager instalados no namespace `monitoring`.

---

### ✅ (iii) Testes de Carga Baseados em Cenários

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Cenários previamente desenhados | ✅ Completo | 4 cenários documentados em `docs/CENARIOS_TESTE.md` |
| Ferramenta de teste de carga | ✅ Completo | k6 (escolhido e documentado) |
| Testes executados | ✅ Completo | 4 cenários completos executados |
| Resultados salvos | ✅ Completo | `scripts/results/load-tests/*.txt` |

---

## 📋 Seção 3: Metodologia para Garantir Observabilidade

### ✅ (a) Simulação de Grande Quantidade de Requisições

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Ferramenta de teste escolhida | ✅ Completo | k6 v1.4.2 |
| Critérios de escolha documentados | ✅ Completo | `docs/LOAD_TESTING.md` - justificativa |
| "Estressar" a aplicação | ✅ Completo | Cenário 4 com até 200 usuários |
| Identificar limites | ✅ Completo | Latência degrada a partir de 150+ usuários |

**Justificativa k6**: Suporte nativo a gRPC, scripting JavaScript, métricas detalhadas.

---

### ✅ (b) Configuração Base da Aplicação

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Cenário simples definido | ✅ Completo | Cenário 1: 1 réplica inicial, HPA habilitado |
| Nenhuma opção de paralelização | ✅ Completo | Início com 1 pod de cada serviço |
| Distribuição inerente ao gRPC | ✅ Completo | gRPC funciona normalmente |
| **(i) Tempo médio para requisição** | ✅ **125.98ms** | Cenário 1 baseline |
| **(ii) Máx requisições por segundo** | ✅ **111.3 req/s** | Cenário 1 baseline |

**Baseline estabelecido**: Cenário 1 com métricas claras.

---

### ✅ (c) Desenho de Cenários Variando Características

| Cenário | Variação | Status | Resultados |
|---------|----------|--------|------------|
| **Cenário 1** | Baseline (HPA normal, 1→5 réplicas) | ✅ Completo | P95: 432ms, 111 req/s |
| **Cenário 2** | Pré-escalado (3 réplicas fixas, sem HPA) | ✅ Completo | P95: 484ms, 110 req/s |
| **Cenário 3** | HPA Agressivo (30% CPU, 1→10 réplicas) | ✅ Completo | P95: 482ms, 111 req/s |
| **Cenário 4** | Stress Test (200 usuários, HPA agressivo) | ✅ Completo | P95: 2.21s, 131 req/s |

**Variações testadas**:
- ✅ Quantidade de instâncias (1 vs 3 vs 10 réplicas)
- ✅ Configuração de HPA (normal vs agressivo vs desabilitado)
- ✅ Variação da carga (10→100 vs 50→200 usuários)
- ✅ Thresholds diferentes (50% vs 30% CPU)

---

### ✅ Requisitos de Cada Teste

| Requisito | Status | Evidência |
|-----------|--------|-----------|
| Documentar atributos/métricas testados | ✅ Completo | `docs/RESULTADOS_COMPARATIVOS.md` |
| Uso do Prometheus para monitorar | ✅ Completo | ServiceMonitors ativos, métricas coletadas |
| Ferramental de teste para cargas variadas | ✅ Completo | k6 com stages diferentes por cenário |
| Mesmas condições de infraestrutura | ✅ Completo | Mesmo cluster 3 nodes, resetado entre testes |
| Teste de carga + observação + conclusões | ✅ Completo | Cada cenário com análise detalhada |

---

## 📋 Seção 4: Questões de Ordem (Entregas)

### ✅ Entregas Obrigatórias

| Item | Status | Localização |
|------|--------|-------------|
| **(i) Códigos + instruções** | ✅ Completo | Todo o repositório, READMEs em cada pasta |
| **(ii) Relatório** | 🟡 **Pendente** | Precisa escrever relatório final |
| **(iii) Vídeo gravado** | ❌ **Pendente** | 4-6 min por aluno |

---

### 📄 Estrutura do Relatório Obrigatório

| Seção | Status | Observações |
|-------|--------|-------------|
| Dados do curso/disciplina/alunos | ❌ Pendente | Criar capa |
| **Introdução** | ❌ Pendente | Visão geral do projeto |
| **Metodologia do grupo** | ❌ Pendente | Como o grupo se organizou, encontros |
| **Experiência de montagem do K8S** | ✅ Pronto | `docs/CLUSTER_SETUP.md` (adaptar) |
| **Monitoramento e observabilidade** | ✅ Pronto | `docs/PROMETHEUS_SETUP.md` (adaptar) |
| **Seção sobre a aplicação** | 🟡 Parcial | `README.md` (adaptar e expandir) |
| **Cenários de teste** | ✅ Pronto | `docs/RESULTADOS_COMPARATIVOS.md` (adaptar) |
| **Conclusão** | ❌ Pendente | Texto conclusivo + comentários pessoais |
| **Referências** | ❌ Pendente | Listar todas as fontes |
| **Anexos** | ✅ Pronto | Scripts, configs já no GitHub |

---

## ✅ Implementação Técnica Completa

### Componentes Kubernetes

| Componente | Arquivo | Status |
|------------|---------|--------|
| Namespace | `k8s/namespace.yaml` | ✅ |
| Gateway Deployment | `k8s/gateway-deployment.yaml` | ✅ |
| Gateway Service | `k8s/gateway-service.yaml` | ✅ |
| Service-A Deployment | `k8s/service-a-deployment.yaml` | ✅ |
| Service-A Service | `k8s/service-a-service.yaml` | ✅ |
| Service-B Deployment | `k8s/service-b-deployment.yaml` | ✅ |
| Service-B Service | `k8s/service-b-service.yaml` | ✅ |
| HPA Normal | `k8s/hpa.yaml` | ✅ |
| HPA Agressivo | `k8s/hpa-agressivo.yaml` | ✅ |
| ServiceMonitors | `k8s/servicemonitors.yaml` | ✅ |
| Ingress (opcional) | `k8s/ingress.yaml` | ✅ |

### Scripts de Automação

| Script | Propósito | Status |
|--------|-----------|--------|
| `setup_cluster.sh` | Criar cluster 3 nodes | ✅ |
| `setup_prometheus.sh` | Instalar Prometheus stack | ✅ |
| `build_and_load_images.sh` | Build e carregar imagens | ✅ |
| `deploy.sh` | Deploy da aplicação | ✅ |
| `expose_gateway.sh` | Expor gateway localmente | ✅ |
| `smoke_tests.sh` | Testes básicos | ✅ |
| `run_load_test.sh` | Teste de carga | ✅ |
| `cenario1_baseline.sh` | Cenário 1 | ✅ |
| `cenario2_pre_escalado.sh` | Cenário 2 | ✅ |
| `cenario3_hpa_agressivo.sh` | Cenário 3 | ✅ |
| `cenario4_stress_test.sh` | Cenário 4 | ✅ |
| `quick_compare.sh` | Script comparativo rápido | ✅ |

### Documentação

| Documento | Conteúdo | Status |
|-----------|----------|--------|
| `README.md` | Overview do projeto | ✅ |
| `STATUS.md` | Status atual | ✅ |
| `docs/CLUSTER_SETUP.md` | Setup do cluster | ✅ |
| `docs/PROMETHEUS_SETUP.md` | Setup do Prometheus | ✅ |
| `docs/LOAD_TESTING.md` | Guia de testes | ✅ |
| `docs/CENARIOS_TESTE.md` | Detalhes dos cenários | ✅ |
| `docs/RESULTADOS_COMPARATIVOS.md` | Análise completa | ✅ |
| `docs/CHECKLIST_REQUISITOS.md` | Este documento | ✅ |

---

## 🎯 Resumo do Que Está Completo

### ✅ 100% Implementado (Parte Técnica)
- ✅ Cluster Kubernetes multi-node
- ✅ Aplicação completa (Gateway + Service-A + Service-B)
- ✅ Prometheus + Grafana + métricas customizadas
- ✅ HPA configurado (normal + agressivo)
- ✅ 4 cenários de teste executados
- ✅ Resultados coletados e analisados
- ✅ Documentação técnica completa

### 🟡 Parcialmente Completo
- 🟡 Aplicação possui endpoint `/stats/:id` não implementado (Service-B)
  - Não impacta funcionamento geral
  - Documentado como problema conhecido

### ❌ Pendente (Entregáveis Finais)
- ❌ **Relatório final formatado** (estrutura do item 4 do documento)
- ❌ **Vídeo de apresentação** (4-6 min por aluno)
- ❌ **Conclusão pessoal de cada membro**
- ❌ **Autoavaliação de cada membro**

---

## 📊 Análise de Completude

### Requisitos Técnicos: **100%** ✅
- Aplicação: 100%
- Cluster: 100%
- Prometheus: 100%
- Autoscaling: 100%
- Testes: 100%

### Documentação Técnica: **100%** ✅
- Setup: 100%
- Testes: 100%
- Resultados: 100%

### Entregáveis do Projeto: **40%** 🟡
- Código/Scripts: 100% ✅
- Documentação técnica: 100% ✅
- **Relatório formal: 0%** ❌
- **Vídeo: 0%** ❌

---

## 🎬 Próximos Passos Necessários

### 1. Relatório Final (Prioridade ALTA)
- [ ] Criar estrutura do relatório conforme item 4
- [ ] Escrever Introdução
- [ ] Seção de Metodologia do grupo
- [ ] Adaptar docs técnicos para formato de relatório
- [ ] Escrever Conclusão geral
- [ ] Adicionar conclusão pessoal de cada membro
- [ ] Adicionar autoavaliação de cada membro
- [ ] Lista de Referências
- [ ] Revisão final

### 2. Vídeo (Prioridade ALTA)
- [ ] Roteiro do vídeo (4-6 min/aluno)
- [ ] Gravação individual ou coletiva
- [ ] Demonstração do sistema funcionando
- [ ] Edição final
- [ ] Upload e link no relatório

### 3. Melhorias Opcionais (Pontos Extras)
- [ ] Fix endpoint `/stats/:id` do Service-B
- [ ] Métricas adicionais (distributed tracing?)
- [ ] Dashboard customizado no Grafana
- [ ] CI/CD pipeline
- [ ] Outras ferramentas de observabilidade (Jaeger, Loki?)

---

## ✅ Pontos Fortes do Projeto

1. **Implementação técnica completa e funcional**
2. **4 cenários bem desenhados e executados**
3. **Documentação técnica extensa e detalhada**
4. **Scripts automatizados para reproduzibilidade**
5. **Análise comparativa profunda dos resultados**
6. **Cluster real multi-node (não simulado)**
7. **Métricas customizadas em todos os serviços**

---

## 🎓 Critérios de Avaliação vs. Status

### Qualidade das Entregas (20%)
- Relatório: ❌ Pendente
- Vídeo: ❌ Pendente
- Documentação técnica: ✅ Excelente

### Nível Técnico e Exploração (80%)
- Cluster K8S: ✅ **Excelente** (3 nodes, automatizado)
- Aplicação: ✅ **Excelente** (todos padrões gRPC)
- Prometheus: ✅ **Excelente** (métricas customizadas)
- Testes: ✅ **Excelente** (4 cenários + análise profunda)
- Descobertas: ✅ **Excelente** (insights valiosos sobre HPA)

**Projeção de Nota**: 
- Parte técnica: 9.5-10/10 ✅
- **Entregáveis finais: Pendente (relatório + vídeo)** ⚠️

---

## 🚀 Recomendação Imediata

**FOCAR AGORA EM**:
1. ✍️ Escrever relatório final (prioridade máxima)
2. 🎥 Gravar vídeo de apresentação
3. 📋 Conclusões pessoais de cada membro

**Projeto está tecnicamente PRONTO para entrega**, faltando apenas a formatação do relatório e vídeo.

---

**Última Atualização**: 6 de dezembro de 2025  
**Status Geral**: 🟢 Tecnicamente Completo / 🟡 Aguardando Entregáveis Finais
