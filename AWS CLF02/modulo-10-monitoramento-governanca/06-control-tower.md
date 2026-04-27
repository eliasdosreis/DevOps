# AWS Control Tower — governança multi-account

## 1. Analogia do Dia a Dia
Control Tower é como a administração central de uma rede de filiais: define regras, monitora e padroniza processos para todas as unidades, garantindo que todos sigam as mesmas políticas.

## 2. O que é (definição técnica oficial AWS)
AWS Control Tower é um serviço de governança que facilita a criação, padronização e gestão de ambientes multi-account na AWS, aplicando políticas, automação e monitoramento centralizado.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Control Tower
DOMÍNIO DO EXAME: Monitoramento e Governança (33%)
============================================================

O QUE É:
- Governança centralizada de múltiplas contas
- Automação de landing zones e políticas
- Monitoramento e compliance integrados

PALAVRAS-CHAVE NA PROVA:
→ "multi-account governance"
→ "landing zone"
→ "políticas automatizadas"

QUANDO USAR:
✅ Ambientes com múltiplas contas AWS
✅ Necessidade de padronização e compliance

QUANDO NÃO USAR:
❌ Ambientes pequenos com uma só conta
❌ Ignorar políticas de governança

DIFERENCIAIS:
- Automatiza criação de contas e aplicação de políticas
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Control Tower?
A) Gera relatórios de custos
B) Governança centralizada multi-account (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: Control Tower governa múltiplas contas.
- A), C), D) não são funções do Control Tower.

Armadilha: confundir Control Tower com Organizations.

2. Quando usar Control Tower?
A) Para ambientes multi-account e compliance (correta)
B) Para backups
C) Para workloads simples
D) Para cache em memória

Explicação:
- A) Correta: Control Tower é para governança multi-account.
- B), C), D) não são casos de uso de Control Tower.

Armadilha: achar que Control Tower substitui Organizations.

## 5. Conceito Senior
- Control Tower automatiza landing zones e enforce de políticas.
- Integra com Organizations, Config e CloudTrail.

## 6. Resumo para Revisão
- Control Tower = governança multi-account | landing zone | automação de políticas | compliance centralizado | integra com Organizations/Config