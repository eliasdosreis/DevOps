#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Ser gestor das Máquinas Virtuais usando a UI (virt-manager) é confortável, 
# como checar relatórios numa TV. 
# Operar no terminal (virsh) é como estar no Cockpit do avião e controlar
# alavancas em milissegundos num caos. E em servidores NúcleoS/Headless de Datacenter 
# você NÃO TERÁ painéis bonitos num servidor SSH do meio da noite num Feriado. 
# A dominância do `VIRSH CLI` separa os homens dos meninos.
#
# 2. O QUE É (Definição Técnica Senior)
# Cintos de utilidades da Command Line Interface (CLI) da Libvirt.
# Ferramenta construída na biblioteca libvirt, possuindo um set de verbos de Lifecycle, 
# Monitoring Device Manipulation.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Executar comandos de inspeção profunda do sistema virsh
# ==============================================================================

echo "=== 1. Informações Sumárias sobre um Domínio (VM) ==="
# virsh dominfo <NOME_DA_VM> (Domínio é o termo técnico para VM no Libvirt)
# Esse comando exibe ID do SO (QEMU_PID), Número da vCPU alocada MAX e RAM Limite/Usada, 
# junto com o "Security label" que o Kernel (SELinux/AppArmor) está blindando o processo.
echo "Executando: virsh dominfo example_vm (Simulado para entendimento)"
# Saida Esperada:
# Id:             5
# Name:           srv-database-prod
# UUID:           xxxxxxxx-xxxx-xxxx-...
# OS Type:        hvm (Hardware Virtual Machine)
# State:          running
# CPU(s):         4
# CPU time:       224599.2s

echo -e "\n=== 2. Comandos de Hotplug de Inspeção em Quente ==="
# As VMs possuem Hardware sendo "arrancado e enfiado" por baixo dos panos na API!
# Lista os blocos de Disco Atuais plugados. Você pode achar VDB, VDC etc em tempo real.
echo "Executando domblklist: (Discos da VM)"
# virsh domblklist srv-database-prod 
#
# Lista as interfaces de Rede anexadas Atualmente (Ex: Para pegar o endereço MAC pra injetar no DHCP Físico)
echo "Executando domiflist: (Placas de Rede Vms)"
# virsh domiflist srv-database-prod 
#
# Listar as Informações detalhadas da vCPU - Qual núcleo fisico host cada linha thread da vm está plugada?
echo "Executando vcpuinfo: (Pinagem de CPU)"
# virsh vcpuinfo srv-database-prod 

# ==============================================================================
# 4. COMANDOS PASSO A PASSO
#
# Comando 1: virsh edit MINHA_VM 
# O comando REI de TUDO: Abre as confs em modo seguro. Se tentar apagar a RAM 
# do arquivo e der Salvar (`:wq`). O virsh irá interceptar o arquivo corrompido, e  
# gritar em vermelho: "Error in XML. Faltam definições de memória!". Impedindo
# a quebra permanente da infraestrutura.
#
# Comando 2: virsh console MINHA_VM 
# Lança sua shell do monitor do Host diretamente na TTY do Kernel "serial terminal" da VM Guest 
# bypassando interfaces de rede SSH e firewall (Excelente para quando o DEV do convidado tira do ar por
# erro do IP e quebrou o network adapter dela pelo interior!).
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Tentar fechar a janela do `virsh console` digitando CRTL-C num pânico.
# Causa: O CRTL-C será interpretado PELA VM INTERNA e o linux convidado matará o processo logado. 
# Você fica preso para sempre olhando a tela.
# Solução de Fuga Sênior: Para ESCAPAR as garras do terminal serial do virsh console, 
# deve-se usar a Sequência Secreta de liberação Telnet/Escape Character: 
# Pressione Simultâneamente:  `CTRL  e  ]`  (Contra Tecla e Chaves Fechando).
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# A Diferença entre DOMSTATE em Transient e Persistent Domais:
# Quando uma VM existe no libvirt mas foi rodada apenas temporariamente via console XML (Live),
# sem estar atrelada a /etc/libvirt/qemu, ela é TRANSIENT. 
# Se ela for transient, quando alguém enviar `virsh destroy VM` (Cortar energia), o DOMÍNIO  
# E TODO O RASTRO DE QUE ELE NUNCA EXISTIU irá expurgar o cache, ele some da UI sem vestígio.
# Isso é intensivamente usado por provedores cloud em funções FaaS/Lambda temporárias em microVms.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se precisarmos realizar manutenção de RAM em um servidor, mas o cliente exige Zero
# Downtime ou Zero Reboot do Guest de Banco de Dados hospedado. É possível adicionar Memória
# a quente (Hotplug) com o virsh sem reiniciar o domstate?"
# Resposta esperada: "Sim. Em configurações e infraestruturas avançadas (que o Linux Host permita 
# e o Linux/Windows VM Convidado suporte Memory Hot-add acpi via kernel module), o virsh executa:
# `virsh setmem <nomeVm> <TamanhoEmKilobytes> --live`. Modificando a tag currentMemory sem
# shutdown. Vale ressaltar que 'Diminuir' RAM hot-unplug é tecnicamente complexo pois
# a VM precisa liberar páginas fisicamente seguras, recomendando-se usar a estratégia 
# de Balloon device drivers com `virsh setmem ...` pra forçar o encolhimento interno cooperativo".
# ==============================================================================
