#!/bin/bash
# ==============================================================================
# Módulo 6: Auditoria e Análise de Logs
# Aula 03 - Forense Básica (Acessos TTY, Históricos e Modified Timestamps)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# A poeira nunca mente. Você pode até arrombar uma porta usando luvas pra não dar print  
# a senha na maçaneta de log, mas na hora que você anda pelo chão do apê e tira foto
# dos quadros secretos, suas pegadas modificaram a estática da poeira natural (mtime / atime).
# E você não tem como tirar sujeira do chão sem criar mais sujeira em volta.
# O Histórico é como quem tira xerox num office, sempre fica o trace na memória da maquina de copia .bash_history! A Forense baseia em traços impossíveis de mascarar por leigos.
#
# 2. O QUE É (definição técnica Senior)
# Incident Response (IR) e Forense em sistemas ativos.
# Não podemos analisar disco morto via dd-image, precisamos ver indícios voláteis:
# - wtmp / btmp / lastlog: Bancos binários de registros TTY (Logins Interativos com e sem sucesso).
# - .bash_history: Cada user gera plain-text com TUDO q ele rodou por padrão.
# - Macb times (Modified, Accessed, Changed, Birth): Metadados de INODES arquivados em disco base ext4.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo: Vendo os Fantasmas e as Histórias dos Usuarios
echo "[+] Listando Logins Históricos de Sucessos via WTMP:"
# O comando last lê o /var/log/wtmp binario. A tag 'pts' indica um fake terminal aberto por remote SSH!
# A tag tty é uma tela fisica do VM. E o crash é quando foi bootado.
# last -n 10

echo "[+] Listando Logins FRACASSADOS brutos via BTMP (Bad Logs):"
# Requer sudo. Lê os bruteforces ou o IP de qm tentou.
# sudo lastb -n 10

echo "[+] A Caça às Pegadas Recentes: Oq Tocou nas últimas 24 Horas no Sistema Base Central?"
# O find tem os Mtimes -modificado, Atime -Acessado Lido (se o OS n estiver config mount nodiratime), e ctime -change permissoes).
# find /var/www -mtime -1 -type f
# O flag -1 diz Menor q 1 Dia atras (em dias).

# Visualizamos todas variaveis de tempo exatas de 1 arquivo suspeito PHP na pasta:
# stat /var/www/html/shell.php

echo "[+] Catamos os Históricos em Plain Text dos usuários bash vivos e mortos na /home"
# Buscamos por comandos como nc, wget, ou perl.. Hacker baixando exploit .
# cat /home/*/.bash_history 2>/dev/null | grep -iE 'wget|curl|nc|nmap|rm'
# No do root é /root/.bash_history.

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Vc recebeu um alerta q a conta "www-data" foi usada. 
# Passo 2: Mas contas www NÃO TEM shell ou histórico gerado bash pq não tem /home. Mas tem pastas temporárias.
# Passo 3: Vamos atrás do MTIME de quem criou coisas ocultas em tmp nas madrugadas. 
# Comando da salvação: `find /tmp /dev/shm /var/tmp -mtime -3 -type f`
# Passo 4: Retornou um `/dev/shm/.kthreadd_system_cache`. Um hacker injonou malware crypto mine e disfarçou o NOME DO ARQUIVO .Oculto pra fingir q era "thread de kernel kthreadd", e upou na mem RAM temp filesystem (shm) pra nao durar mt mtime em disco de ext4. O dev shm apaga a cada reboot limpando evidencia fisica.
# Passo 5: Ganhamos ele antes de bootar! stat ctime e hashes SHA256 do file pro SOC.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Em incidentes críticos, qnd vc roda `last`, e ele diz q o ultimo login foi ha 2 semanas, E VC TEM A CERTEZA que ocorreu logon ontem porque o cliente relatou deface web local... Você foi manipulado por um Toolset rootkit de Hacker Sênior. Utilitários obscuros Hackers editam os bytecodes Hexadecimais dentro do file morto WTMP substituindo o IP do attacker por "0.0.0.0" ou limpam a entrada do Record com bytes Nulos, tornando invisivel via comando "last". Mas o attacker amador esquece que Auth.log/journal existe tambem as vzs se os ids n baterem. Forense é triangulação!
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior não aceitar 'cat /root/.bash_history' pra forense sem checar environment. Quando eu (attacker) ganho RCE System shell local e abro vim ou bash interativo tty no socado. Eu lanço a primeira linha com espaço vazio! O bash ignora comandos que comecam com Espaço branco (' HISTCONTROL=ignorespace'). E segundo, eu digito `export HISTFILE=/dev/null` e logo dpois dou `unset HISTFILE`. Agora TODO COMANDO rodado ali PISA EM AGUA e nao se escreve p ram/disco .history file qd eu dslogar. Hackeamos a maquina de gravar fitas. A Unica chance q a galera defensiva de blue team com Sysdig tem é se eles tiverent capturando SYS_EXECVE (auditd dps) e interceptando syscalls, e nao arquivos bash texto q são editaveis!
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se tu tens um servidor comprometido... E de repente seu time acha um backdoor PHP. Ao rodar `stat shell.php` a data de Modificacao (Mtime) do maldito malware na raiz remonta bizarramente a " 12 de Abril do ano de 1999" enqto vc sabe que criaram isso hoje às 3PM! Que comando unix primitivo o ator usou pra mentir descaradamente f*dendo do Mtime pro TimeStomb e quebrar teus parsers de log temporal?"
# Resposta Esperada: O atancante rodou utilitario unix original "TOUCH" com flag de set timestamp absoluto!! Exemplo `touch -t 199904121000.00 shell.php` !! Essa string forca a metadata do disco no Inode no ext4 a reescrever fisicamnete q a arqv nasceu e mudou num time falso antigo pra passar despressebido em scripts anti-malware q procuram `find -mtime -1` na mesma varredura do Blue Team !
