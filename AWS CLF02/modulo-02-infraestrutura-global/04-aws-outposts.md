# AWS Outposts (nuvem no seu datacenter)

## 1. Analogia do Dia a Dia
AWS Outposts é como ter uma mini-filial da AWS dentro da sua empresa: você recebe racks prontos, instala no seu prédio e usa os mesmos serviços da nuvem, mas localmente.

## 2. O que é (definição técnica oficial AWS)
AWS Outposts é uma solução de infraestrutura híbrida que leva hardware e serviços AWS para dentro do datacenter do cliente, permitindo rodar workloads localmente com gerenciamento centralizado pela AWS.

## 3. Ficha de Estudo Comentada
============================================================
TEMA: AWS Outposts
DOMÍNIO DO EXAME: Infraestrutura Global (Domínio 1 + 3)
============================================================

O QUE É:
- Hardware AWS instalado no cliente
- Gerenciado pela AWS
- Permite workloads híbridos

PALAVRAS-CHAVE NA PROVA:
→ "híbrido"
→ "AWS no datacenter"
→ "gerenciamento centralizado"

QUANDO USAR:
✅ Requisitos de latência ultra baixa
✅ Compliance que exige dados locais
✅ Integração com workloads on-premises

QUANDO NÃO USAR:
❌ Se tudo pode rodar 100% na nuvem
❌ Se não há equipe para gerenciar hardware local

DIFERENCIAIS:
- Permite usar APIs AWS localmente
============================================================

## 4. Questões de Fixação
1. O que é o AWS Outposts?
A) Serviço de backup
B) Hardware AWS no datacenter do cliente (correta)
C) Serviço de banco de dados
D) CDN global

Explicação:
- B) Correta: Outposts é hardware local.
- A), C), D) não são Outposts.

Armadilha: confundir Outposts com CloudFront.

2. Quando usar Outposts?
A) Para workloads 100% na nuvem
B) Para latência ultra baixa e compliance local (correta)
C) Para backup em fita
D) Para monitorar custos

Explicação:
- B) Correta: Outposts é para requisitos locais.
- A), C), D) não são motivos reais.

Armadilha: achar que Outposts é só para backup.

## 5. Conceito Senior
- Outposts exige integração de rede e segurança local.
- Permite migração gradual para nuvem.

## 6. Resumo para Revisão
- Outposts = AWS no datacenter | híbrido | latência ultra baixa | compliance local | gerenciamento centralizado