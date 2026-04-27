#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Desmistifica a forma pela qual um script recebe "Inputs" do 
# mundo externo. Ensina tanto o 'read' (prompt interativo)
# quanto os parâmetros posicionais (rodar direto "script.sh maria").
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Para o script rodar, ele às vezes precisa de você (humano).
# - A função 'read' é o atendente do guichê te perguntando: "Nome completo?" E não faz nada até você digitar.
# - Argumentos Posicionais são como você entregar um envelope já lacrado pro atendente: "Pega isso aqui pra mim." O script roda imediatamente sem perguntar mais nada.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O Bash coleta input de dois vetores distintos de injeção:
# 1) O descritor padrão STDIN via prompt `read` builtin, suspenso (blocking IO).
# 2) Array especial Posicional (`$1`, `$2`, `$@`) populada pela string dos paramêtros argc/argv vindos do kernel via execução (CLI args).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Recebendo Inputs ==="

# VETOR 1: Parâmetros do sistema ($1, $2, $@)
# Note: $0 é sempre o nome do script (ex: ./03-entrada.sh)
# $1 é a primeira caneta que você passar, $2 a segunda

# O '$#' guarda O NÚMERO (count) de argumentos passados.
QUANTIDADE_ARGUMENTOS=$#
NOME_SCRIPT=$0
TODOS_ARGUMENTOS=$@

echo "1. Olá! Meu identificador próprio (script) é o: $NOME_SCRIPT"
echo "2. Você me passou ao total de: $QUANTIDADE_ARGUMENTOS argumentos agora."
echo "3. A lista completa de coisas injetadas foi: $TODOS_ARGUMENTOS"

# Vamos simular que este script requeira um "Nome" sendo o $1
# "Se o $1 não estiver vazio" (nós desativamos o flag -u da proteção bash para este trecho pra exemplificar de boa de forma sênior)
if [ -n "${1:-}" ]; then
  PRIMEIRO_ARG="$1"
  echo "4. O seu nome, puxado do argumento 1 silenciosamente foi: $PRIMEIRO_ARG"
else
  # VETOR 2: Prompt Interativo (se ele não passou argumentos fora, a gente pede de dentro)
  echo "4. Você não passou argumentos executando \`./script Elias\`. Vou perguntar iterativamente:"
  
  # A flag promt -p pede o nome na mesma linha; -r evita que o bash tente interpretar contra-barras malditas '\'
  read -r -p "   - Por favor, digite o seu nome na linha: " NOME_LIDO
  
  echo "5. Perfeito. O seu nome no input interativamete foi: $NOME_LIDO"
fi

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O `read VARIAVEL` trava tudo, pisca até você pressionar ENTER, salvando as letras em VARIAVEL.
# - Rodar sem os args: `./03-entrada-usuario.sh` acionará o 'read' pedindo "Digite o seu nome".
# - Rodar direto por fora: `./03-entrada-usuario.sh Roberto 30` vai processar que "$1" é Roberto e "$2" é 30.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Como peço senhas para o usuário sem deixar o shell mostrar (oculto)?
#   O que fazer: O `read -s` (-s significa silent). O input funciona, mas o eco na tela é blindado.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Qual é o perigo de fazer scripts interativos de prompt (`read`) em empresas/DevOps?
# Sêniores sabem que "a nuvem e a automação não tem mãos". Os Pipelines CI/CD/Jenkins de deploys quebram/timeout eternamente se um script fica parado num prompt (`read`) pedindo aprovação de teclas 'Y/n'.
# O ideal é que todos os scripts sejam desenhados para aceitarem flags e opções "Non-Interactive Flags" (`$1`, `$2`, `--force` com getopts) para que a automação injetem os parâmetros de fora de uma vez.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Qual a sutil (e perigosa) diferença entre as arrays de argumentos unificados em especial entre listar `$*` e `$@`?"
# Resposta Sênior: Se passadas por parâmetro várias palavras ("foo bar" "baz"), se referenciarmos com aspas `"$*"` o bash vai fundir tudo numa ÚNICA e monolítica String/stringona separadas por um prefixo $IFS: `foo bar baz`.
# Se referenciarmos usando `"$@"` entre aspas (SEMPRE A MELHOR PRÁTICA), o bash vai manter as strings em uma lista real de seus componentes isolados, reproduzindo exatamente o isolamento da origem e repassando intactamente para outras funçõeS: "foo bar" e a segunda "baz". Retendo espaços vazios corretos.
# ============================================================
