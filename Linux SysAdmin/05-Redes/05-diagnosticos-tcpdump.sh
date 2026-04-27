#!/bin/bash
# ==============================================================================
# Aula 05.05: Rede - O Sniffer e Diagnóstico Sênior (tcpdump, ss, nmap)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# A internet da empresa travou e a página de Vendas não Abre do celular do cliente.
# O Júnior chuta: "Renicia o Nginx e reza!". Ele não enxerga a física acontecendo.
# 
# Pense na rede como Encomendas da Amazon na rodovia.
# `ss / netstat` -> "Moço Correio, O senhor tá AGUARDANDO alguém chegar (Listen)? 
# E quem é O NOME DO CLIENTE ESTABELECIDO batendo ponto com você LÁ DIRETAMENTE AGORA?
#
# `tcpdump` -> "O CACHORRO FAREJADOR DA ALFÂNDEGA". Ele Morde e Pára TODOS os pacotes 
# elétricos rodando NO AR DO CABO naquele milissegundo. E Pinta as Letras dos Emails e Textos na 
# Sua Tela mostrando TUDO QUE A CONCORRENCIA TÁ FAZENDO sem Criptografia! E Lendo os Bytes Crus IPS.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Diagnósticos Socket e IPC via Netlink Inter-Kernel Comm.
# O `netstat` sofreu Depreciação no CoreUtils (muito lento, lia '/proc').
# A ferramenta Sênior é O `ss` (Socket Statistics do iproute2). Responde 100x mais rápido TCP connections ativas!
# 
# Packet Sniffing na Promiscuous Mode Layer Pcap. O `tcpdump` intercepta
# Protocol Data Units (PDUs) debaixo dos processos de C-Lib pelo modo Físico da Placa em Kernel Mode e
# Loga em formato ".pcap" para o software gráfico "Wireshark" dos Picos de tráfego de Roteamento.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# ===== INVESTIGAÇÃO DE SOQUETES ATIVOS (Socket Statistics) ===================
# Alguém do Datacenter tá derrubando O Banco de Dados de Logs do Apache com 15mil requisições simultâneas? E qual a porta que o banco real roda ali?
ss -tulpn                   # OBRIGATÓRIO T.U.L.P.N
# Explicando o Sagrado TULPN: TCPs | UDPs | LISTENING HOJE | PROCESS NAME/PID | NUMERIC IPs Only(s/ DNS).
# Saída: State LISTEN, Local Address= 0.0.0.0:80, Process = nginx (Isso diz que Nginx é o dono do ralo Porta 80).

# Ver as conexões ativas agora entre Nginx e o Usuário final:
ss -ta                      # (TCP All). State ESTABLISHED entre Servidor e IP do Cliente.

# ===== CÃO FAREJADOR DE TRÁFEGO (TCPDUMP) E WIRESARHK ==========================
# (Sempre rode SUDO!)
# O Cliente "O site Web tá Lento pra carregar!"
# Sênior manda rodar: O TCPdump Lê a porta "HTTP" Bruta e vê SE AS CARTAS TÃO CORROMPENDO 
# no cabo e Descreve na tela ao vivo até vc dar Ctrl+C.
sudo tcpdump -i eth0 port 80 -n  # OBRIGATÓRIO (Lê a rede eth0 de frente -n sem ligar pro nome dns burro lerdo).

# Um Sniffing Pesado Para a Equipe CyberSegurança Ler no Wireshark do PC Gráfico Windows na Segunda Feira!!!
# (O Hacker está na Base).
sudo tcpdump -i any -w gravacao_trafego_hacker.pcap port 3306  # (-w escreve pra disco silencioso pcap gravadas no Banco MYSQL/3306!)

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] nmap -sS -p- servidor1.empresa.com
# [O QUE FAZ] Nmap (Network Mapper). O Sênior Roda de Casa Pra Atacar o Seu Próprio Server e Auditar Furos "Esquecidos abertos".
#             "Scan StealTh (-sS) Testando As Maravilhosas 65 Mil Portas (-p-)"
# [SAÍDA ESPERADA] Port 22/tcp Open. | Port 6379/tcp Redis-Server Open Exposed to the world. (Vulnerabilidade letal Crítica de Cache Encontrada!).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Deu PING "8.8.8.8"... Funcionou Perfeito o disparo de Vida pro Google. (ICMP Echo Request vivo).
#  O Desenvolvedor diz: "Legal, tenho conexão livre e Internet Ilimitada!"... Mentiroso.
#  Você vai Dar "curl http://google.com"  e DÁ TIMEOUT DE SOCKET!!!!
#  
#  A Pegadinha LPI Junior: O Ping SÓ testa Protocolo ICMP! É o pilar vazio só de respiros do Roteamento (Ecos da Rodovia livre).
#  E se o Roteador de Borda ou Iptables do Provedor CORTAR PORTAS TCP 80/443 de Empresas inadipentes deixando o ICMP aberto? 
#  O Sênior sempre testa Camada 4. `telnet google.com 80` (Acesso direto a porta socket crua tcp handshakable!!) se conectar ali sim tá vivo o serviço específico!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Como o Diagnostico `traceroute` salva seu Emprego contra culpas de Provedores Tier-1 Brasileiros!
# A Empresa inteira caiu hoje no seu Plantão SRE. O Diretor berra "Culpa do Time de Cloud AWS, subimos código bugado!".
# O SysAdmin sabe a arquitetura. Ele Dispara O Abençoado `traceroute google.com`.
# Ele pula o pacote pra PORTA DA EMPRESA 1 (1 ms) --> Pula pra FIBRA DA VIVO INTERNET 2 (20ms). ---> Pula Para "Backbone Submarino Brasil / Florida Miami Rota 3" e PAAAAAAAAAAARA!. Começam Mil (*) Asteriscos Mortos. 
# 
# O Tracert Prova por Tempo de Vivência ICMP (TTL decrementativo) que o roteador de Desdobramento Da
# Rota Principal da CLARO/VIRTU na Flórida FOI QUEM INTERRROMPEU O NOSSO PACOTE (Rompimento do Cabo Submerso).
# E NÃO o código/Linux! A Culpa é física de Carrier! O DevOps printa essa Traceroute pra Diretoria e salva reputações C/ ISPS!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Média Alta Crítica: Nossos logs de proxy acusam uma onda de TCP resets estranhos, com 
# rajadas constantes. Precisamos rodar um packet capture tcpdump bruto, contudo, é um servidor de altíssimo 
# débito de pagamento transacionado gerando 3 gigabytes em arquivos '.pcap' a cada hora se salvarmos o payload total!
# Como eu Gravo em um arquivo PCAP APENAS o Cabecalho do TCP pra salvar nos nossos HDs do IDS (Intrusion System) 
# economizando discos sem salvar as mensagens de payloads corporativas dos clientes?"
#
# Resposta Esperada: "Usaríamos a funcionalidade de Corte de Captura do Payload SnapLength (-s) 
# da engine libpcap do tcpdump na Interface Promíscua! O comando engatilhado seria:
# `tcpdump -i eth0 -s 64 -w arquivo_cortado.pcap`
# O flag 'Snaplength -s 64' restringe e poda agressivamente o Packet Capture para armazenar em HD apenas os 
# Primeiros 64 bytes da Frame Ethernet/IpHeader/TCPHeader. Discartando tudo (payload de pagamentos, body html) do dump.
# Preservando os metadados brutos essenciais de MAC/IP e Syn/Ak para análise forense futura consumindo KiloBytes de Storage por mês!"
