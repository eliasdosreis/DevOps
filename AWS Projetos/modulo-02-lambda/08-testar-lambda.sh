#!/bin/bash
# ============================================================
# ARQUIVO: 08-testar-lambda.sh
# O QUE FAZ: Invoca a Lambda e verifica os logs no CloudWatch
#
# CONCEITO: Testar Lambda via CLI = forma mais rápida para debug
#           sem precisar abrir o Console AWS
#
# CUSTO: $0.00 — Invocações de teste dentro do Free Tier
# ============================================================

set -e

NOME_FUNCAO="lambda-hello-modulo02"    # ← MUDE se usou nome diferente
REGIAO="us-east-1"

echo "============================================================"
echo "TESTANDO LAMBDA: $NOME_FUNCAO"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# PASSO 1: Verificar que a Lambda existe
# ------------------------------------------------------------
echo "1. Verificando função Lambda..."
aws lambda get-function-configuration \
    --function-name "$NOME_FUNCAO" \
    --query '{Nome:FunctionName,Runtime:Runtime,Memoria:MemorySize,Timeout:Timeout,Estado:State}' \
    --output table

# ------------------------------------------------------------
# PASSO 2: Invocação SÍNCRONA (RequestResponse)
# A CLI espera a resposta antes de continuar
# ------------------------------------------------------------
echo ""
echo "2. Invocação síncrona (aguardando resposta)..."

# O payload deve ser Base64 encoded
PAYLOAD='{"nome": "Estudante AWS", "linguagem": "pt-BR"}'

aws lambda invoke \
    --function-name "$NOME_FUNCAO" \
    --payload "$PAYLOAD" \
    --cli-binary-format raw-in-base64-out \
    --log-type Tail \               # Inclui últimas linhas do log na resposta
    --output json \
    /tmp/resposta-lambda.json | \
    python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
print('Status Code:', data.get('StatusCode'))
if 'LogResult' in data:
    print('\nLogs (últimas linhas):')
    logs = base64.b64decode(data['LogResult']).decode('utf-8')
    print(logs)
if 'FunctionError' in data:
    print('ERRO:', data.get('FunctionError'))
"

echo ""
echo "Resposta da Lambda:"
cat /tmp/resposta-lambda.json | python3 -m json.tool

# ------------------------------------------------------------
# PASSO 3: Invocação ASSÍNCRONA (Event)
# A CLI retorna imediatamente (StatusCode 202) sem esperar
# Use para tarefas demoradas que não precisam de resposta imediata
# ------------------------------------------------------------
echo ""
echo "3. Invocação assíncrona (não espera resposta)..."
aws lambda invoke \
    --function-name "$NOME_FUNCAO" \
    --payload '{"async": true, "tarefa": "processamento-background"}' \
    --cli-binary-format raw-in-base64-out \
    --invocation-type Event \      # Event = assíncrono
    --output json \
    /tmp/resposta-async.json
echo "   ✅ Invocação assíncrona enviada (StatusCode 202)"

# ------------------------------------------------------------
# PASSO 4: Ver logs no CloudWatch
# ------------------------------------------------------------
echo ""
echo "4. Últimas execuções no CloudWatch..."

# Pega o nome do log stream mais recente
LOG_GROUP="/aws/lambda/$NOME_FUNCAO"

# Lista os últimos log streams (1 por invocação, basicamente)
LOG_STREAM=$(aws logs describe-log-streams \
    --log-group-name "$LOG_GROUP" \
    --order-by LastEventTime \
    --descending \
    --max-items 1 \
    --query 'logStreams[0].logStreamName' \
    --output text 2>/dev/null)

if [ -n "$LOG_STREAM" ] && [ "$LOG_STREAM" != "None" ]; then
    echo "   Log Stream: $LOG_GROUP"
    echo "   Últimos eventos:"
    aws logs get-log-events \
        --log-group-name "$LOG_GROUP" \
        --log-stream-name "$LOG_STREAM" \
        --limit 20 \
        --query 'events[].message' \
        --output text 2>/dev/null || echo "   Nenhum log ainda (aguarde alguns segundos)"
else
    echo "   ⚠️  Nenhum log stream encontrado ainda"
fi

# ------------------------------------------------------------
# PASSO 5: Verificar métricas básicas
# ------------------------------------------------------------
echo ""
echo "5. Métricas da função no último minuto..."
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Invocations \
    --dimensions Name=FunctionName,Value="$NOME_FUNCAO" \
    --start-time "$(date -u -d '5 minutes ago' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')" \
    --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --period 300 \
    --statistics Sum \
    --output table 2>/dev/null || echo "   Métricas aparecerão após a primeira invocação"

# ------------------------------------------------------------
# PASSO 6: Testar com payload inválido (ver comportamento de erro)
# ------------------------------------------------------------
echo ""
echo "6. Testando com payload inválido (para ver error handling)..."
aws lambda invoke \
    --function-name "$NOME_FUNCAO" \
    --payload '{"campo_invalido": null}' \
    --cli-binary-format raw-in-base64-out \
    --output json \
    /tmp/resposta-invalida.json
echo "   Resposta com payload inválido:"
cat /tmp/resposta-invalida.json | python3 -m json.tool

echo ""
echo "============================================================"
echo "✅ TESTES CONCLUÍDOS!"
echo ""
echo "🔍 Para ver todos os logs:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGIAO"
echo "   → Log groups → /aws/lambda/$NOME_FUNCAO"
echo ""
echo "📋 PRÓXIMO PASSO: Configure o trigger S3 (template 06)"
echo "============================================================"
