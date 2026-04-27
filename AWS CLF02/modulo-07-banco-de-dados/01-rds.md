# Amazon RDS: bancos de dados gerenciados (MySQL, PostgreSQL, Oracle, SQL Server, MariaDB)

## 1. Analogia do Dia a Dia
RDS é como contratar um serviço de buffet: você escolhe o cardápio (tipo de banco), o fornecedor cuida de tudo (infraestrutura, backup, atualização) e você só se preocupa com os dados.

## 2. O que é (definição técnica oficial AWS)
Amazon Relational Database Service (RDS) é um serviço gerenciado para bancos de dados relacionais, suportando MySQL, PostgreSQL, Oracle, SQL Server e MariaDB, com backup, alta disponibilidade e escalabilidade automáticos.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon RDS
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Banco de dados relacional gerenciado
- Suporte a múltiplos engines
- Backup, patching e escalabilidade automáticos

PALAVRAS-CHAVE NA PROVA:
→ "banco relacional gerenciado"
→ "backup automático"
→ "alta disponibilidade"

QUANDO USAR:
✅ Aplicações que exigem SQL
✅ Necessidade de alta disponibilidade

QUANDO NÃO USAR:
❌ Workloads NoSQL
❌ Controle total do SO e banco

DIFERENCIAIS:
- Multi-AZ e Read Replicas para alta disponibilidade
============================================================

## 4. Questões de Fixação
1. O que é o Amazon RDS?
A) Banco de dados NoSQL
B) Banco relacional gerenciado (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: RDS é banco relacional gerenciado.
- A), C), D) não são RDS.

Armadilha: confundir RDS com DynamoDB ou S3.

2. O que faz o Multi-AZ no RDS?
A) Cria backups
B) Garante alta disponibilidade (correta)
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- B) Correta: Multi-AZ é para alta disponibilidade.
- A), C), D) não são funções do Multi-AZ.

Armadilha: achar que Multi-AZ é para performance.

## 5. Conceito Senior
- Read Replicas melhoram performance de leitura.
- RDS automatiza patching e failover.

## 6. Resumo para Revisão
- RDS = banco relacional gerenciado | MySQL, PostgreSQL, Oracle, SQL Server, MariaDB | backup automático | Multi-AZ | alta disponibilidade