#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Demonstração das 3 etapas vitais de CI/CD para gerar, assinar
# e mandar sua imagem para o infinito do Hub Central Global.
# ============================================================

echo "Este script apenas lista os comando de exemplo de CI/CD"
echo ""

# -------------------------------------------------------------
# 1. BUILD (ASSAR A MASSA DO BOLO NA FORMA)
# -------------------------------------------------------------
# Ao rodar isso apontando para seu projeto em C ou Node, 
# Ele gerará a tag "meu_app" v1 baseando nas camadas cacheadas.

# docker build -t meu_app:v1 -f 01-Dockerfile-basico .

# -------------------------------------------------------------
# 2. O RENAME PARA PUBLICAÇÃO (A ETIQUETA DOS CORREIOS)
# -------------------------------------------------------------
# O Docker Hub ou ECR(AWS) precisa saber COMO ROTEAR a imagem pra cair
# exatamente na sua pasta "seuLogindeConta". Ele não descobre isso por mágica.
# Para subir nela, o nome da TAG OBRIGATORIAMENTE precisa começar com seu nome de usuario.

# docker tag meu_app:v1 eliassilva/meu_app:v1

# -------------------------------------------------------------
# 3. O LOGIN E O ENVIO
# -------------------------------------------------------------
# Logando via Client no cofre (pedirá senha/token no terminal).
# E executando o fluxo de up-stream bit a bit.
# Nota: Ele faz UPSTREAM SOMENTE das layers que não existem remotamente.
# Se a camada "ubuntu base" que usou na base já existe no servidor do DockerHub,
# seu up-stream fará o skip automático e voce só faz o upload do peso da layer do SEU codigo, em milisegundos!

# docker login
# docker push eliassilva/meu_app:v1
