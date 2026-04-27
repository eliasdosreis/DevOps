# AWS Service Catalog

## 1. Analogia do Dia a Dia
Service Catalog é como um catálogo de produtos de uma loja: a empresa define quais produtos (serviços e recursos) estão disponíveis para os funcionários, padronizando e controlando o que pode ser usado.

## 2. O que é (definição técnica oficial AWS)
AWS Service Catalog permite criar, gerenciar e distribuir portfólios de recursos e serviços aprovados, garantindo padronização, compliance e controle de custos.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Service Catalog
DOMÍNIO DO EXAME: Monitoramento e Governança (33%)
============================================================

O QUE É:
- Catálogo de recursos e serviços aprovados
- Padronização e controle de uso
- Gerenciamento de portfólios e permissões

PALAVRAS-CHAVE NA PROVA:
→ "catálogo de serviços"
→ "padronização de recursos"
→ "controle de custos"

QUANDO USAR:
✅ Empresas que querem padronizar recursos
✅ Controle de compliance e custos

QUANDO NÃO USAR:
❌ Ambientes pequenos sem necessidade de padronização
❌ Ignorar controle de permissões

DIFERENCIAIS:
- Integração com IAM, CloudFormation e Control Tower
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Service Catalog?
A) Gera relatórios de custos
B) Gerencia catálogo de recursos aprovados (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: Service Catalog gerencia portfólios.
- A), C), D) não são funções do Service Catalog.

Armadilha: confundir Service Catalog com Marketplace.

2. Quando usar Service Catalog?
A) Para padronizar recursos e controlar custos (correta)
B) Para backups
C) Para workloads sem padronização
D) Para cache em memória

Explicação:
- A) Correta: Service Catalog é para padronização.
- B), C), D) não são casos de uso de Service Catalog.

Armadilha: achar que Service Catalog é só para grandes empresas.

## 5. Conceito Senior
- Permite automação de provisionamento via CloudFormation.
- Ajuda a evitar shadow IT e uso não autorizado.

## 6. Resumo para Revisão
- Service Catalog = catálogo de recursos aprovados | padronização | controle de custos | integra com IAM/CloudFormation | compliance facilitado