# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# ==============================================================================
# O Hipervisor KVM tem que entregar a VRAM de 32Gbs em pratos de papel na mão  
# da Vm Convidada Lendo.
# A Página "Normal" de RAM no Kernel é picota num padrão miserável de "4 KiloBytes".
# Para a VM processar 32 GBs e achar um dado na RAM, a CPU Host passa a vida inteira 
# LENDO MIlhões de papilhas infímas (Page Table Walks da MMU). O Processamento vira
# um gargalo catastrófico nos Indexes da CPU Cache de Tradução (TLB Miss).
# 
# Solução the Huge Pages: Você embala a RAM host em "Caixas de 1 GIGABYTE".
# Você dá à VM 32 Caixotes. É isso. Imediato mapeamento, processador não engasga em varrredura.

# ==============================================================================
# 2. O QUE É (Definição Técnica Senior)
# ==============================================================================
# **HugePages** é a capacidade do Kernel Host OS e QEMU Guest de trabalharem Ligas de blocos
# contíguos de (2MB - Tradicional Server HugePage) ou (1GB Massives).
# A TLB (Translation Lookaside Buffer no Hardware da Intel CPU) armazena referências de RAM físico/virtual.
# Diminuir a quantida massiva de fragmentos de 4kb na RAM reduz TLB Miss penalities a quasero zero.

# ==============================================================================
# 3. VERIFICAÇÃO E TROUBLESHOOTING NO HOST KVM
# ==============================================================================
# O Host tem Hugepage ativado? Rode:
# `grep Huge /proc/meminfo`
# AnonHugePages:  20000 kb  -> Esse cara ai que destrói a vida da Memória (Transparent).
# HugePages_Total: 1000     -> Static allocation pré reservada para nós no QEMU.

# O Junior deixa por "Default Cloud". O Linux roda algo maligno chamado:
# THP (Transparent Huge Pages - Defragmentation auto). O kernel tenta mesclar RAM em background de 4kb p/ 2mb dma. 
# Quando você tem Banco de dados pesados e libvirt, isso CAUSA SPIKES TRAVAMENTOS DE 2 segundos na CPU em picos 
# The compaction algorithm freeza os threads lock-system base.
# Desative o transparent num Oracle Deploy Host (echo never > /sys/kernel/mm/transparent_hugepage/enabled).

# ==============================================================================
# 4. CONFIGURANDO LIBVIRT COM STATIC HUGE PAGES NO ISOLAMENTO
# ==============================================================================
# Como o Sênior usa a força bruta real e constante:
# Exige-se Static pre-reserved Pools de 1G at boot parameters no root grub (`hugepagesz=1G hugepages=32`).
# E No XML DA SUA MÁQUINA no Libvirt. O pulo que liga a máquina no cano rápido.
#
#   <memory unit='GiB'>32</memory>
#   <memoryBacking>
#     <hugepages>
#         <!-- Atala todas aquelas caixas enormes de 1gb pré configuradas ao Processo QEMU-->
#         <page size='1' unit='GiB' nodeset='0'/>
#     </hugepages>
#     <locked/>
#   </memoryBacking>

# ==============================================================================
# 5. CONCEITO SENIOR (O "porquê" profundo)
# ==============================================================================
# A tag `<locked/>` MemLock do mlock() C API.
# Dar caixas de 1GB resolve 90% do problema.  E O Que acontece se o Host RAM acabar em Overcommit?   
# O Linux host vai dizer "Vou salvar esse caixote inteiro de 1GB da Mémoria no Disco de HD de swap no var/... pra liberar
# a RAM prum Servidor de e-mail respirar. Swapping a RAM no Disco SSD. 
# 1 gb de swap I/o e qnd a VM pedir de volta o I/o reverso read, causa morte súbita latencies 4000ms+. 
# A clausula MemoryBackingLocked  impede as sub-rotinas de swap Host de atreverem enconstar Page-outs dos endereços 
# virtuais da maquina hospedeira, forçando a permanencia na matriz Física SRAM real pro resto da vida.

# ==============================================================================
# 6. PERGUNTA DE ENTREVISTA (Nível Senior)
# ==============================================================================
# Pergunta: "Sua Virtual Machine contendo um Cluster Elasticsearch crítico recebeu o Tuning  
# XML para Backing store Hugepages Estáticos (1GB Size). 
# Contudo, o Host tem 128G e estava a semanas rodando sem hugepages pre-configuradas em cold-boot start.  
# O Operador tenta instanciar allocating dinamico ecoando 64G via `sysctl -w vm.nr_hugepages=64`.
# Ao invés de obter sucesso, The kernel alloc retornou Out Of Memory (Ooom) e reservou apenas 4 Gb na pool enorme. 
# Por que a alocação dinâmica falhou absurdamente numa máquina com 100GB livres via utilitarios meminfo, e como resolvê-lo?"
# 
# Resposta esperada: "Hugepages Estáticas, e notariamente ordens massivas como 1GB blocks  
# OBRIGAM por princípio físico kernel o isolamento de porções de Memória RAM absolutamente CONTÍGUAS fisicamente na p-layer. 
# Uma maquina ligada há semanas sofre com High Memory Fragmentation, e embora demonstre
# 100GB "livres", os seus blocos livres estão espalhados como grãos em esburacados offsets. 
# O Allocator Kernel não encontra corredores atômicos longos e ininterruptos de 1 Gigabyte sem esbarrar 
# num processo trancado, abortando num Memory Fragmented Deficit allocation. Por essa via 
# servidores VM Masters devem assegurar parâmetros syslinux hard-boot GRUB (`default_hugepagesz=...`)
# que reservam a área VIP em Zero-Time boot, antes qlq outro aplicativo se quer pense em instanciar endereços lógicos picados sujos."
# ==============================================================================
