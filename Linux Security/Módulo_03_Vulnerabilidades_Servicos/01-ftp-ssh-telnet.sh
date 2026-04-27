#!/bin/bash
# ==============================================================================
# Módulo 3: Vulnerabilidades em Serviços
# Aula 01 - FTP Anônimo, SSH Mal Configurado e Telnet Clássico
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# FTP Anônimo: É como uma geladeira na rua com a placa "Pegue ou Deixe algo, não
# precisa se identificar". Útil para panfletos, perigoso se alguém resolver 
# deixar uma bomba relógio (malware). 
# Telnet: É você falando no telefone com o banco na praça pública no viva-voz 
# para todo mundo em volta escutar o número da sua conta e senha.
# SSH Mal Configurado: É você trocar a fechadura da porta de casa por uma digital de 
# 10.000 reais (criptografia AES), mas deixar a senha padrão do fabricante "0000" 
# ou a chave da maçaneta debaixo do tapete.
#
# 2. O QUE É (definição técnica Senior)
# Vulnerabilidades de Serviço são as aberturas na Layer 7 (Application) onde softwares 
# nativos implementam seus próprios Handlers de Auth.
# FTP-Anon (21): O daemon (vsftpd, proftpd) permite login `anonymous` ou `ftp` usando um e-mail falso como senha. Expõe vetores de R/W.
# Telnet (23): Transacionais em Plain-Text (Sem TLS), sniffáveis via ARP Spoofing gerando clear-text credentials nas redes L2.
# SSH (22): Se configurado com `PermitRootLogin yes` e `PasswordAuthentication yes`, possibilita Bruteforce de Dicionário direto contra o superusuário. Além de vazamento de Private Keys mal armazenadas (IdentityFiles id_rsa).
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="127.0.0.1" 

# ==================== TELNET ==============================
# Detectar comunicação plain-text passivamente
# Um SysAdmin/Atacante usa o tcpdump (sniffer) na porta 23 para roubar a credencial live!
echo "[+] Ouvindo o Wire pra senhas puras em Telnet..."
# sudo tcpdump -i eth0 port 23 -A | grep -i "login\|password"

# ===================== FTP ================================
# Teste Ativo de FTP Anonymous
echo "[+] Testando Bypass de Auth FTP... "
# ftp -n $TARGET <<EOF
# user anonymous anon@pudim.com
# ls
# quit
# EOF

# ===================== SSH ================================
# O Ataque mais Real no mundo: Brute Force SSH via HYDRA!
# -l root: Especifica testar APENAS o username root.
# -P pass.txt: Fornece um arquivo das top 100 bad passwords.
# -t 4: Processos paralelos pra aceleração.
echo "[+] Iniciando Bruteforce Cego contra o Guardião SSH..."
# hydra -l root -P top100.txt ssh://$TARGET -t 4

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: O NMAP encontrou a porta 21 aberta FTP. Você testa: `nc IP 21`. Ele diz "220 (vsFTPd 2.3.4)".
# Passo 2: Você tenta o login anonimo via NMAP script `nmap --script ftp-anon -p21 IP`. 
# Passo 3: O NMAP vai listar q tem Read/Write lá. Você abre o cliente `ftp IP`, digita de username "anonymous" e enter pra senha vazia.
# Passo 4: Caiu na shell FTP. `ls -la`. Aí você vê a pasta "www" lá dentro, q é o diretório raiz do webserver Apache! Você dá um "put shell.php", o arquivo web PHP infectado upa liso. Escalonamento direto pro App-Layer RCE na porta 80 dpois!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Hydra demora e trava e derruba serviço bloqueado. Se tentar bruteforce na DMZ Real, após 5 erros, a porta 22 para sumariamente de responder e cai (Connection refused). O Blue Team ativou o Fail2Ban! Pentester inteligente usa Bruteforce distribuído em proxies rotativos ou explora falhas de chave (ex: Debian OpenSSL Predictable Keys CVE-2008-0166) em vez de adivinhação burra.
# 
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior temer um Telnet Open (Mesmo em roteadores Switch Cisco Layer 2 inofensivos da infra). A rede confia cegamente que Switches corporativos dão rota e drop pro DMZ do PABX/Voz. Se eu der o bypass com telnet sniffed em texto puro local e entrar de Admin do Switch, eu posso ativar "Port Mirroring" espelhando todo o tráfego do Servidor de Banco de dados pra MINHA porta de cabo... ou eu forço um broadcast storm de VLAN derrubando toda a companhia. "Mas a rede é interna, não tem hacker lá dentro!" -> Atéctica "Insider Threat" ou um celular android via wifi do cliente infectado.
# 
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu CTO removeu o telnet, desativou ftp anonimo e bloqueou root login no /etc/ssh/sshd_config (PermitRootLogin no). Você na auditoria entra na empresa via uma falha web com usuario 'www-data' super fraco q n tem permissão de nada... Mas na bagunça do host do Dev da maquina, vc descobre q na pasta /home/dev/.ssh/ existe um arquivo chamado `id_rsa.pub` e `id_rsa`. Como o SSH agora se tornou seu vetor de ESCALONAMENTO LATERAL contra outros servidores q você não tinha acesso web?"
# Resposta Esperada: O analista copiou ou gerou Asimetrically as Private Keys (`id_rsa`) de cliente sem senha passphrase. Essa infra deve usar Git ou Trust-Based entre máquinas (Dev pra Homologação automática). Com essa key roubada na minha mão no web-shell, eu verifico o `known_hosts` pra ver onde ele conectou antes... E executo um SSH Pass-the-Hash de chaves: `ssh -i /home/dev/.ssh/id_rsa dev@10.0.0.50`. E caio liso na outra máquina (pivoting e movimento lateral sem ter q saber 1 senha usando falha de Trust delegation SSH).
