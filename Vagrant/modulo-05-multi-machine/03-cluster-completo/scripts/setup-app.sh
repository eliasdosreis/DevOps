#!/usr/bin/env bash
set -euo pipefail
DB_IP="${DB_IP:-192.168.56.73}"
DB_NAME="${DB_NAME:-meuapp}"
DB_USER="${DB_USER:-appuser}"
DB_PASS="${DB_PASS:-senha_segura_123}"

echo "⚙️  Configurando App Server (Node.js)..."
apt-get update -q
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y -q nodejs

# Cria app Node.js simples
mkdir -p /opt/app
cat > /opt/app/server.js << 'JS'
const http = require('http');
const os   = require('os');
const server = http.createServer((req, res) => {
  const data = {
    message:  'App Server funcionando!',
    hostname: os.hostname(),
    pid:      process.pid,
    uptime:   Math.floor(process.uptime()) + 's'
  };
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data, null, 2));
});
server.listen(3000, '0.0.0.0', () => {
  console.log('App rodando na porta 3000');
});
JS

# Cria serviço systemd para o app
cat > /etc/systemd/system/nodeapp.service << UNIT
[Unit]
Description=Node.js App Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node /opt/app/server.js
Restart=always
RestartSec=5
Environment=NODE_ENV=development
Environment=DB_HOST=${DB_IP}
Environment=DB_NAME=${DB_NAME}

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable nodeapp
systemctl start nodeapp

echo "✅ App Server configurado! Porta 3000"
