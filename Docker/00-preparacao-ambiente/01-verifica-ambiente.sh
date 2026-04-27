#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Realiza um rito de passagem: a primeira interação com o Docker engine.
# Validaremos a instalação checando se o CLI(Client) existe e 
# em seguida confirmaremos a comunicação com o Daemon(Server).
# ============================================================

echo "========================================="
echo "1. VERIFICANDO A VERSÃO DO CLIENT (CLI)"
echo "========================================="

# O comando abaixo apenas varre o binário local do client.
# Se funcionar, significa que a instalação do pacote base está OK
# ou que o Docker Desktop injetou corretamente a ferramenta "docker" no PATH.
docker --version

echo ""
echo "========================================="
echo "2. TESTANDO A COMUNICAÇÃO COM O DAEMON"
echo "========================================="

# O "info" é poderoso. Ele força o Client a enviar uma requisição GET 
# via sockets/named-pipes para a API do Daemon.
# Se houver uma saída enorme aqui contendo arquitetura de disco (aufs/overlay2), 
# uso de CPU e afins, significa que o SERVIDOR está online e te respondendo."
#
# DICA SENIOR: Se esse comando falhar ou travar eternamente, todo o restante
# dos seus comandos como 'run', 'ps', 'pull' VÃO falhar. Pare aqui e resolva.
docker info

echo ""
echo "========================================="
echo "Se você viu o bloco 'Server:' acima, seu ambiente está 100% pronto."
echo "========================================="
