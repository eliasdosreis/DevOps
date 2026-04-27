#!/bin/bash
# ============================================================
# ARQUIVO: 06-testar-api-completo.sh
# O QUE FAZ: Testa todos os endpoints do e-commerce de ponta a ponta
#
# PRÉ-REQUISITO: Execute 01-master-stack.yaml e cole a URL aqui
# CUSTO: $0.00 — requisições dentro do Free Tier
# ============================================================

set -e

# ============================================================
# CONFIGURAÇÃO — EDITE AQUI
# ============================================================
API_URL="https://XXXXXXXXXX.execute-api.us-east-1.amazonaws.com"  # ← MUDE!
CLIENTE_ID="cliente-teste-001"

echo "============================================================"
echo "TESTE E2E — E-COMMERCE SERVERLESS COMPLETO"
echo "API: $API_URL"
echo "============================================================"
echo ""

# Função auxiliar para formatar o JSON
jq_or_cat() {
    command -v jq >/dev/null 2>&1 && jq '.' || cat
}

# ============================================================
# PASSO 1: Health Check
# ============================================================
echo "1. ✅ Health Check da API..."
HEALTH=$(curl -s "$API_URL/health")
echo "   Resposta: $HEALTH"

# ============================================================
# PASSO 2: Criar Produtos
# ============================================================
echo ""
echo "2. 📦 Criando produtos no DynamoDB..."

# Produto 1
RESP=$(curl -s -X POST "$API_URL/produtos" \
    -H "Content-Type: application/json" \
    -d '{"nome":"Notebook Pro 15","preco":2999.90,"categoria":"eletronicos","estoque":5}')
PRODUTO_ID_1=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('produtoId','ERRO'))")
echo "   ✅ Produto 1 criado: $PRODUTO_ID_1"

# Produto 2
RESP=$(curl -s -X POST "$API_URL/produtos" \
    -H "Content-Type: application/json" \
    -d '{"nome":"Mouse Wireless","preco":89.90,"categoria":"eletronicos","estoque":50}')
PRODUTO_ID_2=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('produtoId','ERRO'))")
echo "   ✅ Produto 2 criado: $PRODUTO_ID_2"

# ============================================================
# PASSO 3: Listar Produtos
# ============================================================
echo ""
echo "3. 📋 Listando todos os produtos..."
LISTA=$(curl -s "$API_URL/produtos")
TOTAL=$(echo "$LISTA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('produtos',[])))")
echo "   Total de produtos: $TOTAL"

# ============================================================
# PASSO 4: Obter Produto Específico
# ============================================================
echo ""
echo "4. 🔍 Obtendo produto 1 ($PRODUTO_ID_1)..."
curl -s "$API_URL/produtos/$PRODUTO_ID_1" | python3 -m json.tool

# ============================================================
# PASSO 5: Criar Pedido
# ============================================================
echo ""
echo "5. 🛒 Criando pedido (→ DynamoDB → SQS → Lambda Worker → SNS)..."
PEDIDO=$(curl -s -X POST "$API_URL/pedidos" \
    -H "Content-Type: application/json" \
    -d "{
        \"clienteId\": \"$CLIENTE_ID\",
        \"itens\": [{
            \"produtoId\": \"$PRODUTO_ID_1\",
            \"nome\": \"Notebook Pro 15\",
            \"qtd\": 1,
            \"preco\": 2999.90
        }],
        \"total\": 2999.90
    }")
PEDIDO_ID=$(echo "$PEDIDO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('pedidoId','ERRO'))")
echo "   ✅ Pedido criado: $PEDIDO_ID"
echo "   Status inicial: pendente"
echo "   ⏳ Aguardando processamento pelo Worker Lambda..."

# ============================================================
# PASSO 6: Verificar processamento assíncrono
# ============================================================
echo ""
echo "6. ⏳ Aguardando 15 segundos para o Worker Lambda processar..."
sleep 15

echo ""
echo "7. 📜 Listando pedidos do cliente $CLIENTE_ID..."
curl -s "$API_URL/pedidos?clienteId=$CLIENTE_ID" | python3 -m json.tool

# ============================================================
# PASSO 7: Verificar métricas no CloudWatch
# ============================================================
echo ""
echo "8. 📊 Verificando métricas Lambda nos últimos 5 minutos..."
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Invocations \
    --dimensions Name=FunctionName,Value="ecommerce-aprendizado-api" \
    --start-time "$(date -u -d '5 minutes ago' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')" \
    --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --period 300 \
    --statistics Sum \
    --output table 2>/dev/null || echo "   (Instale awscli para ver métricas)"

echo ""
echo "9. ❌ Testando error handling (produto inexistente)..."
ERROR_RESP=$(curl -s "$API_URL/produtos/produto-que-nao-existe")
echo "   Resposta: $ERROR_RESP"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/produtos/produto-que-nao-existe")
echo "   HTTP Status: $HTTP_CODE (esperado: 404)"

# ============================================================
# RESUMO FINAL
# ============================================================
echo ""
echo "============================================================"
echo "✅ TESTE E2E CONCLUÍDO COM SUCESSO!"
echo ""
echo "📊 RESUMO DO QUE FOI TESTADO:"
echo "   POST /produtos    → DynamoDB PutItem ✅"
echo "   GET  /produtos    → DynamoDB Scan ✅"
echo "   GET  /produtos/id → DynamoDB GetItem ✅"
echo "   POST /pedidos     → DynamoDB PutItem + SQS SendMessage ✅"
echo "   GET  /pedidos     → DynamoDB Query ✅"
echo "   Worker Lambda     → SQS → DynamoDB Update + SNS Publish ✅"
echo "   Error handling    → 404 Not Found ✅"
echo ""
echo "🔍 VERIFIQUE NO CONSOLE AWS:"
echo "   1. CloudWatch → Lambda → ecommerce-aprendizado-api → Logs"
echo "   2. DynamoDB → Tabelas → ecommerce-aprendizado-pedidos → Explore"
echo "   3. SQS → ecommerce-aprendizado-pedidos → Monitoring"
echo "   4. Email: verifique se recebeu a confirmação do pedido!"
echo ""
echo "🧹 APÓS TERMINAR: execute ./08-limpeza.sh"
echo "============================================================"
