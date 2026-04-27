#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Demonstra as mecânicas Sênior de Job Control do UNIX (Processos em Background,
# Jobs amarrados a Shell, Traps silenciosos, PID Hunting e kill 
# assíncrono). O controle absoluto da vida e morte dos Programas.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# A Fábrica LINUX (Process Management):
# - PID (Process ID): É a matrícula única do empregado Linux. Todo programa tem seu RG temporário.
# - Roda no Background (E-comerce): O funcionário trabalhando de portas fechadas no porão `comando &`. O dono da fábrica pode despachar pacotes pra outros enqunto ele rala.
# - Roda no Foreground (Loja): O funcionário fechou o salão enquanto atende. Ninguém mais anda até ele finir o atendimento.
# - Nohup: Assinar o contrato que o "Funcionario do Porão NUNCA será demitido mesmo se eu gerente Linux ir embora fechar as portas da fábrica!". (Imunidade a hang-ups ssh).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Instância contextual em RAM e Register de instruções atrelada a User/Group via descritor PID da árvore Kernel Process Parent `init (pid 1)` e subseguinte.
# Background Dispatch com ampersand (`&`) separa StdOut do TTY anexando numa Sub-session controlada pela lista de Jobs do Shell.
# A ferramenta `kill` não é um "matador", mas um "Signal Dispatcher" IPC capaz de mandar mais de 60 instruções entre threads, e não só o SIGKILL e SIGTERM letais.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== A Vida Oculta Subprocessual ==="

echo "1. Despachando um Script pesado pro limbo Background (&) assíncrono"

# Emulando um sleep demorado... Se ele rodasse normal "sleep 3" sem o &:
# O Bash Shell atual travava ("Blocking do Frontend") por 3 segs e todos choravam.
# Mas com o & mágico final...
sleep 5 &
PID_DO_SLEEP=$! # A variável '$!' captura a matrícula (PID) do ultimo comando que jogamos no background!!
echo "   - Criança Subshell criada com sucesso. RG/PID do Dorminhoco Invisível: $PID_DO_SLEEP"

echo ""
echo "2. Rastrando como um predador o PID rodando ativamente!"
# Faremos um 'pidof' do sleep limitando ao nosso ID guardado. 
# Ou se for um Nginx no caso do sistema: `pidof nginx`!
if kill -0 "$PID_DO_SLEEP" 2>/dev/null; then
   echo "   - O radar de PID (-0 ping mode) confirmou que o ID $PID_DO_SLEEP de dormir tá vivo e respirando."
fi

# O Sênior não aceita a tarefa demorar. Iremos Ejetar ele! Matador 'Kill'.
# -15 (SIGTERM - Pede por favor), e o Maledito -9 (SIGKILL - Fuzilamento CPU imediato).
kill -15 "$PID_DO_SLEEP"
echo "   - Um Míssil Term (-15) foi enviado via Kernel. O processo foi ordenado a cometer suicidio."

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Ver sua lista de trabalhadores no porão TTY amarrados da sua janela: `jobs`
# - Puxar um deles q tá perdido no porão d Volta pra Tela e travar a tela (Foreground): `fg 1` (Puxa do job id 1 pro fore).
# - Congelar um comando ao vivo brutalmente: Aperte `CTRL+Z` no meio dum wget e o Linux congela a RAM no estado parado em standby. Jogue p seguir no porao com `bg 1`.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao fechar o Terminal SSH remoto (PuttY), todos meus programas `bash script.sh &` que coloquei no bg Morreram! Parou tudo no servidor! O que eh isso?
#   O que é: O Daemon da internet ssh manda um apito gigante pros "Fillhotes (Bash e Todos os & do Bash do TTY dele)" chamado SIGHUP (Signal Hang Up Modem!). Esse apito Mata em cascata os filhos!
#   Solução Sênior Gloriosa: O `nohup`. Rode `nohup bash script.sh &` ou em bash moderno usando builtin disowning: `bash script.sh & disown`.
#   O Nosso lindo disown/nohup CORTA o cordão umbelical da morte! Arranca o subscript da árvore de Jobs e passa o "Padrasto" dos sub-processos pra ser o Init Principal Root isolado! Pode fechar terminal, a vida segue 100% livre.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um tipo de zumbi devorador de memória nos clusters Linux: O Processo "Z" (Defunct).
# O que diabos é o Defunct Zombie? Sêniores usam `top` e assustam "1 Zombie". 
# Zumbi acontece quando um processo Filho M-O-R-R-E e termina de ler!  
# "Ué, Elias.. se ele acabou a vida, pq consome numero na ram e trava?"
# Porque em programacao C/Linux, o PID "MORTO" se converte Zombie na Tabela de PID de proposito para segurar o "Status Exit Code (RC)" na mão até o Pai vir reclamar de volta lendo C (waitpid). Se o Processo Pai for mal programado (E o Dev burrao Node/Java nao consumiu a resposta do wait do kernel)... o zumbi ficará erguendo o cartaz infinitamente segurando lugar e derrubando recursos O.S, matando kubernetes clusters de inanição de file descriptors limite de PIDs PID_MAX_LIMITS sem CPU use e você chora! (E pior: o kill -9 nele não entra! Zombie não sofre balas). A unica saida eh matar o PAI Dele, engalfinhando o init 1 q passará um Reaper p ceifar os file limits e limpando. 
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado a necessidade de rodar 100 comandos `.sh` assíncronos em 100 maquinas/IPs. Pq não posso simplesmente injetar 1000 requests `command &` num `for-loop` burro no Jenkins de uma só vez?"
# Resposta Sênior: "Thrashing Kernel and Resource Starvation". Colocar forks infinitos em loop (Fork Bomb involuntário) disparará a criação desenfreada de C-threads Context Switch destrutivas no processor do Jenkins e exaustão de descritores sem fila estagiária. O Kernel agendador perderá controle no Swap Memory Page Fault.
# Metodologia certa de senior System Admin (Especialista em GNU Parallel!):
# Substituimos For + ampersand pel GNU Parallel Control programado: `parallel -j 10 mycommand {} ::: ips_list` onde estipulamos com segurança limites finitos do Worker Threads e process scheduling C.
# ============================================================
