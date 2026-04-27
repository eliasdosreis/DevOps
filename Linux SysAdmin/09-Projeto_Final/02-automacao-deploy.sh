#!/bin/bash
# ==============================================================================
# Aula 09.02: PROJETO FINAL - Automação Base Cega BASH (A Magia de Dormir a Noite)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. A MENTALIDADE SÊNIOR 
# ------------------------------------------------------------------------------
# Um Junior Digita `apt update` 10 Vezes por Dia.
# Um Pleno Cria Um Script Bash `atualiza_sistema.sh` e o Roda Automaticamente.
# Um Sênior Cria O Script Bash, Injeta Um Tratamento de Erros, Audita O Retorno e Manda Pro Slack da Empresa O Log Base Sozinho Pra Todo Time Operacional Ver Silenciosamente Se O Update Expirou ou Deu Kernel Bug Panic Fhs!
# A Automação E o BashScript Corporativo E O Pai Das Engine Infra Imutables (Ansible / Chef).

# ------------------------------------------------------------------------------
# 2. OSCRIPT_ROBUSTO_DE_BKP.SH (EXEMPLO PRODUÇÃO PRONTA)
# ------------------------------------------------------------------------------
# A SINTAXE DE ERROS BASH MAGICA ABSOLUTA:
set -e          # SêniorIDADE 1: Se o Script Falhar 1 Linha No Meio (Ex: O CD Não Achou a pasta!). ELE CRASHA SOZINHO E MORRE NA HORA! ELE NÃO "CONTINUA" EXECUTANDO CEGO OS DELETES NAS LINHAS DE BAIXO APAGANDO O MUNDO (Safe Shell Exec)!
set -o pipefail # SêniorIDADE 2: Falhas em Pipes '|' Também Matam O Script Pra Proteção! As Variáves Zeras.

LOG_FILE="/var/log/backup_meusite.log"
DATE=$(date +%F_%T)   # Variável Magica Dinamica: (2025-10-18_03:00:22).
SOURCE="/var/www/meusite.com"
DEST="/mnt/s3_storage_backup"

# Log Cego e Lindo (AULA 1 MAGICA BASH ARROW >>).
echo "[${DATE}] INICIANDO O PROCESSO CORPORATIVO DE BACKUP B3..." >> $LOG_FILE

# Fazendo o Backup via Rsync (AULA 7) da Máquina de Bancos
# Redirecinando o Lixo Do Rsync (AULA 1 DE /dev/null STDOUT E 2>&1 ERRORS MAGICAS) Pra Log de Auditoria FHS:
if rsync -avhz --delete ${SOURCE} ${DEST} >> $LOG_FILE 2>&1; then
    echo "[${DATE}] SUCESSO. A Sincronização RSYNC Cega Amazon Funcionou." >> $LOG_FILE
    # MANDA UM BASH CURL Cego API SLACK DO DIRETOR "Backup Feito Sênior!".
else
    echo "[${DATE}] TERROR C-LEVEL ALERTA: O RSYNC QUEBROU NO MEIO DO DA NUVEM" >> $LOG_FILE
    # ACIONA ALARME PAGERDUTY SMS PRO Sênior ACORDAR ONDE ELE ESTIVER NO MUNDO!
    exit 1
fi

echo "[${DATE}] FINALIZANDO O CRONTAB DE ROTINA DIÁRIA PERFEITO." >> $LOG_FILE

# ------------------------------------------------------------------------------
# 3. VERIFICAÇÃO E TROUBLESHOOTING DE BASH
# ------------------------------------------------------------------------------
# - CENA: Aquele Script de Cima Deu Um Pau Oculto "VARIAVEL ${DEST} NOT FOUND OOM NULL ERROR". E O Script Ignorou e Fez Tudo Errado. E Sua Empresa Sumiu.
# Por que? O Shell Bash Script Cego NUNCA Exige Que a Variavel Exista Declarada Cega.
# Sê vc tentar ler a Variavel Magica '$DESTIONATIO' E vc ESQUECEU O "N"... Sabe quem é Ela?
# ELA É UMA VARIAVEL STRING VAZIA CEGA! Ela É O NADA!!!
# AÍ O "rm -rf $DESTIONATIO/*" DO JUNIOR... Vira `rm -rf /*`!!!!! (Ele Caga Pula o Nada... E BOTA A BARRA ROOT CEGA NO APAGADOR!). A Empresa é Excluida O Kernal e A VM Apaga A Si Mesma Do Mundo Sem Dó E VC Perde O Emprego Sem Entender! 
# A Prevenção: `set -u` (UmBound Variable Death Flag). O Kernel Morre De Paragem Cega E Protege Antes de Lero A Variavel Se Vc Não a Setou Nula Explicitamente Cega Magica FHS!! Seguro Absolute Bash!
