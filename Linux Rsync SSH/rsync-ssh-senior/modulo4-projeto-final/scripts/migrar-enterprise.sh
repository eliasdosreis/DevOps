#!/bin/bash
# =============================================================================
# PROJETO FINAL SÊNIOR: Sistema de Migração Enterprise com rsync + SSH
# Módulo 4 - Projeto Final
# Alex DevOps Coach
# =============================================================================
#
# 🧒 PARA CRIANÇAS (e qualquer pessoa!):
#
# Imagine que você é responsável por mover uma BIBLIOTECA INTEIRA
# para um prédio novo. Você precisa:
#   1. Verificar se o prédio novo tem espaço suficiente
#   2. Fazer uma lista de todos os livros
#   3. Transportar os livros com segurança
#   4. Conferir se todos chegaram sem danos
#   5. Avisar quando terminar
#
# Este script faz exatamente isso, mas com ARQUIVOS DE COMPUTADOR!
#
# POR QUE ESTE É UM PROJETO NÍVEL SÊNIOR?
# ✅ Tratamento completo de erros
# ✅ Sistema de logs profissional
# ✅ Verificação de pré-requisitos
# ✅ Verificação de integridade
# ✅ Retry automático com backoff exponencial
# ✅ Relatório detalhado ao final
# ✅ Configuração externa
# ✅ Segurança com chaves SSH
# ✅ Excludes inteligentes
# ✅ Notificação de resultado
#
# =============================================================================
#
# USO:
#   ./migrar-enterprise.sh [--dry-run] [--config arquivo.conf]
#
# EXEMPLOS:
#   ./migrar-enterprise.sh --dry-run          # Simular sem copiar
#   ./migrar-enterprise.sh                     # Executar migração real
#   ./migrar-enterprise.sh --config prod.conf  # Usar config específica
#
# =============================================================================

# -------------------------------------------
# CONFIGURAÇÃO DO BASH
# -------------------------------------------
# set -e = sair imediatamente se qualquer comando falhar
# DESABILITADO aqui porque queremos tratar erros manualmente
# set -e

# set -u = erro se usar variável não definida
set -u

# set -o pipefail = pipes retornam o erro do comando que falhou
# Sem isso: "comando_com_erro | tee arquivo" sempre retorna 0 (sucesso)
set -o pipefail

# -------------------------------------------
# CONSTANTES E CORES
# -------------------------------------------
# readonly = variável que nunca pode ser modificada (como const)
readonly VERSAO="2.0.0"
readonly NOME_SCRIPT="$(basename "$0")"        # Nome deste script
readonly DIR_SCRIPT="$(cd "$(dirname "$0")" && pwd)"  # Pasta do script (caminho absoluto)

# Cores para o terminal (usando códigos ANSI)
readonly VERDE='\033[0;32m'
readonly VERMELHO='\033[0;31m'
readonly AMARELO='\033[1;33m'
readonly AZUL='\033[0;34m'
readonly CIANO='\033[0;36m'
readonly NEGRITO='\033[1m'
readonly RESET='\033[0m'

# Emojis para tornar o output mais legível
readonly OK="✅"
readonly ERRO="❌"
readonly AVISO="⚠️ "
readonly INFO="ℹ️ "
readonly FOGUETE="🚀"
readonly RELOGIO="⏱️ "
readonly PASTA="📁"
readonly CHAVE="🔑"
readonly RELATORIO="📊"

# -------------------------------------------
# VARIÁVEIS GLOBAIS DE ESTADO
# -------------------------------------------
# Estas variáveis guardam o "estado" do script
# (o que aconteceu até agora)
MODO_DRY_RUN="false"             # true = simular, false = executar de verdade
ARQUIVO_CONFIG=""                 # Caminho do arquivo de configuração
ARQUIVO_LOG=""                    # Caminho do arquivo de log desta execução
TEMPO_INICIO=0                    # Quando a execução começou
ARQUIVOS_TRANSFERIDOS=0           # Quantos arquivos foram transferidos
BYTES_TRANSFERIDOS=0              # Quantos bytes foram transferidos
TENTATIVA_ATUAL=0                 # Em qual tentativa estamos

# Arquivo onde guardamos o resumo do rsync (para análise depois)
ARQUIVO_STATS="/tmp/rsync_stats_$$.txt"  # $$ = PID do processo (único)

# =============================================================================
# FUNÇÕES DE UTILITÁRIO
# =============================================================================

# -------------------------------------------
# Função: Exibir uso do script
# -------------------------------------------
# Uma boa documentação interna é marca de código Sênior!
exibir_uso() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║          Sistema de Migração Enterprise v2.0.0               ║
║          Alex DevOps Coach                                    ║
╚══════════════════════════════════════════════════════════════╝

USO:
  ./migrar-enterprise.sh [OPÇÕES]

OPÇÕES:
  --dry-run           Simula a migração sem copiar arquivos
  --config ARQUIVO    Usa arquivo de configuração específico
  --help              Exibe esta mensagem

EXEMPLOS:
  ./migrar-enterprise.sh --dry-run
  ./migrar-enterprise.sh --config /etc/rsync/producao.conf

ARQUIVO DE CONFIGURAÇÃO:
  Por padrão, usa: ./migrar.conf
  Crie o arquivo a partir do template: cp migrar.conf.exemplo migrar.conf
EOF
}

# -------------------------------------------
# Função: Sistema de Logs
# -------------------------------------------
# Um bom sistema de log é ESSENCIAL para produção.
# Permite investigar problemas depois (post-mortem).
log() {
    # Parâmetros:
    # $1 = nível (INFO, OK, AVISO, ERRO, DEBUG)
    # $2 = mensagem
    local NIVEL="${1:-INFO}"
    local MENSAGEM="${2:-}"
    
    # Timestamp com milissegundos para logs precisos
    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Formatar linha de log
    local LINHA_LOG="[${TIMESTAMP}] [${NIVEL}] ${MENSAGEM}"
    
    # Exibir na tela com cor de acordo com o nível
    case "$NIVEL" in
        "INFO")  echo -e "${AZUL}${LINHA_LOG}${RESET}" ;;
        "OK")    echo -e "${VERDE}${LINHA_LOG}${RESET}" ;;
        "AVISO") echo -e "${AMARELO}${LINHA_LOG}${RESET}" ;;
        "ERRO")  echo -e "${VERMELHO}${LINHA_LOG}${RESET}" >&2 ;;  # Erros vão para stderr
        "DEBUG") echo -e "${CIANO}${LINHA_LOG}${RESET}" ;;
        *)       echo -e "${LINHA_LOG}" ;;
    esac
    
    # Gravar no arquivo de log (sem cores, para o arquivo ficar limpo)
    if [ -n "$ARQUIVO_LOG" ]; then
        echo "$LINHA_LOG" >> "$ARQUIVO_LOG"
    fi
}

# Atalhos para cada nível de log
info()  { log "INFO"  "$1"; }
ok()    { log "OK"    "$1"; }
aviso() { log "AVISO" "$1"; }
erro()  { log "ERRO"  "$1"; }

# -------------------------------------------
# Função: Separador visual no log
# -------------------------------------------
separador() {
    local TITULO="${1:-}"
    local LINHA="════════════════════════════════════════════════════"
    
    if [ -n "$TITULO" ]; then
        info "${LINHA}"
        info "  ${TITULO}"
        info "${LINHA}"
    else
        info "${LINHA}"
    fi
}

# -------------------------------------------
# Função: Calcular e formatar duração
# -------------------------------------------
# Recebe segundos, retorna "2h 30min 45seg"
formatar_duracao() {
    local SEGUNDOS="$1"
    
    # Divisão inteira em bash usa $(( ))
    local HORAS=$((SEGUNDOS / 3600))
    local MINUTOS=$(((SEGUNDOS % 3600) / 60))  # % = resto da divisão
    local SEGS=$((SEGUNDOS % 60))
    
    if [ $HORAS -gt 0 ]; then
        echo "${HORAS}h ${MINUTOS}min ${SEGS}s"
    elif [ $MINUTOS -gt 0 ]; then
        echo "${MINUTOS}min ${SEGS}s"
    else
        echo "${SEGS}s"
    fi
}

# -------------------------------------------
# Função: Formatar bytes em unidade legível
# -------------------------------------------
formatar_bytes() {
    local BYTES="$1"
    
    # Comparações com números grandes em bash
    if [ "$BYTES" -gt 1073741824 ]; then    # > 1 GB
        echo "$(echo "scale=2; $BYTES / 1073741824" | bc) GB"
    elif [ "$BYTES" -gt 1048576 ]; then      # > 1 MB
        echo "$(echo "scale=2; $BYTES / 1048576" | bc) MB"
    elif [ "$BYTES" -gt 1024 ]; then         # > 1 KB
        echo "$(echo "scale=2; $BYTES / 1024" | bc) KB"
    else
        echo "${BYTES} bytes"
    fi
}

# =============================================================================
# FUNÇÕES PRINCIPAIS DO SISTEMA
# =============================================================================

# -------------------------------------------
# Função: Inicializar o sistema de logs
# -------------------------------------------
inicializar_logs() {
    # Criar pasta de logs com data (organizado por dia)
    local PASTA_LOGS="/var/log/migracoes"
    local DATA_HOJE
    DATA_HOJE=$(date '+%Y-%m-%d')
    
    # Se não tiver permissão em /var/log, usar /tmp
    if [ ! -w "/var/log" ]; then
        PASTA_LOGS="/tmp/migracoes-log"
    fi
    
    # Criar pasta de logs do dia de hoje
    mkdir -p "${PASTA_LOGS}/${DATA_HOJE}"
    
    # Nome do arquivo: migração_2024-01-15_14-30-00.log
    local TIMESTAMP_ARQUIVO
    TIMESTAMP_ARQUIVO=$(date '+%H-%M-%S')
    ARQUIVO_LOG="${PASTA_LOGS}/${DATA_HOJE}/migracao_${TIMESTAMP_ARQUIVO}.log"
    
    # Criar o arquivo de log
    touch "$ARQUIVO_LOG"
    
    # Exportar para que outras funções possam usar
    export ARQUIVO_LOG
    
    echo "📝 Log sendo gravado em: $ARQUIVO_LOG"
}

# -------------------------------------------
# Função: Carregar configurações
# -------------------------------------------
carregar_configuracoes() {
    separador "CARREGANDO CONFIGURAÇÕES"
    
    # Tentar arquivo de configuração passado como argumento
    # Se não foi passado, tentar o padrão
    local ARQUIVO
    if [ -n "$ARQUIVO_CONFIG" ]; then
        ARQUIVO="$ARQUIVO_CONFIG"
    else
        ARQUIVO="${DIR_SCRIPT}/migrar.conf"
    fi
    
    info "Procurando arquivo de configuração: $ARQUIVO"
    
    if [ -f "$ARQUIVO" ]; then
        # source = carregar o arquivo (executar os comandos de configuração)
        # shellcheck disable=SC1090 = instrução para o linter ignorar esta linha
        source "$ARQUIVO"
        ok "Configurações carregadas de: $ARQUIVO"
    else
        # Usar valores padrão para DEMONSTRAÇÃO
        aviso "Arquivo de config não encontrado. Usando valores padrão (DEMO)."
        
        # ===== CONFIGURAÇÕES PADRÃO =====
        # Modifique estas variáveis ou crie um arquivo migrar.conf
        SERVIDOR="servidor-exemplo.empresa.com"
        USUARIO="devops"
        PORTA_SSH="22"
        CHAVE_SSH="$HOME/.ssh/rsync_senior_key"
        PASTA_ORIGEM="/dados/aplicacao"
        PASTA_DESTINO="/backup/aplicacao"
        MAX_TENTATIVAS=3
        INTERVALO_BASE=30    # segundos (cresce exponencialmente)
        ESPACO_MARGEM=20     # % de margem de segurança no espaço
        
        # Arquivos para excluir (não copiar)
        EXCLUIR=(
            "*.tmp"
            "*.log"
            ".git/"
            "node_modules/"
            "__pycache__/"
            "*.pyc"
            ".DS_Store"
            "Thumbs.db"
        )
    fi
}

# -------------------------------------------
# Função: Validar todas as configurações
# -------------------------------------------
validar_configuracoes() {
    separador "VALIDANDO CONFIGURAÇÕES"
    
    local ERROS=0  # Contador de erros encontrados
    
    # Verificar cada variável obrigatória
    # É boa prática mostrar TODOS os erros de uma vez
    # em vez de parar no primeiro (obriga o usuário a corrigir um por um)
    
    # Verificar variáveis de texto
    for VAR_NOME in SERVIDOR USUARIO PORTA_SSH PASTA_ORIGEM PASTA_DESTINO; do
        # ${!VAR_NOME} = expansão indireta = pegar o valor da variável cujo nome está em VAR_NOME
        local VAR_VALOR="${!VAR_NOME}"
        
        if [ -z "$VAR_VALOR" ]; then
            erro "Variável obrigatória não definida: $VAR_NOME"
            ((ERROS++))
        else
            info "  $VAR_NOME = $VAR_VALOR"
        fi
    done
    
    # Verificar se a chave SSH existe
    if [ -z "${CHAVE_SSH:-}" ]; then
        erro "CHAVE_SSH não definida!"
        ((ERROS++))
    elif [ ! -f "$CHAVE_SSH" ]; then
        erro "Chave SSH não encontrada: $CHAVE_SSH"
        erro "Execute: ssh-keygen -t ed25519 -f $CHAVE_SSH"
        ((ERROS++))
    else
        # Verificar permissão da chave (deve ser 600)
        local PERMISSAO
        PERMISSAO=$(stat -c "%a" "$CHAVE_SSH" 2>/dev/null || stat -f "%OLp" "$CHAVE_SSH" 2>/dev/null)
        
        if [ "$PERMISSAO" = "600" ]; then
            ok "  Chave SSH: $CHAVE_SSH (permissão: $PERMISSAO ✅)"
        else
            aviso "Permissão da chave incorreta: $PERMISSAO (deveria ser 600)"
            aviso "Corrigindo automaticamente..."
            chmod 600 "$CHAVE_SSH"
        fi
    fi
    
    # Verificar se a pasta de ORIGEM existe
    if [ ! -d "${PASTA_ORIGEM:-}" ]; then
        erro "Pasta de origem não encontrada: ${PASTA_ORIGEM:-}"
        ((ERROS++))
    fi
    
    # Se houve algum erro, não continuar
    if [ $ERROS -gt 0 ]; then
        erro "$ERROS erro(s) de configuração encontrado(s). Corrija e tente novamente."
        exit 1
    fi
    
    ok "Todas as configurações válidas!"
}

# -------------------------------------------
# Função: Verificar conexão SSH
# -------------------------------------------
verificar_conexao_ssh() {
    separador "VERIFICANDO CONEXÃO SSH"
    
    info "Testando conexão com: ${USUARIO}@${SERVIDOR}:${PORTA_SSH}"
    
    # Opções SSH para automação segura:
    # -o BatchMode=yes          = não perguntar nada interativo
    # -o ConnectTimeout=15      = desistir após 15 segundos
    # -o StrictHostKeyChecking=accept-new = aceitar novos hosts automaticamente
    #    (em produção real, use 'yes' e pré-configure os hosts conhecidos)
    # -o PasswordAuthentication=no = nunca usar senha (só chave)
    ssh \
        -i "$CHAVE_SSH" \
        -p "$PORTA_SSH" \
        -o BatchMode=yes \
        -o ConnectTimeout=15 \
        -o StrictHostKeyChecking=accept-new \
        -o PasswordAuthentication=no \
        "${USUARIO}@${SERVIDOR}" \
        "echo 'conexao-ok'" \
        2>/dev/null | grep -q "conexao-ok"
    
    if [ $? -eq 0 ]; then
        ok "Conexão SSH funcionando!"
        
        # Verificar versão do rsync no servidor remoto
        info "Verificando rsync no servidor..."
        local VERSAO_RSYNC_REMOTA
        VERSAO_RSYNC_REMOTA=$(ssh \
            -i "$CHAVE_SSH" \
            -p "$PORTA_SSH" \
            -o BatchMode=yes \
            "${USUARIO}@${SERVIDOR}" \
            "rsync --version 2>/dev/null | head -1 || echo 'rsync nao encontrado'")
        
        info "  rsync remoto: $VERSAO_RSYNC_REMOTA"
    else
        erro "Falha na conexão SSH!"
        erro "Verifique:"
        erro "  1. Servidor online: ping $SERVIDOR"
        erro "  2. Porta aberta: nc -zv $SERVIDOR $PORTA_SSH"
        erro "  3. Chave autorizada no servidor: ~/.ssh/authorized_keys"
        exit 1
    fi
}

# -------------------------------------------
# Função: Verificar espaço em disco
# -------------------------------------------
verificar_espaco() {
    separador "VERIFICANDO ESPAÇO EM DISCO"
    
    # Calcular tamanho da origem
    info "Calculando tamanho da origem..."
    local TAMANHO_ORIGEM
    TAMANHO_ORIGEM=$(du -sb "$PASTA_ORIGEM" 2>/dev/null | awk '{print $1}')
    
    if [ -z "$TAMANHO_ORIGEM" ]; then
        aviso "Não foi possível calcular tamanho da origem"
        return  # Continuar mesmo assim (não é erro fatal)
    fi
    
    info "  Tamanho da origem: $(formatar_bytes "$TAMANHO_ORIGEM")"
    
    # Verificar espaço no servidor remoto
    info "Verificando espaço no servidor remoto..."
    local ESPACO_LIVRE_REMOTO
    ESPACO_LIVRE_REMOTO=$(ssh \
        -i "$CHAVE_SSH" \
        -p "$PORTA_SSH" \
        -o BatchMode=yes \
        "${USUARIO}@${SERVIDOR}" \
        "df -B1 ${PASTA_DESTINO} 2>/dev/null | awk 'NR==2{print \$4}' || df -B1 / | awk 'NR==2{print \$4}'" \
        2>/dev/null)
    
    if [ -z "$ESPACO_LIVRE_REMOTO" ]; then
        aviso "Não foi possível verificar espaço no servidor"
        return
    fi
    
    info "  Espaço livre no servidor: $(formatar_bytes "$ESPACO_LIVRE_REMOTO")"
    
    # Calcular espaço necessário com margem de segurança
    local MARGEM=$((ESPACO_MARGEM + 100))  # Ex: 120% do tamanho original
    local ESPACO_NECESSARIO=$(( TAMANHO_ORIGEM * MARGEM / 100 ))
    
    info "  Espaço necessário (com ${ESPACO_MARGEM}% de margem): $(formatar_bytes "$ESPACO_NECESSARIO")"
    
    if [ "$ESPACO_LIVRE_REMOTO" -ge "$ESPACO_NECESSARIO" ]; then
        local SOBRA=$((ESPACO_LIVRE_REMOTO - ESPACO_NECESSARIO))
        ok "Espaço suficiente! (sobra: $(formatar_bytes "$SOBRA"))"
    else
        local FALTA=$((ESPACO_NECESSARIO - ESPACO_LIVRE_REMOTO))
        erro "Espaço INSUFICIENTE no servidor!"
        erro "Faltam: $(formatar_bytes "$FALTA")"
        exit 1
    fi
}

# -------------------------------------------
# Função: Construir opções do rsync
# -------------------------------------------
construir_opcoes_rsync() {
    # Array de opções do rsync
    # Arrays em bash: MINHA_LISTA=("item1" "item2" "item3")
    OPCOES_RSYNC=(
        "--archive"          # = -a: preserva permissões, datas, links, recursivo
        "--compress"         # = -z: comprime durante transferência
        "--human-readable"   # = -h: tamanhos em KB/MB/GB
        "--progress"         # Mostra progresso de cada arquivo
        "--stats"            # Estatísticas detalhadas ao final
        "--partial"          # Mantém arquivos parciais (retoma se interromper)
        "--timeout=120"      # Desiste se ficar 120s sem atividade
        "--checksum"         # Verifica integridade pelo conteúdo, não só pela data
    )
    
    # Modo dry-run (simular sem copiar)
    if [ "$MODO_DRY_RUN" = "true" ]; then
        OPCOES_RSYNC+=("--dry-run")
        aviso "MODO SIMULAÇÃO ATIVO - Nenhum arquivo será copiado!"
    fi
    
    # Adicionar arquivos de exclusão
    # A sintaxe "${ARRAY[@]}" expande todos os elementos do array
    for PADRAO in "${EXCLUIR[@]:-}"; do
        if [ -n "$PADRAO" ]; then
            OPCOES_RSYNC+=("--exclude=${PADRAO}")
        fi
    done
    
    # Configurar o SSH como protocolo de transporte
    # O rsync usa isso para saber como conectar ao servidor remoto
    local SSH_CMD="ssh -i ${CHAVE_SSH} -p ${PORTA_SSH}"
    SSH_CMD+=" -o BatchMode=yes"
    SSH_CMD+=" -o ConnectTimeout=15"
    SSH_CMD+=" -o ServerAliveInterval=30"    # Verifica se o servidor ainda está vivo a cada 30s
    SSH_CMD+=" -o ServerAliveCountMax=3"     # 3 verificações sem resposta = desconectar
    SSH_CMD+=" -o Compression=no"           # Desabilitar compressão SSH (rsync já comprime)
    
    OPCOES_RSYNC+=("--rsh=${SSH_CMD}")
    
    # Arquivo para guardar as estatísticas
    OPCOES_RSYNC+=("--log-file=${ARQUIVO_STATS}")
}

# -------------------------------------------
# Função: Executar rsync com backoff exponencial
# -------------------------------------------
# BACKOFF EXPONENCIAL: Se falha, espera 30s, depois 60s, depois 120s...
# É como tocar a campainha de um amigo: espera um pouco mais cada vez.
executar_rsync_com_retry() {
    separador "EXECUTANDO MIGRAÇÃO"
    
    if [ "$MODO_DRY_RUN" = "true" ]; then
        aviso "${FOGUETE} MODO SIMULAÇÃO"
    else
        info "${FOGUETE} MIGRAÇÃO REAL"
    fi
    
    info "Origem:  $PASTA_ORIGEM/"
    info "Destino: ${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}"
    info ""
    
    # Registrar tempo de início total
    TEMPO_INICIO=$(date +%s)
    
    local TENTATIVA=1
    
    # Loop de tentativas
    while [ $TENTATIVA -le $MAX_TENTATIVAS ]; do
        TENTATIVA_ATUAL=$TENTATIVA
        
        info "──────────────────────────────────────"
        info "Tentativa ${TENTATIVA} de ${MAX_TENTATIVAS}"
        info "──────────────────────────────────────"
        
        local INICIO_TENTATIVA
        INICIO_TENTATIVA=$(date +%s)
        
        # Executar o rsync
        # "${OPCOES_RSYNC[@]}" expande todo o array de opções
        rsync \
            "${OPCOES_RSYNC[@]}" \
            "${PASTA_ORIGEM}/" \
            "${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}" \
            2>&1  # Redirecionar stderr para stdout (para capturar tudo)
        
        local CODIGO_SAIDA=$?
        
        local FIM_TENTATIVA
        FIM_TENTATIVA=$(date +%s)
        local DURACAO_TENTATIVA=$((FIM_TENTATIVA - INICIO_TENTATIVA))
        
        if [ $CODIGO_SAIDA -eq 0 ]; then
            ok "Tentativa ${TENTATIVA} CONCLUÍDA em $(formatar_duracao "$DURACAO_TENTATIVA")"
            return 0  # SUCESSO! Sair da função com código 0
        fi
        
        # Analisar o código de erro do rsync
        local DESCRICAO_ERRO
        case $CODIGO_SAIDA in
            1)  DESCRICAO_ERRO="Erro de sintaxe ou uso" ;;
            2)  DESCRICAO_ERRO="Incompatibilidade de protocolo" ;;
            3)  DESCRICAO_ERRO="Erro selecionando arquivos" ;;
            4)  DESCRICAO_ERRO="Ação não suportada" ;;
            5)  DESCRICAO_ERRO="Erro iniciando protocolo cliente-servidor" ;;
            10) DESCRICAO_ERRO="Erro de socket (problema de rede)" ;;
            11) DESCRICAO_ERRO="Erro de I/O (disco cheio?)" ;;
            12) DESCRICAO_ERRO="Erro no fluxo de dados" ;;
            20) DESCRICAO_ERRO="Interrompido pelo usuário (CTRL+C)" ;;
            23) DESCRICAO_ERRO="Transferência parcial (alguns arquivos falharam)" ;;
            24) DESCRICAO_ERRO="Arquivo sumiu durante transferência" ;;
            25) DESCRICAO_ERRO="Limite de deleções atingido" ;;
            30) DESCRICAO_ERRO="Timeout de leitura/escrita" ;;
            35) DESCRICAO_ERRO="Timeout esperando dados do servidor" ;;
            *)  DESCRICAO_ERRO="Erro desconhecido" ;;
        esac
        
        erro "Tentativa ${TENTATIVA} FALHOU! Código: $CODIGO_SAIDA ($DESCRICAO_ERRO)"
        
        # Se era a última tentativa, desistir
        if [ $TENTATIVA -ge $MAX_TENTATIVAS ]; then
            erro "Todas as tentativas esgotadas!"
            return $CODIGO_SAIDA
        fi
        
        # Calcular tempo de espera com BACKOFF EXPONENCIAL
        # Tentativa 1 falhou → espera 30s
        # Tentativa 2 falhou → espera 60s  (30 * 2^1)
        # Tentativa 3 falhou → espera 120s (30 * 2^2)
        # Assim evitamos sobrecarregar o servidor com tentativas rápidas
        local ESPERA=$(( INTERVALO_BASE * (2 ** (TENTATIVA - 1)) ))
        
        # Limitar a espera máxima a 10 minutos
        if [ $ESPERA -gt 600 ]; then
            ESPERA=600
        fi
        
        aviso "Aguardando ${ESPERA}s antes da próxima tentativa..."
        aviso "(Backoff exponencial: tentativa $((TENTATIVA+1)) de $MAX_TENTATIVAS)"
        
        sleep "$ESPERA"
        
        ((TENTATIVA++))
    done
}

# -------------------------------------------
# Função: Verificar integridade pós-migração
# -------------------------------------------
verificar_integridade_pos_migracao() {
    separador "VERIFICAÇÃO DE INTEGRIDADE"
    
    # Não verificar em modo dry-run (não houve cópia)
    if [ "$MODO_DRY_RUN" = "true" ]; then
        info "Modo simulação: verificação de integridade ignorada"
        return 0
    fi
    
    info "Comparando número de arquivos..."
    
    # Contar arquivos na origem
    local QTD_ORIGEM
    QTD_ORIGEM=$(find "$PASTA_ORIGEM" -type f | wc -l)
    
    # Contar arquivos no destino (via SSH)
    local QTD_DESTINO
    QTD_DESTINO=$(ssh \
        -i "$CHAVE_SSH" \
        -p "$PORTA_SSH" \
        -o BatchMode=yes \
        "${USUARIO}@${SERVIDOR}" \
        "find ${PASTA_DESTINO} -type f 2>/dev/null | wc -l" \
        2>/dev/null)
    
    info "  Arquivos na origem:  $QTD_ORIGEM"
    info "  Arquivos no destino: $QTD_DESTINO"
    
    # Comparar (com tolerância de 0 diferença)
    if [ "$QTD_ORIGEM" -eq "$QTD_DESTINO" ]; then
        ok "Número de arquivos CORRETO!"
    else
        local DIFERENCA=$((QTD_ORIGEM - QTD_DESTINO))
        aviso "Diferença de $DIFERENCA arquivo(s)!"
        aviso "Pode ser por exclusões configuradas ou arquivos temporários"
    fi
    
    # Comparar tamanho total
    info ""
    info "Comparando tamanho total..."
    
    local TAMANHO_ORIGEM
    TAMANHO_ORIGEM=$(du -sb "$PASTA_ORIGEM" | awk '{print $1}')
    
    local TAMANHO_DESTINO
    TAMANHO_DESTINO=$(ssh \
        -i "$CHAVE_SSH" \
        -p "$PORTA_SSH" \
        -o BatchMode=yes \
        "${USUARIO}@${SERVIDOR}" \
        "du -sb ${PASTA_DESTINO} 2>/dev/null | awk '{print \$1}'" \
        2>/dev/null)
    
    info "  Tamanho origem:  $(formatar_bytes "${TAMANHO_ORIGEM:-0}")"
    info "  Tamanho destino: $(formatar_bytes "${TAMANHO_DESTINO:-0}")"
    
    # Tolerância de 5% na diferença de tamanho
    # (diferenças pequenas são normais por causa de links simbólicos, etc)
    if [ -n "$TAMANHO_DESTINO" ] && [ "$TAMANHO_ORIGEM" -gt 0 ]; then
        local DIFERENCA_PERCENT=$(( (TAMANHO_ORIGEM - TAMANHO_DESTINO) * 100 / TAMANHO_ORIGEM ))
        
        # ${DIFERENCA_PERCENT#-} = remove o sinal negativo (valor absoluto)
        local DIFERENCA_ABS="${DIFERENCA_PERCENT#-}"
        
        if [ "$DIFERENCA_ABS" -le 5 ]; then
            ok "Tamanho dentro da tolerância (diferença: ${DIFERENCA_PERCENT}%)"
        else
            aviso "Diferença de tamanho maior que 5%! (${DIFERENCA_PERCENT}%)"
        fi
    fi
}

# -------------------------------------------
# Função: Gerar relatório final
# -------------------------------------------
gerar_relatorio_final() {
    local CODIGO_SAIDA="${1:-0}"
    
    separador "RELATÓRIO FINAL"
    
    # Calcular tempo total
    local TEMPO_FIM
    TEMPO_FIM=$(date +%s)
    local TEMPO_TOTAL=$((TEMPO_FIM - TEMPO_INICIO))
    
    # Determinar status final
    local STATUS
    if [ $CODIGO_SAIDA -eq 0 ]; then
        STATUS="${OK} SUCESSO"
    else
        STATUS="${ERRO} FALHA (código: $CODIGO_SAIDA)"
    fi
    
    # Exibir relatório
    echo ""
    echo -e "${NEGRITO}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${NEGRITO}║           RELATÓRIO DE MIGRAÇÃO                   ║${RESET}"
    echo -e "${NEGRITO}╚══════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${NEGRITO}Status:${RESET}          $STATUS"
    echo -e "  ${NEGRITO}Modo:${RESET}            $([ "$MODO_DRY_RUN" = "true" ] && echo "SIMULAÇÃO" || echo "PRODUÇÃO")"
    echo -e "  ${NEGRITO}Servidor:${RESET}        ${USUARIO}@${SERVIDOR}:${PORTA_SSH}"
    echo -e "  ${NEGRITO}Origem:${RESET}          $PASTA_ORIGEM"
    echo -e "  ${NEGRITO}Destino:${RESET}         $PASTA_DESTINO"
    echo -e "  ${NEGRITO}Tentativas:${RESET}      $TENTATIVA_ATUAL de $MAX_TENTATIVAS"
    echo -e "  ${NEGRITO}Tempo total:${RESET}     $(formatar_duracao $TEMPO_TOTAL)"
    echo -e "  ${NEGRITO}Log salvo em:${RESET}    $ARQUIVO_LOG"
    echo ""
    
    # Extrair estatísticas do rsync (se o arquivo existir)
    if [ -f "$ARQUIVO_STATS" ]; then
        echo -e "  ${NEGRITO}Estatísticas rsync:${RESET}"
        
        # grep = procurar linhas que contêm um padrão
        grep -E "Number of files:|Total file size:|Total transferred" "$ARQUIVO_STATS" 2>/dev/null \
            | sed 's/^/    /' \
            | head -5
        
        echo ""
    fi
    
    echo -e "${NEGRITO}══════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Salvar relatório no log também
    log "INFO" "════ RELATÓRIO FINAL ════"
    log "$([ $CODIGO_SAIDA -eq 0 ] && echo "OK" || echo "ERRO")" "Status: $STATUS"
    log "INFO" "Tempo total: $(formatar_duracao $TEMPO_TOTAL)"
    log "INFO" "Log: $ARQUIVO_LOG"
}

# -------------------------------------------
# Função: Limpeza ao sair
# -------------------------------------------
# Esta função é chamada automaticamente quando o script termina
# Seja por sucesso, erro ou CTRL+C
limpeza() {
    local CODIGO_SAIDA=$?
    
    # Remover arquivo temporário de stats
    rm -f "$ARQUIVO_STATS" 2>/dev/null
    
    # Se o script foi interrompido (CTRL+C), mostrar mensagem
    if [ $CODIGO_SAIDA -eq 130 ]; then
        echo ""
        aviso "Script interrompido pelo usuário (CTRL+C)"
        aviso "Arquivos parcialmente transferidos foram mantidos no destino"
        aviso "Execute novamente para retomar: o rsync continuará de onde parou!"
    fi
}

# Registrar a função de limpeza para ser chamada ao sair
# trap = "armadilha" para capturar sinais do sistema
# EXIT = qualquer saída | INT = CTRL+C | TERM = kill
trap limpeza EXIT INT TERM

# =============================================================================
# PROCESSAR ARGUMENTOS DA LINHA DE COMANDO
# =============================================================================

# Loop para processar cada argumento passado para o script
# "$@" = todos os argumentos passados para o script
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            # Modo simulação: ver o que SERIA feito sem fazer nada
            MODO_DRY_RUN="true"
            shift  # "shift" descarta o argumento atual e avança para o próximo
            ;;
        --config)
            # Próximo argumento é o arquivo de configuração
            ARQUIVO_CONFIG="${2:-}"
            if [ -z "$ARQUIVO_CONFIG" ]; then
                echo "❌ --config requer um arquivo como argumento"
                exit 1
            fi
            shift 2  # Descartar o --config E o nome do arquivo
            ;;
        --help|-h)
            exibir_uso
            exit 0
            ;;
        *)
            echo "❌ Argumento desconhecido: $1"
            echo "   Use --help para ver as opções disponíveis"
            exit 1
            ;;
    esac
done

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

# Banner de início
echo ""
echo -e "${NEGRITO}${CIANO}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   🚀 SISTEMA DE MIGRAÇÃO ENTERPRISE v${VERSAO}             ║"
echo "║   Alex DevOps Coach                                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Executar cada etapa em sequência
# Se qualquer etapa falhar, o script para (graças ao set -o pipefail)

# ETAPA 1: Inicializar logs
inicializar_logs

# ETAPA 2: Carregar configurações
carregar_configuracoes

# ETAPA 3: Validar configurações
validar_configuracoes

# ETAPA 4: Verificar conexão SSH
verificar_conexao_ssh

# ETAPA 5: Verificar espaço em disco
verificar_espaco

# ETAPA 6: Construir opções do rsync
construir_opcoes_rsync

# ETAPA 7: Executar migração com retry
executar_rsync_com_retry
CODIGO_FINAL=$?

# ETAPA 8: Verificar integridade pós-migração
if [ $CODIGO_FINAL -eq 0 ]; then
    verificar_integridade_pos_migracao
fi

# ETAPA 9: Gerar relatório final
gerar_relatorio_final $CODIGO_FINAL

# Sair com o código de sucesso ou erro
exit $CODIGO_FINAL
