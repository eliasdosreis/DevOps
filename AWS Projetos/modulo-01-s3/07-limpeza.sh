#!/bin/bash
# ============================================================
# ARQUIVO: 07-limpeza.sh
# O QUE FAZ: DESTRÓI todos os recursos criados no Módulo 1
#
# ⚠️  EXECUTE SEMPRE ao terminar para não gerar custos!
# ⚠️  Esta operação é IRREVERSÍVEL para os objetos!
# ⚠️  Mesmo com objetos em Glacier, a exclusão é permanente.
#
# CUSTO PÓS-LIMPEZA: $0.00
# ============================================================

set -e

# ============================================================
# CONFIGURAÇÕES — EDITE AQUI
# ============================================================
NOME_BUCKET="seu-bucket-nome-aqui"    # ← MUDE PARA SEU BUCKET!
NOME_STACK="modulo-01-s3"             # ← MUDE se usou nome diferente

echo "============================================================"
echo "⚠️  LIMPEZA DO MÓDULO 1 — S3"
echo "============================================================"
echo ""
echo "Este script irá:"
echo "  1. Esvaziar o bucket (incluindo todas as versões)"
echo "  2. Deletar o bucket"
echo "  3. Deletar as stacks CloudFormation"
echo ""
echo "⚠️  ISSO É IRREVERSÍVEL!"
echo ""
read -p "Digite 'SIM' para confirmar: " CONFIRMACAO

if [ "$CONFIRMACAO" != "SIM" ]; then
    echo "❌ Limpeza cancelada."
    exit 0
fi

echo ""
echo "Iniciando limpeza..."

# ------------------------------------------------------------
# PASSO 1: Deletar TODOS os objetos (incluindo versões!)
# "aws s3 rm --recursive" NÃO deleta versões antigas!
# É necessário deletar versões e delete markers explicitamente
# ------------------------------------------------------------
echo ""
echo "1. Deletando todos os objetos e versões..."
aws s3api list-object-versions \
    --bucket "$NOME_BUCKET" \
    --output json \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' 2>/dev/null | \
    python3 -c "
import sys, json, subprocess
data = json.load(sys.stdin)
objects = data.get('Objects', [])
if not objects:
    print('   Nenhum objeto (versões) encontrado.')
else:
    print(f'   Deletando {len(objects)} versões...')
    # Deleta em lotes de 1000 (limite da API)
    for i in range(0, len(objects), 1000):
        batch = objects[i:i+1000]
        cmd = ['aws', 's3api', 'delete-objects',
               '--bucket', '$NOME_BUCKET',
               '--delete', json.dumps({'Objects': batch, 'Quiet': True})]
        subprocess.run(cmd, check=True)
    print('   ✅ Versões deletadas!')
" 2>/dev/null || echo "   ℹ️  Nenhuma versão encontrada ou bucket não tem versionamento."

# Deletar Delete Markers
echo ""
echo "2. Deletando Delete Markers..."
aws s3api list-object-versions \
    --bucket "$NOME_BUCKET" \
    --output json \
    --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' 2>/dev/null | \
    python3 -c "
import sys, json, subprocess
data = json.load(sys.stdin)
objects = data.get('Objects', [])
if not objects:
    print('   Nenhum Delete Marker encontrado.')
else:
    print(f'   Deletando {len(objects)} Delete Markers...')
    for i in range(0, len(objects), 1000):
        batch = objects[i:i+1000]
        cmd = ['aws', 's3api', 'delete-objects',
               '--bucket', '$NOME_BUCKET',
               '--delete', json.dumps({'Objects': batch, 'Quiet': True})]
        subprocess.run(cmd, check=True)
    print('   ✅ Delete Markers deletados!')
" 2>/dev/null || echo "   ℹ️  Nenhum Delete Marker encontrado."

# Deleta objetos normais
echo ""
echo "3. Deletando objetos atuais..."
aws s3 rm "s3://$NOME_BUCKET" --recursive 2>/dev/null \
    && echo "   ✅ Objetos deletados!" \
    || echo "   ℹ️  Nenhum objeto para deletar."

# ------------------------------------------------------------
# PASSO 2: Deletar o bucket (só funciona se estiver vazio)
# ------------------------------------------------------------
echo ""
echo "4. Deletando o bucket '$NOME_BUCKET'..."
aws s3api delete-bucket \
    --bucket "$NOME_BUCKET" \
    --region us-east-1 2>/dev/null \
    && echo "   ✅ Bucket deletado!" \
    || echo "   ℹ️  Bucket não existe ou não pôde ser deletado."

# ------------------------------------------------------------
# PASSO 3: Deletar as stacks CloudFormation
# (se você criou os recursos via CloudFormation)
# ------------------------------------------------------------
echo ""
echo "5. Deletando stacks CloudFormation..."
for STACK in "modulo-01-s3-site" "modulo-01-s3-lifecycle" "modulo-01-s3-versionamento" "modulo-01-s3"; do
    aws cloudformation delete-stack --stack-name "$STACK" 2>/dev/null \
        && echo "   ✅ Stack '$STACK' deletada!" \
        || echo "   ℹ️  Stack '$STACK' não existe (ok)."
done

# ------------------------------------------------------------
# PASSO 4: Verificação final
# ------------------------------------------------------------
echo ""
echo "6. Verificação final — buckets restantes:"
aws s3 ls 2>/dev/null | grep "$NOME_BUCKET" \
    && echo "   ⚠️  Bucket ainda existe! Verifique manualmente." \
    || echo "   ✅ Bucket não encontrado — limpeza concluída!"

echo ""
echo "============================================================"
echo "🧹 LIMPEZA CONCLUÍDA!"
echo ""
echo "📊 Atualize sua tabela de custos:"
echo "   Módulo | Recursos       | Custo Real | Limpeza"
echo "   1      | S3 Bucket Site | \$0.00      | ✅"
echo ""
echo "🔍 Verifique o Cost Explorer amanhã para confirmar \$0.00"
echo "   https://console.aws.amazon.com/cost-management/"
echo "============================================================"
