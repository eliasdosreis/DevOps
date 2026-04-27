#!/bin/bash
# =============================================================
# SCRIPT 02: Monitoramento de Espaço em Disco
# Módulo 3 - Avançado
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Antes de encher a mala de viagem, você vê se ela é grande
# o suficiente para tudo que quer levar!
# Este script faz isso no servidor ANTES de copiar.
#
# =============================================================

VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

log() { echo -e "${AZUL}[$(date '+%H:%M:%S')]${RESET} $1"; }
ok()    { echo -e "${VERDE}  ✅ $1${RESET}"; }
erro()  { echo -e "${VERMELHO}  ❌ $1${RESET}"; }
aviso() { echo -e "${AMARELO}  ⚠️  $1${RESET}"; }

# -------------------------------------------
# CONFIGURAÇÕES
# -------------------------------------------
SERVIDOR="${SERVIDOR:-192.168.1.100}"
USUARIO="${USUARIO:-devops}"
PORTA_SSH="${PORTA_SSH:-22}"
CHAVE_SSH="${CHAVE_SSH:-$HOME/.ssh/rsync_senior_key}"
PASTA_ORIGEM="${PASTA_ORIGEM:-/dados}"
PASTA_DESTINO_REMOTO="${PASTA_DESTINO:-/backup}"

# Percentual mínimo de espaço livre (em %)
ESPACO_MINIMO_PERCENT=20

# -------------------------------------------
# PASSO 1: Calcular tamanho da origem
# -------------------------------------------
log "📏 Calculando tamanho da pasta de ORIGEM..."

# du = disk usage (uso de disco)
# -s = sum (total da pasta)
# -b = bytes
TAMANHO_ORIGEM_BYTES=$(du -sb "$PASTA_ORIGEM" 2>/dev/null | awk '{print $1}')

if [ -z "$TAMANHO_ORIGEM_BYTES" ]; then
    erro "Não foi possível calcular o tamanho da origem: $PASTA_ORIGEM"
    exit 1
fi

# Converter para MB e GB para exibição
TAMANHO_MB=$((TAMANHO_ORIGEM_BYTES / 1024 / 1024))
TAMANHO_GB=$(echo "scale=2; $TAMANHO_ORIGEM_BYTES / 1024 / 1024 / 1024" | bc)
# ↑ bc = calculadora para números decimais (bash não faz decimais nativamente)

log "   Tamanho a copiar: ${TAMANHO_MB} MB (${TAMANHO_GB} GB)"

# -------------------------------------------
# PASSO 2: Verificar espaço no servidor REMOTO
# -------------------------------------------
log ""
log "🔌 Verificando espaço no servidor remoto..."

# Executar df no servidor remoto via SSH
# df = disk free (espaço livre)
# -B1 = mostrar em bytes
# awk = processar a saída
ESPACO_REMOTO=$(ssh \
    -i "$CHAVE_SSH" \
    -p "$PORTA_SSH" \
    -o ConnectTimeout=10 \
    -o BatchMode=yes \
    "${USUARIO}@${SERVIDOR}" \
    "df -B1 ${PASTA_DESTINO_REMOTO} 2>/dev/null || df -B1 / " \
    | awk 'NR==2 {print $4}')  # NR==2 = linha 2 (a dos dados), $4 = 4ª coluna (livre)

if [ -z "$ESPACO_REMOTO" ]; then
    erro "Não foi possível verificar espaço no servidor!"
    erro "Verifique a conexão SSH."
    exit 1
fi

ESPACO_REMOTO_MB=$((ESPACO_REMOTO / 1024 / 1024))
ESPACO_REMOTO_GB=$(echo "scale=2; $ESPACO_REMOTO / 1024 / 1024 / 1024" | bc)

log "   Espaço livre no servidor: ${ESPACO_REMOTO_MB} MB (${ESPACO_REMOTO_GB} GB)"

# -------------------------------------------
# PASSO 3: Verificar se há espaço suficiente
# -------------------------------------------
log ""
log "⚖️  Verificando se há espaço suficiente..."

# Calcular margem de segurança (20% a mais do necessário)
# O rsync às vezes usa mais espaço temporariamente
ESPACO_NECESSARIO=$((TAMANHO_ORIGEM_BYTES * 12 / 10))  # 120% do tamanho
# ↑ Multiplicar por 12/10 = multiplicar por 1.2 (20% a mais)

ESPACO_NECESSARIO_MB=$((ESPACO_NECESSARIO / 1024 / 1024))

log "   Espaço necessário (com 20% de margem): ${ESPACO_NECESSARIO_MB} MB"

if [ "$ESPACO_REMOTO" -ge "$ESPACO_NECESSARIO" ]; then
    SOBRA=$((ESPACO_REMOTO - ESPACO_NECESSARIO))
    SOBRA_MB=$((SOBRA / 1024 / 1024))
    ok "Espaço suficiente! Sobra: ${SOBRA_MB} MB"
    echo ""
    log "✅ PRÉ-VERIFICAÇÃO APROVADA - Pode prosseguir com o rsync!"
    exit 0
else
    FALTAM=$((ESPACO_NECESSARIO - ESPACO_REMOTO))
    FALTAM_MB=$((FALTAM / 1024 / 1024))
    erro "Espaço INSUFICIENTE no servidor!"
    erro "Faltam: ${FALTAM_MB} MB"
    echo ""
    erro "❌ PRÉ-VERIFICAÇÃO FALHOU - NÃO execute o rsync!"
    erro "   Libere espaço no servidor antes de continuar."
    exit 1
fi
