#!/usr/bin/env bash
# =============================================================
# SCRIPT: prepare-box.sh
# PROPÓSITO: Prepara a VM para ser empacotada como Box Vagrant
# EXECUTADO: Como root na VM que será empacotada
# 
# Esta é a lista de tarefas que um profissional Senior faz
# antes de criar uma box para o time.
# =============================================================

set -euo pipefail

echo "========================================================"
echo "🏗️  PREPARANDO VM PARA EMPACOTAMENTO COMO BOX VAGRANT"
echo "========================================================"

# =============================================================
# FASE 1: Instalar ferramentas que a box deve conter
# =============================================================
echo ""
echo "📦 Fase 1: Instalando ferramentas da DevBox..."

apt-get update -q

# Ferramentas essenciais que todo dev vai precisar
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  curl wget git vim htop tree net-tools jq unzip \
  build-essential python3 python3-pip \
  apt-transport-https ca-certificates gnupg lsb-release

# =============================================================
# INSTALAR DOCKER
# =============================================================
echo ""
echo "🐳 Instalando Docker..."

if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
  usermod -aG docker vagrant
  systemctl enable docker
  echo "✅ Docker $(docker --version | cut -d' ' -f3 | tr -d ',') instalado"
else
  echo "ℹ️  Docker já instalado"
fi

# Docker Compose
if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null 2>&1; then
  COMPOSE_VERSION="2.24.0"
  curl -fsSL \
    "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo "✅ Docker Compose $COMPOSE_VERSION instalado"
fi

# =============================================================
# INSTALAR NODE.JS
# =============================================================
echo ""
echo "🟩 Instalando Node.js..."

if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &>/dev/null
  apt-get install -y nodejs
  echo "✅ Node.js $(node --version) instalado"
fi

# =============================================================
# CHAVE SSH INSECURE DO VAGRANT
# =============================================================
echo ""
echo "🔑 Configurando chave SSH do Vagrant..."

# Baixa a chave pública insecure do Vagrant (necessário para vagrant ssh funcionar)
mkdir -p /home/vagrant/.ssh
curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
  >> /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo "✅ Chave SSH configurada"

# =============================================================
# FASE 2: LIMPEZA — CRÍTICA ANTES DE EMPACOTAR
# Uma box bem preparada tem o menor tamanho possível
# e não contém dados sensíveis
# =============================================================
echo ""
echo "🧹 Fase 2: Limpeza para minimizar tamanho da box..."

# Remove cache do apt (pode economizar 200-400 MB)
apt-get clean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

# Remove histórico de comandos (privacidade)
history -c
> /root/.bash_history
> /home/vagrant/.bash_history

# Remove chaves SSH geradas (serão regeneradas em cada VM)
rm -f /etc/ssh/ssh_host_*key*

# Remove logs do sistema
find /var/log -type f -exec truncate -s 0 {} \;

# Remove arquivos temporários
rm -rf /tmp/* /var/tmp/*

# =============================================================
# FASE 3: COMPACTAR O DISCO VIRTUAL
# Preenche o espaço livre com zeros para que o compressor
# do vagrant package possa reduzir o tamanho do arquivo
# =============================================================
echo ""
echo "💿 Fase 3: Compactando espaço livre do disco..."

dd if=/dev/zero of=/EMPTY bs=1M 2>/dev/null || true
rm -f /EMPTY
sync

echo ""
echo "========================================================"
echo "✅ VM preparada para empacotamento!"
echo ""
echo "Próximo passo (fora da VM, no host):"
echo "  vagrant halt"
echo "  vagrant package --output minha-devbox.box"
echo "========================================================"
