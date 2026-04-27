# Módulo 2 — Computação Serverless: AWS Lambda

> **Custo:** ~$0.00 | **Pré-requisito:** Módulos 0 e 1 concluídos | **Duração estimada:** 4-5 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que o **Lambda é um garçom que aparece apenas quando você o chama**.

- Em um restaurante normal (EC2), você tem um **garçom fixo** — ele fica lá mesmo quando não tem clientes, recebendo salário (pagando pela hora EC2).
- Com o Lambda, é como ter um **garçom mágico**: você aperta o botão, ele aparece, entrega seu pedido e desaparece. Você paga **apenas pelo tempo que ele passou atendendo**, não pelo tempo que ficou esperando.

Mais detalhes:
- **Função Lambda** = a receita que o garçom sabe executar (código)
- **Trigger** = o botão que chama o garçom (evento S3, API, agendamento...)
- **Timeout** = tempo máximo que o garçom pode passar no seu pedido antes de desistir
- **Memory** = quanto o garçom consegue "carregar" de uma vez
- **Cold Start** = quando o garçom precisa "se preparar" antes de atender (demora um pouco mais na 1ª vez)
- **Concurrent Executions** = quantos garçons podem atender ao mesmo tempo

---

## 2. O QUE É (Definição Técnica Sênior)

**AWS Lambda:** Serviço de computação serverless que executa código em resposta a eventos, sem provisionar ou gerenciar servidores. O modelo de execução é stateless e orientado a eventos. A AWS gerencia automaticamente o scaling (de 0 até milhares de execuções simultâneas), alta disponibilidade e infraestrutura subjacente.

**Características técnicas fundamentais:**
- **Runtimes:** Python, Node.js, Java, Go, .NET, Ruby, ou Custom Runtime
- **Timeout máximo:** 15 minutos (para processos longos, use ECS ou Step Functions)
- **Memória:** 128 MB até 10.240 MB (CPU escala proporcionalmente)
- **Payload de entrada:** até 6 MB (síncrono) ou 256 KB (assíncrono)
- **Concorrência:** 1.000 execuções simultâneas por padrão (pode aumentar)
- **Execution Environment:** Firecracker microVMs — isolados e efêmeros
- **Billing:** por 1ms de execução + por GB-segundo de memória usada

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 2:
  - Lambda Invocações: $0.00  (Free Tier: 1.000.000 req/mês SEMPRE)
  - Lambda Compute:    $0.00  (Free Tier: 400.000 GB-segundos/mês SEMPRE)
  - CloudWatch Logs:   $0.00  (Free Tier: 5 GB/mês)
  - S3 (trigger):      $0.00  (Free Tier já coberto no Módulo 1)
  - TOTAL:             ~$0.00
  
  ✅ Lambda é SEMPRE gratuito dentro do Free Tier (sem prazo de expiração!)
  
  PARA REFERÊNCIA (após Free Tier):
  - $0.20 por 1 MILHÃO de invocações
  - $0.0000166667 por GB-segundo
  
  Exemplo: Lambda 128 MB, 1s de execução, 1M req/mês = ~$2.76/mês
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-lambda-hello.py`](./01-lambda-hello.py) | Função Lambda básica | Handler, event, context |
| [`02-lambda-com-s3.py`](./02-lambda-com-s3.py) | Lambda que lê/escreve no S3 | Boto3, IAM Role, permissões |
| [`03-lambda-processador-imagem.py`](./03-lambda-processador-imagem.py) | Processa imagens do S3 | Trigger S3, Layers, PIL |
| [`04-lambda-role.yaml`](./04-lambda-role.yaml) | Role IAM para Lambda | Execution Role, least privilege |
| [`05-lambda-deploy.yaml`](./05-lambda-deploy.yaml) | Deploy da Lambda via CloudFormation | CloudFormation Lambda |
| [`06-lambda-trigger-s3.yaml`](./06-lambda-trigger-s3.yaml) | Conecta S3 → Lambda | Event Notifications |
| [`07-lambda-variaveis-ambiente.py`](./07-lambda-variaveis-ambiente.py) | Env vars e SSM Parameter Store | Configuration, security |
| [`08-testar-lambda.sh`](./08-testar-lambda.sh) | Invoca a Lambda e verifica logs | CLI invoke, CloudWatch |
| [`09-limpeza.sh`](./09-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS DO LAMBDA

### 4.1 Anatomia de uma Função Lambda

```python
# Toda função Lambda TEM que ter este formato:
def handler(event, context):
    #      ↑         ↑
    #   Dados     Metadados
    #  de entrada da execução
    
    return resultado
```

**`event`** = o "pedido" que chegou. Muda dependendo do trigger:
- Trigger HTTP (API Gateway): `{"httpMethod": "GET", "path": "/", "body": "..."}`
- Trigger S3: `{"Records": [{"s3": {"bucket": {...}, "object": {...}}}]}`
- Trigger SQS: `{"Records": [{"body": "...", "messageId": "..."}]}`

**`context`** = metadados da execução (quanto tempo resta, nome da função, etc.)

### 4.2 Cold Start vs Warm Start

```
COLD START (primeira execução / após inatividade):
  AWS cria o container → baixa o código → inicializa runtime → executa
  Tempo extra: 100ms - 1s (Python/Node.js) ou 5-15s (Java/.NET)
  
WARM START (execuções subsequentes):
  Container já existe → executa diretamente
  Tempo extra: 0ms
  
COMO MITIGAR COLD START:
  1. Provisioned Concurrency: mantém containers "aquecidos" (cobra por hora)
  2. Escolha runtimes leves: Python/Node.js > Java/.NET
  3. Minimize o tamanho do pacote de deploy
  4. Mova inicializações pesadas para FORA do handler:
  
  ❌ Ruim (reconecta a cada invocação):
  def handler(event, context):
      db = conectar_banco()  # Dentro do handler
      return db.query()
  
  ✅ Bom (reutiliza conexão entre execuções):
  db = conectar_banco()  # Fora do handler (no módulo)
  def handler(event, context):
      return db.query()
```

### 4.3 Concorrência no Lambda

```
CONCORRÊNCIA RESERVADA: garante X execuções exclusivamente para uma função
CONCORRÊNCIA PROVISIONADA: mantém containers aquecidos (elimina cold start)
THROTTLING: quando excede o limite, retorna erro 429 (TooManyRequests)

Limite default por região: 1.000 execuções simultâneas (total da conta)
Pode ser aumentado via Service Quotas (solicitar aumento)
```

---

## 5. VERIFICAÇÃO E TROUBLESHOOTING COMUNS

### Erro: Task timed out after X.XX seconds
```
Causa: A função demorou mais que o Timeout configurado
Solução:
  1. Aumente o Timeout (máximo: 900 segundos = 15 minutos)
  2. Otimize o código (evite loops desnecessários)
  3. Para tarefas longas: use Step Functions + Lambda encadeados
```

### Erro: Runtime.HandlerNotFound
```
Causa: O nome do arquivo ou da função não bate com o Handler configurado
Solução:
  Handler: "arquivo.funcao" → arquivo.py com "def funcao(event, context)"
  Exemplo: Handler="minha_funcao.handler" → arquivo minha_funcao.py, def handler()
```

### Erro: AccessDeniedException
```
Causa: A Role da Lambda não tem permissão para o recurso acessado
Solução:
  1. Vá em IAM → Roles → encontre a Role da Lambda
  2. Adicione a permissão necessária (ex: s3:GetObject para ler do S3)
  3. Ou use a política gerenciada correta (ex: AmazonS3ReadOnlyAccess)
```

---

## 6. 🧠 CONCEITO SÊNIOR

### O que um Sênior sabe que um Júnior não sabe:

**1. Lambda não é para tudo**  
Use Lambda para: APIs, processamento de eventos, automações. EVITE para: processos longos (>15min), workloads com estado, streaming de vídeo em tempo real.

**2. Execution Environment é efêmero — mas o /tmp persiste entre invocações no mesmo container**  
O diretório `/tmp` (até 10 GB) persiste enquanto o container está "quente". Use para cache de dados entre invocações. Mas nunca assuma que vai estar lá — trate como opcional.

**3. Lambda Power Tuning — otimização de custo vs performance**  
Mais memória = mais CPU = execução mais rápida = pode ser mais BARATO.  
Use o [AWS Lambda Power Tuning](https://github.com/alexcasalboni/aws-lambda-power-tuning) para encontrar o ponto ótimo.

**4. Dead Letter Queue (DLQ) para invocações assíncronas**  
Quando uma Lambda falha em modo assíncrono (ex: trigger S3), a AWS tenta 2 vezes. Após isso, o evento é PERDIDO. Configure DLQ (SQS) para capturar falhas.

**5. Function URLs vs API Gateway**  
Lambda Function URLs (não API Gateway): HTTPS endpoint simples, sem custo adicional. Bom para webhooks simples. Para APIs complexas com auth, transformações e throttling: API Gateway.

---

## 7. PERGUNTAS DE ENTREVISTA

**Q: Explique o que é um cold start no Lambda e como você o mitigaria em produção.**
> **Resposta esperada:** Cold start ocorre quando a AWS precisa criar um novo container para executar a Lambda — isso inclui: inicializar o runtime (Python, Node.js, JVM...), baixar o código, carregar dependências, e chamar o handler. O impacto varia: Node.js/Python: 100-500ms; Java/.NET: 1-10s. Estratégias de mitigação: (1) Provisioned Concurrency: mantém N containers aquecidos, sem cold start — cobra por hora de existência; (2) Escolher runtimes leves (Python/Node.js); (3) Reduzir tamanho do deployment package; (4) Mover inicializações pesadas (DB connections, SDK clients) para fora do handler; (5) SnapStart para Java (snapshot da JVM inicializada); (6) Keep-warm via EventBridge schedules (workaround, não recomendado em produção).

**Q: Como você garantiria que uma Lambda tem apenas as permissões mínimas necessárias?**
> **Resposta esperada:** Aplico o princípio de Least Privilege criando uma IAM Role específica por função Lambda, não uma role compartilhada. O processo: (1) Identifico quais serviços a Lambda usa (ex: S3, DynamoDB, SNS); (2) Identifico as ações específicas (ex: s3:GetObject, NOT s3:*); (3) Identifico os recursos específicos por ARN (ex: arn:aws:s3:::meu-bucket/pasta-especifica/*); (4) Adiciono Conditions quando possível (ex: allow apenas de determinada VPC, ou apenas objetos com tag:owner); (5) Uso IAM Access Analyzer para detectar permissões não usadas; (6) Reviso periodicamente com Credential Reports e Access Advisor.

---

## ✅ Próximo Módulo

Quando terminar e executar a limpeza, avance para:
👉 **[`../modulo-03-api-gateway/README.md`](../modulo-03-api-gateway/README.md)**
