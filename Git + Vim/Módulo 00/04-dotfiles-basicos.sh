#!/bin/bash

# ============================================================
# O QUE ESTE SCRIPT ENSINA:
# Introdução aos conceitos de Dotfiles, configurando o seu 
# `.gitconfig` com aliases e um `.vimrc` limpo para iniciar produtivo.
# ============================================================

# ------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# Quando você compra um carro, o assento e o retrovisor vêm em posições
# padronizadas de fábrica. Fica muito desconfortável dirigir assim.
# Ajustá-los para a SUA altura é como criar dotfiles. Dotfiles (arquivos do ponto)
# são as personalizações salvas das suas ferramentas.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 2. O QUE É (Definição Senior)
# "Dotfiles" é o termo informal para arquivos ocultos usados em 
# shells baseados em Unix e SOs relacionados para guardar configurações
# do usuário (ex: ~/.vimrc, ~/.bashrc, ~/.gitconfig). Versioná-los e mantê-los
# limpos garante reprodutibilidade de setup instantaneamente em novas máquinas.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 3. DEMONSTRAÇÃO COMENTADA
# O script abaixo injeta linhas no seu .gitconfig de atalhos e cria
# seu vimrc básico de sobrevivência.
# Execute os pedaços que achar interessantes em seu terminal.
# ------------------------------------------------------------

# ---- CONFIGURAÇÕES DO GIT (ALIASES/ATALHOS) ----
# Aliases transformam comandos grandes do Git em pequenas letras
git config --global alias.st status        # Transforma 'git status' em 'git st'
git config --global alias.co checkout      # 'git checkout' -> 'git co'
git config --global alias.br branch        # 'git branch' -> 'git br'
git config --global alias.cm commit        # 'git commit' -> 'git cm'

# (Sênior Tool) O log gráfico: Uma forma em ávore mágica de ver os commits, tudo numa linha!
git config --global alias.ll "log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"


# ---- CONFIGURAÇÕES DO VIM (~/.vimrc) ----
# Salvaremos um arquivo de texto no seu diretório home chamado .vimrc
# "<<" indica que jogaremos o bloco de texto inteiro no arquivo.
cat << 'EOF' > ~/.vimrc
" =====================================================
" MEU PRIMEIRO .VIMRC - Setup do Curso
" 'aspas duplas' são usadas como comentário no Vimscript!
" =====================================================

" Exibe os números das linhas no canto esquerdo
set number

" Exibe o número da linha de forma relativa aonde o cursor está
" (Fundamental para dar saltos de linha eficientes)
set relativenumber

" Marca onde a busca casou as letras enquanto você digita
set incsearch

" Destaca as palavras da busca com cor de fundo
set hlsearch

" Desabilita aquela compatibilidade herdada horrível com o antigo VI.
" (Essencial para não bugar o Vim moderno com suas setas)
set nocompatible

" Ativa o processamento de cores decentes para o terminal
set termguicolors

" Auto-identação (quando der enter depois de chaves, ele alinha)
set smartindent
EOF

# ------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# Em vez de executar esse script inteiro, você pode copiar os
# pedaços individualmente. Se usarmos o comando `git ll` agora, 
# se tivéssemos commits, eles apareceriam perfeitamente alinhados na tela.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Verificar arquivos gerados (No git bash ou wsl):
# `cat ~/.gitconfig` - para ver os aliases gravados.
# `cat ~/.vimrc` - para garantir que os números de linha aparecerão quando vc abrir o Vim.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O Dev Junior digita os comandos por extenso todos os dias por anos e 
# abre o Vim "seco".
# O Dev Sénior preza pela automatização da rotina. Um 'git ll' configurado
# pode ser a diferença entre detectar rapidamente um rebasing corrompido ou 
# se perder num oceano com 'git log' feio sem cores.
# ------------------------------------------------------------

# ------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Seu log padrão tá tão sujo que você não enxerga para
# onde a branch tá indo e onde ocorreu o merge divergente. O que você usa?"
#
# Resposta Esperada: "Geralmente eu crio um alias customizado no meu gitconfig usando 
# git log --graph --oneline --all. Isso exibe fluxogramas de branch coloridos e 
# minimalistas no terminal para diagnosticar árvores divididas."
# ------------------------------------------------------------
