#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Libera o acesso para o mundo real entrar na redoma de vidro
# e falar com o NGINX, batendo na placa de rede do seu PC.
# ============================================================

# PORTAS: <DO_SEU_PC_LOCAL>:<DO_CONTAINER>
#
# Se não usar -p, o Nginx nasce, roda na porta 80 lá no namespace dele e nada
# entra nem sai da sua placa wlan/eth0.
# Neste exemplo: Toda request HTTP no 'localhost:8080' do seu navegador do Windows
# Sera engolida pelo Kernel, mapeada num NAT de pacote e injetada na 80 do namespace dele.

docker run -d --name meulocal -p 8080:80 nginx

echo "Abra no seu navegador de internet do computador físico o endereço http://localhost:8080"
