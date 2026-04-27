# Módulo 08 — Containers vs VMs: Namespaces e Cgroups

## 1. ANALOGIA DO DIA A DIA

Pense em um Espelho Mágico em um Hotel.

**VM:** É como alugar um Quarto Separado com paredes reais, teto próprio, 
encanamento exclusivo, porta trancada e um porteiro próprio (kernel completo e exclusivo).

**Container:** É como colocar um ESPELHO mágico em um quarto compartilhado. 
O Inquilino do Container olha no espelho e vê "seu próprio quarto exclusivo", 
mas na realidade é o mesmo quarto, apenas com uma ilusão de separação 
(compartilha o Kernel host, mas "enxerga" recursos isolados).

Os **Namespaces** são os espelhos (ilusão de isolamento por recurso:  
rede, processos, usuários, arquivos).  
Os **Cgroups** são o Gerente que controla "quanto da água, eletricidade e  
internet cada espelho pode consumir" (limites de CPU, RAM e I/O).

---

## 2. DEFINIÇÃO TÉCNICA SÊNIOR

Os **Linux Namespaces** (introduzidos no kernel 2.4.19+) são uma feature do  
kernel que particiona recursos globais em instâncias isoladas, dando a cada  
processo uma visão independente do sistema.

Os **Cgroups v2** (Control Groups versão 2, unificados desde kernel 5.2+)  
são a interface hierárquica do kernel para alocação, throttling e accounting  
de recursos computacionais por grupo de processos.

| Namespace | O que isola            | Syscall           |
|-----------|------------------------|-------------------|
| `mnt`     | Árvore de filesystems  | `mount()`         |
| `pid`     | IDs de processos       | `getpid()`        |
| `net`     | Interfaces de rede     | `socket()`        |
| `ipc`     | Filas de mensagens     | `shmget()`        |
| `uts`     | Hostname, domainname   | `sethostname()`   |
| `user`    | UIDs e GIDs            | `setuid()`        |
| `cgroup`  | Visão da hierarquia    | `clone(CLONE_NEWCGROUP)` |

---

## 3. DEMONSTRAÇÃO PRÁTICA — MÃOS NA MASSA

### 3.1 — Criando um Namespace manualmente (sem Docker!)

```bash
# Criamos um processo bash isolado com NET e PID namespace próprios
# Isso é exatamente o que o runtime do container faz por baixo!
sudo unshare --net --pid --mount --fork bash

# Dentro do novo namespace, inspecione:
ip addr         # Verá APENAS lo — sem eth0! Isolado!
ps aux          # Verá apenas os processos do SEU namespace!
hostname novo-host  # Muda apenas neste namespace!
```

### 3.2 — Criando Cgroups e limitando recursos

```bash
# Criamos um cgroup novo no subsistema de memória
sudo mkdir /sys/fs/cgroup/meu-container-teste

# Limitamos a 128MB de RAM para processos neste cgroup
echo "134217728" | sudo tee /sys/fs/cgroup/meu-container-teste/memory.max

# Adicionamos o PID do nosso bash ao cgroup
echo $$ | sudo tee /sys/fs/cgroup/meu-container-teste/cgroup.procs

# Verifique os limites ativos:
cat /sys/fs/cgroup/meu-container-teste/memory.current
```

---

## 4. CONTAINERS NA PRÁTICA — DOCKER E PODMAN

```bash
# Instalar Podman (Rootless! Sem daemon root)
sudo apt install podman -y

# Rodar um container Nginx isolado — por baixo: namespaces + cgroups automáticos
podman run -d --name web-teste \
  --memory 256m \          # cgroup: memory.max
  --cpus 0.5 \             # cgroup: cpu.max
  -p 8080:80 \             # net namespace + port mapping
  nginx:alpine

# Inspecionar namespaces do processo container em execução
CPID=$(podman inspect --format '{{.State.Pid}}' web-teste)
ls -la /proc/$CPID/ns/    # Verá links simbólicos para cada namespace!

# Inspecionar cgroups ativos do container
cat /proc/$CPID/cgroup
```

---

## 5. VM vs CONTAINER — TABELA COMPARATIVA SÊNIOR

| Critério              | VM (KVM/QEMU)                     | Container (Docker/Podman)         |
|-----------------------|-----------------------------------|-----------------------------------|
| **Isolamento**        | Total (kernel próprio)            | Parcial (namespace)               |
| **Boot Time**         | 5–30 segundos                     | < 100 milissegundos               |
| **Overhead RAM**      | Kernel Completo (~200MB+)         | Mínimo (shared kernel)            |
| **Segurança**         | Alta (ring-0 separation)          | Média (syscall escape risks)      |
| **Portabilidade**     | Imagem pesada (GB)                | Imagem leve (MB)                  |
| **Caso de Uso**       | SO legado, Windows, isolamento    | Microserviços, CI/CD, stateless   |

---

## 6. CONCEITO SÊNIOR PROFUNDO

### Por que containers NÃO são seguros como VMs?

Um container compartilha o **mesmo kernel** do host. Isso significa que uma  
vulnerabilidade de escalada de privilégio no kernel (ex: CVE de `runc` exploit)  
pode permitir que um processo dentro do container faça `breakout` e assuma  
controle do **Host inteiro**.

Em VMs KVM, mesmo que o guest seja comprometido, o atacante ainda está  
dentro de um **processo QEMU** no host, cercado pelo `sVirt/SELinux` e pelo  
`seccomp` do hipervisor.

Por isso:
- **Workloads multi-tenant de clientes diferentes** → sempre VMs
- **Microsserviços da mesma aplicação confiável** → containers são OK
- **Melhor dos dois mundos** → **Kata Containers** (containers dentro de VMs micro-leves)

---

## 7. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Explique a diferença entre `cgroups v1` e `cgroups v2` e por que  
o Kubernetes e o Docker migraram para `cgroups v2` como padrão. Qual é o risco  
operacional de rodar ambos os sistemas simultaneamente num host KVM?"

**Resposta esperada:**  
"O `cgroups v1` possuía uma hierarquia independente por subsistema  
(memória, CPU, blkio, net_cls eram árvores separadas). Isso causava inconsistências  
quando se tentava aplicar limites combinados — ex: limitando 50% CPU E 1GB RAM do  
mesmo grupo de processos simultaneamente exigia coordenação entre subsistemas desacoplados.  
O `cgroups v2` unificou tudo numa hierarquia única com semântica consistente de delegação.  
O risco de misturar v1 e v2: runtimes mais antigos (Docker < 22.x sem `cgroupns`)  
podem montar o cgroup do host no namespace do container, expondo a hierarquia do  
sistema host para o processo interno — um vetor de information disclosure e  
possível path traversal de controle de recursos."
