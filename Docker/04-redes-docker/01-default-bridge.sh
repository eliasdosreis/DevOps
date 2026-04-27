#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Prova a limitação da Rede Default e o quão engessado
# é rodar na infra padrao legada ("bridge" de fabrica).
# ============================================================

# 1. Starta container Servidor
docker run -d --name servidor nginx

# 2. Starta container Cliente (que roda so um ping)
# Note que mesmo referenciando a tag "--name servidor" do nginx que criamos la..
# Este container do alpine vai falhar miseravelmente em resolver quem diabos é "servidor"
docker run --rm alpine ping -c 2 servidor

# E se usarmos o IP daquele Servidor? Aí funciona! (mas IPs mudam)
# Descobrir IP na unha: docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' servidor
# docker run --rm alpine ping -c 2 172.17.0.2

# Limpeza
# docker rm -f servidor
