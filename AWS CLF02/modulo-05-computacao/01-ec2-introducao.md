# Amazon EC2: conceito e introdução

## 1. Analogia do Dia a Dia
EC2 é como alugar um quarto de hotel: você escolhe o tamanho, paga pelo tempo de uso e pode instalar o que quiser durante sua estadia.

## 2. O que é (definição técnica oficial AWS)
Amazon Elastic Compute Cloud (EC2) é um serviço que permite criar e gerenciar servidores virtuais (instâncias) na nuvem, com controle total sobre o sistema operacional e aplicações.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon EC2
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- Servidores virtuais sob demanda
- Controle total do SO e apps
- Diversos tipos e tamanhos de instância

PALAVRAS-CHAVE NA PROVA:
→ "instância EC2"
→ "servidor virtual"
→ "controle total"

QUANDO USAR:
✅ Quando precisa de flexibilidade total
✅ Aplicações legadas ou customizadas

QUANDO NÃO USAR:
❌ Para workloads serverless
❌ Se não quer gerenciar SO

DIFERENCIAIS:
- Paga só pelo tempo de uso
============================================================

## 4. Questões de Fixação
1. O que é uma instância EC2?
A) Serviço de banco de dados
B) Servidor virtual na nuvem (correta)
C) Serviço de armazenamento
D) CDN

Explicação:
- B) Correta: EC2 é servidor virtual.
- A), C), D) não são EC2.

Armadilha: confundir EC2 com S3 ou RDS.

2. Quando NÃO usar EC2?
A) Para workloads serverless (correta)
B) Para aplicações customizadas
C) Para controle total do SO
D) Para aplicações legadas

Explicação:
- A) Correta: serverless usa Lambda.
- B), C), D) são casos de uso de EC2.

Armadilha: achar que EC2 é sempre a melhor escolha.

## 5. Conceito Senior
- EC2 permite auto scaling e integração com outros serviços AWS.
- Escolher o tipo certo de instância reduz custos.

## 6. Resumo para Revisão
- EC2 = servidor virtual | controle total | paga por uso | auto scaling | escolha do tipo impacta custo