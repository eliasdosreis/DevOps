#!/bin/bash
# ==============================================================================
# Módulo 10 — Hardening Prático e Auditoria de Segurança em VMs KVM
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
#
# Pense numa auditoria bancária.
# O auditor não confia nem no gerente — ele verifica TUDO:
# cofres trancados? câmeras funcionando? acesso ao cofre restrito?
# logs de quem abriu o quê e quando?
#
# A auditoria de segurança KVM é igual:
# Não confie que o padrão está seguro — VERIFIQUE cada camada,
# REGISTRE cada acesso, BLOQUEIE tudo que não é necessário.
# ==============================================================================

set -euo pipefail

echo "==========================================="
echo " Módulo 10 — Hardening e Auditoria KVM"
echo "==========================================="

# ==============================================================================
# 3. VERIFICAÇÃO DE POSTURA DE SEGURANÇA (Security Posture Check)
# ==============================================================================

echo ""
echo "=== AUDITORIA 1: Verificar SELinux/AppArmor ==="

# SELinux (RHEL/CentOS/AlmaLinux/Fedora)
if command -v getenforce &>/dev/null; then
    SELINUX_STATUS=$(getenforce)
    if [ "$SELINUX_STATUS" = "Enforcing" ]; then
        echo "✓ SELinux em modo ENFORCING — OK"
    else
        echo "✗ SELinux em modo ${SELINUX_STATUS} — PROBLEMA DE SEGURANÇA!"
        echo "  Corrigir: setenforce 1 && sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config"
    fi
fi

# AppArmor (Ubuntu/Debian)
if command -v aa-status &>/dev/null; then
    if aa-status --enabled 2>/dev/null; then
        echo "✓ AppArmor ativo"
        ENFORCED=$(aa-status | grep "profiles are in enforce mode" | awk '{print $1}')
        echo "  Perfis em enforce: ${ENFORCED:-0}"
    else
        echo "✗ AppArmor desabilitado — RISCO!"
    fi
fi

echo ""
echo "=== AUDITORIA 2: Labels sVirt das VMs ==="
echo "Processos QEMU com labels SELinux:"
ps auxZ 2>/dev/null | grep "[q]emu" | awk '{print $1, $NF}' | head -10 || \
  echo "(executar em host Linux com VMs ativas)"

echo ""
echo "=== AUDITORIA 3: Permissões de disco ==="
echo "Verificando permissões dos discos de VM:"
find /var/lib/libvirt/images/ -name "*.qcow2" -o -name "*.img" 2>/dev/null | \
  xargs ls -la 2>/dev/null || echo "(nenhum disco encontrado ou diretório vazio)"

# Discos devem ser 0600 owner qemu:qemu ou root:root
# Se forem world-readable (644) é um risco!

echo ""
echo "=== AUDITORIA 4: VMs com devices perigosos ==="
# Procurar VMs com PCI passthrough (acesso a hardware físico)
for VM in $(virsh list --name 2>/dev/null); do
    if virsh dumpxml "$VM" 2>/dev/null | grep -q "hostdev"; then
        echo "⚠ VM '$VM' tem PCI passthrough — verificar se é intencional"
    fi
done
echo "Verificação de PCI passthrough concluída"

# ==============================================================================
# 4. CONFIGURAR AUDITD PARA RASTREAR AÇÕES LIBVIRT
# ==============================================================================

echo ""
echo "=== HARDENING: Configurar auditd para libvirt ==="

cat <<'AUDIT_RULES'
# Adicionar ao /etc/audit/rules.d/libvirt.rules:

# Rastrear TODAS as modificações em configurações XML das VMs
-w /etc/libvirt/qemu/ -p wa -k libvirt-config-change

# Rastrear acesso aos discos de VM (identifica leituras suspeitas)
-w /var/lib/libvirt/images/ -p rwa -k libvirt-disk-access

# Rastrear uso do virsh (quem está gerenciando VMs?)
-a always,exit -F exe=/usr/bin/virsh -k virsh-commands

# Rastrear conexões ao socket libvirt
-w /run/libvirt/libvirt-sock -p rwa -k libvirt-socket

# Reload das regras:
# augenrules --load
# systemctl restart auditd
AUDIT_RULES

echo "Regras de auditoria exibidas (adicionar manualmente ao sistema)"

# ==============================================================================
# 5. ISOLAMENTO DE REDE — VERIFICAÇÃO DE FIREWALLING
# ==============================================================================

echo ""
echo "=== AUDITORIA 5: Isolamento de Rede das VMs ==="

# Ver regras de iptables/nftables gerenciadas pela libvirt
echo "Regras de firewall da libvirt (iptables):"
iptables -L LIBVIRT_FWD -n 2>/dev/null | head -20 || \
  echo "(iptables não disponível ou sem regras libvirt)"

echo ""
echo "Redes virtuais ativas:"
virsh net-list --all 2>/dev/null || echo "(libvirt não disponível)"

# Verificar se alguma VM tem interface diretamente em rede física (bridge mode)
echo ""
echo "VMs com bridge direta à rede física (VERIFICAR se intencional):"
virsh net-list --all 2>/dev/null | grep -i "bridge" | head -10 || true

# ==============================================================================
# 6. CONFIGURAR QEMU COM USUÁRIO NÃO-ROOT
# ==============================================================================

echo ""
echo "=== HARDENING: Executar QEMU como usuário não-root ==="

cat <<'QEMU_CONF'
# Em /etc/libvirt/qemu.conf, configurar:

# Usuário sob o qual os processos QEMU rodam:
user = "qemu"
group = "qemu"

# Prevenir que VMs usem o perfil dinâmico (use profiles estáticos):
remember_owner = 1

# Restringir namespaces adicionais:
namespaces = []

# Habilitar seccomp sandbox:
seccomp_sandbox = 1

# Reiniciar o daemon:
# systemctl restart libvirtd (ou virtqemud no RHEL9+)
QEMU_CONF

echo "Configurações de hardening QEMU exibidas"

# ==============================================================================
# 7. DETECÇÃO DE ANOMALIAS — MONITORAMENTO DE SEGURANÇA
# ==============================================================================

echo ""
echo "=== MONITORAMENTO: Detectar comportamento anômalo ==="

cat <<'MONITORING'
# Script de detecção de anomalias KVM (executar via cron a cada 5 minutos):

check_vm_anomalies() {
    # 1. VM com CPU usage > 95% por mais de 5 minutos (possível cryptominer?)
    virsh list --name | while read VM; do
        CPU=$(virsh domstats $VM --cpu-total 2>/dev/null | grep "cpu.time" | awk -F= '{print $2}')
        # Comparar com baseline...
    done

    # 2. VM tentando acessar interfaces de rede que não deveria
    # Verificar via auditd logs:
    ausearch -k libvirt-disk-access -ts today 2>/dev/null | grep DENIED | head -5

    # 3. Número inesperado de VMs rodando
    VM_COUNT=$(virsh list --state-running | grep -c "running" || true)
    EXPECTED_VMS=10  # Definir baseline
    if [ "$VM_COUNT" -gt "$EXPECTED_VMS" ]; then
        echo "ALERTA: ${VM_COUNT} VMs rodando, esperado ${EXPECTED_VMS}!"
        # Enviar alerta via Alertmanager/PagerDuty
    fi
}
MONITORING

echo "Script de monitoramento exibido"

# ==============================================================================
# 8. PERGUNTA DE ENTREVISTA
# ==============================================================================

echo ""
cat <<'EOF'
PERGUNTA DE ENTREVISTA (Nível Sênior):

"Um cliente PCI-DSS nível 1 quer hospedar um ambiente de pagamentos em VMs KVM.
O auditor PCI exige: 'segregação de rede', 'logs de acesso a todos os sistemas',
'criptografia de dados em repouso', e 'acesso privilegiado monitorado e restrito'.
Como você arquitetaria o ambiente KVM para passar na auditoria?"

RESPOSTA ESPERADA:
"Mapear cada requisito PCI-DSS ao controle técnico KVM:

1. Segregação de rede (PCI Req 1):
   - VMs do ambiente de pagamento em rede virtio ISOLATED (sem forward externo)
   - Firewall virtual dedicado (VM pfSense ou Fortigate) com regras microscirúrgicas
   - VLAN tagging via Open vSwitch entre as VMs PCI

2. Logs de acesso (PCI Req 10):
   - auditd com regras cobrindo /etc/libvirt/, virsh commands e socket libvirt
   - Encaminhar logs para SIEM centralizado (Splunk/ELK) via rsyslog/fluentd
   - Retenção de 12 meses com imutabilidade (S3 WORM ou Loki immutable)

3. Criptografia em repouso (PCI Req 3):
   - Discos QCOW2 com LUKS encryption (qemu-img --encrypt.format luks)
   - Chaves gerenciadas via HashiCorp Vault com auto-unseal
   - Verificar que backup dos qcow2 também está criptografado

4. Acesso privilegiado monitorado (PCI Req 7/8):
   - Nenhum acesso root direto ao host — apenas via sudo auditado
   - libvirt RBAC via polkit — operadores têm apenas permissões necessárias
   - Session recording com tlog/auditd para todas as sessões SSH privilegiadas
   - Autenticação com MFA para qualquer acesso à infraestrutura

5. HA para continuidade (PCI Req 12):
   - Live migration + cluster Pacemaker para zero downtime
   - Backups automatizados com virsh snapshot-create testados mensalmente"
EOF
