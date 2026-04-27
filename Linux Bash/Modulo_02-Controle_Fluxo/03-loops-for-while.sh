#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta e contrapõe a essência das iterações iterativas ('loops'): 
# "for" (Para coisas definídas) e "while / until" (Enquanto existir).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# - FOR Loop: Você tem uma lista de compras de 5 itens. Você checa "Para cada item da lista (banana, pão, queijo), coloque no carrinho". Quando os 5 acabam, você vai embora (loop encerra).
# - WHILE Loop: Você precisa esvaziar a água de um balde com um copo furado caindo muita chuva. "Gere copos. ENQUANTO o balde tiver água jogue copo fora." Você não sabe quantos copos vai levar... apenas testa quando o copo parar.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O `for` itera sobre listas ou globbing de parâmetros expansíveis e seletivos (lista em Bash).
# O `while` executa continuamente um conjunto de expressões de testes até que o condition command retorne non-zero (Falso).
# O `break` aborta o loop inteiro, o `continue` pula aquele ciclo e volta para o próximo if do iterador.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Repetições e Iterações ==="

echo "1. Loop FOR Clássico (Iterando sobre uma lista estática)"
# Note os espaços definindo cada item em bash.
SERVIDORES="web-01 app-backend-A bd-master"

# i=Variável index, a cada passe receberá um dos valores acima.
for servidor in $SERVIDORES; do
    echo "   - Atualizando pacotes no server: [$servidor]"
done

echo ""
echo "2. Loop FOR Numérico (no estilo da Linguagem C)"
# Ideal para contagens rápidas. O (()) não usa $ para ler as vars internas.
for (( x=1; x<=3; x++ )); do
    echo "   - Contagem regressiva de segurança C-Style... passo: $x"
done

echo ""
echo "3. Loop FOR usando File Globbing (Lendo discos)"
# Em vez de ls ou pipes! Forma limpa nativa!
PASTA="/var/tmp"
echo "   - Procurando 2 primeiros arquivos em $PASTA:"
contador=0
for arquivo in "$PASTA"/*; do
    # O arquivo expandiu para a string "var/tmp/xxx"
    # Adicionando um mecanismo de BREAK point
    if [[ $contador -ge 2 ]]; then
        break # Aborta todos os ciclos da frente
    fi
    echo "     - Verificando: $arquivo"
    ((contador++))
done

echo ""
echo "4. Loop WHILE (Enquanto o contador não estourar)"
MAXIMO=6
atual=5
while [[ "$atual" -lt "$MAXIMO" ]]; do
   echo "   - Retentativa (retry) de Conexão no Banco: tentativa $atual"
   ((atual++))
done

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Você declara uma lista crua: `"maça" "perâ" "banana"`.
# - Usa `for fruta in $LISTA; do echo "$fruta"; done`.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - O FOR está engolindo pastas com espaço: `for file in $(ls /tmp)` (Se a pasta tiver espaço se parte no meio!).
#   Sênior: NUNCA USAMOS um pipeline de processo num loop for, especialmente `ls`.
#   O Certo é usar GLOBBING do bash: `for file in /tmp/*; do echo "$file"; done`. A expansão do bash (Glob) garante e isola perfeitamente os espaços vazios e quebras nos arquivos!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um monstro engolidor de processamento disfarçado que novatos cometem: o "Cat para Loop".
# `cat arquivo.txt | while read LINHA; do echo $LINHA; done`
# Isso parece correto, não? Não.
# O PIPE (`|`) no bash FORÇA AUTOMATICAMENTE TODO O BLOCO DO `WHILE` A CORRER DENTRO DE UM "SUB-SHELL" DE SISTEMA!
# Se o while estiver no pipeline e salvar um estado temporário Numa Variável nova pra você usar depois que o loop terminar (ex: `TOTAL=10`), a hora q sai do bloco while e o Pipeline Morre, a SUA VARIÁVEL TOTAL MORREU com o pipe... ela sumirá sem rastro e seu script bugará!
# O Correto e Profissional (I/O Redir): `while read LINHA; do echo $LINHA; done < "arquivo.txt"`. O `<` joga do arquivo em disco direto pro FileDescritor na raiz do bash e você não perderá variáveis!!!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual a diferença de while e until?"
# Resposta Sênior: O `while` e o `until` agem como espelhos. O `while` roda seu bloco de código desde que a condição retorne EXIT ZERO (True / Comando funcionando). O `until` (até) continua processando SEU BLOCO ENQUANTO A CONDIÇÃO CONTINUAR FALHANDO DE DAR ZERO (>0 / Comando Erro ou Falso). Quando o comando no cabeçalho der True, o Until para..
# ============================================================
