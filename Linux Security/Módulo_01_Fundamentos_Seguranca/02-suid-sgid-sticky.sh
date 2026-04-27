#!/bin/bash
# ==============================================================================
# Módulo 1: Fundamentos de Segurança Linux
# Aula 02 - SUID, SGID e Sticky Bit
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você trabalha num caixa eletrônico de banco (sistema). Como usuário padrão, 
# você não pode abrir as gavetas de dinheiro sozinhol (sem permissão). 
# Mas existe um botão mágico (um botão "SUID" embutido no sistema).
# Se você segurar o botão mágico e pedir por dinheiro, o sistema temporariamente
# lhe concede a "autoridade" do Gerente do Banco (Superusuário) EXATAMENTE
# DURANTE aquele único procedimento no programa. Quando a rotina de caixa acabe, 
# você perde os poderes de gerente imediatamente. 
#
# 2. O QUE É (definição técnica Senior)
# O SUID (Set User ID) é um bit de permissão especial (octal 4000) definido 
# num binário/executável que orienta o Kernel do Linux a rodar aquele processo 
# utilizando o privilégio do USUÁRIO DONO do arquivo, e não de quem invocou o 
# comando. Se o dono é p Root, é root pra quem rodar.
# SGID (octal 2000) roda com os privilégios do grupo do arquivo em nível de
# pastas. O Sticky Bit (octal 1000) em pastas como /tmp garante que apenas o 
# Dono Criador (ou Root) possa apagar seu próprio arquivo, mesmo a pasta 
# sendo liberada pra todo mundo.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Criação de um ambiente de simulação temporário seguro
mkdir -p /tmp/aula_suid
cd /tmp/aula_suid

# Copiando um binário inofensivo que não tem poder, como o '/bin/bash' ou utilitário
cp /usr/bin/id /tmp/aula_suid/my_id

# Ao rodar isso sem root, seu output de UID mostrara quem VOCE é hoje (ex: elias).
./my_id

# (Ofensivo/Defensivo) Configurando o SUID Bit
# 'u+s' ativa o bit SUID magicamente nesse executável. 
# Repare na letra 's' ao invés de 'x' no dono ao dar 'ls -l'.
# (Para isto funcionar e mudar o dono pra root, precisaremos invocar os binários com SUDO temporário)
# sudo chown root:root /tmp/aula_suid/my_id
# sudo chmod u+s /tmp/aula_suid/my_id

# Se você invocar ./my_id (SIDO AGORA DE ROOT E COM SUID), 
# O seu EUID (Effective User ID) vai saltar para Root (0)! 
# Este é o princípio matemático e arquitetural dos exploits locais clássicos (PrivEsc)
# que abusam de misconfigs em aplicativos.

# Listagem defensiva para Auditoria Pentest
# "Quais binários no meu servidor possuem esse botão de "Sou o Gerente" mágico envenenado?"
# -> -perm -4000 (qualquer um com SUID) 2>/dev/null (descarta erros de Pastas Lidas Restritas)
echo "[!] Buscando Binários com SUID no Servidor..."
find / -path "/proc" -prune -o -type f -perm -04000 -ls 2>/dev/null | head -n 10

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Olhe as permissões do comando de trocar senhas: `ls -la /usr/bin/passwd`
# Passo 2: Perceba a saída como `-rwsr-xr-x`. Aquele 's' em vermelho é o SUID. O dono é 'root'.
# Passo 3: Pense nisto: Como o seu mero usuário de nome 'joao' consegue escrever o hash sensível da senha nova dele no `/etc/shadow` (que apenas o root escreve)? A mágica do executável /usr/bin/passwd possuir SUID é o responsável autorizado pelo kernel que eleva seus privilégios no ato silencioso. E por possuir isso, é muito cobiçado como vetor.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# A vulnerabilidade só existe se você der "s" a um binário perigoso. 
# Ex: Se um admin júnior der SUID no `/usr/bin/tar`, o hacker comum pode invocar o 
# `tar` compactando os segredos p/ si, com poderes de Root.
# O `chmod -s binario` remove o perigo para reverter.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# No background low-level, a syscall `execve` identifica as tags permissivas S/UID, 
# e substitui o Effective User ID (EUID) do processo. Se um atacante encontrar
# o binário mal configurado com SUID de dono root, ele invoca esse binário com
# exploits conhecidos via repositórios como **GTFOBins**, conseguindo forçar o 
# binário a cuspir um Shell (`/bin/sh -p`). 
# E quanto ao *Sticky Bit*? Nas equipes de MLOps ou Bancos de Dados, usam muito a 
# pata compartilhada `/var/lib/dados` -> se tiver `chmod +t /var/lib/dados`, previne que 
# CientistaDeDados-A delete acidentalmente o parquet do CientistaDeDados-B dentro de 
# um mesmo NFS de grupo. Sem isso, seria desastre corporativo.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se eu tiver um Bash script customizado (ex: backup.sh) e eu der Chmod SUID (chmod u+s backup.sh) ele elevará meu privilégio para o dono root do script quando eu executá-lo no Ubuntu?"
# Resposta Esperada: NÃO. A maioria dos kernels modernos baseados em Linux (por pura segurança implementada desde os anos 2000) ignora de forma hardcoded a existência do bit SUID em **scripts interpretados** (`#!` shebang). O SUID só vai funcionar e surtir efeito de PrivEsc se acoplado de verdadeções arquivos **BINÁRIOS compilados em linguagem C**, etc. Scripts de shell igniram essa flag inteiramente. Para bypassar a regra de proteção, seria necessário empacotar o SH num envoker de linguagem C pré-compilada.
