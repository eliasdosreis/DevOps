#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Criar uma VM via 'libvirt/virt-manager' é como comprar um PC da Dell pronto:
# Você clica e tudo liga mágicamente.
# Lançar via `qemu-system-x86_64` CLI pura é como ir na feira, e montar cada 
# cabo PCIe, conector da BIOS, HD e USB fio a fio na placa mãe. Se a energia pifar
# (Se fechar o terminal), você perde a máquina na mesma hora.
# O Sênior monta via CLI UMA ÚNICA VEZ na vida para entender como "a mágica da Dell funciona".
#
# 2. O QUE É (Definição Técnica Senior)
# O `qemu-system-ARCH` é o executável binário raiz. A libvirt nada mais é do que 
# um robô de script que gera uma string gigantesca e repassa a esse binário
# para rodá-lo invisívelmente (em background).
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Criar um HD e Instalar/Rodar um sistema via comandos brutos
# ==============================================================================

echo "=== 1. Criando o Disco Rígido Virtual ==="
# qemu-img é a suíte canivete-suíço que o mercado usa para Discos (Indispensável).
# 'qcow2' é o formato inteligente de sparse-file (Só cresce se for usado). Custa "zeros" em bytes inciais.
qemu-img create -f qcow2 meudisco_qemu.qcow2 10G

echo -e "\n=== 2. Baixando uma ISO ultra-minima (Alpine Linux) ==="
# Alpine bootavel super pequeno para nosso laboratório de QEMU puro não demorar
if [ ! -f "alpine.iso" ]; then
    wget -qO alpine.iso "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-virt-3.18.4-x86_64.iso"
fi

echo -e "\n=== 3. Lançando a Máquina Virutal Bruta pela CLI ==="
# Atenção: Este comando VAI ABRIR UMA JANELA se você estiver no Desktop GUI/Wayland.
# Se estiver num servidor SSH sem X11, ele vai travar o terminal reclamando do Display,
# para contornar num SSH usa-se `-nographic` (que repassa serial log direto na shell).

# DESTrinchando A MÁQUINA DE CHÃO DE FÁBRICA:
# -accel kvm          -> "Use Aceleração nativa por Hardware (Não caia no TCG Lento)".
# -m 512              -> "Forneça exatos 512MB RAM Host para V-Ram guest".
# -smp 2              -> "Symmetric Multiprocessing = 2 Núcleos de CPU".
# -drive file=..      -> "O HD criado via qemu-img, plugado em slot (VIRTIO ou SATA)".
# -cdrom alpine.iso   -> "A Mídia virtual no Drive de CDROM emulado IDE".
# -net nic -net user  -> "Placa de Rede User-mode NAT (A camada TCP é emulada na camada SLIRP nativa, isolada)".

qemu-system-x86_64 \
    -accel kvm \
    -m 512 \
    -smp 2 \
    -drive file=meudisco_qemu.qcow2,format=qcow2,if=virtio \
    -cdrom alpine.iso \
    -net nic,model=virtio \
    -net user \
    -boot d &

PID=$!
echo "Rodando a VM na tela com PID: $PID"
sleep 5
# kill $PID # Descomente para desligar forçado após ver

# ==============================================================================
# 4. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Ao fechar o terminal SSH, o servidor/VM desliga!
# Causa: A CLI foi vinculada ao seu TTY e ela está atuando em User-Space do SEU shell.
# O `qemu-system` é atrelado a sua sessão se não usar nohup/daemonize.
# Por isso DELEGA-SE a libvirt essa automação de daemon, log rotate, e init.D / SystemD rules.
# ==============================================================================

# ==============================================================================
# 5. CONCEITO SENIOR (O "porquê" profundo)
# Olhe para as flags `if=virtio` e `model=virtio` passadas acima!
# O Júnior esquece de passar essas tags. E consequentemente, o QEMU por default as emula
# no formato "IDE arcaico dos anos 90" (para discos) e "e1000/RTL8139" (Intel antiga/Realtek)
# para a placa de rede. A injeção de VIRTIO é mandatória no qemu-cli para altíssima
# escalabilidade, transformando o hypervisor numa rota direta e pulando interrupções IDE.
# ==============================================================================

# ==============================================================================
# 6. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Por que as empresas nunca escrevem scripts chamando `qemu-system-x86_64` 
# diretamente em produção, terceirizando TUDO sempre via XML no `Libvirt`?"
# Resposta esperada: "Ao rodar o qemu diretamente em CLI puro nós perdemos a gestão
# de processos (se o binário congelar, nada reinicia ele). Perdemos rótulos de SELinux, perdemos
# permissionamento Cgroups via root (limitadores de CPU host), não temos estado persistente limpo (XML) 
# para migração (Live Migration), além de os scripts de iptables atrelados a bridges não
# passarem por rotinas de sanitização feitas elegantemente e automaticamente pela Libvirt."
# ==============================================================================
