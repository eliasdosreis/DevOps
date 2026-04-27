#!/bin/bash
# ==============================================================================
# Aula 03.03: Sistema de Arquivos - O Mágico LVM (Logical Volume Manager)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Sistema de Partição Tradicional (O pesadelo limitante):
# Você tem um balde de 5 Litros rígido de plástico e ele encheu de agua de chuva. E agora?
# Você não tem como esticar um balde de plástico! A única solução é comprar um
# de 10 Litros, DESPEJAR TUDO LÁ DENTRO, e jogar o menor fora (Migração Dolorosa de HD).
#
# LVM (Logical Volume Manager):
# Seu balde agora é de Borracha Elástica (LV). Você pode ter uma fileira de Copos 
# pequenos descartáveis (PV). Quando um tá secando, você PINGA ELE (VGs) e
# estica a borracha sem derrubar 1 gota de água! A flexibilidade infinita para nuvem.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O LVM introduz uma camada de abstração (Device Mapper) entre os Discos Físicos (Hardware)
# e o Sistema de Arquivos Software (Ext4/XFS). O LVM é composto de:
# 1. PV (Physical Volumes): O Hard Drive puro ou LUNs do SAN (/dev/sdb, /dev/sdd).
# 2. VG (Volume Group): O agrupamento "Piscina Compartilhada" de todos os HDDs juntos. (10 TB).
# 3. LV (Logical Volume): A Fatia virtual retirada da piscina VG que será finalmente "Particionada e formatada".

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Todos os comandos abaixo exigem Privilégios Root (Sudo).

# 1º Passo - "Marcar os HDs Virgens para Participarem da Bolha do LVM"
# Transforma as LUNs Físicas (Dois discos de 50GB) em volumes Físicos Administrados.
pvcreate /dev/sdb /dev/sdc  # OBRIGATÓRIO: Injeta os metadados do LVM nos cabeçalhos dos discos MBR.

# 2º Passo - "Criar a Piscina (Volume Group) que junta a Terra Total deles"
# Criamos a pool "PISCINA_DADOS" unificando SDB (50)+ SDC (50) = Teremos 100GB livres pra picotar.
vgcreate PISCINA_DADOS /dev/sdb /dev/sdc # OBRIGATÓRIO: Unifica.

# 3º Passo - "Criar um Disco Virtual (LV) pra usarmos hoje pro NOSSO BANCO DE DADOS"
# -L 30G significa 30 Gigas da piscina 100G. E -n dá nome pro disco fatiado invisível.
lvcreate -n lv_bancodados -L 30G PISCINA_DADOS # OBRIGATÓRIO: Cria o bloco pra usarmos.

# 4º Passo - O LV É um disco que precisa ser Asfaltado (mkfs), montado e tudo.
mkfs.xfs /dev/PISCINA_DADOS/lv_bancodados   # FORMATANDO E PRONTO PRA /ETC/FSTAB.

# ===============================================
# MÁGICA LVM - EXPANSÃO ON THE FLY (Sem DownTime)
# ===============================================
# Dezembro de 2025. O Banco encheu os 30Gigas da vida passada. A empresa vai parar.
# "Sênior, adicione 10GB Imediatamente ou a Loja Cai em BlackFriday!!"
#
# COMO RESOLVER COM 2 LINHAS NO LINUX E ZERO REINICIALIZAÇÕES:
# 1. Estica o Bloco Virtual (LV) pegando +10G que sobrou na "PISCINA_DADOS".
lvextend -L +10G /dev/PISCINA_DADOS/lv_bancodados

# 2. ATENÇÃO: Se eu dar '-L', a caixa de borracha esticou. MAS O *SISTEMA DE ARQUIVOS (XFS)*
# LÁ DENTRO AINDA ACHA QUE TEM 30! EU PRECISO ESTICAR "O ASFALTO DELE AO VIVO".
xfs_growfs /mnt/ponto_de_montagem # OU resize2fs se for EXT4. PRONTO!! 40 GIGAS LIDOS PRA CLIENTES.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] pvs | vgs | lvs
# [O QUE FAZ] (Physical Volume Display, etc). Mostra planilhas da infra inteira.

# [COMANDO] lvextend -l +100%FREE /dev/vg_corp/lv_root 
# [O QUE FAZ] Em vez de calcular os megabytes pra esticar com letra Maiúscula (-L +5G),
#             O administrador usa 'l (l-minúsculo de logical extent) e o Curinga
#             +100%FREE pra consumir TUDO O QUE SOBROU DA PISCINA DE UMA VEZ PRA ELE.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO ABSURDO: "lvremove /dev/piscina/lv_bancodados" .. Mas a PISCINA AINDA TÁ CHEIA PELA METADE!
# Se você der `lvreduce` ou `lvremove` em produções Ext4, ELE DESTRÓI CORROMPENDO 
# A TABELA DE INODES, PORQUE O ASFALTO FOI CORTADO AO MEIO E AS PÁGINAS ARQUIVADAS
# EM MÍDIA DO FINAL DO HD SOMEM NO NADA DO SISTEMA NUMÉRICO!
# Em Storage LVM, Sênior só Cresce Volumes. JAMAIS DA SHRINK (MENOR) NUNCA.
# Se precisar menor, você MIGRARÁ OS DADOS pra um LV Novo! Redução = Morte I/O de Paridade.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Por que todas as instâncias EC2 da Amazon Cloud, ou Vagrant Boxes vêm em LVM hoje?
# Por causa dos "Snapshots".
# Você vai aplicar um Patch do Windows Update de 10GB no Kernel Server Prod que 
# pode foder tudo. Um LVM te deixa rodar o comando:
# `lvcreate -s -n BKP_KERNEL -L 5G /dev/vg_sistema/lv_principal`
# O LVM TIRA UMA "FOTO" em Milissegundos desse Ponto No Tempo, guardando só o Diferencial.
# Se o Patch quebrar a máquina inteira? 
# O Pleno formata o servidor, perde as notas da noite em 4h de backup. 
# O Sênior Roda: `lvconvert --merge /dev/vg_sistema/BKP_KERNEL` e Reinicia.
# Ele Voltou a Máquina No TEMPO Exato De Antes Do Patch, Pela Física Dos Blocos de LVM,
# SEM BAIXAR MEIO BYTE PELA INTERNET do Datacenter!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Precisamos substituir fisicamente o disco 'sdb' que está apitando 
# SMART Failures (Velho e pifando). Ele pertencia à pool LVM junto do sdc que era saúdável. 
# Inserimos um sdd novinho na baia quente do servidor como reposição ('Hot Swap').
# Sem desligar o servidor, me dite o plano logístico do LVM Pleno para retirar esse sdb morto."
#
# Resposta Esperada: "Usando as rotinas autônomas de migração on-the-line.
# Primeiro criaríamos o 'pvcreate /dev/sdd' e o adicionaríamos ativamente ao 
# VG da pool doente com 'vgextend PISCINA /dev/sdd' pra pool ganhar mais bytes que o suficente.
# Em Seguida usaria a magia da ferramenta 'pvmove /dev/sdb', que migra espelhado TODOS 
# OS EXTENTS E MAPAS VIVOS dos processos da RAM do disco moribundo pras áreas livres 
# da PISCINA. Após concluir a drenagem silenciosa, o 'sdb' não terá NENHUM Vínculo Cíclico de Inode.
# Apenas rodamos 'vgreduce PISCINA /dev/sdb', espetando ele fora do Kernel, 
# e removemos fisicamente da gaveta da placa SAS."
