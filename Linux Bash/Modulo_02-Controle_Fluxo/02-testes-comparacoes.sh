#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Mergulho profundo nas ferramentas de avaliações lógicas: strings,
# inteiros e a mágica de verificar condições e permissões de arquivos
# no disco (test operators).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você ligou para a transportadora e fez "Testes":
# - O caminhão EXISTE no pátio? (-e)
# - O caminhão ESTÁ VAZIO? (-z)
# - O motorista tem 30 anos (numérico: -eq) ou chama "João" (texto: ==)?
# Comandos de teste respondem "Sim" (0) ou "Não" (1).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Expressões de verificação do bash invocam um subsistema capaz de avaliar:
# 1) Metadados Unarios (Checar metadados de FileSystem: -f, -d, -L, -r, -w)
# 2) Strings (==, !=, >, <, -n "tamanho > 0", -z "string zero length")
# 3) Inteiros Posix (-eq, -ne, -lt, -le, -gt, -ge)
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Expressões de Teste e File Checks ==="

# Arquivo para testes
ARQUIVO_TESTE="/tmp/check_relatorio.txt"

echo "1. Checando se um arquivo EXISTE e SE é um diretório ou arquivo normal."
if [[ -e "$ARQUIVO_TESTE" ]]; then
    # -e checa EXISTÊNCIA global (qualquer coisa serve)
    echo "   - O arquivo '$ARQUIVO_TESTE' já existe, apagando."
    rm "$ARQUIVO_TESTE"
fi

# Cria o arquivo para os próximos testes
touch "$ARQUIVO_TESTE"

# -f checa se NÃO é uma pasta e NEM um symlink e SIM arquivo regular
if [[ -f "$ARQUIVO_TESTE" ]]; then
    echo "   - Verificação Validada: É um arquivo de texto/binário legitimo."
fi

echo ""
echo "2. Operações Aritméticas vs Texto e os Operadores Duplos"

TEXTO_A="Linux"
TEXTO_B="Linux"

VARIAVEL_NULA=""

# Checando Nulidade! Teste -z (Zero Length)
if [[ -z "$VARIAVEL_NULA" ]]; then
    echo "   - A variável testada está 100% vazia (null/zero chars)!"
fi

# Comparando String: Use '==' (dois is) e '!='
if [[ "$TEXTO_A" == "$TEXTO_B" ]]; then
    echo "   - Verificação String: Textos exatos!"
fi

# Comparando NUMEROS: Use os letreiros Mneumônicos!
NUM_X=100
NUM_Y=200

# -ne = Not Equal. -lt = Less Than.
if [[ "$NUM_X" -ne "$NUM_Y" && "$NUM_X" -lt "$NUM_Y" ]]; then
    echo "   - Verificação Numérica: $NUM_X é diferente e MENOR que $NUM_Y."
fi

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O bracket duplo `[[   ]]` não exige quoting rigoroso de palavras sem espaços nas bordas para funcionar de forma confiável em strings, pois anula o word splitting para avaliações!
# - O bracket simples `[   ]` é na verdade o programa estrito `/usr/bin/test` onde a shell invoca o POSIX test, não possuindo features de bash (como regex com =~).
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro comum: `if [[ 10 > 2 ]]; then` -> Bash acha que [10 é MENOR que 2] (falso negativo!).
#   O que é: Você usou operador de Texto (`>`) pra comparar Números! Na ordem alfabética "10" é menor/anterior a "2" (pois 1 vem antes de 2). 
#   Solução: Para matemática SEMPRE use `-gt` ou a expansão matemática `if (( 10 > 2 )); then`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um monstro na casca da Shell que sêniores amam usar no `[[ ]]`: O "Regex Match" nativo!
# É o operador especial `=~` !
# Ex: `[[ "mac-addr-01" =~ ^mac-.*[0-9]{2} ]]` e ele retorna zero/true instantaneamente.
# A diferença de rodar `grep` vs este `[[ ]]`? O bash executa na memória C. O `grep` precisa fazer um 'fork' / 'execve' de sub-processo caríssimo. Se for 1 chamada tanto faz, mas se for avaliar 1 milhão de logs num while, a regex da shell detona em performance bruta em cima do grep.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu não sei se o usuário colocou o file.sh num symlink ou de fato no script, existe algo nativo pra testar e seguir se for um symlink?"
# Resposta Sênior: Sim. O modificador "-L" ou o "-h" garantem um 'True' (0) apenas e unicamente caso o alvo seja um atalho simbólico no Filesystem (Soft Link). `-f` para regular file, `-d` para diretório.
# ============================================================

rm "$ARQUIVO_TESTE"
