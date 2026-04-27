#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Define a anatomia corporativa de uma Função em Bash, ensinando
# sobre parâmetros isolados ($1 da função) e o uso OBRIGATÓRIO
# do modificador `local` para escopo de variáveis.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Uma Função é como você criar o "Botão do Liquidificador".
# Ao invés de você dizer: "Ligue, gire 50x por segundo, amasse, pare" toda hora...
# Você bota isso numa caixa preta chamada "bater_suco()" e só aperta o botão.
# Ele recebe "1 Laranja" ($1) e resolve lá dentro.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Funções em POSIX Shell são blocos lógicos nomeados (named blocks) que correm
# inteiramente no Memory Space do processo pai (current shell).
# Diferente de scripts externos, que chamam o `execve` gerando um PID novo isolado,
# a função compartilha todas as globais do script nativamente, o que exige cuidados.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Funções e Escopo ==="

# Global Scope Var
USARIO_GERAL="Roberto"

# A sintaxe POSIX padrão não usa a palavra 'function'. O Sênior usa NOME().
criar_usuario() {
    # ----------------------------------------------------
    # TODO ARGUMENTO (1,2) AQUI DENTRO PERTENCE À FUNÇÃO!
    # Os argumentos do script pai "saem" de linha enquanto
    # estamos aqui dentro. $1 não é mais o do script.
    # ----------------------------------------------------
    
    # BOA PRÁTICA SUPREMA: NUNCA crie variáveis numa função sem a palavra 'local'.
    local NOME_NOVO="${1:-SemNome}"
    local SETOR="${2:-SemSetor}"
    
    # Se omitirmos 'local', a variável vazaria pro escopo Global!
    USARIO_GERAL="Alterado_Invisivelmente!" # Alterando uma variável global lá de fora
    
    echo "   [⚙️ Func]: Cadastrando $NOME_NOVO no setor $SETOR..."
}

echo "1. Olhando pro usuário externo atual: $USARIO_GERAL"
echo "2. Invocando a função 2 vezes:"

# Chamamos a função passando argumentos pelo espaço (assim como num CLI app)
criar_usuario "Maria" "Vendas"
criar_usuario "José" "TI"

echo "3. Olhando a variável Global depois do botão ter sido apertado:"
echo "   $USARIO_GERAL <- Ela foi sobreescrita porque a função manipulou a global!"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O Bloco `minha_func() { ... }` APENAS DECLARA. Não roda nada.
# - A execução real acontece quando no futuro você chama `minha_func arg1 arg2`.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao rodar dá `command not found` para minha função.
#   O que é: Diferente de Go/Python, O Bash lê proceduralmente DE CIMA PRA BAIXO. Se você chamar `fazer_backup` na linha 10, mas a função `fazer_backup()` estiver declarada na linha 80, o Shell não a conhece ainda! Declare SEMPRE as funções no topo do arquivo (ou em source externo) e deixe a main() no rodapé.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um risco gigantesco de vazar credenciais ou corromper scripts em malhas DevOps?
# Sim. Em shell, se você escrever `TOKEN="x"` dentro de uma função `download()`, e o seu colega tiver o mesmo `TOKEN="y"` noutra função no fim do script, assim que você chamar `download()` ele ESTRAGA o valor de quem estiver usando. Isso se chama "Global Space Pollution".
# No bash, tudo é global por padrão.
# A regra inflexível é: Dentro de chaves `{}`, TODA declaração de variável nova (que não for export global), TEM que usar `local TOKEN="x"`. Assim quando a função terminar, ela é apagada da RAM e o seu colega não chora na madrugada.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se estou na Main do script, o $1 retém o parâmetro passado no terminal. Porém quando executo a minha function `loggar()`, como eu repasso os MESMOS infinitos parâmetros para ela, se o meu $1 e o dela não referenciam mais a mesma coisa?"
# Resposta Sênior: Como o escopo de Array Posicional de function "Sombra/Shadows" a do script base, nós invocamos a função delegando explicitamente a expansão irrestrita global dela como argumento na hora da chamada originária. Nós escrevemos simplesmente: `loggar "$@"`. Assim, a array de infinitos argvs superior é perfeitamente injetada na array local da call function via word splitting protegido!
# ============================================================
