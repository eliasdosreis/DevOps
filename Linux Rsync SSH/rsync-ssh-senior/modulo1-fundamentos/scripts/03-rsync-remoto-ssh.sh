#!/bin/bash
# =============================================================
# SCRIPT 03: rsync Remoto via SSH
# Módulo 1 - Fundamentos
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Agora vamos mandar os arquivos para outra casa (servidor remoto).
# É como mandar carta pelo correio, mas a carta chega em segundos
# e ninguém consegue ler no caminho porque está em código secreto!
#
# =============================================================

# -------------------------------------------
# Cores para terminal
# -------------------------------------------
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

# -------------------------------------------
# ⚙️ CONFIGURAÇÕES - Edite aqui!
# -------------------------------------------
# Estas são as variáveis que você muda para seu ambiente
SERVIDOR="192.168.1.100"                        # IP ou hostname do servidor
USUARIO="devops"                                # Usuário no servidor remoto
PORTA_SSH="22"                                  # Porta SSH (padrão: 22)
CHAVE_SSH="$HOME/.ssh/rsync_senior_key"         # Sua chave privada
PASTA_ORIGEM="$HOME/dados-para-migrar"          # Pasta local de origem
PASTA_DESTINO="/dados/backup"                   # Pasta no servidor remoto

# -------------------------------------------
# Função de log com timestamp
# -------------------------------------------
log() {
    # date '+%Y-%m-%d %H:%M:%S' = data e hora formatada
    echo -e "${AZUL}[$(date '+%Y-%m-%d %H:%M:%S')]${RESET} $1"
}

# Função para mostrar erro e sair
erro() {
    echo -e "${VERMELHO}[ERRO] $1${RESET}" >&2  # >&2 = manda para stderr
    exit 1
}

# -------------------------------------------
# PASSO 1: Verificar se tudo está configurado
# -------------------------------------------
# Um Sênior sempre valida os pré-requisitos antes de começar!
log "🔍 Verificando pré-requisitos..."

# Verificar se a chave SSH existe
# -f = verifica se é um arquivo que existe
if [ ! -f "$CHAVE_SSH" ]; then
    erro "Chave SSH não encontrada: $CHAVE_SSH
Execute primeiro: ./01-gerar-chaves-ssh.sh"
fi

# Verificar se a pasta origem existe
if [ ! -d "$PASTA_ORIGEM" ]; then
    log "${AMARELO}⚠️  Pasta origem não existe. Criando para teste...${RESET}"
    mkdir -p "$PASTA_ORIGEM"
    echo "arquivo de teste 1" > "$PASTA_ORIGEM/teste1.txt"
    echo "arquivo de teste 2" > "$PASTA_ORIGEM/teste2.txt"
fi

log "${VERDE}✅ Pré-requisitos verificados!${RESET}"

# -------------------------------------------
# PASSO 2: Testar conexão SSH antes do rsync
# -------------------------------------------
# Sempre teste a conexão antes de tentar transferir!
log "🔌 Testando conexão SSH com o servidor..."

# ssh com timeout de 10 segundos
# -o ConnectTimeout=10 = desiste após 10 segundos
# -o BatchMode=yes = não pergunta nada (para scripts)
# -q = silencioso (quiet)
# exit 0 = só testa a conexão e sai
ssh \
    -i "$CHAVE_SSH" \
    -p "$PORTA_SSH" \
    -o ConnectTimeout=10 \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    "${USUARIO}@${SERVIDOR}" \
    "exit 0" 2>/dev/null

# Verificar se a conexão funcionou
if [ $? -ne 0 ]; then
    log "${VERMELHO}❌ Não foi possível conectar ao servidor!${RESET}"
    log "   Servidor: $SERVIDOR"
    log "   Usuário:  $USUARIO"
    log "   Porta:    $PORTA_SSH"
    log "   Chave:    $CHAVE_SSH"
    log ""
    log "${AMARELO}💡 Verifique:"
    log "   1. Se o servidor está online (ping $SERVIDOR)"
    log "   2. Se sua chave pública está no servidor (authorized_keys)"
    log "   3. Se o usuário e porta estão corretos${RESET}"
    exit 1
fi

log "${VERDE}✅ Conexão SSH funcionando!${RESET}"

# -------------------------------------------
# PASSO 3: Criar pasta de destino no servidor
# -------------------------------------------
log "📁 Criando pasta de destino no servidor..."

# Executamos um comando NO SERVIDOR via SSH
# As aspas duplas permitem expansão de variáveis LOCAIS
# As aspas simples evitariam a expansão
ssh \
    -i "$CHAVE_SSH" \
    -p "$PORTA_SSH" \
    "${USUARIO}@${SERVIDOR}" \
    "mkdir -p ${PASTA_DESTINO}"

log "${VERDE}✅ Pasta de destino pronta!${RESET}"

# -------------------------------------------
# PASSO 4: SIMULAÇÃO do rsync remoto
# -------------------------------------------
log "${AMARELO}🔍 Simulando transferência (dry-run)...${RESET}"

rsync \
    --dry-run \
    --archive \                          # Preserva tudo
    --verbose \                          # Mostra o que faz
    --compress \                         # Comprime durante transferência
    --human-readable \                   # Tamanhos legíveis
    --progress \                         # Progresso de cada arquivo
    --partial \                          # Mantém arquivos parciais (retoma se falhar)
    --rsh="ssh -i ${CHAVE_SSH} -p ${PORTA_SSH} -o StrictHostKeyChecking=accept-new" \
    #     ↑ --rsh = "Remote Shell" = qual programa usar para conexão
    "$PASTA_ORIGEM/" \
    "${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}"
    # ↑ Formato remoto: usuario@servidor:/caminho/destino

echo ""
read -p "▶️  Executar transferência real? (s/n): " CONFIRMAR

if [[ "$CONFIRMAR" != "s" && "$CONFIRMAR" != "S" ]]; then
    log "${AMARELO}🛑 Cancelado pelo usuário${RESET}"
    exit 0
fi

# -------------------------------------------
# PASSO 5: Executar rsync remoto real
# -------------------------------------------
log "${VERDE}🚀 Iniciando transferência remota...${RESET}"

# Guardar o momento que começou
# date +%s = segundos desde 1970 (usado para calcular tempo)
INICIO=$(date +%s)

rsync \
    --archive \
    --verbose \
    --compress \
    --human-readable \
    --progress \
    --partial \          # Retoma transferências interrompidas
    --stats \            # Mostra estatísticas ao final
    --rsh="ssh -i ${CHAVE_SSH} -p ${PORTA_SSH} -o StrictHostKeyChecking=accept-new" \
    "$PASTA_ORIGEM/" \
    "${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}"

CODIGO_SAIDA=$?   # Guarda o resultado antes que outro comando sobrescreva

# -------------------------------------------
# PASSO 6: Calcular tempo e mostrar resultado
# -------------------------------------------
FIM=$(date +%s)
TEMPO_TOTAL=$((FIM - INICIO))   # Subtração: fim - início em segundos

if [ $CODIGO_SAIDA -eq 0 ]; then
    log "${VERDE}✅ Transferência concluída com SUCESSO!${RESET}"
    log "   ⏱️  Tempo total: ${TEMPO_TOTAL} segundos"
    log "   📂 Destino: ${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}"
else
    log "${VERMELHO}❌ ERRO na transferência! Código: $CODIGO_SAIDA${RESET}"
    log ""
    log "Códigos de erro do rsync:"
    log "  1 = Erro de sintaxe"
    log "  11 = Sem espaço em disco"
    log "  23 = Erro parcial (alguns arquivos falharam)"
    log "  24 = Arquivo sumiu durante transferência"
    exit $CODIGO_SAIDA
fi
