# Versão REST da Aplicação

Objetivo: Servir como base para comparação de desempenho com a versão gRPC.

Estratégia simplificada:
- Replicar funcionalidades: GetUser, ListUsers, CreateUsers(bulk), GetScore.
- Implementar todos os serviços em HTTP/JSON (pode-se usar Node.js para simplicidade ou manter linguagens distintas - escolha do grupo).
- O gateway continuará existindo, mas agora chamará endpoints HTTP dos serviços A e B.

Sugestão de Endpoints REST:
| Serviço | Endpoint | Método | Descrição |
|---------|----------|--------|-----------|
| A | /users/:id | GET | Retorna usuário |
| A | /users | GET | Lista usuários |
| A | /users/bulk | POST | Cria usuários em lote |
| B | /scores/:userId?base=10 | GET | Retorna score calculado |

Ferramentas de teste de performance:
- hey (HTTP)
- ghz (gRPC)

Coleta de métricas:
- Latência média
- p95
- Requisições por segundo

Armazenar resultados em `scripts/results/` em CSV para inserir no relatório.
