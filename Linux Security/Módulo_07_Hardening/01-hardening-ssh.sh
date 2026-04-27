#!/bin/bash
# ==============================================================================
# Módulo 7: Hardening e Remediação
# Aula 01 - Configuração Segura de SSH (O Bastião da Defesa)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Hardening é transformar um "Carro Civil" num "Carro Forte Blindado Diomand".
# E a porta de entrada desse carro é o SSH. Uma porta civil de SSH tem Maçaneta  
# e usa chaves Clic, onde qualquer um pode tentar a chave do mestre Root.
# A porta Blindiada Sênior, em contrapartida: Ela RETIRA O BURACO DA CHAVE (sem Password),
# ela ignora a pessoa chamada "Root" se bater lá (NoRootLogin), ela muda de porta do 
# corredor 22 pro corredor 5722 pra q os robos burros não achem, e se uma câmera ver vc
# tocando 3 vezes na porta e errando a bio-metria, te dá um choque tazer 
# de firewall ativo pra te banir eternamente (Fail2Ban/IPS).
#
# 2. O QUE É (definição técnica Senior)
# O OpenSSH é cronicamente a suite mais confiável desde os anos 90, e a que mais 
# expõe a empresa não por erros de Zero-Day de protocolo, e sim por Defaults Fracos.
# Hardening de SSH baseia-se em Desligar as flagas inseguras nativas e estipular Crypto-Curves 
# restritras pro algoritmo de hash (Drop de sha1 ciphers obsoletos).
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# ==================== O MANUAL DE DEFESA SSHD ====================
# Editar: /etc/ssh/sshd_config 

# 1) Desligar o ROOT cego por password de fora:
# Se invadirem, terão de hackear um joaozinho fraco da maquina, P/ SÓ dpois TENTAR SU ROOT localmente!
echo "[+] Bloqueando Login Direto Root Remoto..."
# sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 2) Forçar "SOMENTE CHAVES". Senhas vazam, chaves Ed25519 encriptadas por TPM não.
echo "[+] Desligamento Mortal de Prompt de Senha via SSH (PasswordAuthentication no)..."
# sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# 3) Desliga Auth PAM (Usada em ambientes sem 2FA que pode ser brute-forced)
# sed -i 's/^UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

# 4) Restart do Demon pra acatar 
# sudo systemctl restart sshd

# ================= Fail2Ban: IPS Simples ====================
# Hackers da china rodarão Bruteforce de IPs aleatótias. 
# "Instrua o Firewall Linux (Banir e Dropar o IP invasor) por 1 hora se ele falhar 5 vezes SSH log".
echo "[+] Instalando Guardião Ativo HIDS..."
# sudo apt install fail2ban -y
# sudo systemctl enable fail2ban

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: No seu bash local, Gere sua Chave Física Indecifrável Curva Eliptica: `ssh-keygen -t ed25519` .
# Passo 2: Exporte pro servidor CDE (Copy Id): `ssh-copy-id -i ~/.ssh/id_ed25519.pub sysadmin@IP`.
# Passo 3: Logue sem senha! Funciona. (Sua key foi escrita em ~/.ssh/authorized_keys no server).
# Passo 4: AGORA E SÓ AGORA... Vc edita o sshd_config atirando a config final de hardening "PasswordAuth no". Se você alterar o No Password *antes* de testar a chave, vc perdr o root dele server e ficará Trancado fora da tua propria maquina corporativa num lock down eterno! 
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Problema: SysAdmins trocam a "Porta 22" pra "Porta 2222" achando q isso é segurança (Security Through Obscurity).
# Resultado p Senior: Nmap Stealth acha o port sshd em 2 segundos! A alteração de porta só tira ruído do log (Impede Script Kiddies de Hydra automatica basica via shodan pq n procuram p cima). NUNCA Substitua chave Pub+Priv forte por mera troca de portas na confiuração de Cloud SG/AWS.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior desligar também o `X11Forwarding` e o `AllowTcpForwarding no` no `/etc/ssh/sshd_config` ! Uma config com porta liberadiça de SSH confia na encriptacao. Mas se a máquina SSHD foi comprometida por um user bobo (Desenvolvedor JR q botou key vazou no git). Se o X11 Tiver ON, o hacker consegue Tunnelar gráficos de Janelas GUI Locais dele pelo túnel pra tua maquina dev. E se o AllowTcpForwarding estiver ON (Padrão perigoso!!), O HACKER NEM TENTA ELEVAR PRIVILEGIO, ELE USA o seu SSH pra ser "VPN/Proxy" Pivoting livre DENTRO da tua subnet (`ssh -D 1080`) e ele Ataca AS OUTRAS maq da REDE AWS usando túnel SSH nativo SOCKS! Desligue encaminhamento em servs de salto!
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu arquivo /etc/ssh/sshd_config está estrito como rocha (PassworAuth no) sem keys, root proibido, porta escondida. MAs vc recebe um audit warning do compliance q diz 'Seu servidor Ubuntu 18 suporta Chave RSA e Algorítimos Diffie Hellman Group14 (sha1)'. Como vc garante blindagem matematica absoluta Cifra Militar pros bancos q só aceitem Curvas Avançadas recusando hand-shakes legados velhos?"
# Resposta Esperada: No Hardening de SSH Sênior nós incluímos explicitamente as tags KexAlgorithms, Ciphers e MACs forçando Cypher Suites rígidos na config. Ex: Eu limito o Cipher a usar GCM apenas : `Ciphers aes256-gcm@openssh.com` e O KEX de curva `KexAlgorithms curve25519-sha256@libssh.org`. Se o cliente for um linux mt velho q so sabe negociar SHA1 o meu servidor DÁ REJECT no hello e droppa tcp. A forquillha cripotgrafica impede Man-In-the-middle matematicos decriptaveis c qtum c.
