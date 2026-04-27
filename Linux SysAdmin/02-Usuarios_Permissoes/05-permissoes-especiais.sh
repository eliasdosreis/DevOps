#!/bin/bash
# ==============================================================================
# Aula 02.05: Usuários, Grupos e Permissões - O Segredo das Especiais (SUID/Sticky)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# (Sticky Bit) "A Geladeira do Condomínio":
# Na área de lazer tem uma geladeira. TODOS podem colocar a própria cerveja lá
# (Write na pasta /tmp). Mas a regra é clara: Ninguém pode pegar ou jogar no
# lixo a cerveja do vizinho, SÓ A PRÓPRIA cerveja! Isso é o Sticky Bit!
#
# (SUID) "O Cartão do Gerente no Caixa do Mercado":
# Você é um caixa (Usuário Normal). Você não tem poder pra cancelar uma compra (root).
# Então você chama a Máquina de Cancelar (Binário SetUID). Ela lê o Cartão do
# Gerente que já tá enfiado nela, cancela a compra COM O PODER DO GERENTE,
# e depois devolve o controle pra você (Caixa).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Permissões octais que mudam o comportamento intrínseco de pastas ou binários.
# - SUID (Set User ID - Bit 4000): Quando ativado num executável compilado, o 
#   processo rodará com o UID do PROPRIETÁRIO do arquivo, e não de quem o chamou.
# - SGID (Set Group ID - Bit 2000): Em pastas, obriga que todo arquivo criado
#   ali dentro herde o GID (Grupo) da pasta, ignorando o grupo primário de quem criou.
# - STICKY BIT (Bit 1000): Usado em `/tmp`. Permite chmod 777, MAS restringe a 
#   deleção do arquivo EXCLUSIVAMENTE ao seu Owner ou ao Root.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# STICKY BIT (+t) - Salvando a pasta compartilhada da empresa
mkdir /dados_compartilhados
chmod 777 /dados_compartilhados     # Erro crasso. O João deleta o projeto da Maria.
chmod +t /dados_compartilhados      # OBRIGATÓRIO (Sticky Bit). Agora o João SÓ apaga o que ele mesmo criar.

# SGID (+s no Grupo) - Compartilhamento inteligente em pastas de Departamentos
# A pasta RH pertence ao root:rh.
mkdir /departamento_rh
chown root:rh /departamento_rh
chmod 770 /departamento_rh          # Diretores RH e Sócios RWX. Outros Zero.
# O SGID entra em ação: Todo arquivo criado dentro da pasta ganhará a pulseira "rh"
chmod g+s /departamento_rh          # OBRIGATÓRIO PARA DEPARTAMENTOS NAS/SAMBA.

# SUID (+s no Owner) - O perigo mortal de elevação de privilégio
# O comando `/usr/bin/passwd` TEM O SUID NATIVO DA MÁQUINA!
# Por que o João consegue trocar a própria senha, se ele não tem acesso ao /etc/shadow?
# Porque o `passwd` foi configurado com o comando:
chmod u+s /usr/bin/passwd           # OBRIGATÓRIO PARA SENHAS (Só o SO usa).
# Isso diz ao shell: "Quando o João rodar 'passwd', engane o Kernel e diga que 
# o ROOT quem está rodando. Altere o shadow com permissão ninja, e feche".

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] ls -ld /tmp
# [SAÍDA ESPERADA] drwxrwxrwt 13 root root 4096 Jan  1 12:00 /tmp
# [O QUE FAZ] Note o "t" no final da permissão. Ele é a prova visual que o 
#             Sticky Bit está blindando o lixo da empresa (t de sTicky!).

# [COMANDO] ls -l /usr/bin/passwd
# [SAÍDA ESPERADA] -rwsr-xr-x 1 root root 68208 Feb 14  2024 /usr/bin/passwd
# [O QUE FAZ] Note a letra "s" minúscula onde deveria estar o X do Root Owner.
#             Isso é o alerta visual de Binário SUID em execução no Sistema!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Fui auditar scripts bash "meuscript.sh" na minha empresa e apliquei `chmod u+s`
#   nele para que o Junior do financeiro rode o script com poderes de root!
#   EU TESTEI E NÃO FUNCIONOU! DEU PERMISSION DENIED! Por que??
# 
# SURPRESA SÊNIOR! Kernel Linux ignora o bit SUID em SCRIPTS INTERPRETADOS
# (Python, Bash, Perl) por motivos bizarros de vulnerabilidade de Race Condition!
# O SUID SÓ TEM EFEITO REAL em binários compilados em C/C++ usando ELF/Bin.
# Para dar poder de root pra um script de texto pro seu júnior, nós usaremos o 
# /etc/sudoers (Assunto da próxima aula)!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Hackers A-M-A-M SUID.
# Quando um invasor ganha "Acesso Não Privilegiado" num webshell do Nginx, a 
# primeira coisa que ele faz (Enumeração) é rodar no terminal um comando `find / -perm -4000`.
# Ele varre O HD INTEIRO do Linux da empresa atrás de binários bobos de 
# "Impressora" que o SysAdmin júnior botou o `SUID ROOT`. 
# O Hacker então, abre a impressora, cria uma falha de Buffer Overflow nela, e 
# pimba: Toma a shell de Root! SUID mal gerido é a principal causa raiz de Rootkits.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa criar uma pasta colaborativa `/var/rh` para as 
# analistas Alice e Joana. Ambas pertencem ao grupo secundário 'rh'. Elas criam
# planilhas o dia todo. O problema é: A planilha da Alice nasce com owner
# 'alice:alice'. Quando a Joana tenta editar a planilha da Alice, o LibreOffice 
# trava por Read-Only, pois a Joana não tem o grupo 'alice'. Como resolvemos isso
# de forma automática e elegante, sem usar ACL (Access Control Lists) e sem script cron?"
#
# Resposta Esperada: "Configuramos o SGID (Set Group ID) no diretório mãe. Primeiro
# garantimos que a pasta '/var/rh' pertença ao grupo 'rh' e alteramos as permissões 
# base para 2770 (chmod 2770 /var/rh). O número 2 no octal ativa o SGID no nível
# do diretório. A partir desse milissegundo, o Kernel forçará que qualquer arquivo 
# Inode novo criado lá dentro nasça automaticamente com o GID persistente 'rh' (e não 
# 'alice:' ou 'joana:'), garantindo instantaneamente permissão Write (rw-) para 
# qualquer outro usuário membro real do departamento de rh que tocar naquele arquivo."
