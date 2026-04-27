# Módulo 14 — Guia de Entrevista Técnica Sênior em Virtualização Linux

## VISÃO GERAL

Este documento é o seu **arsenal de entrevista sênior**. Contém as perguntas  
mais frequentes em processos seletivos para cargos de:
- Senior Infrastructure Engineer
- Senior SRE (Site Reliability Engineer)
- Platform Engineer / Cloud Engineer
- Linux Systems Administrator (Senior)
- Virtualization Architect

---

## BLOCO 1 — FUNDAMENTOS DE VIRTUALIZAÇÃO (KVM/QEMU/libvirt)

### Q1: "Explique a diferença entre Tipo 1 e Tipo 2 de hypervisor e onde o KVM se encaixa."

**Resposta Completa:**  
"Hypervisors Tipo 1 (bare-metal) rodam diretamente no hardware sem OS host — o próprio  
hypervisor É o OS. Exemplos: VMware ESXi, Hyper-V Server, Xen.  
Hypervisors Tipo 2 (hosted) rodam sobre um OS existente. Exemplo: VirtualBox, VMware Workstation.

O KVM é uma categoria híbrida: é um **módulo do kernel Linux** (`kvm.ko`, `kvm_intel.ko`).  
Quando carregado, ele transforma o kernel Linux num hypervisor Tipo 1, pois o Linux  
passa a ter capacidade de gerenciar VMs com acesso direto às instruções VT-x/AMD-V  
do hardware. O QEMU atua como processo userspace complementar que implementa os  
dispositivos virtuais (disco, rede, USB), enquanto o módulo KVM cuida da execução  
das instruções de CPU das VMs diretamente no hardware."

---

### Q2: "O que acontece quando você executa `virsh start myvm`? Descreva o fluxo completo."

**Resposta Completa:**  
"1. `virsh` conecta ao socket Unix `/run/libvirt/libvirt-sock` do daemon `libvirtd`  
2. A requisição é processada pelo driver QEMU dentro do libvirtd  
3. O libvirt lê o XML em `/etc/libvirt/qemu/myvm.xml`  
4. O libvirt monta o comando `qemu-system-x86_64` com todos os parâmetros extraídos do XML  
5. O QEMU é iniciado como processo filho com seccomp sandbox e labels SELinux sVirt  
6. O QEMU abre o módulo KVM via `/dev/kvm` com ioctl() `KVM_CREATE_VM`  
7. Para cada vCPU, o QEMU cria uma thread e chama `KVM_CREATE_VCPU`  
8. O KVM cria estruturas VMCS (Virtual Machine Control Structure) no hardware Intel  
9. A VM começa o ciclo: guest executa → trap → KVM processa → retorna ao guest  
10. O libvirtd registra o domínio como ativo e escreve o PID em `/run/libvirt/qemu/myvm.pid`"

---

### Q3: "Qual é a diferença entre `virsh shutdown`, `virsh destroy` e `virsh undefine`?"

| Comando         | Efeito                                                | Dados perdidos? |
|-----------------|-------------------------------------------------------|-----------------|
| `virsh shutdown`| Envia ACPI power-off (gracioso, igual botão físico)  | Não             |
| `virsh destroy` | SIGKILL no processo QEMU (força imediata)            | Estado de RAM   |
| `virsh undefine`| Remove XML de definição (não afeta disco)            | Configuração XML|
| `virsh destroy` + `--remove-all-storage` | Remove XML + todos os discos | TUDO |

---

## BLOCO 2 — PERFORMANCE E TUNING

### Q4: "O que é CPU steal time e como ele impacta as VMs?"

**Resposta:**  
"CPU steal time é o tempo que as vCPUs de uma VM ficam aguardando ser escalonadas  
pelo hypervisor porque o host físico está com a CPU sobrecarregada — outras VMs  
ou o próprio host estão usando a CPU quando a VM precisaria.

Visível como coluna `st` no `top` dentro da VM. Um valor > 5% é preocupante.  
Causas: overcommit de CPU (mais vCPUs alocadas do que pCPUs físicas),  
NUMA misalignment, ou I/O intenso de outras VMs na mesma máquina física.

Solução: CPU pinning com `vcpupin` + `isolcpus` no host, ou migrar VMs para  
nós menos carregados."

---

### Q5: "Por que HugePages melhora performance de VMs de banco de dados?"

**Resposta:**  
"A CPU mapeia endereços virtuais para físicos via TLB (Translation Lookaside Buffer).  
Com páginas de 4KB padrão, uma VM com 32GB de RAM requer ~8 milhões de entradas  
na tabela de páginas. O TLB tem espaço limitado (tipicamente 1024-4096 entradas),  
então ocorrem TLB Miss frequentes — o hardware precisa percorrer a page table  
na RAM para cada miss (page table walk), adicionando dezenas de ciclos de latência.

Com HugePages de 1GB, a mesma VM precisa apenas de 32 entradas no TLB.  
TLB Miss rate cai de 30-40% para < 1%, eliminando o overhead de page table walk.  
Para DBs como Oracle e PostgreSQL que fazem acesso aleatório a grandes conjuntos  
de dados, isso reduz latência de I/O de memória em 15-30%."

---

## BLOCO 3 — REDE E ARMAZENAMENTO

### Q6: "Explique a diferença entre NAT, Bridge e MACVTAP no contexto de redes KVM."

| Tipo      | Como funciona                              | Caso de uso                          |
|-----------|--------------------------------------------|--------------------------------------|
| **NAT**   | VM atrás de NAT no host; compartilha IP host | Desenvolvimento, Internet simples   |
| **Bridge**| VM conectada diretamente à rede física     | Servidores que precisam de IP real  |
| **MACVTAP**| VM tem MAC próprio ligado à NIC física   | Alta performance, sem bridge overhead|
| **OVS**   | Bridge programável com VLANs e OpenFlow   | Datacenters, SDN, multi-tenant       |

---

### Q7: "Qual a diferença entre snapshot interno e externo no QCOW2?"

**Resposta:**  
"**Snapshot interno**: O estado do disco é salvo DENTRO do próprio arquivo QCOW2.  
Conveniente, mas a VM deve estar pausada (sem consistência de aplicação).  
Limitação: apenas formatos QCOW2 suportam; tamanho do arquivo cresce.

**Snapshot externo**: Cria um NOVO arquivo QCOW2 como 'delta layer'. O disco  
original vira read-only (backing file) e todas as escritas vão para o novo arquivo.  
Suporta quiesce (com qemu-guest-agent) para consistência de filesystem mesmo  
com a VM ligada. Possibilita backups sem parada (via `virsh backup-begin`)  
e é a base para Linked Clones."

---

## BLOCO 4 — ALTA DISPONIBILIDADE

### Q8: "O que é Split-Brain e como o STONITH/Fencing previne?"

**Resposta:**  
"Split-brain ocorre quando nós de um cluster perdem comunicação entre si  
mas continuam operacionais. Sem coordenação:  
- Node-A: 'Node-B morreu, vou assumir os recursos!'  
- Node-B: 'Node-A morreu, vou assumir os recursos!'  
Resultado: dois processos QEMU escrevendo no mesmo disco compartilhado → corrupção.

STONITH (Shoot The Other Node In The Head) previne isso forçando um dos nós  
a se desligar ANTES que o outro assuma os recursos. O Pacemaker envia um  
comando via IPMI/iDRAC/PDU para desligar o nó 'suspeito'. Somente após  
confirmação de que o outro nó está DEFINITIVAMENTE desligado, os recursos  
(VMs) são iniciados no nó sobrevivente."

---

## BLOCO 5 — SEGURANÇA

### Q9: "Como o sVirt/SELinux isola VMs entre si mesmo após um VM escape?"

**Resposta:**  
"O sVirt atribui labels SELinux únicos por VM no formato `svirt_t:s0:c{X},{Y}`.  
O processo QEMU de cada VM recebe categorias diferentes: `c100,c200` vs `c300,c400`.  
Os discos também recebem labels correspondentes: `svirt_image_t:s0:c100,c200`.

A política SELinux MLS (Multi-Level Security) proíbe que um processo com  
label `s0:c100,c200` acesse arquivos com label `s0:c300,c400`.

Portanto, mesmo que um attacker faça VM escape (sai do QEMU), agora está  
num processo QEMU com label restrita. Ele não consegue:  
- Abrir discos de outras VMs (categorias diferentes)  
- Executar binários do sistema (tipo `svirt_t` não pode executar `sysadm_exec_t`)  
- Escrever em `/etc`, `/var/lib` do host (context incompatível)

O sVirt adiciona uma camada de defense-in-depth após o isolamento de VM."

---

## BLOCO 6 — CONTAINERS VS VMs

### Q10: "Quando você escolheria Kata Containers sobre containers Docker/Podman normais?"

**Resposta:**  
"Kata Containers são appropriados quando há requisito de isolamento forte  
sem abrir mão de workflows de container:

1. **Multi-tenancy real**: Diferentes clientes no mesmo cluster K8s.  
   Containers compartilham kernel — CVE em um pode afetar outros.  
   Kata isola cada pod em uma microVM KVM (~128MB overhead).

2. **Workloads com código não-confiável**: Execução de código de usuários  
   (ex: plataformas de Jupyter notebook para usuários externos, CI/CD  
   executando código de PRs de terceiros).

3. **Compliance/Regulatório**: Ambientes PCI-DSS ou SOC2 que exigem  
   isolamento de hypervisor entre workloads de clientes diferentes.

4. **Quando não é viável**: VMs completas seriam muito pesadas (> 30s boot),  
   mas containers puros são considerados inseguros pelo compliance."

---

## CHECKLIST DO CANDIDATO SÊNIOR

Antes da entrevista, você deve conseguir:

- [ ] Explicar o fluxo completo de boot de uma VM KVM (hardware → kernel → QEMU → guest)
- [ ] Desenhar a arquitetura de rede NAT, Bridge e OVS num whiteboard
- [ ] Descrever como configurar Live Migration com pré-requisitos e troubleshooting
- [ ] Calcular overcommit de CPU e RAM e saber quando é seguro
- [ ] Explicar a diferença entre snapshot interno/externo e linked clone
- [ ] Descrever as camadas sVirt + Seccomp + AppArmor e como se complementam
- [ ] Comparar containers vs VMs e quando usar cada um ou híbrido
- [ ] Criar um playbook Ansible idempotente para provisionar uma VM
- [ ] Escrever uma query PromQL para alertar sobre CPU steal time alto
- [ ] Descrever o que acontece em Split-Brain e como STONITH resolve

**Você completou todos os 14 módulos do curso! 🎓**  
Agora você está preparado para entrevistas de nível Sênior em Virtualização Linux.
