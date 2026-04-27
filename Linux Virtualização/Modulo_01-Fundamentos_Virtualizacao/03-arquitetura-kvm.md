# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# ==============================================================================
# Imagine que o kernel Linux (O Gerenciador do Servidor) seja o Síndico Chefe.
# Historicamente, o síndico apenas tratava a sua máquina como UM GRANDE APARTAMENTO.
# Mas com a popularização da virtualização, a Intel/AMD forneceram plantas que 
# permitiriam separar esse apartamento em vários menores.
# O **KVM** (Kernel-based Virtual Machine) é uma DLC ou "Certificado Especial de Múltiplos 
# Residentes" que o Síndico Chefe obteve. Com o KVM, o Linux descobre, organicamente, 
# como controlar esses mini-apartamentos (VMs) alavancando os seguranças e ferramentas
# que JÁ EXISTIAM: Gestão de Memória (para as VMs), O Scheduler de tempo (Para não ter travamentos),
# e escalabilidade nativa. Ele não precisa escrever outro sistema operacional.

# ==============================================================================
# 2. O QUE É (Definição Técnica Senior)
# ==============================================================================
# KVM transforma o núcleo (kernel) Linux em um hypervisor ao introduzir o processo 
# no sistema padrão: a criação de ambientes virtuais via o device `/dev/kvm`.
# Ele não abstrai rede, mouse nem vídeo (ele odiaria fazer isso por peso). Ele apenas
# injeta contexto na CPU e na RAM que diz "O próximo clock é para a Virtual Machine X".
#
# Quem faz o resto (Emular o chip de vídeo VGA ou Cirrus, emular o chip USB e o disco)?
# É o **QEMU**, que roda em Userspace.

# ==============================================================================
# 3. CONCEITOS e ARQUITETURA
# ==============================================================================
# A tríade do sistema:
# +---------------------------------------------------------+
# |           Guest / Maquina Virtual OS (Ex: Ubuntu)       |
# +---------------------------------------------------------+
# |        Processo QEMU  (Emulador HW) (Userspace)         |
# |                  <-> API POSIX/Fio <->                  |
# +---------------------------------------------------------+
# |              Kernel Linux / Módulo KVM                  |
# | (Gerencia Memória da VM e escalonamento da Virtual CPU) |
# +---------------------------------------------------------+
# |   Hardware Físico (Intel VT-x, AMD-V, NVMe SSDs, RAM)   |
# +---------------------------------------------------------+

# ==============================================================================
# 4. FUNCIONALIDADE DO MODULO
# ==============================================================================
# Cada núcleo (vCPU) que você dá para uma VM aparece no htop/top do sistema host 
# físico como sendo APENAS uma thread (POSIX thread) normal do seu QEMU.
# Ou seja, o escalonador Completely Fair Scheduler (CFS) do Linux enxerga 
# vCPUs de máquinas virtuais exatamente da mesma forma que enxerga o Google Chrome
# rodando num notebook. E usa todas as otimizações milimetradas já conhecidas nesses 30 anos.

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ==============================================================================
# Você pode provar a eficácia da thread se você tiver uma VM rodando e o seu host
# dar problema usando todos os recursos no HTOP do host:  
# Procure por "qemu-system-x86_64". Esse grande processo é O SEU SERVIDOR RODANDO e alocando.
# Erro: Você comprou a sua VM na GCP com 32 CPUs. O que isso significa sob a stack de arquitetura?
# Que o processo qemu principal solicitou à API do Libvirt 32 threads de sistema que o
# kernel físico "congela" e disponibiliza pro processo QEMU-KVM na via rápida IOCTL.

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# ==============================================================================
# Quando não usavamos KVM, o QEMU precisava emular TODO O CÓDIGO de x86 para x86.
# Isso usava o modo TCG (Tiny Code Generator) base, extremamente lento e dispendioso em
# recompilações dinâmicas de binários JIT. Ao inserir KVM via diretiva `/dev/kvm` ou `enable-kvm` 
# na shell do qemu, o TCG cessa. O código executa direto no Silício pass-around (IOMMU), 
# operando através de uma syscall assíncrona incrivelmente pesada chamada `ioctl(KVM_RUN)`.
# Um Administrador de sistemas Sênior lendo um `strace` consegue verificar um I/O wait
# excessivo num banco de dados na VM verificando as pausas (VM-Exits) dessas system calls.

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# ==============================================================================
# Pergunta: "Se nós pararmos um processo 'qemu-system-x86_64' correspondente à uma de
# nossas VMs rodando e enviarmos um signal `kill -SIGSTOP PID` via BASH do sistema Host.
# O que ocorrerá sob a perspectiva do KVM e o que o cliente sentirá logado dentro dela via SSH?"
# Resposta esperada: "Processos na base QEMU/KVM são tratados pelo kernel Linux como
# user-threads padrão (embora suportadas pelo contexto KVM p/ hardware). O envio de `SIGSTOP`
# fará todo o processo hipervisor dessa VM PAUSAR instantaneamente sua execução sem travamentos
# ou pânicos no sistema de arquivos. Para o cliente da VM no SSH será como se o 'Tempo parasse', 
# o ping vai expirar ou pausar, e só haverá resposta se ou quando continuarmos repassando 
# `kill -SIGCONT PID`."
# ==============================================================================
