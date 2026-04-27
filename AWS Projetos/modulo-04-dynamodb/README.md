# Módulo 4 — Banco de Dados: Amazon DynamoDB

> **Custo:** ~$0.00 | **Pré-requisito:** Módulo 3 concluído | **Duração estimada:** 5-6 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que o **DynamoDB é um arquivo de fichas de biblioteca** — mas mágico e infinito.

- Cada **Table** é um **gaveta** do arquivo (ex: "fichas de livros")
- Cada **Item** é uma **ficha individual** (ex: dados de um livro específico)
- A **Partition Key** é o **número da ficha** — único, a AWS usa ela para decidir em qual gaveta física guardar a ficha (isso é fundamental para performance!)
- A **Sort Key** é um **sub-índice dentro da gaveta** — permite organizar fichas do mesmo grupo (ex: todos os pedidos de um cliente, ordenados por data)
- O **GSI** (Global Secondary Index) é como um **ficheiro alternativo** — permite buscar as fichas por outro campo (ex: buscar por título em vez do número)

**Analogia do não-relacional:**  
No banco SQL (MySQL), todas as fichas têm os MESMOS campos. No DynamoDB, cada ficha pode ter campos DIFERENTES — item 1 pode ter "isbn", item 2 pode ter "ncm". Isso dá flexibilidade mas exige disciplina no design.

---

## 2. O QUE É (Definição Técnica Sênior)

**Amazon DynamoDB:** Banco de dados NoSQL totalmente gerenciado, de chave-valor e documentos, com latência de um dígito de milissegundo em qualquer escala. Serverless — sem provisioning de servidores, patches, backups manuais. 

**Características fundamentais:**
- **Modelo de dados:** Key-value + Document (JSON até 400 KB por item)
- **Consistência:** Strong consistency ou Eventual consistency (escolha por leitura)
- **Escalabilidade:** Horizontal automática (sharding por partition key)
- **Modo de capacidade:** Provisioned (WCU/RCU fixos) ou On-Demand (paga por uso)
- **Replicação:** Multi-AZ por padrão; Global Tables para multi-região
- **Transações:** ACID via TransactWriteItems/TransactGetItems (máx 100 itens por txn)

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 4:
  - DynamoDB Storage:  $0.00  (Free Tier: 25 GB SEMPRE)
  - DynamoDB RCU:      $0.00  (Free Tier: 25 RCU SEMPRE)
  - DynamoDB WCU:      $0.00  (Free Tier: 25 WCU SEMPRE)
  - Lambda:            $0.00  (Free Tier: 1M inv/mês)
  - TOTAL:             ~$0.00
  
  ✅ Free Tier do DynamoDB é PERMANENTE (não expira em 12 meses)!
  
  PARA REFERÊNCIA PRODUÇÃO (modo Provisioned):
  - $0.00013/WCU/hora (~$0.09/mês por WCU)
  - $0.00013/RCU/hora (~$0.09/mês por RCU)
  - $0.25/GB/mês (além dos 25 GB gratuitos)
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-tabela-simples.yaml`](./01-tabela-simples.yaml) | Tabela DynamoDB básica | PK, SK, tipos de dados |
| [`02-tabela-com-gsi.yaml`](./02-tabela-com-gsi.yaml) | Tabela com Global Secondary Index | GSI, queries alternativas |
| [`03-tabela-com-ttl.yaml`](./03-tabela-com-ttl.yaml) | TTL para auto-deleção | TTL, itens temporários |
| [`04-operacoes-crud.py`](./04-operacoes-crud.py) | Todas as operações DynamoDB | PutItem, GetItem, Query, Delete |
| [`05-lambda-crud-api.py`](./05-lambda-crud-api.py) | Lambda com CRUD completo | Integração API + DynamoDB |
| [`06-padroes-acesso.py`](./06-padroes-acesso.py) | Query vs Scan e performance | Access Patterns, design table |
| [`07-testar-dynamo.sh`](./07-testar-dynamo.sh) | Testa via CLI e API | aws dynamodb commands |
| [`08-limpeza.sh`](./08-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS

### 4.1 Primary Key — A decisão mais importante no DynamoDB

```
OPÇÃO 1: Apenas Partition Key (Simple PK)
  tabela: Usuarios
  PK: userId (ex: "user-abc123")
  → Cada usuário = 1 item
  → Leitura por GetItem(userId) = O(1) = ultrarrápido
  
OPÇÃO 2: Partition Key + Sort Key (Composite PK)
  tabela: Pedidos
  PK: clienteId (ex: "cliente-42")
  SK: pedidoId#timestamp (ex: "pedido-001#2024-01-15T10:30:00Z")
  → Todos os pedidos do cliente = 1 Query
  → Pedidos de 2024 = Query com KeyCondition "BETWEEN"
  → Padrão: MUITOS para MUITOS (1 cliente → N pedidos)
```

### 4.2 Query vs Scan — A diferença que define performance

```
GetItem:  O(1) — busca por PK exata (e SK se existir). SEMPRE use.
Query:    O(n) — busca por PK + condição no SK. Muito eficiente.
Scan:     O(N) — VAI EM TODOS OS ITENS DA TABELA. NUNCA em produção!

Analogia do Scan:
  Scan = procurar um livro lendo PÁGINA POR PÁGINA de todo o acervo
  Query = ir direto à estante certa e buscar pelos itens que você sabe que estão lá

⚠️  Scan em tabela de 1M itens = lê 1M itens = consome 1M RCU
    Query na mesma tabela com PK correta = lê apenas 10 itens = 10 RCU
```

### 4.3 Design Table-First para DynamoDB

```
SQL: Você cria as tabelas e depois escreve os queries
DynamoDB: Você define os queries PRIMEIRO e depois cria a tabela

PROCESSO CORRETO:
  1. Liste todos os padrões de acesso (access patterns):
     - Buscar usuário por ID
     - Listar todos os pedidos de um usuário (ordenados por data)
     - Buscar pedidos por status (em andamento, entregue)
  
  2. Mapeie cada pattern para uma estrutura de PK/SK:
     - GetItem({userId}) → PK=userId
     - Query({clienteId}, SK BETWEEN datas) → PK=clienteId, SK=data#pedidoId
     - GSI: PK=status, SK=data → lista por status
  
  3. Crie a tabela com os índices necessários
```

---

## 5. 🧠 CONCEITO SÊNIOR

**1. Single Table Design vs Multi-Table**  
Padrão avançado: guardar MÚLTIPLAS entidades em UMA tabela usando prefixos no PK/SK:  
`PK=Usuario#123, SK=METADATA` → dados do usuário  
`PK=Usuario#123, SK=Pedido#2024-001` → pedido do usuário  
`PK=Produto#456, SK=METADATA` → dados do produto  
Vantagem: 1 query retorna usuário + seus últimos pedidos. Desvantagem: complexidade.

**2. Hot Partitions — O erro mais comum em produção**  
DynamoDB distribui dados por partition key. Se todos usam a mesma PK (ex: `status=ativo`), uma partição fica sobrecarregada = throttling.  
Solução: adicionar sufixo randômico na PK (`status=ativo#3`) e agregar no código.

**3. Capacidade On-Demand vs Provisioned**  
On-Demand: perfeito para tráfego imprevisível ou desenvolvimento. Pode ser 5x mais caro em tráfego alto constante.  
Provisioned + Auto Scaling: melhor custo para tráfego previsível.

**4. DynamoDB Streams para event sourcing**  
Cada mudança (INSERT, MODIFY, REMOVE) gera um evento no Stream. Uma Lambda pode consumir esses eventos para: sincronizar com OpenSearch (busca full-text), invalidar cache Redis, enviar notificações, auditoria.

---

## 6. PERGUNTAS DE ENTREVISTA

**Q: Como você escolhe entre Query e Scan no DynamoDB? Quando o Scan é aceitável?**
> **Resposta esperada:** Query busca por partition key específica + condição opcional no sort key, consumindo RCU apenas para itens retornados. Scan lê a tabela TODA, consumindo RCU de cada item (independente de filtros — filtros são aplicados APÓS a leitura completa). Scan é aceitável APENAS em: (1) tabelas pequenas (<1000 itens) em operações de import/export one-time; (2) jobs de manutenção off-peak com Parallel Scan limitado; (3) desenvolvimento/debug. Em produção: qualquer Scan recorrente em tabelas grandes deve ser substituído por Query com GSI adequado, ou por ETL para Amazon OpenSearch para search full-text.

**Q: Explique o conceito de Hot Partition e como você evitaria em uma API de e-commerce.**
> **Resposta esperada:** Hot partition ocorre quando muitos requests concentram-se na mesma partition key, sobrecarregando a partição física (limite: 3.000 RCU ou 1.000 WCU por partição). Exemplos em e-commerce: (1) PK=produto_mais_vendido durante Black Friday → todos lendo/atualizando o mesmo item; (2) PK=status, SK=data → todos os pedidos ativos na mesma partição. Soluções: (1) Write sharding: `PK=produto-42#${random(1..10)}` → espalha writes em 10 partições, agrega no lado do read com Parallel Query; (2) DAX (DynamoDB Accelerator): cache in-memory que absorve hot reads sem chegar ao DynamoDB; (3) Caching na Lambda com TTL curto para dados quentes; (4) Para atualizações de quantidades de estoque: usar DynamoDB Transactions com backoff exponencial.

---

## ✅ Próximo Módulo

👉 **[`../modulo-05-sns-sqs/README.md`](../modulo-05-sns-sqs/README.md)**
