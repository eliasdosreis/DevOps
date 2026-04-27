#!/bin/bash
# ==============================================================================
# Aula 03.04: Sistema de Arquivos - Quotas de Disco (Limitar Engolidores de HD)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Pense no servidor como um condomínio que compartilha a mesma Caixa D'água (HD).
# A Maria e o João moram lá. Se a Maria decidir lavar o carro 10 vezes por dia
# e encher a piscina (Baixar 500 Gigas de MP3 na pasta pessoal dela), A CAIXA
# D'ÁGUA SECA. E quando seca, o Síndico (SO Linux) também fica sem água pra 
# passar café e O SERVIDOR INTEIRO TRAVA ("No space left on device").
#
# Quotas de Disco é o hidrômetro individual! É você botar uma catraca na porta 
# da Maria e dizer: "Você tem 10 Litros (Gigas). Usa como quiser. Mas quando
# bater no teto (Hard Limit), sua torneira corta na hora!".

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Por padrão, usuários de um mesmo Filesystem (/home montado no root) brigam 
# livremente pelos mesmos blocos disponíveis no Fundo Comum (Free Space).
# Para impedir Starvation de serviços críticos por atacantes internos ou descuido,
# usamos os utilitários de `Quota` do Kernel no nível de Dispositivo de Bloco 
# (usrquota, grpquota ativados no /etc/fstab).
# 
# A quota define Soft Limits (Avisos Onde você pode estourar um pouquinho por X dias)
# e Hard Limits (O Kernel corta qualquer `write()` daquele UID instantaneamente na C-LIB).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Todos os comandos abaixo exigem Privilégios Root (Sudo) e
# os pacotes (ex: `apt install quota`) instalados previamente.

# Passo 1: Edite o FSTAB E diga que "A PONTE FOI CONSTRUIDA COM CATRACA"
# Era: `UUID=7a39b2 /home ext4 defaults 0 2`
# Fica: `UUID=7a39b2 /home ext4 defaults,usrquota,grpquota 0 2`
# Após isso faça o `mount -o remount /home` pra recarregar a catraca ligada.

# Passo 2: O Comando "quotacheck" - Inspeciona todo o FileSystem uma vez e 
# constrói o mini-DB de quem gastou o quê "aquota.user" e "aquota.group".
quotacheck -cug /home       # OBRIGATÓRIO: Create(-c), User(-u), Group(-g) o banco Index.

# Passo 3: Ativamos as Quotas agora!
quotaon -v /home            # OBRIGATÓRIO: Liga as catracas pra todo mundo (-v pro Verbose falar alto)

# Passo 4: Editando individualmente a conta "maria" no editor Quota's VIM-like.
edquota -u maria            # OBRIGATÓRIO: Abre a matriz de limites Blocks (Peso) ou Inodes (Quantidade Filename).
# Ao abrir o editor você dita os Inodes:
# Filesystem      blocks       soft       hard     inodes     soft     hard
# /dev/sda1         200M          0          0      60000        0        0 
# (Troque o 0 pra 2Gigas e pronto). LIMITADA!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] repquota -a
# [O QUE FAZ] (Report Quota All). Mostra um relatório EXCEL na sua cara do terminal, 
#             com TODOS os abençoados usuários e a roleta russa do Grace Period
#             (Aqueles que estouraram o Soft limit e tão rodando no cheque especial de
#              tempo para limpar o HD deles!).
# [SAÍDA ESPERADA] maria -- 21000M 20000M 25000M  5days | 12K 0 0
# A Maria ta com 21GB lotados, Num Soft warning de 20GB, e Hard (Travar de vez) no 25GB.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: "edquota: Can't parse quota file"
#   As Cotas modernas as vezes usam o Journaled Quota (ext4 nativo) escondido
#   no header do superbloco. O fstab nesses casos não usa `usrquota`, usa O
#   parâmetro `jqfmt=vfsv0,usrjquota=aquota.user`. Sem o formato de Log, o
#   Kernel dá reject pra edições brutas se o OS for muito novo (Debian 12).
#
# - CAOS: O usuário travou com 0 Bytes LIVRES! E ele tentou logar no KDE/GNOME..
#   A TELA DE LOGIN PISCA E VOLTA PRO LOGIN DE NOVO!
#   Porquê? O desktop gráfico cria cookies transitórios ".Xauthority" DE `1 BYTE`!
#   Se o cara lotou 100.00% do Hard Limit dele bloqueado, ELE BLOQUEOU O PRÓPRIO LOGIN 
#   VISUAL DE TELA porque nem esse "1Byte O S.O. permite ele criar"! (Entraremos via SSH Root
#   e apagaremos o lixo da home dele manualmente).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Qual a diferença de LVM Volumes Lógicos e QUOTAS antigas?
# 
# Pense bem: O Quota é maravilhoso para Sistemas de Envio de E-mails Universais e
# Provedores de Hospedagem Web Compartilhada "CPanel Cents", que espremem 200 sites
# de clientes avareza de "10 GIGAS NO MÁXIMO" no HD do FHS.
# Mas para Contas Corporativas de Aplicações e Banco de Dados ou Docker Volumes.. o 
# Sênior da AWS não usa "edquota". Ele usa LVM Virtualizado.
# O LVM restringe DIRETAMENTE A EXTENSÃO FÍSICA NO HARDWARE. Ele é muito mais performático 
# nos reads/writes porque a agulha/chips do SSD só conhece aquele LUN específico. 
# 
# Use Quotas para HUMANOS usuários do FTP de fotos da agência.
# Use LVM para Softwares Abutres que cospem gigas de TempDBs em produção (Kafka).

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa auditar e limpar as homes da empresa. Você nota que o
# usuário 'dev-jr' está ocupando 5GB segundo o `du -sh /home/dev-jr/`. Contudo, o
# comando `repquota /home` garante que ele está 'cobrando' 50GB do disco rígido pelo 
# ID dele e travando a empresa! Pra onde foram esses 45 Gigas que eu sumiram dos
# logs locais da home dele?"
#
# Resposta Esperada: "O repquota rastreia o consumo GERAL deste UID (Dono Exclusivo) 
# por todo o Escopo da partição /home no /etc/fstab (ou da Partição Inteira Raiz /).
# O fato do 'du' não mostrar esses gigas na pasta /home/dev-jr se dá porque o usuário
# tem permissões liberais para salvar arquivos EM OUTROS LUGARES do sistema host. E
# provavelmente ele salvou 45 Gigas de 'Backups em /tmp' ou '/var/spool/..'. Como 
# o Inode do arquivo é 'propriedade legal' do uid dele, o FileSystem Server bilhetou 
# corretamente o limite de Quota da máquina pra ele! Usaria `find / -user dev-jr -size +1G`."
