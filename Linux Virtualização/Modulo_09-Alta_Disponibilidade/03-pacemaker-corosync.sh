#!/bin/bash
# ==============================================================================
# Módulo 09 — Configurando um Cluster HA com Pacemaker + Corosync
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
#
# Imagine duas equipes de bombeiros em cidades vizinhas (Nó A e Nó B).
# Elas se comunicam por rádio constantemente: "Aqui Node-A, estou ok!"
# Se Node-A para de responder, Node-B assume TODAS as ocorrências automaticamente.
# Mas antes de assumir, Node-B envia um sinal para DESLIGAR o rádio e o caminhão
# de Node-A (STONITH/Fencing) — garantindo que os dois não respondam ao mesmo
# chamado ao mesmo tempo (split-brain).
#
# O Pacemaker é o Despachante Central que decide quem assume o quê.
# O Corosync é o sistema de rádio de comunicação entre os bombeiros.
# O STONITH é o botão de emergência que força o outro a desligar.
# ==============================================================================

set -euo pipefail

echo "==========================================="
echo " Módulo 09 — Cluster HA KVM (Conceitual)"
echo "==========================================="

# ==============================================================================
# 3. INSTALAÇÃO DA STACK PACEMAKER+COROSYNC
# ==============================================================================

echo ""
echo "=== PASSO 1: Instalar stack HA (AMBOS os nós) ==="
echo ""
echo "# No Ubuntu/Debian:"
echo "apt install -y pacemaker corosync pcs fence-agents-all"
echo ""
echo "# No RHEL/AlmaLinux/Rocky:"
echo "dnf install -y pacemaker corosync pcs fence-agents-all"
echo ""
echo "# Habilitar e iniciar o PCS daemon:"
echo "systemctl enable --now pcsd"
echo ""
echo "# Definir senha para usuário hacluster (MESMO em ambos os nós!):"
echo "echo 'SENHA_FORTE' | passwd --stdin hacluster"

# ==============================================================================
# 4. CONFIGURAÇÃO DO CLUSTER
# ==============================================================================

echo ""
echo "=== PASSO 2: Inicializar o cluster (apenas no Nó A) ==="
echo ""
echo "# Autenticar os nós entre si:"
echo "pcs host auth kvm-node-a kvm-node-b -u hacluster -p SENHA_FORTE"
echo ""
echo "# Criar o cluster:"
echo "pcs cluster setup CLUSTER-KVM-PRODUCAO kvm-node-a kvm-node-b"
echo ""
echo "# Iniciar o cluster:"
echo "pcs cluster start --all"
echo "pcs cluster enable --all"
echo ""
echo "# Verificar status:"
echo "pcs status"

# ==============================================================================
# 5. CONFIGURANDO FENCING (STONITH) — OBRIGATÓRIO PARA HA REAL!
# ==============================================================================

echo ""
echo "=== PASSO 3: Configurar STONITH/Fencing (IPMI) ==="
echo ""
cat <<'EOF'
# Exemplo com IPMI (Intelligent Platform Management Interface)
# Cada nó deve ser capaz de desligar o OUTRO via IPMI BMC

# Fencing para kvm-node-a (executado pelo node-b se node-a falhar):
pcs stonith create fence-node-a fence_ipmilan \
  pcmk_host_list="kvm-node-a" \
  ipaddr="192.168.1.101" \
  login="admin" \
  passwd="ipmi-senha" \
  lanplus=1 \
  op monitor interval=60s

# Fencing para kvm-node-b (executado pelo node-a se node-b falhar):
pcs stonith create fence-node-b fence_ipmilan \
  pcmk_host_list="kvm-node-b" \
  ipaddr="192.168.1.102" \
  login="admin" \
  passwd="ipmi-senha" \
  lanplus=1 \
  op monitor interval=60s

# Regra de localidade: cada nó faz fence apenas do outro (não de si mesmo)
pcs constraint location fence-node-a avoids kvm-node-a
pcs constraint location fence-node-b avoids kvm-node-b

# TESTAR fencing ANTES de produção!
pcs stonith fence kvm-node-b    # kvm-node-b deve desligar imediatamente!
EOF

# ==============================================================================
# 6. CRIANDO RECURSOS DO CLUSTER — AS VMs COMO RECURSOS HA
# ==============================================================================

echo ""
echo "=== PASSO 4: Registrar VMs como recursos do cluster ==="
echo ""
cat <<'EOF'
# O recurso VirtualDomain faz o pacemaker gerenciar a VM via libvirt!
pcs resource create VM-WEB-01 VirtualDomain \
  hypervisor="qemu:///system" \
  config="/etc/libvirt/qemu/vm-web-01.xml" \
  migration_transport=ssh \
  op start   timeout=120s \
  op stop    timeout=120s \
  op monitor timeout=30s interval=10s \
  op migrate_from timeout=300s interval=0s \
  op migrate_to   timeout=300s interval=0s

# Configurar preferência de localidade (VM prefere rodar no node-a):
pcs constraint location VM-WEB-01 prefers kvm-node-a=100

# Configurar migração automática antes de fazer fence (evita downtime):
pcs resource meta VM-WEB-01 allow-migrate=true
EOF

# ==============================================================================
# 7. TESTANDO FAILOVER E HA
# ==============================================================================

echo ""
echo "=== PASSO 5: Testar failover (simular falha) ==="
echo ""
cat <<'EOF'
# Método 1: Colocar um nó em standby (simulação de manutenção)
# A VM será migrada AUTOMATICAMENTE para o outro nó (live migration!)
pcs node standby kvm-node-a
pcs status    # Deve mostrar VM rodando em kvm-node-b

# Reativar o nó após manutenção:
pcs node unstandby kvm-node-a
pcs resource move VM-WEB-01 kvm-node-a  # Mover de volta (opcional)

# Método 2: Simular falha total (apenas em LAB!)
# Desligar o nó a força:
# ssh kvm-node-a "systemctl poweroff"
# O cluster detectará em ~30s e fará fencing + failover automático

# Verificar tempo de failover (deve ser < 60s em configs corretas):
time pcs status
EOF

# ==============================================================================
# 8. QUÓRUM E CONFIGURAÇÃO PARA 2 NÓS
# ==============================================================================

echo ""
echo "=== PASSO 6: Configurar quórum para cluster de 2 nós ==="
echo ""
cat <<'EOF'
# Em clusters de 2 nós, o padrão causa problema de quórum quando 1 falha
# (50% < 51% necessário). Configurações especiais:

# Opção 1: two_node=1 (habilita votação 1 de 2 como quórum)
# /etc/corosync/corosync.conf:
# quorum {
#   provider: corosync_votequorum
#   two_node: 1           # 1 nó é suficiente para quórum!
#   wait_for_all: 1       # Aguarda todos os nós no boot inicial
# }

# Opção 2: Qdevice (terceiro árbitro leve — recomendado para produção):
# Em um terceiro servidor (não precisa ser poderoso):
pcs qdevice setup model net --enable --start  # No servidor árbitro
# Nos nós do cluster:
pcs quorum device add model net \
  host=qdevice.datacenter.local \
  algorithm=lms
EOF

# ==============================================================================
# 9. PERGUNTA DE ENTREVISTA
# ==============================================================================

echo ""
cat <<'EOF'
PERGUNTA DE ENTREVISTA (Nível Sênior):

"Você tem um cluster Pacemaker de 2 nós rodando 30 VMs críticas sem fencing
configurado (o gestor disse que cortar energia remotamente era 'perigoso').
Às 3am, o Node-A perde a rede mas continua ligado e operando as 30 VMs.
O cluster detecta Node-A como morto. Sem fencing, o que acontece?"

RESPOSTA ESPERADA:
"Sem fencing, o pacemaker no Node-B vê Node-A como morto mas não pode
CONFIRMAR que ele está offline. O Pacemaker ficará em estado 'fencing pending'
INDEFINIDAMENTE — ou seja, as 30 VMs de Node-A NÃO serão iniciadas no Node-B.
O cluster sacrifica a disponibilidade para proteger a integridade dos dados.

Isso é o comportamento CORRETO e SEGURO do cluster, mas o resultado prático
é: 30 VMs fora do ar até a intervenção manual.

A resolução manual seria:
1. Verificar fisicamente que Node-A está desligado
2. Marcar Node-A como 'stonith-confirmed' manualmente:
   pcs stonith confirm kvm-node-a
3. O Pacemaker iniciará as VMs no Node-B

A lição: fencing não é opcional em produção. Sem ele, você não tem HA — 
tem apenas 'dois nós que tentam ser HA mas travam em split-brain'.
O correto é convencer o gestor com a analogia: o fencing é o interruptor
de segurança da usina nuclear — SEM ele, o sistema inteiro paralisa."
EOF
