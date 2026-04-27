# 🖥️ Linux Virtualização — Repositório de Aprendizado Sênior

**Objetivo:** Dominar KVM, QEMU, libvirt, containers e orquestração do zero ao nível Sênior exigido no mercado de trabalho.

---

## 📚 Índice de Módulos

| Módulo | Nome | Tópicos Principais | Arquivos |
|--------|------|-------------------|----------|
| `00` | **Preparação do Ambiente** | HW check, instalação, `/etc/libvirt`, primeiros comandos virsh | `.sh` ×4 |
| `01` | **Fundamentos de Virtualização** | Tipo 1 vs 2, Full vs Para-virt, arquitetura KVM, vCPU/vRAM | `.md` ×4 |
| `02` | **QEMU: O Motor por Baixo** | QEMU vs KVM, TCG vs aceleração HW, CLI qemu-system, qemu-img | `.md/.sh` ×4 |
| `03` | **libvirt: Gerenciamento Elegante** | Arquitetura libvirtd, virsh essencial, XML de domínio, ciclo de vida | `.md/.sh/.xml` ×4 |
| `04` | **Redes Virtuais** | NAT, Bridge, Isolated, MACVTAP, Open vSwitch, troubleshooting | `.md/.sh` ×4 |
| `05` | **Armazenamento para VMs** | RAW vs QCOW2, Storage Pools, Snapshots, Thin/Thick Provisioning | `.md/.sh` ×4 |
| `06` | **Imagens e Templates** | Cloud-Init, Golden Image + virt-sysprep, Linked Clones, virt-v2v | `.sh` ×4 |
| `07` | **Performance e Tuning** | CPU Pinning, NUMA, HugePages, VirtIO/vhost-net, Ballooning+KSM | `.sh` ×5 |
| `08` | **Containers vs VMs** | Namespaces, Cgroups v2, Docker/Podman/OCI, Kata Containers, eBPF | `.md/.sh` ×3 |
| `09` | **Alta Disponibilidade** | Live Migration fases, Pacemaker, Corosync, STONITH, Split-Brain | `.md/.sh` ×3 |
| `10` | **Segurança em Virtualização** | sVirt/SELinux, Seccomp, AppArmor, LUKS, auditd, PCI-DSS | `.md/.sh` ×2 |
| `11` | **Automação com Ansible** | Playbooks idempotentes, community.libvirt, Roles, Jinja2, inventory dinâmico | `.yml/.md` ×3 |
| `12` | **Monitoramento e Observabilidade** | Prometheus, libvirt-exporter, PromQL, Grafana, 4 Sinais de Ouro | `.sh/.md` ×2 |
| `13` | **Gestão Visual de Clusters** | Cockpit, oVirt/RHV, oVirt API Python, comparativo de plataformas | `.md` ×1 |
| `14` | **Projeto Final Sênior** | Datacenter KVM completo (OVS+VLAN+CloudInit+HA), guia de entrevista | `.sh/.md` ×2 |

---

## 🗺️ Trilha de Aprendizado Recomendada

```
Iniciante
    │
    ├── M00 → Preparar seu ambiente Linux e verificar hw
    ├── M01 → Entender o que é virtualização e como o KVM funciona
    ├── M02 → Conhecer o QEMU e seus comandos de baixo nível
    ├── M03 → Aprender a gerenciar VMs com libvirt e virsh
    │
Intermediário
    │
    ├── M04 → Configurar redes: NAT, Bridge, OVS com VLANs
    ├── M05 → Gerenciar storage: pools, volumes, snapshots
    ├── M06 → Criar templates com cloud-init e linked clones
    ├── M07 → Tunar performance: NUMA, HugePages, VirtIO
    │
Avançado
    │
    ├── M08 → Entender containers vs VMs e quando usar cada um
    ├── M09 → Configurar Alta Disponibilidade com Live Migration
    ├── M10 → Aplicar segurança: SELinux, seccomp, auditoria
    ├── M11 → Automatizar com Ansible (IaC idempotente)
    │
Sênior
    │
    ├── M12 → Monitorar com Prometheus + Grafana + alertas
    ├── M13 → Conhecer plataformas enterprise (Cockpit, oVirt)
    └── M14 → Projeto Final + Guia de Entrevista Técnica
```

---

## 🧠 Estrutura Pedagógica de Cada Arquivo

Todo arquivo do repositório segue esta estrutura obrigatória:

```
1. ANALOGIA DO DIA A DIA     → Explicação simples, sem jargão
2. DEFINIÇÃO TÉCNICA SÊNIOR  → A visão técnica profunda e precisa
3. SCRIPT / DEMONSTRAÇÃO     → Código comentado e executável
4. PASSO A PASSO             → Comandos essenciais com explicação
5. VERIFICAÇÃO E TROUBLESHOOTING → Erros comuns e soluções
6. CONCEITO SÊNIOR PROFUNDO  → O "porquê" que diferencia candidatos
7. PERGUNTA DE ENTREVISTA    → Pergunta difícil + resposta modelo completa
```

---

## 🔧 Pré-requisitos para Prática

```bash
# Sistema: Ubuntu 22.04 LTS ou AlmaLinux 9 (recomendado)
# Hardware: CPU com VT-x ou AMD-V, mínimo 16GB RAM, 100GB disco

# Verificar suporte:
grep -Ec '(vmx|svm)' /proc/cpuinfo   # Deve retornar > 0

# Instalar a stack completa:
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system virtinst \
  virt-manager libguestfs-tools cloud-image-utils \
  openvswitch-switch ansible python3-libvirt
```

---

## 📋 Conceitos-Chave por Nível

### 🟢 Nível Júnior (saber explicar)
- O que é um hypervisor e diferença Tipo 1 vs Tipo 2
- Como criar e gerenciar VMs com `virsh` e `virt-manager`
- Tipos de rede: NAT vs Bridge
- Formatos de disco: RAW vs QCOW2

### 🟡 Nível Pleno (saber implementar)
- Configurar redes com Open vSwitch e VLANs
- Criar Golden Images com cloud-init e linked clones
- Snapshots externos com quiesce para consistência
- Diferença técnica entre containers e VMs (namespaces/cgroups)

### 🔴 Nível Sênior (saber arquitetar e troubleshoot)
- CPU Pinning, NUMA awareness e HugePages estáticos
- Live Migration: fases, convergência, pós-cópia e troubleshooting
- Pacemaker + STONITH: Split-Brain, quórum, fencing failure
- sVirt + Seccomp + AppArmor: defense-in-depth de processos QEMU
- Ansible idempotente com community.libvirt e inventory dinâmico
- PromQL para alertas de performance (steal time, NUMA, I/O latência)
- Decisão arquitetural VM vs Container vs Kata para workloads específicos

---

## 🎯 Perguntas de Entrevista Sênior (Compilado)

> Consulte `Modulo_14-Projeto_Final_Senior/02-guia-entrevista-senior.md`  
> para respostas completas e aprofundadas.

1. Explique o fluxo completo de `virsh start myvm` (kernel → QEMU → guest)
2. O que é CPU steal time e como CPU pinning + isolcpus resolve?
3. Por que HugePages 1GB reduz latência em bancos de dados?
4. Qual é a diferença técnica entre snapshot interno e externo QCOW2?
5. O que é Split-Brain e por que STONITH é obrigatório em clusters HA?
6. Como sVirt/SELinux isola VMs entre si mesmo após VM escape?
7. Quando usar Kata Containers em vez de containers Docker normais?
8. O que garante a idempotência num playbook Ansible?
9. Como o PromQL detecta degradação de performance em tempo real?
10. Como você arquitetaria uma migração VMware → KVM open source?

---

*Repositório construído progressivamente — do zero ao nível Sênior em Virtualização Linux KVM/QEMU/libvirt.*
