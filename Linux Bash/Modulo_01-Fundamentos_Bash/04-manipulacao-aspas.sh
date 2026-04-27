#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Traz luz sobre a diferença crucial de expansões no Bash, 
# entre Single Quotes (Aspas Simples), Double Quotes (Duplas) e 
# unquoted text.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você tem um bilhete dizendo "Pagar $100 ao José".
# - Aspas Duplas (""): O banco avalia o valor do $. Ele converte o texto dizendo que o banco vai de fato realizar a alteração e olhar o bolso. "Tem dinâmica!"
# - Aspas Simples (''): É plastificado. Você emoldurou ele na parede. Nada pode mudar as letras lá dentro. Se tá escrito cifrão 1 0 0 será lido literal. Não tem matemática/variável.
# - Sem aspas: "Pagar" "100" "Jose" viram palavras soltas no vento, e o vento se chama "Word Splitting e File Globbing". Destrói arquivos sem querer.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Quoting / Escaping é o mecanismo nativo de Shell para remover significado especial 
# (meta-characters ou whitespace delimiters).
# As aspas duplas presevam o valor literal mas retém recursos de Expansão e Subsituição ($ e \).
# As aspas simples impedem toda e qualquer interpretação: tudo é literal.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Aspas e Interpretações em Bash ==="

DINHEIRO="100"

echo ""
echo "1. Aspas Duplas (Interpreta variáveis):"
# Variável avaliada, ele processou o '$' do prefixo como valor dinâmico.
echo "O valor investido é de $DINHEIRO reais."

echo ""
echo "2. Aspas Simples (NÃO Interpreta NADA. Puramente Literal):"
# Ele escreve 'cifrão D-I-N-H' - Não converte número.
echo 'O valor investido é de $DINHEIRO reais.'

echo ""
echo "3. Contra barra (Escape / Quoting Individual):"
# Anula o PODER da letra a sua frente. Anulamos que o Bash enxergasse as aspas duplas, 
# mas deixamos processar a variável! Imprimirá com as aspas visíveis.
echo "Eu quero citar o manual que diz: \"Use o Bash\" com a quantia \$DINHEIRO."

echo ""
echo "4. O perigo mortal de NÃO USAR ASPAS (Word Splitting e Globbing)"
# Suponha que seu arquivo chama: "Minha Foto.jpg" (com espaço)
NOVO_ARQUIVO="Minha Foto.jpg"
# touch $NOVO_ARQUIVO <- ERRADO! Isso não vai criar 1 arquivo. O espaço no meio 
# o Bash quebra no meio (Word Split). O 'touch' via duas palavras: `Minha` e `Foto.jpg`. Ele criaria dois arquivos avulsos.
# A forma correta e madura: Envelopar (Double Quotes).
touch "$NOVO_ARQUIVO"
echo "- Arquivo [$NOVO_ARQUIVO] criado com sucesso"
rm "$NOVO_ARQUIVO"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Você abre o terminal e digita `echo '$USER'`. A resposta será `$USER` literal.
# - Se você digita `echo "$USER"`, a resposta será verdadeira: `elias` ou `root`.
# - Digitar coisas como `ls *` sem aspas vai expandir todos os arquivos do Path.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Como o comando awk e grep funcionam quando tenho regex complicado e Bash quebrando tudo?
#   O que é: Muitos comandos filhos (processos como awk/sed/grep) têm seus próprios cifrões '$1, $k'
#   A solução: Para evitar que o interpretador da SHELL "destrua ou converta" coisas internamente antes de enviá-las ao AWK, use sempre ASPAS SIMPLES ao programar AWK ou SED (ex: awk '{ print $1 }' arquivo.txt). Se usasse aspas DUPLAS, o shell tentaria repassar algo num espaço vazio.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# "Por que o meu script falha ao apagar arquivos (rm $LISTA) quando um deles tem o carectere espaço no nome, como em Windows?"
# Sêniores sofrem calafrios ao ver `echo $VAR` sem aspas. Quando não há aspas, a expansão ($VAR) passa por dois processos invisíveis antes da execução pelo comando ("Word Split" guiado pela constante $IFS e "Filename Expansion" guiado pelo * globbing).
# Se um atacante definir o nome do arquivo da vítima como '*': uma execução de comando `rm $VAR` expandiria a variável em '*' e como o '*', sem aspas, evoca filenaming regex: ele varreria o disco todo pra você (Catastrofe C-Level!!).
# ASPAS DUPLAS NUNCA EXPANDEM FILES. Sempre escreva `rm -f "$VAR"`. Sempre.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se SingleQuotes ('') protegem até contra o escaping (\), e é 100% forte, como diabos um sistema Linux permite injetar aspas simples DE FATO dentro de uma string de aspas simples? Ex: 'Sant'Anna'"
# Resposta Sênior: É literalmente impossível (em bash padrão). A single-quote sempre encerra single-quote. Para a palavra Sant'Anna, você precisa FECHAR e reativar a mecânica adjacente ou colar com aspas duplas, algo horrendo como: `'Sant'\''Anna'`. O primeiro cara fecha o bloco. O `\'` escapa o apóstrofo, e o bloco `'Anna'` prossegue.
# ============================================================
