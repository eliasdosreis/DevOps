#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Esclarece os obscuros descritores de arquivo StdOut (1), StdErr (2) 
# e Stdin (0) e a manipulação com Redireções como `>`, `>>` e 
# o místico Black Hole Linuxístico `/dev/null`. E unificará TEEs!
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Desviando as águas do Encanamento Central Linux (IO streams);
# A fonte do esguicho do seu script (Água saindo):
# - FD 1 (StdOut) - Água Doce. Os textos felizes de prints.
# - FD 2 (StdErr) - Água Esgoto. Textos de erros vermelhos.
# Toda a água vai p RALO Central: que é a TELA Preta do Terminal do Usuário.
# Nós podemos botar encanamentos `>`, pra água doce ou a bosta ir p lugares diferente (e.g. arquivo log)!
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O Shell manipula Redirection Operators (`>`, `<`, `>>`, `|`) sobre I/O File Descriptors 
# definidos do process context (FD 0 Input Default (KB), FD 1 Output Default (TTY/Screen), FD 2 Error Default (TTY)).
# Redirecionamentos agem criando ou sobrescrevendo FD-maps (descritores) antes mesmo de comandos internos C (fork, exec) prosseguirem no child env.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== A Magia do Encanador (Redirecionamento Streams) ==="

ARQ_LOG="/tmp/pipeline_$$.log"

echo "1. Escrevendo DESTRUTIVO (>), reescreve arquivo inteiro descartando anterior:"
# StdOut natural (o Comando Echo na fd1) tá sendo entubado e desviado pra um txt vazio em vez de ver na tela tty.
echo "Primeira Linha Nova na agua..." > "$ARQ_LOG"

echo "2. Escrevendo APENDADO (++ >>), insere abaixo de tudo da ultima gravada:"
echo "Adenda (Append) da agua limpa sem quebrar a 1." >> "$ARQ_LOG"

echo "3. CÓDIGOS E SILENCIADORES! (O desvio do Lixo 2)!"
# Se fizesse apenas `ls /arquivoErrado > fd1log.txt`. A agua do erro caia na SUA TELA E ENCHIA SEU OLHO.
# Pois a shell ia jogar pro log do fd1 arquivo, mas a água de esgoto (O erro 2 - Stderr) por padrao desvia a tela tty.
# Silenciar é domar a bica do erro "2>" pro bueiro sem fundo do linux Kernel (O Blackhole Void /dev/null)!
ls /arquivo_invesntado_2028 2> /dev/null || true
echo "   - Cuidado tomado. Todo Erro (2) foi absorvido e sugrgado no bit bucket eterno fd null invisivel."

echo ""
echo "4. Duplicador Paralelo da Tubulação (Tee Program)!"
# No log normal `echo abc > arquivo`. A agua foi p arquivo e Sume da vista e tela! Nunca mais!
# No Tee Program Command (Em forma formato em T/Duplicador Tê da Tubulacao Esgoto da loja de construcao): A tubulacao divide o pipe pela metade em tempo real! Ele Loga o texto simultaneamente TTY Display Standard E envia cópia fantasma via ram fd pra escrita em disco. 2 pombos numa cajada de stream.
echo "Relatorio TEE" | tee -a "$ARQ_LOG" > /dev/null # jogamos O print tela pro nulo tmb p teste isolado.

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Encanar TUDO (Agua limpa 1 e Erros Sujos 2) em um SÓ Log misturado bruto de Jenkins:
#   `comando_script >> master.log 2>&1` ->  Este ampresand (&1) instrui o shell a "Caminhe toda sujeira vindo da porta do erro '2', de volta pra misturar redirecionar pra msm porta de ID [1] atual que a gente definiu atrás." Tudo será logado misto maravilhosamente bem. Em modern posix tmb pode ser `&> log`.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao fazer pipagem em scripts que pedem sudo permissão pra gravar log `/etc` o bash diz Permission Error access denied root!
#   `sudo echo "IP" >> /etc/hosts` dá pau!!! Oxi?
#   O que é: O Comando Sudo da frente protege e roda APENAS "O binário do Echo" coberto por credencial alta de privilégio root. O operador de desvio `>>` É OPERADO PELO SEU BASH DA CARROCERIA (Elias User), o redirecionador de kernel da Shell Pai tenta abrir `/etc` (sendo q O Desviador do Pai não herdou seu sudo pontual echo). Ele é recusado!
#   Solução Sênior Braba de TEE pipeline trick with privs : `echo "IP" | sudo tee -a /etc/hosts >/dev/null`. O comando `bash local echo` canaliza por pipe pro sub-programa Binário `tee`, que está sendo escalado sim pelo binário `sudo`, e esse utilitario vai possuir sim a permissao do fs mount root pra dar append num file.  
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Quando os Discos Físicos AWS EFS Ebs lotam subitamente em 100% de inodes Space Left ... E o desenvolvedor corre lá, e digita `rm gigantesco.log` achando que limpou... Mas para surpresa dele o Disco continuou consumindo 100% espaco... A Cifra não caiu nd!! Pq q?
# Arquivos de log removidos fisicamente por `rm` NÃO devolvem IO e Espaço pro SO /dev se houverem descritores de processos Fd abertos escrevendo neles vivos! Se um Tomcat Server/Docker FD Stream Pipeline estava "segurando" aberto a valvula do "2>> log", e o sysadmin deletou o target... o Inode sumiu do `ls` na tela visualmente da árvore DOM (Delete Reference), mas o FD Pointer do kernel manteve o Raw Volume Space ALOCADO na memoria física do HD atá a reinicialização e crash do tomcat pq ele ta "vomitando stream num link ghost".
# Correto Sr DevOps Sysadmin Approach Clear Logs Online Without downtime Process: NUNCA mande o rm. Delete redirecionando e engasgando Null ao pipe stream live file: ZERE truncando com zero bytes na raiz mantendo pointer e liberando C-Memória RAM via: `> application_tom.log` ou `cat /dev/null > log` ou `truncate -s 0 ...`. A Válvula de esvaziar não crashera NGINX pointers. 
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou analisando streams por pipe pra awk como faço e desejo ver oque há no Meio (Between). Oq eu estava recebendo via STDIN pra minha tool de parser awk durante o fluxo de comandos de 11 pipes que nao estao chegando como deviam?"
# Resposta Sênior: Para debugar interceptações de middle pipeline sem abortar redireções de processos e sem comprometer execuções mutaveis e perdas de buffers IPC; a Tooling Standard GNU dispões do comando TEE como spy-mid layer.
# Injetamos o "Tee" e redirecionanmos o dump ram clone dele pra interceptação temporária `/dev/tty` master control console ou `/tmp` ( `curl | processA_string | tee /dev/tty | awk ... > final`. O dump vivo aparecerá printado isoladamente na nossa TTY corrente mas nao perderá os tráfegos assíncronos que ele passa pro awk!
# ============================================================

rm "$ARQ_LOG"
