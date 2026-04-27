#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta como rastrearmos o verdadeiro "Status de Execução" das
# chamadas (O "Exit Code" - RC), e o quão importante isso é em 
# DevOps para controle de sucesso vs. falhas em fluxos de trabalho.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você comprou uma pizza por iFood. O App (Sistema Operacional O.S.) faz um pedido.
# A pizzaria (Seu script / Comando) executa o trampo.
# Quando o motoboy entrega, a pizzaria APITA no App um "Código Numérico Final".
# Se o mototboy voltar com um número "0", é alegria = Sucesso Total.
# Se voltar com o número "1", Erro genérico/Acabou farinha.
# Se voltar com "127", "Ops, A Pizzaria que você chamou faliu/não existe".
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O Retorno ou `Exit Code` (Return Code / RC) é o método primário do Unix 
# para IPC (Inter-Process Communication) após finalização de fork ou kernel signal.
# Armazenado na variável especial mágica de ambiente de shell `$?`.
# Valores variam inteiros entre 0 (Sucesso estrito POSIX) e 1 a 255 (Falha arbitrária ou Mapeada).
# ============================================================

# AVISO: Não usaremos o set -e AQUI, senão o script quebra (morre) quando a gente tentar testar erro.
# set -e -> Retirado propositalmente!
set -uo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Tratamento de Exit Codes (Return Codes) ==="

echo "1. Simulando um comando que dá certo (ls na propria pasta):"
ls -ld . > /dev/null # joga lixo no null pra n sujar a tela
CODIGO_COMANDO_OK=$? 
echo "O Símbolo cifrão+interrogação (\$?) do bash me reportou que o comando anterior deu: $CODIGO_COMANDO_OK (Sucesso!)"

echo ""

echo "2. Simulando um comando fatal/erro:"
# Tentando listar um arquivo que não existe e jogando stderr dele(2>) para lixo
ls /arquivo/inventado/da/minha_cabeca_999.txt 2> /dev/null
CODIGO_COMANDO_ERRO=$?
echo "O Símbolo informou sobre a listagem falsa: $CODIGO_COMANDO_ERRO"

echo ""

echo "3. Usando Exit Codes explicitamente para o seu prório script devolver o valor ao Jenkins/Sistema Operacional"
echo "Imagine que checamos internet e caiu."
# if [[ ! ... rede ... ]]
echo "   - [SIMULACÃO]: Detectado Erro Fatal! Internet Corrompida."
echo "   - Abortando programa do Shell e avisando com o 'Exit Code 88'."

# ============================================================
# IMPORTANTE
# Descomente a linha `exit 88` para ver! Nós não executamos agora senão ele encerra este script atual antes do resto kkk
# exit 88 
# ============================================================

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Tudo o que você digita entra num code:
#   Rode: `grep "root" /etc/passwd`
#   Rode em seguida: `echo $?`. Dará O Zero (Sucesso).
#   Rode com uma palavra inventadassa: `grep "humbug131" /etc/passwd`
#   Rode: `echo $?`. O grep devolveu 1. O código sabe que o grep não achou por causa disso.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - O que acontece se meu script tiver 20 comandos errados mas os dois ultimos comandos derem 100% certo e o script chegar no final?
#   O Seu script jogará CÓDIGO ZERO PRO LINUX. O sistema operacional só olha o Return Code DA ÚLTIMA LINHA LIDA pelo bash de um script antes da morte do seu FileDescritor. Se vc escondeu os erros em cima com gambiarra, e as linhas finais do bash deram certo, CI/CD reporta: "Deu Sucesso!" enquanto o banco de dados era deletado 5 linhas antes.
#   Por isso usamos no cabeçalho do arquivo SEMPRE "set -e" em prod! "Errou ali, morre de uma vez sem rodar o resto".
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O Exit 130 ou o 137 num container Docker (OOC/OOM)?
# O Bash e o kernel usam range extendido (128+) para assinalar a fatalidade por "SINAIS KERNEL (Signals)".
# O cálculo pra mapear exitcodes com Signal id's de interrupções de hardware (ex: `kill -9` que mapeia pro sinal SIGKILL / id 9) é: 128 + id do kill sinal = Exit Code 137 !
# Então se vc ver o script sair como "137" no jenkins, saiba: O linux matou ('kill -9' processo OOM / Ram Lotada).
# Se você der um "CTRL+C" num comando, o Ctrl+C levanta o SIGINT (sinal id 2). 128 + 2 = RC 130!  O processo do loop que parou no Crtl C exita com exit code 130 de quebra.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou executando 4 pipes conectando 4 sub-comandos: `cat logs.txt | grep WARN | sort | tail -n 5`. E o cat lá do início não acha o 'logs.txt' (Arquivo faltoso), mas os do final terminam normalmente sem tela. Qual é o exit code que a variável `$?` registrará na linha debaixo?"
# Resposta Sênior: O bash por padrão retornará ZERO! O $? só herda, e sempre irá se fixar, no Return Code DO ÚLTIMO ELEMENTO DO PIPELINE DE UM COMANDO, que ali é o comando "tail -n 5". Como o tail executou num stream limpo e ele mesmo não quebrou/não pifou, ele deu sucesso!. Para o BASH registrar o erro em qualquer canal esquerdo do pipeline sem sumir/amassar o exit status anterior e expilar a excessão pro `$?`, você é obrigado a declarar o header clássico `# set -o pipefail`.
# ============================================================
