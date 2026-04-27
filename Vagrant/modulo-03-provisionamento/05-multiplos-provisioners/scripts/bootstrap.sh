#!/usr/bin/env bash
# =============================================================
# SCRIPT: bootstrap.sh
# PROPÓSITO: Bootstrap completo do sistema
# EXECUTADO: Como root, na criação da VM
# IDEMPOTENTE: Sim
# =============================================================

set -euo pipefail

echo "======================================"
echo "🚀 Bootstrap iniciado: $(date)"
echo "======================================"

# Atualizar sistema
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q

# Instalar pacotes essenciais
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  nginx curl wget git vim htop tree net-tools unzip jq

# Habilitar serviços
systemctl enable nginx && systemctl start nginx

# Mover arquivo de config copiado pelo file provisioner
if [ -f /home/vagrant/app.conf ]; then
  cp /home/vagrant/app.conf /etc/nginx/sites-available/default
  nginx -t && systemctl reload nginx
  echo "✅ Configuração do Nginx aplicada"
fi

# Configurações de sistema
timedatectl set-timezone America/Sao_Paulo

echo "======================================"
echo "✅ Bootstrap concluído: $(date)"
echo "======================================"
