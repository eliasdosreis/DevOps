#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como configurar sua identidade e editor padrão no Git, sendo
# o passo zero antes de tocar em qualquer código.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Pense no Git como a recepção de um prédio corporativo rigoroso.
# Você não pode entrar sem se identificar (Nome e Email). Quando
# você faz uma alteração (um commit), seu crachá fica gravado nela
# para que todos saibam quem fez aquilo.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# `git config` é a interface de linha de comando para alterar as
# opções que controlam como o Git se comporta e sua aparência. 
# Variáveis de identidade são injetadas nativamente no metadado do
# objeto de commit gerado pelo Git.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Execute estas linhas no seu terminal para configurar seu ambiente.
# ------------------------------------------------------------

# Define seu nome completo (crachá visível) na configuração global
git config --global user.name "Seu Nome Completo"

# Define seu email (usado para vincular a conta do GitHub/GitLab)
git config --global user.email "seu_email@trabalho_ou_pessoal.com"

# Define o editor de texto padrão do Git (Crucial para este curso)
# Troca do padrão (geralmente nano ou vi) pelo Vim (ou de preferência Neovim - nvim)
git config --global core.editor "vim"

# (Opcional recomendado) Define a branch inicial padrão como "main" em vez de "master"
git config --global init.defaultBranch main

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git config --global user.name "João Silva"
# O que faz: Grava "João Silva" no arquivo ~/.gitconfig
# O que esperar: Nenhuma saída no terminal se der certo.
# Se der erro: Pode ser permissão (raro) ou digitação (ex: esqueceu as aspas).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Para verificar se tudo foi configurado corretamente, liste as opções:
#
# git config --list
#
# Você deve ver suas chaves listadas. Se tiver configurações repetidas,
# a mais específica (local > global > system) vence.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Git tem 3 níveis principais de configuração:
# --system: Afeta toda a máquina, todos os usuários (raramente mexemos).
# --global: Afeta apenas VOCÊ, o usuário atual logado, em ~ (seu /home).
# --local: Afeta APENAS o repositório em que você está (.git/config).
#
# Um Junior costuma setar --global com seu email corporativo e vai para 
# casa fazer um projeto open-source: acaba vazando o email da empresa no 
# commit público. 
# O Sênior sabe que no projeto "da empresa" ele usa --local, ou tem uma 
# estrutura de "IncludeIf" no seu ~/.gitconfig para separar personas.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "João, estou em um projeto Open Source local, mas o meu
# Git está globalmente configurado com meu email da empresa XPTO.
# Como faço um commit usando meu email pessoal, mas SÓ neste projeto?"
#
# Resposta Esperada: "Basta navegar até a pasta do projeto e bater o comando:
# `git config --local user.email meupessoal@email.com`.
# Isso vai escrever a chave user.email apenas no arquivo `.git/config` 
# do projeto, e as configs do `--local` sempre têm precedência (sobrescrevem) 
# o que estiver no `--global`."
# ------------------------------------------------------------
