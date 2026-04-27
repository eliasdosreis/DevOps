#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Módulo de Scripts Em Produção. Apresenta a poderosa e nativa
# Engine do "getopts" capaz de construir ferramentas CLI
# padronizadas, extraindo e processando Parâmetros Flags (ex: `-v -u x`).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você tem um restaurante e vende prato feito. O garçom anota num papel:
# "Arroz, feijão, -P Bife, -B Cerveja".
# Em vez do Cozinheiro adivinhar a ordem das anotações (se Bife tá na linha $1 ou $3),
# Ele foca nas "Bandeiras de Letras" (Flags):
# Ah! O 'P' é Proteína, não importa onde esteja na frase. E o 'B' é Bebida.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O `getopts` (versão portável do getopt GNU) é uma função builtin da engine bash
# para parsear Short Options (ex: `-f value`). Ele reordena os parâmetros C argv (`$*`)
# iterativamente dentro de variáveis de controle temporárias (`$OPTARG` e `$OPTIND`) extraindo dependências de flags isoladas de forma imune a espaços ou troca de posições dos argumentos da CLI.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Construtor Universal CLI (GetOpts) ==="

# Definindo Variáveis Padrões Caso o Usuário não passe a Flag
# ==============================
USUARIO="anonimo"
FORCE_MODE="nao"
# ==============================

uso_correto() {
    # Manda pro Erro Fd2.
    echo "Uso incorreto da ferramenta Shell." >&2
    echo "Exemplo: $0 -u <nome_usuario> [-f]" >&2
    exit 1
}

# O Motor Loop Mestre Getopts:
# "u::f" Significa que nossa ferramenta Bash reconhece as letras `-u` e `-f`.
# OS DOIS PONTOS `u:` significa que a flag `-u` EXIGE E COME UMA PALAVRA/TEXTO DOBRADO OBRIGATORIAMENTE logo a frente (ex: -u Elias). Como no pip/npm!
# O 'f' não tem dois pontos. Ele é um simples "Booleano True/False Trigger". (ex: -f só liga, não pede texto).

while getopts "u:f" flag; do
    case "${flag}" in
        u)
            # A palavra que estava engatada frente à letra 'u' foi magicamente
            # salva na macro do sistema $OPTARG (Option Argument).
            USUARIO="${OPTARG}"
            ;;
        f)
            # Aciona a chave da flag "force delete" (-f). Sem Argumentos lidos.
            FORCE_MODE="sim"
            ;;
        *)
            # Estrela (Qualquer letra bizarra que passarem tipo -z, -h não cadastrados)
            uso_correto
            ;;
    esac
done

# 'Shift' Magia Obscura Sênior Posix: Move The Pointers Ahead
# Arranca e Destroi todos os argumentos '-u Elias -f' que nós já lemos pra frente do $1 do kernel, deixando nosso código livre pra ler ($@) puros no final!
shift $((OPTIND-1))

echo "1. Análise do Computador Processada!"
echo "   - O usuário ativo para DB foi setado dinâmicamente: $USUARIO"
echo "   - O Fluxo de Forçar Deleção SemPerguntas ativada? $FORCE_MODE"

if [[ $# -gt 0 ]]; then
    echo "2. Mesmo arrancando os parâmetros de flags... Você digitou sufixos extras soltos no final: $@"
fi

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Rodar normal caindo no ELSE padrão (sem var): `./01-validacao-getopts.sh`
# - Passando Param do User: `./01-validacao-getopts.sh -u Marcos_Silva`
# - Passando a Chave (Force) Embaralhada tmb: `./01-validacao-getopts.sh -f -u Joaozin`
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao rodar `./script.sh -u` me aparece o bash gritando `script.sh: option requires an argument -- u`. E morre.
#   O que é: A maravilha do GetOpts auto-debug! Lembra que vc colocou os DOIS PONTOS no `u:`? Vc estipulou e fechou contrato OBRIGANDO que qlqr DevOps que digitar '-u' no terminal e dar ENTER tome erro fatal forçado da shell, pq a shell sabe cobrar dele uma string ali no lugar! Fim dos "Parametros em branco" nos seus scripts.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O `getopts` nativo e builtin só aceita "Short Options" (uma letra: `-f`, `-v`, `-h`).
# "Mas Elias, eu vejo ferramentas Node/KubeCTL com 'Long Options' `--force`, `--user`. Dá pra fzr no shell puro?"
# Sim mas não com on Builtin Getopts Posix. Vc terá que invocar o GNU Utility Externo `/usr/bin/getopt` (com T final inves de S final). 
# Os Sêniors não gostam de misturar longa opcões no GNU, porque o comportamento de parsing entre MAC OSx BSD / Alpine Musl e Debian Ubuntu GNU divergem horrivelmente quebrando o pipeline parse em multi-servidores! Por pura compatibilidade Universal, Sêniores System Architects programam Scripts Corporativos Linux sempre limitados na Short-option letter (`getopts`) do bash interno (`-h`, `-u`) assegurado 100% de match.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado um Shell Pipeline interagindo com a AWS CLI. Como o comando Kernel Syscall POSIX `shift` altera o estado das Variáveis numéricas Globais $1 ao $9 após as varreduras de Array de um ForLoop de getopts?"
# Resposta Sênior: O comando internal macro `shift N`, fisicamente re-fatia e rotaciona C-Arrays para esquerda. Exato N passos que lhe forem conferidos. Se você passou 5 argumentos no bash ($1 = foo, $2=bar,...). Um "Shift 2", joga p o LIXO atômico da RAM o foo e bar; logo puxa o Terceiro Array element para reassumir com a coroa a variável master $1 e $2 de modo nativamente isolado sem alocar novos structs em C para as demais funções acessarem livremente the rest! Nós demos o Shift no OPTIND-1 (o pointer que marcou quantas flags nós já consumimos na rodada do While lendo o "u:").
# ============================================================
