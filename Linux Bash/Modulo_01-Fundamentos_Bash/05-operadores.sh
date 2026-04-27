#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Guia sobre operadores aritméticos (como fazer contas) 
# e operadores comuns de manipulação de string em Bash 
# nativo (sem utilitários externos).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você tem dois potes: um de farinha e um de arroz e quer pesar numa balança.
# Contas de matemática no bash são péssimas se não ativarmos "A Calculadora".
# Se você disser A+B na tela, o bash vai só escrever na parede: "Farina+Arroz". 
# Pra ele somar 10 + 20 tem que usar blocos matemáticos `$(( ... ))`.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Em bash as variáveis por padrão não têm tipo "Int". São todas character-arrays (strings).
# A Expansão Aritmética `(( expression ))` ou o comando obsoleto `expr` instruem o
# POSIX shell a usar o interpretador math interno (inteiros de 64 bits suportado apenas).
# Operações de Fração Decimal (floating-point) não têm suporte em Bash puro, devendo ser offloadadas para o `bc` e `awk`.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Matemática e Operadores Strings ==="

# =================
# MATEMÁTICA PURA
# =================
NUM_A=10
NUM_B=20

echo "1. Somando sem a sintaxe certa: NUM_A + NUM_B = $NUM_A + $NUM_B (O bash só cuspiu a string)"

# SINTAXE DE SOMA: os Duplos Parênteses "$(( conta ))"
SOMA=$(( NUM_A + NUM_B ))
SUB="$(( NUM_A - NUM_B ))"
MULT="$(( NUM_A * NUM_B ))"
DIV=$(( NUM_B / NUM_A ))

echo "2. Com a expansão certa:"
echo "- A soma foi: $SOMA "
echo "- A divisao foi: $DIV "

echo ""

# INCREMENTO
# O comando interno `(( ))` (sem o Cifrão) executa a função em vez de imprimir!
echo "3. O número A era $NUM_A :"
((NUM_A++))
echo "O número A subiu para $NUM_A (incremento)"

# =========================
# MANIPULAÇÃO STRING (SUBSTRING)
# =========================
echo ""
echo "=== Manipulações Strings Nativas Avançadas ==="

MEU_HOST="servidor_banco_master.prod.com.br"
# Sêniores economizam recursos omitindo `sed` e `awk` quando não precisam e usam sintaxe embutida!

# O operador "#" arranca da ESQUERDA PRA DIREITA. (Se o caractere tiver que arrancar o '_')
HOST_TRIMMED_DIR_1="${MEU_HOST#*_}"
# O operador '%' arranca ao contrário, DA DIREITA PRA ESQUERDA. (Pega só a palavra sem extensão da primeira bolinha vermelha '.prod' etc)
HOST_TRIMMED_ESQ_1="${MEU_HOST%%.*}" 

# Ponto a reter (O jogo de espelhos): '# e ##' tira esquerda. '% e %%' tira do final (da direita).
echo "4. Original: [$MEU_HOST]"
echo "- Se usar a hashtag (Cortando a ESQUERDA antes do primiro underscore): [$HOST_TRIMMED_DIR_1]"
echo "- Se usar o percent (Cortando A DIREITA tudo a pós o ponto dot): [$HOST_TRIMMED_ESQ_1]"

# Substituição massiva interna (O bash consegue fazer replaces como o ctrl+H do word!)
HOST_TROCA_LINUX="${MEU_HOST//banco/linux}"
echo "5. Deixando o nome do banco com nome de LINUX: $HOST_TROCA_LINUX"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - `$((5 + 5))` (A shell entende logo que é o número 10)
# - `$((10 % 3))` (O operador RESTO devolverá '1', porque sobra)
# - `${FRASE/velha/nova}` Substitui "velha" palavra da sua variável "FRASE" pela "nova" palavra.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao fazer `$(( 10 / 3 ))`, a resposta não foi ~3.333 foi "3"
#   O Bash não possui calculadora de Floats. Para lidar com números decimais precisos (moeda) o Sênior apela para o software 'bc'
#   A formula magica no terminal: `echo "scale=2; 10/3" | bc` -> Imprime maravilhosos 3.33.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe o famigerado operando de Atribuição Padrão / Expansão Condicional em Parâmetros: `${VAR:=}`.
# Às vezes os scripts recebem variáveis de fora `$USER`, mas se ele não passar, o script quebra.
# Em vez de fazer lógicas de [ se ta vazio entra e preenche ], use `${USER_API_KEY:=123padrao999}`.
# O bash substitui e preenche o espaço que devia ser preenchido caso seja nulo (o equal := assigna imediatamente na hora). Menos código, mais rápido.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou iterando sobre trilhões de logs de web-server pra ler e processar URLs (`http://foo/`), por que eu não devo usar pipeline pra outros utilitários clássicos de cortes dentro do meu script via \`echo \$URL | cut -d/ -f3\`?"
# Resposta Sênior: Chamar comandos binários externos `/usr/bin/cut` (fazer FORK/EXEC do kernel) dentro de um loop para cada linha consumiria 1000x mais ciclos de Processador (Context Switches) destruindo a CPU. 
# Devemos processá-lo unicamente no memory-state do processo principal do bash usando Parameter Expandions Nativos (as % e #). A shell fará on-the-fly de forma performática.
# ============================================================
