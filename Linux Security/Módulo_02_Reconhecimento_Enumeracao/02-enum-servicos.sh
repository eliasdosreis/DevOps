#!/bin/bash
# ==============================================================================
# Módulo 2: Reconhecimento e Enumeração
# Aula 02 - Enumeração de Serviços e Banners (-sV e Scripts NSE)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você na Aula 1 achou a "porta" destrancada, mas ainda é um detetive do lado 
# de fora batendo... Se você gritar "Oiii, você entrega pizza ai dentro???" (o Probe), 
# quem tiver lá dentro deve te responder "Sim! O forno é 200 graus!" (O Banner Grab). 
# Com essa informação "crua", não é só uma porta aberta, é uma identificação de um programa...
# Sabendo que é um "Forno Brastemp 1999" (Service Version), você já pega a prantilha ou CVE na 
# mochila com o truque específico: "Olha, basta eu meter um pé de cabra aqui no display digital 
# que ele entra em curto... porque esse forno descontinuado já apareceu no programa Fantástico!"
#
# 2. O QUE É (definição técnica Senior)
# O `Service and Version Detection` (Banner Grabbing) consiste num motor heurístico do Nmap que não só abre conexões, 
# bem como INJETA cargas e sequências de probes interativas e lê a resposta regex do software (Ex: "OpenSSH 7.2p2 Ubuntu-4"). O Nmap Engine se chama NSE (Nmap Scripting Engine) via a linguagem LUA e possui mais de 600 pequenos pedaços de programas de testes catalogados pro scan profundo.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="127.0.0.1" 

# Obter o Banner Crú de um serviço telnet sem nmap para pentests em container (O Living Off the Land)
# O comando netcat ou um pacote de bash reverso pra extrair se é OpenSSH ou Dropbear q responde:
# echo "QUIT" | nc -w 1 $TARGET 22

# A varredura suprema Sênior detalhada só nas portas já descobertas abertas
# -sV -> Service Version Mapping (Identifique a marca do software respondente na porta aberta).
# -sC -> Roda a categoria Default Scripts (Vulns e Infos primarias). Usa engine LUA do Nmap.
# -p22,80,445 -> Só ataque as que nós ja sabemos pela aula01 q estão open, nunca rode sV em 65 mil portas (vc gasta tempo e trava de processamento o switch core de sua empresa).

echo "[+] Extraindo os Banners Vitais pro Recon profundo em Serviços Identificados..."
# nmap -sV -sC -p 22,80,445 $TARGET

# Executando um Script NSE específico de vuln
# A engine NSE busca em repos de vulns (`--script=vuln`) para cruzar banners e ver CVEs vivos na unha de um alvo ftp (ex: ftp-anonimo na malícia).
echo "[+] Enumerando falhas NSE Lua em portas FTP de dados..."
# nmap -sV -p21 --script="ftp-anon,ftp-vsftpd-backdoor" $TARGET

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Como de rotina, primeiro você deve fazer na aula01 o stealth run: `sudo nmap -sS -p- IP`. Pegue a lista de números portas.
# Passo 2: Digite agora só com as abertas: `nmap -sV -sC -p21,22,80,445,3306 $IP`
# Passo 3: Assista o resultado sair. Veja mágica de um `VSFTPd 2.3.4` na 21. Se for ele, isso é uma RCE de backdoor lendário embutido do criador da release comprometida! No 80 pode mostrar "Apache 2.4 / Ubuntu", então a sua busca vai para PHP e Apache no google debaixo do braço `searchsploit apache ubuntu 2.4`. O Enumeration é um filtro funil antes do exploit.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Por que eu usei -p21 --script e não mandei script no nmap todo? No ambiente do Brasil ou de nuvens com IPS rodando IDS Snort ou AWS WAF na frente (Firewalls de app web fortes), o `-sC` default dispara dezenas de scanners mal-educadas de User-Agent do "nmap", "nikto", e isso BANIRÁ e ativará as heurísticas defensivas e os bloqueios dinâmicos de fail2ban de sua infra nas próximas meia horas. Seu Pentest vai para o lixo. Foque com bisturi ou rode -T2 stealth pros scripts e não agressivos default em alvos vigiados.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo das Engenharias LUA da NSE existirem: Interatividade. Uma coisa é saber se "MySQL" está na 3306. A outra coisa é: Ele permite login de root em branco? (EmptyPassword check). E quanto às portas customizadas que não usam as de manual? Se alguém esconder do port-scan de scripters um SSH na porta 8080 ou na 443 pra dar bypass da rede corporativa de DPI... Quando o nmap rodar `-sV -p 8080`, ele não assumirá que é um Apache como a porta dita. Os probes do Nmap irão bater, não vai dar hit pra apache HTTP. Então o Nmap tentará todas as dezenas de sondas de protocolos alternativos (`sshd de cara!`) e finalmente cuspirá a saída dizendo: "Opa, porta 8080, porém, servindo OpenSSH v8!". Sem a tag -sV, você acreditaria cegamente pela porta numérica na RFC (service/port-maping) falseando o recon de escopo. Nunca tome NÚMERO porta sem validar com sV como base absoluta.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Sua prova pro time de Red Team te bota pra examinar o serviço de backup de um Windows Server isolado na DMZ, onde o scanner NMAP `-sS` diz q a porta 135 e 445 está Open SMB, mas o `nmap -sV` bizarramente recusa a funcionar, dando time-outs e dizendo desconhecido e Service Not Recognized. Sua máquina atacante está rodando com regras rigorosas de proxy em sua filial via roteamento NAT com DPI forte impedindo a interatividade de assinaturas e você precisa saber O banner Windows no braço sem dar alerta IPS. Tem alternativa rápida low-level sem scanner?"
# Resposta Esperada: Podemos voltar pras ferramentas puras! Basta abrir o `nc 10.0.0.21 445` no modo UDP ou TCP. E injetar caracteres NULL ou bater ENTER duas vzs como CRLF no pipe na força bruta. Sem interatividade o próprio protocolo do rpcbind recusa bad requests da stack TCP do SMB... e pra dar "Invalid Request" ou "Protocol Desync", o deamon jorra como header default os bytes contendo a build do host ou info da stack TCP do RFC, entregando uma build-flag do Windows CE ou XP se o fingerprint IP TTL bater junto pra deduzir que os buffers de tamanho são dele. Além disso o Wireshark (packet cap tcpdump) de um 3way handshake revelaria o WindowSize e os Options de SACK exclusivos a Windows vs Linux permitindo fingerprint cego passivo, sem tocar a app no T7.
