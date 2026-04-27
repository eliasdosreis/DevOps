#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Comportamento Enterprise de alocação de persistencia 
# totalmente isolada do Host (blindada) via Storage Drivers globais.
# ============================================================

# 1. Criação logica do "Pendrive" pra rodar o Banco de DB
# O Docker que se vira para achar no seu disco rigido Host onde tacar os bytes depois.
docker volume create bd_producao

# 2. RUN E ATACHE DO VOLUME (Usamos o nome puro na Esquerda, ele sabe e entende a magica)
# Subir um Postgres (se nao tiver a image ele puxa). 
# E informamos que a pasta oficial LÁ NO CONTAINER onde ficam os DBs 
# tem que ser jogada direto pra dentro do pendrive virtual que criamos em 1.
docker run -d \
 --name banco_principal \
 -e POSTGRES_PASSWORD=senha_secreta \
 -v bd_producao:/var/lib/postgresql/data \
 postgres:16

# 3. LISTAR
# Verifica que ele tá ativo na lista
docker volume ls

# 4. INSPEÇÃO PROFUNDA PARA SYSADMINS (Onde diabos do meu windows C:// isso ta escrevendo?)
# Esse inspec joga na tela a pasta "MountPoint" exata na arvore do Host onde você
# poderia ir la manualmente ler bit a bit, ou dar um TAR BKP da pasta pra guardar no Google Drive kkk
docker inspect volume bd_producao

# 5. TESTE DA MORTE E RESSURREICAO 
# Mate o banco brutalmente e arranque ele da lixeira.
docker rm -f banco_principal

# 6. VERIFIQUE SE O VOLUME MORREU JUNTO
docker volume ls
# (ELE TA VIVO GRAÇAS A DEUS. Todos os insert de clientes na BD estariam salvos lá).

# 7. RELIGAÇÃO DE DEPLOY
# Puxariamos o comando do Passo 2 e os clientes achariam que foi só um refresh do servidor e seguiria a vida.
