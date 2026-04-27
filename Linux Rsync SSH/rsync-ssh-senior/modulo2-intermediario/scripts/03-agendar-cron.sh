#!/bin/bash
# =============================================================
# SCRIPT 03: Agendamento com Cron
# Módulo 2 - Intermediário
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# O cron é como um despertador do computador.
# Você programa: "todo dia às 2h da manhã, faça o backup!"
# E ele faz sozinho, sem precisar lembrar!
#
# =============================================================

# Cores
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

log() { echo -e "${AZUL}[$(date '+%H:%M:%S')]${RESET} $1"; }
ok()  { echo -e "${VERDE}  ✅ $1${RESET}"; }

# -------------------------------------------
# EXPLICAÇÃO: Como funciona o crontab?
# -------------------------------------------
# Formato de uma linha no crontab:
#
# ┌──── minuto (0-59)
# │  ┌─── hora (0-23)
# │  │  ┌── dia do mês (1-31)
# │  │  │  ┌─ mês (1-12)
# │  │  │  │  ┌ dia da semana (0=domingo, 6=sábado)
# │  │  │  │  │
# *  *  *  *  *  comando a executar
#
# EXEMPLOS:
# 0 2 * * *     = Todo dia às 02:00
# 0 2 * * 0     = Todo domingo às 02:00
# 0 2 1 * *     = Todo dia 1 do mês às 02:00
# */5 * * * *   = A cada 5 minutos
# 0 2,14 * * *  = Às 02:00 e 14:00 todos os dias

# -------------------------------------------
# PASSO 1: Mostrar o crontab atual
# -------------------------------------------
log "📋 Crontab atual do usuário:"
echo ""
crontab -l 2>/dev/null || echo "  (nenhuma tarefa agendada ainda)"
echo ""

# -------------------------------------------
# PASSO 2: Criar linha do cron para o rsync
# -------------------------------------------
# Caminho ABSOLUTO é obrigatório no cron!
# O cron não sabe onde você está quando roda o script
CAMINHO_SCRIPT="$(cd "$(dirname "$0")" && pwd)/02-rsync-retry-logs.sh"
CAMINHO_LOG="/tmp/rsync-logs/cron-$(date '+%Y-%m').log"

# Linha do cron: todo dia às 02:30 da manhã
# Redirect 2>&1 = erros também vão para o log
LINHA_CRON="30 2 * * * ${CAMINHO_SCRIPT} >> ${CAMINHO_LOG} 2>&1"

log "📝 Nova linha para o crontab:"
echo ""
echo "  $LINHA_CRON"
echo ""

# -------------------------------------------
# PASSO 3: Adicionar ao crontab (se não existir)
# -------------------------------------------
# Verificar se a linha já existe para não duplicar
if crontab -l 2>/dev/null | grep -qF "$CAMINHO_SCRIPT"; then
    log "${AMARELO}⚠️  Tarefa já existe no crontab. Não duplicando.${RESET}"
else
    # Ler crontab atual, adicionar nova linha, salvar de volta
    # (crontab -l lista, echo adiciona a nova linha, crontab - salva)
    (crontab -l 2>/dev/null; echo "$LINHA_CRON") | crontab -

    if [ $? -eq 0 ]; then
        ok "Tarefa adicionada ao crontab!"
    else
        echo "❌ Erro ao adicionar ao crontab"
        exit 1
    fi
fi

# -------------------------------------------
# PASSO 4: Confirmar o novo crontab
# -------------------------------------------
log ""
log "📋 Crontab atualizado:"
echo ""
crontab -l
echo ""

# -------------------------------------------
# PASSO 5: Criar pasta de logs para o cron
# -------------------------------------------
mkdir -p "$(dirname "$CAMINHO_LOG")"
ok "Pasta de logs criada: $(dirname "$CAMINHO_LOG")"

log ""
log "💡 DICAS SÊNIOR sobre cron:"
log "   • Use caminhos ABSOLUTOS sempre"
log "   • Sempre redirecione a saída para um log"
log "   • Teste o script manualmente antes de agendar"
log "   • Use 'crontab -e' para editar manualmente"
log "   • Monitore se o job realmente rodou (check nos logs!)"
