#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Você fez dezenas de casas de bonecas idênticas (Full Clone): Compriu dezenas 
# de metros de madeira, tinta e janelas pra cada uma, mesmo que um usuário não brinque com elas. (Aquele `cp imagem.qcow backup.qcow` gigas).
# 
# Você aplica o Molde Fotostático (Linked Clones): A Casa original fica num pilar visível.
# Você entrega pros clientes apenas um papél em branco em cima das janelas transparentes. 
# Sempre que o cliente não faz nada, nós lemos a base através do vidro (A imagem Original base). Se ele pinta
# O vidro de vermelho (Escreveu no Hdd ext4), nós salvamos só A TINTA no papel. 
# Resultado: Instanciamos Mil servidores Ubuntu do Mesmo O.S em meros 10 Segundos e cada 
# cliente gasta apenas 100 megas invés de 10 GB.
#
# 2. O QUE É (Definição Técnica Senior)
# `virt-clone` é a API de Deep / Shell Copy da libvirt para cópia total re-faturando GUID e Macs auto.
# Linked-Clones baseiam-se em Qcow2 Backing Store Chain.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Provisionar Dezenas de Instâncias Usando The "Golden Image" Linked Method
# ==============================================================================

IMG_BASE="/var/lib/libvirt/images/UBUNTU_GOLDEN_BASE.qcow2"
NOVO_CLIENTE_IMG="/var/lib/libvirt/images/vm-cliente-x01.qcow2"

echo "=== 1. Travando a Golden Image Pra sempre ==="
# Qualquer gravação acidental (Um start da vm na base) Destruiria as File hashes
# bloqueando a vida de TODOS OS CLONADOS dela!
chmod a-w "$IMG_BASE"

echo "=== 2. O COMANDO MÁGICO (Linked Clone Qemu) ==="
# Crio disco qcow vazio, Apontando "Backing File" pra matriz Read-only. 
# Formato Backing (-F). É mandatório p proteger vulnerabilidades Backing format Injection.
qemu-img create -f qcow2 -b "$IMG_BASE" -F qcow2 "$NOVO_CLIENTE_IMG"

echo "=== 3. Automatizando o XML ==="
# O virt-install se chamardo com --import usa o disco e pula a tela de Cd/Instalacao O.S, ativando on boot.
virt-install \
  --name VM-CLIENTE-01 \
  --os-variant ubuntu22.04 \
  --memory 2048 \
  --vcpus 2 \
  --disk path="$NOVO_CLIENTE_IMG",format=qcow2,bus=virtio \
  --network network=default,model=virtio \
  --import \
  --noautoconsole

# ==============================================================================
# 4. PASSO A PASSO (VIRT-CLONE PADRÃO)
#
# Se precisarmos da cópia TRADICIONAL Pesada (Full clone Indepedente onde base e filho nao se encostam).
# Usaríamos: 
# `virt-clone --original ubuntu_gold --name Ubuntu-Filha --auto-clone`
# A cli libvirt fará os block-copies seriais e reatribuindo chaves Mac e VNC xml pra voce.
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você manda "qemu-img info" no disco clonado do cliente recem criado e 
# ele mostra: Virtual Size: 40G. Disk Size: 1.5M !!! 
# Ai você desespera achando que ocorreu erro na conversão pq tem apenas míseros "Mega Bytes"!
# Solução: Isso é o êxito supremo do Linked Clone e metadados! O QEMU mapeou lógicamente 
# teto (40G) mas fisicamente a delta layer do cliente foi recem forjada.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Qemu Rebase & BlockCommit Live-Streamming
# A Base Gold envelhece? Claro que envelhece! Kernel antigo do Ubuntu em 2026!
# Como eu migro um Client atado a ela pra Base Gold 2026? 
# O Senior executa `qemu-img rebase -b NOVA_UBUNTU_BASE.qcow2 vm-cliente-x01.qcow2`.
# Isso lê as deltas da antiga q n existam na nova, escreve num buffer L1 e repareia o vetor.
# Ou então se o cliente pediu que sua VM se Desprenda (Por Segurança ele nao quer ser um LinkedClone).
# O Admin roda `virsh blockpull domain1 vda`, que Injeta magicamente (em quente s/ desligar VM)
# TUDO o que estava na GOLD puxando pra engordar o arquivo delata e esvaziando back chain! Desvinculando ele vivo.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se temos 200 Linked Clones QCOW2 na produção sendo lidos através do 
# backing file 'CentOS-Gold-Image.qcow2'. Em termos de Memory e Buffer Page Host Caching, 
# existirá um desperdício monstruoso de Buffer ao Hospedeiro tentar abrir simultanemanete 200 conexões de leitura pra
# mesmo Image Data no storage layer, estourando as TLBs caches?"
# Resposta esperada: "Ao contrário, e justamente ai repousa a escalabilidade massiva de Hypervissores kernel-based. 
# Quando o Linux Host mapeia a Gold Base File no VFS layer, todos os 200 processo QEMU Guests que abrem
# requisição File Description de READ-Only para blocos Idênticos desta mesma imagem, são interceptados pelo  
# Page Caching do Host OS. O Linux carrega o arquivo CentOS inteiro NA RAM DO HOSPEDEIRO apenas UMA VEZ. 
# A leitura de 200 clientes vai bater Cache-hit de 99% na RAM e não no disco SAS giratório, mitigando o desperdício, 
# a ponto de 200 vms clonadas executarem o Boot Load OS mais violentamente rápido do que 5 instâncias operando drives RAW apartados."
# ==============================================================================
