# 📋 Simulação de Entrevista Sênior AWS

> **Para usar:** Peça a alguém para te perguntar. Responda sem olhar.
> Depois compare com a resposta esperada.
> Se você conseguir responder com confiança: você está pronto!

---

## Bloco 1: Fundamentos e Arquitetura

### Q01: "Por que usar arquitetura serverless em vez de EC2 para uma startup?"
**Resposta esperada:**
- **Custo:** EC2 cobra por hora mesmo sem requisições. Serverless cobra por execução real.
- **Operação:** Sem gerenciamento de SO, patches, scaling manual, alta disponibilidade manual.
- **Time-to-market:** Foco no produto, não em infraestrutura.
- **Escalabilidade:** Lambda/DynamoDB escalam automaticamente de 0 a milhões de requests.
- **Quando NÃO usar:** Processos longos (>15min), alta CPU constante, custo previsível alto — nestes casos EC2/ECS pode ser mais econômico.

---

### Q02: "Você criaria um único bucket S3 para todos os dados ou um por serviço?"
**Resposta esperada:**
- **Um bucket por "domínio" ou por "conta AWS"** — não um único para tudo, mas tampoco excessivo.
- Por domínio: `uploads-usuarios`, `assets-estaticos`, `logs-auditoria`, `backups`
- Razões: políticas IAM granulares por bucket, facilidade de auditoria, limites de API por bucket, cost allocation tags por bucket.
- Em multi-conta: um bucket de logs centralizado na conta de segurança.
- Nunca: tudo no mesmo bucket sem prefixos claros (problema de IAM e auditoria).

---

### Q03: "O que é o princípio CAP theorem e como o DynamoDB se posiciona?"
**Resposta esperada:**
- CAP theorem: em um sistema distribuído, você pode garantir apenas 2 de 3: **C**onsistência, **A**vailability, **P**artition tolerance.
- DynamoDB escolheu **AP** (Available + Partition Tolerant) no modo padrão — eventual consistency.
- Oferece **Strong Consistency** opcional (CP) com ConsistentRead=true, mas a custo de 2x mais RCU e maior latência.
- Global Tables: eventually consistent entre regiões (AP global).
- Para casos onde consistência é crítica (saldo bancário): DynamoDB Transactions (ACID dentro de uma conta/região).

---

## Bloco 2: Lambda e API Gateway

### Q04: "Como você gerenciaria 1 Lambda com 50 endpoints vs 50 Lambdas?"
**Resposta esperada:**
- **1 Lambda monolítica:** mais simples, deployment unificado, mais risco (1 bug afeta tudo), cold start maior (mais código).
- **Muitas Lambdas granulares:** isolamento, deployment independente, cold starts independentes, custo/complexidade maior de gerenciar.
- **Recomendação Senior:** Começar com 1 Lambda por "domínio" (produtos, pedidos, usuários) — nem monolito total, nem microserviço extremo. Evoluir conforme o sistema cresce.
- Ferramentas: Serverless Framework, AWS SAM, ou CDK para gerenciar múltiplas Lambdas.

---

### Q05: "O que acontece se você não configurar um Dead Letter Queue (DLQ) na Lambda?"
**Resposta esperada:**
- Em invocações **síncronas** (API Gateway): erros são retornados imediatamente ao cliente. Sem DLQ relevante.
- Em invocações **assíncronas** (S3 trigger, SNS): Lambda tenta 3 vezes (2 retries). Após isso: **o evento é SILENCIOSAMENTE DESCARTADO**.
- Isso é perigoso: você perde dados sem saber. Um arquivo S3 processado com erro → ficheiro processado zero vezes → dados perdidos.
- **Solução:** Configure DLQ (SQS) para invocações assíncronas. Configure alarme CloudWatch quando a DLQ tiver mensagens.

---

### Q06: "Qual a diferença de custo entre REST API e HTTP API no API Gateway?"
**Resposta:**
- REST API: $3.50/M chamadas (us-east-1)
- HTTP API: $1.00/M chamadas — 71% mais barata
- Para 10M req/mês: REST = $35/mês; HTTP = $10/mês
- **Quando usar REST API:** WAF integration, Usage Plans, API Keys, Request/Response Transformation, Private APIs (VPC), X-Ray Tracing nativo.
- **Quando usar HTTP API:** 80% dos casos — menor latência também (~60% menos).

---

## Bloco 3: DynamoDB

### Q07: "Como você modelaria uma tabela para um sistema de blog com posts e comentários?"
**Resposta esperada:**
```
Tabela: blog
PK: EntityType#Id      SK: EntityType#Id#SubId

Exemplos:
  PK=POST#blog-001     SK=METADATA              → dados do post
  PK=POST#blog-001     SK=COMMENT#2024#comm-01  → comentário do post (ordenado por data)
  PK=AUTHOR#john       SK=POST#2024-01-15        → posts por autor (GSI)
  
GSI1: PK=status (publicado/rascunho), SK=criadoEm  → listar por status e data

Access patterns:
  GetItem(POST#blog-001, METADATA) → detalhes do post
  Query(POST#blog-001, SK BEGINS_WITH "COMMENT#") → todos os comentários
  Query GSI1(publicado, SK > data) → posts publicados paginados
```
Isso é **Single Table Design** — padrão avançado que evita JOINs e maximiza performance.

---

### Q08: "Quando você usaria DynamoDB TTL vs um Lambda scheduled para deletar dados?"
**Resposta esperada:**
- **TTL:** grátis, automático, aproximado (pode demorar 48h após expiração), sem impacto em WCU/RCU. Use para: sessões de usuário, tokens temporários, cache, dados que podem ser deletados com delay.
- **Lambda scheduled:** preciso, pode fazer lógica adicional (enviar email antes de deletar), mais custo (Lambda + EventBridge). Use para: compliance (log de auditoria antes de deletar), notificação ao usuário, cleanup específico de negócio.
- **Na prática:** TTL para dados de sessão/cache/tokens. Lambda para compliance/negócio.

---

## Bloco 4: Segurança

### Q09: "Como você detectaria se alguém está usando suas credenciais AWS roubadas?"
**Resposta:**
- **CloudTrail:** registra toda chamada de API. Configurar alarme para: logins de regiões não usadas, criação de novos usuários IAM, mudanças de políticas, chamadas a regiões inesperadas.
- **AWS GuardDuty:** ML que detecta automaticamente: comportamento anômalo, coin mining, exfiltração de dados, acesso de IPs maliciosos.
- **IAM Access Analyzer:** identifica recursos expostos publicamente inesperadamente.
- **AWS Config:** detecta mudanças de configuração não autorizadas.
- **Ação imediata:** CreateAccessKey em horário suspeito → alarme → revogar chave automaticamente via Lambda.

---

### Q10: "Explique cross-account access no IAM com exemplo."
**Resposta esperada:**
- **Cenário:** Conta A (dev) precisa ler de um bucket S3 na Conta B (prod-logs).
- **Solução:**
  1. Na Conta B: crie uma Role com Trust Policy que permite que a Conta A assuma (`sts:AssumeRole`);
  2. Na política da Role: permissões necessárias (ex: `s3:GetObject`);
  3. Na Conta A: a Lambda/usuário chama `sts:AssumeRole` com o ARN da Conta B;
  4. Recebe credenciais temporárias (15min a 12h);
  5. Usa essas credenciais para acessar o S3 da Conta B.
- **Use cases:** Conta central de logs que recebe logs de todas as contas. Conta de ferramentas (CI/CD) que faz deploy em múltiplas contas. Audit account que lê CloudTrail de todas as contas.

---

## Bloco 5: Observabilidade e Operações

### Q11: "Um cliente reclama que a API ficou lenta por 10 minutos ontem às 15h. Como você investigaria?"
**Resposta:**
1. **CloudWatch Metrics:** API Gateway Latency e Lambda Duration para janela das 14h50-15h10.
2. **CloudWatch Insights:** `stats avg(@duration), percentile(@duration, 99) by bin(1m)` — identifica onde estava a latência.
3. **CloudWatch Insights Lambda:** filtro por erros e timeouts no período.
4. **X-Ray (se habilitado):** trace completo de uma requisição — onde o tempo foi gasto (API Gateway → Lambda → DynamoDB?).
5. **DynamoDB Metrics:** ConsumedReadCapacityUnits e SuccessfulRequestLatency — verificar se houve throttling.
6. **Correlacionar com:** deploys no horário, mudanças de configuração (CloudTrail), eventos externos (Black Friday?).

---

### Q12: "O que é SLO, SLA e SLI? Como você os definiria para esta API?"
**Resposta esperada:**
- **SLI (Service Level Indicator):** Métrica real medida. Ex: "percentual de requests com latência < 300ms".
- **SLO (Service Level Objective):** Meta interna. Ex: "99,9% das requests devem ter p99 < 300ms".
- **SLA (Service Level Agreement):** Compromisso contratual com cliente. Ex: "garantimos 99,5% de disponibilidade ou crédito".
- Para esta API:
  - SLI: Availability = requests 2xx / total requests
  - SLO: 99,9% availability; p99 latência < 500ms
  - SLA com cliente: 99,5% (mais conservador que SLO para ter margem de erro)
  - Error budget: se SLO é 99,9%, tenho 43,8 min/mês de downtime aceitável.

---

## Bloco 6: Decisões de Arquitetura

### Q13: "Esta API tem autenticação? Como você a implementaria?"
**Resposta:**
- Para esta API de demo: sem auth (CORS aberto).
- Para produção:
  1. **Cognito User Pools:** gerenciado, tokens JWT, MFA, OAuth2, SAML. Integra nativamente com API Gateway JWT Authorizer.
  2. **Lambda Authorizer customizado:** flexível para auth proprietário. Retorna IAM Policy. Cache de auth configurável para performance.
  3. **API Keys + Usage Plans:** para APIs B2B que precisam de throttling por cliente, não é autenticação real mas identificação.
  4. **IAM Auth (SigV4):** para comunicação serviço-a-serviço segura dentro da AWS.
- **Minha recomendação:** Cognito para B2C (usuários finais). Lambda Authorizer para integração com sistema de auth existente. IAM para service-to-service.

---

### Q14: "Como você faria o deploy desta aplicação sem downtime?"
**Resposta:**
- **CloudFormation:** Change Set → revisão → execute. Se rollback necessário: automático.
- **Lambda:** Versioning + Aliases + Traffic shifting (Canary). CodeDeploy: `LambdaCanary10Percent5Minutes` → se erro detectado, rollback automático.
- **DynamoDB:** Schema alterations são online (GSI) ou fora do schema (adicionar campos é gratuito em DynamoDB — sem ALTER TABLE!).
- **S3/Frontend:** Deploy atômico com CloudFront + invalidação de cache após deploy. Blue/green: dois buckets, swap do CloudFront origin.
- **API Gateway:** Stage aliases para testes antes de promover.

---

### Q15: "Se esta aplicação fosse receber 10 milhões de usuários, o que mudaria?"
**Resposta esperada:**
- **CloudFront:** na frente do S3 e API Gateway — cache borda global, DDoS protection, SSL termination.
- **DynamoDB:** trocar On-Demand por Provisioned + Auto Scaling para custo otimizado. Global Tables para multi-região.
- **Lambda:** Reserved Concurrency por função. Provisioned Concurrency para endpoints críticos (elimina cold start).
- **SQS FIFO:** para pedidos onde ordem importa (evitar race condition no estoque).
- **ElastiCache/DAX:** cache de leituras frequentes (catálogo de produtos — pouco muda, muito lido).
- **Multi-Region:** Route53 Latency Routing + Active-Active em us-east-1 e us-west-2 ou sa-east-1.
- **Observabilidade:** X-Ray distribuído. CloudWatch Synthetics (canary). PagerDuty integrado. SLO dashboards.
- **Custo estimado 10M usuários:** ~$2.000-5.000/mês (vs EC2 equivalente: ~$10.000+/mês).

---

## 🏆 CRITÉRIOS DE AVALIAÇÃO

Para cada resposta, avalie:

| Critério | Peso | 
|----------|------|
| Acertou os conceitos técnicos principais | 40% |
| Mencionou trade-offs (prós/contras) | 25% |
| Deu exemplo concreto com código ou ARN | 20% |
| Considerou custo e escalabilidade | 15% |

**Pontuação:**
- 80-100%: Nível Sênior confirmado ✅
- 60-79%: Nível Pleno avançado, falta profundidade Sênior
- 40-59%: Nível Pleno — continua estudando!
- <40%: Revise os módulos fundamentais

---

*"Um Sênior não sabe tudo — sabe onde procurar, sabe os trade-offs, e sabe comunicar claramente."*
