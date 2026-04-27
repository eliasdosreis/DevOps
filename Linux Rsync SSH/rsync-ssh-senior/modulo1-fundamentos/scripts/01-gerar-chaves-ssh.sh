#!/bin/bash
# =============================================================
# SCRIPT 01: Gerar Par de Chaves SSH
# Módulo 1 - Fundamentos
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# É como fazer uma chave e uma fechadura no ferreiro.
# A CHAVE (privada) fica com você.
# A FECHADURA (pública) você coloca na porta do servidor.
#
# =============================================================

# -------------------------------------------
# PASSO 1: Definir onde salvar as chaves
# -------------------------------------------
# Uma variável é como uma caixinha com um nome
# HOME é onde fica sua pasta pessoal (ex: /home/alex)
PASTA_CHAVES="$HOME/.ssh"          # Pasta onde ficam as chaves SSH
NOME_CHAVE="rsync_senior_key"      # Nome da nossa chave
COMENTARIO="devops-senior-projeto" # Etiqueta para identificar a chave

# -------------------------------------------
# PASSO 2: Criar a pasta .ssh se não existir
# -------------------------------------------
# O -p significa: "crie a pasta, mas não reclame se já existir"
mkdir -p "$PASTA_CHAVES"

# Definir permissão correta na pasta
# 700 = só o dono pode ler, escrever e entrar
chmod 700 "$PASTA_CHAVES"

echo "✅ Pasta SSH criada/verificada: $PASTA_CHAVES"

# -------------------------------------------
# PASSO 3: Gerar o par de chaves
# -------------------------------------------
# ssh-keygen = programa que cria as chaves
# -t ed25519  = tipo de criptografia (mais segura e moderna)
# -b 4096     = tamanho da chave em bits (maior = mais seguro)
# -C          = comentário/etiqueta na chave
# -f          = onde salvar o arquivo da chave
# -N ""       = sem senha na chave (para automação funcionar)

echo ""
echo "🔑 Gerando par de chaves SSH..."
echo "   Tipo: ED25519 (algoritmo moderno e seguro)"
echo ""

ssh-keygen \
    -t ed25519 \
    -C "$COMENTARIO" \
    -f "$PASTA_CHAVES/$NOME_CHAVE" \
    -N ""

# -------------------------------------------
# PASSO 4: Verificar se as chaves foram criadas
# -------------------------------------------
# O $? guarda o resultado do último comando
# 0 = sucesso, qualquer outro número = erro
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCESSO! Chaves criadas:"
    echo ""
    echo "   🔒 Chave PRIVADA (NUNCA compartilhe!):"
    echo "      $PASTA_CHAVES/$NOME_CHAVE"
    echo ""
    echo "   🔓 Chave PÚBLICA (pode compartilhar):"
    echo "      $PASTA_CHAVES/$NOME_CHAVE.pub"
    echo ""
else
    echo "❌ ERRO ao criar as chaves!"
    exit 1  # Sair com código de erro
fi

# -------------------------------------------
# PASSO 5: Definir permissões corretas
# -------------------------------------------
# MUITO IMPORTANTE! SSH é RÍGIDO com permissões
# Se as permissões estiverem erradas, o SSH recusa funcionar
#
# 600 = só o dono pode LER e ESCREVER (chave privada)
# 644 = dono pode ler/escrever, outros só leem (chave pública)

chmod 600 "$PASTA_CHAVES/$NOME_CHAVE"       # Chave privada: super restrita
chmod 644 "$PASTA_CHAVES/$NOME_CHAVE.pub"   # Chave pública: pode ser lida

echo "🔐 Permissões configuradas corretamente!"
echo ""

# -------------------------------------------
# PASSO 6: Mostrar o conteúdo da chave pública
# -------------------------------------------
# Este é o conteúdo que você vai copiar para o servidor
echo "📋 Copie a chave PÚBLICA abaixo para o servidor:"
echo "   (Cole no arquivo ~/.ssh/authorized_keys do servidor)"
echo ""
echo "------- CHAVE PÚBLICA -------"
cat "$PASTA_CHAVES/$NOME_CHAVE.pub"
echo "-----------------------------"
echo ""
echo "💡 DICA SÊNIOR: Para copiar automaticamente para um servidor:"
echo "   ssh-copy-id -i $PASTA_CHAVES/$NOME_CHAVE.pub usuario@servidor"
