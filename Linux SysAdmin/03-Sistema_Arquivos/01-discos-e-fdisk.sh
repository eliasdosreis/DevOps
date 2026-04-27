#!/bin/bash
# ==============================================================================
# Aula 03.01: Sistema de Arquivos - Particionamento Físico e Formatação
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Quando você compra um lote de terra, ele é apenas terra. Você não constrói 
# ali instantaneamente.
# 1. Primeiro você demarca o terreno com uma cerca (fdisk = Particionar).
# 2. Depois você passa um rolo compressor, nivela e joga asfalto com as 
#    marcações de asfalto certas para que caubam carros (mkfs = Formatar).
# Se um disco bruto entra no Linux, ele não tem "Sistema de Arquivos". 
# Ele é só poeira metálica!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# No UNIX, dispositivos de bloco (Block Devices) ficam em `/dev`.
# HDs rotativos, SSDs SATAs ou NVMe e SANs recebem namespaces de hardware.
# SSD NVMe = /dev/nvme0n1.
# Disco SATA/SAS Virtual (AWS/VMware) = /dev/sda, /dev/sdb, /dev/sdc...
# Ao particionarmos o disco C (`sdc`), nascem Block Segments filhos (O `sdc1`, `sdc2`).
# E para torná-los graváveis, escrevemos uma árvore SuperBlock nele (mkfs.ext4/xfs).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Todos os comandos abaixo exigem Privilégios Root (Sudo).

# Lista toda a topologia de blocos conectada na placa-mãe.
lsblk                       # OBRIGATÓRIO: Mostra a árvore "HD -> Partição -> Tamanho".

# Suponha que você plugou um Disco Novo (O SEGUNDO DISCO do sistema, chamado SDB).
# Vamos particionar o disco vazio de 50GB:
fdisk /dev/sdb              # OBRIGATÓRIO: Entra no modo interativo do particionador Master Boot Record (MBR).
# (No prompt do fdisk, apertamos 'n' de Novo, Enter pra confirmar Primary padrão,
#  'w' de Write pra dar commit no disco e fechar. Ele agora virou /dev/sdb1).

# O disco foi demarcado. Agora precisa do "Asfalto" (File System Ext4 ou XFS).
# O parâmetro abaixo escreve Inodes do zero.
mkfs.ext4 /dev/sdb1         # OBRIGATÓRIO (Debian/Ubuntu): Padronizado e muito estável.
mkfs.xfs /dev/sdb1          # OBRIGATÓRIO (CentOS/RHEL): XFS escala absurdo em Datacenters.

# Quer verificar as "etiquetas ocultas" e status do formato de todos os discos?
# O UUID (Universally Unique Identifier) é vital pra infraestrutura Sênior.
blkid                       # OBRIGATÓRIO (Block IDentifier): Exibe o UUID pra cada partição.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] fdisk -l
# [O QUE FAZ] (l = list). Puxa o diagnóstico brabo do disco em bytes. Mostra tamanho dos setores.
# [SAÍDA ESPERADA] Disk /dev/sda: 20 GB, 21474836480 bytes, 41943040 sectors

# [COMANDO] parted /dev/sdb mklabel gpt
# [O QUE FAZ] Fdisk trabalha bem com discos velhos MBR (limite 2 Terabytes). Para Storage 
#             Servers modernos com Discos de 10TB+, usamos a tabela de partições GPT via `parted`.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Fui particionar e formatar o "sdb", MAS AO DIGITAR O COMANDO DE FORMATAR DEU:
#   `/dev/sdb is apparently in use by the system`
# 
# Isso ocorre pelo cache interno do Kernel (udev/partprobe). Você deletou ou 
# particionou a tabela, e o Kernel não atualizou a Array interna dele. Rode o 
# comando magico `partprobe /dev/sdb` pra esbofetear o Kernel no rosto e mandar 
# ele re-ler o mapa de slots físicos, e tente formatar de novo.

# - ERRO COLOSSAL (FATAL): Fui formatar O disco 1 da empresa para estender espaço e..
#   RODEI `mkfs.ext4 /dev/sda1`. 
#   VOCÊ ACABA DE DELETAR O SISTEMA OPERACIONAL INTEIRO E TODOS OS DADOS DA EMPRESA EM FRAÇÕES DE SEGUNDOS. 
#   /sda = é quase sempre sua casa!! NUNCA de 'mkfs' num dispositivo que contem o S.O.!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# EXT4 vs XFS? Por que existe diferença?
# Em provas de LPI e no dia-a-dia de Big Data:
# O Ext4 é perfeito pra Web Servers (muitos arquivos pequenos). Mas tem gargalo em Inodes
# e alocação bloqueante.
# O XFS do RHEL foi o File System nascido por alienígenas no SGI (Silicon Graphics) em 1993. 
# Ele performa I/O assustadoramente rápido e paralelo para arquivos massivos. Mas 
# tem uma desvantagem sênior: VOCÊ NUNCA PODE DAR DOWNSIZE (encolher) uma partição 
# viva formatada em XFS! Ele só suporta Crescer (XFS_GrowFS), NUNCA encolher pra devolver RAM/HD!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você ligou no Datacenter um HD de 10 Terabytes Novinho. 
# Você abre o fdisk, pede pra rodar e particionar 100% de ocupação pra nova 
# partição /dev/sdb1 e escreve 'w'. Ele diz 'Size Limit Reached 2TB!!'. Como resolvo isso?"
#
# Resposta Esperada: "O disco virgem subiu com a tabela de partições antiquada 'DOS/MBR'.
# A MBR utiliza endereçamento LBA de 32 bits, que matematicamente estoura no limite de 
# 2.2 Terabytes. Devemos converter o cabeçalho inteiro do disco para tabela GPT 
# (GUID Partition Table). Para contornar, eu abandonaria o `fdisk` (se for antigo)
# e usaria o comando especial GNU `parted /dev/sdb mklabel gpt`. Em seguida 
# eu criaria a partição ocupando 100% que agora tem suporte LBA de 64 bits para Zettabytes."
