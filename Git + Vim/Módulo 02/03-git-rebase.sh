#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como usar a Magia Negra Senior do Git (Rebase) para alterar,
# reescrever e alinhar blocos do passado como se a história
# tivesse caminhado uniformemente, perfeitamente em linha reta.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Lembra da aula de Merge onde você foi viajar e o irmão pintou
# a porta? Como o universo bifurcou, ocorreu um 'conflitinho visual de estradas se curvando' - gerando o clássico Nó Gordinho de Merge.
#
# Já no `Rebase`, imagine que você entra numa Super-Máquina do Tempo (DeLorean).
# Você descobre o teto que seu irmão pintou. Mas VOCÊ quer que todo mundo ache
# que a "SUA" pulseira foi criada DEPOIS do teto (para a sala não parecer bagunçada com a pintura e pó de reboco por cima da pulseira de lã).
# Então a Máquina: Pausa sua atividade temporal -> Vai lá e avança o mundo 1 mês
# sem seu colecionável lá, e então Pega SEUS ITENS DE CÓDIGO e costura no TOPO FINAL
# de toda base de trabalho que o irmão fez hoje!
# Tudo vira perfeitamente linear, sem balões ramificados.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# O "Rebasamento" (Rebasing) move as origens matemáticas do base pointer de um branch para sub-anexar seus
# diffs ("patches/commits rebobinados") perfeitamente recriados um por um sobre O CIMO NOVO HEAD
# alvo especificado da Master. Isso achata fisicamente ("flattens") o gráfico Histórico (`DAG`), destruindo e 
# recriando cada commit antigo modificado gerando um Hash Criptografado inédito. 
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# ------------------------------------------------------------

# 1. Você está na sua branch 'feature' velha desatualizada e o João já atirou toneladas 
# de bugs e fixes pra Master hoje de manhã! 
git switch feature_minha

# 2. Você primeiro captura pra você as novidades que ocorreram na master por segurança as escuras:
git fetch origin main    # (Aprofundaremos mais sobre origin na Aula Seguinte)

# 3. MÁGICA TEMPORAL (O REBASE): Você quer colocar SUA velha ramificação, no TOPO DO PICO dos fixes de hj de manhã da Main!
git rebase main

# RESULTADO NO TERMINAL:
# "Rewinding head to replay your work on top of it..."
# (Traduzindo: Pare o tempo. Arranca (Rebobinar) a arvore pra um bloco secreto. Move sua seta para a 'main'. E a cada PEDACO que estava la ele RE-APLICA o diff silenciosamente por cima. Linear!!)

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git rebase main   (Estando de dentro da Feature)
# O que faz: Aplano a linhadodia pra evitar que um balão imenso deturpcione a visão dos deploys.
# O que esperar: Você pode ter problemas caso seus velhos arquivos trombem no meio do tempo (Rebase Conflict), onde você precisará ajeitar as peças 1 por 1 re-acordando o "git rebase --continue" infinitamente nas dores infernais.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# **O GRANDE PERIGO** e TroubleShooting de 1 Milhão de Dólares:
# E se você iniciar seu rebase, resolver os conflitos no vim e o Git travar no limbo esperando eternamente "Applying Patch:..."?!
#
# - Pra Abortar o Rebase e Restaurar sua velhice sã e salva para 5 minutos antes:
#   `git rebase --abort`
#
# - Pra seguir adiante DEPOIS QUE você salvou no editor (`git add`) os arquivos do passo que a parada emperrou temporalmente e está pronto e lindo pra continuar as peças pro tempo:
#   `git rebase --continue`
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe UMA Regra de Ouro absoluta que reprova juniors em entrevistas. A Regra é:
# "NÃO FAÇA REBASE DE NADA PÚBLICO E EXPOSTO."
# Rebase destroem a "História Real como ela foi."
# Destruir / Reescrever o Hash criptográfico da sua branch local solteirona no seu C:\ (só vc tem ela) => Ótimo, mantém a rede linda.
# Rebasear "A main branch ou a release pública que os clientes e os 20 desenvolvedores do Prédio" já puxaram nos seus próprios Pcs => Inferno Absoluto, eles receberão falhas de tracking no `push / pull` em que as cabeças não combinam pelo erro da assinatura quebrada. Todo dev terá que dar um `Merge` porco contra um código que não existe ou pior deletar todo projeto corrompendo as arruelas locais e clonar dnv em pústula.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se Merge cruza informações sem quebrar grafos, por que engenheiros sêniores obcecadamente nos times de Cloud utilizariam o `Rebase`?"
#
# Resposta Esperada: "Geralmente usamos a combinação 'Rebase e Squash Local' porque em times onde caem 50 deploys diários de Pull-Requests na raiz 'Main', o gráfico Histórico seria um imenso Novelão de Lã e Cabelos indecifrável de 100 merges embaraçados em nó para a direita e esquerda entre features ridículazinhas de 1 linha. O Rebase nos permite puxar a nossa Pull-Request que já não prestava para o Topico, deixando todo processo uma linha linear fácil de fazer 'Bisect' de bugs onde visualizamos sequencialmente cada feature em ordem natural de tempo - O rebase deve SEMPRE obedecer a Regra de Ouro: Sendo aplicado a commit restritamente privados un-pushed da máquina original de submissão do Contribuinte, antes do Remote ver e consolidar os dados."
# ------------------------------------------------------------
