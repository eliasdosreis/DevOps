#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# A caixa de ferramentas `qemu-img` e utils de rede são os martelos e 
# alicates da virtualização.
# Você precisa criar um contêiner flexível que pareça ter 100 Metros cúbicos, 
# mas que na realidade ocupe zero de espaço no seu galpão até que alguém bote 
# uma caixa dentro de fato (Provisionamento Thin/Magro).
#
# 2. O QUE É (Definição Técnica Senior)
# O `qemu-img` é a subsystem toolchain C usada para converter, redimensionar, 
# e inspecionar Virtual Machine Disks em block-layer abstractly. Suporta backing 
# files (arquivos base) para COW (Copy On Write), snaphots em bloco nativo e NBD.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Como o Sênior usa manipuladores brutos (Fora da libvirt)
# ==============================================================================

DIR="/tmp/meus-discos"
mkdir -p $DIR

echo "=== 1. Criação Dinâmica e RAW ==="
# Criação RAW (Crua). Não há metadata, é bloco de byte puro. Aloca direto 2 GBS reais no HD.
# Extremamente rápido em disco local físico pois anula camadas de arquivos (overhead free).
qemu-img create -f raw $DIR/disco_bruto.raw 2G

# Criação QCOW2 (File backend). Sparse/thin: Usa 192KB até ser populado.
# Contém árvore de blocos encriptada e zlib se necessário.
qemu-img create -f qcow2 $DIR/disco_inteligente.qcow2 10G

echo -e "\n=== 2. Inspeção Detalhada ==="
# 'info' lê os cabeçalhos L1/L2 table size do QCOW para te dar os meta-dados reais.
qemu-img info $DIR/disco_inteligente.qcow2

echo -e "\n=== 3. Expandindo espaço (Grow) do HD fora do Ar ==="
# Sim, o Sênior redimensiona discos com a VM desligada com extrema facilidade:
qemu-img resize $DIR/disco_inteligente.qcow2 +5G
# Repare na inspeção pós-expansão
qemu-img info $DIR/disco_inteligente.qcow2

# ==============================================================================
# 4. COMANDOS PASSO A PASSO
#
# Comando 1: qemu-img repair
# Ocorreu queda de luz durante IO pesado? A VM não liga alegando Header Corrupted.
# qemu-img check -r all disco.qcow2 (Refaz os índices de Clusters da imagem corrompida).
#
# Comando 2: Network Stack via TAP (Visão do Backend)
# Historicamente os Sysadmins rodavem: `ip tuntap add mode tap vnet0` 
# e no QEMU: `-netdev tap,id=hn0,ifname=vnet0,script=no,downscript=no`. 
# Mas isso requeria root e iptables hardcoded, razão que parou de ser feito manualmente.
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você aumenta o HD com `qemu-img resize` em +50GB. 
# Quando você liga a VM e digita `df -h` TUDO CONTINUA DO MESMO TAMANHO na tela!
# Causa (Erro Crasso de Junior): Você apenas expandiu "O Galpão" (A camada do Block Device físico).
# O Sistema "Convidado" (A VM Linux/Windows por dentro) continua possuindo a Tabela
# de Partições mapeada pro limite antigo.
# Solução: Você DEVE entrar na VM apos redimencionar e rodar 
# `resize2fs /dev/sda1` ou aumentar a partição via fdisk/growpart internamente.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# QCOW2 Backing Files (Golden Images + Linked Clones).
# Em cloud computing, se 1.000 clientes alugam servidores Ubuntu:
# Nós nunca fazemos 1000 copias da ISO de 4GB ocupando 4000 GB.
# O Sênior cria um `Ubuntu-Gold-Base.qcow2`.
# E cria discos "Filhos" apontando pra ele, que armazenam SOMENTE OS CLIQUES DE
# DIFERENÇA (COW) que o cliente mexeu em relação a base (Deltas).
# `qemu-img create -f qcow2 -b Ubuntu-Gold-Base.qcow2 -F qcow2 cliente1_disco.qcow2`
# A VM liga no disco Client1. Ele ocupa ínfimos Megabytes e compartilha base de Leitura.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se nós temos uma Pool de discos no Libvirt puramente com Formato `RAW`,
# poderíamos fazer backups ou Snapshots Quentes (Com a Vm LIGADA - Live Snapshots) usando
# o utilitário do próprio libvirt/virsh?"
# Resposta esperada: "Não poderíamos. Snapshots atados nativos na ramificação da VM 
# requerem que os arquivos de disco possuam o formato QCOW2 (QEMU Copy-On-Write),
# pois o formato RAW cru carece dos cabeçalhos estruturais necessários pra travar
# checkpoints de Blocos L1/L2 na metadata (A não ser que o Host delegasse este snap 
# ao filesystem usando LVM/ZFS e não o qemu-img, que é um processo exterior do hypervisor)."
# ==============================================================================
