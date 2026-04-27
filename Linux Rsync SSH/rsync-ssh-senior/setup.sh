#!/bin/bash
# =============================================================
# SETUP INICIAL: Preparar Ambiente para o Projeto
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# Antes de cozinhar, você organiza os ingredientes na bancada.
# Este script organiza tudo que você precisa para o projeto!
#
# EXECUTE ESTE SCRIPT PRIMEIRO antes de qualquer outro!
#
# =============================================================

VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NEGRITO='\033[1m'
RESET='\033[0m'

log()   { echo -e "${AZUL}[$(date '+%H:%M:%S')]${RESET} $1"; }
ok()    { echo -e "${VERDE}  ✅ $1${RESET}"; }
aviso() { echo -e "${AMARELO}  ⚠️  $1${RESET}"; }
erro()  { echo -e "${VERMELHO}  ❌ $1${RESET}"; }

echo ""
echo -e "${NEGRITO}${AZUL}"
echo "╔═══════════════════════════════════════════════╗"
echo "║   🚀 SETUP - Projeto rsync+SSH Sênior          ║"
echo "║   Alex DevOps Coach                            ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${RESET}"

# -------------------------------------------
# PASSO 1: Verificar ferramentas necessárias
# -------------------------------------------
log "🔍 Verificando ferramentas necessárias..."
echo ""

TUDO_OK=true

# Função para verificar se um programa está instalado
verificar_ferramenta() {
    local FERRAMENTA="$1"
    local DICA_INSTALACAO="$2"

    # command -v = verifica se o comando existe (mais portável que 'which')
    # &>/dev/null = descarta toda saída (queremos só o código de retorno)
    if command -v "$FERRAMENTA" &>/dev/null; then
        local VERSAO
        VERSAO=$("$FERRAMENTA" --version 2>/dev/null | head -1 || echo "instalado")
        ok "$FERRAMENTA: $VERSAO"
    else
        erro "$FERRAMENTA: NÃO ENCONTRADO"
        aviso "Para instalar: $DICA_INSTALACAO"
        TUDO_OK=false
    fi
}

# Verificar cada ferramenta
verificar_ferramenta "rsync" "sudo apt install rsync  OU  sudo yum install rsync"
verificar_ferramenta "ssh"   "sudo apt install openssh-client"
verificar_ferramenta "ssh-keygen" "sudo apt install openssh-client"
verificar_ferramenta "sha256sum"  "sudo apt install coreutils (já vem no Linux)"
verificar_ferramenta "bc"         "sudo apt install bc"

echo ""

if [ "$TUDO_OK" = "false" ]; then
    aviso "Instale as ferramentas faltando e execute este script novamente"
    exit 1
fi

ok "Todas as ferramentas encontradas!"

# -------------------------------------------
# PASSO 2: Tornar scripts executáveis
# -------------------------------------------
log ""
log "🔐 Tornando scripts executáveis..."

# Encontrar todos os scripts .sh e dar permissão de execução
# find . = procurar a partir da pasta atual
# -name "*.sh" = apenas arquivos terminando em .sh
# -exec chmod +x {} \; = executar chmod para cada arquivo encontrado
find "$(dirname "$0")" -name "*.sh" -exec chmod +x {} \;

ok "Todos os scripts são executáveis agora!"

# -------------------------------------------
# PASSO 3: Gerar chaves SSH (se não existirem)
# -------------------------------------------
log ""
log "🔑 Verificando chaves SSH..."

CHAVE="$HOME/.ssh/rsync_senior_key"

if [ -f "$CHAVE" ] && [ -f "${CHAVE}.pub" ]; then
    ok "Chaves SSH já existem:"
    log "   Privada: $CHAVE"
    log "   Pública: ${CHAVE}.pub"
else
    aviso "Chaves SSH não encontradas. Gerando agora..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    ssh-keygen \
        -t ed25519 \
        -C "devops-senior-projeto" \
        -f "$CHAVE" \
        -N ""

    if [ $? -eq 0 ]; then
        ok "Chaves geradas com sucesso!"
        chmod 600 "$CHAVE"
        chmod 644 "${CHAVE}.pub"
    else
        erro "Falha ao gerar chaves SSH"
        exit 1
    fi
fi

# -------------------------------------------
# PASSO 4: Criar estrutura de pastas de teste
# -------------------------------------------
log ""
log "📁 Criando pastas de teste..."

mkdir -p /tmp/rsync-origem/documentos
mkdir -p /tmp/rsync-origem/configs
mkdir -p /tmp/rsync-destino

# Criar arquivos de exemplo
echo "Documento importante v1" > /tmp/rsync-origem/documentos/relatorio.txt
echo "Configuração do app"     > /tmp/rsync-origem/configs/app.conf
echo "Config do banco"         > /tmp/rsync-origem/configs/db.conf
echo "Script de start"         > /tmp/rsync-origem/start.sh

ok "Estrutura de teste criada em /tmp/rsync-origem/"

# -------------------------------------------
# PASSO 5: Resumo e próximos passos
# -------------------------------------------
echo ""
echo -e "${NEGRITO}${VERDE}"
echo "╔═══════════════════════════════════════════════╗"
echo "║   ✅ SETUP CONCLUÍDO!                          ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${RESET}"

echo ""
echo -e "${NEGRITO}📚 ORDEM DE ESTUDO:${RESET}"
echo ""
echo "  MÓDULO 1 - FUNDAMENTOS:"
echo "  1. Leia:    modulo1-fundamentos/teoria/01-conceitos.md"
echo "  2. Execute: modulo1-fundamentos/scripts/02-rsync-local-basico.sh"
echo "  3. Faça:    modulo1-fundamentos/exercicios/exercicios-m1.md"
echo ""
echo "  MÓDULO 2 - INTERMEDIÁRIO:"
echo "  1. Leia:    modulo2-intermediario/teoria/01-automacao-boas-praticas.md"
echo "  2. Execute: modulo2-intermediario/scripts/01-rsync-com-config.sh"
echo "  3. Faça:    modulo2-intermediario/exercicios/exercicios-m2.md"
echo ""
echo "  MÓDULO 3 - AVANÇADO:"
echo "  1. Leia:    modulo3-avancado/teoria/01-segurança-monitoramento.md"
echo "  2. Execute: modulo3-avancado/scripts/01-verificar-integridade.sh"
echo "  3. Faça:    modulo3-avancado/exercicios/exercicios-m3.md"
echo ""
echo "  MÓDULO 4 - PROJETO FINAL:"
echo "  1. Leia:    modulo4-projeto-final/README-modulo4.md"
echo "  2. Configure: modulo4-projeto-final/configs/migrar.conf"
echo "  3. Execute: modulo4-projeto-final/scripts/migrar-enterprise.sh --dry-run"
echo "  4. Estude:  modulo4-projeto-final/scripts/guia-entrevista-senior.md"
echo ""
echo -e "${NEGRITO}💡 Dica: Comece sempre pelo Módulo 1, mesmo que já conheça!${RESET}"
echo ""
