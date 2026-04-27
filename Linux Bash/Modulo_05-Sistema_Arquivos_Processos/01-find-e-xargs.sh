#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Descobre o poder inigualável da busca profunda no disco 
# cruzada com o 'xargs' para executar ações monstruosas em lote
# de maneira multi-thread.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O 'find' é um "Cão Farejador". Você dá uma blusa com um cheiro:
# - "Ache pra mim tudo que pesa exatos 5 Megabytes gerado na sexta."
# - E tudo que ele farejar, passe para o 'xargs' (O Faz-Tudo com metralhadora). 
# O xargs vai pegar os 10 mil itens que o cão achou, e vai atirar no lixo de uma só vez (Ou compactar de uma vez).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O `find` do POSIX executa varreduras de grafos de diretórios avaliando expressões booleanas contra inode metadata.
# O `xargs` lê streams separáveis oriundos do Stdin, e constrói + executa argumentos via `exec()` de processos empacotando-os num arranjo massivo único `argv[]`, mitigando o lentíssimo overhead do loop iterativo e o famoso erro de Kernel "Argument list too long".
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== O Cão de Caça Find e seu amigo Xargs ==="

PASTA_ESTUDO="/tmp/estudo_find_$$"
mkdir -p "$PASTA_ESTUDO"
touch "${PASTA_ESTUDO}/log_velho1.log" "${PASTA_ESTUDO}/log_novo2.log" "${PASTA_ESTUDO}/foto_boa.jpg"

echo "1. Busca Brutal (-type = f/d, -name = nome): Buscar apenas arquivos terminados em .log"
# O -type f forca exclusividade pra File. -name exige aspas sempre contra globbing bash.
find "$PASTA_ESTUDO" -type f -name "*.log"

echo ""
echo "2. O Paradigma do Encanamento de xargs (Operação Lote):"
echo "- Acharemos os dois logs velhos pelo Find, e vamos compactar ELES COM XARGS debaixo dos panos!"

# -print0 manda pro stream sem usar newline (\n), mas sim o byte Null do C (\0).
# O parceiro xargs com a flag -0 (lê até achar Null byte, unindo tudo). 
# Isso imuniza nossa busca contra qualquer arquivo bizarro Linux que tenha "Espaços" "Quebras" ou Caracteres chineses.
find "$PASTA_ESTUDO" -type f -name "*.log" -print0 | xargs -0 tar -cvzf "${PASTA_ESTUDO}/logs_compactados.tar.gz"

echo "   => Arquivo Tar gerado com o canhão! Veja:"
ls -l "${PASTA_ESTUDO}/"*.tar.gz

rm -rf "$PASTA_ESTUDO"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Achar arquivo q pesa ZERO bytes (vazio) e APAGAR pelo xargs: `find . -type f -empty | xargs rm`
# - Find por data: Arquivos modificados a mais de (+) 7 Dias em var/log. `find /var/log -mtime +7`
# - Find por tamanho: Achar monstrinhos maiores que 500 Megas: `find / -type f -size +500M`
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao tentar dar `rm ./*` em pasta de Backup cheia (1 milhão de logs) dá a tela preta 'Argument list too long'. O bash não apaga e trava!
#   O que é: O array Kernel Posix tem um HardLimit (ex: 2048 Megabytes de lista). Quando o bash expande o `./*` para os 2 milhoes de logs na variavel de array argv[], ela estoura a RAM permitida na subida em linguagem C e aborta a execução pra proteger  o kernel de StackOverflow (Buffer). 
#   A solução: `find . -type f -print0 | xargs -0 rm`. O xargs vai mastigar infinitos arquivos mas dividirá gentilmente o repasse pro 'rm' em lotes C-Compliants (ex: levas de 5 mil), sem estourar o limite num loop automatizado cego!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe uma flag oculta de ouro do xargs: O Multi-Thread assíncrono.
# O Comando `xargs -P N` instrui a engine C a dar Forquilha (Fork) de N processos irmãos distribuídos pelas vCPUS da máquina mãe do servidor AWS!
# Imagina q vc tem 20 videos MP4 pra passar o HandBrake converter. Se iterar `for` levará 10 Horas pois 1 de cada vez num core.
# Com Multi-Thread: `find . -name "*.mp4" -print0 | xargs -0 -P 4 -I {} handbrake -in {} -out {}.mkv`. O xargs abrirá as 4 trheads engolindo 4 conversões simultâneas usando 100% o octacore de seus clusters. Finalizando muito antes.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu posso executar o `-exec rm {} \;` nativamente contido na sintaxe originária do POSIX find... Que motivo real eu tenho e me obriga a usar o piping p/ 'xargs rm' no lugar dele?"
# Resposta Sênior: O `-exec ... \;` instancia a rotina Kernel de Fork Execve() EXATAMENTE UMA VEZ POR RESULTADO. Se o find leu 121 mil arquivos, ele evocará o binário '/usr/bin/rm' 121 MIL VEZES (Criando process pid -> Matando process Pid). Isso é letal para Syscalls de I/O em discos SAS ou CloudVolumes (IOPS goes brrr). O XARGS faz o batching. Ele roda EXATAMENTE 1 ÚNICA VEZ /bin/rm, e passa pra ele um arquivão de string contendo a fila de dezenas milhares atrás num único processo C! Economia brutal de CPU IOPS (Em media 80% mais rapido). Alternativamente, modernamente pode-se usar `-exec rm {} +` que emula o batch do xargs.
# ============================================================
