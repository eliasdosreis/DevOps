#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você testou seu terreno (Aula 01). Agora você precisa comprar as máquinas e
# contratar o síndico. 
# - QEMU/KVM: São os tratores e concreto, quem realmente constrói o prédio e 
#   passa os canos de água (emula os componentes).
# - libvirtd: É o síndico e o administrador do prédio. Ele não carrega cimento,
#   mas ele sabe onde todos estão morando, organiza a tabela de moradores e a rede.
# - virt-manager: É o tablet com a interface bonitinha que o síndico usa para
#   não precisar operar usando códigos no papel.
#
# 2. O QUE É (Definição Técnica Senior)
# KVM atua no kernel space (acelerador). QEMU atua no user space (emulador de
# hardware). 'libvirt' é a API (daemon e biblioteca C) que age como uma camada
# de abstração para não precisarmos executar comandos gigantescos no QEMU
# manualmente. 'virt-install' e 'virt-manager' são clientes que consomem a
# API do libvirt.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Instalar a stack completa de virtualização no Debian/Ubuntu ou RHEL
# ==============================================================================

# Verificando qual é o S.O (Debian-based x RHEL-based)
if [ -f /etc/debian_version ]; then
    echo "Instalando via APT (Debian/Ubuntu)..."
    # qemu-kvm: O backend principal integrado ao kernel
    # libvirt-daemon-system: O daemon principal (síndico) rodando como serviço
    # libvirt-clients: Provê o comando 'virsh'
    # bridge-utils: Necessário para fazer as bridges de rede clássicas (virbr0)
    # virtinst: Fornece o comando 'virt-install'
    # virt-manager: (Opcional) Interface gráfica via X11/Wayland
    sudo apt update
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
elif [ -f /etc/redhat-release ]; then
    echo "Instalando via DNF (RHEL/Fedora/CentOS)..."
    # No ecossistema RedHat, as ferramentas são agrupadas no módulo @virtualization
    sudo dnf install -y @virtualization qemu-kvm libvirt virt-install virt-manager
fi

echo "=== Habilitando e Iniciando o Daemon libvirtd ==="
# Obrigatório: Sem o daemon libvirtd rodando, você não consegue usar 'virsh'
sudo systemctl enable --now libvirtd

echo "=== Concedendo Permissões ao seu Usuário ==="
# Você não quer rodar TUDO como root sempre. Colocar seu usuário nos grupos 
# da libvirt permite administrar as VMs como usuário comum na conexão 'qemu:///system'
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)

# ==============================================================================
# 4. COMANDOS PASSO A PASSO
#
# Comando 1: systemctl status libvirtd
# - O que faz: Verifica se o "síndico" acordou e está trabalhando.
# - O que esperar: "Active: active (running)"
#
# Comando 2: virsh version
# - O que fez: Pergunta ao síndico com qual trator (hypervisor) ele consegue falar.
# - O que esperar: Deve listar as versões compiladas "da biblioteca" (libvirt) e
#   "do hypervisor" (QEMU/KVM).
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Ao rodar `virsh list`, retorna um erro de socket:
# "Failed to connect socket to '/var/run/libvirt/libvirt-sock': Permission denied"
# Causa: Seu usuário não foi adicionado ao grupo 'libvirt' (visto acima), ou as
# alterações de grupo ainda não surtiram efeito na sua sessão do terminal.
# Solução: Faça logoff completo e login novamente, ou rode `newgrp libvirt`.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Um junior se apavora quando o serviço `libvirtd` dá "CRASH" (falha), achando
# que todas as VMs foram desligadas. O Senior tem a calma de saber o que o libvirtd
# apenas "gerencia" o processo do QEMU. Se você matar o processo do `libvirtd`
# com `kill -9`, SUAS VMs CONTINUAREM RODANDO PERFEITAMENTE (!).
# O QEMU roda de forma independente. O libvirtd ao reiniciar, via Cgroups e
# PID files, simplesmente reassume a orquestração deles. A Libvirt não está no O caminho de dados (Data Path).
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se nós desligarmos o serviço `libvirtd` durante uma manutenção 
# noturna para um patch do pacote, haverá downtime (queda) nas VMs de produção em 
# andamento? Explique o motivo."
# Resposta esperada: "Não haverá downtime em VMs puras. O libvirt é uma camada 
# de orquestração de Control Plane (Plano de Controle). As VMs reais são processos 
# gerados e executados pelo QEMU no Data Plane. Enquanto o QEMU estiver em execução, 
# a rede e os discos continuam funcionando. Você perderá apenas temporariamente 
# a capacidade de gerenciar (iniciar/parar/monitorar) as VMs até que o libvirtd suba."
# ==============================================================================
