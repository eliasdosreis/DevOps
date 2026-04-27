#!/bin/bash
# ==============================================================================
# Aula 07.01: Backup - As Ferramentas Curingas Sêniores (Rsync, Tar, DD)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Backup não é copiar um arquivo com o mouse e jogar no pendrive (Isso é Cp).
# Backup profissional tem Arquitetura:
# - TAR: É a Caixa de Papelão e o Durex (Empacota 10 mil fotos de 1kb e 
#   Vira 1 ÚNICO ARQUIVO "Fotos.tar". Isso Acelera em 1000% o disco na hora de 
#   Mandare Pra Nuvem).
# - RSYNC: O "Correio Mágico que Só Leva a Tinta Faltando". Se o Arquivo.tar tem 50GB
#   e você adicionou 1 foto hoje, O Rsync Sabe Qual Foto e Baixa só os bytes Deltas Dela 
#   pela rede (Economizando horas de banda).
# - DD: A Maquina Copiadora Perfeita De Discos Inteiros "Bit a Bit".
#   Até mesmo os setores Vazios do disco ou setores Deletados vão ser Clonados Pro HD Novo da Sala Fria!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Transferência de Estado (State Sync) e Arquivamento (Archiving).
# `tar` (Tape Archive). Utilitário nativo de junção sequencial que usa zlib/gzip
# ou lbzip2 em pipes. Não compacta por padrão, apenas une arquivos.
# `rsync` Ferramenta baseada no algoritmo Delta-Transfer. Usa SSH como túnel TCP e 
# Checksums (Hashes) nos chunks dos Inodes pra validar metadados e enviar o Restante sem Perdas.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# ===== O PODEROSO TAR ======================
# Compactar (c = create, v = verbose, z = gzip compactador, f = file/arquivo)
tar -cvzf bkp_empresa.tar.gz /var/www/site/  # OBRIGATÓRIO (Seu Dia-a-Dia).

# Extrair (x = eXtract, z = lida com o formato gz que eu usei, f = arquivo)
tar -xvzf bkp_empresa.tar.gz -C /tmp/        # SÊNIORIDADE: O Flag MAIÚSCULO '-C' dita a pasta de Destino Limpa
                                             # Ao invés de vomitar Tudo na pasta que eu "Estou logado".

# ===== O REI DA REDE: RSYNC =================
# Sincronização Absoluta pela Internet (a = archive que mantem dono e permissoes originais s=suid r=rwx, 
#                                       v = verbose, z = zip compression pra não congestionar o link de fibra da claro)
rsync -avz /origem/ usuario_gringo@IP_NuVem:/diretorio_remoto/  # OBRIGATÓRIO NO CRONTAB DE TODO SysAdmin

# A Maldição da Barra '/' do Rsync:
# `rsync -av /pasta1 /pasta2`    <-- COPIA A PASTA INTEIRA "PASTA1" E DEPOSITA LÁ. Fica `/pasta2/pasta1`.
# `rsync -av /pasta1/ /pasta2`   <-- (COMPLETAMENTE DIFERENTE). Pega a "ÁGUA" de DENTRO Da Pasta1. E Deposita Na 2.
# O JÚNIOR Bota a barra e Ferra com a estrutura Inteira de WebRoots do Nginx no deploy!

# ===== O CLONADOR DE DISCOS: DD =============
# Se o Servidor Morreu, O Perito Forense não dá Copy Paste! Ele Roda o "Disk Destroyer" pra Tirar A Alma Clone Exata.
# id = Input File (Lê o HD cru /dev/sda) | of = Output File (Gera o arquivo Fantasma Perfeito.img na gaveta SDB).
dd if=/dev/sda of=/mnt/HD_Externo/imagem_forense_do_SD_Morto.img bs=4M status=progress # OBRIGATÓRIO FORENSICS

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] rsync -av --delete /www/producao/ /mnt/backup/
# [O QUE FAZ] (O Limpador Mágico). O Dev deletou uma Imagem Inútil no site 'foto.jpg'. 
#             Mas o Backup Antigo AINDA TINHA 'FOTO.JPG'. A TENDENCIA é o Backup CRESCEER INFINITAMENTE de Lixo.
#             O Sênior Ativa o Flag Armadilha `--delete`.
#             O Rsync Vai No Backup "Opa, essa foto não tem mais no Site original, Logo vou APAGAR DO BACKUP TAMBÉM!".
#             Espelhamento 100% Exigido de Espaço Limpo Vivo!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Deixei um Rsync de 400 GB Rodando À Tarde do DataCenter da B3 pro Da Amazon AWS. (Pela internet limpa, o Firewall cortou e Dropou a porta do túnel VPN e matou O Rsync).
#   O FIM DO MUNDO? "Zerei Meus Gigas? E a Empresa?"
# 
# Essa É A Graça do Rsync E Sua Matavilha Engenharia. O Algoritmo Checa o Checksum de Cada Bloco de 4K, 8K.
# Você Basta APERTAR A SETA PRA CIMA DO TECLADO E DAR ENTER PRO COMANDO RODAR DE NOVO EXATAMENTE, NA MESMA PASTA!!
# O Algoritmo vai Ler Os 400 GB em 1 MINUTO! Ele Pula Tudo! Quando ele Bater Na Foto do Milênio Q CORTARAM O FIO.. Ele vai dar "Resume" A Partir do BYTE Cortado, e enviar O Resto Pela Internet Economizando as HORAS de Upload Gasto!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# "O Backup É Lixo Se Você NUNCA TESTOU O RESTORE."
# A Lei De Murphy É A Religião Dos SysAdmins e SREs. Todo Junior Programa o Script Cron, olha
# pro Log Verde e Acha Que Salvou o Mundo da Instituição (Backup Illusion).
# Três Meses Depois Os Hackers Coreanos Entram... E Ele Dá `tar -xzf backup.tar` ... E o Tar O Cospe Erro:
# "CORRUPTED EOF REACHED. INVALID ARCHIVE". O Lixo do BKP DEU PAU DE GRAVAÇÃO há meses na San Storage Barata.
# E a Empresa é DESTRUÍDA!!
# O Sênior Programa CRONS BKP REVERSOS!
# Na Nuvem "B", O Pipeline Liga 1 VEZ NA SEMANA, Monta O BKP, RODA TESTE UNITÁRO. SE O ARQUIVO ABRIL LÁ, ELE TE MANDA 1 EMAIL: (BACKUP TESTADO, RESTORE POSSÍVEL E SÃO). 
# Só assim Alguém Dorme no Fim de Semana em Infra.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está tentando Extrair UM ÚNICO Arquivo de LOG 'erro_importante.txt' Que Se Encontra Aos
# Milhões Encriptado e Socado no Meio de Um Lixo Histórico Num Tarball 'Lixo2021.tar.gz' Gigante de 60 GBs.
# O Problema: Seu Servidor atual SÓ TEM VAZIO LIVRE 3 GIGAS NO HD! Se você Rodar o Tar 'Extract Todos'
# A Máquina Vai Congelar De Espaço Cheio na Mesma Hora de OOM do Particionamento! E a Empresa Paralisa."
#
# Resposta Esperada: "Usaríamos a funcionalidade Exclusiva De Target Extractions Arquitetural Do Comando TAR.
# Sintonizando A Ferramenta Para Retirar 'The Needle In The HayStack'. A Sintaxe Plena Sem Destruir o HD Seria:
# `tar -zxvf Lixo2021.tar.gz diretorio_original/no_tar/erro_importante.txt`
# O Zlib do Kernel Fará um Piping Buffer Stream Na RAM Cega Do Sistema, Lêr O Tar Inteiro No Fluxo da Memória
# Mas DEVOLVERÁ PARA O HD DE METAL Apenas o Bytes Relativos ao Pattern Encontrado (Nosso Erro.txt com míseros kbs de gravação)."
