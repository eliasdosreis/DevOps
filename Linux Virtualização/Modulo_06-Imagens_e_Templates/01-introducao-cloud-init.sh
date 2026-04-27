#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você recruta 50 novos funcionários (VMs em branco). Em vez de você ir até a mesa
# DE CADA UM DELES (Abrir o Console SSH), e ditar: "A sua senha é X, instale o Pacote Y, 
# mude a sua placa de rede para o IP Z" (Trabalho Manual). Você simplesmente Grampeia um 
# ENVELOPE com as métricas já preenchidas no Computador de Cada um antes deles chegarem. 
# Quando a Máquina Ligar, o Inquilino lê o Envelope e se Auto-configura SOZINHO.
# Isso é o **Cloud-init**.
#
# 2. O QUE É (Definição Técnica Senior)
# O Cloud-init é o pacote de indústria `de-facto` multiplataforma p/ inicialização instanciada
# O pacote (Já pré-instalado em imagens Cloud-Ready como Ubuntu-Cloud), lê na fase de boot 
# "Data Sources" (Fontes de metadados como Amazon AWS Metadata server, ou no KVM local: Uma micro ISO de CD-ROM anexada chamada `seed.iso`).
# O serviço consome um arquivo YAML (user-data e meta-data), configura Netplan, SSH Keys Autorizadas, senhas e scripts Arbitrários sem requerer SSH e DHCP pre-definido.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Como o KVM "Engana" o Ubuntu injetando o Envelope Cloud-init Localds.
# ==============================================================================

# PASSO 1 - Escrevendo a Carta/Envelope do Funcionario (user-data)
cat <<EOF > user-data.yaml
#cloud-config
# O cloud-init vai forçar o Hostname nativo via hostnamectl
hostname: srv-web-01
manage_etc_hosts: true

# Configura o primeiro usuário padrao e a chave PUBLICA SSH (Pra gente não usar senha suja)
users:
  - name: elias-admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    ssh_import_id: None
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-rsa AAAAB3Nza... (SuaPublicaAqui...) elias@macbook

# Pós Instalação Automática Crucial
package_update: true
packages:
  - qemu-guest-agent
  - nginx

runcmd:
  - systemctl enable --now qemu-guest-agent
  - echo "Bem vindo a matrix infra-as-code!" > /var/www/html/index.html
EOF

# PASSO 2 - Gravando o Meta-data local (O ID Cpf da máquina e info do provedor)
cat <<EOF > meta-data.yaml
instance-id: i-kjf8sfsfwkw01
local-hostname: srv-web-01
EOF

echo "=== 3. Empacotando o Envelope como CDROM Virtual RAW (Seed.iso) ==="
# 'cloud-localds' é a ferramenta pacote `cloud-image-utils`. 
# Ela converte os Yamls num Volume MBR/Iso9660 Label: cidata (Formato que o Cloud-init espera achar no Boot).
cloud-localds seed_vdb_cloud_init.img user-data.yaml meta-data.yaml

echo "=== 4. Lançando a VM injetando a Iso base + A Seed do Cloud-init ==="
# Ao rodar isso a Maquina acorda, Pega a IMG do Ubutnu Limpa... Vai no segundo drive..  
# Oh! Um pendrive com CD label "cidata" yaml! Ela muda a própria rede, a conta e instala NGINX! Voilá!
# (Representacao abstrata pro virsh)
# virt-install \
#   --name Srv-Web \
#   --disk path=ubuntu-22.04-cloudimg.qcow2,format=qcow2,bus=virtio \
#   --disk path=seed_vdb_cloud_init.img,device=cdrom \
#   --noautoconsole 

# ==============================================================================
# 4. PASSO A PASSO
#
# Comando: cloud-init analyze show
# Se vocẽ finalmente logar no Servidor Ubuntu pela primeira vez. 
# Execute isso no terminal pra ver quantos SEGUNDOS as rotinas do Yaml 
# demoraram pra iniciar a rede via Cloud-init vs Systemd puro.
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você cria uma VM com a imagem ubuntu-cloud. Mas o Yaml do Nginx e User-data
# TÁ TODO ERRADO. A máquina boota, as 500 falhas se multiplicam, você não consegue logar nela.
# Você desliga a Vm, arruma o Yaml no CD-rom gerado, dá boot DNV, mas NÃO INSTALA e as Keys não atualizam!
# Causa: A Filosofia "Initial-Boot". O Serviço Cloud-init POR DESIGN sela a maquina pós o T=0. 
# Ele escreve marcadores ocultos em `/var/lib/cloud/instance/` decretando "Eu ja configrei esse Host". 
# Se você der boot dnv com outra iso Seed, ele VAI IGNORÁ-LA POR SEGURANÇA.
# Solução: Uma vez manchada a config T=0.. DESTRUA O DISCO BASE e comece outro. Ou rode
# manualmente (Pelo backend serial): `cloud-init clean --logs` que ele esquece e executará no prox boot.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Cloud-init substitui as terríveis Ferramentas Antiquadas do Kickstart (.ks)
# ou Preseed da Redhat/Debian! Nestas últimas, você precisava passar o script 
# EM TEMPO De Instalação da ISO Lenta formatando partição, durando 15 minutos de Boot.
# Com Cloud-Init: Nós baixamos a Imagem PRONTA pre-instalada limpa Cloud da distro 
# (Tamanho de 300Mb). E injetamos o NoCloud DataSource localmente no segundo barramento SCSI. 
# O Tempo de Setup cai de "Instalar um DVD (15 min)" para "Bootar Cópia Magra (6 Segundos)".
# Isso permite Instanciar e Alocar Auto-scaling Kubernetes Nodes sob Load Balancers no KVM  
# sem sofrer com gargalos de espera nos Triggers ANSIBLE posteriores.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Sua arquitetura de Datacenter exige a inicialização de VMs usando Imagens base 
# oficiais Ubuntu, porém sem usar DHCP, o IP precisa subir injetado Estático ANTES de montar
# o File System NFS. Como passar a variável subjacente de Rede (Net-plan / ENIs) 
# pra instruir o kernel host antes da chave de cloud config 'user-data' atuar na layer superior?"
# Resposta esperada: "Nós forneceríamos o objeto 'network-config: version 2' no 
# Cloud-init via volume seed (`NoCloud/config-drive`). A ferramenta `cloud-localds --network-config=net-fixo.yaml ...`
# anexa esta estrutura separadamente do `user-data`. Isso é crucial porque os estágios de boot (Cloud-init Local Stage) 
# leem a infraestrutura MACC addresses baseada nisso ANTES do network manager iniciar a pilha L2 e as aquisições DHCP de timeout 
# ou chamadas REST para metaservers, cravando o IP subjacente em tempo Kernel-startup zero."
# ==============================================================================
