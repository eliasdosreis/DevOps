#!/usr/bin/env bash
# =============================================================
# SCRIPT: configure.sh
# PROPÓSITO: Configura os serviços após a instalação
# EXECUTADO: Como root, após o install.sh
# IDEMPOTENTE: Sim
# PRÉ-REQUISITO: install.sh deve ter sido executado antes
# =============================================================

set -euo pipefail

echo "=============================="
echo "⚙️  FASE 1: Configurando Nginx"
echo "=============================="

# Cria página HTML personalizada
# O heredoc permite escrever HTML diretamente no script
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Vagrant - Shell Script Provisioner</title>
  <style>
    body { font-family: sans-serif; background: #1a1a2e; color: #e0e0e0; 
           display: flex; justify-content: center; align-items: center; 
           min-height: 100vh; margin: 0; }
    .card { background: #16213e; padding: 40px; border-radius: 12px; 
            border: 1px solid #0f3460; max-width: 500px; text-align: center; }
    h1 { color: #e94560; }
    .badge { background: #0f3460; padding: 8px 16px; border-radius: 20px; 
             display: inline-block; margin: 8px; font-size: 0.9em; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 Vagrant + Shell Script</h1>
    <p>Provisionamento via scripts externos funcionando!</p>
    <div class="badge">Nginx ✅</div>
    <div class="badge">Node.js ✅</div>
    <div class="badge">Módulo 3</div>
  </div>
</body>
</html>
HTML

echo "✅ Nginx configurado com página personalizada"

# =============================================================
# CONFIGURAÇÕES DO SISTEMA
# =============================================================
echo ""
echo "=============================="
echo "⚙️  FASE 2: Configurações do sistema"
echo "=============================="

# Cria usuário de deploy (idempotente)
if ! id "deploy" &>/dev/null; then
  useradd -m -s /bin/bash deploy
  echo "✅ Usuário 'deploy' criado"
else
  echo "ℹ️  Usuário 'deploy' já existe"
fi

# Cria estrutura de diretórios da aplicação
mkdir -p /opt/app/{releases,shared,logs}
chown -R vagrant:vagrant /opt/app

echo "✅ Estrutura de diretórios criada em /opt/app"

# =============================================================
# SUMÁRIO FINAL
# =============================================================
echo ""
echo "============================================"
echo "✅ PROVISIONAMENTO CONCLUÍDO COM SUCESSO!"
echo "============================================"
echo "Nginx:   $(systemctl is-active nginx)"
echo "Node.js: $(node --version 2>/dev/null || echo 'não instalado')"
echo "URL:     http://192.168.56.31"
echo "============================================"
