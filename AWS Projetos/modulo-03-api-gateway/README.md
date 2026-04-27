# Módulo 3 — API: API Gateway + Lambda

> **Custo:** ~$0.00 | **Pré-requisito:** Módulo 2 concluído | **Duração estimada:** 4-5 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que o **API Gateway é um porteiro de hotel 5 estrelas**.

- **Você** (cliente/aplicação) pede algo ao porteiro — "Quero ver o quarto 305"
- O **porteiro (API Gateway)** verifica seu crachá (autenticação), anota o pedido (logging), limita quantas vezes você pode pedir por minuto (throttling), e então chama o funcionário certo (Lambda)
- O **funcionário (Lambda)** faz o trabalho real e retorna a resposta
- O **porteiro** entrega a resposta formatada para você

Sem o porteiro: você teria que ir direto ao quarto (acesso direto à Lambda — menos seguro, sem controle)

---

## 2. O QUE É (Definição Técnica Sênior)

**Amazon API Gateway:** Serviço gerenciado para criar, publicar, manter, monitorar e proteger APIs em qualquer escala. Suporta REST APIs, HTTP APIs e WebSocket APIs.

**HTTP API vs REST API:**
```
HTTP API (v2):                    REST API (v1):
  ✅ Mais barato (~70% menos)       ✅ Mais funcionalidades
  ✅ Menor latência                  ✅ Usage Plans e API Keys
  ✅ OIDC/OAuth2 nativo             ✅ Request/Response transformations
  ✅ Lambda Proxy simplificado       ✅ AWS WAF integration
  ❌ Sem request validation          ✅ Private APIs (VPC)
  ❌ Sem mock/mock integration       ❌ Mais caro ($3.50/M vs $1/M)
  
  USO: 80% dos casos use HTTP API  USO: APIs enterprise com WAF, keys
```

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 3:
  - HTTP API Gateway: $0.00  (Free Tier: 1M chamadas/mês por 12 meses)
  - Lambda:           $0.00  (Free Tier: 1M invocações — SEMPRE)
  - CloudWatch Logs:  $0.00  (Free Tier: 5 GB/mês)
  - TOTAL:            ~$0.00
  
  ⚠️  Após 12 meses: HTTP API = $1.00/M req + $0.0035/hora para conexões
  
  PARA REFERÊNCIA PRODUÇÃO:
  - 10M req/mês com API HTTP:  ~$9.00/mês
  - 10M req/mês com REST API: ~$35.00/mês
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-lambda-api-handler.py`](./01-lambda-api-handler.py) | Lambda que responde como API REST | CRUD, HTTP methods, status codes |
| [`02-http-api.yaml`](./02-http-api.yaml) | HTTP API no API Gateway | Routes, integrations, stages |
| [`03-api-com-cors.yaml`](./03-api-com-cors.yaml) | CORS para front-end | CORS, preflight, origins |
| [`04-api-com-throttling.yaml`](./04-api-com-throttling.yaml) | Rate limiting e throttling | Throttling, burst, quotas |
| [`05-testar-api.sh`](./05-testar-api.sh) | Testa todos os endpoints com curl | curl, HTTP methods, payloads |
| [`06-limpeza.sh`](./06-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS

### 4.1 Estrutura de uma Requisição REST

```
Cliente → API Gateway → Lambda → Banco/Serviço → Lambda → API Gateway → Cliente

Requisição HTTP:
  Método:  GET / POST / PUT / DELETE / PATCH
  Path:    /produtos/42
  Headers: Authorization: Bearer jwt-token...
           Content-Type: application/json
  Body:    {"nome": "Camiseta", "preco": 49.90}  (apenas PUT/POST)
  Params:  ?categoria=vestuario&pagina=1

Resposta HTTP:
  Código: 200 / 201 / 400 / 401 / 404 / 500
  Headers: Content-Type: application/json
  Body:    {"id": 42, "nome": "Camiseta", ...}
```

### 4.2 Códigos HTTP que um Sênior conhece de cor

```
2xx SUCESSO:
  200 OK              → GET, PUT, DELETE bem-sucedidos
  201 Created         → POST que criou um recurso
  204 No Content      → DELETE sem corpo de resposta
  
4xx ERRO DO CLIENTE:
  400 Bad Request     → Payload inválido, campo obrigatório ausente
  401 Unauthorized    → Não autenticado (sem token)
  403 Forbidden       → Autenticado mas sem permissão
  404 Not Found       → Recurso não existe
  409 Conflict        → Conflito (ex: email já cadastrado)
  422 Unprocessable   → Dados válidos mas semanticamente incorretos
  429 Too Many Reqs   → Throttling/rate limiting ativado
  
5xx ERRO DO SERVIDOR:
  500 Internal Error  → Erro inesperado (bug)
  502 Bad Gateway     → API Gateway não conseguiu chamar a Lambda
  503 Unavailable     → Serviço temporariamente indisponível
  504 Gateway Timeout → Lambda demorou mais que o timeout configurado
```

### 4.3 CORS — Por que existe e como funciona

```
PROBLEMA: Browser bloqueia chamadas JavaScript para domínios diferentes
          (Poluição Cross-Site Request Forgery — CSRF)

EXEMPLO:
  Site em:   https://meu-site.s3-website.amazonaws.com
  API em:    https://abc123.execute-api.us-east-1.amazonaws.com
  → DOMÍNIOS DIFERENTES → Browser BLOQUEIA por padrão!

SOLUÇÃO — CORS Headers:
  Access-Control-Allow-Origin: https://meu-site.s3-website.amazonaws.com
  Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
  Access-Control-Allow-Headers: Content-Type, Authorization

PREFLIGHT REQUEST (antes de POST/PUT/DELETE):
  Browser envia: OPTIONS /api/recurso
  Server responde: 200 OK + CORS headers
  Browser confirma: "ok, pode fazer a chamada real"
```

---

## 5. VERIFICAÇÃO E TROUBLESHOOTING

### Erro: CORS (blocked cross-origin)
```
Causa: API Gateway não está retornando os headers CORS corretos
Solução:
  1. Na HTTP API: habilite CORS na configuração da API
  2. Na Lambda: o response DEVE incluir os headers CORS:
     headers = {
       'Access-Control-Allow-Origin': '*',
       'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
     }
  3. OPTIONS (preflight) deve retornar 200 com os headers corretos
```

### Erro: 502 Bad Gateway
```
Causa: A Lambda retornou um formato de resposta incorreto
Solução: O retorno DEVE ter esta estrutura:
  {
    "statusCode": 200,           ← Obrigatório (INT)
    "headers": {...},            ← Opcional
    "body": "string aqui"       ← Obrigatório (STRING, use json.dumps())
  }
  
  ❌ ERRADO: return {"mensagem": "ok"}
  ✅ CERTO:  return {"statusCode": 200, "body": json.dumps({"mensagem": "ok"})}
```

---

## 6. 🧠 CONCEITO SÊNIOR

**1. HTTP API é quase sempre a escolha certa**  
REST API existe por razões históricas. HTTP API tem menor latência, é mais barata, e suporta JWT authorization nativo. A única razão para REST API é: WAF, Usage Plans, Request Validation, ou APIs privadas.

**2. Lambda Proxy Integration vs Custom Integration**  
Lambda Proxy: API Gateway passa tudo para a Lambda (event completo). A Lambda controla tudo, inclusive os headers de resposta. É o padrão atual e o mais flexível.  
Custom Integration (REST API apenas): API Gateway transforma request/response usando templates VTL. Poderoso mas complexo — usado para integrar com serviços legacy.

**3. Stage Variables para multi-ambiente**  
Use stage variables para apontar para diferentes Lambdas por ambiente:  
`dev` → `lambda-minha-api-dev` / `prod` → `lambda-minha-api-prod`

**4. WebSocket API para tempo real**  
Para chat, notificações em tempo real, jogos multiplayer: API Gateway WebSocket + Lambda. Mantém conexão persistente e pode enviar mensagens de volta ao cliente a qualquer momento.

---

## 7. PERGUNTAS DE ENTREVISTA

**Q: Qual a diferença entre autenticação e autorização no API Gateway?**
> **Resposta esperada:** Autenticação verifica QUEM você é; autorização verifica O QUE você pode fazer. No API Gateway: (1) Lambda Authorizer: executa uma Lambda customizada antes de cada request para validar tokens/headers e retornar uma IAM Policy; (2) JWT Authorizer (HTTP API): valida JWTs contra um OIDC/OAuth2 provider (Cognito, Auth0, etc.) sem escrever código; (3) IAM Auth: usa credenciais AWS para assinar requisições (SigV4) — ideal para comunicação serviço-a-serviço; (4) API Keys: identificação de clientes, mas NÃO é autenticação de segurança — apenas para throttling por cliente.

**Q: Como você protegeria uma API pública de ataques DDoS e uso abusivo?**
> **Resposta esperada:** Camadas de proteção: (1) AWS WAF: regras gerenciadas contra OWASP Top 10, geo-blocking, IP rate limiting; (2) API Gateway Throttling: limits de burst (pico) e rate (requisições/segundo) por stage ou por rota; (3) Usage Plans + API Keys: limites por cliente com quotas mensais; (4) CloudFront na frente: absorve DDoS na borda global, caching para reduzir carga na origem; (5) Lambda Reserved Concurrency: limita quantas execuções simultâneas a Lambda aceita (proteção contra cascading failure); (6) AWS Shield Standard (gratuito) ou Shield Advanced (pago) para proteção DDoS na camada de rede.

---

## ✅ Próximo Módulo

Após executar a limpeza:
👉 **[`../modulo-04-dynamodb/README.md`](../modulo-04-dynamodb/README.md)**
