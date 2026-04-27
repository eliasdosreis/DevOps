#!/usr/bin/env bash
# =============================================================
# SCRIPT: install-plugins.sh
# PROPÓSITO: Instala plugins necessários do Vagrant
# =============================================================

echo "Instalando dependências Vagrant..."

PLUGINS=(
  "vagrant-vbguest"
)

for plugin in "${PLUGINS[@]}"; do
  if ! vagrant plugin list | grep -q "$plugin"; then
    echo "Instalando $plugin..."
    vagrant plugin install "$plugin"
  else
    echo "Plugin $plugin já está instalado."
  fi
done

echo "Sucesso! Pode executar 'vagrant up'."
