#!/usr/bin/env bash

# ============================================================
# PROJETO FINAL: PIPELINE DE BACKUP EM LIFECYCLE
# O QUE ESTE SCRIPT FAZ:
# Comprime diretórios, armazena em locais com Rotação (Lifecycle).
# Mantem APENAS os últimos 7 backups na HD usando o Famoso comando Find 
# atrelado a xargs the Destruction! Retenção Automática!
# ============================================================

set -euo pipefail

# =================
# VARIAVEIS
# =================
SOURCE_DATA="/home/elias/documents" # Ou `/var/lib/mysql`
BKP_DEST="/bkp_nas_mount"           # Pasta the destino (NFS Mount ou Dir temp)
KEEP_DAYS=7
DB_NOME="docs_server"

TIMESTAMP=$(date +"%A_%d_%H%M") # EX: "Monday_15_1602.tar.gz"

echo "=== PIPELINE CRON GERAL: RETENCAO DB E ARCHIVES ==="

# Proteção Base 1
# Usando Operador Mutually Exclusive OR
[[ -d "$SOURCE_DATA" ]] || { echo "Não há origem pra gerar bkp!"; exit 1; }
[[ -d "$BKP_DEST" ]] || mkdir -p "$BKP_DEST"

# ============================
# PASSO 1 - CÓPIA COMPRESSÃO
# ============================
NOME_FILE_NOVO="${DB_NOME}-${TIMESTAMP}.tar.gz"
DESTINO_COMPLETO="$BKP_DEST/$NOME_FILE_NOVO"

echo "1. Analisando e gerando Block Compress de '$SOURCE_DATA' para a rede..."

# c=create, z=zip(gzip), f=to file (The file).
# Silenciamos The Error 2>/dev nll pq as vzs o tar reclama the files disappearing.
tar -czf "$DESTINO_COMPLETO" "$SOURCE_DATA" 2>/dev/null || true

if [[ -f "$DESTINO_COMPLETO" ]]; then
    echo "   [SUCESSO] ARQUIVO ZIP CRIADO: $DESTINO_COMPLETO"
else
    echo "   [FALHA] ERRO AO GERAR PACOTE."
    exit 1
fi

# ============================
# PASSO 2 - POLÍTICA DE RETENÇÃO (LIFECYCLE) THE MESTRE DA AWS
# ============================
echo ""
echo "2. O HD NÃO É INFINITO. Iniciando Politica Da Tesoura Retentiva (Apenas os últimos $KEEP_DAYS dias viverão!!)..."

# THE MAGIC FIND (Ele Acha na pasta de backup APENAS Arquivos (-f). Começando the name DB*.tar.
# Que possuém The MTIME (Modification Time) Maior/Antigos the 7 dias Atrás (+7). Semanal!
# E Joga atômico pela pipe the NullString pro `rm` (Lixo). Eles somem liberando HD!

ARQUIVOS_MORTOS=$(find "$BKP_DEST" -type f -name "${DB_NOME}-*.tar.gz" -mtime +"$KEEP_DAYS" -print)

if [[ -n "$ARQUIVOS_MORTOS" ]]; then
    # Se achamos algo, deletamos pro val!
    # print0 envia bytes isentos d espace pra deletar limpo.
    find "$BKP_DEST" -type f -name "${DB_NOME}-*.tar.gz" -mtime +"$KEEP_DAYS" -print0 | xargs -0 rm -f
    echo "   -> [Limpeza] Foram eliminadas Versões fósseis de 7 dias O.s. Espaço Devolvido!"
else
    echo "   -> [Manutenção] Nenhum Backup ultrapassou a validade ($KEEP_DAYS dias) ainda. Nenhum Arquivo Físico foi deletado hoje."
fi

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Salve o Script. Dê um  chmod o -WrX neles pra segurança e umask 077 p arquivos gerados `chmod 700 main.sh`. 
# - Enfie no crontab root: `0 3 * * * /scripts/main_bkps.sh > /var/log/bkpssys.log 2>&1`
# ============================================================

echo "Done."
