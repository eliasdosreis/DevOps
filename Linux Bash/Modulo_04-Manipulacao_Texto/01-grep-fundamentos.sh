#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Desvenda o 'grep' (Global Regular Expression Print). O 
# canivete suíço supremo para busca de padrões e palavras
# perdidas em mega logs ou textos corrompidos.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você comprou uma Bíblia de 1000 páginas e querachar a palavra "Amor".
# O 'grep' é um robô de leitura dinâmica impressionante: ele engole
# o livro em 1 segundo e cospe de volta APENAS E ESTRITAMENTE as páginas 
# que tinham a palavra lá, jogando fora todo o resto.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O grep, criado por Ken Thompson en 1973, filtra uma Input Stream
# ou File baseados em Match posicional de Expressão Regular Básica (BRE).
# A ferramenta emite (echo) somente o '\n' originário que conteve a string avaliada 'verdadeira'.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Filtragem Ouro: O mestre $ grep ==="

ARQUIVO_LOG="/tmp/acessos_$$.log"

# Gerando um Log Fake Dinâmico
echo '2026-03-29 10:00 [INFO] Sistema Iniciado Linux' > "$ARQUIVO_LOG"
echo '2026-03-29 10:01 [WARN] CPU atingiu 80% do Linux node' >> "$ARQUIVO_LOG"
echo '2026-03-29 10:05 [FATAL] Banco de Dados Parou' >> "$ARQUIVO_LOG"
echo '2026-03-29 10:06 [INFO] Limpando Memória' >> "$ARQUIVO_LOG"

echo "1. Pesquisando APENAS erros críticos (FATAL):"
# Sintaxe: grep 'palavra' 'arquivo'
grep 'FATAL' "$ARQUIVO_LOG"

echo ""
echo "2. Pesquisa Case Insentive (Ignorando se é Múysculo ou minúsculo) com -i:"
# Vai pegar a linha "Linux" mesmo que escrito "linux"
grep -i 'linux' "$ARQUIVO_LOG"

echo ""
echo "3. Pesquisando com INVERSÃO (Tudo menos o INFO) com -v:"
# O Inverter (V de inVert) joga no lixo o INFO e trás todo o resto! Extremo útil:
grep -v 'INFO' "$ARQUIVO_LOG"

echo ""
echo "4. Apenas contando OCORRÊNCIAS com -c (Conta linhas com match):"
COUNT=$(grep -c 'INFO' "$ARQUIVO_LOG")
echo "- Foram achadas [$COUNT] linhas informacionais."

rm "$ARQUIVO_LOG"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O Grep ama PIPES `|`. Exemplo: listar arquivos normais e achar 1 específico.
#   `ls -l /tmp | grep 'backup'`
# - Usa Expressão regular simples com pontinhos: `grep "B.nco"`.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao fazer grep no pipeline num script (ex: `ps | grep -v "grep"`), meu Bash Script morre misteriosamente `set -e`.
#   O que é: A maldição máxima do DevOps: O seu grep INVERTER ou o normal NÃO ACHOU RESULTADOS NENHUMS (O comando esbarrou numa linha sem o que ele queria). Como O Grep processou sem match, o código dele RC final é `Exit Code 1` (Failure pra ele)!
#   Solução Sênior: Se o grep for em Bash Scripts com `set -e`, o pipefail matará o script na hora. Para greps "opcionais" (pode não achar e ta ok) use fallback: `grep "palavra" || true`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O `grep -R` recursivo vs o comando `find` com exec. Qual o mais veloz?
# Antigamente mandávamos `find . -type f -exec grep -H 'string' {} \;`. Isso é letárgico, chamando 1 clone de process fork de `/bin/grep` pra CADA arquivo do disco!
# No GNU/grep moderno, o `grep -R 'string' .` (Recursive) ou `grep -rI` executa multithreads assustadoras em 'batch loading file descriptors', sendo 10 a 50x mais veloz consumindo 1 único processo base. Em sistemas Giga, um Senior prefere o binário otimizado `rg` (Ripgrep) escrito em Rust.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado que o grep avalia Padrões Regular Expressions. Se eu quiser fazer o grep procurar literalmente e estritamente o texto 'IP: 192.168.0.*' num log. O '*' ali vai explodir de regex? Como mitigamos e limpamos do grep sua 'inteligêngia'?"
# Resposta Sênior: Devemos usar as flags mágicas Fixas (Fixed-strings). Nos core-utils GNU seria a flag `-F` (`grep -F "IP: 192.168.0.*"`) ou chamar nativamente sua outra forma legada invocando `fgrep`. A flag F extirpa do grep (Desativa) inteiramente a Engine de Regex, o fazendo ler o Input char a char sem conversão do `*` iterador ou `|` pipe lógico. É mil vezes mais rápido (Usa Algoritmos de Aho-Corasick) onde Regex não é requerida e blindado a acidentes com caracters de escaping em injeções!
# ============================================================
