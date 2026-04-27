#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você tem um Chefe de Cozinha (Sua VM de alto processamento, Banco de Dados). 
# Você tem 32 Bocas de Fogão no Restaurante (CPus físicas).
# Por padrão, o Gerente do salão (Scheduler Linux Host) manda o chefe cozinhar 
# 1 minuto na Boca 1, no prox minuto Manda o Chefe Trocar todas de Panelas pra Boca 12. Depis ele corre pra Boca 20. 
# O Chefe perde um precioso tempo MUDANDO DE LUGAR o tempo todo (Context Switch Penalty / Cache Misses / Limpar a Memória Cache L2/L3 entre as CPUs Físicas).
# O **CPU PINNING** (Afixamento) é você fechar a porta pra 4 Bocas do Fogão, dar 
# a chave na mão da VM e ditar: "A partir de Hoje Você SÓ RODA o seu O.S Exclusivamente nas CPUS fisicas 4, 5, 6 e 7, 
# e mais ninguem te atrapalha." A velocidade explode.
#
# 2. O QUE É (Definição Técnica Senior)
# CPU Pinning/Affinity é regrar restritamente o "Completely Fair Scheduler" (CFS)
# mapeando Threads do Processo QEMU `vCPU` atrelado aos Cores Físicos `pCPU` específicos do Host.
# ==============================================================================

# ==============================================================================
# 3. CONCEITOS e CLIs COMENTADAS
# Objetivo: Como inspecionar quem ta rodando aonde?
# ==============================================================================

# O virsh tem as funções vcpupin cruas:
# Observe os cores pCPU que a VM01 esta alocada na placa mae host:
echo "Executando pseudo-comando virsh vcpuinfo vm_lab..."
# Exemplo Saída: 
# VCPU:           0          (Vcpu 0 dentro da Vm Guest)
# CPU:            15         (Roda no núcleo Real Físico 15 do Host Socket!)
# State:          running
# CPU Affinity:   yyyyyyyyyyy-yny----.   (Olha as máscaras dizendo nos P-CPUs que ela pode sambar pra cá e pra lá)

echo "=== 4. Isolando Cgroups a quente ==="
# Trava MANUALMENTE a vCPU 0 SOMENTE no Core hospedeiro FÍSICO 2!
# virsh vcpupin vm_lab 0 2 --live
# Para a vCPU 1 da Vm na CPU fisica 3
# virsh vcpupin vm_lab 1 3 --live


# ==============================================================================
# O CÓDIGO XML DO SÊNIOR PRA PINAGEM FIXA AUTOMÁTICA
# ==============================================================================
# Você NÃO fará vcpupin com a Cli na linha de comando e perder no boot, o sênior embuti no XML definitivo.
# Adicionamos ao XML as propriedades "cputune":
#
#  <vcpu placement='static'>4</vcpu>
#  <cputune>
#    <!-- A vcpu 0 guest fica atada a pcpu físico 2 -->
#    <vcpupin vcpu='0' cpuset='2'/>
#    <!-- vcpu 1 atada ao físico 3 -->
#    <vcpupin vcpu='1' cpuset='3'/>
#    <!-- O PROCESSO emulador do qemu do chassi (Tráfego, mouse, io) fica isolado nas Cpus Físicas 0 e 1, desafogando!  -->
#    <emulatorpin cpuset='0-1'/>
#  </cputune>
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Pinagem Destrutiva!
# O Júnior faz pinning da VM-Oracle nas CPUs físicas(0 e 1). Na máquina HOST tem Processos Host SysAdmin Systemctl que AMAM
# rodar na CPU 0 por Default da Kernel Base. A VM e o ROOT HOST batalham até 
# morte no scheduler do Core 0 causando I/O travamento em cascata dpc/irq balance.
# 
# Solução: O Sênior usa os Kernel boot parameters (No Grub `isolcpus=2-15`). Isso ESCONDE as CPUS do host Master root Linux (Nenhuma thread de apache vai atuar nelas e caem todas pra cpus sobradas 0/1). 
# E na libvirt o sênior destranca essas CPUs "Sagradas Isoladas" unicamente pra pass-through das suas VMs High-Perf Pinadas XML. (Host Limite Isolation Mode L3).
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# SMT/HyperThreading Topologies.
# A CPU Intel mostra Vcpus no Linux: 0 e 1 (Core Físico), Depois mostra "2 e 3" e etc.. 
# Se a documentação do LsCPU diz "Thread(s) per core: 2". Significa que a CPU 0 e a CPU 1 (No Host Systemd)
# Compartilham O MESMO CORE DE SILÍCIO (Elas disputam a ALU/Cash L1 entre elas por serem Irmãs).
# Se O Junior Pinar VCPU(0) em HOST-PCPU(0), e dps uma VCPU(1) em HOST-PCPU(1), Ele basicamente entregou para VM
# 1 Núcleo Físico real capenga tentando processar 2 execuçoes estourando Hyperthreading L1 Thrashing misses.  
# O Sênior rodará `lscpu -e` e descobrirá a arvore do silício exata, entregando a ela Cores Independentes que não dividem SMT (Ex: atrelando 0 e 4) caso busquie máxima isenção.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se nós atrelarmos hard-pinning (vcpupin com cpuset fixos) numa das 
# arquiteturas de cluster do Datacenter gerenciadas por Live-Migrations dinâmicas (ex VMs voando do Server A para Server B de madrugada).
# Qual é o risco catastrófico do acoplamento e fixação nas topologias XML no tocante à migração ativada?"
# Resposta esperada: "Se o `cpuset` estiver instanciado estaticamente via XML, p. ex isolando a VCPU aos pinamentos Cores pCPU `18-32`. 
# Se a VM ativar Live-Migration e for recebida no 'Server Node B', e aquele Hardware Destino possuir um 
# processador diferente com APENAS 16 Núcleos, o Scheduler KVM Destination Kernel rejeitará ou quebrará instantaneamente
# as máscaras Cgroups no arrival thread, matando em SIGKILL o processor space do Guest por violação de range out-of-bounds da cputune list.
# Portanto, ambientes Cloud de Alta Migratiblidade não podem emborrachar pinning fixo em Cpusets por Máquina VM, devendo usar Pinning por Perfis Auto-Detectables."
# ==============================================================================
