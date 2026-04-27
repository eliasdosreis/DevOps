#!/usr/bin/env bash
# =============================================================
# SCRIPT: install.sh
# PROPÓSITO: Instala todas as dependências da VM
# EXECUTADO: Como root, uma vez na criação da VM
# IDEMPOTENTE: Sim (usa flags que não falham se já instalado)
# =============================================================

# Sai imediatamente se qualquer comando falhar
set -euo pipefail

# Habilita saída detalhada para debug (comentar em produção)
# set -x

echo "=============================="
echo "📦 FASE 1: Instalação de pacotes"
echo "=============================="

# Atualiza repositórios
apt-get update -q

# Instala pacotes de forma não-interativa e silenciosa
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  nginx \
  curl \
  wget \
  git \
  htop \
  tree \
  vim \
  net-tools \
  unzip

echo "✅ Pacotes instalados com sucesso!"

# =============================================================
# INSTALAÇÃO DO NODE.JS (via NodeSource)
# =============================================================
echo ""
echo "=============================="
echo "📦 FASE 2: Instalando Node.js"
echo "=============================="

# Verifica se Node.js já está instalado (idempotência)
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
  echo "✅ Node.js $(node --version) instalado!"
else
  echo "ℹ️  Node.js já instalado: $(node --version)"
fi

# =============================================================
# HABILITAÇÃO DOS SERVIÇOS
# =============================================================
echo ""
echo "=============================="
echo "🚀 FASE 3: Habilitando serviços"
echo "=============================="

systemctl enable nginx
systemctl start nginx || systemctl restart nginx

echo "✅ Script install.sh concluído!"
