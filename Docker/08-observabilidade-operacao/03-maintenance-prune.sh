#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Pratica Padrão Ouro de faxina. Pode ser colocado no crontab de domingo.
# O Servidor de ci/cd que buila toda dia a versao V2.. v3.. e descarta as base 
# gera GIGA bytes de tralha em overlay2 na raiz.
# ============================================================

echo "Listando imagens dangling"
docker images -f "dangling=true"

# Apaga tudo que esta "desligado ou caido ou falhou" porem preserva as chaves do banco de dados vivas!
# O flag -f (force) diz que não vai pedir [Y/N] na telinha do bash do Jenkins na marte cega pra não travar processo CI.
docker system prune -f 

# Se houver CERTEZA que os logs dos containers não foram enviados pra um Datadog etc.. e 
# não importam mais... pode tambem invocar a bomba nuclear de limpar lixo de dados do HD de volume tbm (Risco Absurdo):
# docker system prune -a --volumes -f
