#!/bin/bash
# =============================================================
# SCRIPT 02: rsync com Retry e Sistema de Logs
# Módulo 2 - Intermediário
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Imagine que você está mandando uma carta e a transportadora
# falha. Em vez de desistir, você tenta de novo!
# Este script tenta 3 vezes antes de desistir.
# E escreve tudo num diário (log) para você conferir depois.
#
# POR QUE ISSO É SÊNIOR?
# Redes falham! Um Sênior sabe que nada é 100% e trata falhas.
#
# =============================================================

# -------------------------------------------
# Cores para o terminal
# -------------------------------------------
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

# -------------------------------------------
# CONFIGURAÇÕES (normalmente viria do rsync.conf)
# -------------------------------------------
SERVIDOR="${SERVIDOR:-192.168.1.100}"
USUARIO="${USUARIO:-devops}"
PORTA_SSH="${PORTA_SSH:-22}"
CHAVE_SSH="${CHAVE_SSH:-$HOME/.ssh/rsync_senior_key}"
PASTA_ORIGEM="${PASTA_ORIGEM:-/dados}"
PASTA_DESTINO="${PASTA_DESTINO:-/backup}"
MAX_TENTATIVAS="${MAX_TENTATIVAS:-3}"
INTERVALO_TENTATIVA="${INTERVALO_TENTATIVA:-60}"

# -------------------------------------------
# CONFIGURAÇÃO DE LOGS
# -------------------------------------------
# Criar nome do arquivo de log com data e hora
# Assim cada execução tem seu próprio log
DATA_HORA=$(date '+%Y-%m-%d_%H-%M-%S')
PASTA_LOGS="/tmp/rsync-logs"
ARQUIVO_LOG="${PASTA_LOGS}/rsync_${DATA_HORA}.log"

# Criar pasta de logs se não existir
mkdir -p "$PASTA_LOGS"

# -------------------------------------------
# FUNÇÃO: Escrever no log E na tela
# -------------------------------------------
# Tee = escreve em dois lugares ao mesmo tempo
# Como ter dois copos, e você derrama água nos dois juntos
log() {
    local NIVEL="$1"      # INFO, ERRO, AVISO
    local MENSAGEM="$2"   # O texto do log

    # Formato da linha de log:
    # [2024-01-15 14:30:00] [INFO] Mensagem aqui
    local LINHA="[$(date '+%Y-%m-%d %H:%M:%S')] [${NIVEL}] ${MENSAGEM}"

    # Escrever na tela com cor
    case "$NIVEL" in
        "INFO")  echo -e "${AZUL}${LINHA}${RESET}" ;;
        "OK")    echo -e "${VERDE}${LINHA}${RESET}" ;;
        "AVISO") echo -e "${AMARELO}${LINHA}${RESET}" ;;
        "ERRO")  echo -e "${VERMELHO}${LINHA}${RESET}" ;;
        *)       echo -e "${LINHA}" ;;
    esac

    # Escrever no arquivo (sem cores, para o arquivo ficar limpo)
    echo "$LINHA" >> "$ARQUIVO_LOG"
}

# -------------------------------------------
# FUNÇÃO: Executar rsync com tratamento de erro
# -------------------------------------------
executar_rsync() {
    rsync \
        --archive \
        --compress \
        --human-readable \
        --stats \
        --partial \
        --timeout=60 \   # Desiste se ficar 60s sem atividade
        --rsh="ssh -i ${CHAVE_SSH} -p ${PORTA_SSH} \
               -o ConnectTimeout=30 \
               -o ServerAliveInterval=15 \
               -o ServerAliveCountMax=3" \
        # ↑ ServerAliveInterval = manda "oi ainda tô aqui" a cada 15s
        # ↑ ServerAliveCountMax = desiste após 3 "oi" sem resposta
        "$PASTA_ORIGEM/" \
        "${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}" \
        2>&1    # 2>&1 = redireciona erros para o mesmo lugar que a saída normal
}

# -------------------------------------------
# INÍCIO DA EXECUÇÃO
# -------------------------------------------
log "INFO" "════════════════════════════════════════"
log "INFO" "INICIANDO MIGRAÇÃO RSYNC"
log "INFO" "════════════════════════════════════════"
log "INFO" "Log sendo salvo em: $ARQUIVO_LOG"
log "INFO" "Servidor: ${USUARIO}@${SERVIDOR}:${PORTA_SSH}"
log "INFO" "Origem:   $PASTA_ORIGEM"
log "INFO" "Destino:  $PASTA_DESTINO"
log "INFO" "Tentativas máximas: $MAX_TENTATIVAS"

# -------------------------------------------
# LOOP DE TENTATIVAS
# -------------------------------------------
# Um loop repete as instruções dentro dele
# Aqui tentamos várias vezes se falhar
TENTATIVA=1

while [ $TENTATIVA -le $MAX_TENTATIVAS ]; do
    # Calcular o número total de tentativas (para exibir)
    log "INFO" "────────────────────────────────────────"
    log "INFO" "Tentativa ${TENTATIVA} de ${MAX_TENTATIVAS}..."

    # Registrar tempo de início desta tentativa
    INICIO=$(date +%s)

    # Executar rsync e capturar saída no log
    executar_rsync | tee -a "$ARQUIVO_LOG"
    CODIGO_SAIDA=${PIPESTATUS[0]}   # Pegar resultado do rsync (não do tee)

    # Calcular duração
    FIM=$(date +%s)
    DURACAO=$((FIM - INICIO))

    # Verificar resultado
    if [ $CODIGO_SAIDA -eq 0 ]; then
        log "OK" "════════════════════════════════════════"
        log "OK" "✅ SUCESSO na tentativa ${TENTATIVA}!"
        log "OK" "   Duração: ${DURACAO} segundos"
        log "OK" "════════════════════════════════════════"
        exit 0   # Sair com sucesso!

    else
        log "ERRO" "❌ FALHOU na tentativa ${TENTATIVA}! Código: $CODIGO_SAIDA"
        log "ERRO" "   Duração: ${DURACAO} segundos"

        # Se ainda tem tentativas, esperar e tentar de novo
        if [ $TENTATIVA -lt $MAX_TENTATIVAS ]; then
            log "AVISO" "⏳ Aguardando ${INTERVALO_TENTATIVA}s antes de tentar novamente..."
            sleep "$INTERVALO_TENTATIVA"
        fi
    fi

    # Incrementar contador de tentativas
    # TENTATIVA++ ou TENTATIVA=$((TENTATIVA + 1))
    ((TENTATIVA++))
done

# -------------------------------------------
# Se chegou aqui, todas as tentativas falharam
# -------------------------------------------
log "ERRO" "════════════════════════════════════════"
log "ERRO" "❌ TODAS AS ${MAX_TENTATIVAS} TENTATIVAS FALHARAM!"
log "ERRO" "   Log completo em: $ARQUIVO_LOG"
log "ERRO" "════════════════════════════════════════"
exit 1
