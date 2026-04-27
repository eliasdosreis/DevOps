# Módulo 5 — Mensageria: SNS + SQS

> **Custo:** ~$0.00 | **Pré-requisito:** Módulo 4 concluído | **Duração estimada:** 4-5 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine uma **rádio FM** (SNS) conectada a **caixas de correio** (SQS).

**SNS (Simple Notification Service):**
- É como uma **estação de rádio** — ela transmite (publica) uma mensagem para todo mundo ao mesmo tempo
- Quem quer receber se "inscreve" (subscribe) na estação
- Múltiplos ouvintes podem escutar ao mesmo tempo (**fan-out**)
- A rádio não guarda as músicas — transmite e pronto (se você não estava ouvindo, perdeu)

**SQS (Simple Queue Service):**
- É como uma **caixa de correio** — as cartas ficam esperando até você abrí-las
- Mesmo que você esteja dormindo, a carta fica lá guardada
- Você processa no seu ritmo (desacoplamento temporal)
- Se a Lambda "morrer" processando, a mensagem volta para a fila (**visibility timeout**)
- Se falhar muitas vezes, vai para a **Dead Letter Queue** (caixa de devolvidos)

**Fan-out (SNS → múltiplos SQS):**
- A rádio transmite → várias caixas de correio diferentes recebem a mesma mensagem
- Cada sistema independente processa no seu próprio ritmo

---

## 2. O QUE É (Definição Técnica Sênior)

**Amazon SNS (Simple Notification Service):** Serviço de pub/sub totalmente gerenciado. Publishers enviam mensagens a Topics; Subscribers (SQS, Lambda, HTTP endpoints, email, SMS) recebem uma cópia. Entrega "push" — SNS empurra para os subscribers. Throughput praticamente ilimitado.

**Amazon SQS (Simple Queue Service):** Serviço de filas totalmente gerenciado. Producers enviam mensagens; Consumers fazem polling para receber. Dois tipos: Standard Queue (alta throughput, ordenação best-effort) e FIFO Queue (order-exactly-once, até 3.000 msg/s com batching).

**Padrão Fan-out:** 1 SNS Topic → N SQS Queues. Permite que múltiplos sistemas recebam o mesmo evento e processem independentemente. Exemplo: pedido criado → fila-estoque + fila-email + fila-analytics processam em paralelo.

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 5:
  - SNS:             $0.00  (Free Tier: 1M publicações/mês SEMPRE)
  - SQS:             $0.00  (Free Tier: 1M requisições/mês SEMPRE)
  - Lambda:          $0.00  (Free Tier: 1M invocações/mês SEMPRE)
  - SNS Email:       $0.00  (Free Tier: 1.000 notificações email/mês)
  - TOTAL:           ~$0.00
  
  ✅ SNS e SQS têm Free Tier PERMANENTE (não expira em 12 meses)
  
  PARA REFERÊNCIA PRODUÇÃO:
  - SNS: $0.50/M notificações; $2.00/M SMS; email: $2.00/100k
  - SQS Standard: $0.40/M requisições; FIFO: $0.50/M
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-topico-sns.yaml`](./01-topico-sns.yaml) | Tópico SNS + subscrição email | Topics, Subscriptions, Protocols |
| [`02-fila-sqs.yaml`](./02-fila-sqs.yaml) | Fila SQS standard com DLQ | Queues, DLQ, Visibility Timeout |
| [`03-fanout-sns-sqs.yaml`](./03-fanout-sns-sqs.yaml) | Fan-out: 1 SNS → 2 SQS | Fan-out pattern, Filter Policy |
| [`04-lambda-consumer-sqs.py`](./04-lambda-consumer-sqs.py) | Lambda que consome SQS | Batch processing, error handling |
| [`05-publicar-e-testar.sh`](./05-publicar-e-testar.sh) | Publica mensagens e testa | CLI SNS/SQS, DLQ em ação |
| [`06-limpeza.sh`](./06-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS

### 4.1 Visibility Timeout — A proteção da fila

```
PROBLEMA: Lambda A começa processando a mensagem.
          Lambda A morre (crash, timeout).
          A mensagem sumiu? NÃO!

SOLUÇÃO — Visibility Timeout:
  1. Lambda A "recebe" a mensagem
  2. SQS esconde a mensagem por X segundos (Visibility Timeout)
  3. Lambda A processa e exclui a mensagem (sucesso)
     OU
  3. Lambda A morre / timeout / não deleta
  4. Após X segundos: mensagem "reaparece" na fila
  5. Outra Lambda B recebe e processa

BOAS PRÁTICAS:
  - Visibility Timeout = 6x o Timeout da Lambda que consome
  - Se Lambda tem timeout de 3min → VisibilityTimeout = 18min
  - Evita que a mesma mensagem seja processada por múltiplas Lambdas
```

### 4.2 Dead Letter Queue (DLQ)

```
CENÁRIO: Mensagem mal-formada faz a Lambda falhar sempre.
         Sem DLQ: mensagem fica na fila para sempre, bloqueando resources.
         Com DLQ: após N falhas, vai para a fila DLQ.

FLUXO COM DLQ:
  Tentativa 1: Lambda falha → mensagem volta para fila
  Tentativa 2: Lambda falha → mensagem volta para fila  
  Tentativa 3: Lambda falha → MaxReceiveCount atingido!
               → Mensagem vai para DLQ (Dead Letter Queue)
               → Alarme CloudWatch dispara → equipe notificada
               → Time investiga e corrige manualmente

IMPORTANTE:
  - DLQ deve ter VisibilityTimeout MAIOR que a fila principal
  - Configure alarme no CloudWatch quando DLQ tiver mensagens!
  - Uma mensagem na DLQ = bug no seu código ou dado inválido
```

### 4.3 SNS Filter Policies — Cada subscriber recebe só o que quer

```
SEM FILTER POLICY: todos os subscribers recebem TODAS as mensagens

COM FILTER POLICY:
  SNS publica: {"tipo": "pedido_criado", "valor": 500.00, "pais": "BR"}
  
  Fila-email (filter: tipo IN [pedido_criado, pedido_cancelado]):
    ✅ Recebe esta mensagem
  
  Fila-analytics (filter: valor >= 100):
    ✅ Recebe esta mensagem (valor = 500)
  
  Fila-fraude (filter: valor >= 1000, pais = "BR"):
    ❌ Não recebe (valor 500 < 1000)

BENEFÍCIO: Reduz processamento desnecessário em cada queue
```

---

## 5. 🧠 CONCEITO SÊNIOR

**1. Standard vs FIFO Queue**  
Standard: throughput ilimitado, entrega "pelo menos uma vez" (pode duplicar!), sem ordem garantida. FIFO: garante exatamente uma entrega e ordem FIFO por MessageGroupId, mas limitado a 3.000 msg/s. Use FIFO para: pagamentos, inventário, qualquer coisa onde duplicatas causam problemas.

**2. SQS como buffer de pressão (backpressure)**  
Quando a Lambda ou outro consumer não consegue processar tão rápido quanto as mensagens chegam, o SQS absorve o volume. Sem SQS: sistema sobrecarregado pode cair. Com SQS: backlog cresce na fila, consumers processam no seu ritmo. Essential em sistemas de alta escala.

**3. Lambda Event Source Mapping para SQS**  
Em vez de a Lambda fazer polling manualmente, o próprio serviço Lambda faz polling do SQS automaticamente. Configurável: batch size (1-10.000), batch window, concorrência. A Lambda processa o batch, e o SQS deleta automaticamente as mensagens bem-sucedidas. Mensagens que lançam exceção continuam na fila.

**4. Idempotência é fundamental com SQS Standard**  
Como SQS Standard pode entregar duplicatas, seu consumer DEVE ser idempotente: processar a mesma mensagem 2 vezes não deve causar efeito colateral. Técnica: usar MessageId como idempotency key, checando no DynamoDB se já foi processado.

---

## 6. PERGUNTAS DE ENTREVISTA

**Q: Explique o padrão Fan-out e quando você o usaria em arquitetura AWS.**
> **Resposta esperada:** Fan-out é enviar uma mensagem a um SNS Topic que a distribui simultaneamente para múltiplos SQS Queues (ou outros endpoints). Usaria quando: (1) Um evento (ex: "pedido criado") precisa acionar múltiplos sistemas independentes: fila de email, fila de estoque, fila de analytics, fila de fraud detection — todos recebem a mesma mensagem em paralelo; (2) Os sistemas têm diferentes velocidades de processamento (via SQS como buffer entre eles); (3) Novos sistemas precisam ser adicionados sem alterar o publisher (apenas adicionar nova subscription no SNS). Vantagens: desacoplamento total entre sistemas, escalabilidade independente, resiliência (falha em um consumer não afeta outros).

**Q: O que é idempotência e por que é essencial com SQS Standard?**
> **Resposta esperada:** Idempotência significa que executar uma operação N vezes produz o mesmo resultado que executar 1 vez. É essencial porque SQS Standard entrega mensagens "pelo menos uma vez" — pode haver duplicatas. Se o consumer não for idempotente: e-mails duplicados, cobranças duplas, estoque negativo. Implementação: (1) Usar MessageId (ou um campo business-key) como idempotency key; (2) Antes de processar, verificar no DynamoDB/Redis se já foi processado; (3) Se já processado: retornar sucesso sem fazer nada; (4) Caso contrário: processar e marcar como realizado (em transação atômica). Para garantias absolutas: use SQS FIFO com exactly-once processing (mas com limite de throughput).

---

## ✅ Próximo Módulo

👉 **[`../modulo-06-cloudformation/README.md`](../modulo-06-cloudformation/README.md)**
