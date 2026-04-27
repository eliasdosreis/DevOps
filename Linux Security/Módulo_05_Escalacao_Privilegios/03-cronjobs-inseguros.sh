#!/bin/bash
# ==============================================================================
# Módulo 5: Escalação de Privilégios (Privesc)
# Aula 03 - Cron Jobs Inseguros e Backup Scripts
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Cron Jobs são o "Despertador Automático" com tarefas atreladas. Todo dia às 3 da 
# madrugada, o Despertador acorda o Robô de Backup da Limpeza da prefeitura,
# dá a chave amarela Master (Root) na mão desse robô, e comanda ele: "Vá lá no galpão, 
# pegue e execute o arquivo de listagem de limpeza que o funcionario de gari 
# anotou pra ontem do Excel e volte com as caixas". Pensa bem: Se VOCÊ invadir e matar
# o gari à meia-noite, e re-escrever o bilhete de excel dele pra "Em vez de caixas sujas, 
# varra todas as notas de dolares da caixa forte americana e jogue na rua". E ai
# você simplesmente DEITA e ESPERA as 3 da manhã chegar... A prefeitura com a chave ROOT cega vai de 
# rodo pra a rua seguindo o SEU manual alterado offline!
#
# 2. O QUE É (definição técnica Senior)
# `Crontab` hospeda tarefas engatilhadas por Daemon Timer cron no Linux.
# Muitos SysAdmins criam scripts em Python ou Bash de backup/Cleanup como "Root" para
# mexer em logs do Var e Systemd. MAS, arquivam a porra da localização do Script em 
# Pastas cujo o teu usuário tem "Permissão rwx - Write!". Sendo assim nós interceptaremos o source code script do cara
# ou envenenaremos as dependências `imports` que ele usa em caminhos órfãos de python library.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

echo "[+] Vigiando o Sistema do CRON em Busca de Tarefas e Vazamentos Ocultos..."

# Lendo as tabelas do SISTEMA Globais (Onde Root cria td p OS)
cat /etc/crontab

# Lendo diretórios agendados granulares diários/semanais (.d configs).
ls -la /etc/cron.d /etc/cron.hourly /etc/cron.daily

# E A FERRAMENTA SÊNIOR PRA CAÇAR AGENDAMENTOS FANTASMAS E PROCESSOS DE CRON ESCONDIDO?
# (O pspy! Ele usa as chamadas ftrace do root ring em usuario comum pra snifar o deamon).
# Se voce desconfiar de um cron Job que NAO APARECE em '/etc' pq o root usou crontab -e oculto...
echo "Para sniffs dinamicos, na maquina hacker baixa o util do 'Pspy64' e joga no /tmp"
# wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
# chmod +x pspy64
# ./pspy64
# Ele vai printar LIVE na tua tela em C verde sempre q o root lá rodar algm lixo a kda 1 minuto de tick de clock automatico!

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: O `cat /etc/crontab` revela a linha doida: `* * * * * root /var/www/check_status.sh`. (Isso ocorre 1 minuto, a cada minuto).
# Passo 2: Mas espera, o script roda "como root", blz. MAs ONDE ele está? No "/var/www/". E lá é a casa livre gravável do "www-data", e seu usuário da shell q tu invadiu agorinha é justamente da web.
# Passo 3: Digite `ls -la /var/www/check_status.sh`. Pra dar risada de deboche do sysadmin júnior, o arquivo permite teu user Editar (w).
# Passo 4: Você apaga o códgio do script do cara que checa status web. E escreve o seu código bash no lugar pra ele mesmo: 
# `echo 'cp /bin/bash /tmp/bash && chmod +s /tmp/bash' > /var/www/check_status.sh` *(injetando SUID backdoor silenciosa)*
# Passo 5: Olha no punho e conta "1 Minuto"... Quando o ponteiro bater os segundos de tick de clock. `ls -la /tmp/bash`.
# Passo 6: O bash SUID novinho em folha vermelho de sangue foi dropado pra você la na TMP! Rode `./bash -p`. Exploit Master of Time!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Deu errado e ele n gerou? Confirme que: O serviço cron PODE estar morto com `systemctl status cron` se você invadiu em docker containers leves que n instalam o daemon timer. E segundo, em ataques de crontab baseando Wildcard Injection tipo comando de arquivamento  `tar *`, assegure que seu arquivo falso se chame as opções puras como `--checkpoint-action=exec=shell.sh`. O Tar do root é quem será hackeado no argv!
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior banir crontabs em diretórios de Users e abolir referências PATH Relativas dentro de Script Bash Corporativo em Linux do Cron. Se o arquivo Bash `/root/meuscript.sh` engatilhado no cron tiver listado assim dentro dele:  `cat backup.log`, E NÃO `cat /var/log/backup.log`. Um hacker manipula a variável "PATH" em ambiente do Root durante a puxada de env, criando um binário falso em `/tmp/cat` e atrelecendo a nova prioridade da bin library local! Ai o root crontab executa achndo q é o comando system e cai no malware que tá no primeiro escopo. Outra vertende mortal do cron é chown/chmod misconfiguracoes do TAR wildcard explication descritos acima em MLOps backups!
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu pspy detectou que no Ubuntu do Banco os deamons da Raiz disparam pthon3 `import sqlite; backup.py` a cda 1 hora de root como um serviço local. Vc n pode Editar o '.py' de backup. Mas cmo cacetadas vc vai RCE no Python?"
# Resposta Esperada: Python usa PIP e Library HIERARCHY Imports! A primeira Path dele q o Interpreter procura o arquivo pra montar em ram a lib 'sqlite' não é o core `/usr/lib/py`... É NO "CWD". (Current Working Directory) de onde ele foi lançado. Se o script está sendo rodado da minha tmp, a primeira coisa q ele vai fazer na vida é buscar a biblioteca falsa minha 'sqlite.py' na pasta de usuário. Basta eu dropar na pasta q o script atua o meu Python module com a funlção `def init()` atirando OS.system reverse shells. Isso chama-se "Library module Hijacking em DevSecops". E mata CIs automaticos em githook runners.
