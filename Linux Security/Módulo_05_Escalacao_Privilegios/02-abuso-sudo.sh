#!/bin/bash
# ==============================================================================
# Módulo 5: Escalação de Privilégios (Privesc)
# Aula 02 - Sudo Mal Configurado (O Perigo do ALL=(ALL) ALL)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você comprou uma lancha em nome da empresa para negócios. Você passa a procuração 
# para o Capitão que diz: O capitão pode assinar os cheques apenas com fornecedores 
# da área naval e nada mais. Isso é a "Configuration Sudo" boa.
# Sudo mal configurado é você escrever na procuração legal (Sudoers): "O capitão pode assinar
# como meu nome e cpf pra comprar peças navais... e AH, EU ESQUECI as cláusulas restritivas, dane-se, o
# capitão ta liberado a ser eu 100% livre.". O capitão entra no Sudo do banco e vende sua empresa inteira pra ele mesmo. 
#
# 2. O QUE É (definição técnica Senior)
# O sub-comando `sudo -l` (list) revela nossa mão restritiva perante a flag NOPASSWD e as entradas no `/etc/sudoers`.
# A principal quebra (PrivEsc) local em caixas HackTheBox e exames OSCP/CPTS é baseada no mal entendimento e 
# na ausência da sintaxe granular sobre "Comandos Permitidos vs Interpretação" que o pam-sudo possui.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# O PRIMEIRO COMANDO DE TODO CTF / AUDITORIA DE PENTEST INTERNO
# "Quem eu sou?"
# "O que eu Poso fazer de mágico Sem Ter que roubar?" 

echo "[+] Revelando o Visudo Rules do meu usuário vivo:"
# Tente sudo -l. Na sorte, se vc não tiver NOPASSWD setado nas configs, ele mandará dar enter pedindo auth no prompt da tua SENHA, e voce tem log de keylogger pra prosseguir. Mas digamos q n precisa.
# sudo -l 
# ======== EXPECTED OUTPUT MALICIOSA ========
# User pablo may run the following commands on svr2:
#   (root) NOPASSWD: /usr/bin/cat
#   (root) /usr/bin/less /var/log/apache2/*.log
# ========================================

# EXPLORAÇÂO DO GTFObins COM SUDO:
# Com base na falha do CAT acima. Pelo amor de deus, eu agora como pablo rodo:
# sudo cat /etc/shadow
# E pego o hash do próprio root de gracia no sudo. E meto pro JOHN the ripper na makina attacker!

# Exploção de Environment (Env_Keep Flag) do sudo:
echo "[*] Vendo sudo vars mantidas pela conf errada (requiretty falso)..."
# Um Sudo com Defaults env_keep += "LD_PRELOAD" ou "LD_LIBRARY_PATH" 
# vai jogar nossa biblioteca dinamica (Aula04 path hijack dpois) na RAM e foder td como root process em exec.


# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Vc descobriu que sudo -l diz: `(root) /usr/bin/less`. (O comando Less é p/ visualizar log grandes em vim screen.)
# Passo 2: O Sudo ali disse "ok, pablo pode olhar os logs the apache SEMPRE Q QUISER, porque ele tem a missao de debugar erro!". Legal né?
# Passo 3: Mas quando voce roda o LESS "como root" `sudo less /var/log/apache2/access.log`.
# Passo 4: O less é incrivel interativo! Lá dentro pra "procurar", vc pode digitar `!`. 
# Passo 5: Digite: `!/bin/sh`. O Root-invocado Pager Less atende a string `!` pro OS nativo bash e abre a shell filha! E pablo cai no `#` Root Prompt de graça na quebra de GUI! O DevOps configurou o SUDO pablo mas ignorou pesquisar PAGING programs na doc do Unix de 1999 q todos os vizualisadores de txt tem função built in de invoke em bash!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Em muitas ocasioes tu roda o exploit e o Sudo te atira "Sorry, user dev is not allowed to execute as root". A linha do sudo dizia `(joao) NOPASSWD` e você é pablo e não joao! Na duvida o `/etc/sudoers` trabalha em 4 vertentes de parse: (Quem Roda) ServidorMaquina = (Como quem Pode Executar : Group que Pode Executar) Comando permitido. Sempre se atente quem é você no "RunAS" antes de assumir e usar "sudo cmd". Se tu tiver liberado pra dar "joao", vc dá `sudo -u joao cat x`.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior banir flag "ALL" nas tags finais e proibir editores e paginadores via sudo list. A política rígida pra Scripts Admin Shell `.sh` de automação da cloud diz "Apenas rode o script XYZ, sem paramentros" e escreve O Caminho Absoluto pra não ter buracos. Mas pior! Tem gente que no visudo da empresa adiciona: `(root) NOPASSWD: /bin/cat /var/log/syslog *`. ELE COLOCOU O WILDCARD `*` NA REGRA DA ROTA DE FIM do nome!. Ele achou que era pro cara dar cat de arquivos de log do passado tipo log2.tar. Mas pq o WILDCARD aceita caracteres especiais como string cega de input... Um hacker logado lá lança `sudo cat /var/log/syslog ../../../../etc/shadow` e a regra do visudo parseia tudo depois de syslogs como TRUE pro Regex dele na memora pam.so e libera a quebra Path Traversal via Parametro pra ler os cofre! Sempre limite Regex forte sem Curingas * em regras visudo pro client-space.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se sudo é tao foda... Uma vez nas vulnerabilidades monstras de 2021 de mem corruption, acharam q mesmo a empresa removendo NOPASSWD do sujeito, ele usava um erro interno de integer overflow no Sudo parser CVE Baron Samedit (CVE-2021-3156) onde o atacante forjava o Argument Index `-s`. Se você assumir o Linux, sem poder dar Sudo, sem hash, OQ tu faz correndo no lab local de maquina DMZ desprotegida?"
# Resposta Esperada: No Samediit Heap-Based Bof, Como o sudo foi codado pra 'escapar' a barra antes de backslash no env `sudoedit -s \`. Eu executo uma proof-of-concept payload de C++ pra causar heap overflows no parser de variavels enviromnet dele q ele devia ler de forma sanitizada. Esmago e escrevo meu ponteiro falso atirando p um lib so. É root universal pra 99% caixas velhas < 1.9.5 de graça! 
