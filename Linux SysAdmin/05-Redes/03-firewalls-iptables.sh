#!/bin/bash
# ==============================================================================
# Aula 05.03: Rede - Segurança com Firewall (IPTables, UFW, Firewalld)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# O castelo (servidor) tem portas (Portas Lógicas TCP, onde a porta 80 é Web TCP, a porta 22 é a SSH).
# Se você abrir Todas as Portas pro mundo, Ladrões chineses e botnets vão girar as maçanetas
# das suas 65.535 portas pra achar Serviços Velhos esquecidos ligados e invadir o S.O..
# 
# Pense no Firewall Iptables como o MAIÚSCULO Segurança da Guarda de Elite.
# Ele fica olhando "O Endereço do Remetente da Carta (Source IP)" e "Destino (Destination Port)".
# Se a carta (Pacote) bater em qualquer Porta Diferente das Autorizadas 80 ou 443... 
# ELE DROPPA (Joga no rio em silêncio) ou REJECTA (Grita: CARTA NEGADA CIDADÃO).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O Netfilter é um Framework embutido profundo no Kernel Linux desde a V. 2.4. 
# `Iptables` é apenas a "linguagem C" que nós usamos no terminal para interagir e escrever 
# regras nas Chains nativas (INPUT, FORWARD, OUTPUT e PREROUTING) do Cérebro Netfilter.
# Devido a dificuldade Humana gigantesca do Iptables, as distribuições inventaram
# Front-Ends mais Fáceis e Mastigados ("UFW" para o Debian, "Firewalld" para RHEL, NFTables moderno).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). E CUIDADO pra não trancar si mesmo pelo SSH.

# ================================ MUNDO DEBIAN =============================
# Usando o UFW (Uncomplicated Firewall). Maravilhoso e limpo de sintaxe.
ufw status verbose          # OBRIGATÓRIO: Verifica qual lei marcial se aplica hoje aqui.
# A melhor estrutura Sênior de defesa se chama "Denaio Total Default":
ufw default deny incoming   # DROPPA TODOS OS PACOTES DA PORRA TODA ENTRANTE EXTERNA!
# Após proibir tudo, O Administrador vai perfurando Buracos específicos na Cerca!
ufw allow 22/tcp            # OBRIGATÓRIO (Se não fizer isso, vocÊ será desconectado e trancado fora do SSH!)
ufw allow 80,443/tcp        # Libera portas 80 HTTP e 443 HTTPS.
# ufw enable                   # (Liga o UFW ao vivo sem medo, ele vai barrar 1 milhão de Bots Asiáticos).

# ================================ MUNDO RHEL ===============================
# Usando O Firewalld (A Zona Rica das regras militares Dinâmicas de Cloud).
firewall-cmd --state                   # Mostra o Vigor do daemon da RH.
firewall-cmd --get-active-zones        # O RHEL Cria "Zonas Internas e Zonas Públicas Internet".
firewall-cmd --zone=public --add-service=http --permanent # Libera permanentemente o Site Apache.
firewall-cmd --reload                  # Aplica no ar as Zonas Drop sem fechar as ativas.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] iptables -L -n -v
# [O QUE FAZ] Mesmo num Server UFW "bonitinho", se o pau quebrar com um Hacker (DDoS), o Sênior
#             Cai direto na Raiz Bruta do Kernel. Ele lê a Tabela de Carga Básica cruzinha.
#             Ele Verá as Cadeias (Chain INPUT -policy DROP 54148 packets, 4202 bytes).
#             Ele conta os BYTES mortos pelo firewall com o parametro "-v" na cara.
#             A Chain FORWARD (O roteamente/NAT do servidor se fingindo ser Firewall Mestre) fica exposta lá.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO ABSOLUTO (Bloqueio Total). O Júnior roda num Datacenter Iptables:
#   `iptables -P INPUT DROP` e A TELA PARA. CONGELA. VOCÊ LIGA PRO CHAT GPT, O GPT REINICIA A TELA.
# 
# Isso Aconteceu Porque a Policy DEFAULT da Máquina foi setada pra Jogar Todo o Trafego no 
# lixo SEM UMA EXCEÇÃO pra própria porta SSH do teclado do menino de Chicago. A Conexão do Junior no PuTTY 
# é um pacote Entrante também! Acabou, pegue o Lacre Físico de emergência Nuvem via VNC da máquina pra voltar lá! 

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# A diferença Crítica que todo Sênior Cobra entre DROP e REJECT.
# A "Regra de Bloqueio" do Iptables tem 2 Targets de Bloquear Pacotes TCP.
# Se um Robô Chinês bate na porta Telnet (23) atrás de Senhas:
# 1. Se usar **REJECT**: O Kernel linux lê a carta maligna 23, FAZ FORÇA DE BATER UM CARIMBO
#    "CARTA RECUSADA CARGO X", e EMBALA NUM TCP-RESET de volta pra China através do Atlântico mandando O ROBÔ SABER QUE ACHOU VOCÊ!
#    Você perde BANDA DE INTERNET e PROCESSAMENTO DE CPU DEVOLVENDO NÃO PRO LADRÃO DA PORTA 23!
#
# 2. Se usar **DROP**: (Furtividade Stealth "Drop" Rules "Drop" Packets):
#    A carta bate na placa da sua DMZ. O kernel VÊ "ah, é lixo chinês". O KERNEL ABRE O CHÃO 
#    E DESTRÓI O PACOTE ELÉTRICO, NUNCA RESPONDENDO NEM UM BYTE DE VOLTA! O Robô trava ele dá TIME OUT
#    e acha que VOCÊ NEM EXISTE na rota! DROP economiza Rede DDoS, REJECT gasta! 

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa barrar ataques SYN FLOOD Brutos (DDoS Estouradores) mas sem bloquear as conexões Legítimas de Clientes HTTP que dão Refresh Normal 
# na porta 80 do nosso Web Server. A placa externa é a eth0. Dite uma sintaxe 
# agressiva Root de Iptables para limitar a Carga Base de Conexões Concorrentes TCP?"
#
# Resposta Esperada: "Usaríamos o módulo `limit` e stateful inspection do iptables Nativo
# pra descartar estouros cegos limitando as colisões burras do SynFlood. CÓDIGO:
# `iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m limit --limit 50/minute --limit-burst 150 -j ACCEPT`
# Isso limita novos fluxos entrantes virgens stateful (NEW TCP FLAGS) restritos à 50 batidas 
# por minuto pra mitigar sobrecarga do Apache. Qualquer coisa acima Disso cai nas regras DROP inferiores Default."
