#!/bin/bash
# ==============================================================================
# Módulo 1: Fundamentos de Segurança Linux
# Aula 03 - Gestão de Usuários e Sudo (/etc/passwd, shadow, sudoers)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Pense no `/etc/passwd` como a "Lista Telefônica Branca" que diz o nome 
# dos funcionários do prédio, seus andares de trabalho, e seus crachás numéricos (UIDs). 
# Em contrapartida, `/etc/shadow` é o gigantesco cofre selado biometria forte onde 
# moram os espelhos iris (Hashes de senhas). Tem que ser fechado e trancado apenas
# para a segurança do prédio. O `sudoers` são as Portarias Especiais: autorizações de 
# quem tem permissão explícita para pegar "a arma da polícia e usar para matar um processo".
#
# 2. O QUE É (definição técnica Senior)
# O modelo de Identidade de usuários e elevação discricionária no Linux.
# - `/etc/passwd` (Perm 644 - leitura universal): Mapeamento de username para UID/GID e Home.
# - `/etc/shadow` (Perm 600 ou oculto): O arquivo dos hashes (geralmente algoritmos sha512 ou yescrypt como $6$ / $y$) e controle de expiração cronológica.
# - O `sudo` é um binário (com SUID) atrelado estritamente à polícia de configuração
# chamada `/etc/sudoers`. Define granulas com sintaxe precisa de que o User X 
# pode executar o comando Y sem fornecer a senha da raiz original.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo/Informativo: Mostrar os usuários ativos e serviços com "Shell Logável" real
# O grep /bin/bash (ou sh, zsh) ignora usuários falsos como "sync" ou "daemon" que
# tipicamente devem ser restringidos com `/bin/false` ou `/usr/sbin/nologin`.
echo "Usuários de carne e osso no sistema:"
grep -E "bash|sh|zsh" /etc/passwd

# Ofensivo: Auditoria e Brute-Force Local de Hash
# Muitas vezes o root esquece senhas, mas um Sênior sabe extrair as linhas do 
# /etc/shadow, un-shadow as entradas, e jogar pro JohnTheRipper ou Hashcat.
# Como root (sudo), tentamos visualizar os usuários que POSSUEM hash instalado.
# root:* significa bloqueado; mas um root:$6$hGg... significa hash real configurado.
# sudo cat /etc/shadow | grep "^\w*:[^\*!]"

# Auditoria Sudo: "O que o meu usuário atual pode rodar como administrador?"
# Extremamente vital num teste de Pentest para Escalonamento (PrivEsc)
echo "Minhas permissões Sudo (podem requerer minha propria senha atual):"
sudo -l

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Visualize o formato do `/etc/passwd` com `cat /etc/passwd | tail -n 5`.
# Repare algo como `elias:x:1000:1000:usuario,,,:/home/elias:/bin/bash`.
# O "x" na segunda coluna nas origens Unix de 1980 era onde a SENHA EM TEXTO PURO 
# ficava! Por ser arquivo legível pra qualquer mortal do sistema, inventaram
# a separação do "shadow", trocando a senha pela letra 'x' e movendo hashes pro escuro.
# Passo 2: Quando precisar auditar quem tem acesso não restrito de `root`, corra para
# o UID. Um usuário falso injetado por Hacker teria o número de UID 0:
# `awk -F: '($3 == "0") {print}' /etc/passwd`
# Passo 3: O editor das regras sudo se chama `visudo` (nunca manipule `/etc/sudoers` 
# via echo ou nano, se der `syntax error` você travará toda empresa de elevar privilégios!).
# 
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# A queixa "fulano não está no arquivo sudoers" e bloqueio de "this incident will be reported" 
# ocorre pq a conta perdeu associação com o Grupo root predefinido via polkit. No Debian,
# é o grupo `sudo`, em RedHat é `wheel` ou `adm`. Garanta: `usermod -aG sudo NomedoCara`.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um ataque mortal chamado PAM Backdoor. O `sudo` não confere senhas nativo; 
# Ele pede para o subsistema Pluggable Authentication Modules (PAM) fazê-lo. Se atacantes com root 
# modificam bibliotecas de `.so` em `/lib/security/pam_rootok.so` em memória (Persistence),  eles 
# podem implementar um passord mestre ("passwordless") global. Além disso, regras mal escritas sudo como 
# `elias ALL=(ALL) /bin/cat` abre brecha porque o usuário agora pode aplicar `sudo cat /etc/shadow`.
# E pior, se permitirem que alguém rode como sudo o `/usr/bin/vim`, ele poderá invocar `!/bin/sh` DENTRO 
# do Vim e pegar um Shell real sendo root sem barreira.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se eu tiver um hash e crackeá-lo, eu descubro sua senha. E se o analista burro da rede esqueceu de colocar `x` num novo usuário na lista `/etc/passwd` mas deixou a senha vazia? Qual linha perigosa lá seria o indicador que a conta tá exposta a Login Sem senha em SSH?"
# Resposta Esperada: O indicador fatal seria `hacker::1002:1002::/home/hacker:/bin/bash`, onde a ausência da variável do campo restritivo senha (o segundo field "x") destrava o PAM para fazer `auth sufficient` no UNIX permitindo logon silencioso global (su) ou sshd caso o EmptyPasswords for ativo no config de Servidor SSH.
