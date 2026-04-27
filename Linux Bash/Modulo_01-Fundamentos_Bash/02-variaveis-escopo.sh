#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Demonstra o uso de variáveis em Bash — como armazenar e
# reutilizar valores, como definir constantes (readonly) e pegar 
# a saída de comandos (command substitution).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Pense em uma variável como uma "Etiqueta" colada numa tupperware:
# Você bota feijão (o valor), e escreve na tampa "ALMOCO" (O nome da variável).
# Amanhã quando for cozinhar, você não procura a comida, procura
# a "Variável ALMOCO" e "lê o conteúdo dela".
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Em Bash, variáveis são essencialmente strings dinâmicas na memória da shell, sensíveis à caixa (case-sensitive) 
# e sem tipagem estrita forte. Podem ser Locais, Globais, de Ambiente, Reservadas e Constantes.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Estudos de Variáveis em Bash ==="

# Atribuição Básica
# CUIDADO: NO BASH NUNCA TEM ESPAÇO ENTRE O NOME, O '=' E O VALOR.
NOME_APLICACAO="Monitor Web"   # Correto!
# NOME_APLICACAO = "Lixo"      # ERRADO! (Bash pensará que NOME é um comando, e '=' é o primeiro argumento)

# Variável Constante (Read-only)
readonly VERSAO="v1.0.5" # Uma vez definida, não pode ser alterada no script
# VERSAO="v2.0"          # Isso quebraria o script.

# Capturando saída de comandos para dentro da variável (Command Substitution)
# Isso abre um sub-shell (um filho do bash), roda o programa e cospe o texto da saída na tupperware:
USUARIO_LOGADO=$(whoami)
DATA_ATUAL=$(date +%Y-%m-%d)

echo "1. Iniciando o aplicativo $NOME_APLICACAO, $VERSAO"
echo "2. O script atual está sendo rodado pelo usuário: $USUARIO_LOGADO"
echo "3. Data da execução: $DATA_ATUAL"

echo ""

# Evitando "Colisão" textual! As chaves {} isolam a variável de letras em volta.
ARQUIVO="log_backup"

echo "4. Exemplo ruim: $ARQUIVO_velho (Ele tentará ler a váriavel 'ARQUIVO_velho' que é nula!)"
echo "5. Exemplo bom (chaves protetoras): ${ARQUIVO}_velho (Lê 'ARQUIVO' e gruda com '_velho')"

echo ""
echo "6. Variáveis de Ambiente Automáticas do Kernel/Bash"
echo "   Sua pasta pessoal é: $HOME"
echo "   Idioma e Encoding (Lang): $LANG"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Variáveis não têm o '$' (dólar) na HORA DE CRIAR. (Ex: IDADE="30")
# - Ao CHAMAR seu conteúdo para ler, sempre é precedido de '$' e entre aspas. (Ex: echo "$IDADE")
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Erro comum: Meu `echo "$MINHA_VAR"` retorna em branco. O que houve?
#   O que é: Você ou não a definiu ou colocou espaço no sinal de "=" (var = valor). O "set -u" pegará o erro na hora e fará o script parar explicitamente `unbound variable`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Por que exportar uma variável? "export VAR='abc'".
# Variáveis declaradas sem "export" morrem na memória assim que o script/terminal se fecha, e NÃO são repassadas a filhos ou outros programas engatilhados por eles.
# Quando usamos 'export', dizemos ao Bash para adicionar essa variável no Bloco Env de todos os Sub-Processos daquele terminal, como o Python, Node.js ou outro script que chamarmos ali.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual a diferença entre usar crase forte \`comando\` e cifrão-parêntese \$(comando) para criar Command Substitution na variável e por que preferimos um ao outro?"
# Resposta Sênior: A crase backtick `date` é sintaxe antiga do Bourne shell (sh). \$(date) é a re-implementação mais moderna do POSIX Bash.
# O problema principal do backtick é o aninhamento; se eu botar um crase dentro de outro (ex: crase de shell dentro de awk), dá conflito horrendo e requer "\" (escapes) feios. Como o \$() tem fechamento definido com parênteses, ele é auto-isolante e infinitamente aninhável.
# ============================================================
