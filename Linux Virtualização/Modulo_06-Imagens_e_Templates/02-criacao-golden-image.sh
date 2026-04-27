#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você constrói 1 robô e veste ele, pinta os olhos e dá um nome ("Bob") e um CPF (MAC Adress).
# Agora você quer fazer uma FÁBRICA. Se você "clonar" o Bob 1000 vezes de forma crua, 
# você terá 1000 robôs que acham que se chamam Bob e que tem o MESMO CPF. O banco de dados (A rede L2 e o Active Directory) 
# enlouquece porque 1000 CpfS IGUAS tentam acessar a catraca da porta.
# "Sysprep" é o processo de tirar o Crachá, apagar as impressões digitais dele e resetar o Cérebro,  
# transformando ele num "Molde Universal Genérico (Golden Template)" pronto pra ganhar vida nas filiais.
#
# 2. O QUE É (Definição Técnica Senior)
# Sysprep / Virt-Sysprep sela o Guest OS para Deployment Massivo. 
# Ele ataca os blocos do Qcow2 Desligado (Offline) montando o LVM/FS do cliente KVM na API host, apagando:
# SSH Host Keys, Udev persist net rules (que amarram MAC fixo ao arquivo), UUIDs de kernel, History e Log temp caches.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Como o Sênior "Lava e Higieniza" uma qcow antes de distribuir
# ==============================================================================

# Passo 1. A Vm deve estar rigorosament Desligada pra podermos montar os blocos sujos de fora!
virsh destroy ubuntu_matriz || true

# Passo 2. Esvazia o cache pra liberar as páginas travadas!
wait

# Passo 3. A Poderosa Ferramenta Virt-Sysprep (Da libguestfs-tools bundle).
# Ela age como "Agente externo Médico" usando Augeas FS.
echo "=== Iniciando a Higienização da Base Golden Image ==="

# --operations: Os Plugins que ele ira executar p/ varrer sujeira.
# machine-id = Força regerar um Hardware Hash ID diferente
# customized = Comando cru q ele mandara dar RUN na raiz base (Ex: deletar chaves apt)
# ssh-userdir = Mata pasta .ssh suja de chaves pub antigas do dev.
virt-sysprep \
  --domain ubuntu_matriz \
  --operations "machine-id,ssh-hostkeys,bash-history,logfiles,tmp-files,net-hwaddr" \
  --enable "customize" \
  --run-command "apt-get clean && rm -rf /var/lib/apt/lists/*" 

echo "=== Concluído. Imagem Higenizada prar Master Template! ==="
# AGORA Sim, o arquivo: /var/lib/libvirt/images/ubuntu_matriz.qcow2
# Pode ser selado `chmod a-w` (Somente Leitura) para atuar de fundação aos próximos scripts Backing Files!

# ==============================================================================
# 4. PASSO A PASSO
#
# Dica do Senior: Executar virt-sysprep num arquivo HD muito fragmentado pode 
# inflar o arquivo porque deleções num FileSystem do lado de fora acabam movendo
# zeros num sparse-file QCOW engordando ele. 
# Comando pós-sysprep de mestres: 
# `virt-sparsify --compress ubuntu_matriz.qcow2 ubuntu_matriz_magra.qcow2`
# (Isso encolhe os zeros lixos que o sysprep apagou e reduz a Imagem Base pra meros MBs pra viagem).
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você roda Sysprep Numa imagem RHEL/AlmaLinux e quando liga
# a VM Clonada "Filha", ela sobe, mas está sem NENHUMA placa de rede. 
# Causa: As Distros RH Antigas atavam o IP estático num arquivo `/etc/sysconfig/network-scripts/ifcfg-eth0`
# preenchido com a clausula hardcoded de `HWADDR=MAC Antigo da VM base`. O virt-sysprep
# apaga o mac da máquina e joga outro la, mas a distro convidada se recusam a parear o ip.
# Solução: Certifique-se que NUNCA exista a clausula HWADDR hardcodada em templates Syspreps,
# deletando isso com `--run-command "sed -i '/HWADDR/d' /etc/sysconfig..."`
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# A Magia do Augeas e LibguestFS (O bisturi no Hypervisor).
# Quando você rodou o `virt-sysprep --domain`, Você notou que não forneceu root pass?
# Como ele entrou no Ubuntu para apagar o Bash-History?!! Hacker Host bypass?!
# EXATAMENTE. Isso É A Prova da assimetria do Hypervisor!! O pacote `libguestfs` atua criando 
# no backend um mini Kernel Linux (appliance) "Fantasma" e liga os blocos QCOW2 do paciente dentro dste appliance.
# O sistema Host Monta a partição EXT4 inteira do hospede, ignora senhas root, e DELETA os arquivos do disco
# frio (Offline fs surgery) manipulando as strings usando lib Augeas CLI config editor. 
# Moral: Se o Disco não for Criptografado por LUKS, o Kernel Host sempre é absoluto sob as VMs em cold state. SecOps total.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se temos que varrer (sysprep) imagens qcow2 para nosso laboratório, mas essas instâncias 
# contém volumes formatados em sistemas LVM Lógicos customizados de dentro ou ZFS Zpools fechados.
# O \`virt-sysprep\` agirá com a mesma fluidez natural atracando o filesystem da forma como faria com um ext4 cru?"
# Resposta esperada: "Depende intrinsecamente do appliance embutido da `libguestfs` acoplado ao Hospedeiro. 
# Se a VM Guest utilizou LVM (pv/vg base), o mini-servidor guestfs do host possui as ferramentas lvm2 
# para invocar `vgchange -ay` varrendo e atachando os volumes internos com sucesso. 
# Porém se o Guest utilizar sistemas alienígenas ou complexos não importados nativos no GuestFS (Ex: ZFS nativo sem kmods no host),  
# a inspeção block-mapping falhará e a injeção / manipulação de Sysprep não ocorrerá por recusa do Mount Lógico na topologia offline."
# ==============================================================================
