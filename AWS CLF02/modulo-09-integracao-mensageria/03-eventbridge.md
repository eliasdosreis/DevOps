# Amazon EventBridge — barramento de eventos

## 1. Analogia do Dia a Dia
EventBridge é como um quadro de avisos digital: vários setores da empresa podem publicar eventos e outros setores podem se inscrever para receber avisos relevantes automaticamente.

## 2. O que é (definição técnica oficial AWS)
Amazon EventBridge é um serviço de barramento de eventos gerenciado, que conecta aplicações usando eventos de AWS, SaaS e aplicações customizadas, permitindo integração desacoplada e reativa.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: EventBridge
DOMÍNIO DO EXAME: Integração e Mensageria (33%)
============================================================

O QUE É:
- Barramento de eventos gerenciado
- Integra AWS, SaaS e aplicações customizadas
- Roteamento flexível de eventos

PALAVRAS-CHAVE NA PROVA:
→ "event-driven"
→ "integração desacoplada"
→ "roteamento de eventos"

QUANDO USAR:
✅ Integração entre múltiplos sistemas
✅ Workloads event-driven

QUANDO NÃO USAR:
❌ Comunicação síncrona
❌ Workloads simples sem eventos

DIFERENCIAIS:
- Suporte a filtros e regras avançadas
============================================================

## 4. Questões de Fixação
1. O que é o Amazon EventBridge?
A) Serviço de banco de dados
B) Barramento de eventos gerenciado (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: EventBridge é barramento de eventos.
- A), C), D) não são EventBridge.

Armadilha: confundir EventBridge com SQS/SNS.

2. Quando usar EventBridge?
A) Para integração desacoplada entre sistemas (correta)
B) Para backups
C) Para workloads síncronos
D) Para cache em memória

Explicação:
- A) Correta: EventBridge é para integração desacoplada.
- B), C), D) não são casos de uso de EventBridge.

Armadilha: achar que EventBridge é igual a SQS.

## 5. Conceito Senior
- Permite integração com SaaS externos (ex: Zendesk, Shopify).
- Suporta regras de roteamento e transformação de eventos.

## 6. Resumo para Revisão
- EventBridge = barramento de eventos | integração desacoplada | AWS/SaaS/custom | regras avançadas | event-driven