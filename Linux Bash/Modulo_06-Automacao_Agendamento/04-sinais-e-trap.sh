#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta O Guardião da Saída Elegante (TRAP).
# Como interceptar quebras fatais do script (Sinais C ou ERROS) 
# para limpar o lixo deixado para trás (tempfiles/bancos temp) 
# antes de deitar no túmulo final. O Graceful Shutdown!
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O seu Script tá construindo um Muro. A Prefeitura (Usuário, Ctrl+C / Error bash)
# grita: "Carga de trabalho abortada!!! Pare!!".
# Um script ruim morre na hora deixando tijolo sujo largado, os potes de tinta aberto 
# vazando no chão da rua.
# O `TRAP` é uma Cláusula Contratual: "Se alguém me mandar fechar na marra, eu prometo (intercepto o golpe final) não piscar pro túmulo sem antes varrer meus arquivos .tmp debaixo do meu pé!". Fechamento Gracioso de Cleanup.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# `trap` é o builtin de Kernel Signal Interception e Event Handling mechanism da bash.
# Permite o acoplamento Hook/Call em rotinas C para execução de comandos quando recebemos Hardware Interrupts (SIGINT), Software Terms (SIGTERM), ou o Bash Event pseudo-signal `EXIT` e `ERR`.
# Fundamental p/ File Lock Releases. O script cata seu próprio SIGKILLing action.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Trap Events: Limpando a Bagunça do Túmulo ==="

# Arquivo Temporário Falso
ARQUIVO_TEMPORARIO_LIXO="/tmp/lock_bd_produzindo_$$.tmp"
touch "$ARQUIVO_TEMPORARIO_LIXO"

# Função vassoura que queremos rodar SÓ NA HORA QUE ALGUÉM MATAR A GENTE ou na hora de encerrar feliz!
funcao_faxina_desligamento() {
    echo ""
    echo "[!] INTERCEPTAÇÃO FATAL ACIONADA: Ops... Fui mandado pra morte ou meu código finalizou."
    echo "    - Varrendo e removendo meus lixos travantes Ocultos de LockFiles..."
    rm -f "$ARQUIVO_TEMPORARIO_LIXO"
    echo "    - Desconectando pontes UDP seguras e morrendo empaz pro Systema. Goodbye Master."
}

# A MADRE DAS MAGIAS!
# O Comando `trap` aceita a "Funçao_Faxina" + a lista e Códigos Sinais q deve escutar.
# O Sinal EXIT = Evento Pseudo. Dispara SEMPRE, seja no erro fatal, seja no Ctrl+C , seja no Sucesso script end.
trap 'funcao_faxina_desligamento' EXIT

echo "1. Arquivo Trabalhador Lock Gerado: $ARQUIVO_TEMPORARIO_LIXO."
echo "2. Processando coisas vitais pro nosso sistema..."

# Nós dormiremos 5 segudos simulando processamento I/O!
# Se VC DEVOLVER NO TECLADO um CTRL+C Brutalmente com violencia emcima desse sleep, a Bash mata vc com rc 130!
# Porém, a mágica: O Nosso lixo será limpado antes do Bash droppar as C-threads. Tente!!!
sleep 5

echo "3. Terminei o script com sucesso (sem qbrar)! Como eu acionei EXIT no the end of file.. o Trap tmb varrerá!"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Rodar sem matar: `./script.sh` -> Vai imprimir 1,2, dormir, 3.. Aí aciona faxina e morre.
# - Roda Matando: `./script.sh` -> E quando ele dormir no 2 e travar tela ESPANQUE O "CTRL+C". Vc verá que ele não morre mudo. O TRAP pegou a morte dele no pulo! Acionou o Evento "Ops", Excluiu a RAM lixo, e liberou tela!
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu `TRAP` tá associado com o SINAL `SIGKILL` (-9). Eu digitei `trap limpando SIGKILL`. Mas se alguem na nuvem da o kill -9 no script... o TRAP não faz nada, deixou tudo lá sem varrer!!
#   O que é: A Grande e Eterna Blindagem Linux Kernel Root.
#   A solução: NENHUM SCRIPT E NEM NINGUEM NO PLANETA TERRA PODE INTERCEPTAR, PEGAR, OU REGERAR O SINAL DE MORTE 9 (SIGKILL ou SINAL KILL)! O Sinal 9 é um golpe do Processador Central/Kernel de fora pra dentro q arranca a RAM do programa na força física para caso ele seja um monstro malicioso intocável. Você NUNCA CONSEGUE botar traps em KILL (-9) . Coloque apenas em TERM (-15), INT (-2/Ctrl+C) ou no genérico EXIT pra capturar tudo de normal possivel.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe o Pseudo-Sinal `ERR` do BASH.
# Muitos de vcs perguntariam "Se eu ligar o `set -e`, quando um erro der falso status 1 na linha 8..o bash aborta imediatamente e desce a roleta do script né? E se eu quiser interceptar só PRA CAÇAR NUMERO DA LINHA do Erro?
# Sêniores usam Mágica de Debug usando a Trap e variáveis nativas do processador Bash:
# `trap 'echo "Erro Fatal Ocorreu no comando [ $BASH_COMMAND ] e abortou nosso sistema infelizmente lá na na LINHA [ ${LINENO} ]"' ERR`.
# Com isso em cabeçalho, a cada falha aleatória invisível estúpida que morre do nada em PROD e Ngm ve cmo... O Script vai Vomitar instantaneamente dizendo pra voce de bandeja: "Morri por causa do programa wget, na Linha 140!" O Tempo do sysAdmin debug se reduz de 9h pra 0!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado que uma rotina main principal de entrypoint tem a TRAP de Cleanup EXIT. Meu script na linha 4 executa uma function() minha, e dentro de function eu digitei `exit 0` no if... O exit da function, vai abortar tudo mas vai chamar o gatilho da TRAP PAI do arquivo?"
# Resposta Sênior: Sim. No Bash Functions NÃO isolam processamento signal scope de EXIT trap global handler. Como a função compartilha o subshell namespace id da mãe shell; invocar `exit` internemente força a finalizaçao inteira do master process (parent bash engine). A engine do bash identificando o aborto vai acionar universal e imediatamente os Traps C-Hooks de terminação independente de qual profundidade ou identação vc puxou a guilhotina do exit. Tudo corre limpo e a vassoura bate pra fora até limpar memória global local.
# ============================================================
