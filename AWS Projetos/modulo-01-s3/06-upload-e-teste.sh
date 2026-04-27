#!/bin/bash
# ============================================================
# ARQUIVO: 06-upload-e-teste.sh
# O QUE FAZ: Faz upload do site para o S3 e testa via CLI
#
# ANALOGIA: É como usar o correio para enviar os arquivos
#           para a "caixa postal" na nuvem.
#
# CUSTO: ~$0.00 — Free Tier cobre transfers e requisições básicas
# PRÉ-REQUISITO: Buckets criados com 01, 02, 03, 04 e 05
# CONCEITO NOVO: aws s3 sync, presigned URLs, Content-Type
# ============================================================

set -e

# ============================================================
# CONFIGURAÇÕES — EDITE AQUI
# ============================================================
NOME_BUCKET="seu-bucket-nome-aqui"   # ← MUDE PARA SEU BUCKET!
REGIAO="us-east-1"

echo "============================================================"
echo "UPLOAD E TESTE — MÓDULO 1 — S3"
echo "  Bucket: $NOME_BUCKET"
echo "  Região: $REGIAO"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# PASSO 1: Verificar que o bucket existe
# ------------------------------------------------------------
echo "1. Verificando bucket..."
aws s3api head-bucket --bucket "$NOME_BUCKET" 2>/dev/null \
    && echo "   ✅ Bucket '$NOME_BUCKET' encontrado" \
    || { echo "   ❌ Bucket não encontrado! Execute os templates 01-04 primeiro."; exit 1; }

# ------------------------------------------------------------
# PASSO 2: Fazer upload do arquivo HTML (comando cp)
# "cp" = copiar UM arquivo
# "sync" = sincronizar UMA PASTA inteira
# ------------------------------------------------------------
echo ""
echo "2. Fazendo upload do index.html..."
aws s3 cp site/index.html "s3://$NOME_BUCKET/index.html" \
    --content-type "text/html" \          # Define o tipo correto do arquivo
    --cache-control "max-age=3600"        # Browsers cachear por 1 hora
    
echo "   ✅ index.html carregado!"

# Upload da página de erro (necessária para WebsiteConfiguration)
echo ""
echo "3. Fazendo upload do error.html..."
cat > /tmp/error.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8"><title>Erro — Página não encontrada</title></head>
<body style="font-family: sans-serif; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
    <h1>🔍 404 — Página não encontrada</h1>
    <p>O arquivo que você procura não existe no bucket S3.</p>
    <a href="/" style="color: #e94560;">← Voltar ao início</a>
</body>
</html>
EOF

aws s3 cp /tmp/error.html "s3://$NOME_BUCKET/error.html" \
    --content-type "text/html"
echo "   ✅ error.html carregado!"

# ------------------------------------------------------------
# PASSO 3: Sincronizar TODA a pasta (se tiver mais arquivos)
# aws s3 sync = compara local com S3 e só copia o que mudou
# --delete = remove do S3 arquivos que não existem mais local
# --exclude = não sincroniza arquivos que casam com o padrão
# ------------------------------------------------------------
echo ""
echo "4. Sincronizando pasta inteira do site..."
aws s3 sync site/ "s3://$NOME_BUCKET/" \
    --content-type text/html \
    --exclude "*.sh" \                    # Não sobe scripts bash
    --exclude ".DS_Store" \               # Não sobe arquivos Mac
    --exclude "*.tmp" \
    --delete \                            # Remove do S3 o que foi deletado local
    --dryrun                              # ← REMOVE --dryrun para de verdade!

echo "   ℹ️  '--dryrun' ativo: mostra o que faria, mas não executa"
echo "   Para executar de verdade: remova --dryrun do script"

# ------------------------------------------------------------
# PASSO 4: Verificar o que está no bucket
# ------------------------------------------------------------
echo ""
echo "5. Listando objetos no bucket:"
aws s3 ls "s3://$NOME_BUCKET/" --human-readable --recursive

# ------------------------------------------------------------
# PASSO 5: Pegar a URL do site e testar
# ------------------------------------------------------------
echo ""
echo "6. URL do site estático:"
URL_WEBSITE="http://${NOME_BUCKET}.s3-website-${REGIAO}.amazonaws.com"
echo "   🌐 $URL_WEBSITE"
echo ""

# Testa se o site responde (HTTP 200)
echo "7. Testando acesso ao site..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL_WEBSITE")
if [ "$HTTP_STATUS" = "200" ]; then
    echo "   ✅ Site respondeu com HTTP $HTTP_STATUS — Funcionando!"
else
    echo "   ⚠️  Site respondeu com HTTP $HTTP_STATUS"
    echo "   Verifique: a política pública foi aplicada? (template 05)"
fi

# ------------------------------------------------------------
# PASSO 6: Criar uma Presigned URL (acesso temporário privado)
# Usar para compartilhar arquivos SEM tornar o bucket público
# ------------------------------------------------------------
echo ""
echo "8. Gerando Presigned URL (válida por 1 hora):"
PRESIGNED_URL=$(aws s3 presign "s3://$NOME_BUCKET/index.html" \
    --expires-in 3600)    # 3600 segundos = 1 hora
echo "   🔐 Presigned URL (expire em 1h):"
echo "   $PRESIGNED_URL"
echo ""

# ------------------------------------------------------------
# PASSO 7: Testar upload de arquivo para versionar
# Mostra como o versionamento funciona na prática
# ------------------------------------------------------------
echo "9. Demonstrando versionamento:"
echo "   Fazendo upload da mesma versão 2x para criar versões..."

# Primeiro upload (versão 1)
echo "<h1>Versão 1</h1>" > /tmp/versao-teste.html
aws s3 cp /tmp/versao-teste.html "s3://$NOME_BUCKET/versao-teste.html" --quiet
echo "   Versão 1 carregada!"

# Segundo upload — sobrescreve mas cria nova versão
echo "<h1>Versão 2</h1>" > /tmp/versao-teste.html
aws s3 cp /tmp/versao-teste.html "s3://$NOME_BUCKET/versao-teste.html" --quiet
echo "   Versão 2 carregada!"

# Lista versões do arquivo
echo ""
echo "   Versões criadas:"
aws s3api list-object-versions \
    --bucket "$NOME_BUCKET" \
    --prefix "versao-teste.html" \
    --query 'Versions[].{VersionId:VersionId,Data:LastModified}' \
    --output table

echo ""
echo "============================================================"
echo "✅ UPLOAD E TESTES CONCLUÍDOS!"
echo ""
echo "🌐 Acesse seu site em:"
echo "   $URL_WEBSITE"
echo ""
echo "📋 PRÓXIMO PASSO:"
echo "   Execute: ./07-limpeza.sh (ao terminar os estudos)"
echo "============================================================"
