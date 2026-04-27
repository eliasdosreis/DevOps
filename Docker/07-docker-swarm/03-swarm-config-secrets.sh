#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Apaga de vez a necessidade de lidar com `.env` em hard-disk, e nos ensina 
# a blindagem suprema do cofre em memória do Master do Swarm.
# ============================================================

# Imagine que a senha do BD de prod nunca deve ser lida no Linux host 
# de ninguem em plaintext em pastas e repositorios .env soltos pelo HD.

# 1. Envie a senha cifrada pura direto da stdOut para o Cofre criptografado com Raft log do Nodo MANAGER 
echo "minha_senha_absurda_1234!!!" | docker secret create bd_senha -

# Veja as chaves na base. Não verá o conteudo, a chave esta selada numa base encriptada mTLS.
docker secret ls

# 2. ATACHANDO NO CONTAINER EM PRODUÇÃO MAGICAMENTE LÁ DISTANTE
# O Swarm Master transfere a cifra oculta na veia pra Maquina Worker XPTO de destino..
# E a memoria TMPFS da maquina XPTO vira um arquivo fisico TEMPORARIO montado exclusivamente na RAM
# no path `/run/secrets/bd_senha` la dentro dp container Node Alpine e vira pó qndo morre.
docker service create --name banco \
  --secret bd_senha \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/bd_senha \
  postgres:16

# Limpeza
# docker service rm banco
# (O secret em si voce não deleta.. ele mora forever guardado blindado no node leader para futuros re-boots)
