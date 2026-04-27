#!/usr/bin/env bash
set -euo pipefail
WEB1_IP="${WEB1_IP:-192.168.56.71}"
echo "⚖️  Configurando Load Balancer..."
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -y -q nginx
if [ -f /home/vagrant/nginx-lb.conf ]; then
  cp /home/vagrant/nginx-lb.conf /etc/nginx/sites-available/default
fi
nginx -t && systemctl enable nginx && systemctl restart nginx
echo "✅ Load Balancer configurado! Upstream: $WEB1_IP"
