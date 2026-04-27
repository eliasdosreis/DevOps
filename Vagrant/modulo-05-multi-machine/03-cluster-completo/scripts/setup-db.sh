#!/usr/bin/env bash
set -euo pipefail
DB_NAME="${DB_NAME:-meuapp}"
DB_USER="${DB_USER:-appuser}"
DB_PASS="${DB_PASS:-senha_segura_123}"
APP_IP="${APP_IP:-192.168.56.72}"

echo "🗄️  Configurando MySQL..."
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -y -q mysql-server
systemctl enable mysql && systemctl start mysql
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

mysql -u root << SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

echo "✅ MySQL configurado! DB: $DB_NAME | User: $DB_USER"
