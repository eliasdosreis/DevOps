#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# O conceito mais importante: Como consolidar suas alterações 
# no histórico imutável (commits) e pequenas correções com amend.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Se o `git add` é empacotar o caminhão, o `git commit` é preencher
# o Conhecimento de Transporte (documento formal de viagem), fechar o cadeado,
# carimbar com horário e registrar no Detran quem dirigiu. Acabou. O que foi no
# caminhão, foi. As informações na guia dizem "O que tem dentro daqui".
# A única forma de mudar algo se escreveste errado uma palavra é usar "emenda"
# (Amend - rasgar aquele papel recém impresso e assinar de novo antes que 
#   ele suba de vez do seu computador).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# Um commit no Git é um objeto criptográfico rastreável atrelado a 
# um hash SHA-1 calculando pais, conteúdos das árvores, autoria, carimbos de tempo e 
# uma mensagem. Ele não "salva as diferenças de texto". O Git tira uma fotografia 
# exata / completa ("snapshot") de como seus arquivos estavam naquele milisegundo exato.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Após ter feito um git add na aula anterior, comitaremos!
# ------------------------------------------------------------

# Você tinha itens no stage (letras verdes do "git status").
# Gravamos eles na história para todo sempre.
# Flag -m permite informar a mensagem do commit diretamente ali mesmo.
git commit -m "feat: adiciona o arquivo da aula 2 sobre staging"

# E se fiz o commit e vi UM SEGUNDO depois que esqueci do 'Ponto e Vírgula' 
# no arquivo html? Não devemos criar um commit só dizendo "arruma o erro besta"
# 1. Corrija o ; no editor de texto.
# 2. Salve, jogue no baú: `git add arquivo.html`
# 3. Funda as alterações do baú no último commit sem alterar o nome:
git commit --amend --no-edit  # "--no-edit" reaproveita a mensagem já digitada.

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git commit 
# O que faz: Se não usarmos o `-m`, ele abrirá o SEU editor de texto (core.editor, Lembra do Vim q setamos?).
# Você escreve longamente os detalhes (Título + Corpo). Salva o Vim (ZZ ou :wq), e magicamente
# o terminal detecta o save e comita.
# O que esperar: Uma saída `[main 1b2c3d4] Titulo do commit` onde 1b2c3d4 é o SHA-1 abreviado.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# 
# "Oops, digitei a mensagem do commit errada"
# Basta rodar `git commit --amend` (sem --no-edit). Seu editor do Vim vai abrir com a
# mensagem errada lá. Altere-a, salve o arquivo e o commit estará trocado!
# 
# Atenção: "Author identity unknown" significa que você pulou o arquivo 01-git-config.sh e o git
# não sabe seu nome! Configure-o.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe um padrão de mercado chamado "Conventional Commits".
# Um sênior não digita `git commit -m "fiz os trem lá"`. Ele escreve de  forma que máquinas consigam
# extrair changelogs automáticos das versões semanticamente.
# Prefixos Clássicos:
# "feat: ..."  - Adiciona nova funcionalidade
# "fix: ..."   - Corrige banco/css
# "docs: ..."  - Mudança nos readmes
# "refactor: ..." - Mexe num código pra melhorar sem quebrar nada.
# "chore: ..." - Atualizações de dependências e pacotes.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual é o perigo oculto e absoluto de usar constantemente o `git commit --amend` 
# numa branch em que outras pessoas também trabalham diariamente (commits compartilhados)?"
#
# Resposta Esperada: "O Git é imutável. Alterar (amend) um commit que JÁ FOI enviado ao 
# repósitório remoto (empurrado / pushed) não 'substitui' só a mensagem. Ele gera 
# matematicamente um Hash SHA-1 inteiramente NOVO no banco de dados, destruindo o antigo.
# Se nosso colega já puxou o antigo para o computador dele, causaremos uma profunda árvore 
# divergente entre os colegas. Regra de Ouro Sênior: Apenas façamos `amend` em commits 
# estritamente locais (que só vivem na nossa máquina ainda)."
# ------------------------------------------------------------
