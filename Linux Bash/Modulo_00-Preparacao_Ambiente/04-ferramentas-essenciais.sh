#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta os comandos de sobrevivência e leitura de manuais
# essenciais para autossuficiência no terminal (man, help, which).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você comprou uma máquina de lavar e veio o manual junto.
# As vezes, você só quer um resumo ("como aperta o botão"), outras vezes,
# precisa de descrições detalhadas ("como funciona a bomba da válvula X",
# e onde fica a nota fiscal - o binário).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O sistema Linux é um repositório autoinstrutivo de utilitários
# documentados via Unix Programmer's Manual (man-pages) divididos em 9 seções.
# As "coreutils" do GNU e utilitários da shell provém embutidos (`builtins`)
# cujos manuais são invocados de forma nativa pela flag `--help` ou pelo `help`.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Sobrevivência Básica no Terminal ==="

# Como ler rápido (Resumo em tempo real)
echo "1. Resumo ágil com o '--help' (exemplo usando cp, comando que copia arquivos)"
# Exibe um bloco pequeno dizendo "Copia X para Y: flags disponíveis..."
# Redirecionamos a saída para só ver as primeiras 5 linhas
cp --help | head -n 5

# Como descobrir ONDE um programa mora (Onde está o executável no disco?)
echo ""
echo "2. Usar o 'which' para rastrear o binário real do comando 'cp':"
# O 'which' mapeia a variável de ambiente $PATH procurando o primeiro
# programa listado que bata com a string 'cp'
which cp

# Descobrir do que um comando é feito internamente.
echo ""
echo "3. Checar o tipo do comando usando 'type':"
type cat
type cd # 'cd' na verdade não é programa separado, é 'shell builtin'!

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - `man tar` (Lê O MANual da Bíblia sagrada do comando tar)
#   - Pressione 'q' para sair.
#   - Pressione '/' e digite 'extract' e dê ENTER para pesquisar dentro do manual.
# - `help cd` (Mostra socorro para comandos do BASH [builtins])
# - `which python3` (Descobre qual Python está rodando no ambiente atual)
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro: Ao executar `man docker`, você vê `No manual entry for docker`
#   O que é: Nem todo software moderno baixa ou instala a man-page por padrão.
#   O que fazer: Em utilitários de terceiros (Go, Node, Docker), use `docker --help`.
# - Problema de navegação: Não consigo subir ou descer no 'man'.
#   O que fazer: O `man` usa um leitor padrão chamado `less`. Use as setas, Espaço (pular página) e 'q' (Quit).
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe uma "ordem" secreta nas seções do 'man'.
# Sêniores sabem que seções importam.
# A "Seção 1" são comandos de usuário (`man 1 passwd` mostra como mudar "SUA" senha).
# A "Seção 5" são arquivos config (`man 5 passwd` explica a /etc/passwd tecnicamente).
# A "Seção 8" são Sysadmins (`man 8 useradd`).
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu usar 'which cd', por que ele não acha o comando no disco?"
# Resposta Sênior: O comando 'which' procura executáveis armazenados no sistema de arquivos varrendo as pastas do $PATH (`/usr/bin`, `/bin`). O `cd` manipula o estado do diretório atual da shell; logo, ele é um "shell builtin" intrínseco. Ele não é e não pode ser um processo externo (fork), por isso não é encontrado pelo 'which'. Para debugar, devemos usar 'type cd'.
# ============================================================
