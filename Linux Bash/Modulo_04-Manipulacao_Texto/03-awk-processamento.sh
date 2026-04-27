#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Traz a verdadeira linguagem AWK. Ao contrário de sed ou grep, 
# AWK é uma linguagem de programação paralela/avançada (criada 
# por Aho, Weinberger e Kernighan) focada em Data Mining tabular
# de logs separados por "Colunas" e "Headers", essencial ao DevOps.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O AWK é o seu "Microsoft Excel" automático.
# Imagine um relatório gigante separado por vírgulas ou espaços.
# Você precisa da Coluna 3 da linha que tiver "Carlos", o AWK vai lá 
# espetar cirurgicamente sua Coluna 3.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Gawk/Awk processa records e fields definidos por variáveis internas 
# FS (Field Separator) e RS (Record Separator) provendo C-like statements
# em pattern-action pairs. `$0` expõe a linha atual, e de `$1` a `$NF` os campos (NF = number of fields).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Bem-vindo a linguagem paralela AWK ==="

# Dados de simulação
ARQUIVO_MEMORIA="/tmp/memory_$$.txt"

# Criamos uma fake lista tabular formatada com espaços em colunas perfeitamente alinhadas
echo "USER     PID    CPU    MEM   COMANDO" > "$ARQUIVO_MEMORIA"
echo "root     1      0.1    0.1   systemd" >> "$ARQUIVO_MEMORIA"
echo "elias    944    12.4   5.5   chrome" >> "$ARQUIVO_MEMORIA"
echo "elias    221    0.0    0.2   bash" >> "$ARQUIVO_MEMORIA"

echo "1. Mostrando o arquivo original (Parece a porta do 'ps aux' ou do 'top'):"
cat "$ARQUIVO_MEMORIA"

echo ""
echo "2. O Poder Oculto de Seleção Específica (Cortador Laser):"
echo "- Pegar apenas a Coluna USER (\$1) e a Coluna MEMORIA (\$4):"
# Note que AWK precisa de chaves '{ }' puros. As aspas SIMPLES isolam pro shell nao engolir.
awk '{ print $1, $4 }' "$ARQUIVO_MEMORIA"

echo ""
echo "3. Combinando Forças (O 'Where' do banco de SQL no Awk):"
echo "- Extracao do nome de Processos (COMANDO = Col 5) DE USUARIOS root QUE CONSUMEM MENOS de 1.0 CPU"
# Sintaxe Regex 'Match' antes do Command Block! Pura genialidade dos anos 70!
awk '/root/ { print "Achei Processo: " $5 }' "$ARQUIVO_MEMORIA"

rm "$ARQUIVO_MEMORIA"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - `$0` Printa TODO o arquivo/Linha interira (Nao modificado).
# - O AWK trata multiplos espaços e Tabs automaticamente fundindo no seu "Field 1" pra garantir robustês.
# - Para lidar com o Arquivo CSV onde o separador não é o espaço puro mas sim a VÍRGULA, Mude o FS passando a flag "-F":
#   `awk -F ',' '{ print $2 }' planilha.csv`
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao fazer AWK puxando o \$1 dento de um `bash $VARIAVEL`, O awk ta vindo quebrado.
#   O que é: Você com ctz escreveu string de awk assim: `awk "{ print $1 }"` com Aspas duplas.
#   A shell expandiu o cifrao $1 na bash, e mandou para o Processo do AWK um comando vazio: `awk '{ print }'`. O AWK obedeceu imprimindo tudo (\$0 padrao). 
#   A Regra: Jamais, NUNCA expanda aspas duplas como wrapper em engine sed ou awk a menos que saiba precisamente injetar variaveis externas com a flag `-v`. Use always: `awk '{ ... }'`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Extrair dados finais `END` Block de calculo analítico com shellscript for-loop? Nunca!
# Sêniores e Engenheiros de SRE usam o bloco magico `{ END }` do awk.
# Exemplo: O HD (Servidor) gerou uma tabela num log de "100 Milhões" de transaçoes em GB de Ram, contendo numeros flutuantes. Vc quer  [SOMA DE TUDO] da coluna 2 ($2).
# CScript: `awk '{ sum += $2 } END { print sum }' master_file.log`.
# Velocidade C! Em memoria linear. Enquanto um Shellscript puro levaria 3 a 5 minutos calculando e crashando float points pela falta de bc nativo... O AWK cospe um 'Sum += $2' de logs giga na tela em 3 segundos porque ele é puro C e O(N).
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu tiver log estruturado mas as colunas flutuam e eu não sei se o COMANDO na última coluna está na Posição 5, ou 8, ou 9 (O NF é aleatório mas sei que é a ULTIMA informação). Como pegar o comando no fim da linha dinâmicamente com AWK se eu não sei indexar $4 vs $9?"
# Resposta Sênior: O AWK armazena internamente no decorrer da line o "Current number of fields" na Special Variable `NF`. 
# Para pegar sempre estritamente A ÚLTIMA COLUNA independente do tamanho (size count), basta usarmos pointer evaluado do numero de fields passando `$NF`. Para pegar a PENÚLTIMA, faremos calculo inline de pointer via `$(NF-1)`. `awk '{ print $NF }'`.
# ============================================================
