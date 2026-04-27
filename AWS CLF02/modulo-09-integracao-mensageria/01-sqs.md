# Amazon SQS — fila de mensagens (desacoplamento)

## 1. Analogia do Dia a Dia
SQS é como uma fila de senhas em um banco: cada cliente pega uma senha (mensagem), espera sua vez e é atendido por ordem de chegada, sem tumulto.

## 2. O que é (definição técnica oficial AWS)
Amazon Simple Queue Service (SQS) é um serviço gerenciado de filas de mensagens, usado para desacoplar e escalar componentes de aplicações distribuídas.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon SQS
DOMÍNIO DO EXAME: Integração e Mensageria (33%)
============================================================

O QUE É:
- Fila de mensagens gerenciada
- Desacoplamento de sistemas
- Suporte a filas padrão e FIFO

PALAVRAS-CHAVE NA PROVA:
→ "fila de mensagens"
→ "desacoplamento"
→ "FIFO/SQS padrão"

QUANDO USAR:
✅ Processamento assíncrono
✅ Escalar aplicações distribuídas

QUANDO NÃO USAR:
❌ Comunicação síncrona
❌ Workloads que exigem entrega instantânea

DIFERENCIAIS:
- Suporte a Dead Letter Queues (DLQ)
============================================================

## 4. Questões de Fixação
1. O que é o Amazon SQS?
A) Serviço de banco de dados
B) Fila de mensagens gerenciada (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: SQS é fila de mensagens.
- A), C), D) não são SQS.

Armadilha: confundir SQS com SNS.

2. Quando usar SQS FIFO?
A) Quando a ordem das mensagens é importante (correta)
B) Para backups
C) Para workloads síncronos
D) Para cache em memória

Explicação:
- A) Correta: FIFO garante ordem.
- B), C), D) não são casos de uso de FIFO.

Armadilha: achar que SQS padrão garante ordem.

## 5. Conceito Senior
- DLQ ajuda a tratar mensagens com erro.
- SQS escala automaticamente conforme demanda.

## 6. Resumo para Revisão
- SQS = fila de mensagens | desacoplamento | padrão/FIFO | DLQ | processamento assíncrono