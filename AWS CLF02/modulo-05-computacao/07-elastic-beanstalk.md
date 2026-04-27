# AWS Elastic Beanstalk — PaaS para desenvolvedores

## 1. Analogia do Dia a Dia
Elastic Beanstalk é como uma máquina de café automática: você coloca os ingredientes (código), aperta um botão e ela faz todo o trabalho de preparar, servir e limpar, sem precisar saber como funciona por dentro.

## 2. O que é (definição técnica oficial AWS)
AWS Elastic Beanstalk é um serviço PaaS que facilita o deploy, gerenciamento e escalabilidade de aplicações web, cuidando automaticamente da infraestrutura subjacente.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Elastic Beanstalk
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- Plataforma como serviço (PaaS)
- Deploy automático de aplicações
- Gerencia infraestrutura, escalabilidade e monitoramento

PALAVRAS-CHAVE NA PROVA:
→ "PaaS AWS"
→ "deploy automático"
→ "infraestrutura gerenciada"

QUANDO USAR:
✅ Desenvolvedores que querem focar no código
✅ Aplicações web comuns

QUANDO NÃO USAR:
❌ Necessidade de controle total da infraestrutura
❌ Workloads muito customizados

DIFERENCIAIS:
- Suporta várias linguagens (Java, .NET, Python, etc.)
============================================================

## 4. Questões de Fixação
1. O que faz o Elastic Beanstalk?
A) Gerencia bancos de dados
B) Deploy automático de aplicações (correta)
C) Cria backups
D) Gerencia usuários

Explicação:
- B) Correta: Beanstalk faz deploy automático.
- A), C), D) não são funções do Beanstalk.

Armadilha: confundir Beanstalk com EC2 puro.

2. Quando NÃO usar Elastic Beanstalk?
A) Para controle total da infraestrutura (correta)
B) Para aplicações web comuns
C) Para deploy rápido
D) Para escalabilidade automática

Explicação:
- A) Correta: Beanstalk não dá controle total.
- B), C), D) são casos de uso de Beanstalk.

Armadilha: achar que Beanstalk serve para tudo.

## 5. Conceito Senior
- Beanstalk automatiza patching, monitoramento e escalabilidade.
- Permite customização limitada via arquivos de configuração.

## 6. Resumo para Revisão
- Beanstalk = PaaS AWS | deploy automático | infra gerenciada | ideal para dev focar no código | customização limitada