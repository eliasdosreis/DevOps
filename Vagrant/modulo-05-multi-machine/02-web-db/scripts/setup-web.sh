#!/usr/bin/env bash
# =============================================================
# SCRIPT: setup-web.sh
# PROPÓSITO: Configura servidor web Nginx com proxy para o DB
# EXECUTADO: Na VM "web" (192.168.56.60)
# =============================================================

set -euo pipefail

DB_IP="${DB_IP:-192.168.56.61}"
DB_NAME="${DB_NAME:-meuapp}"
DB_USER="${DB_USER:-appuser}"

echo "======================================"
echo "🌐 Configurando servidor WEB..."
echo "======================================"

apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -y -q nginx curl mysql-client

# Cria página que mostra info de conectividade
cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Vagrant Multi-Machine</title>
  <style>
    body { font-family: sans-serif; background: #0f172a; color: #e2e8f0;
           display: flex; align-items: center; justify-content: center;
           min-height: 100vh; margin: 0; }
    .card { background: #1e293b; padding: 40px; border-radius: 16px;
            border: 1px solid #334155; max-width: 600px; width: 100%; }
    h1 { color: #38bdf8; margin: 0 0 24px; }
    .status { display: flex; justify-content: space-between; padding: 12px;
              background: #0f172a; border-radius: 8px; margin: 8px 0; }
    .ok { color: #4ade80; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🖥️ Vagrant Multi-Machine</h1>
    <p>Ambiente Web + DB funcionando!</p>
    <div class="status">
      <span>Web Server (Nginx)</span>
      <span class="ok">✅ 192.168.56.60</span>
    </div>
    <div class="status">
      <span>Database (MySQL)</span>
      <span class="ok">✅ 192.168.56.61</span>
    </div>
    <p style="color:#64748b;margin-top:20px;font-size:0.9em;">
      Módulo 5 — Multi-Machine | Acesse via localhost:8080
    </p>
  </div>
</body>
</html>
HTML

systemctl enable nginx && systemctl restart nginx

# Testa conectividade com o banco (com retry)
echo ""
echo "=== Testando conexão com o banco de dados ==="
MAX_TRIES=10
COUNT=0
until mysql -h "$DB_IP" -u "$DB_USER" -p"${DB_PASS:-senha_segura_123}" "$DB_NAME" -e "SELECT 1;" &>/dev/null; do
  COUNT=$((COUNT + 1))
  if [ "$COUNT" -ge "$MAX_TRIES" ]; then
    echo "⚠️  Não foi possível conectar ao banco após $MAX_TRIES tentativas"
    echo "   Certifique-se que 'vagrant up db' foi executado primeiro"
    break
  fi
  echo "   Aguardando banco de dados... ($COUNT/$MAX_TRIES)"
  sleep 5
done

if mysql -h "$DB_IP" -u "$DB_USER" -p"${DB_PASS:-senha_segura_123}" "$DB_NAME" -e "SELECT 1;" &>/dev/null; then
  echo "✅ Conexão com MySQL estabelecida!"
fi

echo ""
echo "======================================"
echo "✅ Servidor WEB configurado!"
echo "   Acesse: http://localhost:8080"
echo "======================================"
