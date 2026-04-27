#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como se conectar à Nuvem (GitHub/GitLab) e transferir ou buscar
# o histórico do seu esqueleto local .git via push/pull/fetch.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Imagine que seu `.git/` local é a agenda de contatos do seu celular.
# Quando você digita "Joãozinho" (Commit), só existe no SEU celular. 
# Para não perder o contato se cair no mar, você espelha a agenda no iCloud (GitHub).
# Adicionar um *Remote* é vincular seu app à conta da Nuvem.
# Fazer um `Push` é APERTAR "Fazer Backup na Nuvem".
# Fazer um `Pull` é APERTAR "Baixar Contatos Novos que a Esposa adicionou".
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# O `remote` não hospeda código em formato legível num FileSystem central; é um daemon bare-repo
# `.git` espelhado que recebe/escreve deltas de packfiles com refs atualizadas por HTTPS ou SSH.
# Um `git fetch` baixa hashes/trees anonimamente de remotes invisíveis localmente para `refs/remotes/origin/main`.
# E o `git pull` é simplesmente o alias composto = `git fetch origin main` SETEADO internamente com `git merge FETCH_HEAD`.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Você tem o seu projeto maravilhoso da linha de comando, e quer empurrar.
# ------------------------------------------------------------

# PASSO 1 - Vinculando a Cordinha na Nuvem:
# Nós damos o apelido de "origin" (poderia ser 'banana' ou 'cloudflare') 
# para o link https://github do nosso repositório que abrimos cru no site deles.
git remote add origin https://github.com/seunome/seu-repo.git

# PASSO 2 - Empurrando as caixas de som no Caminhão
# Você pega a sua branch principal (`main`) e empurra para a "origin".
# A tag `-u` (set-upstream) sela um acordo de união vitalício entre as duas! No futuro pode só bater 'git push'.
git push -u origin main

# PASSO 3 - Baixando as coisas antes de iniciar o dia
# Seu colega trabalhou até as 4 da manhã e upou dele pra origin. E você amanheceu.
# Não trabalhe com o cache obsoleto do seu pc sem bater:
git pull origin main

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git fetch origin
# O que faz: Baixa a história dos seus amigos da internet silenciosamente PARA O SEU PC!
# O que esperar: Você PODE olhar a história deles nas branches "origin/nome" mas 
# ELA NÃO SUJOU NEM TOCOU nos seus arquivos físicos do seu HD ainda!!
# Apenas baixou pro banco invisivel e manteve isolado.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quais naves-mãe este meu projeto local está ancorado?
# Rode: `git remote -v`
# E aparecerá:
# origin  https://github.com/seunome/seu-repo.git (fetch)
# origin  https://github.com/seunome/seu-repo.git (push)
# 
# "GIT PUSH TRAVOU COM ERRO 'REJECTED - FETCH FIRST' "
# A regra mais chata de aprender do Git é que ele proibe você de EMPURRAR algo
# da sua máquina se faltam peças na sua máquina que ESTÃO NA NUVEM!
# O Git te obríga a baixar a dor do trabalho cooperativo primeiro (git pull), aceitar q mexeram num mesmo arquivo no meio da noite (resolvendo os chevron `<<< ==== >>> ` de colisão da aula passada) e só depois te deixa "Subir pro topo!".
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Junior bate `git pull` repetidamente pra tudo e se assusta com a montanha
# de mensagens de Merge Conflict não pedidas pulando no terminal explodindo sua paciencia local..
# O Senior bate `git fetch`, depois abre o log usando a comparação visual das refs baixadas cruzadas (`git log main..origin/main`), espia com calma todos os nomes de arquivos q os amigos comitaram lá e pensa "Isso vai bater na minha feature? Se bater vou salvar minhas pontas com Stash, caso contrário, prossigo liberando o Merge pro working tree agora".
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual é a exata tradução operacional e distinção fundamental que transforma o `git pull` 
# num composto de duas operações unitárias, e qual benefício de desmembrá-las?"
#
# Resposta Esperada: "O `git pull` dispara invariavelmente o `git fetch` associidado instantaneamente em um `git merge` por baixo do chapéu. Ao usar ferramentas visuais ou lidar com bases de conflito, a execução isolada restrita ao `fetch` mantém seu código local (Working Directory) estritamente intocado e livre de fusões imprevistas, nos fornecendo a liberdade de inspecionar os commits origin trackados isoladamente e avaliar as divergências antes de embutir os merges na main limpa."
# ------------------------------------------------------------
