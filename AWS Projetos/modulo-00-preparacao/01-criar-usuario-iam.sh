#!/bin/bash
# ============================================================
# ARQUIVO: 01-criar-usuario-iam.sh
# O QUE FAZ: Cria um usuário IAM para uso diário (NÃO use o root!)
#
# ANALOGIA: É como criar uma chave do apartamento em vez de
#           usar a escritura do imóvel para abrir a porta.
#
# CUSTO: $0.00 — IAM é sempre gratuito na AWS
# OBRIGATÓRIO: Execute este script UMA VEZ apenas
# ============================================================

set -e  # Para o script se qualquer comando falhar

# ============================================================
# CONFIGURAÇÕES — Altere aqui se necessário
# ============================================================
USUARIO="admin-pessoal"                    # Nome do usuário IAM
GRUPO="admins"                             # Grupo com permissões
POLITICA="arn:aws:iam::aws:policy/AdministratorAccess"  # Política gerenciada AWS

echo "============================================================"
echo "CRIANDO USUÁRIO IAM: $USUARIO"
echo "============================================================"

# ------------------------------------------------------------
# PASSO 1: Criar o grupo IAM
# Por quê grupo? Boa prática: você gerencia permissões no grupo,
# não no usuário. Assim, se criar mais usuários, só adiciona ao grupo.
# ------------------------------------------------------------
echo ""
echo "1. Criando grupo IAM '$GRUPO'..."
aws iam create-group --group-name "$GRUPO" 2>/dev/null || echo "   ℹ️  Grupo já existe, continuando..."

# ------------------------------------------------------------
# PASSO 2: Anexar política ao grupo
# AdministratorAccess = acesso total à conta AWS
# ⚠️ Só use isso em conta pessoal de aprendizado!
# Em produção, use políticas com least privilege (Módulo 7)
# ------------------------------------------------------------
echo "2. Anexando política AdministratorAccess ao grupo..."
aws iam attach-group-policy \
    --group-name "$GRUPO" \
    --policy-arn "$POLITICA" 2>/dev/null || echo "   ℹ️  Política já anexada, continuando..."

# ------------------------------------------------------------
# PASSO 3: Criar o usuário IAM
# O usuário herda as permissões do grupo ao qual pertence
# ------------------------------------------------------------
echo "3. Criando usuário IAM '$USUARIO'..."
aws iam create-user \
    --user-name "$USUARIO" \
    --tags Key=Propósito,Value=Aprendizado Key=Módulo,Value=0 \
    2>/dev/null || echo "   ℹ️  Usuário já existe, continuando..."

# ------------------------------------------------------------
# PASSO 4: Adicionar usuário ao grupo
# ------------------------------------------------------------
echo "4. Adicionando '$USUARIO' ao grupo '$GRUPO'..."
aws iam add-user-to-group \
    --group-name "$GRUPO" \
    --user-name "$USUARIO" 2>/dev/null || echo "   ℹ️  Usuário já está no grupo, continuando..."

# ------------------------------------------------------------
# PASSO 5: Criar Access Key para uso no CLI
# ATENÇÃO: Esta chave só aparece UMA VEZ! Guarde em local seguro!
# NUNCA suba para GitHub ou repositórios públicos!
# ------------------------------------------------------------
echo ""
echo "5. Criando Access Key para uso no AWS CLI..."
CREDENCIAIS=$(aws iam create-access-key --user-name "$USUARIO")

ACCESS_KEY=$(echo "$CREDENCIAIS" | python3 -c "import sys, json; print(json.load(sys.stdin)['AccessKey']['AccessKeyId'])")
SECRET_KEY=$(echo "$CREDENCIAIS" | python3 -c "import sys, json; print(json.load(sys.stdin)['AccessKey']['SecretAccessKey'])")

echo ""
echo "============================================================"
echo "✅ USUÁRIO CRIADO COM SUCESSO!"
echo "============================================================"
echo ""
echo "🔑 CREDENCIAIS (GUARDE AGORA — NÃO APARECERÃO NOVAMENTE!):"
echo "   Access Key ID:     $ACCESS_KEY"
echo "   Secret Access Key: $SECRET_KEY"
echo ""
echo "⚠️  NUNCA compartilhe estas credenciais!"
echo "⚠️  NUNCA suba para GitHub/repositórios!"
echo ""

# ------------------------------------------------------------
# PASSO 6: Configurar o AWS CLI com as novas credenciais
# Pergunta ao usuário se quer configurar automaticamente
# ------------------------------------------------------------
echo "Deseja configurar o AWS CLI agora? (s/n)"
read -r RESPOSTA
if [ "$RESPOSTA" = "s" ] || [ "$RESPOSTA" = "S" ]; then
    aws configure set aws_access_key_id "$ACCESS_KEY"
    aws configure set aws_secret_access_key "$SECRET_KEY"
    aws configure set default.region us-east-1
    aws configure set default.output json
    echo "✅ AWS CLI configurado!"
fi

echo ""
echo "============================================================"
echo "VERIFICAÇÃO — Execute este comando para confirmar:"
echo "  aws sts get-caller-identity"
echo ""
echo "Saída esperada:"
echo "  { \"Arn\": \"arn:aws:iam::...:user/$USUARIO\" }"
echo "============================================================"
