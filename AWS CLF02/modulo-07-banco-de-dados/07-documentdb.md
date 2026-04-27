# Amazon DocumentDB — compatível com MongoDB

## 1. Analogia do Dia a Dia
DocumentDB é como uma biblioteca digital onde você pode guardar livros (documentos) em qualquer formato, sem precisar de prateleiras fixas, e encontrar rapidamente o que precisa.

## 2. O que é (definição técnica oficial AWS)
Amazon DocumentDB é um banco de dados de documentos gerenciado, compatível com MongoDB, projetado para alta disponibilidade, escalabilidade e performance.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon DocumentDB
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Banco de dados de documentos (NoSQL)
- Compatível com MongoDB
- Gerenciado, escalável e de alta disponibilidade

PALAVRAS-CHAVE NA PROVA:
→ "NoSQL documentos"
→ "compatível MongoDB"
→ "alta disponibilidade"

QUANDO USAR:
✅ Aplicações que usam MongoDB
✅ Dados semi-estruturados (JSON)

QUANDO NÃO USAR:
❌ Requisitos de SQL relacional
❌ Workloads que não usam documentos

DIFERENCIAIS:
- Migração fácil de MongoDB para AWS
============================================================

## 4. Questões de Fixação
1. O que é o Amazon DocumentDB?
A) Banco relacional
B) Banco de documentos compatível com MongoDB (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: DocumentDB é NoSQL de documentos.
- A), C), D) não são DocumentDB.

Armadilha: confundir DocumentDB com DynamoDB.

2. Quando usar DocumentDB?
A) Para dados semi-estruturados em formato JSON (correta)
B) Para workloads SQL
C) Para cache em memória
D) Para backups

Explicação:
- A) Correta: DocumentDB é para documentos JSON.
- B), C), D) não são casos de uso de DocumentDB.

Armadilha: achar que DocumentDB é igual a DynamoDB.

## 5. Conceito Senior
- DocumentDB facilita migração de aplicações MongoDB.
- Suporta replicação e alta disponibilidade Multi-AZ.

## 6. Resumo para Revisão
- DocumentDB = NoSQL documentos | compatível MongoDB | alta disponibilidade | migração fácil | ideal para dados semi-estruturados