#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Desvenda o modelo clássico de permissões do Linux (UGO e o 
# padrão numérico de controle de acesso) e a forma atômica de 
# manipulação (+rwx).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Num arquivo (ou pasta), temos "etiquetas" dizendo quem pode fazer o que:
# - Ler (R = read)    = Quem pode "Lê o cardápio", mas não conserta;
# - Escrever (W = write) = Quem pode "Riscar o cardápio com caneta", alterar ou excluir itens;
# - Executar (X = execute) = Quem pode "Entrar na cozinha e preparar o prato" (rodar programas).
# A etiqueta diz as regras para: o "User" (Você, chef), o "Group" (garçons), e "Others" (clientes na rua).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# "Discretionary Access Control" (DAC), implementado historicamente pelo POSIX UNIX permissions,
# onde donos de arquivos (owner) especificam as permissões discretas do arquivo nos bits `rwx` (read, write, execute).
# O modelo octal usa a matemática bit-a-bit (4=r, 2=w, 1=x) somados por categoria (UGO: User, Group, Others).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Simulando Permissões na Fábrica ==="

# Criamos uma pasta teste temporária no sistema
PASTA_TESTE="/tmp/aula_perm_$$.dir"
mkdir -p "$PASTA_TESTE"
echo "1. Criado diretório temporário: $PASTA_TESTE"

# Criamos um arquivo sem permissões de execução (o padrão)
ARQUIVO_SECRETO="$PASTA_TESTE/secreto.txt"
echo "Minha senha" > "$ARQUIVO_SECRETO"
echo "2. Arquivo gravado."

echo ""
echo "3. Olhando os metadados (permissões originais) com ls -l:"
# -rw-rw-r-- (no ubuntu) indica que o User e o Group têm Read e Write, Others têm Read.
ls -l "$ARQUIVO_SECRETO"

# Como tornar um arquivo "executável" (como um script)
echo ""
echo "4. Adicionando permissão de execução usando o método literal (+x):"
chmod +x "$ARQUIVO_SECRETO"
ls -l "$ARQUIVO_SECRETO"

# Fechando o arquivo: Apenas o "Dono" (User) tem poderes totais com `600` (rw-------)
echo ""
echo "5. Restringindo severamente com código octal (Maneira Sênior): chmod 600"
# (4+2) = 6 = owner (rw)
# (0)   = 0 = group (nada)
# (0)   = 0 = others (nada)
chmod 600 "$ARQUIVO_SECRETO"
ls -l "$ARQUIVO_SECRETO"

# Limpeza e reset
rm -rf "$PASTA_TESTE"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - `chmod 755 script.sh` (Permite ler, gravar e executar pro dono; outros só leem e executam)
# - `chmod u+x,go-w script.sh` (Sintaxe atômica: adiciona execução pro dono, remove gravação pro grupo/outros)
# - `chown root:admin arquivo` (Muda o "Dono" para root e o "Grupo" para admin)
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro: Um script (.sh) dá o erro 'Permission denied' quando invocado como `./script.sh`
#   O que é: Faltando bit +x. Linux ignora extensões (.sh, .exe). Ele checa a letra 'x' e o conteúdo (shebang).
#   O que fazer: rode `chmod +x arquivo.sh`
# - Erro: A diretório (pasta) não deixa entrar (Permission denied) quando dá `cd pasta`, mesmo sendo dono dela!
#   O que é: Em diretórios, o bit de "Execução" (x) não significa "rodar arquivo", significa "Atravessar / Entrar (cd)". Se não tiver `+x`, o `cd` tranca.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Qual o padrão de criação? Por que quando fazemos "touch" ele nasce `644` e "mkdir" nasce `755`?
# E a máscara (umask)! O umask do sistema define que permissões DEVEM SER RETIRADAS imediatamente na criação.
# Uma `umask 022` tira W (02) dos grupos e O (02) de others. E os arquivos não nascem com x por segurança máxima.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "O que significa 'chmod 4755' onde há 4 dígitos?"
# Resposta Sênior: O primeiro dígito é relacionado ao Especial Permissions. 
# "4" representa o SUID (Set User ID). Um arquivo executável com SUID roda com as permissões do dono que criou o arquivo, e não de quem o chamou (o "ping" ou "passwd" usa isso debaixo dos panos para usar recursos root temporariamente).
# ============================================================
