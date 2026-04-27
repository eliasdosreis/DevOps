# Amazon Redshift — data warehouse

## 1. Analogia do Dia a Dia
Redshift é como um grande arquivo central onde você reúne todos os relatórios e dados históricos da empresa para fazer análises profundas e descobrir tendências.

## 2. O que é (definição técnica oficial AWS)
Amazon Redshift é um serviço de data warehouse totalmente gerenciado, otimizado para análise de grandes volumes de dados, com alta performance e integração com ferramentas de BI.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon Redshift
DOMÍNIO DO EXAME: Banco de Dados (33%)
============================================================

O QUE É:
- Data warehouse gerenciado
- Análise de grandes volumes de dados
- Integração com S3, BI, ETL

PALAVRAS-CHAVE NA PROVA:
→ "data warehouse AWS"
→ "análise de dados em larga escala"
→ "integração com S3"

QUANDO USAR:
✅ Relatórios analíticos
✅ BI e análise de dados históricos

QUANDO NÃO USAR:
❌ Workloads transacionais
❌ Pequenos volumes de dados

DIFERENCIAIS:
- Suporte a consultas paralelas e compressão de dados
============================================================

## 4. Questões de Fixação
1. O que é o Amazon Redshift?
A) Banco relacional transacional
B) Data warehouse gerenciado (correta)
C) Serviço de armazenamento de objetos
D) CDN

Explicação:
- B) Correta: Redshift é data warehouse.
- A), C), D) não são Redshift.

Armadilha: confundir Redshift com RDS.

2. Quando usar Redshift?
A) Para análise de grandes volumes de dados (correta)
B) Para workloads transacionais
C) Para cache em memória
D) Para backups

Explicação:
- A) Correta: Redshift é para análise em larga escala.
- B), C), D) não são casos de uso de Redshift.

Armadilha: achar que Redshift substitui RDS.

## 5. Conceito Senior
- Redshift Spectrum permite consultar dados diretamente no S3.
- Suporta escalabilidade elástica e integração com Lake Formation.

## 6. Resumo para Revisão
- Redshift = data warehouse | análise de grandes volumes | integração S3/BI | consultas paralelas | não é para transações