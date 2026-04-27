# AWS Step Functions — orquestração de workflows

## 1. Analogia do Dia a Dia
Step Functions é como um maestro de orquestra: coordena vários músicos (serviços) para tocar juntos, na ordem certa, garantindo que cada um faça sua parte no tempo correto.

## 2. O que é (definição técnica oficial AWS)
AWS Step Functions é um serviço de orquestração de workflows serverless, que coordena múltiplos serviços AWS em fluxos de trabalho com estados, decisões e paralelismo.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Step Functions
DOMÍNIO DO EXAME: Integração e Mensageria (33%)
============================================================

O QUE É:
- Orquestração de workflows serverless
- Coordenação de múltiplos serviços AWS
- Suporte a estados, decisões e paralelismo

PALAVRAS-CHAVE NA PROVA:
→ "orquestração de workflows"
→ "serverless"
→ "coordenação de serviços"

QUANDO USAR:
✅ Processos com múltiplas etapas
✅ Workloads event-driven

QUANDO NÃO USAR:
❌ Workloads simples
❌ Processos sem etapas dependentes

DIFERENCIAIS:
- Visualização gráfica dos fluxos
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Step Functions?
A) Orquestra workflows entre serviços AWS (correta)
B) Gera relatórios de custos
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- A) Correta: Step Functions orquestra workflows.
- B), C), D) não são funções do Step Functions.

Armadilha: confundir Step Functions com Lambda.

2. Quando usar Step Functions?
A) Para processos com múltiplas etapas (correta)
B) Para backups
C) Para workloads simples
D) Para cache em memória

Explicação:
- A) Correta: Step Functions é para orquestração.
- B), C), D) não são casos de uso de Step Functions.

Armadilha: achar que Step Functions é só para automação simples.

## 5. Conceito Senior
- Suporta integração com Lambda, ECS, SQS, SNS, DynamoDB, etc.
- Permite retries, paralelismo e tratamento de exceções.

## 6. Resumo para Revisão
- Step Functions = orquestração de workflows | serverless | múltiplos serviços | visualização gráfica | retries e paralelismo