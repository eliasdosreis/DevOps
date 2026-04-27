# Módulo 13 — oVirt e Cockpit: Gestão Visual de Clusters KVM

## 1. ANALOGIA DO DIA A DIA

### Cockpit — O Painel da Cabine do Piloto

Imagine um piloto de avião. Ele PODE voar olhando apenas para fora da janela  
(CLI virsh/ssh), mas uma cabine com painel de instrumentos (Cockpit) torna  
tudo mais rápido, seguro e compreensível.

O **Cockpit** é uma interface web leve diretamente no host Linux.  
Você acessa `https://seu-servidor:9090` e vê: CPU, RAM, disco, VMs, logs  
— tudo no navegador, sem precisar instalar nada adicional.

### oVirt — O Centro de Controle de Voo

Se o Cockpit é o painel de um avião único, o **oVirt** é o Centro de Controle  
de Voo que gerencia TODOS os aviões da frota do aeroporto.

Permite gerenciar **clusters inteiros de KVM** num único painel:  
criar VMs, fazer live migration, configurar storage, redes, HA policies —  
tudo com GUI, API REST e controle de acesso (RBAC) para equipes.

---

## 2. COCKPIT — INSTALAÇÃO E FUNCIONALIDADES

### 2.1 — Instalação do Cockpit

```bash
# Ubuntu 22.04+:
apt install -y cockpit cockpit-machines
systemctl enable --now cockpit.socket

# RHEL/AlmaLinux/Rocky:
dnf install -y cockpit cockpit-machines
systemctl enable --now cockpit.socket

# Abrir firewall:
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload

# Acessar em: https://IP-DO-HOST:9090
# Login: usuário do sistema Linux (root ou sudo)
```

### 2.2 — O que o Cockpit oferece para KVM

| Funcionalidade              | Via Cockpit (GUI)                    | Equivalente CLI                    |
|-----------------------------|--------------------------------------|------------------------------------|
| Criar VM                    | Wizard passo a passo                 | `virt-install`                     |
| Iniciar/Parar/Pausar VM    | Botões na interface                  | `virsh start/shutdown/suspend`     |
| Console VNC/SPICE           | Direto no browser (noVNC)            | `virt-manager` ou SSH X11          |
| Ver Console serial          | Terminal web integrado               | `virsh console`                    |
| Snapshots                   | Botão criar/restaurar/deletar        | `virsh snapshot-*`                 |
| Métricas em tempo real      | Gráficos de CPU/RAM/rede             | `virsh domstats`                   |
| Logs do sistema             | `journalctl` integrado               | `journalctl -u libvirtd`           |
| Gestão de Storage           | Lista pools e volumes                | `virsh pool-list`, `vol-list`      |
| Redes virtuais              | Lista e cria redes                   | `virsh net-list`                   |

### 2.3 — Cockpit vs Virt-Manager

```
                  Cockpit                    Virt-Manager
Acesso:           Browser Web (https)        Aplicativo Desktop (X11/GDK)
Instalação:       No servidor                No cliente desktop
Conexão remota:  Nativa (HTTPS tunnel)      SSH -X (lento/problemático)
Multi-host:       Sim (via cockpit-pcp)      Por sessão SSH
Ideal para:       Administração diária       Configuração avançada/debug
```

---

## 3. OVIRT — PLATAFORMA ENTERPRISE DE GESTÃO DE CLUSTERS

### 3.1 — Arquitetura do oVirt

```
┌──────────────────────────────────────────────────────────────────┐
│                     oVirt Manager (Engine)                       │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────┐    │
│  │ Portal Admin│  │  REST API    │  │  SDK Python/Java     │    │
│  │ (browser)   │  │ /ovirt-engine│  │  (automação)         │    │
│  └─────────────┘  └──────────────┘  └──────────────────────┘    │
│         │                │                      │                │
│  ┌──────────────────────────────────────────────┘                │
│  │                PostgreSQL Database                            │
│  │        (configurações, inventário, histórico)                  │
│  └──────────────────────────────────────────────────────────────  │
└──────────────────────────────────────────────────────────────────┘
          │API VDSM│              │API VDSM│
┌─────────────────┐      ┌──────────────────┐
│   KVM NODE A    │      │   KVM NODE B     │
│  VDSM Agent     │      │  VDSM Agent      │
│  libvirtd       │      │  libvirtd        │
│  VMs...         │      │  VMs...          │
└─────────────────┘      └──────────────────┘
          └──────────────────┘
          Storage Compartilhado
          (NFS / Ceph / iSCSI)
```

**VDSM** (Virtual Desktop and Server Manager) é o agente que o oVirt Engine  
instala em cada nó KVM para gerenciar VMs via API XML-RPC.

### 3.2 — Instalação do oVirt (Conceitual)

```bash
# Instalar oVirt Engine (requer RHEL/AlmaLinux/Rocky 8+):
# O Engine É uma VM ou servidor dedicado (não o mesmo do KVM host!)

# 1. Adicionar repositório oVirt:
dnf install -y centos-release-ovirt44
dnf update -y

# 2. Instalar o Engine:
dnf install -y ovirt-engine

# 3. Configurar interativamente:
engine-setup
# O wizard pergunta: domínio FQDN, senha admin, banco de dados, etc.

# 4. Acessar em:
#    https://engine.empresa.local/ovirt-engine
#    Login: admin@internal  /  senha configurada no setup
```

### 3.3 — Funcionalidades oVirt Enterprise

| Funcionalidade                | Descrição                                                  |
|-------------------------------|------------------------------------------------------------|
| **Datacenter Virtual**        | Organize hosts em clusters lógicos por função/localização  |
| **Live Migration Automática** | Sistema move VMs automaticamente para balancear carga      |
| **HA de VM**                  | Se host falhar, VM reinicia automaticamente em outro nó    |
| **Thin Provisioning Pool**    | Storage pools compartilhados com alocação dinâmica         |
| **Network QoS**               | Limitar banda de rede por VM via interface gráfica         |
| **Affinity Groups**           | Regras: "VM-db e VM-app DEVEM estar em hosts diferentes"   |
| **Quota**                     | Limitar recursos por projeto/tenant                        |
| **Templates**                 | Golden images gerenciadas centralmente                     |
| **REST API**                  | Automação via Ansible/Python/Terraform                     |

---

## 4. OVIRT REST API — AUTOMAÇÃO PROGRAMÁTICA

```python
#!/usr/bin/env python3
# Automatizar criação de VM via oVirt API Python SDK

import ovirtsdk4 as sdk
import ovirtsdk4.types as types

# Conectar ao oVirt Engine
conn = sdk.Connection(
    url='https://engine.empresa.local/ovirt-engine/api',
    username='admin@internal',
    password='senha_admin',
    insecure=True,   # Em produção: usar certificado válido!
)

# Criar uma VM
vms_service = conn.system_service().vms_service()

nova_vm = vms_service.add(
    types.Vm(
        name='vm-producao-python-01',
        cluster=types.Cluster(name='Default'),
        template=types.Template(name='ubuntu-22.04-template'),
        memory=4 * 1024**3,    # 4 GB em bytes
        cpu=types.Cpu(
            topology=types.CpuTopology(
                cores=2,
                sockets=2,
                threads=1,
            )
        ),
    )
)

print(f"VM criada: {nova_vm.name} — ID: {nova_vm.id}")

# Iniciar a VM
vm_service = vms_service.vm_service(nova_vm.id)
vm_service.start()

print("VM iniciada com sucesso!")
conn.close()
```

---

## 5. CONCEITO SÊNIOR — OVIRT vs OPENSTACK vs PROXMOX

| Plataforma   | Tipo          | Melhor para                              | Complexidade |
|--------------|---------------|------------------------------------------|--------------|
| **oVirt**    | Enterprise VM | Ambientes Linux corporativos, RH style   | Alta         |
| **OpenStack**| Cloud privada | Multi-tenant, style AWS on-premise       | Muito Alta   |
| **Proxmox**  | VM+Containers | Homelab, SMB, simplicidade               | Baixa        |
| **Cockpit**  | Gestão single | Servidor único ou pequeno cluster        | Mínima       |
| **Harvester**| HCI (Rancher) | Kubernetes + VMs integrados              | Média        |

---

## 6. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Sua empresa quer migrar de VMware vSphere para uma solução  
open source. O CFO aprovou a mudança mas exige que a plataforma substituta  
tenha: gestão centralizada de múltiplos clusters, auto-HA de VMs, controle  
de acesso por equipes (RBAC), API para automação Ansible, e que seja suportada  
comercialmente com SLA. Qual plataforma você recomenda e por quê?"

**Resposta esperada:**  
"Para esse perfil enterprise com suporte comercial, a recomendação é  
**Red Hat Virtualization (RHV)** — que é o oVirt empacotado e suportado  
pela Red Hat com SLA garantido.

Justificativa técnica:
1. **Gestão multi-cluster**: oVirt/RHV suporta datacenters virtuais com  
   múltiplos clusters KVM gerenciados pelo mesmo Engine
2. **Auto-HA de VMs**: VM HA policy nativa — se host falhar, VMs reiniciam  
   automaticamente em outros nós (requer shared storage e fence agent)
3. **RBAC**: oVirt tem sistema granular de roles — DBA só vê VMs do cluster  
   Oracle, infra-dev só pode criar VMs em ambiente de dev
4. **API Ansible**: Red Hat certificou os módulos `ovirt.ovirt.*` no Ansible  
   Galaxy — playbooks nativos para todo o ciclo de vida
5. **Suporte comercial**: Red Hat oferece subscription com SLA e backport de fixes

Alternativa de baixo custo/sem subscription: **Proxmox VE Community** —  
excelente para equipes pequenas, mas sem suporte comercial formal.  
Para large-scale multi-tenant puro: **OpenStack com Kolla-Ansible** — mais  
complexo, mas com ecossistema maior e 100% open source."
