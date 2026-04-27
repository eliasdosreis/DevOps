#!/bin/bash
# ==============================================================================
# Módulo 2: Reconhecimento e Enumeração
# Aula 01 - Port Scans Stealth e Ativos (A base do Recon)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você é um detetive de polícia sondando um prédio de apartamento suspeito.
# Scan Simples (TCP Connect): Você bate na porta forte e grita "Aqui é a puliça". 
# Se alguém falar lá dentro, você anota a porta como "ABERTA". Mas o síndico 
# (o Firewall) anotou na caderneta dele seu Rosto (seu IP) para sempre na delegacia.
# Scan Furtivo (SYN Stealth): Você gira a maçaneta da maçaneta de fraquinho...
# quando escuta que destravou e alguém diz "Quem está ai?", você corre pro 
# mato (Reset). A porta abriu, você confirmou. Mas a conversa nunca se estabeleceu, 
# então oficialmente para os registros normais (logs de serviço do Nginx/IIS por ex),
# você não cometeu infração nem visitou o local!
# E UDP? O UDP é atirar uma pedra com papel na janela do vizinho. Se bater e não voltar um sapato de volta (ICMP Unreachable),
# você asume ingenuamente que ele pode ter lido a mensagem.
#
# 2. O QUE É (definição técnica Senior)
# Varredura de Portas mapeia os 65535 sockets virtuais abertos (LISTEN) vinculados por serviços rodando via IPC na stack de rede.
# A diferença entre `-sT` e `-sS` do NMAP consiste no comportamento do hand-shake do Protocolo TCP.
# -sT (Connect Scan): Completa o 3-Way Handshake (SYN -> SYN/ACK -> ACK). A aplicação na camada 7 encerra o socket, joga pro log e depois corta. É barulhento e lento. Só é usado se você não tiver privilégios ROOT no seu linux atacante pra injetar pacotes RAW no driver da VM.
# -sS (Half-Open/SYN Scan): Envia apenas o Início do pacote de estabelecimento (SYN). O Sistema do alvo ingênuo levanta o chapéu e manda de volta o ACK pronto para aceitar dados. Mas o Nmap na malícia manda instantaneamente o flag de interrupção brusca pacote `RST` da abortagem. A Camada de sistema desfez a conexão antes de entregar na mão do "Apache". Invisibilidade perante logs HTTP, porém visível na Camada de Firewall (IDS Logs tipo Snort).
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="127.0.0.1" # Substitua pelo IP da VM Vulnerável sua do lab

# O MAIS Famoso dos Analistas e Pentesters.
# O Fast Syn Scan (Stealth), requer Sudo/Root!!
# -sS -> Mande RST e corra. (Stealth)
# -Pn -> Pule o "Ping" ICMP, assume que ele tá vivo (o Firewall pode bloquear pings).
# -n -> NÃO perca tempo resolvendo nomes de dns nas portas proip (acelera mtooo).
# -p- -> Escaneie TODAS as 65535 portas, e não apenas as Top 1000 padrões.
# --min-rate 1000 -> Force envio de até 1000 pacotes por seg para terminar em 60 seg pra não durar horas.
#
echo "[+] Iniciando o Furtivo Stealth Completo..."
# Descomente para rodar:
# sudo nmap -sS -Pn -n -p- --min-rate 1000 $TARGET

# O Scan UDP Cruel (Lento de Matar):
# -sU pra protocolos não orientados a conf do RFC.
# -p 53,161,137 -> Portas famosas pra DNS, SNMP, NetBIOS de Windows
# DNS (Domain Name Sys), SNMP (Info Management). Não há 3way-handshake no UDP.
echo "[+] Iniciando a pescaria nos poços densos de UDP (DNS, SNMP, NetBIOS)..."
# sudo nmap -sU -p 53,161,137 $TARGET 
#
# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: No seu laboratorio isolate, defina uma variável `IP_ALVO="192.168.1.10"` e pegue-o pra a Máquina Metasploitable.
# Passo 2: Comece um PING SWEEP (apenas achar quem tá vivo sem dar port scan brutal) primeiro: 
# `nmap -sn 192.168.1.0/24`. Descobrindo os hospedeiros do mar.
# Passo 3: Com o IP Alvo da Metasploitable, rode o Scan Stealth (-sS) detalhado em cima. Redirecione pra um text file ` > fast_scan.txt` e analise as portas que caíram "open".
# Passo 4: Você achou 22, 80, 445 abertos? Perfeito. Um hacker só foca onde tem serviço respondendo.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando você envia `-sS` com usuario nao-root normal, toma aviso. Use Sudo pra poder moldar a socket no header no Linux e injetar SYN corrompido! Se nmap responder `Stats: 0 ports found`, veja se o Host não dropou ICMP e refaça a chamada forçada utilizando a técnica do `-Pn`. T4 significa modo agressivo local (-T4 acelera).
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior quase sempre utilizar a saída customizada e massiva GREPABLE das flag combinadas `-oA <prefix_tname>` ou oXML `-oX`. Quando a Infraestrutura tem 3 mil Range IPs, uma varredura gera gigabytes. Exportando estruturado no XML, automatizadores em Python podem rodar parser iterativo jogando IPs com a 445 SMB aberta numa pipeline automática que puxará um segundo docker exploit de scanner para rodar o "Zero-Logon", acelerando a cadeia da morte. O junior scaneia no visual lendo log verde no console; o Senior scaneia em JSON/XML mandando por API Slack os outputs das falhas e injetando pra relatorios de conformidade do banco de forma simultânea.
# E sobre o UDP? As respostas no UDP podem voltar como erro `open|filtered`. Isso ocorre porque se não vier O PACOTE DE RETORNO de ICMP port unreachable da operadora, não dá pra saber se um firewall Dropou calado ou o serviço está só ignorando por um mal protocolo de DNS.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu contrato te exige provar que uma rede corporativa bloqueou o scaneamento de portas ativas contra as filiais pelo SOC via CheckPoint e o Fortinet IPS. Eles bloquearam todo tráfego Ingress de 3way handshake. Como vc faz uma flag Nmap MÁGICA para dar bypass num firewall antigo ou num switch de layer 3 desatento, sem sequer começar uma conexão SYN real?"
# Resposta Esperada: Utilizando um TCP FIN Scan (-sF) ou um XMAS Scan (-sX) ou NULL Scan (-sN). Como no -sX as flags `FIN, PSH e URG` chegam subitamente ligadas ao mesmo tempo de "graça" sem nenhuma conexão existir em andamento, regras burras de firewall que só leem stateful da tabela SYN passam reto o pacote pra dentro do Linux. E o RFC 793 do kernel Linux manda um RST obrigatório de volta pros atacantes confirmando pra nós tacitamente que a porta ESTÁ aberta ao responder a quebra de um bug bizzaro. O Windows deflete calado na maioria, mas Linux base é fálho á esse scan passivo de pacotes de árvore de Natal com LEDs acesas, uma falha inerente fantasma das RFCs originais da internet!
