# Amazon Aurora — RDS turbinado da AWS

## 1. Analogia do Dia a Dia
Aurora é como um carro esportivo baseado em um modelo popular: tem a mesma aparência (compatível com MySQL/PostgreSQL), mas é muito mais rápido, seguro e eficiente.

## 2. O que é (definição técnica oficial AWS)
Amazon Aurora é um banco de dados relacional compatível com MySQL e PostgreSQL, desenvolvido pela AWS para alta performance, disponibilidade e escalabilidade, com replicação automática e recuperação instantânea.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon Aurora
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Banco relacional compatível com MySQL/PostgreSQL
- Performance até 5x maior que MySQL padrão
- Alta disponibilidade e replicação automática

PALAVRAS-CHAVE NA PROVA:
→ "Aurora = compatível MySQL/PostgreSQL"
→ "alta performance"
→ "replicação automática"

QUANDO USAR:
✅ Workloads críticos de alta performance
✅ Necessidade de escalabilidade e resiliência

QUANDO NÃO USAR:
❌ Workloads NoSQL
❌ Aplicações que não exigem alta performance

DIFERENCIAIS:
- Recuperação instantânea e auto healing
============================================================

## 4. Questões de Fixação
1. O que é o Amazon Aurora?
A) Banco NoSQL
B) Banco relacional compatível com MySQL/PostgreSQL (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: Aurora é relacional e compatível.
- A), C), D) não são Aurora.

Armadilha: confundir Aurora com DynamoDB.

2. Qual diferencial do Aurora?
A) Performance até 5x maior que MySQL padrão (correta)
B) Backup manual
C) Não suporta replicação
D) Não é compatível com PostgreSQL

Explicação:
- A) Correta: performance é diferencial.
- B), C), D) não são verdade.

Armadilha: achar que Aurora é só um MySQL comum.

## 5. Conceito Senior
- Aurora separa armazenamento e computação para escalar independentemente.
- Suporta failover automático e replicação global.

## 6. Resumo para Revisão
- Aurora = relacional compatível MySQL/PostgreSQL | alta performance | replicação automática | auto healing | escalabilidade independente