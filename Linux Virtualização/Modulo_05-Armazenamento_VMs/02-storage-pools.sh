#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Storage Pools (Piscinas de Armazenamento).
# Pense na Libvirt como o Engenheiro Arquivista do Escritório.
# Ele tem 3 Formas de Arquivar maletas: 
# a) A Sala de arquivos (Pool tipo Diretório: Joga os arquivos isolados nas prateleiras).
# b) Cofre Bancário Cimentado na Parede (Pool tipo LVM Logical Vol: Fura espaço físico na parede em blocos alocados fixos)
# c) Uma Esteira que repassa caixa pra uma Galeria numa cidade conectada em Rede (Pool NFS: Armazena em um cluster Storage NAS fora do galpão)

# 2. O QUE É (Definição Técnica Senior)
# O Libvirt gerencia as Pools, que englobam a Capacidade Massiva Bruta atada pelo storage driver do pool manager. 
# E gerencia os "Volumes", que são os recortes formatados específicos dispostos pra as Vms.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Criar Pools Customizadas, fugindo da DEFAULT e entendendo Volumes LVM.
# ==============================================================================

DIR_CUSTOM="/dados_nvme_raid/discos_vms"
mkdir -p "$DIR_CUSTOM"

echo "=== 1. Instanciando Uma Nova Diretory Pool ==="
# virsh pool-define-as Injeta o Schema XML via argumentos inline pra criar "A Sala Nova"
virsh pool-define-as nomepool_nvme_rapido dir - - - - "$DIR_CUSTOM"

echo "=== 2. Ativando a Pool e Iniciar no Boot ==="
# Monta nas estruturas da Libvirt
virsh pool-start nomepool_nvme_rapido
virsh pool-autostart nomepool_nvme_rapido

echo "=== 3. Listagem Saudável de Pools ==="
virsh pool-list --all
# Saídas Típicas:
# Name                 State      Autostart  
# -------------------------------------------
# default              active     yes           
# nomepool_nvme_rapido active     yes           

echo "=== 4. Criando um VOLUME (Disco) alocado direto NA MÃO DO VIRSH ==="
# Vol-create-as Delega API storage pra invocar (qemu-img) lá atrás, alocando 10G
# num volume dentro daquela Pool atrelada.
virsh vol-create-as nomepool_nvme_rapido disco_webserver_01.qcow2 10G --format qcow2


# ==============================================================================
# 4. PASSO A PASSO LVM (Nível Sênior Absoluto Ponto Final I/O)
# - Você tem um disco NVMe Físico vazio na máquina de 1 TB em: /dev/sdb 
# - Você cria um Grupo LVM Linux nele focado em maquinas virtuais.
# `vgcreate vms_pool_vg /dev/sdb`
# - Você amarra esse Grupo na Libvirt!! 
# `virsh pool-define-as lvmpool logical - - - vms_pool_vg /dev/sdb`
# PRONTO. Agora qualquer Disco Vm que o Cliente Fazer, O hypervisor usará 
# blocos de Disco Raw Logical Volume, atingindo Velocidade End-Of-Line.
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Fazer cópia manual dum arquivo (`cp debian.qcow2 \` '/dados_nvme_raid/..`)  e 
# o arquivo novo NÃO aparecer no virt-manager nem no `virsh vol-list`. O Dev Jr chora.
# Causa: O Cache e o state monitor da virsh não ativam fstat recursivos em tempo atômico OOTB.
# Ela precisa ser cutucada para inspecionar que um humano quebrou a promessa da API.
# Solução: `virsh pool-refresh nomepool_nvme_rapido` e como magica o libvirt 
# cataloga o metadata do bloco e apresenta aos painéis do datastore de novo.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Armazenamento Block Share Híbrido, iSCSI Pool Multipath (Live Migration Foundation)
# Os Juniores amam usar HD local ("Dir"). Máquina Rápida! O Que ocorre se o Servidor Node
# Físico pegar fogo por que queimou placa mãe? Adeus dados encriptados! 
# Nós utilizamos Clusters Libvirt atando Pools do tipo iSCSI Target ou GlusterFS Muli-Write blocks. 
# Quando as Pools em todos os Hosts apontam pra NAS Central do Rack, nós transferimos a  
# Maquina M1 (Em uso/Aceso LIGADA) do Servidor A pro Servidor B em 0.5s Milisegundos de delay ("Live migration"),   
# pois O DISCO NÃO PRECISA VIAJAR CABOS DE REDE PARA O OUTRO NODE, ELe só entrega a chave do Storage 
# pro hypervisor B destrancar a mesma LUN em SAN Block access.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se utilizamos uma NFS Mount como The Backing Storage Pool para Hospedar 
# discos QCOW2 num cluster altamente denso operado via libvirt em produçao HA, 
# qual principal risco sistêmico atrelado a Lock de Concorrência de Escritores precisaria
# ativarmos na arquitetura distribuída VirtLockD/SanLockD para evitar Split Brain Corruptions na Live Migration?"
# Resposta esperada: "Quando utilizamos file-based storage points distribuídos em cluster (Ex: NFS Mounts LUNs),    
# nós temos a capacidade física de duas execuções simultâneas de host Hypervisors LIGAREM 
# as threads de um mesmo QEMU acessando o mesmo Volume (`.qcow2`). 
# E esse Dual-writer sujo (Split-brain lock access), destruirá a Metadata L1 do disco integralmente em instantes. 
# A engenharia necessita implementar e habilitar o daemon Distribuido `virtlockd` na camada de 
# libvirtd.conf em fcntl (se o DFS suportar posix locks fiéis)  ou Sanlock leasing managers, garantindo uma restrição de semáforo  
# Mutual Exclusion. Onde apenas UM qemu-guest terá exclusividade do Write descriptor do arquivo por sub-mili tempo real network, protegendo a base atômica."
# ==============================================================================
