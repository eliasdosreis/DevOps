# AWS CloudTrail — auditoria de API (revisão aprofundada)

## 1. Analogia do Dia a Dia
CloudTrail é como uma câmera de segurança que grava tudo o que acontece em um prédio: quem entrou, o que fez, quando saiu. Assim, se algo estranho acontecer, é possível investigar.

## 2. O que é (definição técnica oficial AWS)
AWS CloudTrail registra e armazena todas as chamadas de API feitas na conta AWS, permitindo auditoria, rastreamento de ações e detecção de atividades suspeitas.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: CloudTrail
DOMÍNIO DO EXAME: Monitoramento e Governança (33%)
============================================================

O QUE É:
- Auditoria de todas as ações na AWS
- Registro de chamadas de API
- Permite rastrear quem fez o quê, quando e onde

PALAVRAS-CHAVE NA PROVA:
→ "auditoria de API"
→ "registro de ações"
→ "compliance"

QUANDO USAR:
✅ Investigar incidentes
✅ Atender requisitos de compliance

QUANDO NÃO USAR:
❌ Ignorar logs de auditoria
❌ Ambientes sem necessidade de rastreio

DIFERENCIAIS:
- Integra com S3, CloudWatch e Lambda para automação
============================================================

## 4. Questões de Fixação
1. O que faz o AWS CloudTrail?
A) Gera relatórios de custos
B) Audita chamadas de API (correta)
C) Cria backups
D) Gerencia usuários

Explicação:
- B) Correta: CloudTrail audita APIs.
- A), C), D) não são funções do CloudTrail.

Armadilha: confundir CloudTrail com CloudWatch.

2. Para que serve o CloudTrail?
A) Monitorar custos
B) Auditar ações e rastrear atividades (correta)
C) Gerenciar contas
D) Criar buckets S3

Explicação:
- B) Correta: CloudTrail rastreia ações.
- A), C), D) não são funções do CloudTrail.

Armadilha: achar que CloudTrail monitora performance.

## 5. Conceito Senior
- CloudTrail é essencial para investigações forenses.
- Permite automação de respostas a eventos suspeitos.

## 6. Resumo para Revisão
- CloudTrail = auditoria de API | rastreia ações | integra com S3/CloudWatch | essencial para compliance | investigações forenses