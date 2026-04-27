#!/bin/bash
# =============================================================
# SCRIPT 01: Verificação de Integridade de Arquivos
# Módulo 3 - Avançado
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Depois de copiar os arquivos, precisamos ter CERTEZA
# que nenhum foi corrompido no caminho.
# É como contar o dinheiro depois de receber o troco!
#
# POR QUE ISSO É SÊNIOR?
# Em produção, dado corrompido = problema sério.
# Um Sênior nunca confia cegamente. Ele VERIFICA!
#
# =============================================================

# Cores
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

# -------------------------------------------
# CONFIGURAÇÕES
# -------------------------------------------
PASTA_ORIGEM="${1:-/tmp/rsync-origem}"   # Primeiro argumento ou padrão
PASTA_DESTINO="${2:-/tmp/rsync-destino}" # Segundo argumento ou padrão
ARQUIVO_CHECKSUMS="/tmp/verificacao_$(date '+%Y%m%d_%H%M%S').sha256"

# -------------------------------------------
# Função de log
# -------------------------------------------
log() {
    echo -e "${AZUL}[$(date '+%H:%M:%S')]${RESET} $1"
}

ok()    { echo -e "${VERDE}[OK]    $1${RESET}"; }
erro()  { echo -e "${VERMELHO}[ERRO]  $1${RESET}"; }
aviso() { echo -e "${AMARELO}[AVISO] $1${RESET}"; }

# -------------------------------------------
# PASSO 1: Verificar se as pastas existem
# -------------------------------------------
log "🔍 Verificando pastas..."

for PASTA in "$PASTA_ORIGEM" "$PASTA_DESTINO"; do
    if [ ! -d "$PASTA" ]; then
        erro "Pasta não encontrada: $PASTA"
        exit 1
    fi
done

ok "Pastas encontradas"

# -------------------------------------------
# PASSO 2: Contar e comparar arquivos
# -------------------------------------------
log ""
log "📊 Comparando quantidade de arquivos..."

# find -type f = apenas arquivos (não pastas)
# wc -l = conta o número de linhas (cada arquivo = uma linha)
QTD_ORIGEM=$(find "$PASTA_ORIGEM" -type f | wc -l)
QTD_DESTINO=$(find "$PASTA_DESTINO" -type f | wc -l)

log "   Origem:  $QTD_ORIGEM arquivos"
log "   Destino: $QTD_DESTINO arquivos"

if [ "$QTD_ORIGEM" -eq "$QTD_DESTINO" ]; then
    ok "Quantidade de arquivos IGUAL ✅"
else
    DIFERENCA=$((QTD_ORIGEM - QTD_DESTINO))
    aviso "Diferença de $DIFERENCA arquivo(s)!"
    aviso "Pode indicar que alguns não foram copiados"
fi

# -------------------------------------------
# PASSO 3: Comparar tamanho total
# -------------------------------------------
log ""
log "📏 Comparando tamanho total..."

# du -sb = tamanho em bytes da pasta toda
# awk '{print $1}' = pegar apenas o primeiro campo (o número)
TAMANHO_ORIGEM=$(du -sb "$PASTA_ORIGEM" | awk '{print $1}')
TAMANHO_DESTINO=$(du -sb "$PASTA_DESTINO" | awk '{print $1}')

# Converter para MB para exibição mais amigável
MB_ORIGEM=$((TAMANHO_ORIGEM / 1024 / 1024))
MB_DESTINO=$((TAMANHO_DESTINO / 1024 / 1024))

log "   Origem:  ${MB_ORIGEM} MB"
log "   Destino: ${MB_DESTINO} MB"

if [ "$TAMANHO_ORIGEM" -eq "$TAMANHO_DESTINO" ]; then
    ok "Tamanho IGUAL ✅"
else
    aviso "Tamanhos diferentes! Possível problema."
fi

# -------------------------------------------
# PASSO 4: Gerar checksums SHA256 da ORIGEM
# -------------------------------------------
log ""
log "🔐 Gerando checksums SHA256 da ORIGEM..."
log "   (Isso pode demorar para muitos arquivos)"

# find = listar arquivos
# sort = ordenar (para comparar depois)
# xargs = passar cada arquivo para o sha256sum
# -exec = executar comando para cada arquivo encontrado
find "$PASTA_ORIGEM" -type f -exec sha256sum {} \; | \
    sort > "$ARQUIVO_CHECKSUMS"
# ↑ O pipe (|) envia a saída de um comando para o próximo

ok "Checksums gerados: $ARQUIVO_CHECKSUMS"
TOTAL_CHECKSUMS=$(wc -l < "$ARQUIVO_CHECKSUMS")
log "   Total de checksums: $TOTAL_CHECKSUMS"

# -------------------------------------------
# PASSO 5: Verificar cada arquivo no DESTINO
# -------------------------------------------
log ""
log "🔍 Verificando integridade no DESTINO..."

ARQUIVOS_OK=0
ARQUIVOS_ERRO=0
ARQUIVOS_FALTANDO=0

# Ler o arquivo de checksums linha por linha
while IFS= read -r LINHA; do
    # Cada linha do arquivo de checksums tem:
    # HASH  /caminho/do/arquivo
    
    # awk = ferramenta para processar texto
    HASH_ORIGEM=$(echo "$LINHA" | awk '{print $1}')
    ARQUIVO_ORIGEM=$(echo "$LINHA" | awk '{print $2}')
    
    # Calcular o caminho equivalente no DESTINO
    # sed = editor de texto de linha de comando
    # s|ORIGEM|DESTINO|g = substituir ORIGEM por DESTINO
    ARQUIVO_DESTINO=$(echo "$ARQUIVO_ORIGEM" | sed "s|${PASTA_ORIGEM}|${PASTA_DESTINO}|g")
    
    # Verificar se o arquivo existe no destino
    if [ ! -f "$ARQUIVO_DESTINO" ]; then
        erro "FALTANDO: $ARQUIVO_DESTINO"
        ((ARQUIVOS_FALTANDO++))
        continue   # Pular para o próximo arquivo
    fi
    
    # Calcular hash do arquivo no destino
    HASH_DESTINO=$(sha256sum "$ARQUIVO_DESTINO" | awk '{print $1}')
    
    # Comparar os hashes
    if [ "$HASH_ORIGEM" = "$HASH_DESTINO" ]; then
        ((ARQUIVOS_OK++))
    else
        erro "CORROMPIDO: $ARQUIVO_DESTINO"
        erro "  Esperado: $HASH_ORIGEM"
        erro "  Encontrado: $HASH_DESTINO"
        ((ARQUIVOS_ERRO++))
    fi
    
done < "$ARQUIVO_CHECKSUMS"
# ↑ < "arquivo" = ler do arquivo (em vez do teclado)

# -------------------------------------------
# PASSO 6: Relatório final
# -------------------------------------------
log ""
log "════════════════════════════════════"
log "📊 RELATÓRIO DE VERIFICAÇÃO"
log "════════════════════════════════════"
log "   ✅ Arquivos OK:       $ARQUIVOS_OK"
log "   ❌ Corrompidos:       $ARQUIVOS_ERRO"
log "   ⚠️  Faltando:         $ARQUIVOS_FALTANDO"
log "   📄 Checksums em:      $ARQUIVO_CHECKSUMS"
log "════════════════════════════════════"

# Definir código de saída baseado nos resultados
if [ $ARQUIVOS_ERRO -eq 0 ] && [ $ARQUIVOS_FALTANDO -eq 0 ]; then
    ok "✅ VERIFICAÇÃO APROVADA! Todos os arquivos íntegros."
    exit 0
else
    erro "❌ VERIFICAÇÃO FALHOU! Existem problemas."
    exit 1
fi
