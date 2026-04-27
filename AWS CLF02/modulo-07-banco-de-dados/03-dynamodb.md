# Amazon DynamoDB — NoSQL serverless

## 1. Analogia do Dia a Dia
DynamoDB é como um fichário digital super rápido: você pode guardar e buscar informações instantaneamente, sem se preocupar com estrutura fixa de tabelas.

## 2. O que é (definição técnica oficial AWS)
Amazon DynamoDB é um banco de dados NoSQL totalmente gerenciado, serverless, com alta performance, escalabilidade automática e baixa latência.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: DynamoDB
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Banco NoSQL gerenciado e serverless
- Escalabilidade automática
- Baixa latência e alta disponibilidade

PALAVRAS-CHAVE NA PROVA:
→ "NoSQL AWS"
→ "serverless banco de dados"
→ "baixa latência"

QUANDO USAR:
✅ Workloads com leitura/escrita intensiva
✅ Dados sem estrutura fixa

QUANDO NÃO USAR:
❌ Requisitos de SQL complexo
❌ Relacionamentos complexos entre tabelas

DIFERENCIAIS:
- Suporte a triggers (Streams) e TTL
============================================================

## 4. Questões de Fixação
1. O que é o DynamoDB?
A) Banco relacional
B) Banco NoSQL gerenciado (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: DynamoDB é NoSQL.
- A), C), D) não são DynamoDB.

Armadilha: confundir DynamoDB com RDS ou S3.

2. Quando NÃO usar DynamoDB?
A) Para dados sem estrutura fixa
B) Para workloads serverless
C) Para relacionamentos complexos (correta)
D) Para alta escalabilidade

Explicação:
- C) Correta: relacionamentos complexos não são ideais.
- A), B), D) são casos de uso de DynamoDB.

Armadilha: achar que DynamoDB substitui RDS em todos os casos.

## 5. Conceito Senior
- DynamoDB suporta replicação global (Global Tables).
- Permite triggers e integração com Lambda.

## 6. Resumo para Revisão
- DynamoDB = NoSQL gerenciado | serverless | alta escalabilidade | baixa latência | triggers e TTL