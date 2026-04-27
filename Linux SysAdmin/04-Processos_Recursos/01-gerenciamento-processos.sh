#!/bin/bash
# ==============================================================================
# Aula 04.01: Processos e Recursos - Gerenciamento (ps, top, kill, nice)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# O Linux é um enorme restaurante com um único Cozinheiro super-rápido (A CPU).
# Cada pedido de cliente ("Me dê uma água", "Asse uma pizza") é um Processo.
# O Cozinheiro faz 1 segundo de trabalho no hamburguer, para, faz 1 segundo da pizza, e volta.
# 
# - O comando `top` funciona como o Relógio da Cozinha de cara pro chefe, mostrando quem 
#   ta pedindo e quem o cozinheiro tá atendendo agora no milissegundo em tempo real.
# - O `kill` é o segurança expulsando um cara (Processo) que travou o caixa com um cartão que não passa.
# - O `nice` (NICEness / Bondade) é você sendo gentil e dizendo pro cozinheiro:
#   "Olha, meu pedido de água, atrasa ele (Nice Alto), tem idoso (Processo VIP) na fila querendo comer logo!"

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Processos do Kernel são threads em alocação de tempo (Scheduler Round-Robin).
# Quando um programa Binário (Texto no HD) é startado, ele vira um PROCESSO (Entidade viva na RAM),
# e ganha um ID único universal chamado PID (Process ID). Tudo interage por meio de "HUP/TERM/KILL"
# Sinais POSIX (Signals) despachados pelo IPC do CPU via Syscalls (kill() function).
#
# A prioridade de quem a CPU vai rodar primeiro varia de -20 (Cruel Absoluto de Alto, pega tudo) 
# a +19 (Muito 'NICE' / Bonzinho, espera o ultimo da fila agir).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# PS: O Retrato Falado. (O `ps aux` tira uma 'foto' e não movimenta ela. Você leu).
ps aux                      # OBRIGATÓRIO: A=All(todos user), U=UserOriented, x=WithoutTerminal(Background).

# TOP e HTOP: O Monitoramento Ao Vivo
# O `top` vem em TODOS os Linux de fábrica desde os anos 90. É feio, cru, mas NUNCA falha.
top                         # OBRIGATÓRIO (Em provas LPI e servidores sem internet).
# O `htop` tem cores, barras vermelhas, setas de mouse. Precisamos Instalar ele ('apt install htop').
htop                        # OBRIGATÓRIO EM VIDA REAL (Muitos usam Btop ou Glances hoje).

# MATANDO UM PROCESSO (A arte da morte limpa vs Morte Sangrenta).
# Suponha que o PID da sua querrying travada seja 8550.
# O `kill 8550` (Puro) envia o Sinal SIGTERM (-15). Ele fala "Por favor, feche as conexões
# limpe o lixo e Desligue graciosamente as coisas pra mim".
kill 8550                   # OBRIGATÓRIO (JEITO CORRETO E SÊNIOR).

# Se o programa tá tão travado (Deadlocked RAM) que nem lê o "Por Favor"?
# Usamos o Famoso Kill -9 (SIGKILL). O Linux APAGA as posições da memória do cara à força
# sem perguntar e explode ele no void! Risco de corrupção se for DataBase!
kill -9 8550                # MODO SOBREVIVÊNCIA.

# NICENESS: Alterar Prioridade do Scheduler CPU
# Querem rodar um "Backup Gigante Zip" no meio do dia do Black Friday
# O `nice` roda ele gentil (15) pra CPU dar 0% de atenção pra ele se tiver Venda ocorrendo,
# Mas usar ele caso a Cozinha esteja vazia (idle).
nice -n 15 tar -czvf /backup.tar.gz /var/www  # OBRIGATÓRIO PRA CORRER PROCESSOS GORDOS NO EXPEDIENTE.

# E se ele JÁ ESTIVER rodando (você esqueceu de mandar o nice antes)? Você dá um RE-NICE!
renice -n 15 -p 8550        # Acalma (Bota no canto pra CPU dar atenção) a query que ta comento o DB vivo.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] killall -9 firefox
# [O QUE FAZ] Em vez de pescar PID a PID, o SysAdmin mata TODA Árvore de Processos
#             onde a String for "firefox". Você devasta 50 processos filhos num tiro.
# [SAÍDA ESPERADA] O programa some instantaneamente.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: Fui dar um "nice -n -20 script.sh" pra rodar um Script CRÍTICO DO DB de forma
#   Prioritariamente Furiosa (-20). O terminal respondeu:  `Permission denied`
#   Porquê?
#   Usuários Normais SÓ PODEM SER "BONZINHOS" (Valores positivos > 0). Um usuário bobo
#   nunca teria o poder de "Furar Fila do Processo SSH do Servidor" e falar "Me ouça 
#   antes do próprio Kernel!". Jogar o tráfego da CPU pra valores Negativos (Prioridade Insana)
#   é exclusividade Absoluta do UID 0 (Root via sudo).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# O Câncer do "Load Average".
# No comando `top`, a primeira linha diza algo como: `load average: 2.15, 1.80, 0.45`
# Média de Cargos (1 minuto atrás, 5 minutos atrás, 15 minutos atrás).
# O Pleno acha que aquilo "é a porcetagem de Uso do processador".
# O Sênior sabe que Load Average é "A FILA DE PROCESSOS TENTANDO ENTRAR NA COZINHA E QUE FORAM 
# BARRADOS".
# Se você tem `1 Core`, e seu load average é `1.00`, significa que o seu CPU ta SOANDO mas
# TODO MUNDO TÁ RODAANDO NORMAL SEM ESPERAR.
# Se seu load average for `4.00` em um Servidor `1 Core`: Voce tem 3 processos no Pátio (Em Wait State) 
# morrendo asfixiados porque o Cozinheiro só atende 1. VOCÊ PRECISA URGENTE ADD +3 CORES na Máquina Cloud!
# (Regra de Ouro: CPU Cores Visíveis pela metade = Limite Max. Se Load Average > Quantidade de Cores: ALERTA CRÍTICO).

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Pelo terminal 'top' você constata que um processo maligno está gastando 
# 100% de CPU. Você aplica o clássico `kill -9 5543`. Nada acontece. O State Status
# dele no htop está marcado com a letra 'D' macabra, e seu Load Average esta indo 
# a 1500 travando tudo. O que é isso e por que nem o Root 'Deus' conseguiu matar ele?"
#
# Resposta Esperada: "Processos em estado 'D' (Uninterruptible Sleep) estão bloqueados a nível 
# de Hardware (Física), frequentemente aguardando uma LUS de NFS (Rede) ou Disco que pifou/Caiu
# a rota para retornar um Byte e prosseguir sua thread final. A Signal -9 não surte efeito em Uninterruptible Sleepers, 
# pois Kernel signals são flags de processamento e a thread simplesmente não está em CPU Execution Time
# para ler a mensagem da morte! A única solução nesses raros casos (Zombie D) é restaurar 
# o link de Disco/Hardware original que o prende ou aplicar um Hard Reboot (Reciclagem Fria) no servidor inteiro."
