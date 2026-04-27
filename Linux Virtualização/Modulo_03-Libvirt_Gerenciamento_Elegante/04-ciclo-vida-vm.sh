#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Administrar instâncias é como conduzir um veículo em um autódromo através das  
# manetes ou pedais de transição de fase de energia e de banco de dados.
# Start = Ignição; Suspend = Pausa a simulação estilo Videogame (Congelamento Criogênico); 
# Shutdown = Pede gentilmente à pessoa ao lado (ACPI guest) para puxar a chave sem estrago;
# Destroy = Você corta o FIO DA BATERIA COM ALICATE. Destruindo na marra (Geração de Hard Crashing).
#
# 2. O QUE É (Definição Técnica Senior)
# OS verbos Lifecycle afetam ativamente o State Transition Table do Daemon Libvirt.
# Existem processos como o Define/Undefine que adicionam e extraem XMLs das ramificações 
# da árvore sem tocar na energia da máquina física ou no Hypervisor em si.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: O Ciclo de vida estrito e operacional dos estados das VMs
# ==============================================================================

VM="ubuntu-lab-estudos"

echo "=== 1. DEFINE (A Matrícula) ==="
# virsh define arquivo.xml
# Carrega a config do XML na memória do daemon, escreve ele pro /etc/libvirt/qemu/ 
# e transforma ele de estado TRANSIENTE, para PERSISTENTE. 
# A VM existirá no futuro mesmo desligada e poderá usar 'autostart' no boot da máquina root.
# Obs: O 'create' arquivo.xml ligaria a VM porem em modo Não Persistente (Some se desligar).
echo "- Matrícula efetivada no galpão oficial."

echo "=== 2. START (O Boot de Hardware) ==="
# virsh start $VM
# Pega o mapeamento criado na Define, instanciona e submete os processos pro QEMU/KVM
# solicitando alocação física de RAM no nó de computação. As L1 Pages são formadas.

echo "=== 3. SUSPEND / RESUME (Congelamento Instantâneo) ==="
# virsh suspend $VM  |  virsh resume $VM
# Isso pausa 100% da VCPU. A máquina fica parada onde estiver. 
# Importante: A RAM (Memória da VM) CONTINUA SENDO CONSUMIDA NO HOST (O espaço fisico na RAM não é devolvido).
# Simplesmente o tempo Cessa. Ótimo pra tirar Snapshots frios de File System rsync.

echo "=== 4. SHUTDOWN Gracioso ==="
# virsh shutdown $VM
# Manda um sinal ACPI de power button (Igual dar um toque rapido no botão do seu gabinete)
# O Kernel LINUX DO GUEST tem que estar rodando e responsivo pra entender o sinal
# salvar seu systemd, e desligar lindamente seus bancos.

echo "=== 5. DESTROY (O Pós Fatal / Corte de Energia Seca) ==="
# virsh destroy $VM
# Sim, a palavra assusta e faz junior suar frio achando que apagou o arquivo de vez!
# Nao! Ela apaga O processo Ativo em Fogo! Igual a Puxar a Tomada.
# Ocorre perda das memorias transacionais que estivessem no ar e os discos sofrem power loss no write buffer.

echo "=== 6. UNDEFINE (A Rescisão de Contrato do Hospede) ==="
# virsh undefine $VM
# Esse sim destrói os registros de existencia! Remove o XML do /etc/libvirt e 
# tira o acesso do manager. Contudo (Atenção redobrada) o HD com os arquivos (O QCOW2)
# continua existindo esquecido na pasta `/var/lib/` sem ser excluído por precaução.
# Undefine com o flag `--remove-all-storage` deletaria o disco tbm.

# ==============================================================================
# 4. PASSO A PASSO
#
# Comando: virsh autostart $VM
# - O que faz: Ao religarmos NOSSO servidor hospedeiro FÍSICO onde as VM mora (Após a queda 
#   da subestação de energia da empresa). O Daemon sobe, e já executa start 
#   automaticamente nesta VM para devolver serviço o quanto antes à rede comercial.
#   Ele faz isso atochando um symlink do `.xml` na pasta `/etc/libvirt/qemu/autostart/`.
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você manda "virsh shutdown vm" e fica esperando. Manda `virsh list` e a  
# VM continua 'running'. Não desligou. Por que?
# Causa: A VM Guest Linux dentro não tem o daemon `acpid` (ACPI handler daemon) instalado
# (Como numa instalação Alpine mega enxuta ou um Ubuntu Minimal sem QEMU-Guest-Agent).
# Solução: A solução oficial é o sênior instalar o `qemu-guest-agent` POR DENTRO do sistema
# da VM via yum/apt-get. Ou intervir via SSH manualmente por terminal pra desligar com `init 0`.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Salvar o 'Memory Core Dump' ou (virsh save $VM arquivo.sav) - O Hibernar do Datacenter!!
# Quando eu disse que o `suspend` congela mas mantem Consumo da RAM FÍSICA HOST?
# O `virsh save` faz o Suspend e extrai um Stream Dump completo do que estava na 
# Memoria viva e MANDA PRA UM ARQUIVO DE TEXTO no HD de Storage e mata a VM fisicamente (Livra a RAM do host zero bytes consumidos).
# Semanalmente depois eu posso rodar `virsh restore arquivo.sav`. A VM acorda milissegundos dps, do mesmo lugar,
# com tudo carregado no Chrome aberto daquele funcionário perfeitamente intacto.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Seu analista Júnior lhe diz que não consegue dar START em uma Virtual Machine em pânico
# porque o console relata 'domain is already running', no entanto o `virsh list` e `htop`
# provam que o processo qemu está extinto na RAM. Sabendo que é uma corrupção do Lifecycle,
# Onde procuraremos o PID travado em falso transitório e como resolver?"
# Resposta esperada: "Ao crashar severamente o processo hospedeiro sem expurgar o cache, o daemon libvirt 
# continua sustentando falsamente um socket do monitor residual nos Ficheiros Sockets temporários 
# do host (localizados em `/var/run/libvirt/qemu/nomeVm.pid`). 
# Precisaremos deletar este arquivo de pid morto `.pid` que trancava o lock file, ou opcionalmente 
# efetuarmos o reload daemon com `systemctl reload libvirtd` forçando um handshake cleanup socket status, atestando o real  
# shut off pra posteriormente mandar a ignição correta (start)."
# ==============================================================================
