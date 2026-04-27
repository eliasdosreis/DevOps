#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Demostra a navegação básica e os conceitos do FHS (File 
# Hierarchy Standard) do Linux. Ajuda a entender onde as coisas
# estão guardadas no sistema operacional.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O disco rígido do Windows tem letras de disco: C:\ e D:\. São como condomínios fechados.
# O Linux tem uma "Árvore" que começa em uma única raiz (Root): `/`. 
# É como uma grande biblioteca onde `/` é a entrada principal.
# - `/bin` são os extintores e ferramentas de emergência.
# - `/home` são os armários pessoais de cada funcionário (usuários).
# - `/etc` é o escritório do gerente, contendo todas as regras do prédio (configurações).
# - `/var` é o almoxarifado vivo, que muda de tamanho constantemente (logs, bancos de dados).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O FHS (Filesystem Hierarchy Standard) define a estrutura principal de diretórios 
# em sistemas da família Unix/Linux e dita onde os arquivos devem ser alojados
# (ex: arquivos estáticos, dinâmicos, read-only vs writables).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Explorando o FHS ==="

# O diretório atual onde você está rodando o script: `pwd` (print working directory)
DIR_ATUAL=$(pwd)
echo "1. Você executou este script de dentro de: $DIR_ATUAL"

# Listando o que há no nível mais alto do sistema, o '/' raiz
echo ""
echo "2. O que tem na raiz '/' do seu sistema (ou emulação/WSL)?"
# "ls -ld" lista o diretório em si, o asterisco expande para mostrar o que há dentro
ls -ld /* | head -n 5 
echo "... e mais outros diretórios vitais."

# Analisando o diretório /etc: o painel de controle do sistema
echo ""
echo "3. Checando um arquivo vital de configuração em /etc (o arquivo passwd):"
# head mostra apenas o início do arquivo ('top' of the stream)
head -n 3 /etc/passwd

# Mostrando o TMP, pasta temporária
echo ""
echo "4. Criando e destruindo lixo em /tmp:"
ARQUIVO_TEMP="/tmp/meu_lixo_$$.txt" # $$ = ID do processo atual, ajuda a não conflitar nomes
echo "Dados importantes mas temporários" > "$ARQUIVO_TEMP"
echo "- Arquivo temporário criado em: $ARQUIVO_TEMP"
rm "$ARQUIVO_TEMP"
echo "- Deletado com sucesso."

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - `cd /` (Volta para a raiz do disco inteiro)
# - `cd ~` (Volta para o seu "home" - a sua pasta de usuário. Ex: /home/elias)
# - `ls -la` (Lista tudo, inclusive arquivos ocultos que começam com ponto, ex: .bashrc)
# - `cd -` (Volta para o diretório imediatamente anterior de onde você estava)
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro: `cd /root` -> `bash: cd: /root: Permission denied`
#   O que é: O FHS restringe. /root é a "home" do superusuário. Usuários comuns não entram na sala do CEO.
# - Como resolver: Use `sudo cd /root` (embora interativamente necessite de `sudo su -` ou `sudo -i`).
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Diferença Sênior: Por que temos `/bin` e `/usr/bin`?
# Eram divididos por limitações de espaço de disco nos anos 70 (o disco antigo de Ken Thompson lotou, ele precisou de outro disco, que montou no /usr).
# Hoje (desde o udev systemd), as distribuições modernas como RHEL/Fedora/Ubuntu fundiram os dois!
# `/bin` é muitas vezes apenas um atalho simbólico (`symlink`) para `/usr/bin`.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Seu disco raiz (/) está em 100% de uso, mas o comando `du -sh *` não mostra arquivos pesados. Onde o espaço pode estar sendo consumido no FHS?"
# Resposta Sênior: Pode estar em arquivos ocultos diretamente na raiz (ex: `/.Trash`), sob montagens obscurecidas, ou um grande arquivo de log apagado (`rm`) que ainda está sendo "segurado" por um processo zumbi / em execução em `/proc` ou `/var/log`.
# ============================================================
