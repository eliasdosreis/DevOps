# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# ==============================================================================
# Os discos dentro do Datacenter em KVM são como maletas para acomodar coisas de inquilinos:
# - RAW: A Maleta de Tiânio Fina: Não dobra, já pesa e gasta espaço cheio (100 Kilos / 100 Gbs).
#   Abre rápido. Não tem bolso secreto (Sem histórico). Extremamente violento de rápido.
# - QCOW2 (Qemu Copy On Write): A Mochila Flexível: Magra. Se você põe 1 meia ela pesa 1 grama. 
#   Ela tem zíperes onde suporta fundos falsos salvos do tempo (Snapshots Reais em Metadados) 
#   e ainda vem com Criptografia em zíper Nativa (Luks) + Compressão a vacuo se quiser.
# - VMDK: A Mochila que o vizinho fabricante gringo caro usa (VMware). Nós até lemos
#   o modelo de fecho, mas convertemos ela pra as nossas.

# ==============================================================================
# 2. O QUE É (Definição Técnica Senior)
# ==============================================================================
# Formatos da imagem referem-se não ao Sistema de Arquivos interno do Guest (Ext4/XFS), 
# Mas o contêiner Virtual de Bloco subjacente mantido pelo Host. 
# Imagem QCOW2 e RAW são dominantes absolutas nas Hyperconverged Infraestructure (HCI).
# 
# Pense na Árvore Física: 
# Host Físico (NVMe Físico) -> LVM / EXT4 HostDir -> Arquivo `debian_01.qcow2` 
# -> Bloco Lba Virtio-Blk -> Dentro MBR/GPT (VM Guest Partit. Tble -> LVM GUEST -> EXT4 VM. 
# Complexo? Demais. Custa performance? Sim, chama-se Double File System Overhead.

# ==============================================================================
# 3. VERIFICAÇÃO E TROUBLESHOOTING
# ==============================================================================
# O Junior relata: "Criei o disco com QCOW2 'Thin', coloquei 1 Terabyte para DB da VM! 
# Não usaram o banco inteiro, ele cresceu só 150GB. Mas a máquina HOST Fisica apagou (Deu Kernel Panic e travou 
# O QEMU por erro de EndOfSpace I/0 Write)".
# Cause: Thin Provisioning perigoso (Overcommit de armazenamento).
# A pool de armazenamento do host Físico era um HD de Míseros 256 Gbs e você liberou  
# uma locação potencial "Magra" pra 1 Tera. Devido aos metadados e os preenchimentos do BD
# expandindo esporadicamente os sparse files, o host acabou esgotando blocos lógicos 
# resultando numa quebra catastrófica sistêmica irrecuperável que extingue file descriptors atômicos 
# das Storage Pools do ext4 hospedeiro host (panic mode FS corrupt).

# ==============================================================================
# 4. CONCEITO SENIOR (O "porquê" profundo)
# ==============================================================================
# Para evitar o Double Overhead File System e maximizar Bancos Críticos. O Sênior  
# não utilizará Arquivos `.qcow2` no Sistema Hospedeiro em File Directory para Produção T0. 
# O Sênior usará ZFS zvol blocks diretórios, OU alocará Physical LVM Logical Volumes nativos do Linux host (`/dev/vg01/lvm-vm1`).
# Usar discos RAW em bloco host (ex: `/dev/StorageServerPool/lvm-disk`) 
# joga todo o peso do IOPS fora das file system lookup tables ext4 em host files. 
# Ele entrega leitura e escrita limpas cruas e brutas no array de disco super-saturando as SAS Raid Cards Hardware.

# ==============================================================================
# 5. PERGUNTA DE ENTREVISTA (Nível Senior)
# ==============================================================================
# Pergunta: "Seu Time de Engenharia reporta alta degradação I/O Write throughput em nossas 
# Máquinas KVM. Investigando, a VM de dados tem um .qcow2 atrelado ao ext4 físico do nó Compute,   
# possuindo 80% do espaço cheio. Piorando, nós rotineiramente criamos Snapshots Externos Backing files QCOW
# por motivos de backup contínuo e a fragmentação do file system bateu índices caóticos.
# Mudar o formato do V-Disk pra algo menos sofisticado traria benefício de I/O puro atestável? Qual arquitetura?"
# Resposta esperada: "Sim, os benefícios de IOPS de escrita Random-Write de um formato RAW, e idealmente um Raw
# atrelado a Logical Volume Bloco (/dev/xxx) ao invés de filesystem-backed em arquivos grandes é brutalmente
# notado em latências sob stress de Databases. Isso ocorre pois extirpamos todo o overhead da Árvore L2 Look up   
# Caching Table da virtualização do `.qcow2`. Sem a conversão esporádica e lock thread no re-alloc metadados Copy-on-write   
# as requisições fluem nativamente IO_Native pro Scheduler físico de IO Host. 
# Adicionalmente não faremos snapshots pelo formato Kvm Image, mas delegaremos ao pool mestre subjacente LVM o dever de Snap Físico por blocos hardware."
# ==============================================================================
