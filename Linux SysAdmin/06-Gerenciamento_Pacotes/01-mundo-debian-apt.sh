#!/bin/bash
# ==============================================================================
# Aula 06.01: Gerenciamento de Software - APT e o Mundo Debian/Ubuntu
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Antes das "Lojas de Aplicativos" (App Store/Google Play), o Linux JÁ FAZIA ISSO
# desde 1998 com os Gerenciadores de Pacote!
# O `APT` é a Loja de Aplicativo. Você não precisa ir no Google, baixar um arquivo
# suspeito ".exe", dar dois cliques e clicar em 'Next, Next, Finish'.
# O Celular (APT) baixa o App validado criptograficamente pelo fabricante, instala 
# as dependências que o app precisa (ex: se o app precisa de Camera.dll, ele
# baixa a camera.dll SOZINHO sem te pedir), e te entrega pronto pra uso!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Debian Packages (`.deb`). Um pacote nativo é um arquivo Ar (Archive) contendo 
# binários compilados, páginas de `man` e scripts de Pre-Install. 
# 
# Existem 2 níveis na hierarquia do Debian:
# 1. O Nível Baixo: O comando `dpkg`. Ele é Cego. Instala o arquivo `.deb` local 
#    no seu HD, mas FALHA se faltar dependência, pois ele NÃO VAI NA INTERNET buscar o resto.
# 2. O Nível Alto: O comando `apt` (Advanced Package Tool). O Maestro de Rede 
#    Calcula as Árvores de Dependências na RAM resolvendo DAGs matemáticos, vai
#    pra Internet, Baixa TUDO, e usa o dpkg em Background silencioso pra você!

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo).

# Passo 1: O "Refresh" da Loja de Aplicativos.
apt update                  # OBRIGATÓRIO: NUNCA inicie um servidor e Dê "apt install".
# O "update" NÃO BAIXA PROGRAMA! Ele apenas baixa a LISTA DE TEXTO (Catálogo de papél)
# avisando quais as versões novas disponíveis na nuvem Ubuntu.

# Passo 2: A instalação Perfeita (Ex: Servidor Apache)
apt install apache2 -y      # OBRIGATÓRIO: O `-y` auto-aceita o [Y/n] pra poder Automatizar.

# Passo 3: Removendo o Lixo depois de testes
apt remove apache2          # Apaga o binário apache, mas DEIXA as Pastas de Configurações pra trás!
apt purge apache2           # SÊNIORIDADE: O 'Purge' Exorciza! Apaga Arquivos e TUDO do /etc dele.

# Passo 4: O Nível Baixo DPKG Local. 
# Você baixou o arquivo "discord.deb" no site Oficial. O APT não tem ele na Loja.
dpkg -i discord_amd64.deb   # OBRIGATÓRIO (-i = install): Instala arquivo local.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] apt search nginx
# [O QUE FAZ] Puts, esqueci o nome exato do pacote do Nginx-Cache. Rode isso e
#             o Regex de busca do APT escaneia o catálogo por todos os nomes
#             que contêm a string 'nginx'.

# [COMANDO] apt autoremove
# [O QUE FAZ] Faxina. Quando você instala o Nginx, ele traz o 'lib-http-1.0'.
#             Quando você Deleta o Nginx, a Lib fica ocupando espaço inútil e órfã!
#             O auto-remove mapeia C orphans e delete-os do SO. Use com sabedoria.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - FENÔMENO MACABRO DE DOWNGRADE: "Elias, o Apache do servidor PROD tá na varsão 2.4.40.
#   A versão Mais Nova na Nuvem é a 2.4.55 contendo um fix de Segurança Crítico.
#   Porém, Toda vez que eu rodo `apt upgrade apache2` ele dá "0 Newly installed, 0 to remove", ELE IGNORA O UPGRADE! Por que!?"
#   
# A Maldição do Pacote Held (Retido).
# Algum SysAdmin Anterior seu TRANCOU O PACOTE por medo do software quebrar a empresa!
# (Processo de Dpkg Pinning ou Apt-mark).
# Solução de Investigação: Roda `apt-mark showhold`. (Vai Listar 'apache2').
# Retire a trava na permissão do chefe: `apt-mark unhold apache2`. Depois
# faça o upgrade normalmente e observe se nada explodiu!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Por que Não usamos "apt-get upgrade" Cego Diariamente Num Datacenter?
# Você acabou de herdar o Banco Central do Brasil Ubuntu Server. 
# O júnior manda ali no terminal Root `apt upgrade -y` no desespero.
# Acontece que a Atualização trouxe um "Kernel 6.8 Novo", e Modificou as sub-redes
# base de segurança do IPtables/Polkit.
# 
# O Servidor que você deveria "Manter No Ar CustoqueCustar" agora Reiniciou sozinho 
# pra trocar de Kernel ou Corrompeu as chaves da base. 
# REGRA SÊNIOR ABSOLUTA: Servidores Cloud-Native R-a-r-a-m-e-n-t-e devem ser "Upgradados" (Pets).
# Se O Servidor tá com Versão velha (Ex: Nginx 1.14)?
# VOCÊ NÃO ATUALIZA ELE! Você DESTRÓI a VM de 2 anos, Vai no Terraform, Cita
# Arquitetura Nova Ubuntu 24.04, Gera Uma Imagem Nova no Ar com Nginx Zero KM (Cattle),
# Direciona o banco e Mata a máquina antiga sem dor! Infraestrutura Imutável é o Caminho.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está tentando debugar uma falha Bizarra na porta 443 do 
# sistema. Existe 1 arquivo estático misterioso em `/etc/ssl/openssl.cnf` que 
# você acredita estar causando a falha, mas você não sabe de Onde ele veio nem
# quem instalou Ele. Qual comando no ecossistema Debian DPKG nos garante
# imediatamente Mapear esse arquivo pra 1 pacote oficial Pai?"
#
# Resposta Esperada: "A Ferramenta de Reverse Mapping do dpkg. O comando exato é:
# `dpkg -S /etc/ssl/openssl.cnf` (-S de Search). 
# O comando varrerá a base de dados hash do Local Archive localizando a qual 
# pacote original (ex: 'openssl' ou 'libssl-dev') aquela string absoluta de path
# pertence intrinsecamente, permitindo recriar pacotes ou desinstalar pacotes ofensores."
