#!/bin/bash
# ==============================================================================
# Módulo 5: Escalação de Privilégios (Privesc)
# Aula 01 - Abuso SUID/SGID e GTFOBins
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você é um operador de telemarketing terceirizado da empresa (usuário normal) 
# e descobre que a máquina de café na sala dos diretores (um processo com SUID)
# foi configurada erradamente e não checa o crachá de quem pede o café... E o café
# é depositado dentro da sala blindada. E se, em vez de pedir café, você colocar no 
# painel dela: "Me passe as chaves do cofre de pagamentos, que eu coloco açucar extra"? 
# Como a máquina DE CAFÉ age como o Diretor (Root UID) perante o sistema, ela aceita, 
# entra na sala blindada invisível às regras, e joga a sua chave. O GTFOBins é o TINDER  
# dos Hackers: Uma lista inteira de quais "Máquinas de café" você pode explorar!
#
# 2. O QUE É (definição técnica Senior)
# Como estudamos na Módulo 1 Aula 2, o SUID executa na autoridade do Dono da file "Root".
# GTFOBins é um repositório curado no github incrivelmente foda de truques de bypass unix.
# Se um admin setar permissão SUID num `/usr/bin/find`, `/bin/tar`, ou até `.vim`,
# não há patch pra defender. O programa funciona *como desenhado*. Mas podemos
# abusar dos argumentos `-exec` para fazer o binario legitimo gerar as "Shell /bin/sh" 
# em cascata dentro da thread SUIDizada para nós.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defesa/Enumeração Rápida que você faz logo quando entra em uma shell morta:
echo "[+] Buscando Vetores SUID Mágicos no meu OS:"
# (A mesma da primeira aula de permissions, revisada:)
# find / -perm -u=s -type f 2>/dev/null 

# ========== O ABUSO DO `FIND` ==========
# Digamos que o comando find te retornou '/usr/bin/find' na lista com 's' vermelho.
# Ele roda pra ti as as Root. Só abra o site GTFOBins -> procure FIND -> clique em SUID.
# E use este comando maligno:

# find . -exec /bin/sh -p \; -quit
# O `-p` (privilegiado) pro SH diz pro novo Bash: "Se o seu papai invocador (o executável do Find) ti rodou com EUID de Root emprestado da capa mágica da flag S, NÂO DROPE ELA, ASSUMA QUE TU ÉS O ROOT PRA SEMPRE!"

echo "[+] Explorando o Vim (se ele fosse rodante SUIDizado na busca)..."
# Exemplo 2. Achei o comando vim. (Um editor de texto!)
# vim -c ':!/bin/sh'
# A flag -c roda comandos do editor "vi" e '!' evoca comandos do OS. O `/bin/sh` vai aparecer invocado com poder Root.
# O admin q deu chmod do vim em root só queria q ninguem precisasse ficar dando sudo pra abrir nginx.conf kkk... e perdeu o DB!

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: No metasploitable/CTF da vida, após quebrar pro usuário "test", vc dá o scan -perm -4000.
# Passo 2: O scan mostra `/usr/bin/nmap`. Bizarro. O Nmap tá com flag SUID pra galera escanear sS. Mas nmap antigo de época de 2012 na verdade era foda: O nmap tinho o flag `--interactive`.
# Passo 3: Então vc abre ele: `nmap --interactive`.
# Passo 4: Cai num console `nmap> `. E lá dentro, tem feature obscura nativa, o comando de shell bang `!`. Digita lá: `!sh`.
# Passo 5: Gool. A shell sai spawnada Root pura, o promt pisca `#`. CTF vencido em 3 minutos.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Por que as vezes o GTFObins manda vc colocar `/bin/bash -p 0` pra bypass e a shell morre na hora ou diz de permission maluca? Se for Debian Moderno, o deamon bash e dpkg forçou "Drop Privileges". O bash, do OS, internamente testa GetEUID. Se ele for diferente do GetUID real teu, o BASH DESISTE DA flag "S" do pai sozinho e cospe teu bash mendigo devolta!!! A Defesa de distro é muito genial. Por isso usamos `dash` nativo com o `-p` argument pra desarmar a defesa do dev do bash e re-honrar o SUID e forçar o Privilegiado.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior não se desesperar quando acha GTFObins vazios no host (`/usr/bin` limpo). A Auditoria Sênior procura pelas "Shared Objects libraries" (.so). O comando `ldd <binario>` exibe as bibliotecas de dependencia dinâmica. Se um SUID binario obscuro, inventado pelo dev na empresa em linguagem C na hora (nao catalogado no GTFObins) chamar uma .so e você olhar se vc TEM permssão de gravação `-w` no Path de onde essa `.so` será instanciada em runtime? Voce sobre-escreve ela, empurra uma `.so` malware de linguagem C que so atira shell no teu ip 4444... E roda o binário suid inventado inofensivo! Resultado, RCE em cascata Dinamica Root Hijack via RPATH/RUNPATH SUID.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Sua busca por Suids atirou vazio. Mas tu esbarrou em um comando nativo chamado `cpuloadd-monitor.sh` jogado na past `/opt`... Ele TEM a tag SUID de root nas perms '-rwsr-xr-x'. Você pensa: "Perfeito, vou achar uma vulnerabilidade no código bash de injecao de variável nele pra eu pegar root shell". O executável `cpuloadd-monitor.sh` que comeca com '#!/bin/bash', se vc o rodar no root dele e vc não ter perms nenuhum, qual sua chance de PrivEsc real e porque?"
# Resposta Esperada: SUA CHANCE É ZERO %. Como tocado de forma rapida na Aula 02 de permissões, o Kernel do Unix tem proteção anti-burros hardcoded: Módulos como execve() do linux Kernel Ignoram Completamente TODOS os bits de Flags SUID e SGID quando os Arquivos Alvo são meros "Scripts Interpretados via Shebang #!". O fato do `.sh` ter SUID visivel nas perms ali é falha de display do comando Chmod, q aceitou o input de string "u+s" mas na realidade do run-time ele não afeta binario interpretador dinâmico q carrega texto, pra evitar justamente a "Injeção Dinamica Trivial de Root Shells". Só executáveis Compilados em ELF C / C++ puros atrelam o bit para pular. O Host não tá exposto.
