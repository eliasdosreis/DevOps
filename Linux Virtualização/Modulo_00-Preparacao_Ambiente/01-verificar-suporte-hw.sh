#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Imagine que você comprou um terreno para construir um prédio de apartamentos (Virtualização).
# Antes de trazer os tratores, você precisa avaliar se o solo (Processador)
# suporta o peso de um prédio de vários andares. Se o solo for muito mole (sem suporte
# a virtualização por hardware), você até consegue construir, mas será lento e
# instável (emulação via software). Se o solo for firme (Intel VT-x / AMD-V),
# você pode construir prédios enormes e eficientes.
#
# 2. O QUE É (Definição Técnica Senior)
# Virtualização assistida por hardware é uma extensão na arquitetura x86
# (Intel VT-x ou AMD-V) que permite que o hypervisor (KVM) execute instruções
# de CPU das VMs diretamente no hardware físico, quase sem overhead. Sem isso,
# o hypervisor teria que traduzir cada instrução (emulação), o que é terrível
# para performance.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Verificar suporte a hardware e módulos do KVM
# ==============================================================================

echo "=== Verificando extensões de CPU ==="
# 'vmx' é a flag da Intel (Virtual Machine Extensions)
# 'svm' é a flag da AMD (Secure Virtual Machine)
# Se a contagem for maior que 0, seu processador suporta virtualização física.
USO_HW=$(grep -Ec '(vmx|svm)' /proc/cpuinfo)

if [ "$USO_HW" -eq 0 ]; then
    echo "FALHA: Nenhuma extensão de hardware detectada. Você só poderá rodar emulação."
else
    echo "SUCESSO: Seu processador suporta virtualização por hardware ($USO_HW threads detectadas)."
fi

echo -e "\n=== Verificando módulos de Kernel ==="
# O KVM é um módulo embutido no Linux. Para usá-lo, o módulo kvm_intel ou kvm_amd
# precisa estar carregado.
lsmod | grep kvm

echo -e "\n=== Verificando o dispositivo Character KVM ==="
# O QEMU usa este arquivo especial no Linux para se comunicar com o hypervisor KVM
# no Kernel-space. Se isso não existir, as VMs falham ao iniciar.
ls -la /dev/kvm

# ==============================================================================
# 4. COMANDOS PASSO A PASSO
#
# Comando 1: lscpu | grep Virtualization
# - O que faz: Um comando mais amigável que ler o /proc/cpuinfo.
# - O que esperar: "Virtualization: VT-x" ou "Virtualization: AMD-V"
# 
# Comando 2: stat /dev/kvm
# - O que faz: Verifica quem é dono do dispositivo KVM.
# - O que esperar: Pertence ao root, e ao grupo 'kvm' (Gid: (   XX/     kvm))
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: O /proc/cpuinfo mostra 0 (sem suporte), MAS você sabe que comprou
# um processador Intel Core i9. 
# Causa: A virtualização está desativada na BIOS/UEFI da sua placa-mãe.
# Solução: Reiniciar, entrar na BIOS e habilitar "Intel Virtualization Technology" 
# ou "SVM Mode" (AMD).
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Juniores apenas sabem que precisam ativar na BIOS. Seniores sabem sobre
# Nested Virtualization (Virtualização Aninhada). Se você estiver rodando este
# script de DENTRO de uma VM na nuvem (AWS/GCP), ele dirá que NÃO tem suporte (0),
# a menos que o provedor libere Pass-through de flags da CPU para a sua VM.
# Isso se chama Nested Virt. O Senior sabe habilitar o KVM para aceitar Nested:
# cat /sys/module/kvm_intel/parameters/nested -> 'Y' (sim) ou 'N' (não).
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Sua VM está extremamente lenta. Você confere as configurações e nota 
# que o /dev/kvm existe, mas percebe que a libvirt/QEMU não está usando ele. 
# Como você garante, dinamicamente no terminal, que o KVM Nested está habilitado 
# ou como verificar os parâmetros do módulo?"
# Resposta esperada: "Eu usaria o comando `systool -m kvm_intel -v` ou olharia 
# diretamente em /sys/module/kvm_intel/parameters/. Além disso, eu bateria o dmesg 
# (`dmesg | grep kvm`) para ver se o kernel desabilitou o suporte de hardware 
# no boot devido a algum erro de IOMMU ou inconsistência de BIOS."
# ==============================================================================
