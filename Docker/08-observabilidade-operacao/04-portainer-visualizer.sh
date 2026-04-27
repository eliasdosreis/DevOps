#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# A ferramenta da Interface Gráfica padrão da indústria: Portainer.
# Ideal para quem quer clicar e ver logs na web bonitinho ou debugar visualmente 
# os resources metrics inves do CLI.
# ============================================================

# 1. Ele precisa do proprio volume dele pq ele tem um bd embutido de regras
docker volume create portainer_data

# 2. Start (Modo Community Edition)
# Veja o truque absurdo do bind mount q vamos fazer:
# Ele É um container na bolha izolada. Como ele consegue listar Containers 
# e redes do nosso Host CLI e até deleta-los?!
# Nós injetamos o SOCKET do daemon (`/var/run/docker.sock`) da maquina Host DE MÃO BEIJADA 
# na veia dele como root. Ele tem poder de Deus sobre nosso Host.
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

echo "O Portainer está rodando."
echo "Abra no navegador em HTTPS (Ignore the warning certificate):"
echo "https://localhost:9443"

# DICA SÊNIOR: Por plugar diretamente no Kernel socket do Host, expondo-o publicamente pra web
# Sem WAF (Web Application Firewall) na frente, é considerado falha fatal de seguranca Zero-Trust. 
# Deixe apenas pra redes internas (VPN/Localhost).
