#!/bin/bash
# ==============================================================================
# Aula 00.03: Sistema de Arquivos (FHS) - O que tem dentro do Servidor?
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Imagine que o Windows tem o "C:" (onde fica o sistema) e "Arquivos de Programas". 
# No Linux, não existem letras de disco. Existe uma "Grande Árvore" chamada Raiz (Root)
# representada pelo símbolo /. O Linux organiza TUDO de forma lógica nessa árvore.
# É como um condomínio gigante (/), onde cada prumo de elevador ou apartamento tem
# uma funcionalidade específica (ex: A portaria = /dev, administração = /etc, 
# moradia dos inquilinos = /home, esgoto/lixo temporário = /tmp).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O FHS (Filesystem Hierarchy Standard) define a estrutura e o conteúdo dos 
# diretórios principais nas distribuições Unix and Linux. Ele garante que os
# arquivos de configuração estejam sempre isolados dos arquivos binários e dos 
# dados do usuário. Isso permite padronização. Tudo no Linux é um arquivo: 
# o mouse, o HD, a memória, até portas TCP/IP. E todos eles vivem pendurados no /.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# Abaixo, estamos listando o diretório principal para ver a árvore do seu servidor.
# O comando ls (list) exibe os arquivos do local.

# O parâmetro / manda listar a base do HD (a Raiz do sistema)
ls /                # OBRIGATÓRIO: A base da navegação Linux.

# O que significa o que você está vendo aí dentro:

# /bin   -> Onde ficam os comandos essenciais (como o próprio 'ls', 'cp').
# /boot  -> Arquivos para o sistema iniciar (o Kernel Linux em si fica aqui).
# /dev   -> Suas peças físicas (teclado, pendrive, HD de banco de dados).
# /etc   -> Arquivos de configuração de TODO O SERVIDOR (Nginx, SSH, sistema).
# /home  -> A pasta pessoal de cada usuário do sistema (como seus Documentos).
# /lib   -> Bibliotecas (as "DLLs" do Linux) que os programas do /bin usam.
# /opt   -> Onde instalamos programas opcionais, criados por empresas terceiras.
# /root  -> A pasta `/home` particular do Administrador principal (o usuário Root).
# /tmp   -> Lixo elétrico (arquivos temporários, exclui tudo quando o server desliga).
# /var   -> Arquivos que Variavelmente crescem (ex: Banco de Dados de clientes e Logs).

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# O Sênior sabe de cabeça que o /var lotado causa Kernel Panic no app.
# Como ver o tamanho / uso do disco da raiz? (Disk Free modo Human Readable -h)
df -h                  # SALVA-VIDAS: O "Gerenciador do Disco", mostra os gigas de cada pedaço de HD.

# Como pesar qual pasta está gigante e pesada? (Disk Usage)
du -sh /var/log        # SALVA-VIDAS: Traz o peso agregado (Sum -s) em Megas/Gigas de apenas 1 pasta e seu conteúdo.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] ls /
# [O QUE FAZ] Lista todos os apartamentos base do seu "condomínio Linux".
# [SAÍDA ESPERADA] bin  boot  dev  etc  home  lib  lib32  lib64  libx32 ...
# [O QUE FAZER SE DER ERRO] O / nunca falha. Se o Terminal disse "Permissão negada"
#                           para listar alguma subpasta como `ls /root`, significa
#                           que o Linux está te isolando por segurança.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# Se você está num terminal Ubuntu Server puro e digitou "LS /" (TUDO MAIÚSCULO),
# ele disse que "comando não foi encontrado". 
# 
# ERRO CLÁSSICO DE INICIANTES: Case-Sensitivity!
# O Linux diferencia completamente letras maiúsculas de minúsculas. 
# `Arquivo.txt`, `arquivo.txt` e `ARQUIVO.TXT` são 3 arquivos totalmente diferentes.
# Assim como `ls` é válido e `Ls` é inválido. A regra de ouro é:
# No Linux, praticamente todo comando nativo é em letras minúsculas.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# A separação de pastas no FHS não é só pra ficar bonito, mas por Motivos de
# Particionamento Físico e Segurança. Um Sênior que implanta um banco de dados gigante,
# não o coloca "na partição do sistema operacional". 
# Ele formata um HD novo, rápido (SSD NVMe), e "monta" (conecta artificialmente) na 
# pasta `/var/lib/mysql`. 
# O por quê? Se o banco de dados encher o disco 100%, o sistema não trava! O sistema 
# operacional, que está no disco C:, na verdade está no HD base raiz `/`. O banco 
# trava só a fatia dele no `/var` ou `/opt`.
# Em Windows, se os logs enchem a partição `C:`, a OS inteira tem um Kernel Panic e freia.
# No Linux, o SysAdmin corta o disco em pastas separadas. O LVM e mount points são nossos amigos.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Precisamos mudar a porta padrão do Servidor Web Nginx de 80 para 8080.
# Em qual diretório da hierarquia FHS você esperaria encontrar essas configurações 
# e por que você não alteraria o arquivo binário dele em /usr/bin/?"
#
# Resposta Esperada: "A alteração deve ser feita no diretório `/etc` (especificamente 
# algo como `/etc/nginx/nginx.conf`). A recomendação do FHS é que o `/etc` agregue dados
# de reconfiguração de todo o Host, sem que precisemos regravar os binários que estão 
# em `/usr/bin` (que deve se manter inalterado por distribuições para que upgrades
# do package manager funcionem corretamente)."
