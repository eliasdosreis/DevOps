#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta as estruturas de decisão clássicas: if, elif, else 
# e a elegante estrutura de múltipla escolha 'case'.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O "if" é o porteiro da boate. 
# - IF (Se) você tem VIP: Entra na área nobre.
# - ELIF (Senão, Se) você tem ingresso normal: Entra na pista.
# - ELSE (Senão, nenhum dos dois): Fica na fila da rua.
# O "case" é quando você tem 50 filas de guichê diferentes e você
# só lê o número da ficha pra direcionar, pra não perguntar 50 vezes.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O `if` no bash testa o "EXIT STATUS" (código de saída) de um comando.
# Se o comando retornar '0' (sucesso), executa o bloco 'then'.
# Qualquer outro valor (>0) é avaliado como "false" e avança pro else/elif.
# O `case` usa *Pattern Matching* (inclusive com globbing/regex) em strings
# e avisa quando bate (match).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Estruturas Condicionais ==="

# Definindo uma variável
IDADE=${1:-18} # Retira a idade passada por parâmetro (ou usa 18 padrão se não vier)

echo "1. Analisando a idade informada: $IDADE anos"

# IF Clássico com o comando especial de teste "[[ ]]"
if [[ "$IDADE" -lt 18 ]]; then
    # Se IDADE < (less than) 18
    echo "   - Status: Menor de idade. Bloquear acesso."
elif [[ "$IDADE" -ge 18 && "$IDADE" -lt 65 ]]; then
    # Senão, Se IDADE >= (greater equal) 18 E < 65
    echo "   - Status: Adulto. Acesso total garantido."
else
    # Se não atendeu nenhuma das anteriores
    echo "   - Status: Sênior. Acesso com prioridade garantido."
fi

# CASE (Switch Case)
echo ""
echo "2. Encaminhamento rápido por região (Região padrão: SP)"
REGIAO=${2:-"SP"}

# O 'case' lê a string "$REGIAO"
case "$REGIAO" in
    "SP" | "RJ" | "MG" | "ES")
        # Se for qualquer um desses, faz isso e para (;;)
        echo "   - Rota: Entrega Região Sudeste."
        ;;
    "BA" | "PE" | "CE" | "MA" | "RN" | "PB" | "AL" | "SE" | "PI")
        echo "   - Rota: Entrega Região Nordeste."
        ;;
    *)
        # O asterisco funciona como o "else" global (Match em qualquer outra coisa)
        echo "   - Rota: Rota Nacional Padrão."
        ;;
esac

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Rodando padrão: `./01-condicionais-if.sh`
# - Passando argumentos: `./01-condicionais-if.sh 70 BA` (Irá pro ELSE do If e pro NE da linha BA).
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - O `if` reclama `[: missing ]`
#   O que é: O comando antigo `[` (test do posix) precisa obrigatoriamente de ESPAÇOS antes do fechamento `]`. Ex: `[ $VAR = "x" ]`.
#   Sênior: Sempre largue a notação simples `[ ]` em favor do robusto bash ismo `[[ ]]`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O `if` NÃO testa variáveis lógicas "True" ou "False" por padrão como no Python (`if True:`).
# O Bash testa o STATUS CODE DE UM PROGRAMA de 0 a 255.
# Se você fizer `if grep "root" /etc/passwd; then`, ele funciona maravilhosamente bem.
# Pois o comando "grep" tenta achar a palavra. Se ele ACHA, a saída (exit code) do grep é Zero, o 'If' lê esse Zero invisivelmente nas costas, diz "OK!" e roda o Then. Retorno 1 é avaliado como "Falso".
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou programando um shell script pra CI/CD, por que os Sêniors preferem o short-circuit evaluation (`[ -f arquivo ] && rm arquivo`) ao invés do If Clássico de 4 linhas?"
# Resposta Sênior: Para operações atômicas single-line, operadores lógicos `&&` (AND) e `||` (OR) servem como controle de fluxo curto. O `&&` exige que a avaliação de comando à ESQUERDA seja ZERO para executar à DIREITA. O `||` é o reverso (só executa a direita se a esquerda falhar). É mais performático de processar no pipeline interno, e absurdamente limpo na leitura de Makefile ou YAMLs Docker.
# ============================================================
