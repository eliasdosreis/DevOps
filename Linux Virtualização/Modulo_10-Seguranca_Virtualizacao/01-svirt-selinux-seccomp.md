# Módulo 10 — Segurança em Virtualização: sVirt, Seccomp e AppArmor

## 1. ANALOGIA DO DIA A DIA

Imagine um presídio de máxima segurança.

- **A VM** é um preso perigoso em uma cela individual
- **O KVM/QEMU** é o presídio
- **O processo QEMU** é o guarda que vigia a cela
- **SELinux/sVirt** é o regulamento do presídio que define exatamente o que  
  o guarda pode fazer (quais portas pode abrir, quais áreas pode acessar)
- **Seccomp** é o colete à prova de balas do guarda — limita quais ações ele  
  pode executar mesmo que o preso o domine
- **AppArmor** é um crachá com permissões específicas de área — o guarda  
  só pode entrar nos corredores que estão no crachá dele

Se um preso (malware na VM) fugir da cela (VM escape exploit), ele agora  
está no corpo do guarda (processo QEMU). Sem sVirt+Seccomp, o fugitivo tem  
acesso total ao presídio. Com eles, o guarda é uma camisa de força adicional.

---

## 2. SÉCURITÉ ARCHITETE — AS CAMADAS DE DEFESA

```
┌──────────────── Camadas de Segurança KVM ──────────────────┐
│                                                             │
│  Nível 5: Hardware VT-x Ring-0 separation (Intel VMX)      │
│  Nível 4: KVM Kernel Module (gerencia VMCS privilegiado)   │
│  Nível 3: QEMU Processo do usuário (emulação de devices)   │
│  Nível 2: sVirt/SELinux (MAC labels nos processos QEMU)    │
│  Nível 1: Seccomp (filtro de syscalls do processo QEMU)    │
│  Nível 0: AppArmor (profiles de acesso a arquivos)         │
│                                                             │
│  Um atacante deveria comprometer TODOS os 6 níveis         │
│  para escapar para o sistema host.                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. SVIRT — SECURITY-ENHANCED VIRTUALIZAÇÃO

O **sVirt** é a integração do SELinux com o KVM/libvirt. Cada VM recebe  
um **label SELinux único** automaticamente quando é definida.

### Como funciona:

```bash
# Ver os labels SELinux das VMs em execução:
ps auxZ | grep qemu

# Saída típica:
# system_u:system_r:svirt_t:s0:c123,c456  qemu-system-x86_64 -name vm-web-01
# system_u:system_r:svirt_t:s0:c789,c012  qemu-system-x86_64 -name vm-db-01
#                                ^^^^  ^^^^
#                                |     |__ categorias únicas por VM! (c123,c456)
#                                |________ tipo svirt_t = processo de VM

# O DISCO da vm-web-01 tem label correspondente:
ls -laZ /var/lib/libvirt/images/vm-web-01.qcow2
# -rw------- system_u:object_r:svirt_image_t:s0:c123,c456
#                                              ^^^^^^^^^^^
#                                              MESMAS categorias! VM só acessa SEU disco

# A vm-db-01 NÃO PODE ABRIR o disco de vm-web-01:
# As categorias diferentes (c789,c012 vs c123,c456) bloqueiam o acesso!
# Mesmo que haja um VM escape, o processo QEMU da vm-db-01 não consegue
# ler o disco da vm-web-01 por MLS SELinux policy!
```

---

## 4. SECCOMP — FILTRAGEM DE SYSCALLS DO QEMU

O QEMU usa **~300+ syscalls** do kernel para operar normalmente.  
No entanto, um processo QEMU comprometido poderia usar syscalls como  
`ptrace()`, `mount()`, `setuid()` para escalar privilégios.

O **seccomp BPF** cria uma lista branca de syscalls permitidas:

```bash
# Ver quais syscalls um processo QEMU está usando hoje:
strace -c -p $(pgrep -f "qemu.*vm-web") -e trace=all sleep 10 2>&1 | head -30

# O QEMU moderno já inclui seccomp por padrão!
# Verificar se está ativo:
virsh dumpxml vm-web-01 | grep seccomp
# Se não aparecer, adicionar com:
# <domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
#   <qemu:commandline>
#     <qemu:arg value='-sandbox'/>
#     <qemu:arg value='on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny'/>
#   </qemu:commandline>
```

---

## 5. APPARMOR — PERFIS DE SEGURANÇA POR PROCESSO

No Ubuntu/Debian, o AppArmor é o mecanismo de controle mandatório padrão  
(substituindo SELinux na maioria das distribuições Debian-based).

```bash
# Ver o profile AppArmor do QEMU:
cat /etc/apparmor.d/abstractions/libvirt-qemu

# Status dos perfis ativos:
aa-status | grep -A5 qemu

# Se novo storage path não estiver no perfil (erro comum!):
# O QEMU tenta abrir /data/vms/disco.qcow2 mas falha silenciosamente
# Verificar negações:
dmesg | grep -i "apparmor.*denied.*qemu"
journalctl -k | grep "apparmor.*DENIED"

# Adicionar path ao perfil AppArmor do QEMU:
cat >> /etc/apparmor.d/abstractions/libvirt-qemu << 'EOF'
  /data/vms/** rwk,
EOF
systemctl reload apparmor
```

---

## 6. LUKS — CRIPTOGRAFIA DE DISCOS DE VMs

Para dados sensíveis, o disco da VM pode ser criptografado com **LUKS**:

```bash
# Criar disco QCOW2 com criptografia LUKS integrada:
qemu-img create -f qcow2 \
  --object secret,id=sec0,data=SENHA_FORTE \
  -o encrypt.format=luks,encrypt.key-secret=sec0 \
  /var/lib/libvirt/images/vm-secreto-encrypted.qcow2 \
  50G

# No XML da VM, referenciar o secret:
# <secret ephemeral='no' private='yes'>
#   <description>Chave LUKS do disco da VM</description>
#   <uuid>UUID-UNICO</uuid>
# </secret>
#
# virsh secret-set-value UUID-UNICO SENHA_FORTE
```

---

## 7. HARDENING CHECKLIST SÊNIOR

| Item de Segurança                          | Verificação                               | Status |
|--------------------------------------------|-------------------------------------------|--------|
| sVirt labels únicos por VM                 | `ps auxZ | grep qemu`                    | ✓/✗    |
| Seccomp sandbox ativo no QEMU              | `virsh dumpxml vm | grep seccomp`        | ✓/✗    |
| AppArmor/SELinux em modo ENFORCE           | `getenforce` / `aa-status`               | ✓/✗    |
| Nenhuma VM rodando como root guest         | `virsh dumpxml | grep user`              | ✓/✗    |
| Redes de VMs isoladas (sem bridge pública) | `virsh net-list`                         | ✓/✗    |
| Discos com permissão 0600 (somente qemu)   | `ls -la /var/lib/libvirt/images/`        | ✓/✗    |
| QEMU atualizado (CVE tracking)             | `qemu-system-x86_64 --version`           | ✓/✗    |
| UEFI SecureBoot nas VMs críticas           | `virsh dumpxml | grep secboot`           | ✓/✗    |
| Auditd rastreando acessos libvirt          | `grep libvirt /etc/audit/rules.d/*.rules`| ✓/✗    |

---

## 8. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Um pesquisador de segurança reporta um CVE crítico no QEMU  
(CVSS 9.8) que permite que código executado dentro de uma VM guest faça  
escape para o processo QEMU host via buffer overflow no driver virtio-net.  
Descreva sua resposta a incidente e as camadas de mitigação que limitariam  
o impacto mesmo antes do patch."

**Resposta esperada:**  
"A resposta em camadas seria:

**Contenção imediata (0-4h):**
1. Isolar VMs de rede externa — remover IPs públicos das VMs afetadas
2. Ativar modo temporário de monitoramento agressivo: `auditctl -a always,exit -F arch=b64 -S all -k qemu-audit`
3. Verificar se seccomp sandbox está ativo nos processos QEMU — se não, ativar imediatamente

**Mitigação técnica antes do patch (4-24h):**
1. **Seccomp**: Mesmo com escape do processo QEMU, syscalls perigosas estão bloqueadas
2. **sVirt labels**: O processo QEMU comprometido ainda está limitado pelos labels SELinux — não acessa discos de outras VMs nem arquivos host fora do context svirt_t
3. **AppArmor profiles**: Restringir ainda mais o profile qemu para permitir apenas os paths estritamente necessários
4. **Migrar VMs críticas** para nós isolados de rede enquanto patch é testado

**Mitigação de workaround (se patch não disponível):**
- Substituir virtio-net por e1000 emulado (vulnerabilidade é no driver virtio-net específico)
- Aceitar perda de performance em troca de reduzir superfície de ataque

**Patch e validação:**
1. Testar patch em ambiente de staging com workload similar
2. Rolling update dos nós com live migration das VMs
3. Validar com `qemu-system-x86_64 --version` e CVE-specific PoC em sandbox"
