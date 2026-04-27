# Modelos de serviço: IaaS, PaaS, SaaS

## 1. Analogia do Dia a Dia
Imagine pedir uma pizza:
- IaaS: você recebe os ingredientes e faz tudo em casa.
- PaaS: recebe a pizza pronta para assar.
- SaaS: recebe a pizza já assada, só precisa comer.

## 2. O que é (definição técnica oficial AWS)
- IaaS (Infrastructure as a Service): infraestrutura básica (servidores, rede, armazenamento) entregue como serviço.
- PaaS (Platform as a Service): plataforma pronta para desenvolver, rodar e gerenciar aplicações.
- SaaS (Software as a Service): software pronto, acessado via internet, sem gerenciar infraestrutura.

## 3. Ficha de Estudo Comentada
============================================================
TEMA: Modelos de Serviço
DOMÍNIO DO EXAME: Conceitos de Nuvem (24%)
============================================================

O QUE É:
- IaaS: infraestrutura sob demanda
- PaaS: plataforma pronta para apps
- SaaS: software pronto para uso

PALAVRAS-CHAVE NA PROVA:
→ "IaaS = EC2, VPC"
→ "PaaS = Elastic Beanstalk"
→ "SaaS = Gmail, Salesforce"

QUANDO USAR:
✅ IaaS: controle total, flexibilidade
✅ PaaS: foco no desenvolvimento
✅ SaaS: uso imediato, sem gestão

QUANDO NÃO USAR:
❌ IaaS: se não quer gerenciar nada
❌ PaaS: se precisa de controle total
❌ SaaS: se precisa customizar profundamente

DIFERENCIAIS:
- Cada modelo tem nível diferente de controle e responsabilidade
============================================================

## 4. Questões de Fixação
1. Qual exemplo de IaaS na AWS?
A) Amazon EC2 (correta)
B) Amazon S3
C) AWS Lambda
D) Gmail

Explicação:
- A) Correta: EC2 é IaaS.
- B) S3 é armazenamento.
- C) Lambda é serverless (PaaS).
- D) Gmail é SaaS.

Armadilha: confundir EC2 com SaaS.

2. O que caracteriza SaaS?
A) Infraestrutura gerenciada pelo usuário
B) Plataforma para desenvolvimento
C) Software pronto, sem gestão de infra (correta)
D) Compra de hardware

Explicação:
- C) Correta: SaaS é software pronto.
- A), B), D) não são SaaS.

Armadilha: achar que SaaS exige gestão de servidores.

## 5. Conceito Senior
- A escolha do modelo depende do nível de controle e responsabilidade desejado.
- SaaS reduz custos operacionais, mas limita customização.

## 6. Resumo para Revisão
- IaaS = infra sob demanda | PaaS = plataforma pronta | SaaS = software pronto | cada um tem nível de controle diferente | exemplos: EC2, Beanstalk, Gmail