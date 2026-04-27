#!/bin/bash
# ==============================================================================
# Aula 09.01: PROJETO FINAL - A Infraestrutura Real (WebStack LEMP)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Chegamos no Grande Desafio. Você juntará Tudo (Aulas 1 a 8) pra botar um
# Sistema Corporativo (A Pilha LEMP: Linux, Engine-X (Nginx), MySQL e PHP).
# 
# Pense Numa Loja:
# Linux: O Chão e as Paredes Físicas Do Prédio.
# Nginx: O Balcão De Atendimento Ágil Da Frente (O FrontEnd TCP 80).
# PHP: O Cozinheiro (A Lógica De Processamento Ram Dinamica Da Comida).
# MySQL: O Estoque Onde A Comida (Os Dados Base) Está Escondida Longe De Clientes!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O Setup de LAMP e LEMP. No mundo Moderno o "Apache 2.4 Mpm" perdeu muito 
# MarketShare Pro Nginx (C Engine Asincrôno Orientado A Eventos Sem Pthreads Bloqueantes Epoll).
# Subir uma máquina Dessa Consiste em Download de Pacotes Debian APT, Linkagem dos
# Sockets Fast-CGI Unix IPC entre O Ngnix e O Daemon PHP-FPM Backend, E Isolamento Cego Firewall Oculto Database.

# ------------------------------------------------------------------------------
# 3. SCRIPT DE DEPLOY COMPLETO COMENTADO MÃO NA MASSA
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). 

# 1. ATUALIZAR A ARVORE CACHE DA EMPRESA E INSTALAR TUDO DE UMA VEZ!
apt update
apt install nginx mariadb-server php-fpm php-mysql ufw fail2ban -y

# 2. FECHANDO AS PORTAS C/ UFW (Segurança Nível 1 Sênior)
ufw allow 'Nginx Full'    # O Ubuntu Facilita: Ele Abre As Portas 80 e 443 num Comando Limpo Ufw Application Profile.
ufw allow ssh             # NUNCA ESQUECA ESSA LINHA, CENA DA AULA 5 E 8!!.
ufw enable                # Muros Levantados Na Hora "Yes".

# 3. O HARDENING DO BANCO CEGO MILITAR INICIAL MYSQL!
# O MySQL Instala De Fabrica Com 'Root' Sem Senha Vazio!! Vc Não Deixa Isso Na Cloud! O Comando Automatico Dele Blindar FHS:
mysql_secure_installation 
# (Vai Te perguntar no Terminal Interativo "Test Database Delete?" Pressione Y! "Disallow Root Remote Network Access?" Pressione Y! A Empresa Tá Segura Local Base Sockets!).

# 4. A ARQUITETURA DE LINUX DEUS MÁGICA: O VIRTUALHOST DO NGINX (As Pontes Lógicas):
# Criamos Um Espaço Na Raiz Pra Deixar Os Arquivos do Site:
mkdir -p /var/www/meusite.com
chown -R $USER:$USER /var/www/meusite.com   # "AULA 2 Permissões Chown": Mudo De Root Pra Mim e Dou Paz Cega Pra Trabalhar!

# O Sênior Agora Edita O Roteador L7 Mágico do Nginx Em: `/etc/nginx/sites-available/meusite.com`
# server {
#    listen 80;
#    server_name meusite.com www.meusite.com;
#    root /var/www/meusite.com;
#    index index.php index.html;
#    # A Mágica Do IPC (Comunicação Intra-Processos Sockets Mágico PHP): 
#    location ~ \.php$ {
#        include snippets/fastcgi-php.conf;
#        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
#    }
# }

# 5. TESTAR A SINTAXE DO ARQUIVO ANTES DE RELOAD (Evitar Kernel Panics Aulas 4 Daemon)!
nginx -t                      # [SAÍDA SÊNIORIDADE ESPERADA]: nginx: syntax is ok / test is successful!

# 6. REINICIO SUAVE SEM MATAR AS COMPRAS CEGAS AO VIVO!
systemctl reload nginx        # Aula 4 O RELOAD (Sighup Suave Live). Magicamente Vivo!!

# ------------------------------------------------------------------------------
# 4. VALIDAÇÃO MAGNIFICA E DEBUGGING:
# ------------------------------------------------------------------------------
# - FIZ TUDO, QUANDO DIGITEI O IP DA MÁQUINA "19.33." no BROWSER DO CELULAR, E O NGNIX DEU UMA TELA BRANCA ESCRITO "ERRO 502 BAD GATEWAY" GIGANTE! E O DIRETOR LIGOU CHORANDO Q O SITE ESTA MORTO!
# 
# Pense Sênior (Saber Onde O Fio Arrebentou):
# Erro 502 Significa Que o PORTAO DA FRENTE (TCP 80 Ngnix Cego) ATENDEU SEU CLIENTE! LOGO O FIREWALL TÁ ABERTO!
# Mas Quando Ele Virou E Bateu Na Janela Da Cozinha (O Famoso FastCGI_Pass Unix Sock. do PHP), O COZINHEIRO CEGO NÃO TAVA LÁ (Serviço do PHP-FPM Estava Parado/Crashado No SystemCtl)!
# Solução de Mestre: `systemctl restart php8.1-fpm` e O Site Volta Liso Sem Derrubar O Ngnix Cego Novamente! 

# FIM DA OBRA WEBSTACK. PARABÉNS PELO VOO SOZINHO.
