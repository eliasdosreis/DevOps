# Amazon SNS — notificações pub/sub

## 1. Analogia do Dia a Dia
SNS é como um sistema de alto-falante em uma escola: um aviso é enviado e todos que estão ouvindo (inscritos) recebem a mensagem ao mesmo tempo.

## 2. O que é (definição técnica oficial AWS)
Amazon Simple Notification Service (SNS) é um serviço gerenciado de notificações pub/sub, que entrega mensagens a múltiplos assinantes via push (e-mail, SMS, Lambda, SQS, HTTP).

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon SNS
DOMÍNIO DO EXAME: Integração e Mensageria (33%)
============================================================

O QUE É:
- Notificações pub/sub gerenciadas
- Entrega para múltiplos assinantes
- Suporte a vários protocolos (e-mail, SMS, Lambda, SQS, HTTP)

PALAVRAS-CHAVE NA PROVA:
→ "pub/sub"
→ "notificações push"
→ "múltiplos assinantes"

QUANDO USAR:
✅ Notificações em massa
✅ Integração com SQS, Lambda

QUANDO NÃO USAR:
❌ Comunicação ponto a ponto
❌ Workloads que exigem confirmação de recebimento

DIFERENCIAIS:
- Integração nativa com outros serviços AWS
============================================================

## 4. Questões de Fixação
1. O que é o Amazon SNS?
A) Serviço de banco de dados
B) Notificações pub/sub gerenciadas (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: SNS é pub/sub.
- A), C), D) não são SNS.

Armadilha: confundir SNS com SQS.

2. Quando usar SNS?
A) Para notificações em massa (correta)
B) Para backups
C) Para workloads síncronos
D) Para cache em memória

Explicação:
- A) Correta: SNS é para notificações.
- B), C), D) não são casos de uso de SNS.

Armadilha: achar que SNS garante ordem de entrega.

## 5. Conceito Senior
- SNS pode acionar Lambda, SQS, HTTP endpoints e SMS.
- Suporta filtragem de mensagens por atributos.

## 6. Resumo para Revisão
- SNS = notificações pub/sub | push para múltiplos assinantes | integra com SQS/Lambda | vários protocolos | filtragem por atributos