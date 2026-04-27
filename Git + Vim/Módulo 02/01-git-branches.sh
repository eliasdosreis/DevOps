#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como criar universos paralelos (Branches), trocar entre eles
# e deletar linhas do tempo antigas no Git.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Imagine que você está lendo um livro estilo "Escolha Sua Aventura".
# Você chegou na página onde deve decidir: Salvar a Princesa ou 
# Derrotar o Dragão. Em vez de avançar e "estragar o seu livro",
# você faz uma CÓPIA idêntica do livro.
# Em um livro, o caminho é Princesa.
# No outro livro, o caminho é Dragão.
# Uma Branch não duplica os arquivos físicos antigos. Ela é apenas
# um "adesivo post-it" pregado numa determinada página da sua história.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# Uma Branch no Git representa uma linha independente de desenvolvimento.
# Mecanicamente, é apenas um arquivo `ref` de 41 bytes escondido em `refs/heads/` 
# que contém os 40 caracteres do hash SHA-1 de um commit para o qual ela aponta, 
# e uma quebra de linha. Criar branches é absurdamente barato `O(1)`, diferente de SVN 
# que copia fisicamente diretórios inteiros.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Na nossa pasta do `meu-projeto/`:
# ------------------------------------------------------------

# Vamos criar um "mundo paralelo" chamado 'feature-login' a partir de onde estamos.
git branch feature-login

# Só criar não nos move para ele. O HEAD (nossa visão agora) ainda tá na 'main'.
# Então cruzamos a ponte interdimensional para dentro da nossa nova branch recém montada:
git switch feature-login       # (Em Git mais antigo você vedia: git checkout feature-login)

# O.K. O terminal costuma mudar e indicar: `(feature-login)`. E o que nós fizermos
# com 'git add' ou 'git commit' a partir DE AGORA trilhará na estrada amarela "feature-login",
# deixando nossa 'main' original intocável no espelho retrovisor.

# Legal, fizemos o código, fomos demitidos, e o projeto faliu. Não queremos mais essa feature.
# Voltamos primeiro para a realidade da main. Não dá pra explodir a ponte que estamos pisando.
git switch main 

# E deletamos esse nome/etiqueta.
git branch -d feature-login

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git checkout -b nome-sua-branch 
#                OU o comando novo: 
#          git switch -c nome-sua-branch
#
# O que faz: Junta 2 passos num só: Cria a branch e JÁ PULA para dentro dela instantaneamente.
# O que esperar: "Switched to a new branch 'nome-sua-branch'".
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Corremos `git branch` (sem passar parêmetro). Ele lista todas as criadas.
# A branch que tem um asterisco estelar do lado ( * main ) indica onde ONDE NOSSO OLHO 
# `HEAD` se encontra atracado hoje.
# 
# ERRO CLÁSSICO: "error: The branch 'feature-log' is not fully merged." 
# Você editou coisas lá, e o banco sabe que deletar isso usando `-d ` fará o código
# ser órfão de qualquer ramificação (vc vai perder a alteração para sempre). 
# Git é esperto e segura sua mão, bloqueando sua bomba nuclear. 
# Se tem certeza absoluta de que aquele código era inútil, o Git manda vc forçar: `-D` (maiúsculo).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Junior acredita que branches existem por uma questão geográfica. Ele não cria. 
# Codifica direto na `main`. Se quebrar a main, a produção de todo mundo chora e sangra.
# O Senior sabe que branches não são pastas; são a essência das transações no ecossistema
# para a CI/CD, deploys seguros e para habilitar "Isolamento assíncrono entre devs". 
# Branching strategy (ex: GitFlow, Trunk-Based) é 40% de engenharia de software Senior 
# em times maiores de 20 pessoas alinhando as pontes paralelas diariamente de volta a `main`.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou na branch main e crio uma gigantesca branch chamada 'feature-1',
# e rodo 'git branch feature-2'. Isso duplicará fisicamente 200 mil linhas de código 
# pesando meus bits em duas vezes no HDD?"
#
# Resposta Esperada: "Não. As branches do git são infinitamente leves e não 
# existem como cópias de trabalho separadas. Criar uma branch `feature` custa meros
# poucos bytes como um ponteiro de texto alocado em `refs/`. Essa é a maravilha
# da arquitetura de hash trees DAG subjacente construída por Linus Torvalds."
# ------------------------------------------------------------
