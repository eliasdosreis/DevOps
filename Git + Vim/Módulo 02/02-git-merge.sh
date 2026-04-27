#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como unificar o trabalho separado de duas branches divergentes 
# (trazer o 'feitiço' do seu lab de volta pro mundo real)
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Você foi viajar por 1 mês (Branch Feat). Seu irmão ficou em casa e pintou 
# (Branch Main) a porta do quarto de vermelho numa quinta-feira e limpou o teto na sexta. 
# Você, longe, trançava pulseiras. 
# Dar "Merge" é você voltar para a mesma casa (Main) e colocar suas pulseiras na 
# cama. Agora todas as novas realidades da família coabitam na linha oficial da família:
# "Porta vermelha + Casa teto brilhante + Seu lote de Pulseiras prontos".
# O merge os une criando um Ponto temporal único convergente chamado "Merge Commit" (nós de união das linhas).
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# O `git merge` incorpora o histórico divergente em uma branch comum. Utiliza o LCA (Lowest 
# Common Ancestor) ou "merge base" em um snapshot final para cruzar 3 árvores no algoritmo (3-Way Merge).
# Caso o caminho para divergir a sua branch da principal não tenha possuído ramificações 
# adicionais no meio (ex, `main` "ficou parada"), aplica-se o trivial "Fast-Forward".
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# ------------------------------------------------------------

# Posição: NÓS ESTAMOS NA BRANCH destino, a nossa 'main', esperando para reber.
git switch main 

# Assuma que nosso colega terminou o trabalho na isolação da feature dele.
# O comando de "Puxar e Anexar a branch paralela para este nosso galho destino mestre aqui".
# Se der tudo certo, abtirá O VIM pedindo uma justificativa para fundir as realidades (o seu Merge Commit).
git merge feature-login

# E agora, a branch temporária dele, como prometeu trazer mudanças permanentemente
# à nossa master file, pode ser deletada para varrer o lixo temporal:
git branch -d feature-login

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git merge feature --no-ff
# O que faz: Se o git identificar que a `main` NUNCA se moveu e pode simplesmente
# avançar a fita (fast-forward) reto (uma linha reta só sem nódulo de desvio visível visualmente),
# você perde a noção histórica explícita (bolinha gráfica separada) de que ISSO UMA VEZ EXISTIU SOLITARIAMENTE como um pacote FEATURE coeso.
# O sinalizador `--no-ff` ("não pule fita, gere nó") forçará graficamente a criação do balão unificador
# preservando um "Ooo, olha que legal, teve uma branch sendo desenvolvida inteira no lado antes de re-aterrirzar."
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Verificar arquivos gerados: log visual após o merge de nó.
# Rode 'git ll' e verá e cruzamento de caminhos e linhas rosas atravessando linhas verdes.
# 
# Se aparecer "Auto-merging <ARQUIVO>" e depois => "CONFLICT (content): Merge conflict in <ARQUIVO>": 
# O Git falhou sozinho. Significa que você e seu colega mudaram fisicamente as MESMAS linhas de 
# texto do mesmo arquivo ao mesmo tempo, em suas garagens separadas. (Veremos este inferno na aula 4.)
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe uma eterna "Guerra Religiosa Sênior" na comunidade:
# "Devemos mesclar a API do time através de uma montoeira de `--no-ff` (Bolotas de Merge e grafo feio mas com contexto granular)?
# Ou devemos esmagar e re-empilhar historicamente como linha reta limpa?"
# A filosofia geral conservadora prefere manter explicitamente e semanticamente os balões explícitos
# `--no-ff` pra branches "Grandes" de vida longa e rebase pra limpezas temporais antes de lançar à main.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se você abrir o Terminal do log amarrado, por que verá frequentemente vários 'Merge commit...' na main
# e qual diferença do avanço 'Fast-Forward' onde não existem bolotas e os commits só saltitão à frente linearmente?"
#
# Resposta Esperada: "Fast-forward ocorre quando o galho destino (ex: Main) estacionou quietinho desde o momento
# que a sua Feature saiu dele. Como ela não mudou (nem andou para a frente), o ponteiro Head da main pode ser simplesmente empurrado
# arrastado linearmente (O(1)) pelo caminho à frente dos novos commits. No entanto, se o meu amigo João já atirou 3 commits
# novos na Main que não estavam previstos antes, as estradas se partem. Para unir pontas disfarçadamente de árvores ramificandas 
# o Git invoca o Recursive True Merge, batendo no liquidificador ambas pontas em um NOVO commit final de Unificação. A principal diferença 
# do Fast Forward é esta, Fast-Forward não exige um commit cimentando e descrevendo filosoficamente o porquê de existir colapso das árvores."
# ------------------------------------------------------------
