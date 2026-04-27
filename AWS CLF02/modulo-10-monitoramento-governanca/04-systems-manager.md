# AWS Systems Manager — gestão de instâncias

## 1. Analogia do Dia a Dia
Systems Manager é como um painel de controle central para gerenciar todos os computadores de uma empresa: você pode atualizar, monitorar, automatizar tarefas e corrigir problemas remotamente.

## 2. O que é (definição técnica oficial AWS)
AWS Systems Manager é um serviço de gestão centralizada de recursos AWS e on-premises, permitindo automação, monitoramento, aplicação de patches, inventário e execução remota de comandos.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Systems Manager
DOMÍNIO DO EXAME: Monitoramento e Governança (33%)
============================================================

O QUE É:
- Gestão centralizada de instâncias e recursos
- Automação, patching, inventário e execução remota
- Suporte a AWS e ambientes on-premises

PALAVRAS-CHAVE NA PROVA:
→ "gestão centralizada"
→ "patching automático"
→ "execução remota"

QUANDO USAR:
✅ Gerenciar múltiplas instâncias
✅ Automatizar tarefas administrativas

QUANDO NÃO USAR:
❌ Ambientes pequenos sem necessidade de automação
❌ Ignorar atualizações de segurança

DIFERENCIAIS:
- Integração com Parameter Store e Secrets Manager
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Systems Manager?
A) Gera relatórios de custos
B) Gerencia instâncias e automatiza tarefas (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: Systems Manager gerencia e automatiza.
- A), C), D) não são funções do Systems Manager.

Armadilha: confundir Systems Manager com CloudWatch.

2. Quando usar Systems Manager?
A) Para gerenciar múltiplas instâncias e automação (correta)
B) Para backups
C) Para workloads sem automação
D) Para cache em memória

Explicação:
- A) Correta: Systems Manager é para gestão centralizada.
- B), C), D) não são casos de uso de Systems Manager.

Armadilha: achar que Systems Manager é só para AWS.

## 5. Conceito Senior
- Permite automação de patching, compliance e inventário.
- Suporta execução remota em ambientes híbridos.

## 6. Resumo para Revisão
- Systems Manager = gestão centralizada | automação | patching e inventário | execução remota | integra com Parameter Store/Secrets Manager