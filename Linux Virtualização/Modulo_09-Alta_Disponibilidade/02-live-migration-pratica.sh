#!/bin/bash
# ==============================================================================
# Módulo 09 — Live Migration na Prática com virsh
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
#
# É como mudar de apartamento enquanto você dorme e continua seus sonhos.
# O caminhão de mudança (hypervisor) vai pegando móvel por móvel (páginas de RAM)
# e colocando no novo apartamento (nó destino).
# Quando tudo estiver lá, em 0.1 segundo o sonho continua do ponto exato — 
# você nem acordou durante a mudança.
#
# 2. DEFINIÇÃO TÉCNICA
#
# virsh migrate usa o QEMU Migration Protocol via QMP socket.
# O mecanismo "pre-copy" itera dirty-pages bits até o delta ser pequeno o
# suficiente pra fazer o stop-and-copy final em milissegundos.
# ==============================================================================

set -euo pipefail

SOURCE_HOST="kvm-node-a.datacenter.local"
DEST_HOST="kvm-node-b.datacenter.local"
DEST_URI="qemu+ssh://${DEST_HOST}/system"
VM_NAME="vm-producao-web"
SHARED_STORAGE_PATH="/mnt/storage-nfs/libvirt/images"

echo "=========================================="
echo " Módulo 09 — Live Migration Prática"
echo "=========================================="

# ==============================================================================
# 3. PRÉ-CHECKLIST ANTES DE MIGRAR (CRUCIAL!)
# ==============================================================================

echo ""
echo "=== PASSO 1: Verificar compatibilidade de CPU entre nós ==="
# Os nós DEVEM ter flags de CPU compatíveis!
# O destino NÃO PODE ter menos features que a origem
# Caso contrário: migrate falhará com "CPU feature not supported"

# No nó SOURCE:
echo "CPU flags do nó source:"
virsh cpu-models x86_64 2>/dev/null | head -5 || echo "(executar no host Linux)"

# Verificar compatibilidade direta:
# virsh cpu-compare /etc/libvirt/qemu/capabilities.xml --error

echo ""
echo "=== PASSO 2: Verificar acesso ao storage compartilhado ==="
# AMBOS os nós devem ver o mesmo path de storage!
# Em produção: NFS, Ceph RBD, iSCSI — disco NUNCA pode ser local!

if mountpoint -q "${SHARED_STORAGE_PATH}" 2>/dev/null; then
    echo "✓ Storage compartilhado montado em: ${SHARED_STORAGE_PATH}"
else
    echo "⚠ Storage compartilhado NÃO montado! Migração irá falhar."
    echo "  Monte o NFS primeiro: mount -t nfs storage-server:/vms ${SHARED_STORAGE_PATH}"
fi

echo ""
echo "=== PASSO 3: Verificar conectividade entre hypervisors ==="
if ping -c 1 "${DEST_HOST}" &>/dev/null; then
    echo "✓ Nó destino ${DEST_HOST} acessível"
else
    echo "⚠ Nó destino inacessível! Verifique rede de migração."
fi

# ==============================================================================
# 4. EXECUTANDO A LIVE MIGRATION
# ==============================================================================

echo ""
echo "=== PASSO 4: Live Migration em execução ==="

# Migração básica Live (mais simples — requer storage compartilhado)
# A VM continua rodando durante toda a transferência!
echo "Comando de migração (executar no nó source como root):"
echo ""
echo "virsh migrate \\"
echo "  --live \\                    # Migração a quente (VM continua rodando)"
echo "  --persistent \\             # Define a VM no destino após migração"
echo "  --undefine \\               # Remove definição do source após sucesso"
echo "  --verbose \\                # Progresso em tempo real"
echo "  ${VM_NAME} \\"
echo "  ${DEST_URI}"
echo ""

# Para migração com storage local (sem NFS — copia o disco também!):
# Mais lenta pois trafega disco + RAM, mas não requer storage compartilhado
echo "Migração com cópia de disco (offline storage — sem NFS):"
echo ""
echo "virsh migrate \\"
echo "  --live \\"
echo "  --copy-storage-all \\       # Copia todos os discos também!"
echo "  --persistent \\"
echo "  ${VM_NAME} \\"
echo "  ${DEST_URI} \\"
echo "  --desturi qemu:///system"

# ==============================================================================
# 5. MONITORAMENTO DA MIGRAÇÃO EM TEMPO REAL
# ==============================================================================

echo ""
echo "=== PASSO 5: Monitorar progresso da migração ==="

echo "Durante a migração ativa, execute num segundo terminal:"
echo ""
echo "# Ver estatísticas detalhadas da migração (dirty pages, throughput):"
echo "watch -n1 virsh domjobinfo ${VM_NAME}"
echo ""
echo "Campos importantes do domjobinfo:"
echo "  Data Processed:    Bytes de RAM já transferidos"
echo "  Data Remaining:    Bytes ainda a transferir"
echo "  Memory bandwidth:  Throughput da migração (MB/s)"
echo "  Dirty rate:        Velocidade que a VM está 'sujando' páginas"
echo ""
echo "  SE: dirty rate > throughput => migração NUNCA convergirá!"
echo "  SOLUÇÃO: virsh migrate-setmaxdowntime VM 500  (500ms de pausa máxima)"

# ==============================================================================
# 6. TUNING DE MIGRAÇÃO PARA WORKLOADS PESADOS
# ==============================================================================

echo ""
echo "=== PASSO 6: Tuning para VMs com alta taxa de escrita ==="

# Aumentar largura de banda da migração (padrão: 32MB/s — muito lento!)
echo "Aumentar bandwidth durante migração ativa:"
echo "virsh migrate-setspeed ${VM_NAME} 1024  # 1 GB/s"
echo ""

# Para VMs com memória muito "suja" (banco de dados ativo):
# Se não convergir em pré-copia, forçar pausa final com downtime aceitável
echo "Configurar downtime máximo aceitável (padrão: 30ms):"
echo "virsh migrate-setmaxdowntime ${VM_NAME} 500  # 500ms de downtime máximo"
echo ""

# Para convergência forçada em último caso:
echo "Forçar convergência (post-copy) — VM roda parcialmente no destino:"
echo "virsh migrate-start-postcopy ${VM_NAME}"
echo "# ATENÇÃO: post-copy => se a rede cair durante, VM MORRE!"

# ==============================================================================
# 7. VERIFICAÇÃO PÓS-MIGRAÇÃO
# ==============================================================================

echo ""
echo "=== PASSO 7: Verificar sucesso da migração ==="

echo "No nó DESTINO, verificar se a VM está rodando:"
echo "virsh list --all"
echo ""
echo "Verificar se a VM responde (ping, SSH):"
echo "VM_IP=\$(virsh domifaddr ${VM_NAME} 2>/dev/null | awk '/ipv4/{print \$4}' | cut -d/ -f1)"
echo "ping -c 3 \$VM_IP"
echo ""
echo "Verificar integridade do storage após migração:"
echo "virsh domblkstat ${VM_NAME}"

# ==============================================================================
# 8. TROUBLESHOOTING DE LIVE MIGRATION
# ==============================================================================

echo ""
echo "=== TROUBLESHOOTING COMUM ==="

cat <<'EOF'
PROBLEMA 1: "Unable to allow access for disk path: Permission denied"
  CAUSA: SELinux bloqueando acesso ao arquivo qcow2 no NFS
  SOLUÇÃO: 
    setsebool -P virt_use_nfs 1
    restorecon -Rv /mnt/storage-nfs/

PROBLEMA 2: "CPU feature not supported: avx512f"
  CAUSA: CPU do Source tem AVX-512, CPU do Destino não tem
  SOLUÇÃO: 
    No XML da VM, mudar: <cpu mode='custom'> e especificar modelo base
    Ex: <model fallback='allow'>Haswell-noTSX</model>
    OU  usar cpu mode='host-model' em ambos os hosts

PROBLEMA 3: Migração interminável (dirty pages não convergem)
  CAUSA: VM escrevendo em RAM mais rápido do que a rede migra
  SOLUÇÃO:
    1. Aumentar bandwidth: virsh migrate-setspeed VM 2048
    2. Migrar em horário de baixo uso (janela de manutenção)
    3. Usar post-copy como último recurso
    4. Considerar memória ballooning para reduzir footprint antes de migrar

PROBLEMA 4: "Failed to connect to destination host"
  CAUSA: SSH keys não configuradas entre nós OU firewall bloqueando porta 49152+
  SOLUÇÃO:
    ssh-copy-id root@kvm-node-b
    firewall-cmd --add-port=49152-49215/tcp --permanent
    firewall-cmd --reload
EOF

# ==============================================================================
# 9. PERGUNTA DE ENTREVISTA (Nível Sênior)
# ==============================================================================
#
# Pergunta: "Durante uma live migration de uma VM com 256GB de RAM rodando
# um banco de dados PostgreSQL de produção, você observa que após 2 horas
# a migração ainda não convergiu — o 'Data Remaining' oscila entre 8GB e 12GB
# sem nunca chegar a zero. O SLA de manutenção acaba em 30 minutos.
# Quais são suas opções e os riscos de cada uma?"
#
# Resposta esperada:
# "A não-convergência indica dirty rate > throughput — o Postgres está escrevendo
# em RAM mais rápido do que a rede consegue transferir.
#
# Opções:
# 1. Aumentar bandwidth (virsh migrate-setspeed 4096): Se a rede suportar 4GB/s,
#    pode convergir. Risco baixo, mas pode afetar outras VMs na mesma rede.
#
# 2. Post-copy migration (virsh migrate-start-postcopy): A VM começa a rodar
#    parcialmente no destino, buscando páginas faltantes sob demanda via rede.
#    Risco ALTO: se a rede entre nós cair durante post-copy, a VM MORRE
#    imediatamente (dados na metade do caminho). Usar apenas em redes redundantes.
#
# 3. Janela de manutenção com downtime planejado: Avisar usuários, fazer
#    checkpoint do Postgres (pg_checkpoint), pausar writes temporariamente
#    (read-only mode), executar migração com dirty rate zero. Downtime de ~30s.
#
# 4. Cancelar e reagendar: Abortar a migração (virsh migrate --abort-job),
#    VM continua no source intacta. Reagendar para horário de menor carga (3-4am).
#
# Minha escolha: Opção 4 se o SLA permite. Opção 2 NUNCA sem rede redundante.
# Opção 3 se o impacto no negócio for menor que o risco de corrupção."
