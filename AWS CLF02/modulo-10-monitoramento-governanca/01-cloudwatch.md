# Amazon CloudWatch — métricas, logs, alarmes, dashboards

## 1. Analogia do Dia a Dia
CloudWatch é como o painel de instrumentos de um carro: mostra velocidade, combustível, alertas e permite monitorar tudo em tempo real para evitar problemas.

## 2. O que é (definição técnica oficial AWS)
Amazon CloudWatch é um serviço de monitoramento e observabilidade, que coleta métricas, logs, eventos e permite criar alarmes e dashboards para recursos AWS e aplicações customizadas.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: CloudWatch
DOMÍNIO DO EXAME: Monitoramento e Governança (33%)
============================================================

O QUE É:
- Monitoramento de métricas e logs
- Alarmes e dashboards customizáveis
- Observabilidade de recursos AWS

PALAVRAS-CHAVE NA PROVA:
→ "monitoramento de métricas"
→ "logs e alarmes"
→ "dashboards"

QUANDO USAR:
✅ Monitorar performance e disponibilidade
✅ Criar alertas automáticos

QUANDO NÃO USAR:
❌ Ignorar logs e métricas
❌ Ambientes sem requisitos de monitoramento

DIFERENCIAIS:
- Integração com Lambda, EC2, RDS, etc.
============================================================

## 4. Questões de Fixação
1. O que faz o Amazon CloudWatch?
A) Gera relatórios de custos
B) Monitora métricas, logs e cria alarmes (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: CloudWatch monitora e alerta.
- A), C), D) não são funções do CloudWatch.

Armadilha: confundir CloudWatch com CloudTrail.

2. Quando usar CloudWatch?
A) Para monitorar performance e criar alertas (correta)
B) Para backups
C) Para workloads sem monitoramento
D) Para cache em memória

Explicação:
- A) Correta: CloudWatch é para monitoramento.
- B), C), D) não são casos de uso de CloudWatch.

Armadilha: achar que CloudWatch é só para logs.

## 5. Conceito Senior
- CloudWatch Logs Insights permite consultas avançadas em logs.
- Alarmes podem acionar ações automáticas (ex: Auto Scaling).

## 6. Resumo para Revisão
- CloudWatch = métricas, logs, alarmes | dashboards | integra com AWS | automação de alertas | observabilidade completa