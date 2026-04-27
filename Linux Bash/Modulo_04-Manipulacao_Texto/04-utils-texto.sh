#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Um "Round-up" dos utilitários fundamentais que, como legos do 
# UNIX, salvam vidas: sort (ordenação), wc (contagem), uniq,
# head e tail (leitura limpa).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Nós temos as facas pra cortar nosso "Bife":
# - 'head/tail': É olhar as 3 primeiras fotos (Head) ou as 3 últimas da estante(Tail) do álbum sem retirar da parede.
# - 'sort': Coloca o album em alfabético (ou números de tamanho de camisa).
# - 'uniq': Tira todas as fotos clonadas do álbum, enxugando.
# - 'wc' (Word Count): A balança, pesa ou conta linhas do album!
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Estes são os "Core Utilities" GNU Standard que aderem as leis da filosofia UNIX:
# "Write programs that do one thing and do it well, Write programs to handle text streams, because that is a universal interface".
# Eles recebem Standard Input via pipes '|', mutam a informação linearmente, e espelem de volta.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Canos Combinados (Pipes e Utilitarios de Texto) ==="

# Preparando nosso Input caótico 
LISTA="/tmp/lista_compras_$$.txt"

# Observe as redundâncias!
echo -e "Zebra\nMaçã\nMaçã\nAbacaxi\nMaçã\nBanana" > "$LISTA"

echo "1. Conteudo Original e Caótico:"
cat "$LISTA"

echo ""
echo "2. O 'sort' orgazinando em alfabético (A-Z) puro via PIPE:"
cat "$LISTA" | sort

echo ""
echo "3. Identificando e contando o CAOs (Agrupamento Sênior): sort + uniq -c"
# O comando uniq SÓ funciona se elementos idênticos estiverem juntos/subsequentes linha a linha!
# 'uniq -c' (count) printa ao lado numérico de vezes que viu a repetição aglutinada ocorrendo
cat "$LISTA" | sort | uniq -c

echo ""
echo "4. A Balança Global: Quantas Linhas o arquivo continha 'wc -l'?"
# lines (-l), words (-w), characters (-c)
wc -l < "$LISTA"

rm "$LISTA"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Ver logs do sistema atualizando/girando frenéticamente: `tail -f /var/log/syslog` (O 'f' eh follow e não deixa escorregar o prompt, grudando vivo lendo pra vc).
# - Obter os piores processos q pesam CPU (Estatística Invertida do topo):  `ps aux | sort -rnk 3 | head -n 5` (ordena reverso numérico na coluna 3 e mostra o top 5).
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu `cat $ARQ.csv | uniq` tá passando coisa repetida pelo funil! A linha "Carlos" apareceu duas vezes!
#   O que é: Você falhou a regra de ouro estrita do Uniq! 
#   A Engine de O(N) do uniq APENAS INSPECIONA 1 JANELA DE CIMA com A JANELA DE BAIXO Imediatos. Ele não se lembra de uma linha 8 linhas no passado!
#   Solução Sênior: Para que o uniq amasse perfeitamente a sua base inteirinha, vc OBRIGATORIAMENTE DEVE DAR `sort` NA FRENTE PIPANDO PRO UNIQ, pois o SORT vai botar identicos abraçados grudados! `sort meu.csv | uniq`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Pipe abusivo (Useless Use of Cat / UUOC Award)
# Quando mandamos: `cat arquivo.txt | grep "ERROR" | wc -l`.
# Acabamos de disparar 3 sub-processos do kernel de graça pra engasgar I/O do hd.
# O `cat` não lê stream process e nao faz nada de útil além de repassar aspas pra direita, o `grep` o substitui inteiramente podendo ejetar os arquivos nativamente abrindo o ponteiro do HD por ele mesmo!
# Sempre limpe a arquitetura! Fica assim o sênior: `grep "ERROR" arquivo.txt | wc -l`. Economizou o "pipe | " e a criação do PId clone do "cat"!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado um arquivo numérico que contêm números bagunçados stringificados "10", "2", "300", "5" nas linhas. Como é a bandeira no GNU Sort pra garantir avaliação correta? (Pois sem bandeira o sort dá alfabético e 10 será classificado colado ANTES de 2)."
# Resposta Sênior: O Default sort usa a ordem alfabética de byte (ordenação ascii) `[2]` é "maior alfabeticamente" que `[1]0`. Para forçar o binário a converter arrays temporárias e calcular base dez nativamente no pipeline, ativamos o Numeric Modifier (-n). O Comando imaculado de números seria `sort -n arquivo.txt`.
# ============================================================
