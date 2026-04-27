#!/bin/bash
# ============================================================
# ARQUIVO: 02-budget-alert.sh
# O QUE FAZ: Cria um alerta de orçamento para avisar se
#             os gastos ultrapassarem $5/mês na conta AWS
#
# ANALOGIA: É como configurar um limite de gasto no cartão
#           de crédito — você recebe um SMS antes de estourar.
#
# CUSTO: $0.00 — Os 2 primeiros budgets são gratuitos
# ============================================================

set -e

# ============================================================
# CONFIGURAÇÕES — EDITE AQUI
# ============================================================
EMAIL="seu-email@exemplo.com"    # ← MUDE PARA SEU EMAIL!
LIMITE_USD="5"                   # Alerta quando gastar $5
NOME_BUDGET="limite-aprendizado-aws"

# Pega o Account ID automaticamente
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "============================================================"
echo "CRIANDO BUDGET ALERT"
echo "  Conta:  $ACCOUNT_ID"
echo "  Limite: \$$LIMITE_USD/mês"
echo "  Email:  $EMAIL"
echo "============================================================"

# ------------------------------------------------------------
# PASSO 1: Criar arquivo JSON de configuração do budget
# Budget = "envelope de dinheiro" — você define quanto pode gastar
# ------------------------------------------------------------
cat > /tmp/budget-config.json << EOF
{
    "BudgetName": "$NOME_BUDGET",
    "BudgetLimit": {
        "Amount": "$LIMITE_USD",
        "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostTypes": {
        "IncludeTax": true,
        "IncludeSubscription": true,
        "UseBlended": false,
        "IncludeRefund": false,
        "IncludeCredit": false,
        "IncludeUpfront": true,
        "IncludeRecurring": true,
        "IncludeOtherSubscription": true,
        "IncludeSupport": true,
        "IncludeDiscount": true,
        "UseAmortized": false
    }
}
EOF

# ------------------------------------------------------------
# PASSO 2: Criar arquivo JSON de notificações
# Notifica quando atingir 80% do limite ($4) E quando ultrapassar
# ------------------------------------------------------------
cat > /tmp/budget-notificacoes.json << EOF
[
    {
        "Notification": {
            "NotificationType": "ACTUAL",
            "ComparisonOperator": "GREATER_THAN",
            "Threshold": 80,
            "ThresholdType": "PERCENTAGE"
        },
        "Subscribers": [
            {
                "SubscriptionType": "EMAIL",
                "Address": "$EMAIL"
            }
        ]
    },
    {
        "Notification": {
            "NotificationType": "ACTUAL",
            "ComparisonOperator": "GREATER_THAN",
            "Threshold": 100,
            "ThresholdType": "PERCENTAGE"
        },
        "Subscribers": [
            {
                "SubscriptionType": "EMAIL",
                "Address": "$EMAIL"
            }
        ]
    },
    {
        "Notification": {
            "NotificationType": "FORECASTED",
            "ComparisonOperator": "GREATER_THAN",
            "Threshold": 100,
            "ThresholdType": "PERCENTAGE"
        },
        "Subscribers": [
            {
                "SubscriptionType": "EMAIL",
                "Address": "$EMAIL"
            }
        ]
    }
]
EOF

# ------------------------------------------------------------
# PASSO 3: Criar o budget na AWS
# ------------------------------------------------------------
echo ""
echo "Criando budget '$NOME_BUDGET'..."
aws budgets create-budget \
    --account-id "$ACCOUNT_ID" \
    --budget file:///tmp/budget-config.json \
    --notifications-with-subscribers file:///tmp/budget-notificacoes.json

# ------------------------------------------------------------
# PASSO 4: Verificar se foi criado com sucesso
# ------------------------------------------------------------
echo ""
echo "Verificando budget criado..."
aws budgets describe-budgets \
    --account-id "$ACCOUNT_ID" \
    --query 'Budgets[?BudgetName==`'"$NOME_BUDGET"'`].{Nome:BudgetName,Limite:BudgetLimit.Amount,Tipo:BudgetType}' \
    --output table

# Limpeza dos arquivos temporários
rm -f /tmp/budget-config.json /tmp/budget-notificacoes.json

echo ""
echo "============================================================"
echo "✅ BUDGET ALERT CRIADO COM SUCESSO!"
echo ""
echo "Você receberá emails em:"
echo "  📧 80% do limite  → \$$(echo "scale=2; $LIMITE_USD * 0.8" | bc)"
echo "  📧 100% do limite → \$$LIMITE_USD"
echo "  📧 Previsão de ultrapassar → \$$LIMITE_USD"
echo ""
echo "⚠️  Confirme o email de inscrição que a AWS enviará!"
echo "============================================================"
