# Amazon ElastiCache — cache em memória (Redis/Memcached)

## 1. Analogia do Dia a Dia
ElastiCache é como um bloco de notas ao lado do computador: você anota informações que precisa acessar rápido, sem ter que buscar tudo de novo no arquivo principal.

## 2. O que é (definição técnica oficial AWS)
Amazon ElastiCache é um serviço gerenciado de cache em memória, compatível com Redis e Memcached, usado para acelerar aplicações ao armazenar dados temporários de acesso frequente.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: ElastiCache
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Cache em memória gerenciado
- Suporte a Redis e Memcached
- Reduz latência e carga em bancos de dados

PALAVRAS-CHAVE NA PROVA:
→ "cache em memória"
→ "Redis/Memcached"
→ "reduzir latência"

QUANDO USAR:
✅ Aplicações que exigem resposta rápida
✅ Reduzir consultas ao banco principal

QUANDO NÃO USAR:
❌ Dados que não podem ser perdidos
❌ Workloads que não se beneficiam de cache

DIFERENCIAIS:
- Suporte a alta disponibilidade e replicação
============================================================

## 4. Questões de Fixação
1. O que é o ElastiCache?
A) Banco relacional
B) Cache em memória gerenciado (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: ElastiCache é cache em memória.
- A), C), D) não são ElastiCache.

Armadilha: confundir ElastiCache com RDS ou S3.

2. Quando NÃO usar ElastiCache?
A) Para dados críticos que não podem ser perdidos (correta)
B) Para acelerar respostas
C) Para reduzir consultas ao banco
D) Para workloads de leitura intensiva

Explicação:
- A) Correta: cache pode ser volátil.
- B), C), D) são casos de uso de ElastiCache.

Armadilha: achar que cache substitui banco de dados.

## 5. Conceito Senior
- ElastiCache pode ser usado para sessões, filas e ranking.
- Redis suporta persistência opcional.

## 6. Resumo para Revisão
- ElastiCache = cache em memória | Redis/Memcached | reduz latência | não serve para dados críticos | acelera aplicações