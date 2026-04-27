#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como verificar a história passada (`log`), entender quem
# fez o que, e visualizar o que o Git rastreou palavra por
# palavra e linha por linha nas modificações (`diff`).
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Se o Commit é o carimbo no Detran do caminhão, o `git log` é puxar
# o relatório da Polícia Rodoviária listando cronologicamente todos
# os caminhões que passaram na cidade nas últimas duas décadas.
# E o `git diff` atua como os detetives microscópicos apontando
# que o contrato original dizia "pão de forma", mas o contrato 
# novo foi modificado para "pão australiano" e grifando a linha.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# O `log` percorre os ponteiros PAI a partir do commit atual apontado por
# `HEAD`. O `diff` não compara arquivos passivamente, mas sim objetos "tree" 
# e "blobs" do grafo de dados do Git para computar inserções (+) e remoções (-)
# com sintaxe em blocos baseados em contexto.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# O ambiente pode estar no terminal sem pastas específicas
# ------------------------------------------------------------

# Veja todos os últimos saves do histórico, mais recentes no topo.
# Irá listar o SHA-1 longo, o Author, a Date e a mensagem:
git log

# Usa aquele alias ninja que instalamos no Módulo 00? Lembra dele?
# Log condensado numa linha, com cores indicando as ramificações de branches:
git ll 

# Eu adicionei no arquivo ".txt" a palavra "Ola", mas ainda não joguei no Stage (baú).
# Como eu vejo o texto que fisicamente deletei ou adicionei antes de preparar o commit?
git diff

# "E para ver o que já está jogado dentro do Baú e pronto pra viajar, contra meu ultimo commit?"
git diff --staged

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git show <hash_do_commit>    (ex: `git show e4fb2c1`)
# O que faz: Extrai todos os detalhes sobre como o mundo era naquele instante.
# Mostra ao mesmo tempo a mensagem, O DIFERENCIAL (patch das linhas mudadas) 
# daquele commit específico de 1 ano atrás que introduziu um código bugado.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# "Mano, entrei no log ou bati 'git diff' e sumiu meu prompt de cmd! Travei na tela preta!"
# O Git joga listagens longas dentro de programas chamados paginadores ("less").
# 
# Pressionar ESPAÇO: desce uma página inteira.
# Pressionar Seta p/ Cima e Baixo: navega linha a linha.
# PRESSIONAR LETRA "q" (de "quit"): SAI do paginador e te joga livre no terminal.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Ferramentas como VSCode possuem GUI que desenha em verde ou vermelho belamente
# as linhas alteradas lado-a-lado no projeto.
# Um Engenheiro Senior aprende `git diff` nativo de raiz por um motivo forte:
# Em auditoria ou dentro de servidores hospedados na AWS via SSH, você raramente 
# tem VSCode conectado remotamente. Seu principal aliado para caçar "Por que isso 
# subiu às três da manhã e quebrou minha home page" é debugar lendo os `--staged` diffs
# diretos no terminal via interface ANSI colorida.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Seu log tem 100 mil commits na base de dados de um aplicativo enorme
# e você deve resgatar os commits do projeto na qual o programador Fulano (fulano@x.com) 
# modificou arquivos apenas entre as datas 01 de Jan e 15 de Jan e cujo commit envolva 
# a palavra 'senha'. Como faria por linha de comando?"
#
# Resposta Esperada: "Podemos encadear sinalizadores (flags) avançados de `log`.
# A query final seria: 
# `git log --author="fulano@x.com" --since="2023-01-01" --until="2023-01-15" --grep="senha"`
# E para facilitar a visão visual, anexaria o comando nativo `--oneline`."
# ------------------------------------------------------------
