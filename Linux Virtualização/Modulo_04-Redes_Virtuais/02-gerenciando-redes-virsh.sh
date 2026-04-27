#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Criar uma rede no libvirt é como mandar o Síndico puxar um novo cabeamento 
# para um corredor privado. Você passa a planta (XML), que contém onde fica 
# a calha (bridge name), qual a faixa de números dos apartamentos (IPs DHCP), e 
# se aquela rede pode ou não sair pra rua pra ligar pra pizzaria (Forward/NAT mode).
#
# 2. O QUE É (Definição Técnica Senior)
# O Libvirt gerencia as Redes Virtuais em abstração de `<network>`. Sob os 
# panos o `virtnetworkd` levanta a intreface "virbrX" via syscall sysfs, executa
# `dnsmasq` atrelado em PID único àquela porta pra gerenciar DNS/DHCP interno,
# e compila novas linhas FORWARD nas tabelas iptables/nftables nativas Linux.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Definir uma rede Isolada Segura de Banco de Dados sem Fio XML
# ==============================================================================

# Crie esse script XML na sua maquina ou /tmp/rede_db.xml
cat <<EOF > /tmp/rede_db_isolated.xml
<network>
  <!-- O Identificador da Rede para a CLI virsh -->
  <name>database-isolated</name>

  <!-- NOME da interface que aparecerá rodando o comando \`ip a\` no Host Linux. -->
  <bridge name='virbr-db-00' stp='on' delay='0'/>

  <!-- A Mágica SENIOR: Omitted Forward element.
       Sem a tag <forward mode='nat'/>, nenhuma regra de roteamento externo
       será gerada. É uma gaiola de ouro perfeitamente isolada. -->

  <!-- Configuração IP (Subnet Privada de Banco de Dados Classe A 10.x) -->
  <ip address='10.10.10.1' netmask='255.255.255.0'>
    <!-- O pequeno DHCP Server injetado pelo Libvirt (Dnsmasq invisível) -->
    <dhcp>
      <range start='10.10.10.50' end='10.10.10.200'/>
    </dhcp>
  </ip>
</network>
EOF

echo "=== 1. Validando e Injetando a Rede Nova ==="
# virsh net-define carrega o XML no banco daemon e testa sua validade sem ligar
virsh net-define /tmp/rede_db_isolated.xml

echo "=== 2. Ativando O Switch Virtual ==="
# O Kernel receberá a ordem, puxará a ponte L2 virbr-db-00 e IP host 10.10.10.1
virsh net-start database-isolated

echo "=== 3. Forçando a Subir sempre com o Servidor Root ==="
# Garante que as VMs deste banco não reiniciem sem cabo plugado pq o host rebootou
virsh net-autostart database-isolated

# ==============================================================================
# 4. PASSO A PASSO
#
# Comando 1: virsh net-dhcp-leases default
# - O que faz: Muitas vezes criamos Vms mas não sabemos QUE IP ELA PEGOU pra
# dar SSH nela! Este comando interroga o DNSMasq do libvirt e exibe imediatamente
# a tabela de Endereços IP mapeados a VM MAC.
#
# Ex:  Expiry Time          MAC address        Protocol  IP address                Hostname      
# -----------------------------------------------------------------------------------------
# 2026-10-18 10:20:00  52:54:00:23:45:67  ipv4      192.168.122.3/24          lab-node01
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você manda "virsh net-start default" e ganha um erro trágico: 
# "Failed to start network default. dnsmasq failed to start".
# Causa: Você rodou um servidor Apache, ou outro `dnsmasq` GERAL instalado via apt-get 
# na sua máquina FÍSICA e ele cravou bind global na porta TCP/53 (DNS). 
# Agora o pobre coitado do dnsmasq mini da libvirt nao consegue bindar no mini switch.
# Solução: O DNS da máquina fisica DEVE rodar configurado pra escutar apenas nos
# `bind-interfaces` ou desabilite o systemd-resolved conflict na porta 53 local.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O `mac filter` nativo (Spoof Checking em Redes). 
# No ambiente bare-metal host, você injela a tag `<filterref filter='clean-traffic'/>` 
# na inteface Virtual do XML de uma respectiva Vm suspeita na libvirt. 
# O NWFilter subsystem aplica anti-MAC Spoofing e ARP Poisoning bloqueando 
# (via chaves ebtables/nft zero overhead) qualquer pacote gerado por essa VM que tente falsificar
# o IP original registrado pelo DHCP dhcp-snooping, eviscerando ataques man-in-the-middle
# perpetrado por hackers infectando a VM Guest invadida tentando atacar as outras instâncias Bridge.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se precisarmos garantir que nossa instância do vCenter Virtual ou 
# nosso Master node Kubernetes pegue SEMPRE O MESMO IP DENTRO da Rede NAT Libvirt,
# mas não temos acesso SSH e não podemos forçar IP Estático no seu OS interno (via netplan). 
# Como resolveriamos puramente no Hypervisor?"
# Resposta esperada: "Nós editaríamos a rede através de `virsh net-edit <network>`
# e adicionaríamos na subceção `<dhcp>`, a reserva IP Estática por reserva de MAC atrelada ao servidor dnsmasq.
# Exemplo: `<host mac='52:54:00:11:22:33' name='kubemaster' ip='192.168.122.10'/>`. 
# Dessa forma, mesmo rodando cliente genérico DHCP na VM de forma limpa e auditável, o hypervisor 
# libvirt forçará eternamente a cessão da locação daquele endereço, mantendo 
# as referências de DNS intocáveis."
# ==============================================================================
