# Módulo 08 — Quando Usar VM, Container ou Ambos?

## 1. ANALOGIA DO DIA A DIA

Pense numa expedição de exploração:

- **VM** = Acampamento Base completo: barraca pesada, fogão, gerador próprio,  
  equipe de segurança. Caro, demorado pra montar, mas sobrevive a tempestades  
  extremas. Cada explorador tem seu próprio território.

- **Container** = Mochileiro leve: dorme em albergue compartilhado, usa a  
  cozinha coletiva (kernel compartilhado), move-se rápido. Eficiente, mas  
  se o albergue pegar fogo (kernel panic), TODOS acordam no chão.

- **Kata Container** = Mochileiro que aluga um quarto privado no albergue:  
  a velocidade e custo do mochileiro, mas com a porta trancada da VM.

---

## 2. MATRIX DE DECISÃO ARQUITETURAL

| Cenário de Workload                        | Solução Recomendada          | Por quê                                      |
|--------------------------------------------|------------------------------|----------------------------------------------|
| Windows Server 2022                        | VM KVM                       | Requer kernel próprio do Windows             |
| Banco Oracle crítico com RMAN              | VM KVM + Huge Pages          | NUMA tuning, memlock, latência previsível    |
| 200 microsserviços Node.js                 | Containers + K8s             | Densidade, escala, deployment rápido         |
| SaaS multi-tenant (clientes diferentes)   | VMs ou Kata Containers       | Isolamento forte entre tenants               |
| CI/CD pipelines de build                  | Containers rootless           | Efêmero, rápido, sem overhead                |
| Firewall virtual (pfSense, OPNsense)      | VM KVM + SR-IOV              | Acesso direto à NIC física                   |
| Machine Learning / GPU                    | VM com PCI Passthrough        | GPU dedicada à VM                            |
| Edge computing (IoT gateway)              | Containers arm64              | Footprint mínimo                             |

---

## 3. ARQUITETURA HÍBRIDA — O PADRÃO DE PRODUÇÃO REAL

```
┌─────────────────────────────────────── Host KVM (Linux Kernel) ─────────────────────────┐
│                                                                                          │
│   ┌──────────────────────────────┐    ┌─────────────────────────────────────────────┐   │
│   │  VM: Database (PostgreSQL)   │    │  VM: Kubernetes Worker Node                 │   │
│   │  ├── NUMA Pinned CPUs        │    │  ├── containerd runtime                     │   │
│   │  ├── Huge Pages 1GB          │    │  │   ├── Pod: nginx (container)              │   │
│   │  ├── virtio-scsi + Ceph      │    │  │   ├── Pod: api (container)                │   │
│   │  └── Isolated Network        │    │  │   └── Pod: payment (Kata Container→microVM)│   │
│   └──────────────────────────────┘    └─────────────────────────────────────────────┘   │
│                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

Esta é a arquitetura de **OpenStack + Kubernetes** (OpenShift, Anthos):  
- VMs provisionadas pelo OpenStack/libvirt com tuning de hardware  
- Kubernetes rodando DENTRO das VMs gerenciando containers  
- Cargas multi-tenant em Kata Containers (microVMs dentro das VMs dos nós K8s)

---

## 4. COMPARAÇÃO TÉCNICA DE RUNTIMES

| Runtime          | Tipo       | Root?    | Interface | Caso de uso                    |
|------------------|------------|----------|-----------|--------------------------------|
| `runc`           | OCI Low    | Root     | CLI       | Base de Docker/containerd      |
| `crun`           | OCI Low    | Root     | CLI       | Alternativa em C (mais rápido) |
| `kata-runtime`   | OCI        | Root     | CLI       | Isolamento VM + velocidade      |
| `containerd`     | High-level | Root     | gRPC      | Kubernetes CRI padrão          |
| `CRI-O`          | High-level | Root     | gRPC      | OpenShift nativo               |
| `Podman`         | High-level | Rootless | CLI/REST  | Desenvolvimento, RHEL          |
| `Docker Engine`  | High-level | Root     | REST      | Desenvolvimento legado          |

---

## 5. CONCEITO SÊNIOR — A REVOLUÇÃO EBPF NOS CONTAINERS

O **eBPF** (extended Berkeley Packet Filter) é a tecnologia mais disruptiva dos  
últimos anos para containers. Em vez de usar `iptables` e `netfilter` para  
roteamento de rede (que é O(n) em regras), ferramentas como **Cilium** usam  
programas eBPF compilados JIT diretamente no kernel:

```
Container TX → eBPF hook (XDP) → encaminhar DIRETO para destino
           (zero cópias, zero iptables, zero overhead userspace)
```

Comparação de latência em cluster Kubernetes com 10.000 pods:
- `kube-proxy + iptables`: ~30ms de latência adicional por regra chain
- `Cilium eBPF`: ~0.5ms constante, independente de escala

---

## 6. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Sua empresa está migrando 500 VMs VMware para uma plataforma  
moderna. O time de negócio quer 'containers' pra tudo pois ouviu que é mais  
barato. Como você arquitetaria a migração identificando o que vira container,  
o que permanece VM e o que usa a abordagem híbrida?"

**Resposta esperada:**  
"A decisão arquitetural começa com categorização de workload:

1. **Análise de Stateful vs Stateless**: Aplicações stateless (APIs REST,  
   workers de fila, servidores web frontend) são candidatas naturais a  
   containers por serem efêmeras e escaláveis horizontalmente.

2. **Análise de isolamento de tenant**: Se as 500 VMs pertencem a múltiplos  
   clientes, a migração para containers PUROS violaria requisitos de isolamento.  
   A solução é VMs K8s nodes por tenant OU Kata Containers.

3. **Análise de estado**: Bancos Oracle/SQL Server, sistemas legados com  
   licenciamento por socket físico, workloads Windows → permanecem VMs com  
   NUMA/pinning tuning.

4. **Análise de latência**: HFT, processamento real-time, sistemas com SLA  
   de latência sub-milissegundo → VMs com huge pages e SR-IOV. Containers  
   introduzem jitter de scheduler compartilhado.

5. **Abordagem final recomendada**: 20-30% permanece VM pura,  
   60-70% migra para Kubernetes com containers, 10% usa Kata Containers  
   para multi-tenancy. Infraestrutura gerenciada com OpenStack ou Proxmox  
   como control plane de VMs."
