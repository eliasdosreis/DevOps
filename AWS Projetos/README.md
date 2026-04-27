# 🚀 AWS do Zero ao Senior — Curso Prático com Custo < $1 por Projeto

> **Tutor:** AWS Expert Sênior  
> **Objetivo:** Te levar do zero ao nível Sênior exigido pelo mercado, com projetos reais e custo controlado.

---

## 🎯 O que você vai aprender

Ao concluir todos os módulos, você será capaz de:

- ✅ Criar e gerenciar infraestrutura real na AWS com custo controlado
- ✅ Entender cada serviço profundamente (não apenas clicar no console)
- ✅ Passar em entrevistas técnicas de nível Sênior (incluindo AWS Solutions Architect)
- ✅ Repassar esse conhecimento para outros
- ✅ Usar esse projeto como base para qualquer arquitetura AWS real

---

## 💰 REGRA DE OURO: Cada projeto custa menos de $1

| Módulo | Tema                          | Custo Estimado | Status |
|--------|-------------------------------|---------------|--------|
| 0      | Preparação do Ambiente        | $0.00         | ⬜     |
| 1      | Storage — S3                  | $0.00         | ⬜     |
| 2      | Computação Serverless — Lambda| $0.00         | ⬜     |
| 3      | API — API Gateway + Lambda    | $0.00         | ⬜     |
| 4      | Banco de Dados — DynamoDB     | $0.00         | ⬜     |
| 5      | Mensageria — SNS + SQS        | $0.00         | ⬜     |
| 6      | IaC — CloudFormation          | $0.00         | ⬜     |
| 7      | Segurança — IAM + Secrets     | ~$0.05        | ⬜     |
| 8      | Containers — ECR + ECS        | ~$0.30        | ⬜     |
| 9      | Observabilidade — CloudWatch  | $0.00         | ⬜     |
| 10     | Projeto Final Senior          | ~$0.50        | ⬜     |
| **TOTAL** |                            | **< $1.00**   |        |

---

## 📁 Estrutura de Arquivos

```
AWS/
├── README.md                          ← Este arquivo
├── modulo-00-preparacao/              ← IAM, CLI, Cost Explorer
├── modulo-01-s3/                      ← Buckets, Policies, Lifecycle
├── modulo-02-lambda/                  ← Functions, Triggers, Layers
├── modulo-03-api-gateway/             ← REST API, HTTP API, CORS
├── modulo-04-dynamodb/                ← Tables, GSI, TTL, Streams
├── modulo-05-sns-sqs/                 ← Topics, Queues, Fan-out, DLQ
├── modulo-06-cloudformation/          ← Stacks, Templates, Parameters
├── modulo-07-iam-secrets/             ← Roles, Policies, Secrets Manager
├── modulo-08-containers/              ← Docker, ECR, ECS, Fargate
├── modulo-09-cloudwatch/              ← Metrics, Logs, Alarms, Dashboards
└── modulo-10-projeto-final/           ← E-commerce Serverless Completo
```

---

## ⚠️ Regras de Segurança OBRIGATÓRIAS

1. **NUNCA** use a conta root para nada além de criar o usuário IAM inicial
2. **SEMPRE** ative MFA na conta root e no usuário IAM
3. **SEMPRE** configure um Budget Alert de $5 antes de qualquer módulo
4. **NUNCA** suba credenciais AWS em repositórios públicos
5. **SEMPRE** execute o passo de limpeza ao final de cada projeto
6. **VERIFIQUE** o Cost Explorer no dia seguinte a qualquer projeto novo
7. **PREFIRA** recursos serverless (Lambda, DynamoDB, S3) com Free Tier generoso
8. **EVITE** NAT Gateway, EC2 ligado 24h, RDS Multi-AZ em aprendizado

---

## 🔧 Ferramentas Necessárias

```bash
# Verifique se estão instalados antes de começar:
aws --version          # AWS CLI v2 — https://aws.amazon.com/cli/
docker --version       # Para o Módulo 8
python3 --version      # Runtime principal das Lambdas
```

---

## 📊 Acompanhamento de Custos

| Módulo | Recursos Criados      | Custo Real | Limpeza Feita? |
|--------|-----------------------|------------|----------------|
| 0      | IAM, CLI              | $0.00      | N/A            |
| 1      | S3 bucket             | -          | ⬜             |
| 2      | Lambda + CloudWatch   | -          | ⬜             |
| 3      | API Gateway + Lambda  | -          | ⬜             |
| 4      | DynamoDB + Lambda     | -          | ⬜             |
| 5      | SNS + SQS + Lambda    | -          | ⬜             |
| 6      | Stacks CloudFormation | -          | ⬜             |
| 7      | IAM Roles + Secrets   | -          | ⬜             |
| 8      | ECR + ECS Fargate     | -          | ⬜             |
| 9      | CloudWatch Dashboards | -          | ⬜             |
| 10     | Projeto Completo      | -          | ⬜             |
| **TOTAL** |                    | **< $1.00**|                |

---

## 🏁 Por onde começar?

👉 **Comece pelo [`modulo-00-preparacao/`](./modulo-00-preparacao/README.md)**

Cada módulo tem seu próprio README com instruções completas, analogias, código comentado, comandos CLI e passos de limpeza.

---

*"A jornada de mil milhas começa com um único passo." — Lao Tzu*
