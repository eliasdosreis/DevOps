#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta a diferença entre Terminal e Shell, e demonstra
# os comandos básicos de navegação e identificação do ambiente.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Pense no seu computador como uma grande fábrica:
# - O **Terminal** é a janela de vidro por onde você olha para dentro e o microfone que você usa para falar. Ele só mostra e recebe texto.
# - O **Shell** é o gerente da fábrica (chamado Bash) que escuta pelo microfone. Ele pega o que você diz (comandos), traduz para o chão de fábrica (Kernel) e devolve a resposta pelo vidro.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# - Terminal (Emulador de Terminal): Um programa de I/O (Input/Output) visual que passa caracteres para um processo PTY (pseudo-terminal).
# - Shell: Um interpretador de linha de comando (CLI) e linguagem de script (ex: bash, zsh, sh) que processa e executa os comandos em interações de kernel do sistema operacional.
# ============================================================

# Boa prática: configurações para garantir a quebra segura do script
set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

# Exibindo qual shell atual está em execução
# "$SHELL" é uma variável de ambiente predefinida no Linux.
echo "1. Meu Shell Padrão é: $SHELL"

# "echo $0" exibe o nome do comando ou shell que está interpretando o script no momento.
echo "2. Este script está sendo rodado pelo executável: $0"

# O comando 'type' é um built-in do bash que revela como um comando será interpretado (se é alias, função, binário do sistema ou keyword do shell).
echo "3. Identificando onde mora o comando 'ls':"
type ls

# O comando 'uname -a' retorna todas as informações do kernel e de arquitetura da máquina.
echo "4. Informações do sistema:"
uname -a

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - execute `./01-terminal-e-shell.sh`
# - O `echo "1..."` imprimirá por exemplo `/bin/bash`
# - O `type ls` mostrará que ls muitas vezes é um 'alias' (um atalho) para 'ls --color=auto'
# - O `uname -a` trará algo como 'Linux hostname 5.15.0... x86_64 GNU/Linux'
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro comum: `bash: ./01-terminal-e-shell.sh: Permission denied`
#   O que fazer: Você precisa dar permissão de execução. Rode: `chmod +x 01-terminal-e-shell.sh`
# - Erro comum: script quebra ao rodar com `sh 01-terminal-e-shell.sh`
#   O que fazer: O comando `sh` invoca um shell mais antigo (POSIX sh) e não o Bash. No Linux moderno, prefira executar sempre como `./script.sh` para usar o bash (declarado no shebang).
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Por que usamos `#!/usr/bin/env bash` e não `#!/bin/bash`?
# Sêniores sabem que em ambientes diferentes (macOS, FreeBSD, distribuições NixOS), o binário do Bash pode não morar estritamente em `/bin/`.
# O utilitário `env` vasculhará o $PATH do sistema procurando onde o bash foi instalado de verdade, garantindo portabilidade.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual a diferença entre um shell interativo (interactive/login shell) e não-interativo?"
# Resposta: Um login shell altera o ambiente carregando arquivos como `.bash_profile` ou `.profile`.
# Um shell interativo não-login (quando você abre uma nova aba no terminal) carrega `.bashrc`.
# Um shell não-interativo (rodando um script via cron ou ./script.sh) não carrega nenhum desses arquivos, não possuindo aliases a menos que explicitamente solicitados via BASH_ENV.
# ============================================================
