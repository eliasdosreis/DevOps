# Módulo 12 — Dashboards Grafana e Análise de Performance KVM

## 1. ANALOGIA DO DIA A DIA

Imagine o painel de controle da NASA durante uma missão espacial.

Não é um terminal com texto rolando — é um conjunto de painéis visuais  
com gráficos, tendências, semáforos vermelho-amarelo-verde, números   
em tempo real e histórico. O controlador vê DE RELANCE o estado de  
100 subsistemas simultaneamente.

O **Grafana** é exatamente isso para seu cluster KVM:  
Um dashboard visual que transforma séries numéricas do Prometheus  
em gráficos de linha, heatmaps, gauges e tabelas que você entende em segundos.

---

## 2. QUERIES PROMQL ESSENCIAIS PARA KVM

O **PromQL** é a linguagem de consulta do Prometheus. Dominar PromQL é  
habilidade sênior fundamental — é com ela que você cria alertas e dashboards.

### 2.1 — CPU das VMs

```promql
# Uso de CPU por VM em % (média dos últimos 5 minutos)
100 * (
  rate(libvirt_domain_cpu_time_seconds_total[5m])
  / on(domain) group_left()
  libvirt_domain_vcpu_maximum
)

# Top 5 VMs que mais consomem CPU
topk(5,
  rate(libvirt_domain_cpu_time_seconds_total[5m])
)

# CPU Steal Time no host (indica sobrecarga do hypervisor)
rate(node_cpu_seconds_total{mode="steal"}[5m]) * 100
```

### 2.2 — Memória das VMs

```promql
# % de RAM usada por VM
(
  libvirt_domain_memory_used_bytes
  / libvirt_domain_memory_maximum_bytes
) * 100

# VMs com balloon ativo (memória sendo devolvida ao host)
libvirt_domain_memory_stats_available_bytes - libvirt_domain_memory_stats_unused_bytes

# RAM livre no host disponível para overcommit
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024  # em GB
```

### 2.3 — I/O de Disco

```promql
# Throughput de escrita por VM e disco (MB/s)
rate(libvirt_domain_block_stats_write_bytes_total[5m]) / 1024 / 1024

# Latência de I/O (ms) — requer métricas de operações
rate(libvirt_domain_block_stats_write_time_seconds_total[5m])
/ rate(libvirt_domain_block_stats_write_requests_total[5m])
* 1000

# VMs com I/O acima de 100 MB/s (possível bottleneck)
rate(libvirt_domain_block_stats_write_bytes_total[5m]) > 100e6
```

### 2.4 — Rede das VMs

```promql
# Tráfego de entrada por VM (Mbps)
rate(libvirt_domain_interface_stats_receive_bytes_total[5m]) * 8 / 1e6

# Tráfego de saída por VM (Mbps)
rate(libvirt_domain_interface_stats_transmit_bytes_total[5m]) * 8 / 1e6

# Erros de rede (pacotes descartados)
rate(libvirt_domain_interface_stats_receive_drop_total[5m])
+ rate(libvirt_domain_interface_stats_transmit_drop_total[5m])
```

---

## 3. ESTRUTURA DE DASHBOARD GRAFANA PARA KVM

### Dashboard: "KVM Cluster Overview"

```
┌────────────────────────────────────────────────────────────────────┐
│  ROW 1: Cluster Summary                                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│  │ VMs      │ │ CPU Host │ │ RAM Host │ │ Alertas  │             │
│  │ Running  │ │ Avg: 45% │ │ Used:78% │ │ ⚠ 2 warn │             │
│  │   47     │ │          │ │          │ │ ● 0 crit │             │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘             │
│                                                                    │
│  ROW 2: CPU por VM (Top 10)                     [24h]             │
│  ┌──────────────────────────────────────────────────────┐         │
│  │  vm-oracle-db ████████████████░░░░░░░░░ 82%          │         │
│  │  vm-nginx-lb  ████████░░░░░░░░░░░░░░░░░ 41%          │         │
│  │  vm-app-01    ██████░░░░░░░░░░░░░░░░░░░ 31%          │         │
│  └──────────────────────────────────────────────────────┘         │
│                                                                    │
│  ROW 3: Rede (Mbps)              ROW 4: Disco I/O (MB/s)          │
│  ┌──────────────────┐           ┌──────────────────┐              │
│  │  linha temporal  │           │  linha temporal  │              │
│  │  IN/OUT por VM   │           │  Read/Write/VM   │              │
│  └──────────────────┘           └──────────────────┘              │
│                                                                    │
│  ROW 5: Inventário de VMs — Tabela completa                        │
│  ┌────────────────────────────────────────────────────────┐       │
│  │ VM Name    │ State  │ vCPUs │ RAM   │ Disk   │ Node    │       │
│  │ vm-web-01  │ ● RUN  │ 4     │ 8 GB  │ 50 GB  │ node-a  │       │
│  │ vm-db-01   │ ● RUN  │ 8     │ 32 GB │ 500 GB │ node-b  │       │
│  └────────────────────────────────────────────────────────┘       │
└────────────────────────────────────────────────────────────────────┘
```

---

## 4. ANÁLISE DE PERFORMANCE — OS 4 SINAIS DE OURO

Em SRE (Site Reliability Engineering), monitora-se 4 métricas fundamentais  
(definidas pelo Google SRE Book) — aplicados ao KVM:

| Sinal          | Métrica KVM                              | Threshold de Alerta |
|----------------|------------------------------------------|---------------------|
| **Latência**   | I/O disk wait time, rede RTT             | > 10ms disk wait    |
| **Tráfego**    | Mbps rede, MB/s disco                    | > 80% capacidade    |
| **Erros**      | Pacotes descartados, disk errors         | > 0 erros/min       |
| **Saturação**  | CPU steal, RAM overcommit, queue depth   | > 90% qualquer      |

---

## 5. VIRSH DOMSTATS — MONITORAMENTO NATIVO SEM EXTENSÕES

```bash
# Coletar TODAS as métricas de uma VM com um único comando:
virsh domstats vm-oracle-db --state --vcpu --balloon --block --net --perf

# Saída exemplo:
# Domain: 'vm-oracle-db'
#   state.state=1              (1=rodando, 3=pausado, 5=desligado)
#   state.reason=1
#   vcpu.current=8             (vCPUs alocadas)
#   vcpu.maximum=8
#   vcpu.0.state=1             (vCPU 0 rodando)
#   vcpu.0.time=28491234567    (nanosegundos de CPU usados)
#   balloon.current=33554432   (RAM atual em KB = 32GB)
#   balloon.maximum=33554432
#   block.count=2              (2 discos)
#   block.0.name=vda
#   block.0.rd.reqs=192847     (total read requests)
#   block.0.rd.bytes=9876543   (total bytes lidos)
#   block.0.wr.reqs=98765
#   block.0.wr.bytes=1234567
#   net.0.name=vnet0
#   net.0.rx.bytes=567890123   (bytes recebidos)
#   net.0.tx.bytes=123456789
#   perf.cmt=0                 (Cache Monitoring Technology)

# Para coletar de TODAS as VMs de uma vez:
virsh domstats --state --vcpu --balloon --block --net
```

---

## 6. CONCEITO SÊNIOR — MÉTRICAS DE PERF (PMU)

O QEMU expõe métricas de **Performance Monitoring Unit (PMU)** do hardware  
intel, permitindo monitorar cache misses, branch mispredictions e instruções  
por ciclo — vital para troubleshoot de performance em workloads sensíveis:

```bash
# Habilitar perf metrics no XML da VM:
# <perf>
#   <event name='cmt' enabled='yes'/>      <!-- Cache Monitoring -->
#   <event name='mbmt' enabled='yes'/>     <!-- Memory Bandwidth Monitoring -->
#   <event name='mbml' enabled='yes'/>     <!-- Memory Bandwidth Local -->
#   <event name='cpu_cycles' enabled='yes'/>
#   <event name='instructions' enabled='yes'/>
#   <event name='cache_misses' enabled='yes'/>
# </perf>

# Coletar via perf host-side no processo QEMU:
QEMU_PID=$(cat /var/run/libvirt/qemu/vm-oracle-db.pid)
perf stat -p $QEMU_PID sleep 5
```

---

## 7. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Você está analisando um cluster KVM que apresenta latência  
variável nas VMs — às vezes responde em 1ms, outras em 50ms, sem padrão claro.  
O CPU steal time do Prometheus está em 0%. Quais outras métricas você  
investigaria e em que ordem para isolar a causa raiz?"

**Resposta esperada:**  
"Com steal time em 0%, eliminamos sobrecarga de CPU. A investigação segue:

1. **Memory Pressure — KSM e THP thrashing**: `virsh domstats --balloon`  
   Ver se o balloon está inflado (host retomando RAM). Verificar  
   `/proc/vmstat | grep nr_mmap_fail` — THP compaction está ocorrendo?

2. **I/O latency — storage bottleneck**: 
   `virsh domblkstat --human` mostrando latência média por operação.  
   Se latência de escrita > 5ms em storage SSD → verificar `iostat -x 1` no host.  
   Possível symptom: muitas VMs disputando o mesmo backend de storage.

3. **Network Jitter — IRQ affinity**: 
   `cat /proc/interrupts | grep vnet` — as interrupções de rede das VMs  
   estão distribuídas entre CPUs ou concentradas numa só (IRQ storm)?

4. **NUMA cross-node memory access**:  
   `numastat -p $(cat /var/run/libvirt/qemu/vm-name.pid)` — quantas  
   page faults cruzam NUMA nodes? Se alto, o QEMU está alocando memória  
   no nó NUMA errado, causando penalidade de latência via QPI bus.

5. **Clock source — TSC instability** (causa mais obscura):  
   `dmesg | grep -i 'clocksource\|tsc'` — hypervisors virtualizados  
   podem ter instabilidade de TSC em hosts com CPUFREQ scaling ativo,  
   causando jitter de microsegundos que se acumula em latência percebida."
