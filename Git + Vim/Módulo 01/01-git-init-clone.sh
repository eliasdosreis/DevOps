#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como inicializar o Git no seu projeto e conectar uma pasta 
# local ao seu primeiro rastreio de versão, ou clonar da web.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Imagine que uma pasta do seu computador é apenas uma sala normal.
# Fazer um `git init` é como instalar um sistema de câmeras de 
# segurança e um DVR (banco de dados) nessa sala. Dali em diante,
# cada movimento poderá ser gravado. Fazer um `git clone` é como 
# abrir uma franquia de uma loja: você pega a loja matriz (nuvem) e 
# constrói uma idêntica localmente com todas as mercadorias.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# `git init` cria um repositório vazio alocando a base de dados subdiretório
# .git, além do HEAD padrão apontando para refs/heads/main. 
# `git clone` faz um init local, adiciona o remote origin referenciando o 
# repositório remoto, e puxa os refs, branches e refs track (checkout main). 
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Criaremos uma pasta do zero e a "ligaremos" ao Git.
# ------------------------------------------------------------

# Cria uma pasta comum chamada 'meu-projeto' 
mkdir meu-projeto 

# Entra dentro da pasta recém-criada
cd meu-projeto 

# [A MÁGICA]: Avisamos ao git que queremos versionar essa pasta. 
# Repare a saída disso! Ele dirá: "Initialized empty Git repository..."
git init 

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO (OPÇÃO 2: CLONE)
#
# Comando: git clone https://github.com/torvalds/linux.git 
# O que faz: Baixa todo o repositório público do kernel do Linux e cria
# uma pasta chamada /linux
# O que esperar: Uma barra de progresso cheia de "Receiving objects..." 
# Se der erro: Problemas de permissão de SSH caso a URL fosse ssh:// git@github...
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Como sei se a pasta meu-projeto é um repositório Git?
# 
# git status
#
# Se for repo do git: "On branch main. No commits yet."
# Se NÃO for: "fatal: not a git repository (or any of the parent directories): .git"
#
# COMO DESFAZER (E SE EU ME ARREPENDER DO INIT?)
# cd meu-projeto
# rm -rf .git
# (A pasta voltou a ser uma pasta comum do Windows/Linux).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Junior tem medo de `git init` achando que ele "suja" o sistema de 
# alguma forma que é difícil reverter.
# O Senior sabe que o poder inteiro do Git mora confinado no arquivo oculto `.git/`.
# Não existe registro central global ou "periferia" suja. Por isso dizemos que o Git 
# não depende de servidores ("Distributed"). O repositório real inteiro SÃO esses arquivos do objeto.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se você tem uma pasta no seu computador com 5.000 fotos de família.
# O que acontece com as fotos quando você executa um `git init` dentro dela?"
#
# Resposta Esperada: "Absolutamente nada acontece com os arquivos na *Working Tree*.
# O `git init` simplesmente cria o esqueleto oculto do banco de dados na estrutura 
# `.git/`. Os arquivos reais continuam intocados e 'untracked' (não rastreados) até você
# decidir adicioná-los e comitá-los explicitamente."
# ------------------------------------------------------------
