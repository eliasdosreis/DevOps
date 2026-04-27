#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# A técnica bizarra das bonecas Russas Mátrioska: Você 
# hospedando Um Git Completo e Independente VIVO, ESCONDIDO 
# INTERNO dentro de uma Pasta do Seu Outro Projeto Original!
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Você constrói um Carro (Super-Projeto Main Git Repo).
# Mas o Motor v8 do Carro não é seu, Ele é da Honda do Google, e está Num Projeto DELES isolado lá!
# Em vez de você Baixar O Download Estático ZIP Das peças, Voce Coloca um BURADO NEGRO (Um portal chamado Submódulo) dentro da pasta `\motor` do seu Projeto. Pela Janela dela O Submódulo respira! Se A Honda Criar um Pino Novo la Do jJapao. Você simplesmente atualiza O seu Modulo que "Puxa" As Pecas Novas Do Japão sozinhas Pro meio do teu carango, com 1 so clique! Eles são Projetos Parasitas mas indepedentes na matrix mãe!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# Submodules apontam um Pointer Commit Reference fixo (The GitLink) para um external remote repository alojado em path restrito, gerido num arquivo top-level chamado `.gitmodules` que dita URI protocol maps. O Git Principal NÃO registra no grafo os arquivos-blobs literais em plain-text desse path atachado. Ele Grava Únicamente: "No diretório `/motor`, existe um Repositório Externo Na URL Honda q tem o hash X.Vá LER de LÁ se precisar! ". 
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# Você tem no Seu Projeto o seu Theme de CSS que usa numa API louca. 
# ------------------------------------------------------------

# Adicionando As Bonecas Parasitas Dentro Do SEU Projeto Pela URL Original Da Honda (Google/Theme) Na pasta `/vendor/themes`:
git submodule add https://github.com/hondaofficial/motor-v8.git vendor/motor 

# Seus Colega Baixa (Clonezão) O Seu Carro Completo Com o Submodulo E ... A Tela Da Pasta do `/vendor/motor` VEM VAZIA INVISIVEL E OCA! :( Nao Compilou!
git clone https://...meucarro.git

# MAGIA QUE COSPE E DESENROLA O ROLO DOS SUBSMODULOS DA MATRIX PRA SEUS COLEGAS:
git submodule init    # (Configura os .gitmodules Da Boneca e Local paths!)
git submodule update  # (Puxa os Blob e a árvore Real Viva dos Parasitas do motor pra dentro oco da pasta).

# [Sênior Atalho Ninja De Um Só Chute no Clone]:
# Seu Amigo clona o Seu Projeto COM MÃE E OS PARASITAS TUDO DE UMA VEZ BASTANTE RECURSIVO!!
git clone --recurse-submodules https://.....meucarro.git 

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# - Você Puxou "Honda O Motor V8". O Seu pai Puxou O Motor Daqui 3 anos.
# CADE A ATUALIZAÇÃO RECENTE DA HONDA Q SAIU ONTEM???
# Vá para pasta `/vendor/motor`. Rode La Dentro da Pasita o `git pull` Liso Deliciioso (Pq Ele É UMA FILIAL DE GIT A PARTE E DESASSOCIADA!). O Motor Updatea!  Você Sobe A pasta Pro Seu Projeto-Mae Maiorzão: Vá e bata 'git add vendor/motor'. PRONTO O SEU CARRO DA MAE USA  O MOTOR MAIS FORTE ATUALIZRADO!
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Conflito Fatal Em "Detached HEADs" do Submodule?
# Os parasitas Não Seguem Branches Main Padroezinhas pq Eles Nao Podem Mudar Todo Dia por Vontandes Obscuras. Eles se fixam No Hash exato "v23.24 da Honda" e Morrem ali travados. Se Vc Entrar nele e mexer codar e fuçar os oleos... Vc Escreveu Em HEAD PERDIDA EM LIMBO! Use Checkouts Branches la dntro antes De Editar Algo Pelo A MOr de Deus Cego C/ raiva..
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe o Horror a Submódulos Na Indústria DevOps inteirça Pela Complexidade Estrepiante Das Pipeline Syncs E Orfaos References Perdidas..
# O Pleno/Senior Abandona Ferramentarias Antigas Submodule qnd Pode Para abraçar **Package Managers** (`NPM, PIP, CARGO, MAVEN`). Porque Lidares Com Versoionig System e Resolucao Deps é trabalho Do Npm registry na nuvem e num num Submodulo. Porem se a empresa possui Microsserviços e Monorepos de Bibliotecas Common Próprias Restritas em Private Clouds de C++, Submódulos AINDA governam e prosperam atestando Links estáticos de Graça.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado um Repo Mae e As Bibliotecas Dependentes Em Submodulos Clicados Dentro... Qual É A Imagem Visuial E Lógica de Blob Ref Registrada Num Ponto No Git da Mae Referente à Pasita Inclusa (e.g Vendor/Themes)? E como remove-los inteiramente do chao limpando The Cache s/ explusoes e orfaos perdidos e quebras?"
#
# Resposta Esperada: "A mãe reconhece SubTree Merges Através Do FileMode Especial 160000 `(commit object em tree root directory)` marcando ali que a estrutura do chao Pertence a Uma Regência de Outro Banco Externo, e Não um File Comum 10644. P/ Remoçao Cirurgica limpa O dev deve deletar o path em .gitmodules config, usar git rm --cached do directory link, remover as sections locadas em .git/config root, e estripar as pastas fisicas pesadas da barriga escondida dos modules via `rm -rf .git/modules/vendor/themes` p/ ninguem ver o fantasma no fs!"
