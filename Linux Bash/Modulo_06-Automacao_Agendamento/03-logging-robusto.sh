#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Prototipa um sistema de log corporativo pra Shell, com níveis
# visuais (INFO, WARN, ERROR), timestamp absoluto C-Compliant,
# cores pra terminal TTY e encaminhamento unificado para disco.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você comprou uma Go-Pro e colou no capacete do trabalhador.
# Quando ele escorrega e derruba carga, o chefe pega a camera sabendo:
# - Que Horas exatas ele trombou? Qual Setor estava? A pancada foi Fatal ou só um Aviso?
# Scripts Bash sem Log Robustos são trabalhadores vendados numa caverna silenciada. Se engasgar, chora.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Logging mechanism customizado padronizando saída e canais multiplex com timestamps (Format ISO 8601 UTC ou T-Local).
# Implementação recorre a Syslog patterns (`FACILITY.LEVELS` base syslog levels 0-Emerg a 7-Debug) 
# empacotados em `printf` de escopo de função, utilizando redirecionamento fd1 / fd2 e codes ANSI Escape Color Codes pra interface humana.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Mestre dos Logs ==="

# Definindo constantes ANSI Colors text modes para a TTY tela
COR_ERROR='\033[0;31m'  # Vermelho Red
COR_WARN='\033[0;33m'   # Amarelo Yellow
COR_INFO='\033[0;34m'     # Blue
COR_NC='\033[0m'        # No Color (Reseta a configuração da tela)

# Nosso arquivo mestre central - Se der permissão denied ponha na /tmp no aprendizado.
ARQUIVO_GLOBAL_LOG="/tmp/app_production_10.log"

log_engine() {
    local NIVEL="$1"
    local MSG="$2"
    
    # Gerar a Data Formantando pra ISO (ex: 2026-03-29 14:02)
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Decidir a COR para ecoar na cara do ususario, a depender da palavra $1
    local COR_ATIVA="$COR_NC"
    
    if [[ "$NIVEL" == "ERROR" ]]; then
       COR_ATIVA="$COR_ERROR"
    elif [[ "$NIVEL" == "WARN" ]]; then
       COR_ATIVA="$COR_WARN"
    elif [[ "$NIVEL" == "INFO" ]]; then
       COR_ATIVA="$COR_INFO"
    fi

    # Monta a String Final formatada com o Level engruvinhado [] 
    local LOG_TEXTO="[$TIMESTAMP] [$NIVEL] - $MSG"
    
    # 1. Manda a Cor e Msg pro Terminal/Dono do Bash (Stdout visual fd1)
    # A flag -e é essencial pro bash não imprimir a string '\033' e sim entender cmo cor!
    echo -e "${COR_ATIVA}${LOG_TEXTO}${COR_NC}"
    
    # 2. Manda pro Arquivo TXT o texto PURO (sem variavel de cor invisível maldita que zoa os regex e suja vim)
    # E apendamos (Salvar Sem destruir o log anterior).
    echo "$LOG_TEXTO" >> "$ARQUIVO_GLOBAL_LOG"
}

# UTILIZANDO!
log_engine "INFO" "Sincronia de DB S3 Aberta com sucesso!"
sleep 1
log_engine "WARN" "Uso excessivo da CPU: Threshold 80%."
log_engine "ERROR" "Conexão perdida com node principal AWS (Socket Timeout). Abortando rotina."

echo ""
echo "Veja o que o arquivo de txt de backoffice gravou escondido (Sem tinta colorida):"
cat "$ARQUIVO_GLOBAL_LOG"

rm "$ARQUIVO_GLOBAL_LOG"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O comando `date` suporta formatadores do Sistema Operacional C Posix.
#   %Y=2026, %m=03, %d=01 etc.
# - Cores no bash sao os "Escape Codes". Apenas decolore \033[0m no fim, senão a tela inteira do seu usuário continuará vermelha pra sempre até ele deslogar!
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao abrir meu Arquivo Txt de log no VIM / NANO / LESS / CAT... vejo textos malucos e lixo como:
#   `^[[0;31m [ERROR] Pane no sistema ^[[0m`
#   O que é: O Desenvolvedor Júnior canalizou o TTY Escape Color com a string de cor (pipe Tee ou `>>`) DENTRO da Escrita pro Disco Fisico / TXT! Editores texteis enlouquecem as lendo bytes ANSI Raw de cores. A tela processa cores, o notepad.exe vê um lixo Unicode ASCII.
#   Solução Sênior: Nossa função em cima fez EXATAMENTE DE FORMA PERFEITA E PROFI: O Echo "LIXOSO E CHEIO DE COR" foi ejetado pra TELA apenas, E o comando puro de disco `echo texto >> log` mandou string virgem sem cor. Mantenham o txt puro!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe arquivo /var/log/syslog ou /var/log/messages. Posso logar algo neles dos meus scripts?
# Sim! E é o método padrão de Sistemas Resilientes usando facilidade LOGGING central. Invés de escrever em `meu_arq.log`, Vc manda o log direto pro "Daemon Global Syslogd Centalizado": Usando o comando binário `logger`.
# Exemplo brabo: `logger -p user.err -t MeuApp_FinX "DB falhou pra iniciar socket "`. 
# O "sysadmin system" absorverá ciente cmo Erro real (user facility nivel error (-p)). Ele cairá no journalctl, no rsyslog e num pipeline central cloud Splunk / Datadog de empresa que espreguiça da pasta /var !
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado um pipeline Shell escrevendo intensamente pra um Mount Network Storage (NFS Logger). O que acontece de risco estrutural e bloqueativo se o HD estiver em latência, dado o design do bash Redirection `>>` blocking I/O stream pattern?"
# Resposta Sênior: Em Bash Scripting os File Descriptors I/O (Incluindo redirect `>>`) seguem modelo Síncrono Bloqueante do Kernel em Thread principal. Se o HD Remoto engasgar pra responder 500ms, a Linha do `echo log >> network.file` irá paralisar integralmente a Execução (Halting execution da C stack e do processo parent shell) até q o Syscall Write retorne Acknowledgement (Sync)! A melhor solução de escape pra Mega-IO é offload via filas com subshells background ou Logstash/Daemon async.
# ============================================================
