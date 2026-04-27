# EC2: tipos de instância (On-Demand, Reserved, Spot, Savings Plans)

## 1. Analogia do Dia a Dia
Escolher o tipo de instância EC2 é como escolher entre alugar um carro por hora (On-Demand), por um mês com desconto (Reserved), pegar um carro de leilão quando está barato (Spot) ou assinar um plano de economia (Savings Plans).

## 2. O que é (definição técnica oficial AWS)
- On-Demand: paga por hora/segundo, sem compromisso
- Reserved: reserva por 1 ou 3 anos, com desconto
- Spot: usa capacidade ociosa, até 90% mais barato, pode ser interrompido
- Savings Plans: compromisso de uso, flexível entre tipos de instância

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: EC2 Tipos de Instância
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- On-Demand: flexível, sem compromisso
- Reserved: desconto por compromisso
- Spot: barato, mas pode ser interrompido
- Savings Plans: economia flexível

PALAVRAS-CHAVE NA PROVA:
→ "On-Demand = flexível"
→ "Reserved = desconto"
→ "Spot = capacidade ociosa"
→ "Savings Plans = compromisso flexível"

QUANDO USAR:
✅ On-Demand: cargas variáveis
✅ Reserved: workloads previsíveis
✅ Spot: tarefas não críticas
✅ Savings Plans: economia planejada

QUANDO NÃO USAR:
❌ Spot para workloads críticos
❌ Reserved para cargas imprevisíveis

DIFERENCIAIS:
- Savings Plans cobre EC2 e Fargate
============================================================

## 4. Questões de Fixação
1. O que caracteriza uma instância Spot?
A) Sempre disponível
B) Pode ser interrompida, mais barata (correta)
C) Compromisso de 1 ano
D) Uso exclusivo

Explicação:
- B) Correta: Spot é barata, mas pode ser interrompida.
- A), C), D) não são Spot.

Armadilha: confundir Spot com Reserved.

2. Quando usar Reserved Instances?
A) Para cargas imprevisíveis
B) Para workloads previsíveis e de longo prazo (correta)
C) Para tarefas não críticas
D) Para workloads serverless

Explicação:
- B) Correta: Reserved é para previsibilidade.
- A), C), D) não são casos ideais.

Armadilha: achar que Reserved é sempre melhor.

## 5. Conceito Senior
- Savings Plans oferecem flexibilidade maior que Reserved.
- Spot pode ser usado para economizar em workloads tolerantes a falhas.

## 6. Resumo para Revisão
- On-Demand = flexível | Reserved = desconto | Spot = barato/interrompível | Savings Plans = economia flexível | escolha impacta custo e risco