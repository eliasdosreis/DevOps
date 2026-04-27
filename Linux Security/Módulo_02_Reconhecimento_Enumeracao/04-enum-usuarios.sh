#!/bin/bash
# ==============================================================================
# Módulo 2: Reconhecimento e Enumeração
# Aula 04 - Enumeração Avançada (Usuários RPC, Shares SMB Nulos, SNMP e BruteLocal)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Achou o serviço, descobriu como o forno funciona, agora você fuça pela frestinha pra ver 
# O NOME DO CACHORRINHO do morador pra tentar ganhar a confiança na engenharia social e 
# ligar no banco dele com login social. Usuários são O VALOR. Se você não consegue uma falha 
# estelar 0-day no "kernel de ouro" para abrir buraco na porta, pegue a chave da dona MARIA 
# das unhas que está usando uma permissão fraca e perdeu o crachá por senha default 'Admin123'. 
# Pra achar qual user eu preciso adivinhar a senha, vamos no Correio Mágico da Intranet (RPC MSRPC, 
# Sessões Nulas SMB, ou SNMP Público Comunitário) e pedimos: "Qual a lista de funcionários ativos aqui amigãozinho do guiche?"
# O Guichê bobo te entrega.
#
# 2. O QUE É (definição técnica Senior)
# O Enum de User e Shares extrai metadados valiosissímis expostas nas camadas da aplicação nativas dos S.O.
# SMB (Samba/Windows File Sharing RPC - portas 139/445): Legados até 2012 na mal-config permitem Sessions Nulas "Anonymous IPC$" para dump massivo da SA (Security Account).
# RPCBIND (111): EndPoint Mapper Unix das portas efemeras NFS.
# SNMP (161/UDP): Protocolo de Gerenciamento. Se a "Community String" estiver setada para "public", você dompa e lê as árvores da Management Info Base (MIB). A MIB guarda a RAM, CPUs rodantes, interfaces IP vivas, TUDO sobre software rodando. Quase uma visualização da Task Manager remota anonima para o Reconhecimento.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="127.0.0.1" 

# Ferramenta pilar para SMB Null Sessions em Unix / Samba Pentests: `enum4linux`
# Faz uso do samba (smbclient/rpcclient na bagagem) para pingar RPC endpoints.
# -A => All. Enumera Users, Shares Mapeados Ocultos ($), Grupos Domain Admins e Política Máx Pwd
echo "[+] Enumerando Windows Services / SMB SAMBA shares com Enum4Linux_..."
# enum4linux -A $TARGET

# Utilitando smbclient direto. Sem conta, tentamos o login do "anonymous login vazio no share \IPC$".
echo "[+] Checando Compartimentos Exportados abertos manualmente..."
# smbclient -L //$TARGET/ -N   # (-N indica No Password do prompt).

# SNMP Enum (Comunity String 'public', versão snmp de proto v2c - legada mas mega usada hj).
# O snmp-check formata em relatório bonito a MIB lida se der sucesso. As infos listam:
# processos mortos, network shares, rotas estáticas internas...
echo "[+] Extraindo Network Trees via UDP Management com snmp-check..."
# snmp-check -c public -v 2c $TARGET

# Enumeração Pura a Partir de Ferramentais LDAP e NMAP RPC:
# Para nfs shares vazados (Unix Network File Systems nas portagens 2049 atrelada do mapeador antigo)
# nmap -p 111 --script=rpcinfo,nfs-showmount $TARGET

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: O NMAP lhe cantou que as portas 139 e 445 abalam e estão vivas. 
# Passo 2: O Samba tá virado prum Linux na DMZ corporativa. Rode `smbmap -H <IP>`.
# Passo 3: Imagine a output do smbmap lhe cuspindo: `[+] Share: \TI_Backup_Admin  READ ONLY`.
# Passo 4: Jackpot. Você acabou achando acesso de leitura a um FileShare de Backup mal protegido não-rootado de guest. E pode dar download via `smbclient //$IP/TI_Backup_Admin -N` , e usar `get banco.db` pro seu HD e analisar os hashes de TI de infra do domínio. Brute force local neles finaliza o exploit chain offsite!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Em caso de Connection Refused no samba SMB/139 445 ou erros de dialect como "NT_STATUS_ACCESS_DENIED", As versões do W10 recentes e Server 2019 de MS impõem mitigação agressivas que derrubam NTLMv1, desligam a Anonymous IPC session com flags fortes, e removem suporte do protocolo frágil de Dialeto SMBv1 (WannaCry Vetor). Ferramentas legadas do kali 2015 não conversam mais. Se enum4linux feio travar, você pula para os enums python moders com impacket toolset `rpcclient -U "" -N <ip>` !
# 
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro enum rpc port-mapper (TCP/UDP 111) num servidor Linux valer peso de Ouro. O NFS / RPC unix não possui autenticação forte acoplada nas camadas inferiores como o Windows Kerberos da floresta AD. A regra de segurança do NFS `/etc/exports` é bizarramemente estúpida limitando por IP. Eles fazem: `/pasta_secreta  10.0.0.*(rw)`. Tudo de lá é exposto a toda lan daquele subnet! Pra piorar, o NFS mapeia ownership pro mesmo UID do atacante do kali!!! Se for um Share montado e Exportado com a flag insegura brutal chamada `no_root_squash`, eu do meu Linux Ataque, crio uma pasta chata. Escrevo um arquivo C compilado contendo código exploit na lib C maliciosa com setuid "s". Envio o aquivo rootado pra dentro dessa minha pasta share na nuvem. Então, um administrador bobão entra por SSH e executa pra testar meu file root e PUM, a shell reverter me devolve com poder superAdmin. Escalonamento em 2 steps e 1 infra bugado de DevOps de Terraform.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu Enum4linux retorna `[E] Server doesn't allow session using username '', password ''`. O SysAdmin removeu Guest Shares. Então não posso pegar a lista de Usuários, estou em dead-end pra Forjar força Bruta Remota em senhas de VPN SMB do Active Directory?"
# Resposta Esperada: Se MSRPC tá fechado, não estamos num Dead-End! Nos dominios Windows com OWA Outlook ou Servidores Kerberos Portas (88 udp) de KDC, é possivel explorar e extrair via técnica de AS-REP Roasting ou usar `kerbrute userenum nome_empresa_wordlist.txt`. O protocolo Kerberos permite enumeração dos Kerberos Pre-Auth AS-REQ! Se o TGT me devolver erro code diferenciado pro hash criptado, é veridico meu brute da wordlist local e achei user valido com 1 click. Se devolver e nao pedir preAuth é pior: ganho os hashes na via pro john ripar e ser domainadmin!
