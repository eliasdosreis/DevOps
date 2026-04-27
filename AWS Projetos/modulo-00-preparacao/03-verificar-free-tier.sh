#!/bin/bash
# ============================================================
# ARQUIVO: 03-verificar-free-tier.sh
# O QUE FAZ: Mostra o uso atual do Free Tier para garantir
#             que você não está sendo cobrado inesperadamente
#
# ANALOGIA: É como checar o saldo de dados do celular antes
#           de assistir um vídeo em 4K no plano pré-pago.
#
# CUSTO: $0.00 — Consulta apenas (não cria recursos)
# ============================================================

echo "============================================================"
echo "VERIFICADOR DE FREE TIER E CUSTOS AWS"
echo "============================================================"
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "🔐 Conta AWS: $ACCOUNT_ID"
echo "👤 Usuário:   $(aws sts get-caller-identity --query Arn --output text)"
echo ""

# ------------------------------------------------------------
# VERIFICAR CUSTOS DO MÊS ATUAL
# Cost Explorer permite ver custos por serviço
# Nota: Dados podem ter até 24h de atraso
# ------------------------------------------------------------
echo "💰 CUSTOS DO MÊS ATUAL:"
echo "   (Nota: dados têm até 24h de atraso)"
echo ""

# Pega o primeiro dia do mês atual
INICIO_MES=$(date -u +"%Y-%m-01")
HOJE=$(date -u +"%Y-%m-%d")

aws ce get-cost-and-usage \
    --time-period Start="$INICIO_MES",End="$HOJE" \
    --granularity MONTHLY \
    --metrics "BlendedCost" \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount!=`0`].{Servico:Keys[0],Custo:Metrics.BlendedCost.Amount}' \
    --output table 2>/dev/null || echo "   ⚠️  Cost Explorer não habilitado ainda (aguarde 24h após a criação da conta)"

echo ""

# ------------------------------------------------------------
# VERIFICAR BUDGETS CRIADOS
# ------------------------------------------------------------
echo "📊 BUDGETS CONFIGURADOS:"
aws budgets describe-budgets \
    --account-id "$ACCOUNT_ID" \
    --query 'Budgets[].{Nome:BudgetName,Limite:BudgetLimit.Amount,Atual:CalculatedSpend.ActualSpend.Amount}' \
    --output table 2>/dev/null || echo "   ⚠️  Nenhum budget configurado — execute 02-budget-alert.sh!"

echo ""

# ------------------------------------------------------------
# LISTAR RECURSOS ATIVOS QUE PODEM GERAR CUSTO
# Recursos "esquecidos" são a causa mais comum de gastos surpresa
# ------------------------------------------------------------
echo "🔍 RECURSOS ATIVOS (verificação rápida):"
echo ""

echo "   EC2 Instances rodando:"
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{ID:InstanceId,Tipo:InstanceType,Regiao:Placement.AvailabilityZone}' \
    --output table 2>/dev/null || echo "   Nenhuma instância EC2 rodando ✅"

echo ""
echo "   NAT Gateways (cobram ~\$0.045/hora!):"
aws ec2 describe-nat-gateways \
    --filter "Name=state,Values=available" \
    --query 'NatGateways[].{ID:NatGatewayId,VPC:VpcId,Estado:State}' \
    --output table 2>/dev/null || echo "   Nenhum NAT Gateway ativo ✅"

echo ""
echo "   RDS Instances:"
aws rds describe-db-instances \
    --query 'DBInstances[].{ID:DBInstanceIdentifier,Tipo:DBInstanceClass,Estado:DBInstanceStatus}' \
    --output table 2>/dev/null || echo "   Nenhuma instância RDS ✅"

echo ""
echo "============================================================"
echo "DICAS PARA MANTER CUSTOS ZERADOS:"
echo ""
echo "  1. Sempre execute o passo de LIMPEZA ao final de cada módulo"
echo "  2. Verifique este script após CADA módulo"
echo "  3. Acesse Cost Explorer: https://console.aws.amazon.com/cost-management/"
echo "  4. Configure alertas de anomalia: Billing → Cost Anomaly Detection"
echo "============================================================"
