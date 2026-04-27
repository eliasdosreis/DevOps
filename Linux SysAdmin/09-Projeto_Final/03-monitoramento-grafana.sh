#!/bin/bash
# ==============================================================================
# Aula 09.03: PROJETO FINAL - Monitoramento e Dashboards (Prometheus/Grafana)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA SÊNIOR
# ------------------------------------------------------------------------------
# Ficar Logando e Dando 'DF -H', 'HTOP', 'TAIL SYSLOG' 30 vezes Por Dia Em 1 Máqina Ok, o Sysadmin Junior Faz. 
# Quando VocÊ Fica Sênior E Sobe pra 'Site Reliability Engineer (SRE)' E Tiver 500 Máquinas Na Nuvem EC2 da Aple Em NY?
# Você é Humano Cego FHS. VOcê Nao consegue logar nas 500 PRA DAR HTOP ao Vivo Acionado!
# 
# A SOLUÇÃO Cloud: Prometheus Cego Magico Puxador De Dados Temporais!
# O Prometheus Voa e "Raspa" (Scrape) os dados Internos Da Sua Máquina de RAM IO HD NETWORK Do Nginx Das 500 Máqionas e Guarda Numa Series Tempoaral Num DB Gigante Único. E O "GraFANA" BATE NELE EXIBINDO Uma TEla Cheia De Graficos De Bolha VIVo 3D Linda Com Avisos E Apitos Cego Sem o SRE Teclar O Ssh Num Terminal O Dia Inteiro Ceog Base.

# ------------------------------------------------------------------------------
# 2. O QUE SÃO AS PEÇAS NO MUNDO LINUX MAGICO?
# ------------------------------------------------------------------------------
# 1. NODE EXPORTER: O Escondido Exposto Das Entrañas Da Máquina.
# Um Arquivioto Binário Foda Em GO Lang, Que Pega A Sua Aba Fhs Do Proc (`/proc/meminfo`) E Joga Ela Numa Rota HTTP Limpa Porta (9100) Pra Quem Quiser Ler Na Lan Interna (Os Metricos).
# 2. PROMETHEUS O DEMONIO MASTIGADOR DB CEGO:
# O Prometheus Passa E "Curl" Na Sua Porta 9100 Toda Hora Arquivando Historicamente E Limitando Consumo Espaços (TSDB Time Sereias).
# 3. GRAFANA DO BROWSER CEGO: Front End UI Visual Javascript Reativo Ginga Cego Lendo O PromQls Dele.

# ------------------------------------------------------------------------------
# 3. SCRIPT MÃO NA MASSA / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root Cego (Sudo). 

# BAIXANDO O EXTRATOR MAGICO DA MÁQUINA (O Exporter Nativo Linux Kernel Ocult):
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar -xvf node_exporter*.tar.gz
mv node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/

# O SÊNIORIDADE ABSOLUTA - INJETANDO O EXPORTER NO DEUS SYSTEMD DA AULA 4 MAGICO:
# (Para ele Sobreviver a TODOS Os Reboots Cego AWS):
# sudo vim /etc/systemd/system/node_exporter.service 
# ============ ARQUIVO ABAIXO =======
# [Unit]
# Description=Senhor Metricas Node Exporter Cego Base SRE
# After=network.target
#
# [Service]
# User=nodeusr
# Group=nodeusr
# Type=simple
# ExecStart=/usr/local/bin/node_exporter
#
# [Install]
# WantedBy=multi-user.target
# ============ SALVOU ! ================

systemctl daemon-reload               # O DEUS ACORDA QUE INJETARAM ARQUIVO NOVO Cego BASE!
systemctl enable --now node_exporter  # UMA ETERNA MAGIA ELE VOA PRA REBOOT AUTOMATICAMENTE!!

# TESTE SUA MÁQUINA CUSPÍNDO SANGUE PRO NATIVO DO AR: `curl localhost:9100/metrics`
# SE VC VOMITAR LETRAS INFIINTIAS "node_cpu_seconds_total 109282212" NA TELA. 
# SUA MAQUINA ESTÁ AUTOCONSIENTE ESPALHANDO TELEMETRIA DE SRE!! A PROxima Máquina Central Docker Prometheus Pega isso e Plota Pra Todo A Empresa Em Um WallPanel LCD CEGO NO ESCRITORIO DE SÃO PAULO PRA ELES COmEMORAREM VENDAS!!! Fim De SysAdmin Master!
