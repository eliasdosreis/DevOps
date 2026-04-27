#!/bin/bash
# =============================================================
# SCRIPT 03: Hardening SSH para rsync Seguro
# Módulo 3 - Avançado
# Alex DevOps Coach
# =============================================================
#
# 🧒 PARA CRIANÇAS:
# "Hardening" = "endurecer" a segurança.
# É como colocar fechadura, câmera e alarme na sua casa.
# Por padrão, o SSH vem "aberto demais". Vamos fechar o que não precisamos!
#
# ⚠️  ATENÇÃO: Este script modifica configurações do servidor.
#     Execute APENAS em ambiente de teste ou com cuidado em produção!
#     Sempre mantenha uma sessão SSH aberta ao modificar o sshd_config!
#
# =============================================================

VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

log()   { echo -e "${AZUL}[$(date '+%H:%M:%S')]${RESET} $1"; }
ok()    { echo -e "${VERDE}  ✅ $1${RESET}"; }
aviso() { echo -e "${AMARELO}  ⚠️  $1${RESET}"; }
erro()  { echo -e "${VERMELHO}  ❌ $1${RESET}"; }

# =============================================================
# PARTE 1: CRIAR USUÁRIO DEDICADO PARA RSYNC
# =============================================================
# Princípio do menor privilégio:
# Crie um usuário que SÓ pode fazer rsync, nada mais!

criar_usuario_rsync() {
    log "👤 Criando usuário dedicado para rsync..."

    local USUARIO_RSYNC="rsync-backup"
    local SHELL_NOLOGIN="/usr/sbin/nologin"  # Shell que não permite login interativo

    # Verificar se o usuário já existe
    # id = mostra informações de um usuário
    if id "$USUARIO_RSYNC" &>/dev/null; then
        aviso "Usuário '$USUARIO_RSYNC' já existe"
    else
        # useradd = criar usuário
        # -r = usuário de sistema (sem home por padrão, sem senha)
        # -s = shell (nologin = não pode fazer login interativo)
        # -m = criar pasta home
        # -d = onde fica a pasta home
        useradd \
            -r \
            -s "$SHELL_NOLOGIN" \
            -m \
            -d "/home/${USUARIO_RSYNC}" \
            -c "Usuario dedicado para rsync backups" \
            "$USUARIO_RSYNC"

        ok "Usuário '$USUARIO_RSYNC' criado com shell: $SHELL_NOLOGIN"
    fi

    # Criar pasta .ssh para o usuário
    mkdir -p "/home/${USUARIO_RSYNC}/.ssh"
    chmod 700 "/home/${USUARIO_RSYNC}/.ssh"
    chown -R "${USUARIO_RSYNC}:${USUARIO_RSYNC}" "/home/${USUARIO_RSYNC}/.ssh"

    ok "Pasta .ssh configurada"

    # Mostrar como adicionar a chave pública
    log ""
    log "📋 Para autorizar sua chave no servidor, execute:"
    log "   cat ~/.ssh/rsync_senior_key.pub >> /home/${USUARIO_RSYNC}/.ssh/authorized_keys"
    log "   chmod 600 /home/${USUARIO_RSYNC}/.ssh/authorized_keys"
    log "   chown ${USUARIO_RSYNC}:${USUARIO_RSYNC} /home/${USUARIO_RSYNC}/.ssh/authorized_keys"
}

# =============================================================
# PARTE 2: CONFIGURAR authorized_keys COM RESTRIÇÕES
# =============================================================
# Você pode restringir O QUE um usuário pode fazer quando conecta!
# Isso é muito mais seguro do que apenas autorizar a chave.

configurar_chave_restrita() {
    log ""
    log "🔒 Exemplo de authorized_keys com restrições..."

    # O arquivo authorized_keys pode ter opções antes da chave:
    cat << 'EXEMPLO'
# =============================================================
# EXEMPLO: /home/rsync-backup/.ssh/authorized_keys
# =============================================================

# CHAVE SEM RESTRIÇÃO (padrão - perigoso!)
ssh-ed25519 AAAA... usuario@computador

# CHAVE COM RESTRIÇÕES (modo Sênior!)
# Explicação de cada opção:
#
# command="rsync --server --sender -avz . /backup/"
#   → Só pode executar EXATAMENTE este comando rsync
#   → Qualquer outro comando é recusado!
#
# no-port-forwarding
#   → Não pode criar túneis de porta
#
# no-X11-forwarding
#   → Não pode redirecionar interface gráfica
#
# no-agent-forwarding
#   → Não pode usar o agente SSH local
#
# no-pty
#   → Não recebe terminal interativo
#
# from="192.168.1.0/24"
#   → Só aceita conexão a partir desta rede!
#   → Bloqueia qualquer outro IP automaticamente

from="192.168.1.0/24",command="rsync --server --sender -avz . /backup/",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAA... devops@empresa

# =============================================================
# RESULTADO: Este usuário só pode:
# ✅ Conectar da rede 192.168.1.0/24
# ✅ Executar rsync em modo somente-leitura (--sender)
# ❌ Fazer login interativo
# ❌ Executar qualquer outro comando
# ❌ Criar túneis
# ❌ Conectar de outros IPs
# =============================================================
EXEMPLO

    ok "Exemplo exibido!"
}

# =============================================================
# PARTE 3: VERIFICAR CONFIGURAÇÃO SSH ATUAL
# =============================================================

verificar_config_ssh() {
    log ""
    log "🔍 Verificando configuração SSH atual..."

    local SSHD_CONFIG="/etc/ssh/sshd_config"

    if [ ! -f "$SSHD_CONFIG" ]; then
        aviso "Arquivo $SSHD_CONFIG não encontrado (normal se não for um servidor)"
        return
    fi

    log ""
    log "Verificações de segurança:"

    # Função auxiliar para verificar uma configuração
    verificar_opcao() {
        local OPCAO="$1"       # Nome da opção (ex: PermitRootLogin)
        local SEGURO="$2"      # Valor seguro esperado (ex: no)
        local DESCRICAO="$3"   # Descrição amigável

        # grep -i = case-insensitive | awk = pegar o valor
        local VALOR_ATUAL
        VALOR_ATUAL=$(grep -i "^${OPCAO}" "$SSHD_CONFIG" | awk '{print $2}' | head -1)

        if [ -z "$VALOR_ATUAL" ]; then
            aviso "$DESCRICAO: não configurado (usando padrão)"
        elif [ "${VALOR_ATUAL,,}" = "${SEGURO,,}" ]; then
            # ${variavel,,} = converter para minúsculas
            ok "$DESCRICAO: $VALOR_ATUAL ✅"
        else
            aviso "$DESCRICAO: $VALOR_ATUAL (recomendado: $SEGURO)"
        fi
    }

    verificar_opcao "PermitRootLogin"        "no"  "Login como root"
    verificar_opcao "PasswordAuthentication" "no"  "Autenticação por senha"
    verificar_opcao "PubkeyAuthentication"   "yes" "Autenticação por chave"
    verificar_opcao "MaxAuthTries"           "3"   "Máximo de tentativas"
    verificar_opcao "X11Forwarding"          "no"  "Redirecionamento X11"
}

# =============================================================
# PARTE 4: GERAR RELATÓRIO DE SEGURANÇA SSH
# =============================================================

relatorio_seguranca() {
    log ""
    log "📊 Checklist de Segurança SSH para DevOps Sênior:"
    echo ""

    # Lista de verificações com status
    echo "  OBRIGATÓRIO:"
    echo "  [ ] Autenticação apenas por chave (sem senha)"
    echo "  [ ] Root login desabilitado"
    echo "  [ ] Usuário dedicado para rsync"
    echo "  [ ] Chaves ED25519 (não RSA 1024/2048 antigo)"
    echo ""
    echo "  RECOMENDADO:"
    echo "  [ ] Porta SSH não-padrão (não 22)"
    echo "  [ ] Restrição de IP no authorized_keys"
    echo "  [ ] Comando restrito no authorized_keys"
    echo "  [ ] fail2ban instalado e configurado"
    echo "  [ ] Logs de acesso monitorados"
    echo ""
    echo "  AVANÇADO:"
    echo "  [ ] Certificados SSH (ao invés de chaves individuais)"
    echo "  [ ] Bastion host / Jump server"
    echo "  [ ] MFA (autenticação de dois fatores)"
    echo "  [ ] Auditoria com auditd"
}

# =============================================================
# EXECUÇÃO PRINCIPAL
# =============================================================

log "🛡️  AUDITORIA E CONFIGURAÇÃO DE SEGURANÇA SSH"
log "=================================================="
log ""

# Verificar se está rodando como root (necessário para modificar sshd_config)
if [ "$(id -u)" -ne 0 ]; then
    aviso "Script não está rodando como root"
    aviso "Algumas verificações podem falhar"
    aviso "Para criar usuário e modificar config: execute com sudo"
    echo ""
fi

verificar_config_ssh
configurar_chave_restrita
relatorio_seguranca

log ""
ok "Auditoria concluída!"
log ""
log "💡 Para aplicar as mudanças no sshd_config:"
log "   sudo systemctl reload sshd"
log "   (NÃO feche a sessão SSH atual antes de testar!)"
