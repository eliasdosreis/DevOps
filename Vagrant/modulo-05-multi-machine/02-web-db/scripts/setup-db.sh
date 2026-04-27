#!/usr/bin/env bash
# =============================================================
# SCRIPT: setup-db.sh
# PROPÓSITO: Instala e configura MySQL Server
# EXECUTADO: Na VM "db" (192.168.56.61)
# =============================================================

set -euo pipefail

DB_NAME="${DB_NAME:-meuapp}"
DB_USER="${DB_USER:-appuser}"
DB_PASS="${DB_PASS:-senha_segura_123}"
WEB_IP="${WEB_IP:-192.168.56.60}"

echo "======================================"
echo "🗄️  Configurando servidor de BANCO DE DADOS..."
echo "======================================"

apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -y -q mysql-server

# Inicia e habilita MySQL
systemctl enable mysql
systemctl start mysql

# Configura MySQL para aceitar conexões externas (da VM web)
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

# Cria banco e usuário
mysql -u root << SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'${WEB_IP}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${WEB_IP}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

echo ""
echo "======================================"
echo "✅ MySQL configurado!"
echo "   Banco:   $DB_NAME"
echo "   Usuário: $DB_USER"
echo "   Acesso:  $WEB_IP"
echo "======================================"
