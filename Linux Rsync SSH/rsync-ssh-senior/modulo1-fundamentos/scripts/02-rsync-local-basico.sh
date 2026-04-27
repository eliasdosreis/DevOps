#!/bin/bash
# =============================================================
# SCRIPT 02: Primeiro rsync - Cópia Local
# Módulo 1 - Fundamentos
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Vamos copiar arquivos de uma pasta para outra.
# É como tirar foto dos seus desenhos antes de apagá-los!
# O rsync é mais esperto que o cp porque só copia o que mudou.
#
# =============================================================

# -------------------------------------------
# Cores para deixar o terminal bonito
# -------------------------------------------
# \033[0;32m = Verde | \033[0;31m = Vermelho | \033[0m = Resetar cor
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

# -------------------------------------------
# Função de log (boa prática Sênior!)
# -------------------------------------------
# Uma FUNÇÃO é como uma receita de bolo:
# você escreve uma vez e usa várias vezes
log() {
    # $1 = primeiro parâmetro que você passa para a função
    echo -e "${AZUL}[$(date '+%H:%M:%S')]${RESET} $1"
}

# -------------------------------------------
# PASSO 1: Configurar as pastas
# -------------------------------------------
PASTA_ORIGEM="/tmp/rsync-origem"    # Onde estão os arquivos
PASTA_DESTINO="/tmp/rsync-destino"  # Para onde vão os arquivos

# -------------------------------------------
# PASSO 2: Criar estrutura de teste
# -------------------------------------------
log "📁 Criando pasta de ORIGEM com arquivos de teste..."

# Criar pastas (mkdir -p cria toda a estrutura de uma vez)
mkdir -p "$PASTA_ORIGEM/documentos"
mkdir -p "$PASTA_ORIGEM/imagens"
mkdir -p "$PASTA_ORIGEM/configs"

# Criar arquivos de teste com conteúdo
echo "Arquivo de texto importante" > "$PASTA_ORIGEM/documentos/relatorio.txt"
echo "Configuração do sistema" > "$PASTA_ORIGEM/configs/app.conf"
echo "Dados do banco" > "$PASTA_ORIGEM/configs/database.conf"

# Criar arquivo grande (simula arquivo real)
# dd = programa para criar arquivos de tamanho específico
dd if=/dev/zero of="$PASTA_ORIGEM/imagens/foto.img" bs=1M count=1 2>/dev/null

log "${VERDE}✅ Arquivos de teste criados!${RESET}"
echo ""

# -------------------------------------------
# PASSO 3: Mostrar o que existe na origem
# -------------------------------------------
log "📋 Arquivos na ORIGEM:"
# find = procura arquivos | -type f = só arquivos (não pastas)
find "$PASTA_ORIGEM" -type f | sort

echo ""

# -------------------------------------------
# PASSO 4: SIMULAÇÃO (dry-run) - Pense antes de agir!
# -------------------------------------------
# 🧒 PARA CRIANÇAS: É como fazer o dever antes de entregar.
# Você confere se está certo ANTES de apagar o rascunho.
#
# Um SÊNIOR SEMPRE faz dry-run antes de rodar em produção!

log "${AMARELO}🔍 SIMULANDO a transferência (dry-run)...${RESET}"
log "   Nenhum arquivo será copiado ainda!"
echo ""

rsync \
    --dry-run \        # Simula sem fazer nada de verdade
    --archive \        # Preserva tudo: permissões, datas, links
    --verbose \        # Mostra cada arquivo que seria copiado
    --human-readable \ # Tamanhos legíveis (MB, KB, não bytes)
    --progress \       # Mostra barra de progresso
    "$PASTA_ORIGEM/" \ # ORIGEM: a barra / no final é importante!
    "$PASTA_DESTINO"   # DESTINO: sem barra no final

echo ""
log "${AMARELO}⚠️  ATENÇÃO: A barra (/) no final da ORIGEM muda tudo!${RESET}"
log "   COM barra:    rsync origem/  destino/  → copia CONTEÚDO"
log "   SEM barra:    rsync origem   destino/  → copia a PASTA"
echo ""

# -------------------------------------------
# PASSO 5: Confirmar antes de executar
# -------------------------------------------
read -p "▶️  Executar a cópia real? (s/n): " CONFIRMAR

# Verificar se o usuário disse 's' ou 'S'
if [[ "$CONFIRMAR" != "s" && "$CONFIRMAR" != "S" ]]; then
    log "${AMARELO}🛑 Operação cancelada pelo usuário${RESET}"
    exit 0
fi

# -------------------------------------------
# PASSO 6: Executar o rsync de verdade
# -------------------------------------------
log "${VERDE}🚀 Iniciando transferência REAL...${RESET}"

# Criar pasta destino se não existir
mkdir -p "$PASTA_DESTINO"

rsync \
    --archive \        # -a: preserva permissões, datas, links, etc
    --verbose \        # -v: mostra o que está fazendo
    --human-readable \ # -h: tamanhos legíveis
    --progress \       # Mostra progresso de cada arquivo
    --stats \          # Mostra estatísticas ao final
    "$PASTA_ORIGEM/" \
    "$PASTA_DESTINO"

# -------------------------------------------
# PASSO 7: Verificar resultado
# -------------------------------------------
# $? = código de retorno do último comando (0 = sucesso)
if [ $? -eq 0 ]; then
    echo ""
    log "${VERDE}✅ Transferência concluída com SUCESSO!${RESET}"
    echo ""
    log "📋 Arquivos no DESTINO:"
    find "$PASTA_DESTINO" -type f | sort
else
    echo ""
    log "${VERMELHO}❌ ERRO na transferência!${RESET}"
    exit 1
fi

echo ""
log "💡 DICA SÊNIOR: Para transferência REMOTA, use:"
log "   rsync -avzP origem/ usuario@servidor:/destino/"
log "   O 'z' comprime os dados durante a transferência!"
