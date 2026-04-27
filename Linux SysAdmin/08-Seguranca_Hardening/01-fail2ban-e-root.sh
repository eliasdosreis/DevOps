#!/bin/bash
# ==============================================================================
# Aula 08.01: Segurança e Hardening - Defesas Perimetrais (Fail2Ban)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Já Vimos o UFW (Firewall) e As Chaves SSH! Contudo O Mundo Físico Não É Branco No Preto. E se Um Script Bot Da Russia Descobrir QUE A SUA WebSite EMPRESA EM WORDPRESS TÁ VIVA Na Porta 80!!
# A PORTA 80 / 443 É ABRIL PARA TODO MUNDO, VOCE NÃO PODE BLOQUEAR A WEB PRO SEU SITE DE VENDAS!!!
# MAS E SE O BOT FICAR ACESSANDO `/wp-admin` TENTANDO 5 MIL SENHAS POR SEGUNDO??? O SITE VAI CAIR CEGO!
#
# COMO O SEGURANÇA BATE NELE DEPOIS QUE ELE ENTROU NO RESTAURANTE??
# Isso é o Fail2Ban. O Policial Disfarçado. Ele Lê o Log De Clientes do RESTAURANTE AO VIVO (Log File Daemon), E Conta...
# `1 ERRO DE SENHA / 2 ERROS DE SENHA / 3 ERROS DE SENHA:` "OPA ESSE CARA DO IP 130. É SUSPEITO! NO QUINTO ERRO DELE: O FAIL TO BAN BANEE E EXPULSA O CARA DO RESTAURANTE DURANTE 30 MINUTOS CEGOS (Ele cria uma Regra IPTABLES no ar Magica para Barrar O Acesso do Cliente Hostil Pra que A Máquina Respire Paz)."

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Intrusion Prevention System framework. Software Daemon programado em Python que
# utiliza expressóes regulares (Regex) em Filtros (.conf File) Para Matchar "Linhas De
# Authentication Failure e HTTP 401s" Dnetro dos arquivos de Audit (/var/log/auth.log Ou Access.log Nginx). 
# E Quando Ultrapassado O Parametro `maxretry`, Aciona Uma Ação de Punição `Banaction`
# Injetando Iptables/Nftables Drop Rules de `Bantime` limitados (ex: 600 segundos Drop Null), Pra Mitigar Negação De Serviços Bruteforce At-Layer7.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). 

# Vamos Ligar as Câmeras Mágicas Ativas Do Servidor Para Escutar O Log De Logins Falsos!
apt install fail2ban -y

# ATENÇÃO SÊNIORIDADE ABSOLUTA: 
# Um Sênior NUNCAAAAAA EDITA O ARQUIVO Oiginal Do Github Deles `/etc/fail2ban/jail.conf`!!
# Porquê??? PORQUE NA ATUALIZAÇÃO DO APT ELE SERÁ SOBREESCRITO E ZERADO E A EMPRESA FICA VULNERÁVEL O ANO TODO!
# 
# A MANEIRA SÊNIOR É: Criar um COPY Clone Chamado `.local`!! O Fail2ban Lê O `.local` e Sobreescreve Cego A Mente dele!! 
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local  # OBRIGATÓRIO EM TODOS OS DEPLOYS MUNDIAIS.

# LIGANDO A CADEIA DO SSH E PUNINDO QUEM ERROU 3 VEZES DE REDE EXTERNA C/ BAN 1 HORA:
# No vim do `jail.local`: 
# [sshd]
# enabled = true
# port = 22
# maxretry = 3
# bantime = 1h
# ignoreip = 127.0.0.1/8 192.168.1.15   <--- A MAGIA DO SYSADMIN (Whitelista O PRÓPRIO IP DO SEU NOTEBOOK DE CASA PRA SUA EMPRESA.. ASSIM SE VC ERRAR 5 VEZES A SUA SENHA CEGA... O SISTEMA NÃO VAI TE BANIR DA RUA TE DEIXANDO DESEMPREGADO BLOQUEADO FORA DO DATACENTER DOS ESTADOS UNIDOS! MUITO CUIDADO AQUI!)!

sudo systemctl restart fail2ban       # Liga E Vigia Os Robôs Russos Serem Jogados no Chão De Dor!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] fail2ban-client status sshd
# [O QUE FAZ] Ele Pergunta Ao Guardinha Ao Vivo "Me Mostras O Seu Caderno De Presos Desta Prisão (jail name sshd)!!"
#             [SAÍDA MARAVILHOSA]: Banned IP list: 189.3.4.15 | 200.5.4.1 ... O Cara Da Russia Foi Engolido Pelos Logs.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - PÂNICO DE MADRUGADA DO DEVOPS (O TRANCAMENTO DE GÊNIO DE FORA): Você Omitiu O "Ignore_Ip" Na Jail Do Ssh!
#   Você E a Sua Equipe Tentou Logar Da Empresa Usando O IP 180.x.x Do Escritoir Cego E Pelo Teclado Cego Sujo Vocês Erraram 4 vezes a Senha Cega Root De Deploy Da Chave ED25519 Sem Querer Pq O KeyRing Windows Falhou. E O Fail 2Ban "TRancou O Escritório De São Paulo Pra Fora Por 2 Dias!!!!!". 
# 
# Puxem o Lacre Cloud da VM Rescue AWS, entrem em IP Troca Nat... E Façam o Perdao Militar do "UnBan Cego IP Na Mão Do Preso Via Socket IPC":
# SOLUÇÃO MÁGICA DE RETORNO: `fail2ban-client set sshd unbanip 180.x.x.x` (Ele arranca e Deleta a algema iptables na hora Perdoando Sua Empresa).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Proteger Senhas de Mysql Com O Fail2Ban É Um Mito Bruto E Pode MATA-LO! (Vazamento de Ram Por Regex Parsing!)
# Fail2ban Lê Texto (I/o Arquivos Txt Cego). Arquivo de Log "Erros" Do Servidor. 
# Se você Configurar Ele Vigiar Os Failed Logins Cego de Uma "API JAVA SPRINGBOOT QUE ESCREVE 500 LINHAS DE EXCEPTION MENSAGEM NO DISCO POR ERRO... " O Daemon Do Python do Fail2Ban COMEÇAR A PROCESSAR  A "REGEX" DE MATCH DE EMAIL EM 500 GIGABYTES DE EXCEPTION LOG INFINITA NUMA LINHA SÓ DA RAM!! Isso Causa 'OOM (Out Of Memory) Killer' Inverso Onde O Policial Pesa Mais Que O Custo Que o Ladrão! Use APENAS Pra Arquivos Sintetizados Unilines Curtas (Auth.log, Nginx access e Cia limitadas). E Não Para Java Huge Dumps Cego.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você configurou Nosso Servidor Web com O Fail2Ban Lidando Cargas Massivas Da Internet, Após O Jail Nginx Ser Ativado Cego... O Comando `iptables -nL` Ficou COM 5 MIL REGRAS DE IPS DROPPADOS NA CADEIA! Cada vez que o Kernel Tenta Entregar O Ping Pro Seu Nginx, Ele Fica Fazendo o processador Ler E TESTAR A Linha 1 À Uma De 5 MIL Regras Desnecessárias Cego do List Pra Chegar No Aceite Daquele Pagante De Cartão. O Tráfego Congestionou Numa Complexidade Morte O(N-Rules). Como o Administrador de Base Resolve a Complexidade e Desfoga o Firewall Cego O(N) mantendo as penas do Fail? Num Cenário Cego De Escalabilidae?"
#
# Resposta Esperada: "A Alteração Estaria Na Action (Acão) do Subdaemon do Fail2ban Básico. A BANACTION Inicial Do Jail É Usar 'iptables-multiport'. A Solução Exclusiva Sênior Em Altissima Escalaridade Cega Corporativa é Mudar A Banaction Para Usar Os Filtros Hasheados de Index 'Ipset' (`banaction = iptables-ipset`). O Ipset Opera Do Lado C-Array Kernel Em Tree-Hash Rápida 'O(1)'. Ao invés De Escrever 5 Mil Regras Lentíssimas Drop Sequencias No Netfilter, Ele Mapeia Todas Punições NUMA ARRAY BINÁRIA Hash Unica de Lookup Assincrona Em Milisegundos Do Ipset Cego Não Interrompendo Nenhum TCP Client Cego Legítimos!"
