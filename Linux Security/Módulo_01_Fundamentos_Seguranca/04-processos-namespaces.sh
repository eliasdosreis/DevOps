#!/bin/bash
# ==============================================================================
# Módulo 1: Fundamentos de Segurança Linux
# Aula 04 - Processos, Sinais e Namespaces (O Coração do SO e Docker)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# A CPU é uma pista de obstáculos rotativa. O Processo é um atleta correndo nela.
# Muitos atletas correm juntos de forma ultra simétrica para a ilusão do 
# multitasking. "Sinais" são os cartões (amarelo ou vermelho, SIGTERM, SIGKILL)
# que o juiz do campo joga para o atleta ordenando ele "Descanse (Stop)" ou 
# "Seje banido pra sempre (Morra)". E os "Namespaces" são os muros invisíveis:
# Se colocamos divisórias espelhadas, dois atletas podem jurar de pé junto 
# que eles são o Número 1 sozinhos na pista sem ver os outros vizinhos reais.
#
# 2. O QUE É (definição técnica Senior)
# Cgroup (Controle de recursos CPU/RAM por processo) combinado com Namespaces
# (MNT, IPC, PID, UTS, NET, USER) formam as primitivas do Kernel Linux de onde 
# os Containers (Docker/Kubernetes) emergem. O Docker não é uma mágica de VMware;
# é apenas um "filtro ilusório de namespaces" limitando o campo de visão dos processos
# executantes. Sinais (Signals do POSIX - tipo `kill -9`) comunicam interrupções 
# assícronas aos Processos via interface binária de OS.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Entendendo o processo "pai de todos" - PID 1
# O Init System (systemd moderno de todos OS). Tudo deriva em cascata, ele respawna filhotes.
ps -p 1 -o pid,comm,user

# Verificando as hierarquias em Árvore
# -u filtra arvore especificando a "floresta" do teu usuário.
# Isto é ótimo para caçar Backdoors de Bash e conexões estranhas amarradas em Python filhas do CRON.
pstree -p $USER

# Ofensivo / Defensivo: Como enviar sinais corretos e limpos de processos travados
# Sem precisar de Root Local (se o processo for seu):
# 1) Inicie um sleep (hibernação contínua de 5000 segundos rodando no background &)
sleep 5000 &
meu_pid=$!

echo "[+] Criei um dorminhoco com PID $meu_pid."

# 2) SIGTERM (15): O comando polite (Educado). Pede para o processo fechar conexões, 
# salvar os dados e então sair. O próprio processo pode ignorar/mask esse alerta, como malwares avançados.
kill -15 $meu_pid

# 3) SIGKILL (9): A Bala de escopeta violenta. O sistema Operacional não entrega 
# a carta na mão do Processo pra fechar. O Kernel destroi as páginas de memoria
# alocadas instantaneamente deixando lixo no FS as vezes.
# kill -9 $meu_pid

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Visualize o poder do Namespace no Docker dando vida a um Container.
# No seu server c docker, roda `docker run -d nginx`. 
# Passo 2: O docker criará o container. Você loga no container (exec) e digita `ps aux`.
# Perceberá que o deamon web do nginx DENTRO DO container clama que ele é o PID = 1 Mestre do mundo.
# Passo 3: Então, no Linux HOST (Virtual machine real mestre), digite `ps aux | grep nginx`.
# Você vai ver que fora do matrix do container, o processo nginx continua rodando...
# mas com  um PID gigante número 87342 ! 
# Isso ocorre porque os containers mentem pro PID dos apps pela montagem namespace isolada.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando Sysadmins tentam matar conexões e servidores presas com `kill -9` e elas revivem magicamente (Zombie Process)
# geralmente ocorre porque o Processo Pai (`PPID`) interceptou e está revivendo 
# as threads de pool (como o apache faz pra aguentar picos de web clients via KeepAlive). A solução? Atacar a mãe (processo pai primário via kill -15).
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O isolamento "Namespaces USER" é o buraco negro pra falésias de Cibersegurança em DevSecOps.
# Se um desenvolvedor preguiçoso executa docker run passando a flag "--privileged" (Desliga tudo), 
# os namespaces caem e o cgroup do guest monta a árvore `/dev` física real de seu Linux. 
# Nessa hora, mesmo que você seja Root lá num continer fechado Alpine inocente, caso ganhe via 
# RCE exploração, você consegue acessar partições RAW com drivers de `/dev/sda` host do Azure VM
# e sair de dentro do container virtual injetando seu path no host principal!! (Container Escape clássico).
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu processo crítico corporativo entrou em Loop Infitino (consuming 99% CPU) e ignora a interrupção SIGTERM/SIGINT (Ctrl+C). Mas você não pode usar SIGKILL nele porque senão a perca de estados de cache e bancos SQLite vai corromper os dados irrecuperavelmente de quem tá gerando o relatório. Existe alguma magia extra pra tentar inspecionar o travamento processual sem apaga-lo do PID pool?"
# Resposta Esperada: Sim. Um Processo pode receber Signal de "Suspender/Parar Temporáriamente" via SINAL SIGSTOP (`kill -19` ou Ctrl+Z). Isso congela seu processamento (Time Slice de Scheduling param), aliviando o uso da CPU para 0%, e fica parado na memória RAM dormente esperando pra retornar via SIGCONT. Dessa forma estipulamos alívios sem destruir dados, ganha tempo pro time do de infra agir e debugar.
