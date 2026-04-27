#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Como carimbar permanentemente o Histórico como uma Cópia
# Sagrada Versão do Projeto (Tags Semânticas vs Tags Leves) e 
# congelar lançamentos em produção (Releases).
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Você comprou 20 pães de forma na padaria que eles assaram às 9h, 10h e 11h.
# Eles vêm enfileirados todos com a mesma cara (Commits de historico em linha).
# Se um cliente diz "Eu amei e quero eternizar aquele pão q foi pro fornono meio", é dificil se orientar só olhando (hashes ex:. df49a2s).
# Então colamos com DUREX VERMELHO ESCRITO "O PÃO DA VOVÓ" naquela fatia específica de historico.
# Agora ninguem fala hashs, as pessoas pedem a v1.0. Uma tag não arranca código:
# Ela é uma Placa inamovível colada do lado de um balão do DAG.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# Tags nada mais são que "Pointers Reference de Refs" estáticos no `.git/refs/tags/`.
# Existem as lightweight (ponteiro leve apontando cru pro hash) e as **Annotated**; Onde
# o próprio Git crava um objeto Novo Blob de Tag no grafo (pesado) atrelando "Autor de quem marcou a Placa, Título de Mensagem de Tag, Data da marcação GPGPG Signature criptografia".
# Tags não devem, como acordo de cavalheiros da indústria, NUNCA SER movidas retroativamente da origem apontada sob-pena-de-morte.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# ------------------------------------------------------------

# Eu olhei o projeto e decidi que terminamos! Está LINDO! E eu quero apelidar como "v1.0.0".

# (Opcao ruim: TAG LEVE) -> Só cria o apontamento mudo.
git tag v1.0-leve

# MODO SÊNIOR CORPORATIVO (Tags Anotadas `-a` com Mensagem de release atrelada `-m`)
git tag -a v1.0.0 -m "Versão 1.0 Oficial c/ Login Corrigido em Produção e CSS bonitinho"

# Listando qual tags foram postadas historicamente do projeto e as versoes:
git tag

# Ops, mandei um git push q subiu a tag ? 
# Nao !! O Push do git é medroso. Nao sobe Tags pros Remotes (Github). A equipe nao consegue ver da sua máquineta lá! 
# Pra chutar sua super tag do seu PC pras Nuvens da API:
git push origin v1.0.0

# Pra puxar O COMBO TUDO EM MASSA: Codigo, commits e TUDO das flags tag q não foram
git push origin --tags

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
#
# Comando: git show v1.0.0
# O que faz: Extraí exatamente todos os metadados! Quem Taggou o commit? Qual o texto completo gigante amarrado para justificar o Tagg? e Qual Hash criptografico alvo dele está espetado visualizando a base do dado!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# A GERAL DO ERRO DE DELETAR TAGS DE DEPLOY!
# Se eu marquei a tag errada e quero APAGAR O NOME NOVO v2 porque a versão de deploy de banco implodiu na cara do presidente...
# Delete ela Local do HD seu da maquina com D maiusculo `-d`:
# `git tag -d v2.0`
# E DELETE DA API NUVEM GITHUB, destruindo o Remote q subiu errado para lá! (O famoso comando mágico do dois pontos apagador do git push):
# `git push origin :refs/tags/v2.0`
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Dev Junior nunca tagueia, ele se baseia no "Foi o penultimo commit pro ar que a CI catou...".
# Para a engenharia Sênior o ciclo de deploys de Release é rigorosamente travado em **Semantic Versioning (SemVer)** = Major . Minor . Patch (1.12.3).
# Todo git hospedado (GitLab ou GitHub) utiliza Tags como os "gatilhos reativos" de Pipelines. 
# Quando você envia pro servidor um `push origin v1.2`, um Robo C.I do Jenkins escuta: "Opa chegou uma Tag v...", ele baixa os pacotes, compila minificado o javascript, Zipa os binários C++, e plubica na abinha "Releases" bonitinha automaticamente seu executavel pro usuario final clicar Botão de Download na capa do repo. Sem tag, nao ha deploy de robos da release versionada garantida!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se você precisa procurar num repositório alheio histórico (um repositório clone linux antigo gigante sem nomes de branch main legiveis hoje), um momento exato pra você voltar o codigo seu numa maquina pra testar como ele costumava agir limpo na versão que deu fama dois anos antes. Branch ou Tags?"
#
# Resposta Esperada: "Tags! A funcionalidade arquitetônica absoluta de uma tag é a inamobilidade. Branches são ponteiros efêmeros moveis que vivem correndo adiante apontados ao `Head` mais superior de commit constante das mutações e que podem se deletar após pull-requests. Tags cravam e ancoram fixo o carimbo naquele ponto para eternidade pra permitir `git checkout v2.3.11` fazendo com maestria eu inspecionar a árvore perfeita na qual a empresa baseou a antiga API no tempo cronologico confiavel historicamente."
# ------------------------------------------------------------
