#!/usr/bin/env bash

# ============================================================
# PROJETO FINAL: MONITOR DE SAÚDE DE SISTEMA (SRE TOOL)
# O QUE ESTE SCRIPT FAZ:
# Um espião de Performance atômico que usa o utilitarios Unix
# (awk, df, free, grep) para testar se Memória, Disco ou CPU
# do Cluster ultrapassaram o Threshold, batendo um e-mail local.
# ============================================================

set -euo pipefail

# =================
# THRESHOLDS DE AVISO (LIMITES)
# =================
MAX_CPU=85       # Em Porcentagem
MAX_MEM_RAM=90   # Em Porcentagem
MAX_DISK=80      # Em Porcentagem

# =================
# FUNÇÕES DE COLETA E AVALIAÇÃO (The Metrics Engine)
# =================

checar_disco() {
    # Usamos the `df` (Disk Free) em partição `/`.
    # O Tail tira a primeira linha (cabeçalhos). O awk puxa The 5th Colum q ta "46%".
    # O Sed corta o símbolo % pra liberar os num pra conta!
    local DISCO_USO=$(df -h / | tail -n 1 | awk '{ print $5 }' | sed 's/%//')
    
    if [[ "$DISCO_USO" -gt "$MAX_DISK" ]]; then
        echo "[ALERTA] -> O Disco Raiz atingiu uso Crítico de: ${DISCO_USO}% !"
    else
         echo "  [OK] Disco Seguro: ${DISCO_USO}%"
    fi
}

checar_ram() {
    # Comando `free -m`. O Awk calcula e printa só The Number Final pra nso (Matematica)!
    # Memoria usável / TOTAL  * 100.
    local USADA=$(free -m | grep Mem | awk '{print $3}')
    local TOTAL=$(free -m | grep Mem | awk '{print $2}')
    
    local CPU_PCT=$(( USADA * 100 / TOTAL ))
    
    if [[ "$CPU_PCT" -gt "$MAX_MEM_RAM" ]]; then
         echo "[ALERTA FATAL] -> A Ram subiu absurdamente pra: ${CPU_PCT}%"
    else
         echo "  [OK] Memória Segura e com folga: ${CPU_PCT}%"
    fi
}

checar_cpu_load() {
    # Usaremos the UPTime system average 1-minute load vs Num de Nucleos de verdade.
    local LOAD_AVG=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/ //g')
    local NUCLEOS=$(nproc)
    
    # Bash nao entende . / decimal virgula (Load avg da 0.40). O 'bc' ou 'awk' salvariam a pátria!
    # Mas pra este mock de bash faremos usando O Bc calculator pipe 
    # (( 0.40 > 2 nucleos ? ))
    
    local IS_CRITICAL=$(echo "$LOAD_AVG > $NUCLEOS" | bc -l)
    
    if [[ "$IS_CRITICAL" -eq 1 ]]; then
         echo "[ALERTA INCENDIO CPU] -> O Load System ($LOAD_AVG) Estourou brutalmente o numero fisico das suas cores de CPU ($NUCLEOS)!"
    else
         echo "  [OK] Processadores sob Load aceitável médio: ($LOAD_AVG avg para $NUCLEOS cores)."
    fi
}

echo "=== MÁQUINA DE RAIO-X SYSTEMA (SRE HEALTH) ==="
echo "Checando o Coração do Servidor as: $(date)"

# Disparando Avaliações...
checar_disco
checar_ram

# Como nós usamos o bc p float/decimal, ele apita que falta instalá-lo se não exisitir The linux pkg.
if command -v bc >/dev/null; then
    checar_cpu_load
else
    echo "  [AVISO] A CPU Não pode ser auferida nativamente... O binário 'bc' de Ponto Flutuante não está instalado neste OS."
fi

# ============================================================
# Esse Script se torna O OURO sendo agendado num Crontab de SystemD
# pra disparar A CADA 5 MINUTOS (`*/5 * * * *`). Integrando ele com O
# Telegram Bot API Token via 'curl' nas linhas de WARNING e vc viraria 
# The GOD DA FIREWATCH NUMA STARTUP! 
# (Ex: curl -s "https://api.telegram.org/botTOKEN/sendMessage" -d "text=DISCO_TRAVADO_AJUDA")
# ============================================================
