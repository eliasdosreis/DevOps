#!/bin/bash
# ==============================================================================
# Aula 06.04: Gerenciamento de Software - Caçando PPAs e Repositórios
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Pense no seu celular. A "App Store Oficial da Apple" já vem pré-instalada 
# nele, garantida, segura e testada pelo dono do ecossistema. (Repos Oficiais APT Main).
# MÁÁS... E se você quer instalar o "Emulador de Super Nintendo", de um cara da
# faculdade, E O TIM COOK (UBUNTU) DETESTA Emuladores E PROIBIU ELES NA LOJA OFICIAL?
# Você vai adicionar o "Link Secreto Da Nuvem Pessoal do Cara da Faculdade"
# DENTRO do catalógo da sua App Store, pra elá "Ler a loja dele também".
# Isso é um PPA (Personal Package Archive)! E O perigo Disso é Assustador!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O FHS do Debian aloca os catálogos universais do `apt` em `/etc/apt/sources.list`.
# O parser HTTP HTTPS dpkg entra em cada linha `deb http://archive.ubuntu...` e
# coleta os Index Files de Release e Packages.gz de cada árvore de repo listado.
# PPAs do portal Launchpad (Ubuntu) inserem fontes de terceiros ("Unsupported")
# na array do DPKG. Tais Repos NÃO TÊM GARANTIA DE COMPATIBILIDADE do Kernel,
# Causando Vulnerabilidades de Dependency Hell em "Apt Grades/Full-Upgrades".

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo).

# Passo 1 (Você vai no site do Nginx e eles falam: Nginx Oficial nosso É MUITO MAIS NOVO QUE O NGINX VELHO OFICIAL DO UBUNTU! Add O PPA!)

# Adicionamos o PPA Ondrej Surý para PHP 8 Novo (O Ubuntu 20 antigo morreu no PHP 7):
add-apt-repository ppa:ondrej/php -y    # OBRIGATÓRIO: Injeta GPG Keys confiaveis Criptografadas no Chaveiro (/etc/apt/trusted.gpg.d).

# Passo 2 (Como Adicionei um Link Pessoal Novo da loja, DEVO Atualizar Catálogo Pra O APT ler O Link!)
apt update                              # OBRIGATÓRIO (Agora ele enxerga o cara novo).

# Passo 3 (Baixar "A Versão PHP 8 que SÓ EXISTE NO PPA, e NUNCA O UBUNTU TE DARIA")
apt install php8.3 -y                   # OBRIGATÓRIO (MÁGICA OCORRIDA E PPA VENCE).

# COMO EXTRADITAR UM PPA NOCIVO PRA FORA DA EMPRESA E REMOVER TUDO (REMOVER CARAS RUINS).
# O utilitário abençoado "ppa-purge". Ele DESTRÓI O REPOSITORIO E ENCHE A EMPRESA
# COM A VERSÃO DOWNGRADE ORIGINAL E CONFIÁVEL DE VOLTA PRA NÃO QUEBRAR A MÁQUINA!
apt install ppa-purge -y
ppa-purge ppa:ondrej/php                # SÊNIORIDADE: Retira a loja do Ondrej, remove o php8, Reabilita o php7.4 liso do Ubuntu!!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] cat /etc/apt/sources.list.d/*
# [O QUE FAZ] Em vez de usar arquivos sujos pra edição burra do Sources.List original...
#             Deixe o Source original em Paz. O Comando joga os arquivos em `.list` da nova
#             pastinha mágica `sources.list.d/`. Você lê a lista de quem sÃo Os Terceiros que
#             Injetaram Softwares Gringos Na Sua Empresa Listando essa pasta Drop-Ins Ali!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - "APT UPDATE FALHOU COM GPG ERROR KNOWLEDGE NO_PUBKEY 43BXXK0S!!""
# 
# Isso Aconteceu Porque você Baixou A Linha do Catálogo de um Sistema Pessoal Sem Adicionar O 
# CADEADO CRIPTOGRÁFICO de "Documento Reconhecido em Cartório Da Assinatura do Software" DO INDIVIDUO!
# No Linux Seguro, NINGUÉM PODE INJETAR REPOSITÓRIOS Clandestinos SEM O TOKEN DE ASSINATURA DA LOJA (GPG Key Ring)!
# Solução: `apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 43BXXK0S`. Confia a Key e da Update dnv!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Nunca Adicione PPAs No Seu Servidor Bancário! "O PPA VENENOSO DO DESENVOLVEDOR". 
# 
# O Júnior, Querendo a versão Nova do "Grafana", adicioua o PPA Do Github do Zezinho!
# Seis meses depois (ZeroDay Excalation Privileges), O PPA Do Zezinho é HACKEADO por Coreanos, 
# E OS HACKERS SUBSTITUEM O ARQUIVO BINÁRIO GRAFANA NO SERVIDOR DO ZEZINHO PELA MESMA 
# ARQUITETURA. MAS ELES EMBUTIRAM "O MAIOR SCRIPT RANSOMWARE NO PACOTE DO ZEZINHO"!
# O Junior Chega No Serviço Na Segunda, Bate Aquela Vontade e Roda: `apt update && apt upgrade`!!
# O APT "ENXERGA QUE NO PPA DO ZEZINHO TEM UMA ATUALIZACAO NOVA E ASSINATURA BATE", E ATUALIZA!!!
# O BANCO DO BRASIL FICA OFFLINE POR 1 MÊS, OS HACKERS COMEM MILHÕES!!!
# E o Culpado Foi O Júnior Achando que PPA era App Store Brincadeira Opcional Segura! USE CONTAINERS/DOCKER, ISOLADOS PARA SOFTWARES RESSICLIANTES!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está tentando adicionar um repositório Estrito `.deb` 
# que Nossa Arquitetura Interna RedHat Da Empresa Proveu Pelo IP Interno Offline sem Internet! 
# O Arquivo Da Nuvem Oficial da Oracle Tá Bloqueado pra Vocês Baixarem. O `apt update` Trava 100% Por 
# Tentativas de Bater Em 'security.ubuntu' Pra Atualizar, Mas Sua Máquina TÁ SEM INTERNET NUMA VLAN DMZ BLINDADA!
# A Empresa Vai Parar Se Você não Instalar esse Módulo Python Agora Offline! Como Funciona o ByPass APT Offline Cego?"
#
# Resposta Esperada: "Garantiriamos a Restrição Abosulta e Desvio da Topologia da DMZ (Arquitetura Air Gapped). Nós
# Colocaríamos o Arquivo `meu.deb` num Pendrive USB ISO Ou SAN de NFS Seguro (Mount Seguro). Depois de Atrelar, Mencionamos
# e Editamos No Fundo do `/etc/apt/sources.list` comentando ('#') Toda Rota Cloud HTTP Ubuntu Antiga e Registrando Unica:
# `deb [trusted=yes] file:///media/usb/repo ./` (File Protocol Archive Absoluto Local!). A engine APT, 
# Crente Que Resolveu um Cluster Giga-Storage Pela Placa Loopback Local, 
# Fará Todas AS Checagens de Dependencies Trees Do DEB Perfeito Com Pacotes C-libs Esgotando As Fitas Cegas! O Sistema Vinga!"
