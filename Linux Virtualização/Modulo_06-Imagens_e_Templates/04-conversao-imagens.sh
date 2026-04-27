#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você comprou DVDs da vida toda formato "NTSC" pra sua TV Antiga. (A VM operando No VMware c/ disco `.vmdk`).
# Agora você comprou o Home-theater Moderno KVM. Ele exige MP4 H264 (Extensão `.qcow2`).
# Você tem que rasgar os metadados do vídeo e recosturar ele nas malhas certas. 
# Se você só converter os bits do video, pode rodar, mas as "Legendas do filme"  
# (Os Drivers Sata Guest e placas de Video Kernel dntro do Linux Guest) vao quebrar. Você precisa INJETAR as 
# legendas originais novas durante o transcode. Isso é a migração V2V.
#
# 2. O QUE É (Definição Técnica Senior)
# `qemu-img convert`: Faz alteração bruta bit level Block formats (Transforma Container format).
# `virt-v2v`: Solução holística que converte não só o bloco, mas lê as partições internas UEFI, 
# apaga drivers VMware-Tools, e injeta Modulos de VirtIO e recompila InitramFs garantindo Guest Linux/Win bootable na KVM.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Realizar conversão bruta VS conversão Assistida Holística.
# ==============================================================================

echo "=== 1. Conversão de Bloco PURA E BRUTA (O Rápido Inseguro) ==="
# Usamo qemu-img para destripar arquivos RAW, VMDK (VMware), VDI (VirtualBox) ou VHD (Microsoft) para .QCOW2
# -O -> Formato Target  | -c -> Comprimir arquivo magro  | -p -> barra de progresso!
qemu-img convert -p -f vmdk -O qcow2 -c /backup_antigo/Servidor_Legado.vmdk /var/lib/libvirt/images/Servidor_Libvirt.qcow2
# ATENÇÃO! A Máquina Windows do VMware DENTRO desse disco, PODE E VAI dar tela Azul 0x00..B 
# Ao ligar na libvirt! A conversão bruta NÃO ALTO_ALTEROU OS DRIVERS SCSI do registro sys.

echo "=== 2. Conversão Mágica Holística Sênior (Virt-V2V) ==="
# Esse é o comando empresarial de Datacenters rodando migração de mass storage.
# -i ova -> Lê o arquivo Exportado OVF/OVA original da VMware/Oracle.
# -o libvirt -> O output NÃO É SÓ O DISCO! Manda pro daemon virtqemud e JÁ CRIA O XML PRONTO e amarrado!!
# virt-v2v -i ova Servidor_Legado.ova -o libvirt -os default

# ==============================================================================
# 4. PASSO A PASSO
#
# Comando 1: V2V Conexão direta Remota a Hosts VMware ESXi (Sem baixar disco pra ca)
# virt-v2v -ic vpx://user@esxiHost.local/Datacenter/esxiHost?no_verify=1 \
#          "NomeDaVM_La_No_Vmware" \
#          -o libvirt  ...
# MAGICO: O Host KVM Linux chuging data via rede diretamente dos Endpoints do ESXi Proprietário!
# Convertendo na RAM Fria sem salvar Lixo, e instanciando sua VM viva na virsh local!
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Fazer virt-v2v de uma VM Windows Server 2019 pesada, e quando liga, 
# Ele até dá Boot, mas O Rato (Mouse) não mexe no virt-manager Console VNC, não 
# ping a placa Intel E1000 de rede, um terror. Tudo congelado sem rede.
# Causa: A Migração automatizada Virt-V2V depende dos Drivers "VirtIO" assinados Windows 
# estarem pré-descarregados no pacote hospedeiro `virtio-win` p/ injeção offline guestfs.
# Solução: Assegure-se de instalar (`apt install virtio-win` / `dnf install virtio-win`) no nó Linux
# antes de rodar v2v. Isso colocará os `.Vfd/.Iso`  em `/usr/share/virtio` e o v2v automaticamente pegará, abrirá 
# o registro sys hive do Windows apagado e atracará sysprepo offline deles! 
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# As entranhas do Dracut / InitFS Update no Kernel Guest.
# Quando você move um Linux RedHAT do Hyper-v pra KVM e dá Kernel Panic: 
# "cannot mount VFS Root File System" / "vg not found". Por quê ocorre essa tela preta de morte? 
# Por que o Initramfs do Kernel Interno no Booting Process não tinha compilado drivers VirtioBlock drivers para ler as extensões /dev/vda,
# ele estava treinado pelo módulo pra tentar carregar /dev/sda (SATA Host adapter). 
# A engenharia reversa do virt-v2v força o Chroot e re-executa `dracut --regenerate-all` ou `update-initramfs`
# forçando os módulos virtio a se costurarem no bootloader initrd p/ que os drivers bootáveis Kvm acordem vivos na faísca principal.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se temos que extrair dados cruciais contidos num Disco VMDK originário no VMWare, porém 
# não queremos subir esse disco numa VM Ligável e nem fazer uma conversão inteira V2V pesada pois custará tempo.  
# Como conseguiriamos acessar os arquivos internos Linux (ext4) desse .vmdk localmente a partir do Hypervisor Host (Libvirt Node)?"
# Resposta esperada: "O Sênior usará a biblioteca network block device (NBD). Nós atacharemos as partições 
# expostas do contentor virtual num dispositivo de looping block de rede local no host, rodando o utilitário nativo host-side Qemu Network Block Device. 
# Ex: `modprobe nbd` seguido de `qemu-nbd --connect=/dev/nbd0 disco_vmware.vmdk`.
# Desta forma o host linux reconhecerá fdisk root system `/dev/nbd0p1` nas partições cruas e permitirá um simples `mount -t ext4 /dev/nbd0p1 /mnt/vmware`,  
# acessando os aquivos instantaneamente na sua árvore T1 física como root sem perda de tempo em boot conversion ou Vm Instancing."
# ==============================================================================
