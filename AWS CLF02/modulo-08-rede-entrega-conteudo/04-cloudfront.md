# Amazon CloudFront — CDN global

## 1. Analogia do Dia a Dia
CloudFront é como uma rede de filiais espalhadas pelo mundo, onde os clientes pegam produtos rapidamente, sem esperar vir do estoque central.

## 2. O que é (definição técnica oficial AWS)
Amazon CloudFront é um serviço de Content Delivery Network (CDN) global, que distribui conteúdo com baixa latência a partir de edge locations próximas ao usuário.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: CloudFront
DOMÍNIO DO EXAME: Rede e Entrega de Conteúdo (33%)
============================================================

O QUE É:
- CDN global da AWS
- Distribuição de conteúdo com baixa latência
- Integração com S3, ALB, EC2, Lambda@Edge

PALAVRAS-CHAVE NA PROVA:
→ "CDN global"
→ "edge location"
→ "baixa latência"

QUANDO USAR:
✅ Sites globais, streaming, APIs
✅ Reduzir latência para usuários

QUANDO NÃO USAR:
❌ Conteúdo privado sem criptografia
❌ Aplicações só internas

DIFERENCIAIS:
- Integra com WAF e Shield para segurança
============================================================

## 4. Questões de Fixação
1. O que é o Amazon CloudFront?
A) Serviço de banco de dados
B) CDN global para entrega de conteúdo (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: CloudFront é CDN.
- A), C), D) não são CloudFront.

Armadilha: confundir CloudFront com S3.

2. Quando usar CloudFront?
A) Para sites globais e streaming (correta)
B) Para backups
C) Para workloads internos
D) Para banco de dados

Explicação:
- A) Correta: CloudFront é para entrega global.
- B), C), D) não são casos de uso de CloudFront.

Armadilha: achar que CloudFront é só para sites estáticos.

## 5. Conceito Senior
- CloudFront pode usar Lambda@Edge para customização.
- Ajuda a cumprir requisitos de compliance de latência e segurança.

## 6. Resumo para Revisão
- CloudFront = CDN global | edge locations | baixa latência | integra com S3/WAF/Shield | entrega rápida de conteúdo