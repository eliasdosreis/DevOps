#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# A prova Definitiva de que VOCÊ NUNCA PERDE NADA NO GIT MESMO 
# SE DELETANDO ARQUIVOS, DELETANDO BRANCHES ou Destruindo o Computador!
# A Rede se chama REFLOG (Reference Logs).
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Você perdeu o cachorro do menino no shopping de multidão. Todos correm e ngm acha.
# Você procura no "Histórico Normal" (Git Log) Onde Fica "Fotos que a familia guarda da vida delas", mas o menino deletoiu as fotos!
# Mas o Reflog é A CAMERA DE SEGURANÇA 360 do TETO OCULTO DO SHOPPING! (Central da CIA).
# Não importa se a Filial tentou queimar documentos, a CAMERA DAS CABEÇAS GRAVOU SEUS PASSOS.
# Cada vez q vc Move a Perna no git (Cada Checkout, cada deleção) o RefLog tira print invisível de vc.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# `git reflog` é o subsistema de log local puramente volátil (Não pushável em nuvem), que registra toda transição posicional do pointepointer Global do HEAD Reference Daemon nas chaves hashs locais antes de trigger Garbage Collector Daemon (a cada aprox 90 dias GC sweep prune). 
# Se um commit foi Hard-Resetado e sua sub-tree orphaned perdeu o edge apontador referencial da Main, o 'commit' persiste vivendo nos Dangling Blobs Objects e seu endereço original resiste resgatável intocável pelo painel do `reflog`.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# O ALUNO FAZENDO MERDA BRABA: E PERDENDO TUDO QUE CODOU HOJE
# ------------------------------------------------------------

# 1. Eu To na Main! Tinha um codigo massa lixoso lá e eu Dei Hard Reset Odiando Ele (Destruir C/ Força):
git reset --hard HEAD~1

# (BOOMMMMM. Olho no terminal, Olho no VSCode.. TUDO QUE EU DIGITEI ESSA SEMANA SUMIIIIIIIIU DO FISICO. O GIT APAGOU EM HARD TUDO O MEU TRABALHO!!!! O Chefe vai me matar!!!)

# 2. Respireee!! Nada some... Olhe As Câmeras de Teto Ocultas Do Reflog Agora Da Base Inteirinha Local!!
git reflog

# (O TERMINAL CUSPE UMA LISTA IGUAL LOG COM @{0}):
# e4fb2c1 HEAD@{0}: reset: moving to HEAD~1
# a1b2c3d HEAD@{1}: commit: TrabalhoDaSemanInteiraPerfeita
# 9a8b7c6 HEAD@{2}: pull: Fast-forward

# 3. MÁGICA DE RE-RRESSUREIÇÃO DIVINA (O Resgate da Cia Oculta)!:
# O meu "Trabalho da Semana Perfeita" estava em `a1b2c3d` ANTES deu ter mandado Destruí-lo né !!
# Você simplesmente viaja DNC NO TEMPO E INVOCA ELE PELO INDEX DELE!!
git reset --hard a1b2c3d

# BOOOMM! Todos Os arquivos, tudo que eu tinha "Anihilado Perdidio" Pula dnv na cara inteirão no Visual Studio!!! A vida Continua!!!  (O choro dura so O Segundo da Emoção Hahaha ).

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# Em vez de resurgir O Mundo em cim da SUA cabeça e Cagar A branch atual.. Pq NAO invocar O Fantasma de Um Trabalho perdido Dentro de Um Quarto Branch Isoladinha Pra tu espiar Com Medo?
# BATA: `git branch recuperado a1b2c3d` 
# Isso vai criar um universo paralelo chamdo 'recuperado' Baseado Naquela Foto antiga Perdida do Teto Sem Sujar sua Main que esta segura!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Por Que O Reflog me Traiu E Nao Mostrou Meu "TEXTINHO MÁGICO" Que Eu só Salvei No VSCode e Nao dei Git ADD e Commit?!!!?
# REFLOG NÃO Cobre Untracked UnStaged E Un-Commited Files Sujos em Espelhos temporarios Do SO!!!! ELA Só bate fotos das CABEÇAS Pointer do Seu Caminhão. Se O Pacote nem Saiu De Sua Bolsa pro Baú do chao, a CAMERA num viu. Trabalhos só existem pro git a partir do Add-Commit. Se vc deu 'Git Restore' duma Letrinha Em Vermelho Nao Trackeada, vc Jogou pro limbo mesmo e ela Ja Era.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe O Medo De Fazer `Git Rebase` Porque Altera E Esconde Historic.  O Engenheiro Senior Trabalha Fazendo Squashing Brutos Sem Medo das Operacoes Mutaveis Complicadas. 
# Quando Uma Rebase Quebra A Espinha Logica Dele Durante Resolucao De Merges,  Ele Simplesmente Aborta, Ou Bate "Reflog" Do Time-Stamp "Rebase (start)" E Dá Reset Voltando Pra Lá Imediatamente Suprimindo Quaisquer Inseguranças Sobre The "Immutability of The Log". O RefLog é a Principal Armadura Tecnologica Psicológica Do Sênior!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado Uma Branch Gigante 'feature-x', Nao Enviada Pra Nuvem, Foi Deletada Por Engano Com `git branch -D` Da Sua Maquina Hoje As Onze Horas.. Qual Ferramental Voce Invoca No Terminal Local Do Sistema Pra Impedir Que o Fim De Semana Em Familia Restante Vá Pro Esgoto Devido A Ansiedade Transtornada Repetindo Código Dnv Na Segunda??"
#
# Resposta Esperada: "A destruição via`-D` forçado apenas apaga de maneira simplificada a symlink de ponteiro que dava nome nominal de texto descritivo humano `refs/heads/feature-x` contendo o Target alvo da árvore. Os `Hunks e commits blobs` estao isoladamente vivos E Pendurados na estrutura DAG e o indexador de passagens O `Reflog` Detém Exatamente onde E O Que Essa Cabeça Tinha Sido Vista Viva A última Vez! Comandando Uma Leitura Ocular no Reflog Pelo Hash E Executando Uma Criacao De Branch Através Desse Pointer Ressussitando Totalmente o Pointer Novamente."
