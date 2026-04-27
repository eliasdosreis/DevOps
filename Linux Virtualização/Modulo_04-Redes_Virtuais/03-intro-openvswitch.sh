#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Usar a "Linux Bridge" (brctl) do laboratório passado, é como usar um 
# "T" de tomada ou um hub passivo para espalhar cabo CAT5 pra turma inteira. Funciona e é rápido.
# Mas usar o **Open vSwitch (OVS)** é como comprar um Switch Cisco Catalyst C9000
# Gigantesco (de Fibra), operável por linha de código, onde nós definirmos regras ricas:
# "Vms com a tag VLAN 10 descem na porta X. Aplica esse Quality of Service. Redireciona tudo".
# Ele não é pra pequenos laboratórios, ele é o Santo Graal do Datacenter em Nuvem Produtivo.
#
# 2. O QUE É (Definição Técnica Senior)
# Open vSwitch (OVS) é um provedor multiplataforma de switch virtual C aberto sob 
# GPL que implementa Forwarding SDN L2/L3 com fluxos OpenFlow 1.0-1.5, sFlow, e 
# Gre/VXLAN Tunneling e integração profunda com a camada Datapath Netlink do Kernel.
# ==============================================================================

# ==============================================================================
# 3. COMANDOS PASSO A PASSO SR (Instalação e VSwitch creation)
# Objetivo: Forjar e integrar OVS no Libvirt ao em vez de bridges simplorias
# ==============================================================================

echo "=== 1. Instalação do Daemon e Módulo ==="
# Em servers Enterprise, as ferramentas ficam no repo mainstream
# apt-get install openvswitch-switch  ||  dnf install openvswitch

echo "=== 2. Criando o Switch VIRTUAL Gigante do Datacenter ==="
# Esse comando joga no daemon do banco OVSDB uma bridge mestre robusta
ovs-vsctl add-br ovsbr0

echo "=== 3. Plugando Interface Fisica Gigabit do Servidor nele ==="
# Transforma a Placa externa do Host na Trunk Port ascendente da Nuvem Externa
ovs-vsctl add-port ovsbr0 enp3s0

echo "=== 4. Como fica na Libvirt do XML de uma VM? ==="
# O dev Jr usava o mode <source network='default'/>.
# O Sênior injeta OVS no arquivo XML da VM passando a porta virtual com 
# "virtualport type='openvswitch'"
#
#    <interface type='bridge'>
#      <source bridge='ovsbr0'/>
#      <virtualport type='openvswitch'/>
#      <model type='virtio'/>
#    </interface>

echo "=== 5. Injetando Port Group (VLAN 100) na Instância ==="
# O poder Real do Ovs! Mandar uma Vm e já pinar ela no 802.1q de VLAN nativo 
# da sua corporação!
# ovs-vsctl set port <nome-do-vnet-da-vm> tag=100

# ==============================================================================
# 4. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você executa `ifconfig` ou `ip link show` para ver as interfaces de rede 
# Vnet subindo, e vê a rede ovsbr0 criada. Mas o tráfego não navega nos guests!
# Causa: O OVS desativa protocolos L3 num device puro bridge port sem tap route, Ou
# existe Loop da sub-ponte.
# Como inspecionar fluxos brutos do Switch Inteligente?
# Solução: `ovs-vsctl show` (Mata-a-pau em audit de portas)
# Ou mais aterrorizante: `ovs-ofctl dump-flows ovsbr0` pra checar a matriz de Forwarding em modo OpenFlow Controller.
# ==============================================================================

# ==============================================================================
# 5. CONCEITO SENIOR (O "porquê" profundo)
# VxLAN e SDN Overlay Cloud via OpenvSwitch:
# Imagine Seu Host KVM está em Nova York, e Host B em São Paulo. Você quer que 
# as duas Máquinas virtuais deles se pinguem sem saber que cruzaram o oceano, 
# existindo na mágica da LAN interna Broadcast 192.168.10.x.
# Você anexa a bridge com `ovs-vsctl add-port ovsbr0 vxlan0 -- set interface vxlan0 type=vxlan options:remote_ip=IP_SP`.
# E a mágica é feita em Kernel Data-Path Tunneling. Essa é toda a arquitetura base
# existente do Calico/Cilium Kubernetes ou Neutron de OpenStack Cloud! Tudo baseado nisso.
# ==============================================================================

# ==============================================================================
# 6. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se nós estivéssemos desenhando um Cluster KVM para milhares de contêineres e VMs 
# em alta segurança, por que migrar da ponte tradicional 'brctl' para o 'Open vSwitch' OVS
# se demonstra financeiramente obrigatório em termos de gestão de VLAN tagg e performance?"
# Resposta esperada: "Enquanto Linux Bridges lidam com VLANs e Trunk através de pesadas 
# ramificações de subinterfaces (`br0.10, br0.20`), poluindo o sysfs e kernel root, 
# O Open vSwitch processa tags IEEE 802.1Q internamente baseado em regras de Tabela de Fluxos (Flow Cache)  
# em memória, que processam milhões de pacotes com MegaFlows no Kernel de forma unificada. Ele 
# fornece Telemetria L2/L3 com os logs NetFlow, e nós atrelamos políticas de Quality Of Service (QoS / Policing)
# limitando banda para VMs barulhentas instantaneamente em tempo real na switch logic — algo penoso no design tradicional leg."
# ==============================================================================
