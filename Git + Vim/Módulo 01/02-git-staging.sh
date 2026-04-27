#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# A "Área de Preparação" (Staging / Index), o coração de
# como o Git decide o que exatamente será salvo.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Imagine que você está montando móveis novos para um caminhão de mudança.
# Os móveis espalhados na calçada (Working Directory).
# O baú de papelão onde você arruma as coisas (Staging Area).
# O Caminhão trancado pronto pra viajar para outra cidade (Commit).
# O `git add` pega as cadeiras soltas e põe dentro do baú, mas o
# caminhão não andou ainda (não salvamos). Você pode até tirar algo 
# de volta do baú se achar que não cabe!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# A *Staging Area* (também chamada de *Index*) é a área intermediária do Git.
# Ela prepara o próximo snapshot (fotografia de estado). Adicionar arquivos com
# `git add` apenas armazena objetos do tipo *Blob* na árvore binária do Git listados 
# no índice `index`, mas não gera o commit (o objeto final imutável).  
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Simulação na sua pasta recém iniciada (`meu-projeto/`)
# ------------------------------------------------------------

# 1. Eu crio um arquivo local vazio (estado: Untracked)
touch aula02.txt 

# 2. O Git dirá: "Tem esse arquivo aí mas eu não ligo pra ele."
git status 

# 3. MOVE PARA O BAÚ (Staging area). Isso não é salvar! É APENAS enfileirar.
git add aula02.txt

# 4. O Git dirá em letras verdes: "Changes to be committed: new file: aula02.txt"
git status

# 5. Ops! Coloquei no baú por engano. Quero TIRAR do baú (unstage).
git restore --staged aula02.txt

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git add .    (ponto final significa "tudo")
# O que faz: Adiciona TODOS os arquivos novos e arquivos modificados no stage.
# Cuidado: É adorado pelos Juniors, mas perigoso, porque pode enviar
# arquivos sensíveis, senhas e logs temporários (.env, .log) se não 
# filtrarmos pelo arquivo `.gitignore`.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Corremos `git status` o TEMPO TODO.
#   ✅ Tinta verde: "Changes to be committed" => Estão no Stage (Prontos no baú).
#   ❌ Tinta vermelha: "Untracked" ou "Changes not staged" => Estão na calçada.
# 
# Você deve sempre olhar a seção recomendada de remoção que o próprio `git status` te dá.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Por que o Git tem esse passo incômodo no meio, ao invés de só commitar tudo?
# Porque o Sênior altera dezenas de arquivos enquanto resolve um bug.
# Três arquivos consertaram a interface CSS, e dois arquivos corrigiram o banco de dados.
# Se o Sênior commitar tudo junto, o histórico vira lixo misto.
# A Staging area permite "empacotar" metodicamente: pega só os CSS -> commita;
# pega só os de banco de dados -> commita. Você controla em granulometria *o quê* 
# compõe *cada* bloco lógico de alteração. Múltiplos saves com sentido claro.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se você alterar a linha 10 e a linha 50 do mesmo arquivo extenso,
# você é capaz de comitar a linha 10 sem comitar a alteração da linha 50?"
#
# Resposta Esperada: "Sim, isso é um dos super-poderes do Git. Nós usamos `git add -p`
# (Add Patch). Ele vai dividir o arquivo modificado em partes (hunks) e perguntar
# interativamente no terminal 'Adicionar essa parte no stage? [y/n]'. 
# Assim colocamos só o fragmento da linha 10 no Staging, sem precisar desfazer o que
# digitamos na linha 50 fisicamente do nosso editor."
# ------------------------------------------------------------
