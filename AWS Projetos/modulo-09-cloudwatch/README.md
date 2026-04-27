# Módulo 9 — Observabilidade: Amazon CloudWatch

> **Custo:** ~$0.00 | **Pré-requisito:** Módulos 1-8 concluídos | **Duração estimada:** 4-5 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que o **CloudWatch é como o painel de controle de um avião**.

- **Métricas** = os **instrumentos de voo**: velocidade, altitude, combustível — dados numéricos em tempo real
- **Logs** = a **caixa preta**: registra tudo que aconteceu, em ordem cronológica
- **Alarmes** = a **luz de alerta**: "combustível abaixo de 20%" → alarme dispara → piloto age
- **Dashboards** = o **painel principal**: todos os instrumentos importantes na mesma tela
- **CloudWatch Insights** = o **analisador de voo**: após um incidente, analisa a caixa preta com queries

Sem CloudWatch, você está voando no escuro: não sabe se a Lambda está funcionando, se o DynamoDB está estrangulado, se há erros aumentando. Um sistema sem observabilidade em produção é como um avião sem instrumentos.

---

## 2. O QUE É (Definição Técnica Sênior)

**Amazon CloudWatch:** Plataforma de observabilidade nativa AWS que coleta e monitora métricas, logs e eventos de recursos AWS e aplicações personalizadas. Base do pilar de Excelência Operacional do AWS Well-Architected Framework.

**Os três pilares da observabilidade:**
- **Metrics:** Dados numéricos agregados ao longo do tempo (ex: Invocations/min, ErrorRate %)
- **Logs:** Eventos textuais com timestamp (ex: "2024-01-15 10:30:00 ERROR NullPointerException")
- **Traces:** Rastro de uma requisição por múltiplos serviços (X-Ray — não coberto neste módulo)

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 9:
  - CloudWatch Metrics:     $0.00  (Free Tier: 10 métricas customizadas)
  - CloudWatch Logs:        $0.00  (Free Tier: 5 GB ingestão + 5 GB armazenamento)
  - CloudWatch Alarms:      $0.00  (Free Tier: 10 alarmes)
  - CloudWatch Dashboards:  $0.00  (Free Tier: 3 dashboards)
  - CloudWatch Insights:    $0.00  (Free Tier: 5 GB queries/mês)
  - SNS (alertas email):    $0.00  (Free Tier)
  - TOTAL:                  ~$0.00
  
  ⚠️  Após Free Tier:
      Logs: $0.50/GB ingestão + $0.03/GB/mês armazenamento
      Métricas customizadas: $0.30 cada/mês
      Alarmes: $0.10/alarme/mês (métricas customizadas)
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-log-group-basico.yaml`](./01-log-group-basico.yaml) | Log Group com retenção | Log Groups, retention, KMS |
| [`02-metrica-customizada.py`](./02-metrica-customizada.py) | Publica métricas de negócio | PutMetricData, dimensions, units |
| [`03-alarme-cloudwatch.yaml`](./03-alarme-cloudwatch.yaml) | Alarme com ação SNS | Alarms, thresholds, actions |
| [`04-dashboard.yaml`](./04-dashboard.yaml) | Dashboard completo | Dashboards, widgets, metrics |
| [`05-log-insights-queries.sh`](./05-log-insights-queries.sh) | Queries nos logs | CloudWatch Insights, query language |
| [`06-lambda-com-metricas.py`](./06-lambda-com-metricas.py) | Lambda que gera métricas | Structured logging, EMF |
| [`07-limpeza.sh`](./07-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS

### 4.1 Métricas — O que entender

```
ESTRUTURA DE UMA MÉTRICA:
  Namespace: AWS/Lambda        (ex: AWS/Lambda, AWS/DynamoDB, ou custom: "MeuApp/Pedidos")
  Nome:      Invocations        (ex: Invocations, Errors, Duration, Throttles)
  Dimensions: FunctionName=...  (quais recursos estão sendo medidos)
  Value:     42                 (o valor)
  Unit:      Count              (Count, Milliseconds, Bytes, Percent, ...)
  Timestamp: 2024-01-15T...     (quando medido)

MÉTRICAS AUTOMÁTICAS (AWS cria para você):
  Lambda: Invocations, Errors, Duration, Throttles, ConcurrentExecutions
  DynamoDB: ConsumedWriteCapacityUnits, ConsumedReadCapacityUnits
  API Gateway: Count, 4XXError, 5XXError, Latency

MÉTRICAS CUSTOMIZADAS (você cria):
  "PedidosCriados", "ValorTotalVendido", "UsuariosAtivos"
  São as métricas de negócio que importam para o seu produto
```

### 4.2 Alarmes — Como configurar corretamente

```
ANATOMY DE UM ALARME:
  Métrica:    Lambda Errors > 5 em 5 minutos
  Período:    Cada ponto de dados = 5 minutos de dados agregados
  Avaliação:  3 períodos consecutivos (15 minutos total de problemas)
  Ação:       Enviar email via SNS → Criar ticket no PagerDuty
  
ESTADOS DO ALARME:
  OK         → tudo normal
  ALARM      → threshold atingido → ação disparada
  INSUFFICIENT_DATA → dados insuficientes (comum nos primeiros minutos)

ERROS COMUNS:
  ❌ Período muito curto (1 min): muitos falsos positivos
  ❌ Threshold muito alto: erros passam sem alarme
  ✅ Use pelo menos 3 períodos avaliação (evita alarme em pico momentâneo)
  ✅ Crie alarme de "sem dados" para detectar se a Lambda parou de reportar
```

### 4.3 CloudWatch Logs Insights — Query language

```
# Contar erros por hora:
stats count(*) as erros by bin(1h)
| filter @message like /ERROR/
| sort @timestamp desc

# Performance da Lambda — percentil 95:
stats percentile(@duration, 95) as p95, 
      avg(@duration) as media, 
      max(@duration) as maximo
by bin(5m)
| filter @type = "REPORT"

# Encontrar cold starts:
filter @message like /Init Duration/
| parse @message "Init Duration: * ms" as initDuration
| stats avg(initDuration) as avgColdStart, count(*) as quantidadeColdStarts

# Erros agrupados por tipo:
filter @message like /ERROR/
| parse @message "[*] *" as nivel, mensagem  
| stats count(*) as total by mensagem
| sort total desc
| limit 10
```

---

## 5. 🧠 CONCEITO SÊNIOR

**1. Embedded Metrics Format (EMF) — A forma correta de publicar métricas de Lambda**  
Em vez de chamar PutMetricData explicitamente (latência + custo), escreva métricas como JSON estruturado nos logs. CloudWatch reconhece automaticamente e cria métricas:
```python
import json
# Em vez de: cloudwatch.put_metric_data(...)
# Escreva nos logs:
print(json.dumps({
    "_aws": {
        "Timestamp": 1234567890,
        "CloudWatchMetrics": [{
            "Namespace": "MeuApp/Pedidos",
            "Dimensions": [["Ambiente"]],
            "Metrics": [{"Name": "TotalPedidos", "Unit": "Count"}]
        }]
    },
    "Ambiente": "prod",
    "TotalPedidos": 42
}))
# CloudWatch detecta automático e publica a métrica!
```

**2. Log Dimensions — O erro mais comum que explode o custo**  
Nunca use `request_id` ou `user_id` como dimensão de uma métrica customizada — cria uma nova timeseries por request (cardinality explosion → R$$$). Dimensões devem ser de baixa cardinalidade: ambiente (prod/dev), região, serviço.

**3. Anomaly Detection — Alertas inteligentes sem threshold fixo**  
Em vez de "alerta se > 100 erros", use ML para aprender o padrão normal e alertar em anomalias:  
`aws cloudwatch put-anomaly-detector --namespace AWS/Lambda --metric-name Errors`  
Detecta: picos inesperados, queda de tráfego (que pode indicar falha silenciosa), sazonalidade.

**4. Composite Alarms — Reduzir alertas desnecessários**  
Combina múltiplos alarmes com AND/OR lógico. Evita alert fatigue:  
"Alertar APENAS SE: (erros > 5) AND (latência > 2000ms) AND (invocações > 100)"

---

## 6. PERGUNTAS DE ENTREVISTA

**Q: Como você estruturaria observabilidade para uma arquitetura de microsserviços na AWS?**
> **Resposta esperada:** Três pilares: (1) Metrics: CloudWatch Metrics customizadas para métricas de negócio (pedidos/min, valor médio), métricas default para cada serviço. Alarmes compostos para reduzir noise. (2) Logs: Structured logging em JSON em todos os serviços (facilita Insights queries). Log Groups com retenção por ambiente (7d dev, 30d staging, 90d+ prod). CloudWatch Insights para correlação cross-service com @requestId. (3) Traces: AWS X-Ray para tracing distribuído — rastrear uma requisição passando por API Gateway → Lambda → DynamoDB → SQS. Identifica gargalos por percentil de latência. Além dos três pilares: Dashboards por serviço + dashboard executivo de negócio. Alarmes com múltiplas ações (SNS → PagerDuty, Slack). Service Level Objectives (SLOs) monitorados com CloudWatch Metrics Math.

**Q: Qual a diferença entre CloudWatch Logs e CloudWatch Metrics? Quando usar cada um?**
> **Resposta esperada:** Logs são dados textuais discretos — registam EVENTOS: "às 10:30:42 o usuário X fez checkout com erro de pagamento". Metrics são dados numéricos agregados — medem TENDÊNCIAS ao longo do tempo: "144 erros de pagamento na última hora". Use logs para: debugging de bugs específicos, auditoria de eventos, descoberta de causa raiz, correlação de múltiplos eventos. Use metrics para: alertas em tempo real (alarmes reagem em segundos), dashboards de tendência, análise de performance (percentis), custo-efetivo para dados em alta frequência. Na prática: gere logs estruturados (JSON) nas Lambdas e use Metrics Filter para extrair métricas automaticamente dos logs (sem custo extra de PutMetricData).

---

## ✅ Próximo Módulo (FINAL!)

👉 **[`../modulo-10-projeto-final/README.md`](../modulo-10-projeto-final/README.md)**
