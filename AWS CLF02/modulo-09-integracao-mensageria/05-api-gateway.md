# Amazon API Gateway

## 1. Analogia do Dia a Dia
API Gateway é como a recepção de um prédio comercial: recebe todas as solicitações, verifica quem pode entrar, direciona para o andar certo e pode registrar tudo o que acontece.

## 2. O que é (definição técnica oficial AWS)
Amazon API Gateway é um serviço gerenciado para criar, publicar, monitorar e proteger APIs REST, HTTP e WebSocket, com escalabilidade automática e integração com outros serviços AWS.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: API Gateway
DOMÍNIO DO EXAME: Integração e Mensageria (33%)
============================================================

O QUE É:
- Gerenciamento de APIs REST, HTTP e WebSocket
- Escalabilidade automática
- Integração com Lambda, S3, DynamoDB, etc.

PALAVRAS-CHAVE NA PROVA:
→ "gerenciamento de APIs"
→ "proxy de requisições"
→ "integração com Lambda"

QUANDO USAR:
✅ Expor APIs para clientes externos
✅ Integração com serviços serverless

QUANDO NÃO USAR:
❌ Workloads internos sem necessidade de API
❌ APIs sem requisitos de segurança

DIFERENCIAIS:
- Suporte a autenticação, throttling e monitoramento
============================================================

## 4. Questões de Fixação
1. O que faz o API Gateway?
A) Gerencia APIs REST, HTTP e WebSocket (correta)
B) Gera relatórios de custos
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- A) Correta: API Gateway gerencia APIs.
- B), C), D) não são funções do API Gateway.

Armadilha: confundir API Gateway com ELB.

2. Quando usar API Gateway?
A) Para expor APIs para clientes externos (correta)
B) Para backups
C) Para workloads internos
D) Para cache em memória

Explicação:
- A) Correta: API Gateway é para expor APIs.
- B), C), D) não são casos de uso de API Gateway.

Armadilha: achar que API Gateway é só para REST.

## 5. Conceito Senior
- Suporta autenticação via IAM, Cognito e custom authorizers.
- Permite throttling, caching e monitoramento detalhado.

## 6. Resumo para Revisão
- API Gateway = gerenciamento de APIs | REST/HTTP/WebSocket | integra com Lambda | autenticação e throttling | expor APIs para clientes