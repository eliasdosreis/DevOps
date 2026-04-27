# Database Migration Service (DMS)

## 1. Analogia do Dia a Dia
DMS é como uma transportadora especializada em mudanças: ela leva seus dados de uma casa (banco de dados) para outra, sem perder nada e com o mínimo de interrupção.

## 2. O que é (definição técnica oficial AWS)
AWS Database Migration Service (DMS) é um serviço gerenciado para migrar bancos de dados para a AWS, com suporte a migrações homogêneas (mesmo engine) e heterogêneas (diferentes engines).

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS DMS
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Migração de bancos de dados para AWS
- Suporte a migração homogênea e heterogênea
- Minimiza downtime

PALAVRAS-CHAVE NA PROVA:
→ "migração de banco de dados"
→ "downtime mínimo"
→ "homogênea/heterogênea"

QUANDO USAR:
✅ Migração para AWS
✅ Mudança de engine de banco

QUANDO NÃO USAR:
❌ Ambientes sem necessidade de migração
❌ Dados não estruturados

DIFERENCIAIS:
- Suporte a replicação contínua
============================================================

## 4. Questões de Fixação
1. O que faz o AWS DMS?
A) Cria backups
B) Migra bancos de dados para AWS (correta)
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- B) Correta: DMS é para migração.
- A), C), D) não são funções do DMS.

Armadilha: confundir DMS com backup.

2. O que é migração heterogênea?
A) Entre bancos do mesmo tipo
B) Entre bancos de tipos diferentes (correta)
C) Entre buckets S3
D) Entre contas AWS

Explicação:
- B) Correta: heterogênea = engines diferentes.
- A), C), D) não são migração heterogênea.

Armadilha: achar que DMS só migra bancos iguais.

## 5. Conceito Senior
- DMS pode ser usado para replicação contínua e sincronização.
- Suporta migração de bancos on-premises e cloud.

## 6. Resumo para Revisão
- DMS = migração de bancos | downtime mínimo | homogênea/heterogênea | replicação contínua | suporta múltiplos engines