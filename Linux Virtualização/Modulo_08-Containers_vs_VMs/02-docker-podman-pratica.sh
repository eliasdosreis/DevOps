#!/bin/bash
# ==============================================================================
# Módulo 08 — Docker e Podman: O Runtime por Baixo dos Panos
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
#
# O Docker é como uma Pizzaria com sistema de delivery.
# Você (Desenvolvedor) prepara a receita (Dockerfile) e a empacota num Box Perfeito
# (Imagem Docker — layers imutáveis).
# O motoboy (Runtime Docker/containerd/runc) pega o box, abre o espelho mágico
# (namespace) no caminhão e entrega o serviço rodando.
#
# O Podman é a mesma pizzaria, mas SEM um Gerente Central (sem daemon root)!
# Cada motoboy é autônomo e não precisa de supervisor pra trabalhar.
# Isso é "rootless" — um container que roda como seu usuário normal, sem sudo.
#
# 2. DEFINIÇÃO TÉCNICA SÊNIOR
#
# A stack de containers tem CAMADAS:
# Docker CLI / Podman CLI  →  API REST
#   └── containerd (daemon de lifecycle de containers)
#         └── containerd-shim (processo intermediário)
#               └── runc (chama clone() e unshare() no kernel)
#                     └── Kernel: namespaces + cgroups + overlayfs
#
# O OCI (Open Container Initiative) especifica o formato de imagem e o
# runtime spec, garantindo que uma imagem construída com Docker rode em Podman,
# Kubernetes (CRI-O), e vice-versa.
# ==============================================================================

set -euo pipefail

echo "========================================="
echo " Módulo 08 — Containers na Prática"
echo "========================================="

# ==============================================================================
# 3. PRÁTICA: Anatomia de uma Imagem (Layers OverlayFS)
# ==============================================================================

echo ""
echo "=== 1. Entendendo Image Layers ==="
# Cada linha de um Dockerfile cria uma LAYER imutável no OverlayFS
# Isso permite reuso entre imagens (cache de build)
cat <<'DOCKERFILE'
# Este Dockerfile cria layers assim:
# Layer 1: FROM ubuntu:22.04      (base ~80MB)
# Layer 2: RUN apt update          (delta de ~30MB)
# Layer 3: RUN apt install nginx   (delta de ~20MB)
# Layer 4: COPY app /app           (delta de ~1MB)
#
# Se outra imagem também usa FROM ubuntu:22.04, a Layer 1 É COMPARTILHADA
# no storage host (OverlayFS lowerdir). Economizando disco e RAM!
DOCKERFILE

echo ""
echo "=== 2. Inspecionando o OverlayFS de um container ativo ==="
# Rode isso no HOST enquanto um container está ativo

# COntainer ID de exemplo
CONTAINER_ID="meu-nginx"

# Ver as camadas do OverlayFS montadas pelo runtime
# podman inspect --format '{{.GraphDriver.Data}}' $CONTAINER_ID
# Retorna algo como:
# map[LowerDir:/var/lib/containers/storage/overlay/SHA.../diff
#      UpperDir:/var/lib/containers/storage/overlay/SHA.../diff  <--- Gravável! (delta)
#      WorkDir:/var/lib/containers/storage/overlay/SHA.../work
#      MergedDir:/run/containers/storage/overlay/SHA.../merged]  <--- O que o container vê!

echo "Exemplo de inspect executado (container deve estar ativo)"

# ==============================================================================
# 4. PRÁTICA: Buildando uma imagem do zero SEM Dockerfile!
# ==============================================================================

echo ""
echo "=== 3. Container do zero com buildah (OCI) ==="
# buildah é a ferramenta para construir imagens OCI sem daemon

# Cria um container "working" baseado em scratch (container vazio!)
# buildah from scratch

# Monta o filesystem do container para manipulação direta
# MOUNTPOINT=$(buildah mount "$CONTAINER")

# Instala o bash diretamente nos arquivos do container (sem rodar dentro dele!)
# dnf install --installroot $MOUNTPOINT bash coreutils --releasever 9 -y

# Configura o ponto de entrada
# buildah config --cmd "/bin/bash" "$CONTAINER"

# Commita como imagem OCI final
# buildah commit "$CONTAINER" minha-imagem-minimalista

echo "Imagem minimalista seria criada com buildah (requer Linux host)"

# ==============================================================================
# 5. PRÁTICA: Redes de Containers — Equivalente ao libvirt
# ==============================================================================

echo ""
echo "=== 4. Rede de Containers (CNI / Netavark) ==="

# Criar uma rede isolada (equivalente ao virsh net-define!)
podman network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  rede-app-backend 2>/dev/null || echo "Rede já existe, continuando..."

# Listar redes (equivalente ao virsh net-list)
echo ""
echo "Redes Podman disponíveis:"
podman network ls

# Rodar dois containers na mesma rede (equivalente a VMs na mesma bridge)
# podman run -d --name db --network rede-app-backend postgres:15
# podman run -d --name app --network rede-app-backend \
#   -e DATABASE_URL=postgresql://db:5432/mydb \
#   minha-app

# Containers na mesma rede se comunicam pelo NOME (DNS automático!)
# O "db" é resolvido para o IP do container postgres — igual ao dnsmasq do libvirt NAT

# ==============================================================================
# 6. TROUBLESHOOTING DE CONTAINERS
# ==============================================================================

echo ""
echo "=== 5. Troubleshooting Avançado ==="

# PROBLEMA: Container sobe mas a app não responde na porta
# DIAGNÓSTICO:
# Passo 1: Verificar se o processo interno está rodando
# podman exec meu-container ps aux

# Passo 2: Verificar logs do container
# podman logs --tail 50 meu-container

# Passo 3: Ver o namespace de rede do container (igual ao tcpdump de VM!)
# CPID=$(podman inspect --format '{{.State.Pid}}' meu-container)
# sudo nsenter --target $CPID --net -- ss -tlnp

# Passo 4: Capturar tráfego DENTRO do container namespace
# sudo nsenter --target $CPID --net -- tcpdump -i eth0 -n port 80

echo ""
echo "=== 6. Kata Containers — O Melhor dos Dois Mundos ==="
# Kata Containers: cada container roda dentro de uma microVM KVM própria!
# O processo dentro do container está isolado por:
#   - Namespaces (container)
#   - QEMU/KVM (VM ultra-leve ~128MB)
#   - SELinux/sVirt (hypervisor)
# Performance próxima de containers + segurança de VM!
# Usado em: Azure AKS, Google GKE Sandbox, OpenShift

echo "Script demonstrativo concluído!"

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Sênior)
# ==============================================================================
#
# Pergunta: "Sua empresa roda um cluster Kubernetes com containerd.
# Um Security Audit reporta que containers com UID 0 (root) dentro do pod
# podem escrever em /proc/sys do HOST se o pod tiver hostPID: true.
# Como você mitigaria esse vetor de ataque preservando a funcionalidade
# de monitoramento que precisa de acesso a /proc?"
#
# Resposta esperada:
# "O vetor acontece porque /proc é montado com o namespace PID do host
# quando hostPID: true, expondo todos os processos e alguns arquivos de sysctl.
# A mitigação em camadas seria:
# 1. Substituir hostPID:true por um DaemonSet com securityContext.readOnlyRootFilesystem
#    e probes montando apenas /proc/<namespace-específico>
# 2. Aplicar PodSecurityAdmission (PSA) com policy 'restricted' bloqueando hostPID
# 3. Usar Kata Containers para isolar o namespace do pod numa microVM separada,
#    onde o /proc exposto pertence ao kernel da microVM e não ao kernel do cluster node
# 4. AppArmor/Seccomp profiles proibindo open() em caminhos /proc/sys fora da allowlist"
