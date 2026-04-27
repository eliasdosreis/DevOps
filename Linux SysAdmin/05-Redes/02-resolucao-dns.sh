#!/bin/bash
# ==============================================================================
# Aula 05.02: Rede - Tradução de Nomes (DNS, resolv.conf, hosts)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# A internet é uma Agenda Telefônica gigante.
# As máquinas burras do mundo todo só entendem NÚMEROS (142.250.70.0). Ponto.
# Mas O humano Elias jamais lembraria que o Netflix é "52.28...". 
# Então, O Linux "Liga" para uma Telefonista Terceirizada (O Servidor de DNS - Google 8.8.8.8)
# e pergunta: "Telefonista, me traduza google.com". 
# O servidor Master (Root Hint) devolve o número pra Máquina em Milissegundos e 
# o Ping avança pra porta correta!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Domain Name System (DNS) é um protocolo hierárquico, udp/tcp port 53.
# A Resolução de Nomes Local tem precedência estrita: O SO lê primeiro hardcoded 
# o arquivo `/etc/hosts` (A lista VIP do segurança). 
# Se não achar ali, aí sim ele dispara a Query pela placa de rede pro DNS Resolver Autorizado 
# apontado no `/etc/resolv.conf`. Esse é regido hoje por resolvedores Caching do 
# demônio `systemd-resolved` pra acelerar perfomance na Camada 7.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo) para mudar estado.

# O ARQUIVO DOS DEUSES: /etc/hosts
# Você construindo um site novo: Meusite.com.br mas o DNS oficial do BR não aprovou ainda seu dominio (vai demorar 2 dias).
# O Sênior ENGANA O LINUX! Ele edita o `/etc/hosts` com o VIM adicionando a linha:
# `192.168.1.55     meusite.com.br`
# O LInux NUNCA Vai buscar na Telefonista DNS pro meu_site. Ele Confia no arquivo Local e joga localmente!

# O OUTRO ARQUIVO DE OURO: /etc/resolv.conf
# Quem é o Roteador de DNS do qual O Meu linux é cliente e confia pra não tomar Golpe de Phising?
cat /etc/resolv.conf        # OBRIGATÓRIO: A saída tem a string mágica: `nameserver 1.1.1.1` (CloudFlare)

# FERRAMENTA MATADORA DE SYSADMIN PRA REDE: "DIG" (Domain Information Groper)
# Você tenta testar o banco de dados. "Falhou conectividade pro Banco".
# Você manda o carteiro bater no Domínio pra ver qual IP os gringos responderão hoje:
dig banco.empresa.com       # OBRIGATÓRIO: Mostra a Query de Tráfego completa da Árvore Autorizada!
# Ele mostrará o CNAME (apelidos da Amazon) e o A-RECORD IPv4 (O IP do destino).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] getent hosts servidor.local
# [O QUE FAZ] Como o Sênior sabe se a palavra 'servidor.local' bateu na Lista 
#             do Banco de Dados local Falsa (/hosts) ou atravessou a internet DNS Real?
#             A ferramenta Switch de NSS `getent` engole os dois sub-sistemas, resolve a
#             pergunta na hora simulando um software de sistema.

# [COMANDO] flush dns: systemd-resolve --flush-caches (ou resolvectl flush-caches)
# [O QUE FAZ] Limpa as falsas respostas oxidadas que a RAM do Linux guardou pra economizar ms.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - PING FALLANDO: Ping em "8.8.8.8" Funciona Impecavelmente. (A internet física existe!).
# - Mas Ping em "google.com" Dá erro `Temporary failure in name resolution`.
#
# Isso é "O Clássico Erro de Resolv". A porta 53 (Pacotes DNS) está bloqueada (Firewall do Datacenter)
# ou você mudou pra IPv6 Interno e o Resolvectl Não tem NAMESERVER apontado em `/etc/resolv.conf`.
# Se Pinga Número Mas não pinga Letra = Problema é A Telefonista do DNS!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# O "Bug da Falsa Resolução do LoadBalancer Cloud".
# A Equipe dev chora: "O Curl da máquina C pra API do Billing tá dando Timeout 504 no Ubuntu 22!!".
# Você abre o Nginx: Sucesso.
# Qual o problema Sênior? O Daemon "systemd-resolved" no mundo Nuvem cria um cache Agressivo
# Stubs pra acelerar as Queries na Layer 7 Lendo `/etc/resolv.conf` (Que agora é um symlink para `127.0.0.53`).
# Quando a Amazon EC2 destrói a API do Billing velha, a AWS vira a Rota pro IP Novo. 
# MÁS O SEU LINUX CONTINUA "CHAMANDO" O NÚMERO DE IP VELHO ENLATADO NO CACHE LOCAl DO RESOLVED!
# E ataca o Proxy morto! O Sênior reseta o daemon de Cache Local de Nome e desativa a retenção de CNAME.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você roda `cat /etc/resolv.conf`, adiciona com VIM a linha majestosa 
# 'nameserver 8.8.8.8' porque O DNS Parou de Funcionar, salva, e a internet mágica 
# Respondeu na hora!! Contudo, O Servidor precisou ser reiniciado (Reboot). E na
# reinicialização, a Falha de Letras Voltou, MÁGICAMENTE Alguém Apagou seu nameserver!"
#
# Resposta Esperada: "O erro foi tentar editar estaticamente um arquivo Dinâmico Pseudo-Gerenciado.
# No Ubuntu/Redhat recentes, o '/etc/resolv.conf' não é um arquivo físico, é um SymLink (Atalho Curto)
# apontando para `/run/systemd/resolve/stub-resolv.conf` em RAM Fria. Na inicialização do OS, 
# o NetworkManager ou o Service Resolved apaga TUDO que havia ali e 'injeta as regras corretas 
# fornecidas Por Netplan ou via DHCP Lease'. A linha deve ser obrigatoriamente declarada
# estática no código-mãe real do DHCP config (ou no `/etc/netplan/*`) e aplicado pra não sumir após Boot."
