# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# ==============================================================================
# Imagine um Datacenter Gigante (Sua Placa-Mãe). Você tem o Prédio A (O Processador Socket 1) 
# e o Prédio B (O Processador Socket 2).
# Cada um tem sua própria caixa d'água em cima do bloco (Os Pentes de Mémoria RAM locais grudados nele).
# O Inquilino da VM-SAP mora no Prédio A.
# Se ele beber Água da sua caixa no Prédio A, a agua cai imediata na boca (NanoSegundos Locais).
# Se o Hypervisor KVM foi burro, e entregou as "Memórias do Prédio B" pra VM do Prédio A, a água 
# tem que fluir por um cabo quilométrico na rua puxado por cano ligando os dois prédios (O Barramento UPI/QPI bus na placa-mãe).
# Isso gera latência monstra! Esse conceito chama-se: **Non-Uniform Memory Access (NUMA)**.

# ==============================================================================
# 2. O QUE É (Definição Técnica Senior)
# ==============================================================================
# Datacenters 99% das vezes compram servidores Dual-Socket. (Dois chips Intel físicos).
# A memória não é uniforme (Unified/UMA do seu celular). É NUMA. A RAM do Socket 1 
# é "Local", A RAM do Socket 2 é "Remota (Interconnection Delay)".
# Alocar a vCPU da Máquina virtual num core físico "NUMA Node 0", e forçar/errar as alocaçoẽs
# de páginas da vRAM dessa VM pra irem pro pente "NUMA Node 1", detrói o IO e estressa o QPI link.

# ==============================================================================
# 3. VERIFICAÇÃO E TROUBLESHOOTING NO HOST KVM
# ==============================================================================
# Como o Sênior verifica a topologia de sua Placa-Mãe antes de codar XMLs:
# `numactl --hardware`
# Retorna: 
# available: 2 nodes (0-1)
# node 0 cpus: 0 1 2 3 4 5 6  (O Processador no slot Esquerdo)
# node 0 size: 64700 MB       (A RAM espetada do lado esquerdo)
# node 1 cpus: 8 9 10 11 12 13 (O Processador Vizin)
# node 1 size: 64700 MB
# node distances: 10 Local | 20 Remoto Link penalty !

# ==============================================================================
# 4. CONFIGURANDO LIBVIRT COM AWARENESS ESTRITO
# ==============================================================================
# O Sênior força no arquivo XML em `virsh edit` a política de localidade estrita.
# O "numatune" diz pro hypervisor: "BIFURQUE ABSOLUTAMENTE TUDO NO NODE 0".
# 
#  <numatune>
#    <memory mode='strict' nodeset='0'/>
#  </numatune>
#
# Adicionado com o CPU Pinning do arquivo de aula anterior. Sua VM atingirá O estado de 
# Baixa Latência Extrema (Low Latency HFT Tuning) muito visto na B3 (Trading System Servers).

# ==============================================================================
# 5. CONCEITO SENIOR (O "porquê" profundo)
# ==============================================================================
# AutoNumaD e o Kernel rebalancing Host:
# E Se o Administrador é leigo ou tem mil maquinas e nao quer fazer isso XML a XML?
# O Linux kernel Host tem o Daemon Numad (Automatic Numa daemon). Ele varre passivamente as page faults
# dos processos QEMU no sistema e pensa "Opa! Esse processo Qemu do Socket 1 ta lendo muita RAM que ele alocou
# la no Pente Remoto 2. Deixa as escondidas eu migrar e varrer as paginas da memoria pra o RAM Pente 1 
# p/ ficar pertinho do Socket do processador rodando em Local-Hit Cache". 
# Esse varredura constante melhora sistemas caóticos, MAS o custo da troca "Moving Pages Live" gera espasmos
# e micro jittering de CPU Spikes. Em servidores HFT Cloud Tier 0, Sêniores desativam o AutoNuma no Host 
# e codam Pinning fixo Manual.

# ==============================================================================
# 6. PERGUNTA DE ENTREVISTA (Nível Senior)
# ==============================================================================
# Pergunta: "Se temos um Host KVM com 2 sockets (NUMA 0 e NUMA 1) onde CADA Socket 
# possui exatos Física 64 GB de RAM. Um cliente nos solicita uma gigantesca Virtual Machine  
# Monolítica que deve rodar usando internamente 90 GB de RAM.
# Como o hypervisor e a topologia NUMA lidará com o fato de que um único node subjazendo 
# não cobre sozinho a cota de 90 GB se impusermos o Tuning Strict=Node0?"
# Resposta esperada: "Se o XML estiver forçando a tag `<memory mode='strict' nodeset='0'/>` exigindo exclusividade local,  
# O Kernel Host lançará um esgotamento (falha atômica OOM kill out-of-memory exception) no start do QEMU 
# pois a VM exigiu mais RAM residente do que as matrizes de silício de fato possuíam atreladas ao slot Cpus (64G max strict limit). 
# A engenharia de Virtualização numa VM gigante (Monster-VMs) tem que arquitetar na XML a exposição e espelhamento
# do modelo vNUMA internamente pro Convidado OS (Dividindo o `90Gb` no XML, em células de cpus 45gb numatune 0 e 45gb numatune 1).
# Assim, O Linux da VM por via API Acpi descobrirá como escalonar seu app interno distribuindo memória correta pelos p-nodes transparentemente."
# ==============================================================================
