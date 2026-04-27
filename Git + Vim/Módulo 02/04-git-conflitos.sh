#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# O que fazer, passo-a-passo, visual e conceitual, quando
# você bate num obstáculo inevitável em equipe: O Merge Conflict.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Você está escrevendo um testamento colaborativamente com
# o seu irmão.
# Você na "linha 5" diz: "Vou doar a porshe e o carro para mim".
# Ao mesminho o seu irmão nas costas na "linha 5" diz dnv (em outro pc): "A Porshe toda vai ditar pros meus cavalos velhos da rua."
# O Git é como o cartório que compara o seu documento com o do irmão - "Galera, ambos tentaram registrar texto SOBRE PELA MESMA LUGAR da caneta! Não vou assumir a autoria para não favorecer ninguem. Entrem num acordo na porrada aí o que deve viver, e batam de novo o carimbo na minha testa!". E o cartório sublinha os riscos de vermelho pra você!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# O conflito de mesclagem é decorrente do limitador das verificações Heurísticas da `Diff` string matching nos objetos tree do Git. Quando dois blobs divergentes divergem nas adjacências consecutivas de bytes e apontam para a idêntica `Hunk`, a engine autônoma aborta a fase C de inserção parando num limbo 'Unmerged Path' contendo os delimitadores explícitos padrão 7 chevron "<<<<<<<" que dividem e separam a sua current branch target, a branch que vem ("remote"), e qual as decisões a serem removidas/inseridas do texto fisicamente pelos devs no editor antes do Commit-Resolution.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA E SINTAXE CHOCANTE
# Quando vc atirar `git merge branch_dele` ou `git rebase` a Tela dirá as letrinhas terríveis "CONFLICT (content)". 
#
# Se você abrir naquele instante exato o seu arquivo `app.js` no VIM localmente do pc:
# Você ficará aterrorizado porque o git ALTEROU o seu texto literal preenchendo aspas e letras feias como abaixo:
# (Isso aqui de baixo foi INJETADO no seu aquivo):
#
# <<<<<<< HEAD
# function calcular() { return a + b * 2; }
# =======
# function calcular() { let x = a+b; return x; }  
# >>>>>>> branch_dele
#
# A sua missão aqui, não é o terminal de cmd. O seu papel é apagar <<<< ==== e >>>> as canetas sujas na mão, editar e decidir logicamente "Como fica no final". Ficando EX: function calcular() { let x = a + b * 2; return x;} 
# ------------------------------------------------------------

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# 1. Detectar os conflitos sangrando vermelhos pela espada: `git status` -> Unmerged Paths.
# 2. Abre o seu arquivo: `vim app.js`
# 3. Procure `====` apague o lado perdedor que o amigo fez burrado ou some os dois e arrume o código na sintaxe da linguagem. Limpe TODOS os chifres <<<<<< e >>>>> que tavam em volta para o compilador e o interpretador nodejs e VIM no syntax highli. não falharem por erros chulos e bizzarros!
# 4. Salve seu arquivo: `:wq`
# 5. Feito isso para 100% de todos os arquivos bugados do `status`, empurre-os os resolvidos pra validarem pro estage: `git add .`
# 6. Oficialize seu diploma final e lacre a guerra e saquinhos de defuntos pra sempre e feche: `git commit -m "Merge finalizado corrigindo login e header!"` 
#   [Pronto! Acabou a tensão!]
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Em panico total no Git Merge estragando seu arquivo de prod?! 
#
# COMO DESFAZER E ANULAR: (Nao sei consertar apague e me volte no inicio q tentei da merge pfv socor!!!)
# Comando Salvador de Corações de Junior desesperados pondo fogo no prédio:
# `git merge --abort` 
# Seu ambiente volta inteiro perfeito pra trás intocavelmente seguro antes que do estupro conflitivo do código!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe uma interface Visual mais segura de se trabalhar do que editando Chevron por Chevron cegamente com Medo.
# Quando você tem problemas sérios nas linhas vc precisa bater `git mergetool`. E ele invoca a nossa ferraenta externa,
# O qual configuraremos a sua MÁQUINA DE MAGIA DE VIM DIFF (`vimdiff`), que abre 3 Telas lindas Splitadas Verticais mostrando você a esquerda o amigo na direita e o resultado perfeitamente casando as texturas no centro sem sofrimento para mesclarmos! (Cenário Visto Posteriormente em "git+vim mundo real aula mod9")
# E os desenvolvedores Seniors utilizam PRs (Pull Requests) para não lidar com os problemas locais e sim resolvê-los de interface das ferramentas github com revisores sêniors no intermédio opinando.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou na master branch corrigindo um array, e eu recebo os erros <<<<<<< HEAD ...  ======= .... >>>>>>> bug_feature.   Qual é a MINHA responsabilidade sobre a sessão 'HEAD'? "
#
# Resposta Esperada: "A demarcação 'HEAD' indica estritamente as suas modificações na branch local que você VESTE no dado exato instante de tempo inicial de execução de operação. E a parte inferior é estritamente O ALVO do remote recebido (Sua equipe - em nosso caso as do branch 'bug_feature'). A responsabilidade não se encerra em 'Escolher um ou Outro', podendo frequentemente e geralmente o programador optar atuar transicionalmente editando e re-desenhando ambos logicamente numa terceira via coerente pra a solução rodar no browser após o clear-text."
# ------------------------------------------------------------
