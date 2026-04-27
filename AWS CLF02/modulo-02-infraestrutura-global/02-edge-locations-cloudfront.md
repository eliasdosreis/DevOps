# Edge Locations e CloudFront

## 1. Analogia do Dia a Dia
Edge Locations são como filiais de uma grande rede de lojas espalhadas pelo mundo, onde você pode pegar produtos rapidamente, sem esperar vir do estoque central.

## 2. O que é (definição técnica oficial AWS)
- Edge Location: ponto de presença global da AWS para entrega de conteúdo com baixa latência
- Amazon CloudFront: serviço de CDN (Content Delivery Network) que usa Edge Locations para distribuir conteúdo rapidamente aos usuários

## 3. Ficha de Estudo Comentada
============================================================
TEMA: Edge Locations e CloudFront
DOMÍNIO DO EXAME: Infraestrutura Global (Domínio 1 + 3)
============================================================

O QUE É:
- Edge Location: ponto de presença para cache e entrega de conteúdo
- CloudFront: CDN global da AWS

PALAVRAS-CHAVE NA PROVA:
→ "baixa latência"
→ "CDN"
→ "entrega de conteúdo"

QUANDO USAR:
✅ Sites globais
✅ Streaming de vídeo
✅ Reduzir latência para usuários

QUANDO NÃO USAR:
❌ Conteúdo privado sem criptografia
❌ Aplicações só internas

DIFERENCIAIS:
- CloudFront pode proteger contra ataques DDoS
============================================================

## 4. Questões de Fixação
1. O que é uma Edge Location?
A) Datacenter principal
B) Ponto de presença para entrega de conteúdo (correta)
C) Serviço de banco de dados
D) Região AWS

Explicação:
- B) Correta: Edge Location é ponto de presença.
- A), C), D) não são Edge Locations.

Armadilha: confundir Edge Location com AZ.

2. Para que serve o Amazon CloudFront?
A) Gerenciar bancos de dados
B) Entregar conteúdo globalmente com baixa latência (correta)
C) Monitorar custos
D) Gerenciar contas

Explicação:
- B) Correta: CloudFront é CDN.
- A), C), D) não são funções do CloudFront.

Armadilha: achar que CloudFront é só para sites estáticos.

## 5. Conceito Senior
- CloudFront pode integrar com WAF para segurança.
- Edge Locations ajudam a cumprir requisitos de latência e compliance.

## 6. Resumo para Revisão
- Edge Location = ponto de presença | CloudFront = CDN global | baixa latência | entrega rápida de conteúdo | integra com WAF para segurança