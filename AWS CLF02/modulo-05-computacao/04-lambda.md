# AWS Lambda — serverless (funções sem servidor)

## 1. Analogia do Dia a Dia
Lambda é como uma lâmpada automática: só acende quando alguém entra no cômodo, funciona sozinha e desliga quando não precisa mais.

## 2. O que é (definição técnica oficial AWS)
AWS Lambda executa código em resposta a eventos, sem necessidade de gerenciar servidores. Você paga apenas pelo tempo de execução do código.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Lambda
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- Execução de código sem servidor
- Escala automática
- Paga só pelo uso

PALAVRAS-CHAVE NA PROVA:
→ "serverless"
→ "event-driven"
→ "paga por execução"

QUANDO USAR:
✅ Workloads event-driven
✅ Tarefas rápidas e automação

QUANDO NÃO USAR:
❌ Workloads de longa duração
❌ Necessidade de controle total do SO

DIFERENCIAIS:
- Integra com quase todos os serviços AWS
============================================================

## 4. Questões de Fixação
1. O que é AWS Lambda?
A) Serviço de banco de dados
B) Execução de código sem servidor (correta)
C) Serviço de armazenamento
D) Load balancer

Explicação:
- B) Correta: Lambda é serverless.
- A), C), D) não são Lambda.

Armadilha: confundir Lambda com EC2.

2. Quando NÃO usar Lambda?
A) Para workloads event-driven
B) Para tarefas rápidas
C) Para workloads de longa duração (correta)
D) Para automação

Explicação:
- C) Correta: Lambda não é para tarefas longas.
- A), B), D) são casos de uso de Lambda.

Armadilha: achar que Lambda serve para tudo.

## 5. Conceito Senior
- Lambda pode ser disparado por eventos S3, API Gateway, etc.
- Limite de tempo de execução por função.

## 6. Resumo para Revisão
- Lambda = serverless | executa código por evento | escala automática | paga por uso | não serve para tarefas longas