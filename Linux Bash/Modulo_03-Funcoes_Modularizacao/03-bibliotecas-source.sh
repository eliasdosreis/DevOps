#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Em vez de criarmos arquivos .sh gigantes, nós dividimos o 
# nosso código-fonte em "libs" (.lib.sh ou ext-funcs) para
# manter a "Separation of Concerns" na arquitetura do app.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Este arquivo é como um "Livro de Regras do RH".
# Você não executa o RH em si, você pega o Funcionário (seu script principal) e fala:
# "LÊ AS NORMAS DO LIVRO". Quando ele acaba de ler, o cérebro dele internalizou todas as leis que estavam no papel e lá fora ele as empregará!
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O comando interno `source` (ou o ponto `.`) do Bourne Again Shell carrega
# arquivos de instrução diretamente no memory-space originário em contexto linear corrente (current shell context).
# Ao processá-lo não são disparados sub-shells ou `forks()`. Variáveis, Arrays e Functions ali transcritas são instantaneamente acessíveis na árvore DOM/Global como se constassem declaradas in line.
# ============================================================

# IMPORTANTE: Em libs a gente geralmente não bota o `set -e`, 
# a gente deixa o script "Pai" declarar a regra de vida e morte dele.

# ============================================================
# 3. SCRIPT COMENTADO -- UMA BIBLIOTECA FAKE
# ============================================================

# Apenas funções brutas: sem chamada de execução (como uma classe importada num Python ou Java)

# Variável Centralizada!
# Todos os scripts PAI do nosso sistema que carregarem isso conhecerão o LOG_FILE.
LOG_FILE="/tmp/banco_central.log"

db_conectar() {
    local USER="${1:-padrao}"
    echo "[LIB DB] - Tentando bridge conectiva TCP ao Node Master com User $USER..."
    # Lógica de network ou psycopg2 etc
    sleep 1
    echo "[LIB DB] - Conexão efetuada."
    return 0
}

logger_info() {
    # Logging simples e unificado com Tiemstamps!
    local DATE_STAMP=$(date +"%Y-%m-%d %H:%M:%S")
    local MENSAGEM="$1"
    
    # Imprime no terminal E salva em arquivo, se quisesse... Usaremos só terminal.
    # printf "[INFO][%s] %s\n" "$DATE_STAMP" "$MENSAGEM"
    echo ">> (LIB) LOG REGISTRADO $DATE_STAMP: $MENSAGEM"
}

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - NOTA: Você não vai executar e mandar `./03-bibliotecas-source.sh`.
# - Ele não faz "nada". É um arquivo morto (dead pool template). Ele aguarda ser "Apendado/Carregado" no próximo script que faremos!
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao tentar usar o source num jenkins ele falha 'No such file':
#   O source exige o PATH completo até o txt.
#   A solução: Para bibliotecas atadas lado a lado da mesma pasta se precaver no bash usando:
#   `source "$(dirname "$0")/meu_lib.sh"` para carregar perfeitamente independente de com onde seu cronjob disparar e emular caminhos isolados!.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O `source` não é perigoso?
# Sim. É EXTREMAMENTE PERIGOSO injetar libs que você não auditou de repos git abertos / web, usando hooks remotos como `curl https://scripts... | source /dev/stdin`.
# Uma função no Bash injetada no Source sobrescreve sem dó qualquer outra que tivesse o MESMO nome na stack prévia no seu sistema principal sem avisar (Silent Overriding)!
# Sêniores nomeizam metodicamente os imports: O "db_conectar_" serve para 'namespacing' - Evitando que funções genéricas "conectar" engulam umas as outras dependendo do load order em repos.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "No Bourne Shell `sh` do Alpine clássico no Docker não existe o tal alias chamado de `source`. Como injetamos libs e templates nele obrigatoriamente?"
# Resposta Sênior: O POSIX Standard que definiu universalmente (o Bourne ancestral de 70) previu tal atitude através do operador Dot `. /caminho/do/file.sh`. 
# O comando em texto expresso `source /caminho` é o Sugar Sintax moderno não-padrão exclusivo de Bash/Ksh/Zsh (incompatível na crueza da imagem Alpine). Em scripts rigorosos portáveis de DevOps sempre se usa o dot import (O PONTO). Ponto+Espaço+Arquivo.
# ============================================================
