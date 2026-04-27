# AWS Fargate — containers serverless

## 1. Analogia do Dia a Dia
Fargate é como pedir comida pronta: você só escolhe o prato (container), não precisa se preocupar com a cozinha, fogão ou limpeza. Tudo é entregue pronto, sem gerenciar infraestrutura.

## 2. O que é (definição técnica oficial AWS)
AWS Fargate executa containers sem necessidade de provisionar ou gerenciar servidores. É serverless para containers, integrado ao ECS e EKS.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Fargate
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- Execução de containers sem gerenciar servidores
- Integra com ECS e EKS
- Paga só pelo uso

PALAVRAS-CHAVE NA PROVA:
→ "serverless para containers"
→ "sem provisionar servidores"
→ "integração ECS/EKS"

QUANDO USAR:
✅ Containers sem gestão de infraestrutura
✅ Workloads elásticos e event-driven

QUANDO NÃO USAR:
❌ Necessidade de controle total do host
❌ Workloads monolíticos

DIFERENCIAIS:
- Reduz complexidade operacional
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Fargate?
A) Executa containers sem gerenciar servidores (correta)
B) Gerencia bancos de dados
C) Cria backups
D) Gerencia usuários

Explicação:
- A) Correta: Fargate é serverless para containers.
- B), C), D) não são Fargate.

Armadilha: confundir Fargate com EC2.

2. Com o que o Fargate se integra?
A) Lambda
B) ECS e EKS (correta)
C) S3
D) RDS

Explicação:
- B) Correta: Fargate integra com ECS/EKS.
- A), C), D) não são integrações do Fargate.

Armadilha: achar que Fargate é serviço separado de containers.

## 5. Conceito Senior
- Fargate elimina patching e manutenção de host.
- Ideal para workloads imprevisíveis e escaláveis.

## 6. Resumo para Revisão
- Fargate = serverless para containers | integra com ECS/EKS | sem gestão de servidores | paga por uso | reduz complexidade