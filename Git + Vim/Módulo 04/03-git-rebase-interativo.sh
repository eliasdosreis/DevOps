#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como falsificar, juntar, reescrever e polir o lixo do histórico
# local pra ele ficar perfeito como o trabalho de um deus da programação
# usando o `-i` (Interactive Rebase). 
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Você escreveu 5 rascunhos de uma monografia em papel num dia inteiro:
# "Rascunho 1 Introducao torta".
# "Rascunho 2 Corrigi acento ahhaha"
# "Rascunho 3 Adicionei O fim"
# "Rascunho 4 Arrumei burrice da intro.."
# O Rebase Interativo abre uma Sala De Cirurgias com a Tesoura Magica. 
# Vc manda ele JUNTAR OS 4 PAPEIS NA MASSA como cimento ("SQUASH"),
# Joga todos as desculpas podres de lixo do titulo foraaa, e Vc Bota uma Capa Dura Bonita só:
# "Monografia Perfeita Assinada Pronta".
# O Chefe Olha e Fala: Uau. Ele escreve limpo numa tacada só q magico!".
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# Interactive rebasing utiliza o arg flag `-i` invocando editor de textos buffer em modo VIM exibindo comandos procedurais sequenciais mapeados do HEAD regressivo apontado (e.g. `HEAD~4`). Ele permite Squash (Unir commit preservando txt messagem original), Fixup (Uniar Commit deletando txt messagem original), Edit (Invervir E Parar loop tempão temporal abrindo buffer tree pro operator mudar na mao a index), E Drop (Aniquilar silenciamento commit da timeline DAG inteira)! Resultando no hash override global de ponta a ponta gerando nova linearidade mutada.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Você comitou 3 bobeirinhas as escondidas na sua FEATURE nova q vc não queria em publico no P.R Da Empresa pra não Rirem De vc.
# ------------------------------------------------------------

# 1. Acorde o Cinto Do VIM interativo mirando "Para Os Ultimos "TRES (3)" Carroções (Commits) Pra Tras daki!"
git rebase -i HEAD~3

# ==============  MAGIA VIM MODO DO GIT ABERTA!  ==============
# TELA DO VIM SE ABRE SOZINHA COM ISSO DECORADO EM CIMA NO TXT:

# pick 2f3a4bb Adiciona a parte 1 do nav
# pick e1b2c3d Arrumei uma coisa da parte 1 que o burro esqeceu  <---- VOCE TA COM VERGNOHA DISSO.
# pick 9a8b7c6 Limpa espaço n brancoo    <--------  LIXOL

# A SUA MISSÃO DA CIRURIA INTERATIVA COM O EDITOR E TECLADO VIM AGORA!!!
# Vc anda com A FLECHA J DO VIM. 
# Vai Em cima da palavrinha *pick* das duas de baixo. Usa Cw E Muda Pra a Letrinha de Letalidade Ninja *s* (Que é do inglês SQUASH = ESMAGUE)!
# Fica Assim VISTO NO SEU MONITOR:

# pick 2f3a4bb Adiciona a parte 1 do nav
# s e1b2c3d Arrumei uma coisa da parte 1 que o burro esqeceu 
# s 9a8b7c6 Limpa espaço n brancoo 

# Salve E Saia Brutalmente do Vim como vc ja Sabe Sênior: "ZZ" (Batendo Z Shift).
# O GIT JUNTARAAAAA TUDO AS LINHAS NAS ÁRVORES AS TRES COISAS EM 1 SÓ COROAO E ABRIRA DE NOVO O VIM TE PERGUNTADO:
# "Ok! Esmaguei td dentro duma panela chefe!  QUAL NOME NOVO DE UM COMMIT SO BONITO QUE ELA LEVARA DO BAÚ FUSIONADO?"
# Vc apaga as vergonhas suajs velhas c/ 'dd' e Digita: "feat: Navbar completo perfeito do zero". 
# ZZ Pra Sair. 
# MÁGICA FINALIZADA HISTÓRIA MUDADAAA PARA UM SÓ COMMITO MARAVILHOSO PRA SEREMPURE!

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# "Perai Eu Nao Quero Esmagar O trem de cima Com o de Baixo.. Eu Comitei Meu Nome Do Arquivo Fdp Mas era Pra ser ArquixvoXpto, Preciso abrir ele no passado consertarn a burrice!!"
# USE O COMANDO `edit` ou `e`  Ao invés de squash !!
# O Git Aborda Temporalmente A vida. Ele Congela Tudo Lá Atrás.
# "ESTAMOS PARADOS NO TEMPO. PODE CORRIGIR ARQUIVOS NO VSCODE. BATA GIT COMMIT --amend Quando Terminar Mestre!!".
# Batendo depois O "git rebase --continue" qnd tu salbou. Misticismo do passado reparado com honras ao lorde!!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Tive Um Conflito Bizarro no meio do Squash E Perdi Controle Mental da Situacao!! Pânico! Travei nas paredes Do Rebase! 
# Respira.. Não se Caga Calças pq Tudo é Volaill:
# Mande Abortar o Trem Da Linha Do tempo Cirugica q ta Rasgada Pela Metade Em Sange:
# `git rebase --abort` !! Seu Mundo Voltara Ao Exato Lixo Antigo Sem Danos Reais Nenhuns!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe O Principio Do Senior Lindo De PR (Pull Request Code Review Clean).
# Ninguem (Manitainers/Devs Ouros) Lê os Detalhes Burros Dos Processosos De "Pq Vc Falhou" em 50 commits pequenos chamados 'wip, fix, testa, foo'. O Revisador Cansado Da Google Avalia A INTEGRIDADE da Logical Idea como Atomic Unit Delivery. O Interative Rebase é a vassoura da domestica varrendo a Sujeira Pra Cima dos tapetes Da Matrix e Entrelacando em Blocos O (Fix 1234 - Implementa User Login Oauth), Reduzindo E Facilitando Dificuldades Mentais Durante Bisections E Code-Audits das CI pipelines e Auditores SOx.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se Vc Possui Trinta Commites Isolados De Um Fix Pequeno Na branch Sua Oculta Solitaria E Vc precisa Esmagar Exatamente Todos Numa Linha So De Unificacao Antes Do Merge. Usar Interative Rebase `~30` Pra Subistir 29 Linhas Do vim Por 'S' Seria Arrastadíssimo. Há Como Atacar Essa Limpeza De Squash Rapidamente com Soft Reset?"
#
# Resposta Esperada: "Alternativa Extrema do Squash Efeito Prático Sem a Magia do Vim: Nós Aplicamos um Reset Temporal Ponderado mantendo a Carne Viva no Stage: `git reset --soft HEAD~30`. Assim as Cabecas de 30 comitem Explodem Ao Void. As alteracoes Arquitetonicas Em Arquivos Sao Mantidas Inteiramente Incalvas E Empilhadas De Primeira Em Sua Stage Index. Daí Apenas Finalizamos C/ A Graça De Um Unico `Git Commit -m "feat: O Fix Da Vida Inteira"`. O Efeito Matrix E O Mesmo S/ Dores Interativas Longas!"
