#!/bin/bash
# ==============================================================================
# Aula 00.02: Preparação do Ambiente - Primeiro Acesso via SSH
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Imagine que instalar a VM foi construir o prédio do seu servidor. 
# O SSH é como um "túnel blindado e subterrâneo" exclusivo pelo qual você viaja 
# da sua casa (seu computador pessoal) até o seu prédio (o servidor) de forma
# totalmente invisível e segura. Sem o SSH, você teria que ir fisicamente
# até o teclado e monitor do servidor toda vez que quisesse fazer algo.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O Secure Shell (SSH) é um protocolo de rede criptográfico que permite a operação 
# segura de serviços de rede em uma rede não segura. Substituiu alternativas 
# arcaicas e inseguras, como Telnet e rlogin, que transmitiam credenciais em 
# texto plano (plaintext), permitindo interceptação (sniffing). Na porta TCP 22,
# o deamon sshd aguarda conexões.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# Abaixo comandos que você executará no seu terminal Windows (PowerShell) para
# acessar com segurança sua nova Máquina Virtual Linux recém-criada:

# Pega o seu nome de usuário criado na instalação da VM (ex: elias)
# e o IP que a sua VM pegou na rede (descubra digitando 'ip a' na VM local).
# O parâmetro `-p` (porta) só precisa ser especificado se não for a porta padrão 22.
# 
# sintaxe: ssh [usuario]@[ip-ou-dominio]

# ssh elias@192.168.1.50   # OBRIGATÓRIO: Forma padrão de logar em um servidor novo.

# O sistema perguntará se você confia na "impressão digital" (fingerprint) desse servidor.
# Digite 'yes' e aperte Enter. Depois informará: "Password:". 
# Dica de segurança da tela: ao digitar, a tela do terminal do SSH não mostrará NADA.
# Não aparecerão asteriscos (*). Continue digitando cego e aperte Enter.

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# 1. Cópia Prática de Chave Pública (Passwordless Delegation natural)
# Ao invés de você usar 'cat' e colar sua chave pública manualmente lá no Host,
# utilitário Sênior empurra a chave de modo autônomo (digite a senha apenas essa última vez):
# ssh-copy-id elias@192.168.1.50    # SALVA-VIDAS: Injeção automática segura de PKI.

# 2. Configurando o Atalho Ninja (~/.ssh/config)
# SysAdmins não decoram IPs de 50 servidores. Nós ensinamos o ssh a criar "apelidos".
# Se você tiver um arquivo local na sua máquina física em `~/.ssh/config` escrito:
# 
# Host bd-prod
#     HostName 192.168.1.50
#     User elias
#     Port 22
#
# A partir desse momento, de qualquer terminal seu, bastará digitar:
# ssh bd-prod                       # SALVA-VIDAS: Conecta instantâneo direto para o servidor alvo.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] ssh elias@192.168.1.50
# [O QUE FAZ] Inicia o handshake criptográfico com a porta 22 do servidor .50
# [SAÍDA ESPERADA] "Are you sure you want to continue connecting (yes/no/[fingerprint])?"
# [O QUE FAZER SE DER ERRO] Se disser "Connection refused", o OpenSSH-Server não 
#                           está instalado lá. Volte para a VM e instale:
#                           sudo apt update && sudo apt install openssh-server -y

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# Como confirmar que funcionou? 
# O seu terminal do PowerShell (que geralmente diz `PS C:\Users\Elias>`) mudará
# e ficará verde (no Ubuntu) escrito `elias@Lab-Linux-SeniorUbuntu:~$`. Você
# oficialmente está dentro do servidor! Para sair do túnel, basta digitar `exit`.

# ERROS COMUNS:
# - Connection Timed Out: Significa que a sua rede local (Windows) não achou a
#   rede da sua VM. Geralmente ocorrem problemas de firewall, ping desativado, 
#   ou sua VM está em NAT e não em Modo Bridge.
# - Permission Denied: Você digitou a senha errada ou errou o nome de usuário.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Um nível Pleno se contenta em logar com SSH jogando Senha repetidas vezes.
# O **SysAdmin Sênior** DESABILITA completamente o login por senha no servidor.
# Senhas sofrem ataques de Força Bruta (Brute-Force) ou dicionário o dia todo.
# Um Sênior acessa o servidor usando um PAR DE CHAVES CRIPTOGRÁFICAS (RSA/ED25519).
# Ele gera as chaves (`ssh-keygen`), coloca a chave pública (o cadeado) no
# servidor, e guarda a chave privada com ele. Quando o SSH bate no servidor, 
# se as chaves se encaixarem, o login ocorre sem digitar senha alguma, 
# impossibilitando matematicamente invasões comuns. Veremos isso no mód. Segurança.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você percebeu alertas de múltiplos logins remotos fallhos nos 
# logs de um dos nossos servidores expostos na porta 22 pro mundo, tentando adivinhar
# as credenciais do nosso usuário ROOT. Como você mitiga isso imediatamente, sem
# bloquear nossos desenvolvedores de continuar o deploy via SSH?"
#
# Resposta Esperada: "Primeiro, devemos editar o arquivo /etc/ssh/sshd_config 
# e alterar a diretiva 'PermitRootLogin' de 'yes' para 'no', bloqueando o acesso 
# direto ao usuário master (root). Em seguida, devemos forçar 'PasswordAuthentication no', 
# obrigando a autenticação exclusiva baseada em chaves (Public Key Infrastructure). 
# Para controle dinâmico que impede ataques contínuos (flood), instalamos e ativamos
# um software como o 'Fail2Ban' para dropar temporariamente o tráfego via firewall 
# do IP do atacante após X tentativas mal sucedidas."
