# Roteiro Pessoa 3 - Kubernetes e Comparativo Performance (3,5 minutos)

## Introdução Pessoal (15 segundos)
"Boa noite, eu sou o guilherme soares, e agora vou mostrar como a gente fez o deploy de toda essa aplicação no Kubernetes e os resultados dos nossos testes de performance comparando gRPC com REST. Vamos demonstrar a aplicação rodando em containers e discutir quando usar cada tecnologia."

---

## 1. Deploy em Kubernetes (2 minutos)

### Conceitos e Arquitetura Kubernetes (45 segundos)
"Primeiro, deixa eu explicar rapidamente como organizamos tudo no Kubernetes. A gente usou o Minikube, que é uma versão simplificada do Kubernetes que roda em uma máquina só, perfeita pra desenvolvimento e testes. No Kubernetes tudo funciona com alguns conceitos básicos: os Pods são onde nossos containers rodam, os Services fazem a comunicação entre os pods, e os Deployments garantem que os pods estejam sempre funcionando. A gente criou um namespace chamado 'pspd-lab' pra organizar tudo e evitar conflitos."

### Estrutura dos Manifests (30 segundos)
"Criamos manifests YAML pra cada componente: três Deployments - um pro Gateway, um pro Service A em Python, e um pro Service B em Go. Cada deployment tem seu Service correspondente, onde os serviços A e B usam ClusterIP pra comunicação interna, e o Gateway usa NodePort pra permitir acesso externo. Também configuramos um Ingress opcional pra ter URLs mais amigáveis."

### Demonstração do Deploy (45 segundos)
"Agora vou mostrar isso funcionando. Primeiro vou verificar se o Minikube está rodando e depois aplicar os manifests."

**[DEMONSTRAÇÃO: Terminal com comandos Kubernetes]**

"Vou verificar o status do cluster..."
```bash
minikube status
```
<!-- 
"Agora vou aplicar todos os manifests de uma vez..."
```bash
kubectl apply -f k8s/
``` -->

<!-- "E aqui vocês podem ver todos os pods e services rodando no nosso namespace..."
```bash
kubectl get pods,svc -n pspd-lab
``` -->

"Vou abrir a aplicação através do Minikube..."
```bash
minikube service gateway -n pspd-lab
```

"E aqui temos nossa aplicação rodando completamente em containers Kubernetes, com os mesmos padrões gRPC que o Pedro demonstrou, mas agora em um ambiente distribuído real."

---

## 2. Comparativo gRPC vs REST (1 minuto e 20 segundos)

### Metodologia do Teste (30 segundos)
"Agora vou mostrar os resultados do nosso comparativo de performance. A gente implementou uma versão REST da mesma aplicação - o Service A em FastAPI Python e o Service B em Go - mantendo exatamente as mesmas funcionalidades. Rodamos 40 requisições de cada tipo em ambiente local, medindo tempo médio e tempo mínimo pra ter uma comparação justa."

### Resultados e Análise (35 segundos)
"Os resultados foram bem interessantes e talvez surpreendentes. Pro GetUser, gRPC ficou em 38.73ms contra 38.12ms do REST - praticamente idêntico. Pro GetScore, gRPC ficou em 37.92ms contra 37.33ms do REST - novamente muito próximo. A diferença foi mínima, menos de 1ms em média. Isso mostra que pra operações simples como essas, a vantagem do gRPC não está na velocidade bruta, mas em outras características."

### Quando Usar Cada Tecnologia (15 segundos)
"Então quando usar gRPC? Ele brilha em cenários com streaming, contratos tipados, comunicação entre microserviços, e quando você precisa de alta performance com grandes volumes. REST continua sendo ideal pra APIs públicas, prototipagem rápida, e quando você precisa de simplicidade e debugging fácil."

---

## 3. Demonstração Final no Kubernetes (10 segundos)

**[DEMONSTRAÇÃO: Testar aplicação via Kubernetes]**
"Pra finalizar, vou fazer um teste rápido na aplicação rodando no Kubernetes pra mostrar que tudo funciona perfeitamente em ambiente containerizado."

---

## Conclusão da Apresentação (15 segundos)
"Então a gente conseguiu implementar com sucesso todos os padrões gRPC, fazer o deploy no Kubernetes, e descobrir que gRPC e REST têm performance similar pra operações simples. A escolha entre eles depende mais do contexto: gRPC pra sistemas distribuídos complexos, REST pra simplicidade e APIs públicas. Foi um projeto muito legal que mostrou na prática como funciona desenvolvimento de microserviços modernos."

---
```
"Este projeto nos ensinou muito sobre sistemas distribuídos modernos. Aprendemos gRPC na 
prática, arquitetura de microserviços, containerização, e orquestração com Kubernetes. 
O mais interessante foi descobrir que a escolha entre gRPC e REST não é só sobre performance, 
mas sobre contexto de uso. Agradecemos a oportunidade e ficamos à disposição para perguntas!"
```

## DICAS PARA APRESENTAÇÃO:

### Preparação antes da gravação:
```bash
# Verificar se Minikube está funcionando
minikube status

# Se não estiver, iniciar
minikube start

# Verificar se os manifests estão aplicados
kubectl get pods,svc -n pspd-lab

# Se não estiverem, aplicar
kubectl apply -f k8s/

# Ter resultados do benchmark prontos
./scripts/quick_compare.sh
```

### O que mostrar na tela:
1. **Terminal com comandos kubectl** - mostrando pods e services
2. **Browser com aplicação via Minikube** - demonstrando que funciona
3. **Resultados do benchmark** - tabela com tempos
4. **Manifests YAML** (opcional) - estrutura dos deployments

### Timing sugerido:
- **0:00-0:15**: Introdução pessoal
- **0:15-2:15**: Deploy Kubernetes (conceitos + demo)
- **2:15-3:35**: Comparativo performance (metodologia + resultados + análise)
- **3:35-3:45**: Demo final Kubernetes
- **3:45-4:00**: Conclusão

### Comandos essenciais a ter prontos:
```bash
# Status do cluster
minikube status

# Aplicar manifests
kubectl apply -f k8s/

# Verificar recursos
kubectl get pods,svc -n pspd-lab

# Abrir aplicação
minikube service gateway -n pspd-lab

# Benchmark (se quiser mostrar rodando)
./scripts/quick_compare.sh
```

### Pontos importantes a enfatizar:
- **Facilidade do Kubernetes**: Manifests simples, deploy automatizado
- **Isolamento e escalabilidade**: Cada serviço em seu container
- **Performance equivalente**: gRPC vs REST pra operações simples
- **Contexto de escolha**: Quando usar cada tecnologia
- **Projeto completo**: Do desenvolvimento ao deploy em produção

### Se algo der errado:
- Tenha screenshots dos pods rodando
- Tenha os resultados do benchmark salvos
- Pratique os comandos kubectl antes de gravar
- Tenha um plano B com aplicação local se Kubernetes falhar
