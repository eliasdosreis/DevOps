#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Nós rodamos um Servidor Linux e queremos colocar um adaptador de rede.
# O QEMU por default diz: "Olha como sou legal, eu finjo ser um Chip da Realtek E1000 
# (Um hardware de 20 anos atrás que TODO SO Windows/Linux reconhece sem drivers) e enfio lá".
# A Vm usa, mas bate max 80 Mbs por segundo c/ CPU Host Spikes (Qemu emulando 1 a 1).
# O Sênior diz: "Não emula porcaria nenhuma! Vamos colocar o chip abstrato VirtIO!". 
# Ele é um buraco de minhoca. Um tunel de Memória compartilhada que a Vm e O host 
# leêm os mesmos ring buffers com Zero-Copy. Explode pra 50 Gbps a velociade.
#
# 2. O QUE É (Definição Técnica Senior)
# O padrão Virtio: A ParaVirtualização I/O standard suportada em ABI C.
# Forjado sobre ring-buffer queues (Virtqueues).
# ==============================================================================

# ==============================================================================
# 3. CONCEITOS e CLIs
# Objetivo: Como inspecionar se a sua Plataforma é lenta via I/O emulation.
# ==============================================================================
echo "Comando no Cliente: lspci -k"

# Saída de LENTIDÃO (Emulação)
# 00:04.0 Ethernet controller: Red Hat, Inc. QEMU Virtual Machine
#         Kernel driver in use: e1000  <----- PÉSSIMO.

# Saída de PERFORMANCE TIER 0
# 00:03.0 Ethernet controller: Red Hat, Inc. Virtio network device
#         Kernel driver in use: virtio-pci <----- BRUTAL.

# ==============================================================================
# 4. XML DO VHOST-NET MÁGICO
# ==============================================================================
# Há dois tipos de VirtIo nas redes: 
# 1. UserSpace VirtIO (Context Switches Qemu!)
# 2. Kernel-Space VHost-Net (O pacote Tcp sai do Host Bridge Kernel direto pra Vm!).
#
#    <interface type='bridge'>
#      <source bridge='ovs0'/>
#      <virtualport type='openvswitch'/>
#      <model type='virtio'/>            <---- Driver ParaVirtualizado Ring 
#      <!-- Mágica Do Vhost Multi-Queue para CPUs host rotearem threads -->
#      <driver name='vhost' queues='4'/>   
#    </interface>
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Erro comum: Instalação Indisível em Windows Server.
# Causa: O Kernel Windows trava pois o Barramento "virtio" não existe nativo Microsoft. 
# Solução: Adicione um SEGUNDO CDROM na Libvirt XML espelhando a ISO `virtio-win.iso`. 
# Na Instalação do Windows direcione os drivers pro CD e o disco/rede QEMU aparecerá!
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# VIRTIO-SCSI (O Super Controlador Massivo LUN)
# Virtio-blk atrela um tunel de cada disco individualmente. 
# Se tivermos 60 Discos num Servidor Oracle, Virtio-Blk sofreria com PCI slotting limits.
# O Senior injeta a controladora `<controller type='scsi' model='virtio-scsi'/>`.
# Ele cria 1 único Barramento Mega-Virtio HBA que atende centenas Luns agregadas.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Sua Virtual Machine contendo um Cluster Firewall opera sob o modelo virtio  
# usando Vhost. Contudo ela 'teta' nos parcos 2 Gbps batendo 100% CPU numa única Thread, 
# mas o link host é 25Gb. Como explodir a Bandwith da Vm diluindo o tráfego?"
# Resposta esperada: "Escalabilidade via Multi-Queue feature no virtio-net. 
# Especificando `<driver name='vhost' queues='num-threads'/>`, o KVM desmembra os 
# Buffers Rings de TX/RX gerando filas simétricas distribuídas para múltiplas vCPUs."
# ==============================================================================
