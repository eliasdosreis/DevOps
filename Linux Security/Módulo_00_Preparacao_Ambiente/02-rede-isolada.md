# Módulo 0: Preparação do Ambiente
## Aula 02 - Rede Isolada (Laboratório Seguro)

### 1. ANALOGIA DO DIA A DIA
Pense na rede isolada como uma "Jaula de Faraday" ou uma "sala de quarentena" num hospital. Se você vai trabalhar com vírus altamente contagiosos (ou no nosso caso, exploits de rede perigosos, malware ativo e port scans agressivos), você não pode abrir as janelas e portas para o resto dos pacientes. Você precisa de um ambiente onde nada entra sem passar por um guardião forte e, principalmente, **nada sai**.

### 2. O QUE É (definição técnica Senior)
Uma Rede Isolada no contexto de Pentest Lab é uma segmentação Lógicamente contida, habitualmente implementada por meio de switches virtuais dentro do hypervisor (ex: modo `Host-Only` ou `Internal Network` do VirtualBox). Nesse modelo, as placas virtuais de rede (vNICs) das máquinas alvo (vulneráveis) e as máquinas atacantes (KaliLinux/ParrotOS) conseguem trocar pacotes IP entre si, mas não possuem Rota Default para a placa física do *Host* principal em direção à Internet ou LAN. A topologia padrão evita a interatividade oculta com serviços reais.

### 3. SCRIPT / COMANDO COMENTADO
Como é configuração via interface gráfica na maior parte das vezes, um comando de exemplo para o próprio Linux Host (caso use `KVM/libvirt`) para criar a rede seria:

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Em ambientes KVM/Libvirt gerenciados via virsh, define
# uma rede totalmente isolada simulando nosso lab no CLI.
# ============================================================

#!/bin/bash

# Criando um XML temporário definindo a rede "isolated-lab"
cat <<EOF > /tmp/isolated-lab.xml
<network>
  <name>isolated-lab</name>
  <!-- Definindo sem tags de foward (SEM NAT, SEM BRIDGE) -->
  <bridge name="virbr-iso" stp="on" delay="0"/>
  <!-- Sub-rede do laboratorio isolada na 10.0.0.X -->
  <ip address="10.0.0.1" netmask="255.255.255.0">
    <dhcp>
      <!-- range que as VMs alvo pegarão IP -->
      <range start="10.0.0.100" end="10.0.0.254"/>
    </dhcp>
  </ip>
</network>
EOF

# Registrando e Iniciando a rede no Virsh (Se for KVM)
# virsh net-define /tmp/isolated-lab.xml
# virsh net-start isolated-lab
# virsh net-autostart isolated-lab
```

### 4. PASSO A PASSO
**Passo 1:** No VirtualBox, vá em Preferências -> Network -> e crie ou ative a aba "Host-Only Networks" ou "Nat Network". A escolha mais segura é a "Host-Only" se você quer acessar SSH a partir de sua máquina Windows usando PuTTY.
**Passo 2:** Nas configurações da VM Atacante (Ex: Kali Linux), defina a placa como "Host-Only".
**Passo 3:** Nas configurações da VM Vulnerável (ex: Metasploitable), faça o mesmo: coloque em "Host-Only".
**Passo 4:** Agora, ambas estarão na mesma faixa de IP (ex: `192.168.56.x`) fornecida pelo VirtualBox.

### 5. VERIFICAÇÃO E TROUBLESHOOTING
- **Na VM atacante, teste o alcance:** `ping <IP_DA_VM_VULN>`
- **Comando não sai pacote:** Provavelmente é porque a VM não recebeu DHCP na nova rede isolada. No terminal de cada VM, rode `ip addr` ou reinicie as interfaces com `ifdown eth0 && ifup eth0` ou reiniciando o serviço, dependendo do OS.
- **Troubleshooting Sênior:** Muitas vezes a placa não subiu no boot (`ONBOOT=yes` no CentOS/RedHat, ou dhclient falhou). Faça manualmente: `sudo dhclient eth0`.

### 6. CONCEITO SENIOR (o "porquê" profundo)
Muitos malwares, vermes (worms) legados contidos em sistemas como Windows 7/XP rolam scans RPC agressivos (MS08-067, EternalBlue) assim que iniciam. Quando fazemos análises dinâmicas em honeypots e enviamos pacotes de broadcast com `nmap` de uma VM injetada para a outra, essa poluição de tráfego, no caso da Bridge, acionaria alertas de IDS/IPS (Suricata, Snort) da rede da sua empresa ou até do provedor, gerando chamados de suporte do SOC para isolar a sua mesa na empresa. Isolar é higiene profissional, evidenciando respeito pelo domínio de colisão e transmissão do cliente.

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Suponha que no seu laboratório, além das VMs estarem isoladas em *Host-Only*, uma delas precisa de conexão externa controlada para baixar certas atualizações específicas (somente para a porta TCP/443 de um único domínio), e as demais devem ficar ocultas de fato. Qual é uma abordagem arquitetural adotada em SOCs para lidar com esse gateway de saída restrito em labs?"
**Resposta Esperada:** Instanciação de um Firewall/Router virtual (como pfSense, OPNsense ou uma VM Linux simples com iptables) que atua como Default Gateway para as VMs restritas. Essa máquina possui duas vNICs (uma na frente externa com NAT/Bridge, uma interna). Em seguida, regras estritas de Egress Filtering são construídas liberando *apenas* a comunicação essencial da VM que requer tráfego externo, fazendo block drop explícito de todo o resto. Isso mantém o rigor do isolamento provendo funcionalidade pontual.
