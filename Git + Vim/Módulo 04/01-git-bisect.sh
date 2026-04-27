#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como encontrar UM bug invisível perdido numa palheira
# de milhares de commits num passe de mágica logarítimico: `git bisect`.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Imagine que você tirou 1.000 fotos sequenciais do céu durante a tarde no seu celular e em UMA exata foto surgiu um ET voador no fundo pequeneninho.
# Olhar foto por foto da número 1000 até a número 1 no dedo pra ver "QUANDO ELE APARECEU" vai te matar de tédio.
# O Git Bisect abre a foto do meio Exato (Foto 500). Vc fala: "Bom".
# O Git joga as 500 velhas no lixo da analise e divide de novo (Foto 750). Vc fala "Tem o Et aqui carvalho! Ta Ruim e Sujo!".
# E ele vai picotando pela metade a lista e dividndo até isolar 1 unico milessimo causador! (Binary Search Tree Math).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# O `git bisect` automatiza loops de Binary Search (O log n) transversal pelo grafo Directed Acyclic Graph do repositório, alternando sub-árvores recursivamente testando flags State ('Good' vs 'Bad'), reduzindo o delta linear de 10.000 checkpoints pra inspecções iterativas pírricas de fator ~13 passos absolutos para isolamento causal do culpado original que introduziu patches degenerativos em Continuous Integration.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# ------------------------------------------------------------

# 1. O PÂNICO: "A Tela ta quebrando em branco. Começamos a caça ao culpado! HORA do Jogo":
git bisect start

# 2. Eu informo ao Juiz: "Ei, o commit exato atual AGORA HOJE ONDE ESTOU é LIXO E TÁ RUIM (BAD)":
git bisect bad

# 3. Eu sei e lembro de cabeça que a UM MÊS ATRÁS o sistema bootava lindo! Pego a TAG de meses atrás ou seu SHA velho:
git bisect good v1.0.0

# [A MÁGICA]: O git arranca seus arquivos atuais e "Viaja pro Meio-Terrmo". No terminal ele escreve:
# "Bisecting: 512 revisions left to test after this (roughly 9 steps)".

# Você abre o Google Chrome ou O App e clica Testar. Humm. Aqui tá lisinho, não pisca.
git bisect good

# (Boom.. Ele divide a fita e viaja e re-testa.. "256 left (roughly 8 steps)"). E Vc re-testa no Seu olho tbm! E Vê:
# "Caraaaaca q lixo.. deu Pau aquI!": 
git bisect bad

# Ele Dirá Finalmente: 
# "3f2a8q IS THE FIRST BAD COMMIT. AUTHOR: FELIPE". 

# UFAA ACHEI O COISA RUIM! Pare a Sessão de detetive e reseta voltando td pra Vida atual do futuro!!:
git bisect reset

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# Em CI (O Robo Do Servidor Senior Autônomo): O bisect pode rodar Sozinho enquanto vc vai tomar Café da Tarde e faz A busca SEM você Clicar!!
# Comando Gigante autônomo: `git bisect run npm run jest-tests`
# Se o robo npm teste der fail ele joga Bad, se nao der ele joga Good Sozinhuuuoooo!!!! E te cospe o relatório asquerosa na cara depois q vc volta da maquina de cafe! =DDDDDDDDD O MUNDO E LINDK!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Comecei o Bisect e de repente no Passo Oito deu conflito da biblioteca do npm que eu nem usava no ppassado e travou!  :(
# Como eu pulo 1 Ponto Mofado Sujo do passado que eu não consigo compilar pra testar ser Good ou Bad??
# Solução: `git bisect skip` (Por favor, git, ignore esse pontual problemático e divida o outro vizinho para não quebrar a balança matematica log).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Senior sabe q programar com "Small Commits Adittions" Atômicos (Um commit pra CSS, Ouro pro Banco) Não é pra deixar Trello e JIRA lindos.
# Commits Monolíticos do Lixo ( Onde tem 1000 arquivos misturados alterados) Dificultam a magia do `git bisect` e de ferramentas Debug analíticas. O Bisect Encontra Brilhantemente a Agulha "Qual Hash Destruíu?". Mas Se o Programador Junior botou TUDO Dentro Dum "Commit -m Fix stuff" O Bisect achará um contêiner lixo enorme de lixo e não vai te isolar O VETOR cirúrgico q era só uma vírgula maldita numa variavelzinha minúscula varrida! O Bisect BRILHA em históricos bem escritos e particionados!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado um repositório legado com aproximatidade 2.050 commits entre 2 marcos (Good1.2 <----> Bad 2.0), caso voce inice um processo algorítimico de git-bisect manual de caça analítica... Qual o Número máximo e absoluto de iterações/passos mecânicos vc testará fisicamente na maquina antes que o Git o entregue a Root Cause?"
#
# Resposta Esperada: "Pela matemática inata fundamental da Binary Division Search em árvores de complexidade temporal O (LOG² n). Log de 2048 de base Dois culmina precisamente fixos em aproximalidade técnica MÁXIMA de 11 exatos steps-verificadores para estrangular o range num único vetor isolado."
