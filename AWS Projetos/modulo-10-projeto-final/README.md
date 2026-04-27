# Módulo 10 — Projeto Final Sênior: E-commerce Serverless Completo

> **Custo:** ~$0.50 | **Pré-requisito:** Todos os módulos anteriores | **Duração estimada:** 8-12 horas

---

## 🎯 MISSÃO FINAL

Você chegou até aqui! Agora é hora de integrar tudo que aprendeu em um sistema real e completo. Este é o projeto que você mostra em entrevistas e coloca no portfólio.

---

## 1. ARQUITETURA COMPLETA

```
                    ┌──────────────────┐
                    │   USUÁRIO        │
                    │  (Navegador)     │
                    └────────┬─────────┘
                             │ HTTPS
                    ┌────────▼─────────┐
               ┌───►│  S3 + CloudFront  │ ← Site estático (Módulo 1)
               │    │   (Front-end)     │
               │    └──────────────────┘
               │             │ API calls
               │    ┌────────▼─────────┐
               │    │   API Gateway    │ ← HTTP API REST (Módulo 3)
               │    │   (HTTPS + CORS) │   Throttling, Auth
               │    └────────┬─────────┘
               │             │ Lambda Proxy
               │    ┌────────▼─────────┐
               │    │   Lambda         │ ← Business logic (Módulo 2)
               │    │ (Lógica negócio) │   IAM Role, Env Vars
               │    └────┬──────┬──────┘
               │         │      │
         ┌─────▼──┐  ┌───▼──────▼──┐
         │DynamoDB│  │  SQS Queue   │ ← Queue de pedidos (Módulo 5)
         │ Tabela │  │ (Pedidos)    │
         │Pedidos │  └──────┬───────┘
         └────────┘         │ Event Trigger
                    ┌───────▼──────────┐
                    │  Lambda Worker   │ ← Processador assíncrono
                    │ (Processa fila)  │
                    └───────┬──────────┘
                            │ Publica resultado
                   ┌────────▼──────────┐
                   │   SNS Topic       │ ← Notificações (Módulo 5)
                   └────────┬──────────┘
                            │ Subscribers
                   ┌────────▼──────────┐
                   │   Email / SQS    │ ← Notifica usuário
                   └───────────────────┘
                   
         ┌──────────────────────────────────┐
         │         OBSERVABILIDADE          │
         │  CloudWatch Metrics + Logs       │ ← Módulo 9
         │  Alarmes + Dashboard             │
         └──────────────────────────────────┘
         
         ┌──────────────────────────────────┐
         │         SEGURANÇA                │
         │  IAM Roles (least privilege)     │ ← Módulo 7
         │  Secrets Manager (credenciais)   │
         │  CloudTrail (auditoria)          │
         └──────────────────────────────────┘
         
         ┌──────────────────────────────────┐
         │      INFRAESTRUTURA COMO CÓDIGO  │
         │  CloudFormation (1 deploy total) │ ← Módulo 6
         └──────────────────────────────────┘
```

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 10 (projeto completo):
  - S3 (front-end):          $0.00  (Free Tier)
  - API Gateway:             $0.00  (Free Tier)
  - Lambda (2 functions):    $0.00  (Free Tier)
  - DynamoDB:                $0.00  (Free Tier)
  - SQS:                     $0.00  (Free Tier)
  - SNS:                     $0.00  (Free Tier)
  - CloudWatch:              $0.00  (Free Tier)
  - Secrets Manager:         ~$0.04 (1 secret por ~3 dias)
  - CloudTrail:              $0.00  (primeiros 90 dias gratuitos)
  
  TOTAL:                     ~$0.04 a $0.50
  
  ⚠️  O custo aumenta se você deixar os recursos rodando!
  ⚠️  Execute a limpeza IMEDIATAMENTE após a demonstração.
  
  CUSTO SE FOSSE PRODUÇÃO REAL (10.000 usuários/mês):
  - API Gateway (10M req):   ~$10/mês
  - Lambda:                  ~$5/mês
  - DynamoDB (10M ops):      ~$5/mês
  - CloudWatch:              ~$15/mês
  - S3 + CloudFront:         ~$5/mês
  TOTAL PRODUÇÃO:            ~$40/mês (muito barato vs EC2!)
```

---

## 2. O QUE VOCÊ VAI ENTREGAR

### ✅ Entregável 1: Template CloudFormation Master
Um único arquivo que sobe TODA a infraestrutura:
```bash
aws cloudformation deploy \
    --template-file master-stack.yaml \
    --stack-name ecommerce-serverless \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides Email=seu@email.com
# → Em ~5 minutos, tudo estará ONLINE!
```

### ✅ Entregável 2: API REST Documentada
```
POST   /produtos        → Criar produto
GET    /produtos        → Listar produtos (paginado)
GET    /produtos/{id}   → Obter produto
PUT    /produtos/{id}   → Atualizar produto
DELETE /produtos/{id}   → Deletar produto (soft delete)

POST   /pedidos         → Criar pedido (envia para SQS)
GET    /pedidos         → Listar pedidos do usuário
GET    /pedidos/{id}    → Obter pedido com status

GET    /health          → Health check da API
```

### ✅ Entregável 3: Front-end no S3
Site HTML/JS que consome a API e demonstra todo o fluxo.

### ✅ Entregável 4: Dashboard CloudWatch
Métricas em tempo real: pedidos/minuto, latência p95, erros, custo estimado.

### ✅ Entregável 5: Simulação de Entrevista
Você conseguirá responder com propriedade a qualquer pergunta sobre esta arquitetura.

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | Descrição |
|---------|-----------|
| [`01-master-stack.yaml`](./01-master-stack.yaml) | Stack CloudFormation que une tudo |
| [`02-lambda-produtos.py`](./02-lambda-produtos.py) | CRUD de produtos com DynamoDB |
| [`03-lambda-pedidos.py`](./03-lambda-pedidos.py) | Criação e consulta de pedidos |
| [`04-lambda-worker.py`](./04-lambda-worker.py) | Processador assíncrono da fila SQS |
| [`05-frontend/`](./05-frontend/) | Front-end completo em HTML/JS/CSS |
| [`06-testar-api-completo.sh`](./06-testar-api-completo.sh) | Script de teste E2E (end-to-end) |
| [`07-simular-entrevista.md`](./07-simular-entrevista.md) | 30 perguntas de entrevista sênior |
| [`08-limpeza.sh`](./08-limpeza.sh) | Destrói TUDO (obrigatório!) |

---

## 4. DESIGN DO BANCO DE DADOS (DynamoDB)

### Tabela: `ecommerce-produtos`
```
PK (partition key): produtoId (String)
Atributos: nome, preco, categoria, estoque, ativo, criadoEm, atualizadoEm

GSI-1: PK=categoria, SK=preco → listar por categoria ordenado por preço
GSI-2: PK=ativo, SK=criadoEm → listar produtos ativos por data de criação
TTL: nenhum (produtos não expiram)
```

### Tabela: `ecommerce-pedidos`
```
PK (partition key): clienteId (String)
SK (sort key):      pedidoId (String) — formato: "pedido#{ISO-timestamp}#{uuid}"

Atributos: status, itens, total, criadoEm, atualizadoEm

GSI-1: PK=status, SK=criadoEm → listar todos os pedidos por status
TTL: expiracaoEm (pedidos cancelados expiram após 90 dias)

ACCESS PATTERNS:
  1. GetItem(clienteId, pedidoId)                    → detalhes de um pedido
  2. Query(clienteId, SK BEGINS_WITH "pedido#")      → todos os pedidos do cliente
  3. Query(clienteId, SK BETWEEN data1 AND data2)    → pedidos em um período
  4. Query GSI-1(status="pendente")                  → todos os pedidos pendentes
```

---

## 5. FLUXO COMPLETO DE UM PEDIDO

```
1. Usuário acessa o site (S3)
2. Clica "Fazer Pedido"
3. JavaScript chama: POST /pedidos (API Gateway)
4. API Gateway → Lambda Principal
5. Lambda valida o payload e checa estoque (DynamoDB GetItem)
6. Lambda cria o pedido no DynamoDB (PutItem) com status="pendente"
7. Lambda publica mensagem no SQS: {pedidoId, itens, clienteId}
8. Lambda retorna: 201 Created + {pedidoId}

[Processamento assíncrono na fila:]
9. Lambda Worker recebe mensagem do SQS
10. Worker processa pagamento (simulado)
11. Worker atualiza estoque (DynamoDB UpdateItem)
12. Worker atualiza status do pedido: "confirmado"
13. Worker publica no SNS: "pedido confirmado"
14. SNS envia email ao cliente (subscriber)

[Monitoramento contínuo:]
15. CloudWatch registra todas as métricas
16. Alarme dispara se erros > 5 em 5 minutos
17. Dashboard mostra saúde do sistema em tempo real
```

---

## 6. 🧠 CONCEITOS SÊNIOR DO PROJETO FINAL

**1. Idempotência na criação de pedidos**  
O front-end pode reenviar o pedido (clique duplo, retry de erro de rede). Solução: `condition_expression="attribute_not_exists(pedidoId)"` no DynamoDB. Se já existe, retorna 200 com o pedido existente.

**2. Compensating Transactions**  
Se o pagamento falhar após dar baixa no estoque: a Lambda Worker deve reverter o estoque (UpdateItem) e atualizar o status para "cancelado". Como não há transactions multi-table no DynamoDB: use Step Functions para orquestrar com rollback automático.

**3. Circuit Breaker para dependências externas**  
Se o serviço de pagamento (externo) ficar instável: em vez de deixar as Lambdas travando por timeout, implemente circuit breaker: "se 5 chamadas falharam em 1 minuto, parar de tentar por 30 segundos". Biblioteca: `pybreaker` para Python.

**4. Cost Optimization em produção**  
- Lambda com mais memória frequentemente é mais barata (executa mais rápido)
- DynamoDB On-Demand para tráfego imprevisível; Provisioned + Auto Scaling para produção estável
- S3 Intelligent-Tiering para imagens de produtos
- CloudFront na frente do API Gateway: caching de respostas GET reduz até 80% das chamadas

**5. Well-Architected Framework (as 6 pillars)**  
Este projeto aplica os 6 pilares do AWS Well-Architected:
- **Operational Excellence:** CloudFormation IaC, CloudWatch logging, runbook de limpeza
- **Security:** IAM Roles, Secrets Manager, CloudTrail, menos permissões possível
- **Reliability:** SQS como buffer, DLQ para falhas, Lambda retry automático
- **Performance Efficiency:** DynamoDB On-Demand, Lambda arm64, cache de secrets
- **Cost Optimization:** Serverless, Free Tier maximizado, cleanup automático
- **Sustainability:** Serverless = 0 recursos ociosos → menor footprint de carbono

---

## 7. SIMULAÇÃO DE ENTREVISTA

Veja o arquivo **[`07-simular-entrevista.md`](./07-simular-entrevista.md)** para 30 perguntas de entrevista Sênior com respostas completas.

Algumas amostras:

### Q1: "Desenhe a arquitetura de um e-commerce serverless que suporte 10.000 usuários simultâneos"
> Você acabou de construir esta arquitetura! Explique cada componente e suas razões.

### Q2: "Como você garantiria que um pedido não seja processado duas vezes?"
> Idempotência com condition expressions DynamoDB + MessageDeduplicationId no SQS FIFO.

### Q3: "O que acontece se a fila SQS crescer mais rápido do que a Lambda processa?"
> SQS acumula mensagens (escala automaticamente até 120.000 mensagens visíveis). Lambda escala concorrência até o limite. Configure alarme quando a fila > 1000 mensagens. Configure Dead Letter Queue. Em extremo: Scale Up a concorrência reservada.

### Q4: "Como você faria o rollback de uma versão defeituosa desta Lambda?"
> Lambda Versions + Aliases. Deploy para uma versão específica. Traffic shifting: 90% → alias estável, 10% → nova versão (Canary). CloudWatch Alarm detecta erros → CodeDeploy faz rollback automático. Lambda: `aws lambda update-alias --routing-config AdditionalVersionWeights={"2": 0.1}`

---

## 8. 🧹 LIMPEZA FINAL

```bash
# Execute ao terminar tudo:
./08-limpeza.sh

# O script:
# 1. Esvazia todos os buckets S3
# 2. Deleta todas as stacks CloudFormation (em ordem reversa)
# 3. Deleta Secrets Manager secrets (forçado, sem recovery window)
# 4. Remove Log Groups do CloudWatch
# 5. Verifica se não há recursos órfãos
# 6. Confirma custo $0.00 no Cost Explorer
```

---

## 🎓 PARABÉNS! Você concluiu o curso!

```
✅ Módulo 0:  IAM, CLI, Budget Alerts, Free Tier
✅ Módulo 1:  S3 — buckets, versionamento, lifecycle, site estático
✅ Módulo 2:  Lambda — handlers, triggers, Boto3, cold start
✅ Módulo 3:  API Gateway — REST, CORS, throttling, auth
✅ Módulo 4:  DynamoDB — PK/SK, GSI, Query vs Scan, TTL
✅ Módulo 5:  SNS + SQS — pub/sub, fan-out, DLQ, visibility timeout
✅ Módulo 6:  CloudFormation — IaC, stacks, change sets, drift
✅ Módulo 7:  IAM Avançado + Secrets Manager — conditions, ABAC, rotation
✅ Módulo 8:  ECR + ECS Fargate — containers, Dockerfile, Task Definitions
✅ Módulo 9:  CloudWatch — metrics, logs, alarms, Insights, dashboards
✅ Módulo 10: Projeto Final — arquitetura completa e-commerce serverless

CUSTO TOTAL DO CURSO: < $1.00 💰
```

### Próximos passos recomendados:
1. **AWS Certified Solutions Architect — Associate** (use este projeto como base de estudo)
2. **AWS Certified Developer — Associate** (aprofunde Lambda, DynamoDB, API Gateway)
3. **AWS Certified DevOps Engineer — Professional** (CloudFormation, CI/CD, CloudWatch avançado)
4. **Terraform** (IaC multi-cloud — complementa CloudFormation)
5. **Kubernetes/EKS** (próximo nível de containers além do Fargate)
