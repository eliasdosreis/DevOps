#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Configuração base de inicialização do cluster.
# Único momento na vida Docker em que pegamos os ips das maquinas do provedor cloud reais.
# ============================================================

echo "Deseja inicializar o modo SWARM na sua máquina? (Ele abrirá portas seguras 2377/TCP nativamente e engajará memoria root extra)."
echo "Basta rodar:"
echo "docker swarm init"
echo ""

# Em cenários hibridos Cloud onde sua EC2 da Amazon tem VÁRIOS ips e placa de rede.
# O Daemon fica burro e não sabe em qual Porta/IP ele vai esgotar os pacotes pros Workers conectarem de fora..
# Devemos forçar mandando o Swarm ditar as ordens NA CARA pro IP privado da sua placa eth0 da aws:
# docker swarm init --advertise-addr 10.150.0.9

# DESLIGAR / ARRANQUE DO PLUG DA PAREDE EM PANICO
# Se voce fudeu o sistema e precisa sair do cluster pra sempre pra zerar.
# docker swarm leave --force
