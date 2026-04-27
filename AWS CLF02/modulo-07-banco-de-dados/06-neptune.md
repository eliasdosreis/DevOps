# Amazon Neptune — banco de grafos

## 1. Analogia do Dia a Dia
Neptune é como um mural de conexões de detetive: você pode ligar pessoas, lugares e eventos para descobrir padrões e relações escondidas.

## 2. O que é (definição técnica oficial AWS)
Amazon Neptune é um banco de dados de grafos gerenciado, otimizado para armazenar e consultar relacionamentos complexos entre dados, usando os padrões Gremlin e SPARQL.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon Neptune
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Banco de dados de grafos gerenciado
- Suporte a Gremlin e SPARQL
- Ideal para relacionamentos complexos

PALAVRAS-CHAVE NA PROVA:
→ "banco de grafos"
→ "relacionamentos complexos"
→ "Gremlin/SPARQL"

QUANDO USAR:
✅ Redes sociais, recomendações, fraudes
✅ Consultas de relações entre dados

QUANDO NÃO USAR:
❌ Dados tabulares simples
❌ Workloads sem relações complexas

DIFERENCIAIS:
- Alta performance para consultas de grafos
============================================================

## 4. Questões de Fixação
1. O que é o Amazon Neptune?
A) Banco relacional
B) Banco de grafos gerenciado (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: Neptune é banco de grafos.
- A), C), D) não são Neptune.

Armadilha: confundir Neptune com RDS ou DynamoDB.

2. Quando usar Neptune?
A) Para relacionamentos complexos entre dados (correta)
B) Para dados tabulares simples
C) Para cache em memória
D) Para backups

Explicação:
- A) Correta: Neptune é para grafos.
- B), C), D) não são casos de uso de Neptune.

Armadilha: achar que Neptune é igual a DynamoDB.

## 5. Conceito Senior
- Neptune suporta replicação e alta disponibilidade Multi-AZ.
- Ideal para casos de uso como redes sociais e detecção de fraudes.

## 6. Resumo para Revisão
- Neptune = banco de grafos | Gremlin/SPARQL | relacionamentos complexos | alta performance | ideal para redes sociais e fraudes