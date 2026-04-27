# Módulo 09 — Alta Disponibilidade e Live Migration

## 1. ANALOGIA DO DIA A DIA

Imagine uma cirurgia cardíaca com coração artificial externo.

O médico precisa operar o coração de um paciente sem PARAR o coração.  
Ele conecta uma máquina de circulação extracorpórea que faz o sangue circular  
enquanto o coração é operado — o paciente continua vivo, o sangue circula,  
o cérebro não percebe a transição.

A **Live Migration** KVM é exatamente isso para VMs:
- O "coração" = a VM em execução (CPU state, memória, dispositivos)
- A "máquina extracorpórea" = o hypervisor destino
- "Sangue circulando" = páginas de memória sendo copiadas em background
- "Paciente acordado" = usuários conectados na VM não percebem nada

---

## 2. DEFINIÇÃO TÉCNICA SÊNIOR

A **Live Migration** do KVM ocorre em fases usando o protocolo QMP (QEMU Machine Protocol):

```
Fase 1 — Setup:
  ├── Verifica compatibilidade de CPU flags (host-A ≥ host-B features)
  ├── Verifica acesso ao storage compartilhado (NFS/Ceph/iSCSI)
  └── Estabelece conexão TCP entre QEMUs (por padrão porta 49152+)

Fase 2 — Pre-copy (bulk transfer):
  ├── Copia todas as páginas de RAM para o destino
  ├── VM continua rodando no source → páginas "sujas" são rastreadas
  └── O bitmap "dirty pages" é enviado iterativamente (rounds)

Fase 3 — Stop-and-copy (downtime):
  ├── VM é pausada no source (freeze de microssegundos a milissegundos)
  ├── Último conjunto de dirty pages é transferido
  └── Estado de CPU registers + device state é enviado

Fase 4 — Switchover:
  ├── VM é resumida no destino
  ├── Source VM é destruída
  └── Storage + rede já apontavam para nova instância
```

O **downtime** perceptível é tipicamente **10ms a 200ms** em condições favoráveis.

---

## 3. PRÉ-REQUISITOS DE ALTA DISPONIBILIDADE

```
┌──────────────────────────────────────────────────────────────┐
│                    CLUSTER HA KVM                            │
│                                                              │
│  ┌─────────────┐         ┌─────────────────────────────┐     │
│  │ SHARED       │         │  FENCING / STONITH          │     │
│  │ STORAGE      │         │  (Shot The Other Node       │     │
│  │              │         │   In The Head)              │     │
│  │ ├── NFS v4   │         │                             │     │
│  │ ├── Ceph RBD │         │  ├── IPMI / iDRAC           │     │
│  │ └── iSCSI    │         │  ├── pacemaker + corosync   │     │
│  └──────────────┘         │  └── fence_ipmilan agent    │     │
│                           └─────────────────────────────┘     │
│  Node A (Active)              Node B (Standby)                │
│  ├── libvirtd                 ├── libvirtd                    │
│  ├── VM-prod-01 ──────────────→ (aguardando migração)        │
│  └── VM-prod-02               └── VM-prod-02 (failover)      │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. POR QUE O FENCING É CRÍTICO (Cenário Split-Brain)

**O cenário catastrófico sem fencing:**

```
Node A e Node B perdem comunicação de rede (apenas entre eles).
Node A: "Node B morreu! Vou assumir os recursos dele!"
Node B: "Node A morreu! Vou assumir os recursos dele!"

Resultado: AMBOS assumem as VMs.
AMBOS escrevem no mesmo disco NFS compartilhado simultaneamente.
Corrupção total de dados. Disaster.
```

**O fencing (STONITH) resolve:**
- Antes de assumir recursos, o cluster força o outro nó a DESLIGAR via IPMI
- Só depois assume os recursos com garantia de exclusividade
- "Atire primeiro no outro nó, pergunte depois"

---

## 5. FERRAMENTAS DO ECOSISTEMA HA

| Componente     | Função                                    | Alternativas              |
|----------------|-------------------------------------------|---------------------------|
| `pacemaker`    | Gerenciador de recursos do cluster (CRM)  | keepalived (simples)      |
| `corosync`     | Camada de mensageria/quórum entre nós     | —                         |
| `fence_agents` | Drivers de fencing (IPMI, AWS, VMware)    | —                         |
| `drbd`         | Replicação de blocos em tempo real        | Ceph RBD                  |
| `lvmlockd`     | Lock distribuído para LVM compartilhado   | —                         |
| `libvirt-dbus` | Interface D-Bus para automação HA         | —                         |

---

## 6. CONCEITO SÊNIOR — QUORUM E O PROBLEMA DOS 50%

Em clusters de **2 nós**, se os dois nós perdem comunicação, nenhum tem quórum  
(ambos veem apenas 50% do cluster). O pacemaker entra em "standby" por segurança.

**Soluções práticas:**

1. **Quorum Device (QDevice)**: Um terceiro servidor leve que atua como desempatador.  
   Não roda VMs, só vota no quórum. Amplamente usado em clusters 2+1.

2. **Clusters ímpares**: 3, 5, 7 nós — sempre tolerando `(n-1)/2` falhas.

3. **AWS/GCP HA**: Usam diferentes AZs (Availability Zones) como "nós" com  
   storage compartilhado via EBS Multi-Attach ou FSx.

---

## 7. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Seu cluster KVM de 3 nós está rodando 50 VMs. Um dos nós perde  
energia abruptamente às 3am. O pacemaker deveria fazer failover automático das  
VMs do nó morto, mas o fencing falhou (o PDU remoto estava inacessível).  
O que acontece e como o cluster reage? O que você recomenda pra evitar isso?"

**Resposta esperada:**  
"Quando o fencing falha, o pacemaker entra num estado de 'fencing pending' e  
**se recusa a iniciar as VMs do nó morto** no cluster remanescente — mesmo  
com quórum suficiente. Isso é intencional: sem confirmar que o nó morto está  
REALMENTE desligado (off), iniciar as VMs poderia causar dois processos QEMU  
escrevendo no mesmo storage simultaneamente, corrompendo dados.

O cluster ficará 'frozen' até o fencing ser resolvido manualmente.

Mitigações recomendadas:
1. **Redundância de fence agents**: Configurar múltiplos métodos de fencing  
   (IPMI primário + PDU secundário + VMware API terciário)
2. **Fence delay**: `priority-fencing-delay` — o nó com menos VMs aguarda  
   mais antes de tentar fazer fence, reduzindo race conditions
3. **SBD (STONITH Block Device)**: Um disco compartilhado especial onde  
   nós 'escrevem o testamento' — se o nó não atualizar seu slot em N segundos,  
   ele se auto-faz-fence (suicide watchdog via `sbd` daemon)
4. **UPS + IPMI**: Garantir que o IPMI tenha alimentação independente do PDU  
   principal para que o fencing funcione mesmo em falha de energia"
