#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Imagine rodar Backup Time Machine ou Jogar Video Game (Salvar State Base):
# Você vai alterar as engrenagens perigosas do Datacenter Banco hoje às 20h. 
# O Snapshot Tira uma FOTO em milissegundo de TODA AS COISAS (VCPU+RAM+HD Blocks).
# Se tudo der Kernel Panic, você volta pro Checkpoint e "NUNCA TERÁ ACONTECIDO O CRASH".
# A Magia? A Máquina nem precisa ser desligada na madrugada para a foto atuar.
#
# 2. O QUE É (Definição Técnica Senior)
# Snapshotting at Libvirt: Operações em modo Snapshot geram Deltas Reversos no formato QCOW2.
# Snapshots INTERNOS: Os deltas crescem dentro do mesmo arquivo físico QCOW único, entortando índices.
# Snapshots EXTERNOS: O servidor Convidado Cessa o Despejo (Freeze Write). O Qemu gera
# UM NOVO arquivo QCOW2 menor vazio referenciando Backing File pra base antiga Fria congelada, 
# E retoma despejo apenas no novo topo (A Prática segura massiva em Clouds Globais Openstack).
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Executar fluxo complexo de Checkpoints via Storage e Memoria KVM.
# ==============================================================================

VM="linux_lab_servidor"

echo "=== 1. Tira uma foto Rápida e Suja (Disco apenas na Raiz Interna) ==="
# --disk-only força ser atrelado puro em disco lógicos (Garante tempo ultra rápido  
# ignorando dumpar a Memória RAM de 32GB num disco, que levariam 3 minutos c/ máquina travada).
virsh snapshot-create-as --domain $VM \
      --name "PreAtualizacaoKernel" \
      --description "Snap antes do pacman -Syu perigoso" \
      --disk-only \
      --atomic

echo -e "\n=== 2. Listagem de Árvore Histórica ==="
# Demonstra os Checkpoints Encadeados (Você pode ter filhos de snapshots)
virsh snapshot-info --domain $VM --current
virsh snapshot-list --domain $VM


# echo "=== 3. O Fim do Mundo ocorreu, Devolva à Origem ==="
# ATENÇÃO! A reversão em Disco Interno sobrescreve em metadados a timeline! 
# Dados Escritos NO INTERSTÍCIO após a tela Azul VIRAM PÓ, as portas dos deuses recuam.
# virsh snapshot-revert --domain $VM --snapshotname "PreAtualizacaoKernel" --running

# echo "=== 4. Deletando o Histural pra Liberar GIGABYTES ==="
# Um arquivo `.qcow2` internamente entupido de Snaps antigos é lento (Overhead metadata index read block). 
# Remove o checkpoint unindo os merges de tempo.
# virsh snapshot-delete --domain $VM --snapshotname "PreAtualizacaoKernel"

# ==============================================================================
# 4. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você dá snapshot Quente na RAM LIGADA com Snapshot interno em Live state. 
# A VM de BD Oracle TRAVA e fica Inacesível caindo conexão por 5 minutos no seu ERP Financeiro, depois "destrava".
# Causa: Salvar RAM de 64 Gbs num Datacenter HD demora os 5 minutos. Nesse tempo 
# O Libvirt DEU PAUSE (Suspend System) parando tempo-espaço dentro do SO, para evitar Memory Dirty em tempo real.
# Solução: Snapshots Quentes com RAM Extensa necessitam Backend Storage de Altíssimo NVMe IOPS
# p/ minimizar a janela de Time Suspend em milissegundos, Ouu use Live External Snapshot Quiesced mode.
# ==============================================================================

# ==============================================================================
# 5. CONCEITO SENIOR (O "porquê" profundo)
# Qemu Guest Agent - FS-Freeze & Quiesce (O Suspiro Sincronizado do Kernel Master).
# O Grande Risco dum snapshot LUN em Vm rodando pesada: 
# O QEMU avisa o Block Storage "Copie AGORA". Mmas o Kernel LINUX DA VM tem buffers
# nas memórias RAM sujos (Delayed write flush no File System Ext4), que iam num SSD logo lá embaixo!.
# O Snapshot cortaria esse buffer! A cópia do backup ficaria corrupta! 
# O Senior injeta a Flag `--quiesce`. Que mágico? A Libvirt usa um backdoor na Serial (Porta Socket pty)  
# Acorda o Servidor DA VM lá por dentro, e diz "Esvazia e Mande Sincronizar (FSFREEZE SYNC) as Memórias em RAM agorinha!". 
# A VM trava File systems Segura pra cópia, Snapshot copiado atômicamente limpo, a Libvirt avisa FSThaw. DB Safe!
# ==============================================================================

# ==============================================================================
# 6. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Se temos uma Infraestrutura Base de imagens na qual nós derivamos centenas de
# "Múltiplos Clones Vinculados" (Linked Clones qcow2) referenciando sempre a Imagem Matriz (Backing File).
# E O administrador rodar um live merge command (qemu-img commit / blockcommit na raiz matriz do LUN). O que desanda em escala Global catastrófica?"
# Resposta esperada: "Ao realizar uma operação de Merge Back / BlockCommit Layer de um 
# snapshot Top na Base Original Matriz que compartilha N nós de outras VMs Clientes (Golden Rule Dependency),
# ocorrrerá a Corrupção Integral de CADEIAS da Infra inteira ligada nela! 
# A Imagem Matriz deve ser estritamente gerida em modo Read-Only, inalterável. 
# Se Commits de block backing descenderem para mescla na origm, Todos os Linked Clones 
# computarão assinaturas inválidos base num bloco delta não síncrono. Extinguindo 
# simultaneamente centenas de instâncias com ext4 header destruction em cascata."
# ==============================================================================
