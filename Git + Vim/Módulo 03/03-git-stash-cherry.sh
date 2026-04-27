#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# As duas pérolas cirúrgicas da agilidade git: 'Stash' 
# (esconder bagunças para limpar a mesa rápidão) e Cherry-Pick
# (Roubar pedaços isolados de universos alheios pro seu).
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# STASH: Vc está montando um avião de LEGO (seu código novo super chato e pela metade). De repente, toca o alarme do predio pra vc sair, ou o chefe berra: "Para tudo e conserta a página de login q quebrou (outra branch)".
# Em vez de jogar o LEGO pela Janela ou amontoar com SuperBonder ruim e quebrado do jeito que tá (Commitando código inútil e nao compilavel quebrando seu histórico): Você Joga tudo dentro de uma gaveta (Stash!). Limpa a mesa pra login, e quando voltar puxa o Lego montado tortinho inteiro do refugo debaixo da mesa ileso (Stash Pop)!
#
# CHERRY-PICK: Um amigo fez uma branch paralela. Ele lançou lá: o botão logar, e o CSS do navbar, e um Bug Feio do navbar comitado no 3° save. Eu (Na main) falo "nossa ele é muito genial, porém nao quero o navbar cagad0.. Só curti a linha e commit 1 de `botão`.". Com a canetinha verde cereja você "Pinça do Meio da Árvore" isoladamente apenas aquele 1 Hash SHA pro topo seu sozinho!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# `Stash` (Stshing) cria e assina uma Tree dangling isolada gravando `WIP` "Work In Progress" Index e un-staged objects. Eles criam reflogs invisíveis em stack em LIFO structure (Last In - First Out) local sem comprometer as arvores rastreadas de histórico da sua current-head.
# `Cherry-pick` efetua um merge algoritimico reverso do DIFF entre a parent do commit ALVO e ele, pra transplantar e commitar (reescrevendo um novo hash clone) pra current Head.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# ------------------------------------------------------------

# Puts. Alterei o menu.. O codigo nao funciona. Meu chefe mandou eu mudar de branch na correria! Se eu mudar agora suja as arvores... Eu limpo a calçada inteira num piscar de olhos com:
git stash 

# Uhu! Git status dirá: Limpinho!
git switch branch_bug
# (Arrumei o bug, o prédio parou de por fogo, ufa..)
git switch menu_sujo_branch

# (Cade as alterações que fiz as tres da tarde??) -> Vamos puxar a gaveta superior! `pop` traz e DELETA da gaveta:
git stash pop

#
# ---- AGORA O CHERRY PICK ----
# Eu to na main. Meu caçador fez um commit magnifico e5f9a2 que gera relatórios na branch B.
# Não posso trazer a branch B toda com um Merge! Nao tá pronta!
git cherry-pick e5f9a2 
# BOOOM. Acaba de vir pro meu repositório central uma cópia xerox genial daquele trabalho dele, sem atrelar a branch.

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git stash list
# O que faz: Exibe o inventário das gavetas empinhadas caso vc seja desorganizado e abraçado em 5 gavetas (1 stash@{0}, stash@{1} ...).
# Use comandos atados nas keys pra voltar o q queria: `git stash apply stash@{1}` (apply nao deletará da maquina igual o q o Pop faz).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Conflitos com Stash POp??
# PODE OCORRER QUE SIM!
# Se, no tempo que sua alteração ficou escondida, Você alterou coisas no código principal que encostam no lixo engavetado. O git grítará conflito na hora q o Pop abrir na mesa. Resolva manualmente `<<<< ==== >>>>` idêntico à aula anterior! 
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe uma pegadinha imensa. `git stash` por padrão engole coisas conhecidas e arrastadas pro Track. Arquivos que acabaram de ser recém criados (Novos Text Document Vazio.txt) com touch / echo não costumam ir na roleta pq o Stash os ignora cegamente por estarem "Untracked"! O sênior precavido bate a Flag ninja: `git stash -u` (include untracked), pra não estragar sumindo as novidades físicas desvinculadas das pastas pro abismo de trocas de brancas.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou mantendo 3 versões corporativas antigas ativas ativamente vendidas pro cliente (Ex: v1.0 LTS, v2.0, Main V3.0), e eu encontro em 2024 uma vulnerabilidade fatal gigante ZeroDay de Hacker explodindo na v3.0! Eu concerto isso hoje gerando commit xpto! Como evito a fadiga de ter que escrever na mão a mesma logica e concertar em cascata na v1 e v2 manualmente pra equipe?"
#
# Resposta Esperada: "Aqui mora O brilho do `Cherry-pick`. Um programador Senior só resolve a pane na branch da feature, desce para Master, Merga o hotfix commit 0xA77! Após isso, basta mudar a branch (git checkout v1.0LTS), e roubar o diff idêntico limpinho da correção `git cherry-pick 0xA77`. Ir para a segunda branch `checkout v2.0` e rodar o cherry idêntico `cherry pick 0xA77`. Corrigimos as três frentes do tempo do sistema na linha temporal com a mesma cirurgia de remendo atômico de uma forma assincrona isoladamente."
# ------------------------------------------------------------
