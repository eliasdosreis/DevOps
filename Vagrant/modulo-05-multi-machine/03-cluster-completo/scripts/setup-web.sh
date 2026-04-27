#!/usr/bin/env bash
set -euo pipefail
APP_IP="${APP_IP:-192.168.56.72}"
SERVER_ID="${SERVER_ID:-web1}"
echo "🌐 Configurando Web Server $SERVER_ID..."
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -y -q nginx
cat > /etc/nginx/sites-available/default << NGINX
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://${APP_IP}:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        add_header X-Served-By "$SERVER_ID";
    }
    location /health { return 200 "OK - $SERVER_ID\n"; add_header Content-Type text/plain; }
}
NGINX
nginx -t && systemctl enable nginx && systemctl restart nginx
echo "✅ Web Server $SERVER_ID configurado! Proxy → $APP_IP:3000"
