#!/bin/bash
# ==============================================================================
# Aula 01.02: Fundamentos do Shell - Manipulação de Arquivos (cp, mv, rm)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# No Windows você usa o Mouse. Você clica com o botão Direito e vai em 'Copiar', 
# 'Recortar', e joga na Lixeira.
# No Linux:
# - 'cp' (copy): É o seu Ctrl+C / Ctrl+V. Clona um arquivo de um lugar pra outro.
# - 'mv' (move): É o seu Recortar (Crtl+X). Mas também funciona como "Renomear".
# - 'rm' (remove): É a Lixeira. Mas com um detalhe aterrorizante: no Linux CLI
#   não existe lixeira. Apagou com 'rm', já era de forma irreversível.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Manipulação de arquivos via POSIX Coreutils.
# - cp: Executa syscalls para ler block devices e escrever novos no disco.
# - mv: Simplesmente renomeia o ponteiro do Inode (se estiver no mesmo sistema 
#   de arquivos/partição) - por isso mover um arquivo de 100GB é instantâneo, 
#   mas copiar demora.
# - rm: Remove o hard link (ponteiro) do arquivo (unlink()). Os dados brutos ainda 
#   ficarão lá no HD fisicamente até serem sobrescritos por zeros.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# NÃO EXECUTE este script como '.sh' de uma vez. Faça os comandos no terminal.

# touch cria um arquivo vazio do nada, perfeito para testar comandos neles
touch /tmp/meuarquivo.txt           # OBRIGATÓRIO: Criei o alvo.

# O comando copy (cp) precisa do que será copiado, e depois de para ONDE.
#   [ORIGEM]                          [DESTINO]
cp /tmp/meuarquivo.txt      /tmp/meuarquivo_copia.txt   # OBRIGATÓRIO: Copia.

# O move (mv) pega o arquivo, RECORTA ele (renomeia) e muda de lugar e nome.
#   [ORIGEM]                          [DESTINO COM OUTRO NOME]
mv /tmp/meuarquivo_copia.txt          /tmp/arquivonovo.txt

# Remove (rm). O Linux nunca pede "Tem certeza?". Ele assume que você sabe o 
# que tá fazendo (Philosophy Unix).
rm /tmp/arquivonovo.txt             # OBRIGATÓRIO: Apaga de vez.

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# E para construir árvores inteiras de pastas de 1 vez só?
# Um júnior faria isso:
# mkdir /opt/app
# cd /opt/app && mkdir logs
# cd logs && mkdir nginx
#
# O Sênior usa a flag `-p` (Parents/Caminho Intermediário):
mkdir -p /opt/app/logs/nginx        # SALVA-VIDAS: Se o caminho não existe, ele constrói todos os galhos da matriz na hora.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] rm -rf /minha_pasta/
# [O QUE FAZ] Apaga PASTAS (diretórios). O `rm` puro só debita arquivos normais.
#             Para deletar uma pasta com subpastas dentro, é preciso o flag:
#             -r (Recursive: apague filhas e netas) e -f (Force: não me pergunte nada).
# [ALERTA GERAL] ESSE COMANDO DERRUBA SERVIDORES SE USADO NO DIRETÓRIO RAIZ (/).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# ERROS COMUNS:
# - Ao tentar dar `cp` de uma pasta pra outra pasta, o bash acusa erro:
#   `cp: omitting directory`.
#   Por quê? Porque `cp` normal não copia pastas. Precisa do `cp -r`.
#
# - Ao tentar dar `rm` e diz `Permission denied`:
#   Você não tem permissão para apagar. Provavelmente é de outro usuário. (Veremos 
#   em módulos futuros como o administrador (sudo) pode desviar isso).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# O "mv" como Renomeador:
# Um Júnior às vezes fica catando comando "rename" no Linux... Ele não precisa 
# disso (tem, mas raramente usamos pra coisas simples). Se você move 
# `/etc/nginx/nginx.conf` pra `/etc/nginx/nginx.conf.bak`, você acabou de fazer um 
# backup de segurança antes de mexer numa Config de Produção.
# ISSO É LEI SÊNIOR: NUNCA, NUNCA mesmo edite um arquivo crítico 
# de serviço (como o .conf de banco dados) sem antes dar 
# um `cp arquivo arquivo.bkp` ou `arquivo.old`. Acredite em mim.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa fazer uma cópia de um diretório inteiro contendo os
# logs de Nginx de ontem do disco para um pendrive, mas ele quer que a permissão
# do proprietário antigo, timestamps de criação e permissões rwx sejam TODAS
# perfeitamente preservadas. Qualquer alteração invalida a auditoria de segurança."
#
# Resposta Esperada: "Usaria o comando `cp -a origem destino` (modo Archive).
# O parâmetro -a funciona como a união dos parâmetros -r (Recursivo) para copiar a
# pasta toda, e o mais importante: o parâmetro -p (Preserve), que mantém
# intactos CADA metadado, ownership, grupo (UID/GID) e carimbos de data/hora originais."
