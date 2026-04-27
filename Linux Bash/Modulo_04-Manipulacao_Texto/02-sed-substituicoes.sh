#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Mostra o magico The Stream Editor (sed). Um programa Turing
# complete que não só acha, mas substitui e reescreve textos
# em pipelines de maneira avassaladora `s/VELHO/NOVO/g`.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você tem uma forma de redigir um contrato. Onde aparecia "João" você
# queria "Marcos". Você dá "CTRL+H" (Find and Replace) no Word, e preenche
# os campos. O 'sed' é o seu Ctrl+H dentro do ambiente de tela preta CLI só
# que não precisa nem abrir do arquivo, e ele pode fazer 1000 ctrl-h em 1 seg.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# `sed` (Stream Editor) é uma ferramenta Posix de transformação de fluxo non-interactive.
# Ele roda na arquitetura 'Read/Execute Cycle': Lê 1 linha no pattern space (memoria de buffer),
# executa comandos definidos por script sed nele, e expele (printf) no Standard Output o estado atual iterativamente.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== SED: The Stream Editor ==="

DADOS="Eu sempre digo que o Windows eh lindo e programar pra Windows eh facil."

echo "1. A frase original era:"
echo "$DADOS"

echo ""
echo "2. SED Clássico: O Reemplaze Básico (Substitui apenas o primeiro q ele achar)"
# s = Substituir
# / / / = Delimitadores de corte do espaço.
echo "$DADOS" | sed 's/Windows/Linux/'

echo ""
echo "3. SED Global: O Reemplaze Supremo (-g) - Vai subsituir TODAS presenças da linha!"
# g = Global modifier (Sem o 'g', o sed só atua na primeira ocorrência [match num 1] da linha).
echo "$DADOS" | sed 's/Windows/Linux/g'

echo ""
echo "4. Operador Deletador (O SED agindo como GREP INVERTIDO)"
# d = Deletar a linha. "/lindo/" = Match pattern regex p encontrar.
# Se a linha tiver "lindo", o sed mata ela inteira sem ecos.
echo "$DADOS" | sed '/lindo/d' || true # O Fallback empty pq o echo ali sumirá.

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Pra alterar um arquivo de verdade, o SED exige os modificadores "-i"
#   `sed -i 's/IP_VELHO/127.0.0.1/g' config.env`  (-i é In-Place Edit / Edição Destrutiva).
# - ATENÇÃO: Se não user `-i`, ele só testa e Bota O TEXTO RESULTANTE DE VOLTA NA TELA, e a config no disco rígido não se alterou.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu `sed -i` no MacOS dá o erro 'invalid command code .'!
#   O BSD sed (No Mac/FreeBsd) do Darwin e do iOS não são o GNU sed do Linux Debian.
#   NO MAC/BSD: O Modifier `-i` Pede OBRIGATORIAMENTE que você prove um sufixo vazio pra backup com aspas duplas, caso sim quer apagar sem rastros!
#   Solução pra rodar no OSX/MAC: `sed -i '' 's/X/Y/g' text.txt`. Em Linux Ubuntu o GNU é perdoador e não requer o `''` no `-i`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe o maldito "Slash Hell" (O inferno das Barras).
# Se você for dar um ctrl-h usando o sed pra mudar `/usr/bin/bash` para `/bin/sh` você criaria o caos dos 'escaping hells' pois o seu path tem o Carectere Barra (/) que tmb é o delimiter universal do comando SED:
# Sintaxe amaldiçoada e ilegível: `sed 's/\/usr\/bin\/bash/\/bin\/sh/g' `.
# Sêniores sabem a MAGIA PURA: O Delimitador na sintaxe `s/A/B/` do sed pode ser literalmente *QUALQUER* caracter gráfico que sua alma quiser desde q não esteja na string! 
# Use o Pipe ou HashTrick: `sed 's|/usr/bin/bash|/bin/sh|g'` ou `sed 's#/usr/bin/bash#/bin/sh#g'`. Elegante e 100% legível e Posix Complaint.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu tiver um yaml/config gigantesco e eu precisar substituir 'DEBUG=false' por 'DEBUG=true' APENAS DA LINHA 10 ATÉ A LINHA 25 do arquivo... Dá pra fazer um Replace só em Range Específico ignorando as ocorrências do resto do arquivo?"
# Resposta Sênior: Perfeitamente possivel usando Range Address Pointers do programa `sed`.
# A sintaxe antes da instrução 's' ou 'd' pode carregar os Endereçamentos: `sed '10,25s/DEBUG=false/DEBUG=true/g' log.yaml` - O Bash mandará o sed dar bypass/Ignorar do 1 até o 9 e do 26 pra baixo, aplicando in-place os regexes somente no core delimitado numérico.
# ============================================================
