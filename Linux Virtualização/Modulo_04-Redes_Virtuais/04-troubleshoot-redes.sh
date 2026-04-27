#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# A placa de rede física está ligada. O Cabo está no Hub Virtual. E Sua Vm ligada.
# Pinga os coleguinhas? PINGA!
# Pinga o 8.8.8.8 na Internet Google? TIMEOUT 100% loss. 
# O que fechou a torneira? Geralmente, a água na rua (Datacenter Externo) não 
# flui pra canos que eles "não conhecem", ou o porteiro (Firewall Host) achou
# o pacote suspeito cruzando a catraca da porta e explodiu o pedaço.
#
# 2. O QUE É (Definição Técnica Senior)
# Packet Drops em Ambientes Virtualizados concentram-se no Layer 2 Bridge Filtering 
# em conflitos de Sysctl, ou em Masking Error Routing do Linux Forwarding Chain,
# ou Anti-spoofing em hypervisors da Nuvem Subjacente (ex: Hetzner / AWS / OVH port sec).
# ==============================================================================

# ==============================================================================
# 3. COMANDOS PASSO A PASSO SR (A Bula do Diagnóstico)
# Objetivo: Ferramentas pra varrer de ponta a ponta sem adivinhar.
# ==============================================================================

# Passo 1. O Kernel do Host está autorizado a ser roteador de IPs?
# O Sênior checa Imedatamente a Master Flag Sysctl Route (Requisito mandatório pra NAT network funcionar).
sysctl net.ipv4.ip_forward
# > Esperado: `net.ipv4.ip_forward = 1`

# Passo 2. As Redes de fato atrelaram-se nas Bridges lógicas corretas nas entranhas?
# O IP link mostrará que as VnetX (Placas das VMs vivas) estão dentro dos MASTER.
ip link show master virbr0
# > Esperado : `vnet1: <BROADCAST,MULTICAST,UP...> master virbr0 state UNKNOWN`

# Passo 3. (Caso de Cobre Bruto Host/Hetzner Drop). Mac-Spoffing físico em nuvem.
# Se o Datacenter te atrelou 1 MAC físico e você tentou rodar Máquinas em Bridge Externa sem rotear,
# A Nuvem física achará que estão hackeando o Switch Rack deletando sua porta por anti-Spoof.

# ==============================================================================
# 4. VERIFICAÇÃO COM TCPDUMP OMNIPRESENTE
# ==============================================================================
# Você NÃO PRECISA de senha dentro da VM do Cliente pra auditar porque o pacote morre. 
# O Hypervisor Host POUDE olhar o tunel cruzando a Vnet host-side e monitorá-lo.
# Comando de Raio-X do Administrador Host:
# tcpdump -i vnet0 -nn icmp
# "Escute na linha virtual 0 (placa da VM), sem converter nomes a dns (-nn) e me mostre só PINGs."
# Resultado: Você verá o "Echo Request" saindo pra o roteador e nunca havendo "Echo Reply". 
# Prova irrefutável de roteamento do Hypervisor truncado e falha no masquerade NAT!

# ==============================================================================
# 5. CONCEITO SENIOR (O "porquê" profundo)
# Firewalld/UFW Backend Block das tabelas libvirt.
# Ao reiniciar o Docker, ou recarregar as políticas do Firewalld base/UFW base 
# depois do libvirt estar iniciado (O Daemon do firewall flusha tabelas gerais).
# Isso deleta as Forwarding Polices que a libvirt construiu cuidadosamente na zona POSTROUTING para o NAT.
# 
# Solução Ouro Automática: Todo Senior implementa HOOKS LIVES e reinicia estritamente
# o tráfego chamando um restart forçado nas bridges de rede no libvirt:
# `virsh net-destroy default && virsh net-start default` - Essa execução 
# força a reconstrução completa das árvores em iptables/nftables da API e arruma magicamente a navegação.
# ==============================================================================

# ==============================================================================
# 6. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Seu laboratório relata que pingar entre Cidades nas VMs conectadas em VPN,
# falham sempre se eles transferirem arquivos GRANDES mas ping vazio 'pequeno' funciona.
# Você verifica a Virtualização KVM base/Host. Qual configuração obscura em interfaces virtuais (VirtIO/TAP)
# tipicamente quebra pacotes massivos sem relatar nos logs L2 do hospedeiro, e como ajustamos?"
# Resposta esperada: "Esses sintomas são a assinatura clássica de problema de MTU 
# (Maximum Transmission Unit) em Mismatch. Em redes overlay de virtualização (Vxlan/GRE/Ipsec VPN),
# as embalagens adicionais dos cabeçalhos encapsulam bytes extras, fazendo um pacote VirtIO gerado a 1500 bytes 
# da Vm Guest ultrapassar o teto físico na nic Real (ex: 1550b). 
# Os roteadores subjacentes L3 no datapath irão descartá-los (Drops of Fragment Needed).
# Resolvemos limitando o MTU ativamente da interface NAT/Bridge Virtual e o payload dnsmasq libvirt
# para MTU <= 1400 (ou o calculado teto overlay correto), forçando a VM Guest a modularizar seus tamanhos."
# ==============================================================================
