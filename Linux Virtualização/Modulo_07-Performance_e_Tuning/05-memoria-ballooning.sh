#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você alugou um Galpão pra 10 Empresas (VMs) com 10GB de espaço pra cada.
# Só que o seu Espaço Total Físico só tem 60GB! Você super-locou! (Overcommit).
# Durante a noite, uma empresa faz uma festa e pede os 10GB dela de uma vez.
# Você entra em pânico pois fisicamente só sobraram 5GB livres na sua base.
# 
# O "Ballooning": Você pega um balão vazio, entra escondido no galpão das outras 
# empresas que ESTÃO DORMINDO, e começa a inflar esse balão lá dentro.
# A empresa dormindo sente um objeto inflando em 5GB no quarto e pensa: 
# "Humm, minha RAM ta enchendo, vou liberar caches bestas e compactar minhas gavetas".
# O Balão inflado TOMA 5GB daquela empresa, mas MAGICA: O Balão físico reverte esses  
# 5Gbs pro Seu Galpão Mestre e você dá pra empresa que pediu!
#
# 2. O QUE É (Definição Técnica Senior)
# Driver `virtio-balloon` operando entre Qemu Monitor API e Host Kernel MMU.
# Permite ao Hypervisor requisitar ativamente (Inflar o balão) que a VM GUEST O.S 
# ceda páginas de RAM de L1/L2 Caches e anule elas de volta pro Sistema Hospedeiro em L0.
# ==============================================================================

# ==============================================================================
# 3. CONCEITOS e CLIs
# Objetivo: Como inflar e desinflar sob a lupa do comando CLI do Virsh.
# ==============================================================================

# Suponha que "vm-web-elastic" tenha `<currentMemory>16G</currentMemory>` MAX=32G

echo "=== 1. Verificar a Memória Atual ==="
# virsh dominfo vm-web-elastic

echo "=== 2. Set Active Memory Hot (Inflar/Desinflar) ==="
# O hypervisor host quer pegar RAM DE VOLTA, então mandamos a VM FICAR com apenas 8G!!
# Isso INFLA o driver do balão pra roubar os 8G de diferença.
# virsh setmem vm-web-elastic 8G --live

# A VM precisa de RAM extra pra um backup pesado? (Desinfle o Balão Host!).
# virsh setmem vm-web-elastic 16G --live

# ==============================================================================
# 4. PASSO A PASSO SR.
# ==============================================================================
# "Mas como isso acontece no Linux de forma segura?"
# O Driver do Balão chama no Guest a `alloc_page()` (Syscall). O Kernel DA VM Guest 
# pega páginas Livres (Caches Page Cache) e preenche elas de NADA pro driver balão. 
# O Driver Balão manda pro QEMU Host um Array "MADV_DONTNEED". 
# D Dizendo: "Kernel Host, as memorias virtuais nos endereços 0xABC ate 0xFF ta cheia
# de nada, pode DESALOCAR O P-RAM silício físico desso range pro seu uso Host". 

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Erro comum: Travar Database e derrubar Kernel Panic Na Vm Cliente!
# Causa: O Sênior mandou a VM ficar com "2G". Mas a VM tá rodando um Oracle SGA rígido!!! 
# O Oracle tá engolindo 12G de ram que ele não deflata... 
# O Balloon enche enche... o Oracle não larga, O Kernel Linux da VM enlouquece e aciona
# o OOM-Killer matando o ORACLE NA FACA pra tentar sanar o driver KVM.
# Solução: NUNCA USE BALLOONING aggressively em instâncias transacionais sensíveis (DBs).
# Memory Ballooning é pra Web-servers farm e Stateless containers.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O KSM (Kernel Samepage Merging) aliado com Balloon = The Magic Overcommit.
# Se o Host Host físico tiver ativado o daemon `ksmd`, O Kernel Host escaneia a 
# RAM e diz: "Nossa, tenho 10 VMs rodando Ubuntu. Eu tenho 10 Blocos idênticos de CoreLib C
# carregados NA MINHA RAM Fìsica ocupando espaço dobrado e triplicado D:!"
# O KSM Atômico Une as 10 Leituras numa Física Só, muda as 9 VMs pra "Read-Only Mapping"   
# pra aquele bloquinho, e LIBERA 9 blocos pra uso! Se uma das VMs escrever nela, KSM  
# des-unifica ela (Copy-on-write page fork). A economia de RAM Hoster beira de 15% a 30%.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se utilizamos Memória Ballooning pesadamente com o driver virtio em nossas
# instâncias OpenStack, um de nossos clientes relata que o contador de memória `free -m` 
# do Linux Host diz '20 GB free', contudo ele tenta forçar um `setmem 24GB` na base dele e
# a operação recaba num hard OOM. Por que o hypervisor aceitou falhou em re-alloc 
# se existia espaço visual e como o virtio-balloon reportava esse erro na ABI?"
# Resposta esperada: "Se o Host aparentava RAM livre sob buffers host, o virtio-balloon  
# age primariamente via cooperação do sistema operacional Convidado. O hypervisor (Libvirt) manda
# a requisição, e o Qemu repassa via PCI pro Guest de que ele deverá MINGUAR (Desinflar o balão cedendo 
# as RAM caches host side page). Mas o O.S Convidado pode recusar tacitamente ou 
# retardar assincronamente a devolução se esgotamento interno o privar. A `setmem` subida só injetará
# fisicamente se a soma total não for excedica do hardware Host somado. Em ambientes de Super Overcommit
# se o Host exaure sua cota Swapping space física e o balão falha demograficamente, o System Daemon
# não tem salvação senão abortar syscalls Ioctl do p-node inteiro."
# ==============================================================================
