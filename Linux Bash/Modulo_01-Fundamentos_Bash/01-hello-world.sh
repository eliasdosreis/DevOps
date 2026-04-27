#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# O clássico primeiro passo na programação. Apresenta o
# comando 'echo' e a sintaxe básica de execução de scripts de Bash.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você ligou o microfone do palco ("echo") e disse a primeira
# frase para a plateia (terminal) testar o som.
# A partir de agora, o terminal vai responder aos seus comandos.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# "Echo" é um comando builtin da shellPOSIX e do GNU coreutils que 
# imprime o argumento do tipo string para a saída padrão (stdout = descritor de arquivo 1).
# ============================================================

# Boas Práticas - A regra de ouro dos Seniors
# Todo script profissional começa com as "flags de pânico" ativadas:
set -euo pipefail
# Significa que:
# -e : O script morre/para imediatamente se algum comando falhar (exit > 0)
# -u : O script morre se tentarmos usar uma variável que não existe
# -o pipefail: O erro num "A | B" não é engolido. Se 'A' falhar, todo o pipeline quebra.

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

# O comando básico para imprimir uma linha no terminal (inclui quebra de linha n no final)
echo "1. Hello, World!"

# A flag '-e' no comando echo ativa o interpretador de caracteres de escape.
# O '\n' cria uma quebra de linha, igual o <br> no HTML
# O '\t' dá um recuo (espaço como a tecla TAB)
echo -e "2. Bem Vindo ao Bash!\n\t- Pulou linha e deu tabulação!"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Salve este arquivo (ex: `01-hello-world.sh`)
# - No terminal digite `chmod +x 01-hello-world.sh` para dar permissão de se comportar como executável
# - Rode invocando o path local: `./01-hello-world.sh`
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro: Ao executar `./script`, você recebe `bash: ./script.sh: Permission denied`
#   Solução: `chmod +x script.sh` na pasta que você salvou.
# - Dúvida comum: Sem o `./` antes do script (rodar só `01-hello-world.sh`) aparece `command not found`
#   Motivo: O Linux não varre a pasta atual (`.`) procurando executáveis para evitar vírus. Ou você bota a pasta atual no `$PATH` ou diz o caminho explicitamente com `./`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O "Shebang" (#!/usr/bin/env bash) na primeira linha não é um comentário.
# O kernel do Linux (função execve) lê os dois primeiros bytes ("#!") que é o "Magic Number" atestando que é um texto executável.
# Ali informamos qual a linguagem do interpretador absoluto (bash ou python ou node).
# O Bash carrega e executa esse script sequencialmente, sem compilar antes.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual a diferença de `echo` e `printf` no Bash, e qual é mais seguro preferir em ambientes com dados não confiáveis?"
# Resposta Sênior: O `echo` tem comportamentos diferentes de flags (como -e ou -n) em distribuições de OS diferentes (ex: BSD/Mac vs GNU/Linux). Ademais, se os dados inseridos em um `echo "$dado"` começarem com '-e', o echo pensará tratar-se de argumento.
# Já o `printf` em uso de POSIX é muito mais robusto, aceitando modelagens exatas, ignorando traços em variáveis, tornando a injeção acidental virtualmente nula: `printf '%s\n' "$dado"`.
# ============================================================
