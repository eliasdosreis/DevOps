#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Expõe os conceitos avançados de Exceção Mutex (Mutually Exclusive).
# Quando queremos que o nosso Script rode APENAS UMA VEZ na galáxia
# no memso instante, sem clonagens! Utilizando `flock` (File Lock).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# É o provador de roupa da loja! Há apenas 1 espelho e 1 porta.
# O Cronjob "Joao" chama o Script As 10H para atualizar Banco Dados.
# A porta da loja de Atualizar "tranca" e ninguém entra.
# As 10H02 o CronJob Injetor "Maria" chama o Script As 10:02 TMB!!.
# Mas ele bate de cara na maçaneta "FLOCK". A porta diz falha!
# Ele vai embora triste e o servidor não se corrompeu fazendo dois backups gigantes concorrentes sobre os arquivos um do outro (Race Condition / Corrupção).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# C Kernel `flock(2)` Apply or Remove An Advisory Lock na Descriptor Node Level.
# Utilitário POSIX `flock` wrapper cria mutexes amarrados a Inodes via Standard File Descriptors que liberam atomicamente seus File Handlers se seu parent process despontar The Ghost End. Traz serialização bruta a bash pipelines.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Blindagem de Scripts em File Lock ==="

LOCK_FILE_MASTER="/tmp/seguranca_banco_master.lock"

# Tentaremos abrir a Porta e criar o arquivo via comando Flock Externo (-x exclusivo, -n não espere na fila trave e de Erro já). E usaremos um FileDescritor Custom (ID 200). 
# Se alguém ja tiver pego a ID 200 na RAM nos ultimos minuto de outro PC... o if caíra pra ELSE Fatal!
exec 200>"$LOCK_FILE_MASTER"

echo "1. Tentando adquirir Maçaneta Segura na RAM (Exclusive Lock)..."
if ! flock -n 200; then
    echo "   [!] ERRO FATAL: O Sistema/Script Master já está Rodando Invisivelmente agorinha!"
    echo "   Processo clonado detectado. Abortando imediatamente a subida do script duplo p nao sujar disco."
    exit 1
fi

echo ""
echo "2. Lock Adquirido Exclusivamente!"
echo "   - O nosso Script é o verdadeiro Master em Execução na Thread. Mais ninguém entrará nas paredes limitadas."
echo "   - Iremos Executar Nossa Operação Pesada do Banco de 10 Horas Seguras dormindo!"

# Coloquei 2 segs aqui senao minha execução vai te travar eternamente kkk
# Mas tente colocar sleep 30 pra ver! E rode o script na Tab 1!
# Abra o Tab 2 do terminal rapdo enqnt Tab 1 dorme, e vc vai ver Lindo! A Tab2 dará "Já estou rodando, saindo!"
sleep 2

echo ""
echo "3. Operação Terminada. Tranca aberta do cofre, proximo cronjob do dia que vem tá liberado de entrar sem crashar."
# Embora n precise ser explicitado pq a bash libera file descriptors mortos na limpeza kill C. Faremos por elegância manual:
flock -u 200

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Ao invés de botar dento do Bash if como um fd=200.. podemos dar Wrap NO CRONTAB PAI (no cron.d global):
#   `*/5 * * * * root /usr/bin/flock -n /var/run/cron.lock bash script.sh` (O Próprio binário FLOCK vai abraçar e rodar o bash limitando ele sem voce sujar suas LINHAS do código Bash!).
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Se o PC queimar bateria desligando forçado sem dar "Cleanup / rm" ou soltar minha FD-Massa da maçaneta fd-200, eu vo fica travado pra sempre pq criei Lock Permanente?
#   O que é: MITO DE JUNIOR! Quando você cria File Locks primitivos de JUNIOR do tipo `touch /lockarquivo.txt;` se a maquina crashar, o txt ficou preso, e ninguem entra ano q vêm.
#   A solução de Flock Sênior: O `FLOCK` não se preocupa se o TXT de lock existe de fato nas pastas. Ele dá tranca NO DESCRITOR DE VÍNCULO de I/O em MEMÓRIA RAM Kernel (Node pointer). Se o SCRIPT for explodido por OOM, Ctrl C Morte (SIGKILL 9 Sem Trap) ou Poweroff Físico AWS Reboot! O KERNEL LINUX descarta 100% o Pointer fantasma do processo extinto da FD Table.. Destrancando a sala perfeitamente! FLOCK C-Nodes Kernel são a Magia Suprema Anti-Travamento de Restart O.s.!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O `flock -n` aborta, desliga e morre sse achar concorrência do vizinho de prompt. 
# Mas eu não quero q morra! Eu tenho um script Deployer Jenkins Sincrono q quero esperar minha vez na fila pacientemente pra ir!
# Sêniores usam a flag de timeout blocking: `flock -w 600 arquivo.lock myScript`. (W = Wait de 600 segundos/10min na porta).
# Quando o Processo Alpha da Tab/Aba anterior desligar e abrir o cadeado... O Bash do Processo Jenkins seu em TimeOut sentinela "sente" a macaneta pingar e invade em decimos a porta prosseguindo pipeline perfeitamente alinhado assíncronamente sem crash e skip sem quebras brutas. Mutexes Resilientes.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado NFS/SMB Mounted Shares Cluster Filesystems (Amazon EFS / NAS), qual o Custo e Limite de implementar Flock Advisory Locks de exclusão sobre as portas deles numa escala distribuida multi-node entre 4 Servidores Linux disputando o /efs/shared.lock ?"
# Resposta Sênior: Historicamente desastroso. O comando `flock()` e Syscall da Libc antiga mapeavam estritamente sobre VFS File Descriptor Limitados no Node Local C! Em clusters Linux Kernel versions pré 2.6 as syscalls de flock falhavam e todos Servos achavam que eram donos (Collision MultiNode Cluster). Soluções On-Premise exigiam fallbacks a `fcntl(2)` primitivos ou a `LockFiles Directory atomic mkdir trick` que usam FS Tree Meta limits atômicos pra isolar Locks distantes. Hodiernamente via NLM NetworkLockManager as modernizações de Mount do NFSv4+ e Linux3+ embutiram e traduzem flocks em Vórtices Locks de cluster funcionais mas o arquiteto DEVE auditar mount params e NFS versions antes de lançar isso, além da latência colossal atrelada de network handshake IPC. A regra? Lock de Flock é pra Local Host Pura O.S IPC. Multi-Cluster Node Locks é territoryo para redis distribuído, Consul KV ou Apache ZooKeeper Election Tokens e Etcd de Kubernetes e nunca lockfiles puras do bash."
# ============================================================
