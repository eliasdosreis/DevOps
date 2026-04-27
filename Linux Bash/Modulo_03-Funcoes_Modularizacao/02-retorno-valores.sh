#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Mitos e Verdades sobre como "extrair" resultado de dentro
# de uma função. 'Return' limita a inteiros (Code RC), enquanto
# 'Echo' acarreta 'Command Substitution'.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Num restaurante, o "Chef" (Função) cozinha o bife. Como você pega esse bife?
# Se ele der "Return", tudo que ele consegue passar por debaixo da porta é um pequeno bilhete com um Número de 0 a 255 (geralmente de Erro ou Sucesso).
# Se ele der "Echo", ele empurra o prato inteiro pela janela pra você capturar e comer, e você precisa Botar as Duas Mãos `VAR=$(Chef)` na hora de receber.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O statement `return INT` em bash apenas assina e empurra um Exit Status Code.
# Um erro comum de programadores vindos do Python/Js é tentar rodar `return "Maria"`: em bash, strings retornarão 'numeric argument required'!
# Para funções ejetarem DATA BLOCKS para quem as chamou, elas devem despachar textos ao seu canal STDOUT (echo/printf) em par com uma avaliação `$()` do invocador.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Metodologias de Retorno ==="

# Metodo 1: Abordagem Boolean CI (Exit Status) - Usado SÓ pra Sucesso/Falha
validar_porta() {
    local PORTA="$1"
    # Somente simulação: a porta real precisa ser numérica e tal
    if [[ "$PORTA" -eq 80 ]]; then
        # Sucesso! '0' informa que deu certo sob padrao UNIX
        return 0
    else
        # Qualquer falha! '1' a '255'
        return 1
    fi
}

echo "1. Validando Porta de Sistema (Retorno Numérico Silencioso):"
# Repare a elegância! O Retorno booleano preenche o requisito condicional do 'IF'!
if validar_porta 80; then
    echo "   - [OK] A porta é de HTTP segura. Processo autorizado a continuar."
else
    echo "   - [FALHOU] Porta desconhecida."
fi

# Metodo 2: Abordagem de Captura (Textual Returns)
gerar_token_seguro() {
    # Em um processo sério chamariamos o /dev/urandom ou openssl
    local SENHA="TkN_abCd99_${RANDOM}"
    
    # ATENÇÃO ALUNO! Em vez de 'return', usamos 'echo'!
    # Tudo que esse bloco logar/escrever, será o retorno 'String / Textual' da função inteira.
    echo "$SENHA"
}

echo ""
echo "2. Gerando Senha em Módulo (Captura Txt)"
# Botamos o "Prato duplo" Cifrão Parênteses pra amparar a resposta echoada:
NOVA_KEY=$(gerar_token_seguro)

echo "   - A chave capturada por nós do cofre virtual da função foi: $NOVA_KEY"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O `return 0` desiste de rodar todo o resto da funcão na hora, pulando pra fora dela com código 0.
# - Uma variável var=$(func) pega tudo que foi printado. Cuidado pra não botar um 'echo "Acessando DB"' de LOG dentro dessa função, senão a senha sairá cagada: `Acessando DBTkN_abCd99`. E seu script vai estourar!
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu `return 0` mata meu loop For se a condição falhar. O script exita?
#   O que é: Return só encerra e descarrega a FUNÇÃO. O Script continuará executando lindamente a linha de baixo. 
#   Por outro lado: O comando interno 'exit X' dentro de uma função mata não apenas a função mas O SCRIPT INTEIRO instantaneamente, matando quem chamou!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe uma técnica Global Ref (Nameref) do Bash moderno (>4.3).
# Programadores maduros às vezes evitam empurrar Mega Arrays gigantes pelo `echo array[@] | awk` por gargalo de I/O em bash.
# Eles usam o `declare -n REF=$1` do nameref.
# A função recebe apenas o Nome FANTASMINHA da váriavel global do script, e modifica na raíz da memória sem fazer echo nenhum. É análogo brutal clássico e performático com os "Pointers in C++"!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado `NOME=$(gerar_nome)`, se minha função possuir `return 5` E também um `echo JOAO`... se eu der um echo `$?` pós a execução de atribuição... o que o system loga?"
# Resposta Sênior: Retornará 5! Mas o `NOME` guardará "JOAO".
# Funções em Command Substitution executam assincronamente em subshells; o Kernel coleta o STDOUT (buffer fd1 textual JOAO) assinalando no `$NOME`, E simultaneamente o POSIX bash retem o IPC RC status vindo do `return` nativo repassando-o magicamente para repousarr na macro ambiental global da sub-shell pai (`$?`).
# ============================================================
