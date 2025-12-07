# Configuração do Cluster Kubernetes Multi-Node

## Requisitos do Projeto
Conforme especificação do documento, o cluster deve ter:
- **1 nó mestre (control-plane)**
- **Pelo menos 2 nós workers**
- **Interface web de monitoramento**
- **Recursos de autoscaling**

## Ferramentas Utilizadas
- **Minikube v1.37.0**: Ferramenta para executar cluster Kubernetes localmente
- **Docker**: Driver para os containers do Minikube
- **kubectl**: CLI para interagir com o cluster Kubernetes

## Passo 1: Limpeza (se necessário)

Se você já tem um cluster Minikube rodando, delete-o primeiro:

```bash
minikube delete
```

## Passo 2: Criar Cluster Multi-Node

Execute o comando para criar um cluster com 3 nós (1 control-plane + 2 workers):

```bash
minikube start \
  --nodes 3 \
  --cpus 2 \
  --memory 4096 \
  --driver docker \
  --kubernetes-version stable
```

**Parâmetros explicados:**
- `--nodes 3`: Cria 3 nós no total
- `--cpus 2`: Aloca 2 CPUs por nó
- `--memory 4096`: Aloca 4GB RAM por nó
- `--driver docker`: Usa Docker como driver (containers)
- `--kubernetes-version stable`: Usa a versão estável mais recente do K8s

⏱️ **Tempo estimado**: 5-10 minutos

## Passo 3: Verificar o Cluster

Após a criação, verifique os nós:

```bash
# Ver status do Minikube
minikube status

# Ver os nós do cluster
kubectl get nodes

# Ver detalhes dos nós
kubectl get nodes -o wide
```

**Saída esperada:**
```
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   5m    v1.34.0
minikube-m02   Ready    <none>          4m    v1.34.0
minikube-m03   Ready    <none>          3m    v1.34.0
```

## Passo 4: Habilitar Addons Necessários

### 4.1 Dashboard (Interface Web)

```bash
# Habilitar o Dashboard do Kubernetes
minikube addons enable dashboard

# Habilitar métricas (necessário para HPA)
minikube addons enable metrics-server
```

### 4.2 Verificar Addons Habilitados

```bash
minikube addons list
```

## Passo 5: Acessar o Dashboard

Para abrir a interface web de monitoramento:

```bash
# Abre o dashboard no navegador
minikube dashboard
```

Ou para obter apenas a URL:

```bash
minikube dashboard --url
```

## Passo 6: Configurar Context do kubectl

Certifique-se de que o kubectl está apontando para o cluster correto:

```bash
# Ver contexto atual
kubectl config current-context

# Deve mostrar: minikube
```

## Verificações de Sanidade

Execute estes comandos para validar o cluster:

```bash
# 1. Verificar nós
kubectl get nodes

# 2. Verificar namespaces
kubectl get namespaces

# 3. Verificar pods do sistema
kubectl get pods -n kube-system

# 4. Verificar metrics-server
kubectl top nodes
```

## Comandos Úteis

```bash
# Pausar o cluster (economiza recursos)
minikube pause

# Retomar o cluster
minikube unpause

# Ver logs de um nó específico
minikube logs -n minikube-m02

# SSH em um nó
minikube ssh -n minikube-m02

# Parar o cluster
minikube stop

# Deletar o cluster
minikube delete
```

## Troubleshooting

### Problema: Cluster não inicia
```bash
# Ver logs detalhados
minikube start --nodes 3 -v=7

# Ou tentar com menos recursos
minikube start --nodes 3 --cpus 1 --memory 2048
```

### Problema: Metrics não funcionam
```bash
# Reinstalar metrics-server
minikube addons disable metrics-server
minikube addons enable metrics-server

# Aguardar 1-2 minutos e testar
kubectl top nodes
```

### Problema: Docker não conecta
```bash
# Certificar que Docker Desktop está rodando
docker ps

# Verificar driver do Minikube
minikube config set driver docker
```

## Arquitetura do Cluster

```
┌─────────────────────────────────────────────┐
│         Minikube Cluster (Multi-Node)       │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────┐                          │
│  │  minikube    │  Control Plane           │
│  │  (master)    │  - API Server            │
│  │              │  - Scheduler             │
│  │              │  - Controller Manager    │
│  └──────────────┘  - etcd                  │
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │ minikube-m02 │  │ minikube-m03 │        │
│  │  (worker-1)  │  │  (worker-2)  │        │
│  │              │  │              │        │
│  │  - Pods      │  │  - Pods      │        │
│  │  - Kubelet   │  │  - Kubelet   │        │
│  └──────────────┘  └──────────────┘        │
│                                             │
└─────────────────────────────────────────────┘
```

## Próximos Passos

✅ Cluster multi-node configurado  
⬜ Deploy da aplicação no cluster  
⬜ Configurar Prometheus  
⬜ Configurar HPA (Horizontal Pod Autoscaler)  
⬜ Testes de carga  

## Referências

- [Documentação Minikube Multi-Node](https://minikube.sigs.k8s.io/docs/tutorials/multi_node/)
- [Minikube Addons](https://minikube.sigs.k8s.io/docs/handbook/addons/)
- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
