# Módulo 8 — Containers: ECR + ECS Fargate

> **Custo:** ~$0.30 | **Pré-requisito:** Docker instalado, Módulo 7 concluído | **Duração estimada:** 5-6 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que **containers são como lancheiras padronizadas**.

- Uma **lancheira (container)** contém tudo que o aluno precisa: comida, talheres, guardanapo. Não importa se o aluno vai para escola A ou escola B — a lancheira tem tudo dentro, funciona em qualquer lugar.
- O **Docker** é o processo de **empacotar a comida na lancheira** (criar a imagem)
- O **ECR (Elastic Container Registry)** é a **lanchonete** onde você guarda as lancheiras prontas para distribuição
- O **ECS (Elastic Container Service)** é a **cantina escolar** que pega as lancheiras e distribui para os alunos (containers rodando)
- O **Fargate** é como contratar uma empresa que **gerencia as mesas e cadeiras** — você só se preocupa com o cardápio, não com a infraestrutura da cantina

**EC2 vs Fargate:**
- Com EC2: você gerencia as máquinas, os patches, a capacidade ("quantos alunos cabem por sala")
- Com Fargate: Amazon gerencia tudo — você só diz "quero 512 MB e 0.25 vCPU para este container"

---

## 2. O QUE É (Definição Técnica Sênior)

**Amazon ECR (Elastic Container Registry):** Registry privado de imagens Docker gerenciado. Alta disponibilidade, integração nativa com IAM, scanning de vulnerabilidades automático, replicação cross-region. Alternativa gerenciada ao Docker Hub ou Harbor.

**Amazon ECS (Elastic Container Service):** Orquestrador de containers na AWS. Suporta dois launch types:
- **EC2:** Você provisiona e gerencia as instâncias EC2 onde os containers rodam
- **Fargate:** Serverless — a AWS provisiona a infraestrutura automaticamente. Você define apenas CPU/memória por task.

**Task Definition:** "Receita" de como rodar um container. Define: imagem, CPU, memória, variables, porta, volume, logging, IAM role.
**Task:** Instância em execução de uma Task Definition (como um "pod" no Kubernetes).
**Service:** Garante que N Tasks estejam sempre rodando (auto-restart, load balancing).

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 8:
  - ECR:             $0.00  (Free Tier: 500 MB/mês por 12 meses)
  - ECS (Fargate):   ~$0.30 (0.25 vCPU + 512 MB por ~2-3 horas de teste)
  
  CÁLCULO FARGATE:
    vCPU: 0.25 × $0.04048/hora = $0.0101/hora
    Memória: 0.5 GB × $0.004445/hora = $0.0022/hora
    Total: ~$0.012/hora
    2 horas de teste: ~$0.025
    
  ⚠️  DESTRUA os recursos imediatamente após o teste!
  ⚠️  Um ECS Service com 1 task rodando 24h = ~$0.30/dia
  ⚠️  ECR após Free Tier: $0.10/GB/mês para storage
  
  TOTAL:             ~$0.05 a $0.30 (dependendo do tempo de uso)
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-Dockerfile`](./01-Dockerfile) | Imagem Docker da aplicação | Dockerfile, layers, best practices |
| [`02-app.py`](./02-app.py) | Aplicação Python simples | Flask app para containerizar |
| [`03-ecr-repository.yaml`](./03-ecr-repository.yaml) | Repositório no ECR | ECR, lifecycle policies, scanning |
| [`04-build-push-ecr.sh`](./04-build-push-ecr.sh) | Build e push para ECR | docker build, docker push, ECR login |
| [`05-ecs-task-definition.yaml`](./05-ecs-task-definition.yaml) | Task Definition ECS | CPU, memória, logging, IAM role |
| [`06-ecs-fargate-run.sh`](./06-ecs-fargate-run.sh) | Executa container Fargate | run-task, IP público, logs |
| [`07-limpeza.sh`](./07-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS

### 4.1 Docker em 5 minutos

```dockerfile
# Dockerfile = receita de como criar a imagem

# Imagem base — onde começa
FROM python:3.12-slim          # Python 3.12 mínimo (slim = menor tamanho)

# Variáveis de ambiente dentro do container
ENV APP_PORT=8080

# Usuário não-root (segurança!)
RUN useradd --system --uid 1001 appuser

# Diretório de trabalho
WORKDIR /app

# Copia arquivos de dependências PRIMEIRO (aproveita cache do Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o resto do código
COPY . .

# Troca para usuário não-root
USER appuser

# Expõe a porta (documentação — não abre automaticamente!)
EXPOSE 8080

# Comando que roda quando o container inicia
CMD ["python", "app.py"]
```

### 4.2 ECS Terminology

```
CLUSTER         = Grupo de recursos ECS (como um datacenter virtual)
TASK DEFINITION = Template do container (imagem, CPU, mem, env vars)
TASK            = Uma instância rodando de uma task definition
SERVICE         = Garante N tasks rodando; reinicia se morrer; load balance
CONTAINER       = O processo Docker rodando dentro da task

FARGATE vs EC2:
  Fargate: AWS gerencia hosts → você só gerencia tasks
  EC2:     Você gerencia hosts + tasks → mais controle, mais trabalho
  
VANTAGENS FARGATE:
  ✅ Sem gerenciamento de EC2 (patches, AMIs, scaling de instâncias)
  ✅ Billing pelo segundo (vCPU + memória usada)
  ✅ Isolamento por nível de task (mais seguro que instâncias compartilhadas)
  
DESVANTAGENS FARGATE:
  ❌ Mais caro que EC2 equivalente (20-30% premium)
  ❌ Cold start mais lento que EC2 (pull da imagem a cada task)
  ❌ Sem acesso SSH direto (mas CloudWatch Logs e ECS Exec)
```

---

## 5. 🧠 CONCEITO SÊNIOR

**1. Multi-stage Builds — Reduzir tamanho da imagem**  
```dockerfile
# Estágio 1: Build (com todas as ferramentas)
FROM python:3.12 as builder
WORKDIR /build
COPY . .
RUN pip install pyinstaller && pyinstaller app.py

# Estágio 2: Runtime (mínimo possível)
FROM python:3.12-slim
COPY --from=builder /build/dist/app /app
CMD ["/app/app"]
# Resultado: imagem de 80 MB em vez de 800 MB
```

**2. ECR Lifecycle Policies — Evitar explosão de custo em storage**  
Sem lifecycle policy, toda imagem enviada fica para sempre no ECR. Em CD (deploy a cada commit): centenas de imagens acumulam.  
Configure para manter apenas as últimas 10 imagens:
```json
{"rules": [{"rulePriority": 1, "description": "Keep last 10",
            "selection": {"tagStatus": "any", "countType": "imageCountMoreThan", "countNumber": 10},
            "action": {"type": "expire"}}]}
```

**3. Task Role vs Execution Role**  
- **Task Execution Role:** usada pelo ECS Fargate para baixar a imagem do ECR e enviar logs para CloudWatch (serviço AWS gerencia)
- **Task Role:** usada pelo SEU código dentro do container para acessar outros serviços AWS (S3, DynamoDB, etc.) — princípio de least privilege

**4. ECS Fargate vs Lambda vs EC2**  
- Lambda: ideal para funções curtas (<15 min), event-driven
- Fargate: processos longos, HTTP servers, sempre ativo, mais controle que Lambda
- EC2: máximo controle, cargas específicas de hardware (GPU, specific networking)

---

## 6. PERGUNTAS DE ENTREVISTA

**Q: Explique a diferença entre Task Execution Role e Task Role no ECS. Qual a implicação de segurança?**
> **Resposta esperada:** Task Execution Role é uma IAM Role assumida pelo ECS Fargate (o plano de controle AWS) para operações de infraestrutura: baixar a imagem do ECR, enviar logs ao CloudWatch, e buscar segredos do Secrets Manager para injetar como variáveis de ambiente. Task Role é a IAM Role assumida pelo código da sua aplicação rodando dentro do container — usada para chamar serviços AWS (s3:GetObject, dynamodb:PutItem, etc.). Implicação de segurança: são roles separadas com escopos distintos. Misturá-las viola least privilege: a Task Execution Role não precisa de acesso ao S3, e a Task Role não precisa de acesso ao ECR. Em ambientes multi-tenant, cada serviço deve ter sua própria Task Role com permissões mínimas.

**Q: Como você gerenciaria o deploy zero-downtime de um ECS Fargate Service em produção?**
> **Resposta esperada:** ECS Service com Rolling Update: (1) Configurar Deployment Configuration com minimumHealthyPercent=100, maximumPercent=200 — mantém 100% da capacidade durante o deploy, permite até 2x tasks temporariamente; (2) Health checks no ALB com unhealthyThresholdCount=2 e tempo de grace period adequado; (3) CodeDeploy Blue/Green com ECS: cria novo Target Group com novas tasks, testa health, redireciona tráfego gradualmente (Canary ou Linear), rollback automático se health check falhar; (4) Circuit Breaker no ECS Service — se o deploy falhar X vezes, ECS para automaticamente e faz rollback; (5) Feature flags para mudanças de grande impacto; (6) Smoke tests automatizados pós-deploy.

---

## ✅ Próximo Módulo

👉 **[`../modulo-09-cloudwatch/README.md`](../modulo-09-cloudwatch/README.md)**
