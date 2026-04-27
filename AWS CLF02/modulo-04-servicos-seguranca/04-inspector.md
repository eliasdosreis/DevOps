# AWS Inspector — análise de vulnerabilidades

## 1. Analogia do Dia a Dia
Inspector é como um inspetor de segurança que faz vistoria periódica no prédio, procurando portas destrancadas ou janelas quebradas que podem ser exploradas por invasores.

## 2. O que é (definição técnica oficial AWS)
AWS Inspector é um serviço automatizado que avalia vulnerabilidades e desvios de configuração em instâncias EC2 e workloads, ajudando a manter a segurança e conformidade.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Inspector
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Avaliação automatizada de vulnerabilidades
- Scans em EC2, containers e workloads
- Gera relatórios de findings

PALAVRAS-CHAVE NA PROVA:
→ "vulnerabilidades EC2"
→ "scans automatizados"
→ "findings"

QUANDO USAR:
✅ Manter workloads seguros
✅ Atender requisitos de compliance

QUANDO NÃO USAR:
❌ Ignorar findings
❌ Ambientes sem EC2/containers

DIFERENCIAIS:
- Integra com Security Hub para visão centralizada
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Inspector?
A) Detecta ameaças em tempo real
B) Avalia vulnerabilidades em EC2/containers (correta)
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- B) Correta: Inspector avalia vulnerabilidades.
- A), C), D) não são funções do Inspector.

Armadilha: confundir Inspector com GuardDuty.

2. O que é um "finding" no Inspector?
A) Relatório de vulnerabilidade encontrada (correta)
B) Backup
C) Grupo de usuários
D) Política de acesso

Explicação:
- A) Correta: finding é relatório de vulnerabilidade.
- B), C), D) não são findings.

Armadilha: achar que finding é configuração.

## 5. Conceito Senior
- Inspector automatiza avaliações periódicas, reduzindo riscos.
- Ajuda a cumprir normas como PCI DSS, HIPAA.

## 6. Resumo para Revisão
- Inspector = análise de vulnerabilidades | EC2, containers | findings (relatórios) | integra com Security Hub | compliance facilitado