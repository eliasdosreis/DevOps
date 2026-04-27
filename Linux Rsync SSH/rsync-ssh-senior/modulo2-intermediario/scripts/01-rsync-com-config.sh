#!/bin/bash
# =============================================================
# SCRIPT 01: Sistema com Arquivo de Configuração
# Módulo 2 - Intermediário
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Em vez de escrever o endereço de todo mundo na cabeça,
# você anota numa agenda. Quando precisar, abre a agenda!
# Este script tem uma "agenda" (arquivo de config) que ele lê.
#
# POR QUE ISSO É SÊNIOR?
# Sênior separa configuração do código!
# Assim você muda o servidor sem mexer no script.
#
# =============================================================

# -------------------------------------------
# Carregar arquivo de configuração externo
# -------------------------------------------
# O arquivo de config fica SEPARADO do script
# Isso é uma boa prática ESSENCIAL para Sênior!

ARQUIVO_CONFIG="$(dirname "$0")/rsync.conf"
# dirname $0 = pasta onde está o script atual

# Verificar se o arquivo de config existe
if [ ! -f "$ARQUIVO_CONFIG" ]; then
    echo "❌ Arquivo de configuração não encontrado!"
    echo "   Esperado em: $ARQUIVO_CONFIG"
    echo "   Crie o arquivo rsync.conf primeiro."
    exit 1
fi

# Carregar as configurações
# source = "ler este arquivo e executar os comandos dele"
# É como importar em Python ou require em JavaScript
source "$ARQUIVO_CONFIG"

echo "✅ Configurações carregadas de: $ARQUIVO_CONFIG"
echo ""
echo "📋 Configurações ativas:"
echo "   Servidor: $SERVIDOR"
echo "   Usuário:  $USUARIO"
echo "   Origem:   $PASTA_ORIGEM"
echo "   Destino:  $PASTA_DESTINO"
echo ""

# -------------------------------------------
# Validar configurações obrigatórias
# -------------------------------------------
# Um Sênior valida TUDO antes de executar
ERRO_CONFIG=0

# Função para verificar variável
verificar_var() {
    local NOME_VAR="$1"   # Nome da variável
    local VALOR="$2"       # Valor da variável

    # -z = verifica se a string está VAZIA
    if [ -z "$VALOR" ]; then
        echo "❌ Configuração obrigatória não definida: $NOME_VAR"
        ERRO_CONFIG=1
    fi
}

# Verificar cada variável obrigatória
verificar_var "SERVIDOR"      "$SERVIDOR"
verificar_var "USUARIO"       "$USUARIO"
verificar_var "PASTA_ORIGEM"  "$PASTA_ORIGEM"
verificar_var "PASTA_DESTINO" "$PASTA_DESTINO"
verificar_var "CHAVE_SSH"     "$CHAVE_SSH"

# Se alguma variável falhou, sair
if [ $ERRO_CONFIG -ne 0 ]; then
    echo ""
    echo "⚠️  Corrija o arquivo de configuração: $ARQUIVO_CONFIG"
    exit 1
fi

echo "✅ Todas as configurações validadas!"

# -------------------------------------------
# Executar o rsync com as configurações
# -------------------------------------------
echo ""
echo "🚀 Iniciando sincronização..."

rsync \
    --archive \
    --compress \
    --verbose \
    --human-readable \
    --progress \
    --stats \
    --partial \
    --rsh="ssh -i ${CHAVE_SSH} -p ${PORTA_SSH:-22}" \
    # ↑ ${PORTA_SSH:-22} = usa $PORTA_SSH ou 22 se não definido
    "$PASTA_ORIGEM/" \
    "${USUARIO}@${SERVIDOR}:${PASTA_DESTINO}"

# Capturar o resultado
RESULTADO=$?

if [ $RESULTADO -eq 0 ]; then
    echo ""
    echo "✅ Sincronização concluída!"
else
    echo ""
    echo "❌ Erro na sincronização! Código: $RESULTADO"
    exit $RESULTADO
fi
