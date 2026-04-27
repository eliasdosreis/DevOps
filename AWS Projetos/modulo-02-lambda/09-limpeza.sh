#!/bin/bash
# ============================================================
# ARQUIVO: 09-limpeza.sh  
# MÓDULO 2 — Lambda + CloudWatch
# ⚠️  EXECUTE SEMPRE ao terminar para não gerar custos!
# ============================================================

set -e

NOME_FUNCAO="lambda-hello-modulo02"
NOME_STACK="modulo-02-lambda"

echo "============================================================"
echo "⚠️  LIMPEZA DO MÓDULO 2 — Lambda"
echo "============================================================"
read -p "Digite 'SIM' para confirmar a limpeza: " CONFIRMACAO
[ "$CONFIRMACAO" != "SIM" ] && { echo "Cancelado."; exit 0; }

echo ""
echo "1. Deletando função Lambda '$NOME_FUNCAO'..."
aws lambda delete-function --function-name "$NOME_FUNCAO" 2>/dev/null \
    && echo "   ✅ Lambda deletada!" \
    || echo "   ℹ️  Lambda não existe (ok)."

echo ""
echo "2. Deletando Log Group no CloudWatch..."
aws logs delete-log-group \
    --log-group-name "/aws/lambda/$NOME_FUNCAO" 2>/dev/null \
    && echo "   ✅ Log Group deletado!" \
    || echo "   ℹ️  Log Group não existe (ok)."

echo ""
echo "3. Deletando Role IAM..."
ROLE_NOME="role-${NOME_FUNCAO}-dev"
# Primeiro desanexa as políticas (obrigatório antes de deletar a role)
aws iam list-attached-role-policies --role-name "$ROLE_NOME" \
    --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null | \
    tr '\t' '\n' | while read -r POLICY_ARN; do
        [ -z "$POLICY_ARN" ] && continue
        aws iam detach-role-policy --role-name "$ROLE_NOME" --policy-arn "$POLICY_ARN" 2>/dev/null
        echo "   Desanexada: $POLICY_ARN"
    done
    
aws iam list-role-policies --role-name "$ROLE_NOME" \
    --query 'PolicyNames[]' --output text 2>/dev/null | \
    tr '\t' '\n' | while read -r POLICY_NOME; do
        [ -z "$POLICY_NOME" ] && continue
        aws iam delete-role-policy --role-name "$ROLE_NOME" --policy-name "$POLICY_NOME" 2>/dev/null
        echo "   Removida inline: $POLICY_NOME"
    done

aws iam delete-role --role-name "$ROLE_NOME" 2>/dev/null \
    && echo "   ✅ Role IAM deletada!" \
    || echo "   ℹ️  Role não existe (ok)."

echo ""
echo "4. Deletando stack CloudFormation (se existir)..."
aws cloudformation delete-stack --stack-name "$NOME_STACK" 2>/dev/null \
    && echo "   ✅ Stack CloudFormation deletada!" \
    || echo "   ℹ️  Stack não existe (ok)."

echo ""
echo "============================================================"
echo "🧹 LIMPEZA DO MÓDULO 2 CONCLUÍDA!"
echo ""
echo "📊 Atualize seu acompanhamento:"
echo "   Módulo 2 | Lambda + CloudWatch | \$0.00 | ✅"
echo "============================================================"
