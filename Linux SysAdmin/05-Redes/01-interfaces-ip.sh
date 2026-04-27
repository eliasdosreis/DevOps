#!/bin/bash
# ==============================================================================
# Aula 05.01: Rede - Configuração de Interfaces (ip, nmcli, netplan)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# O Servidor é uma fortaleza gigante (Castelo). Ele não tem comunicação nativa
# com a casa dos desenvolvedores. Ele precisa de uma "Ponte Levadiça".
# No Linux, essa "ponte" levadiça é a Placa de Rede (Interface de Rede: `eth0`).
# O Comando `ip` do Linux diz "Baixe a ponte, deixe o TCP/IP entrar Onde e Como".
# O Endereço IP é o CEP Postal exato dessa ponte pro carteiro de pacotes achar.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Interfaces virtuais e físicas residem na subcamada MAC do Kernel. Tradicionalmente
# chamadas de `eth0`, `eth1` (Ethernet). Modernamente o systemd injetou nomes
# baseados na topologia Pci-Express Pra Impedir Mudança de Ordem, nascendo os 
# nomes esquisitos de servidor (enp3s0, ens160, wlp2s0).
# O utilitário `ifconfig` da suíte Net-Tools FOI DEPRECIADO em 2005. O Sênior 
# gerencia a pilha TCP/IP 100% via pacote IProute2 (Comando `ip`).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo) para mudar estado das placas.

# VER SEU IP AGORA (O Famoso "Me dê seu IPv4")
ip addr show                # OBRIGATÓRIO: (Muito Sênior digita apenas `ip a`). Mostra MAC e CDIR.

# DESLIGAR A PONTE LEVADIÇA NA MARRA.
ip link set eth0 down       # MODO DE EMERGÊNCIA (Corta Ping, SSH e a internet inteira do server na hora).

# CONFIGURAÇÃO PERSISTENTE (Após o Reboot). O Comando "IP" MORRE no boot.
# - No MUNDO RHEL/CentOS: A placa mãe usa o NetworkManager (nmcli).
#   `nmcli con mod eth0 ipv4.addresses 192.168.1.10/24`
#   `nmcli con up eth0`

# - No MUNDO DEBIAN/UBUNTU (Moderno): Usamos o Arquivo YAML do Netplan.
#   `cat /etc/netplan/00-installer-config.yaml`  (Edita o IP puro lá dentro)
#   `netplan try`  (Pra testar se você não errou os espaços da Config)
#   `netplan apply` (Aplica de verdade as rotas no Kernel).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] ip route show
# [SAÍDA ESPERADA] default via 192.168.1.1 dev eth0 proto dhcp metric 100
# [O QUE FAZ] (ip r). A Tabela de Roteamento. Responde a pergunta de ouro de Rede: 
#             "Por Qual Porta Física Mágica a Minha Internet sai pra falar com o Google? (Default Gateway)".

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO CATASTRÓFICO "Perdi O Servidor Remoto!"
#   Você editou o arquivo `/etc/network/interfaces` ou `/etc/netplan/..yaml`.
#   Por um erro de digitação, colocou `192.1.10/24` sem faltar o "168".
#   Você roda `systemctl restart network` (ou netplan apply). 
#   Na mesma hora, o PuTTY da tela PRETA. "Conexão Fechada". 
#   Você perdeu a comunicação SSH do Datacenter em Chicago.
# 
#   É por isso que as Ferramentas Novas (Netplan Try) dão "60 Segundos" de Revert Automático.
#   Os Gênios Sêniores Nunca aplicam "reinício total de rede CEGO" via SSH sem testar 
#   uma porta paralela antes ou usar `screen / tmux`. E sempre agendam `shutdown -r +5`
#   (O PC se mata daqui 5 minutos revertendo modificacoes não salvas do disco se você perder acesso).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Por que a interface `lo` (Loopback / Localhost 127.0.0.1) Jamais cai?
# O Júnior instala o Docker, aponta pro IP do servidor "192.168.1.55" e chora
# quando a placa de rede reinicia e o banco de dados quebra.
#
# O Loopback interface é a Camada TCP/IP Virutalizada 100% DE DENTRO DO CHIP DA CPU.
# Ela não obedece cabo de rede. Não depende de Roteador do Provedor. 
# Softwares Sêniores (Banco de Dados, Redisl, Workers) conversam uns com os outros
# localmente Exclusivamente pela Loopback (127.0.0.1 porta 3306), ignorando 
# as placas de rede Enp3s0 do mundo externo, garantindo 0 milissegundos de latência em IPC sockets tcp.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa colocar provisoriamente DOIS IPv4 diferentes na mesma 
# Máquina (eth0), pois ela vai atuar temporariamente de Ponte Proxy Recebendo Trafego
# da subrede A (192.168.0.x) e da subrede B (10.0.0.x). Como engatilha o IP Secundário "On the Fly" sem derrubar nada?"
#
# Resposta Esperada: "Usando a ferramenta limpa do IPRoute2 atrelando um Virtual IP Alias
# na interface primária em RAM: `ip addr add 10.0.0.50/24 dev eth0`. Diferente 
# da época sombria do ifconfig que exigia nomear devices subficiais como `eth0:1`, o 
# comando IP simplesmente anexa Vários IPs Secundários na array da própria placa real.
# Confirmaríamos com `ip a` e removeríamos depois com `ip addr del ...`."
