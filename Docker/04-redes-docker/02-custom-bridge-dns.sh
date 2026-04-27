#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Mágica pura. Você cria um Switch Virual seu e cadastra 
# os seus containers lá. O CoreDNS entra em ação instantâneo!
# ============================================================

# 1. Cria a rede
docker network create minha_rede_empresa

# 2. Starta servidor dizendo qual a Flag de rede e NOME
docker run -d --name db_empresa --network minha_rede_empresa postgres:16

# 3. Mágica do DNS resolvendo o Hostname!
# O alpine agora ta na MSMA rede, e vai pingar a variavel NOME dele e nao o IP hardcoded!
# (Ele resolverá automato e voce vera o Output disparando Ping pro IP nativo interno)
docker run --rm --network minha_rede_empresa alpine ping -c 3 db_empresa

# Limpeza
# docker rm -f db_empresa
# docker network rm minha_rede_empresa
