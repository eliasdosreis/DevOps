#!/usr/bin/env bash

# ============================================================
# PROJETO FINAL: DEPLOY AUTOMATIZADO COM ROLLBACK
# O QUE ESTE SCRIPT FAZ:
# Une todo o conhecimento do curso (Variáveis, Ifs, Logs, Args,
# Traps, Rsync e SystemD) para criar uma pipeline de deploy 
# 100% profissional e imune a falhas.
# ============================================================

set -euo pipefail

# =================
# VARIAVEIS GLOBAIS
# =================
APP_DIR="/var/www/minha_app"
BACKUP_DIR="/var/backups/deploys"
LOG_FILE="/var/log/deploy_app.log"
APP_NAME="myapp_v1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# =================
# PREPARAÇÃO (TRAP)
# =================
# O Cleanup gracioso caso o deploy quebre no meio copiando arquivos
limpar_lixo_em_falha() {
    # Ele executa isso automático se tomar Error Exit
    if [[ $? -ne 0 ]]; then
         echo "[FALHA CRITICA] Pipeline de Deploy Abortada! Iniciando rollback de emergência..." | tee -a "$LOG_FILE"
         # Aqui colariamos a lógica real de desfazer pasta tmp.
         rm -rf "/tmp/deploy_pendente" 2>/dev/null || true
    fi
}
trap limpar_lixo_em_falha EXIT

# =================
# FUNÇÕES CORE
# =================
logger() {
    # Usa Tee pra jogar no Terminal E no Disco.
    local MSG="[$(date +'%Y-%m-%d %H:%M:%S')] [$1] $2"
    echo "$MSG" | tee -a "$LOG_FILE"
}

verificar_requisitos() {
    logger "INFO" "Etapa 1: Validando integridade do Ambiente..."
    
    # 1. Validar se Sou Root
    if [[ $(id -u) -ne 0 ]]; then
        logger "ERROR" "Este Deployador mestre exige permissão Root (sudo)."
        exit 1
    fi

    # 2. Validar Existencia de Pastas vitais
    [[ -d "$APP_DIR" ]] || mkdir -p "$APP_DIR"
    [[ -d "$BACKUP_DIR" ]] || mkdir -p "$BACKUP_DIR"
}

executar_backup_predeploy() {
    logger "INFO" "Etapa 2: Gerando Snapshot de Segurança do código vivo atual..."
    
    # Criamos o arq zip do app se ele existir usando Tar Multicore local.
    local FILE_NAME="BKP_${APP_NAME}_${TIMESTAMP}.tar.gz"
    
    if [[ "$(ls -A $APP_DIR 2>/dev/null)" ]]; then
       tar -czf "${BACKUP_DIR}/${FILE_NAME}" -C "$APP_DIR" . 2>/dev/null
       logger "INFO" "Backup efetuado com Sucesso em: ${BACKUP_DIR}/${FILE_NAME}"
       
       # Salva nativamente o Link do backup numa variavel Global para o Rollback da main enxergar.
       BKP_CRIADO="${BACKUP_DIR}/${FILE_NAME}" 
    else
       logger "WARN" "A Aplicação atual está 100% vaza. Cópia Backp Pulada."
       BKP_CRIADO="NENHUM"
    fi
}

aplicar_codigo_novo() {
    local PATH_SOURCE="$1"
    logger "INFO" "Etapa 3: Aplicando Código novo no Servidor vindo de ${PATH_SOURCE}"
    
    # Usando Sync Rsync atômico (Só atualiza os Diferentes). E deleta os antigos fantasmas!
    # Mock apenas no nosso script, pois nao temos path_source real
    # rsync -av --delete "$PATH_SOURCE/" "$APP_DIR/"
    
    sleep 1
    logger "INFO" "Arquivos Sincronizados com a Main do Sistema."
}

reiniciar_aplicacao() {
    logger "INFO" "Etapa 4: Reiniciando WebService (SystemD Graceful Restart)..."
    
    # Apenas visual e mocado pq não rodará num Systemd Real daqui
    # systemctl restart myapp.service
    sleep 1
    
    # Pós check - Verificar Retorno (Exit Code Real SystemD)
    # Se der erro no restart (Código quebrado porta travada)... a gente cai no || e faz Throw!
    if true; then  # Simula um Systemctl q deu Sucesso 0 !
        logger "INFO" "Deploy e Restart O.K."
    else
        logger "ERROR" "A Nova aplicacao Crashou na Subida!! Abortando p Rollbak!"
        exit 1 # O Exit aciona o Trap e morre
    fi
}

# =================
# MAIN ENTRYPOINT
# =================
# O GetOpt processará o '-s /caminhodocodigo' passado por quem chamar o script.
CODIGO_NOVO=""

while getopts "s:" opt; do
    case $opt in
        s) CODIGO_NOVO="$OPTARG" ;;
        *) echo "Uso: $0 -s /caminho/do_seu_novo_codigo_buildado" >&2; exit 1 ;;
    esac
done

# Só continua se passou a string
if [[ -z "$CODIGO_NOVO" ]]; then
    echo "ERRO: Path do código Source não fornecido (-s)." >&2
    exit 1
fi

# THE PIPELINE
echo "------------------------------------------------------"
logger "INFO" "INICIANDO DEPLOY CONTINUO [ $APP_NAME ] "
echo "------------------------------------------------------"

verificar_requisitos
executar_backup_predeploy
aplicar_codigo_novo "$CODIGO_NOVO"
reiniciar_aplicacao

echo "------------------------------------------------------"
logger "INFO" " DEPLOY FINALIZADO COM EXITO MÁXIMO! A T L A S "
echo "------------------------------------------------------"

# O Status final da execução chega no Return 0 implicito pro CI/CD (Jenkins/Actions) ver verdinho!
