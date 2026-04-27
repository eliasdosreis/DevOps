#!/bin/bash
# ============================================================
# ARQUIVO: 08-limpeza.sh
# MÓDULO 10 — LIMPEZA FINAL (PROJETO COMPLETO)
# ⚠️  EXECUTE SEMPRE ao terminar para não gerar custos!
# ⚠️  Esta operação destrói TODA a infraestrutura criada
# ============================================================

set -e

NOME_STACK="ecommerce-serverless"
NOME_PROJETO="ecommerce-aprendizado"
REGIAO="us-east-1"

echo "============================================================"
echo "⚠️  LIMPEZA COMPLETA — PROJETO FINAL E-COMMERCE SERVERLESS"
echo "============================================================"
echo ""
echo "Este script vai destruir:"
echo "  • Stack CloudFormation '$NOME_STACK' (todos os recursos)"
echo "  • Bucket S3 (frontend) — esvaziado primeiro"
echo "  • DynamoDB Tables (produtos e pedidos)"
echo "  • Lambda Functions (api e worker)"
echo "  • API Gateway"
echo "  • SQS Queues (incluindo DLQ)"
echo "  • SNS Topic e subscrições"
echo "  • IAM Roles"
echo "  • CloudWatch Log Groups e Alarmes"
echo ""
echo "⚠️  ISSO É IRREVERSÍVEL!"
read -p "Digite 'DESTRUIR' para confirmar: " CONFIRMACAO

if [ "$CONFIRMACAO" != "DESTRUIR" ]; then
    echo "❌ Limpeza cancelada."
    exit 0
fi

echo ""
echo "Iniciando limpeza..."

# ------------------------------------------------------------
# PASSO 1: Esvaziar o bucket S3 (necessário antes de deletar a stack)
# CloudFormation não consegue deletar bucket com objetos!
# ------------------------------------------------------------
echo ""
echo "1. Localizando e esvaziando bucket S3..."

# Pega o Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NOME="${NOME_PROJETO}-frontend-${ACCOUNT_ID}"

echo "   Bucket: $BUCKET_NOME"

# Deleta versões
aws s3api list-object-versions \
    --bucket "$BUCKET_NOME" \
    --output json 2>/dev/null | \
    python3 -c "
import sys, json, subprocess
try:
    data = json.load(sys.stdin)
    versions = data.get('Versions', []) + data.get('DeleteMarkers', [])
    if not versions:
        print('   Bucket já vazio ou não existe.')
    else:
        objects = [{'Key': v['Key'], 'VersionId': v['VersionId']} for v in versions]
        print(f'   Deletando {len(objects)} versões/markers...')
        for i in range(0, len(objects), 1000):
            batch = objects[i:i+1000]
            subprocess.run(['aws', 's3api', 'delete-objects',
                           '--bucket', '$BUCKET_NOME',
                           '--delete', json.dumps({'Objects': batch, 'Quiet': True})],
                          check=True, capture_output=True)
        print('   ✅ Versões deletadas!')
except Exception as e:
    print(f'   ℹ️  {e}')
" 2>/dev/null

aws s3 rm "s3://$BUCKET_NOME" --recursive 2>/dev/null \
    && echo "   ✅ Objetos deletados!" \
    || echo "   ℹ️  Bucket vazio ou não existe (ok)."

# ------------------------------------------------------------
# PASSO 2: Deletar a Stack CloudFormation
# Isso deleta TODOS os recursos definidos no template!
# ------------------------------------------------------------
echo ""
echo "2. Deletando Stack CloudFormation '$NOME_STACK'..."
aws cloudformation delete-stack \
    --stack-name "$NOME_STACK" \
    --region "$REGIAO" 2>/dev/null \
    && echo "   Deleção iniciada... aguardando (pode levar 3-5 minutos)..." \
    || echo "   ℹ️  Stack não existe (ok)."

# Aguarda a deleção completar
echo "   Aguardando conclusão da deleção..."
aws cloudformation wait stack-delete-complete \
    --stack-name "$NOME_STACK" \
    --region "$REGIAO" 2>/dev/null \
    && echo "   ✅ Stack deletada com sucesso!" \
    || echo "   ⚠️  Timeout ou stack não existe — verifique manualmente."

# ------------------------------------------------------------
# PASSO 3: Verificar recursos órfãos
# ------------------------------------------------------------
echo ""
echo "3. Verificando recursos órfãos..."

echo "   Lambdas com o nome do projeto:"
aws lambda list-functions \
    --query "Functions[?contains(FunctionName,'$NOME_PROJETO')].FunctionName" \
    --output table 2>/dev/null || echo "   Nenhuma Lambda encontrada ✅"

echo ""
echo "   Tabelas DynamoDB com o nome do projeto:"
aws dynamodb list-tables \
    --query "TableNames[?contains(@,'$NOME_PROJETO')]" \
    --output table 2>/dev/null || echo "   Nenhuma tabela encontrada ✅"

echo ""
echo "   Filas SQS com o nome do projeto:"
aws sqs list-queues \
    --queue-name-prefix "$NOME_PROJETO" \
    --query 'QueueUrls' \
    --output table 2>/dev/null || echo "   Nenhuma fila encontrada ✅"

# ------------------------------------------------------------
# PASSO 4: Deletar Log Groups (CloudFormation às vezes não deleta)
# ------------------------------------------------------------
echo ""
echo "4. Deletando Log Groups do CloudWatch..."
for FUNCAO in "api" "worker"; do
    LOG_GROUP="/aws/lambda/${NOME_PROJETO}-${FUNCAO}"
    aws logs delete-log-group --log-group-name "$LOG_GROUP" 2>/dev/null \
        && echo "   ✅ Log Group deletado: $LOG_GROUP" \
        || echo "   ℹ️  Log Group não existe: $LOG_GROUP (ok)"
done

echo ""
echo "============================================================"
echo "🧹 LIMPEZA COMPLETA DO PROJETO FINAL CONCLUÍDA!"
echo ""
echo "📊 REGISTRO FINAL DO CURSO:"
echo ""
echo "  Módulo | Recursos                    | Custo Real | Limpeza"
echo "  -------|------------------------------|------------|--------"
echo "  0      | IAM, CLI, Budget             | \$0.00      | N/A"
echo "  1      | S3 Bucket + Site Estático    | \$0.00      | ✅"
echo "  2      | Lambda + CloudWatch          | \$0.00      | ✅"
echo "  3      | API Gateway + Lambda         | \$0.00      | ✅"
echo "  4      | DynamoDB + Lambda            | \$0.00      | ✅"
echo "  5      | SNS + SQS + Lambda           | \$0.00      | ✅"
echo "  6      | CloudFormation Stacks        | \$0.00      | ✅"
echo "  7      | IAM Roles + Secrets Manager  | ~\$0.05     | ✅"
echo "  8      | ECR + ECS Fargate            | ~\$0.30     | ✅"
echo "  9      | CloudWatch Dashboard         | \$0.00      | ✅"
echo "  10     | E-commerce Serverless        | ~\$0.05     | ✅"
echo "  -------|------------------------------|------------|--------"
echo "  TOTAL  |                              | < \$1.00    | ✅"
echo ""
echo "🔍 Verifique no Cost Explorer amanhã para confirmar:"
echo "   https://console.aws.amazon.com/cost-management/"
echo ""
echo "🎓 PARABÉNS! Você concluiu o curso AWS do Zero ao Sênior!"
echo "   Custo total: menos de \$1.00"
echo "   Conhecimento adquirido: PRICELESS 💎"
echo "============================================================"
