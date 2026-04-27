#!/bin/bash
# ==============================================================================
# Aula 02.03: Usuários, Grupos e Permissões - Grupos e Controle de Acesso
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# O conceito de "Usuário" sozinho não escala numa holding com milhões de funcionários.
# Se temos no Linux 20 Desenvolvedores, 10 de RH e 5 DevOps, o síndico NÃO PODE
# ir porta por porta em cada arquivo do servidor e dizer "O Joao pode ler, a 
# Maria também, o Carlos também".
#
# A solução natural de TI é criar os **CLUBES VIPs (Grupos)**: `devs`, `hr`, `devops`.
# O condomínio distribui as "Pulseiras do Clube" (Adiciona usuários aos grupos).
# Quando a porta de vidro do Servidor de Pagamento for instalada, O SÍNDICO SÓ
# MANDA UM CHIP DE ENTRADA: "Apenas membros da pulseira HR entram aqui". E pronto.
# Se o João do RH é demitido, ele tira a conta do João e mais nada.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# No Linux (POSIX), além do seu User ID (UID), cada processo porta uma lista secundária
# acoplada ao kernel: O GID Primário (Primary Group ID) e arrays de GIDs Suplementares.
# Por design FHS, quando um Linux como Ubuntu Server / CentOS cria a conta de um
# novo Joãzinho, ele cria um GID 1001 chamado João e joga a conta 1001 dentro dele
# pra respeitar o POSIX Core Requirements (Esquema Grupo Privado).
# 
# Portanto TODO Humano já tem um grupo matriz. Outros grupos coletivos como 
# "www-data" (Web Servers), "docker" ou "sudo" podem ser somados a ele.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# Cria o Clube Vip dos Desenvolvedores Seniores (Apenas registra na prancheta global)
groupadd devsnr                     # OBRIGATÓRIO: Forma de criar uma equipe de trabalho isolada.

# Observa os grupos registrados hoje nessa máquina:
cat /etc/group                      # OBRIGATÓRIO: A porta de registros /etc/group é o equivalente do /passwd.
# O tail do arquivo sairá algo assim:
# docker:x:998:elias
# devsnr:x:1003:

# Vamos Inserir (Append) o cara talentoso "joao" na pulseira VIP.
# -a : Apenda a array (NUNCA ESQUEÇA DO APPEND, SÉRIO!).
# -G : Supplementary Groups (Modifique as pulseiras Extras do joão, e não tire a Matrix dele).
usermod -aG devsnr joao             # OBRIGATÓRIO: Comando perfeitíssimo de adicionar membros a departamentos.

# COMO RETIRAR O JOÃO DE UM GRUPO ÚNICO?
# O usermod é péssimo pra remover de grupo específico. O GNU Coreutils tem o `gpasswd` pra isso.
gpasswd -d joao devsnr              # OBRIGATÓRIO: Delete do grupo (Revoga acesso ao Clube Vip dele).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] groups joao
# [O QUE FAZ] Lista, separadamente, que clubes o user "joao" tem no pulso.
# [SAÍDA ESPERADA] joao : joao cdrom floppy sudo audio dip video plugdev lxd netdev
# (Isso mostra que ele tem poder da pulseira CDROM, sudo e video sem ser Root!).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO CATASTRÓFICO: Minha equipe Frontend reclamou que o usuário "pedro" sumiu do
#   grupo "html" quando eu rodei o comando hoje cedo pra colocar ele no grupo "devops".
# 
# Isso ocorre todo santo dia.
# O SysAdmin Pleno escreveu rápido de cabeça: `usermod -G devops pedro`
# O que ele mandou o Kernel fazer: "Apague ABSOLUTAMENTE TODAS AS OUTRAS PULSEIRAS DO
# JOÃO DO UNIVERSO, E COLOQUE SÓ A PULSEIRA ÚNICA 'devops' NO CORPO DELE".
# 
# O Parâmetro `-G` (Maiúsculo) é Substituto (Overwrite Completo).
# Para ADICIONAR uma pulseira mantendo as da mão direita, é `-aG` (-a minúsculo de Append).
# NUNCA se esqueça do 'a' ao gerenciar vidas de funcionários alheios.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# "O Bug do Grupo Cacheado".
# O João bate no seu Slack: "Admin! Você avisou que me deu a pulseira do DOCKER. E eu 
# confirmei no comando `groups joao` que eu tô nela, MAS EU DOU `docker ps` AQUI NA
# TELA E TOMO PERMISSION DENIED DENOVO. Você mentiu".
# 
# Não. O João tá com a tela do SSH Terminal dele Aberta Caching Sessions. 
# Quando um shell interativo remoto abre `/bin/bash` TCP, ele CACHEIA as pulseiras de 
# identidade no Kernel PRA AQUELA SESSÃO PID.
# Modificações nas bases do Administrador `/etc/passwd /etc/group` SÓ DESCERÃO 
# pro cliente na próxima inicialização do Shell dele.
# O João Precisa: Desconectar do SSH Server (exit) e reconectar (ssh joao@...).
# Ou dar PING da identidade lá de dentro pra recarregar os File Descriptors: 
# `su - joao` (Switch user forced para ele mesmo, simulando login inteiro). 
# Eis o segredo do Kernel Pleno de Autenticação Ativa. 

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você percebeu no /etc/group a criação explícita da linha abaixo: 
# 'wheel:x:10:root,elias,pedro'. 
# Qual arquitetura base de SO estamos operando e qual o privilégio especial que o Pedro
# acabou de herdar em cima dessa plataforma Red Hat?"
#
# Resposta Esperada: "Essa linha denuncia explicitamente uma família base baseada no 
# ecossistema RedHat/CentOS/Fedora, diferindo do Ubuntu/Debian que usa o grupo 'sudo' 
# padrão de delegar poder via Polkit. A pulseira 'wheel' é uma herança das origens 
# Unix BSDs e Mac OS antigas (Wheel = Big Wheel/Chefão). Logo, o Pedro herdou poder 
# administrativo irrestrito ou moderado de rodar comandos como SuperUsuário Root 
# pela via do /etc/sudoers que mapeia hardcoded a pulseira wheel globalmente."
