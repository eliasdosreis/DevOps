# Amazon ECS e EKS — containers

## 1. Analogia do Dia a Dia
ECS e EKS são como cozinhas industriais: você pode preparar vários pratos (aplicações) em recipientes separados (containers), cada um com seus ingredientes e receitas, sem misturar sabores.

## 2. O que é (definição técnica oficial AWS)
- Amazon ECS (Elastic Container Service): orquestração de containers Docker gerenciada pela AWS.
- Amazon EKS (Elastic Kubernetes Service): orquestração de containers usando Kubernetes gerenciado.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: ECS e EKS
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- ECS: orquestração nativa AWS para Docker
- EKS: Kubernetes gerenciado

PALAVRAS-CHAVE NA PROVA:
→ "orquestração de containers"
→ "ECS = Docker"
→ "EKS = Kubernetes"

QUANDO USAR:
✅ Aplicações em containers
✅ Necessidade de escalabilidade e automação

QUANDO NÃO USAR:
❌ Workloads monolíticos
❌ Sem necessidade de containers

DIFERENCIAIS:
- EKS é compatível com clusters on-premises
============================================================

## 4. Questões de Fixação
1. O que faz o Amazon ECS?
A) Orquestra containers Docker (correta)
B) Gerencia bancos de dados
C) Cria backups
D) Gerencia usuários

Explicação:
- A) Correta: ECS é para Docker.
- B), C), D) não são ECS.

Armadilha: confundir ECS com EKS.

2. Quando usar o EKS?
A) Para workloads em Kubernetes (correta)
B) Para bancos de dados
C) Para backups
D) Para Lambda

Explicação:
- A) Correta: EKS é Kubernetes.
- B), C), D) não são casos de uso de EKS.

Armadilha: confundir EKS com ECS.

## 5. Conceito Senior
- ECS é mais simples para workloads 100% AWS.
- EKS facilita migração de clusters Kubernetes existentes.

## 6. Resumo para Revisão
- ECS = Docker | EKS = Kubernetes | orquestração de containers | escalabilidade | escolha depende do padrão da aplicação