#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Como rodar algo sabendo o peso maximo que ele causará e provando 
# e abrindo o Dashboard Visual embutido para monitorar memória.
# ============================================================

# 1. RUN COM CADEADO ESTRITO
# -m 256m : Limite de 256 Megabytes exatos no Isolamento de Cgroup do Linux RAM. Se bater 258M ali no pico, vira pó pelo Kernel Kill e morre.
# --cpus 1.5: Ele pode fritar livremente. Chegando em 1 cpu e MÊIA da máquina.. ele toma Time-Sleep-Slices pelo kernel e sua maquina hospedeira salva folego pra ela nao travar.
docker run -d \
  --name app_gula \
  -m 256m \
  --cpus 1.0 \
  nginx

# 2. ABRE O DASHBOARD
# Ele assumirá sua tela no terminal e ficara piscando o status e banda alocada a cada segundo.
docker stats
# Para sair aperte CTRL+C.

# Limpeza
# docker rm -f app_gula
