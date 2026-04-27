#!/bin/bash
# ==============================================================================
# Aula 05.04: Rede - Hardening Sênior com SSH (Chaves, Arquivo Config)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Vimos que o SSH é o Metrô Subterrâneo Secreto na Aula 0. Porém, ele tem Portas 
# gigantes que dão pra rua. Hardening (Endurecimento Militar) significa blindar essas
# saídas pra que, mesmo se alguém souber a senha master "123mudar", seja
# FÍSICA E MATEMATICAMENTE Impossível a entrada não autorizada.
# Hardening = Transformar fechadura comum Biológica num Scanner de DNA Digital .

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O Daemon (Demônio de background) chamado `sshd` opera pela configuração universal 
# residente em `/etc/ssh/sshd_config`. Hardening corporativo reescreve chaves Host
# ECDSA e ED25519 elípticas removendo as DSS velhas velhas DSA Inseguras.
# Além de revogar Autenticação via Teclado e Bloquear Escalada de Root via TCP Bruto,
# trocando Senhas puras pelo modelo PKI (Public Key Infrastructure) Assimetrico Autorizado.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# O FLUXO DE OURO DO SYSADMIN PARA CHAVES SSH! (Executa isso do PC ClIENT WIN).
# O Sênior Roda no Windows 11 dele antes de logar: (Isso gera o "DNA/Cadeado").
ssh-keygen -t ed25519 -C "elias_key_windows_note_pro"
# (Ele cria DUAS chaves: id_ed25519 [A Privada Secreta], e id_ed25519.pub [O Cadeado]).
# Ele agora manda a FECHADURA (O Pub) pro cofre autorizado do servidor Linux la na AWS:
ssh-copy-id elias@192.168.1.55         # OBRIGATÓRIO (Envia via sftp automático a Pub e cadastra lá).
# AGORA O ELIAS DO WINDOWS LOGA no LiNUX SEM PRECISAR DE NENHUMA TECLA DE SENHA PRA SEMPRE MÁGICAMENTE!

# ===== APLICANDO HARDENING NO LINUX DA EMPRESA EM SI =====
# Agora no Servidor, o Operador Root DESTRÓI a porta de hackear.
# Edite religiosamente o ARQUIVO: `sudo vim /etc/ssh/sshd_config`.
# Modificadores de Vida ou Morte (Encontre eles no config longo e Troque o valor):

# Regra 1: "Desabilita que o cara logue com senha na mão de bruteforce".
# PasswordAuthentication no         # NINGUÉM entra mais por teclado. SÓ DNA (Chave Pub registrada).

# Regra 2: "Bloqueia o ROOT SSH direto". (Sabe o `ssh root@ip`?? Nunca Permita!).
# Mande Hackers tentarem chutar nomes obscuros no lugar da previsilididade "root:root" admin.
# PermitRootLogin no                

# Regra 3 (Opcional Paranóica): "Troque a 22 padrão".
# Hackers scaneiam massivo porta 22 do mundo todo.
# A porta 65121? Invisível pros "Shodan Bots".
# Port 65121                   

# PRA FECHAR O CIRCUITO: 
systemctl restart sshd              # Reinicia o Demonio. Tchau Hackers!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] cat ~/.ssh/authorized_keys
# [O QUE FAZ] No /home de todo usuário, existe uma pasta oculta `.ssh`.
#             Esse arquivo Guarda todos os "Fechaduras PUB" dos amigos e Pcs do Elias em Texto Sujo Exposto.
#             Se a fechadura da chave Privada Dele Casar Criptográfica Pura com uma
#             dessas Strings de 700 bytes, o PAM abre a porta Local pra ele Entrar SSH.
#             Sempre audite esse arquivo para ver se não deixaram chaves Ex de Devs Demitidos vivos alí.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Criei Chaves ED25519! Desativei o Uso de Senhas! Reiniciei O Servidor SSH! 
# E Quando meu DEV "Jorge" foi entrar na maquina, e deu "Permission denied (publickey)".
# E O SISTEMA NÃO DEIXOU ELE NEM TENTAR TECLAR A SENHA E EXPULSOU ELE DA RUA!
#
# O Erro de Hardening mais Frequente do Universo é PERMISSÃO da Pasta Invisível!
# O Daemon SSHD é PARANÓICO por segurança nativa do Posix!
# Se o Jorge tiver criado o `.ssh/authorized_keys` com permissões bobas de chmod 777.
# O SSHD se Recusa A ler CADEADOS QUE TEM PERMISSÃO frouxas!
# A Solução: 
# `chmod 700 ~/.ssh`  E DEPOIS  `chmod 600 ~/.ssh/authorized_keys`  E DEPOIS DA UMA DE DONO `chown -R jorge:jorge ~/.ssh`!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Proxying the Tunnel Inception (A Magia JumpHost do Bastion).
# Numa Arquitetura Nuvem Perfeita (AWS VPC), O Servidor de Banco de Dados de Produção
# **NÃO TEM IP PÚBLICO** E NÃO VÊ A INTERNET. IMPOSSÍVEL DO MUNDO PINGAR ELE.
# Como O SysAdmin da Cadeira do PC DELE acessa o "DB do Core" pra consertar Erros as 4AM?
# Ele usa um PULO DA ARANHA DE TUNELAMENTO. A máquina Bastilha Exposta (A FrontEnd). O Jump de Tráfego:
#
# Comando Pleno: (Login Sujo PingPong Manual)
# ssh servidor_bastiao (Da Enter, ta nele) -> Do bastiao Roda: ssh banco_10_interno_privado (Ta Nele).
# Comando SÊNIOR com Forward Proxy TCP de Confiança: (Tudo pelo Terminal Nativo)
# `ssh -J admin@bastiao.publico.com elias@10.0.1.55` 
# MÁGICA (-J = Jump). O tráfego VOA pelo Bastion Transparente, Criptografando "End to End" Local->Banco sem 
# Decriptar/Largar as chaves privadas vulneráveis na máquina do meio exposta aos chineses.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Houve um desligamento corporativo massivo de CTOs da filial EUA.
# Queremos que qualquer SSH estabelecido ou dormindo na Camada TCP/IP de ROOT daquelas máquinas 
# que foram feitos HOJE Cedo sejam DROPPADOS E FECHADOS de Imediato nas Mãos dos caras! O Restart The SSHD e 'Block Passwords' vai Expulsar as Shells Ativas Que
# Já Conseguiram Atravessar Portas no SO?"
#
# Resposta Esperada: "Negativo. O 'systemctl restart sshd' apenas finaliza o Daemon Escuta Padrão
# Pai, impedindo NOVOS SYN FLAGS Handshakes Entrarem. Para 'Matar a Shell Conectada' daqueles
# Devs Hostis imediatamente de dentro do SO em Tempo de Guerra de Retenção a Resposta Sênior 
# é encontrar e Despachar SIGKILL Nos PIDS Forquilhas! Utilizaríamos `pkill -9 -u CTO-Demitido sshd` ou,
# sendo letal nos logs para todos não root atrelados: `killall -9 sshd`."
