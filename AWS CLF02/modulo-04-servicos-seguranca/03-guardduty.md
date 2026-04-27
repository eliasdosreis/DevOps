# Amazon GuardDuty — detecção de ameaças com ML

## 1. Analogia do Dia a Dia
GuardDuty é como um alarme inteligente em casa: ele aprende o que é normal, detecta comportamentos estranhos e avisa se algo suspeito acontecer.

## 2. O que é (definição técnica oficial AWS)
Amazon GuardDuty é um serviço de detecção de ameaças que usa machine learning para identificar atividades maliciosas e anomalias em contas e workloads AWS.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: GuardDuty
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Detecção automática de ameaças
- Usa machine learning e feeds de ameaças
- Gera alertas (findings) em tempo real

PALAVRAS-CHAVE NA PROVA:
→ "detecção de ameaças"
→ "machine learning"
→ "findings"

QUANDO USAR:
✅ Monitorar contas e workloads AWS
✅ Detectar atividades suspeitas

QUANDO NÃO USAR:
❌ Ambientes sem necessidade de monitoramento
❌ Ignorar alertas gerados

DIFERENCIAIS:
- Não exige instalação de agentes
============================================================

## 4. Questões de Fixação
1. O que faz o Amazon GuardDuty?
A) Cria backups
B) Detecta ameaças usando ML (correta)
C) Gerencia usuários
D) Protege contra DDoS

Explicação:
- B) Correta: GuardDuty detecta ameaças.
- A), C), D) não são funções do GuardDuty.

Armadilha: confundir com Shield (DDoS).

2. O que é um "finding" no GuardDuty?
A) Backup
B) Alerta de ameaça detectada (correta)
C) Grupo de usuários
D) Política de acesso

Explicação:
- B) Correta: finding é alerta.
- A), C), D) não são findings.

Armadilha: achar que finding é configuração.

## 5. Conceito Senior
- GuardDuty pode ser integrado com Lambda para resposta automática.
- Ajuda a cumprir requisitos de compliance de monitoramento.

## 6. Resumo para Revisão
- GuardDuty = detecção de ameaças | machine learning | findings (alertas) | sem agentes | integra com Lambda para resposta