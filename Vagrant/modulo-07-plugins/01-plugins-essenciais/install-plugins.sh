#!/usr/bin/env bash
# =============================================================
# SCRIPT: install-plugins.sh
# PROPÓSITO: Instala todos os plugins Vagrant necessários
# EXECUTADO: No host, ANTES de vagrant up
# USO: bash install-plugins.sh
# =============================================================

echo "========================================"
echo "Instalando plugins Vagrant necessários"
echo "========================================"

PLUGINS=(
  "vagrant-vbguest"        # Sincroniza VirtualBox Guest Additions
  "vagrant-hostsupdater"   # Gerencia /etc/hosts automaticamente
  "vagrant-disksize"       # Permite redimensionar disco da VM
  "vagrant-env"            # Carrega variáveis de arquivo .env
)

for plugin in "${PLUGINS[@]}"; do
  if vagrant plugin list | grep -q "^${plugin}"; then
    echo "✅ $plugin já instalado: $(vagrant plugin list | grep "^${plugin}" | awk '{print $2}')"
  else
    echo "📦 Instalando $plugin..."
    vagrant plugin install "$plugin"
    echo "✅ $plugin instalado!"
  fi
done

echo ""
echo "========================================="
echo "✅ Todos os plugins instalados!"
echo ""
echo "Versões instaladas:"
vagrant plugin list
echo "========================================="
