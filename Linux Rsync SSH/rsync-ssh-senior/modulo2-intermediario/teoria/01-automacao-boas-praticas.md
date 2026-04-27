# 📖 Módulo 2 - Teoria: Automação e Boas Práticas

## 🤖 Por que Automatizar?

### Explicação para Criança:
Imagine lavar a louça toda vez manualmente vs ter uma máquina de lavar louça.
A máquina faz sempre igual, sem esquecer nada, sem cansaço.
Automatizar scripts é criar sua "máquina de lavar louça" para tarefas repetitivas!

---

## 📁 Separação de Configuração e Código

### O Princípio:
> "O código diz O QUE fazer. A configuração diz COM QUEM e ONDE fazer."

```bash
# ❌ RUIM - Configuração no meio do código:
rsync -av /dados/ devops@192.168.1.100:/backup/

# ✅ BOM - Configuração separada:
source migrar.conf       # Carrega as configs
rsync -av "$ORIGEM/" "${USUARIO}@${SERVIDOR}:${DESTINO}/"
```

**Por que isso importa?**
- Você pode ter `prod.conf`, `staging.conf`, `dev.conf`
- Troca de servidor = edita só o `.conf`, não o script
- Segurança: o `.conf` vai no `.gitignore`, o script vai no Git

---

## 🔁 Retry com Backoff Exponencial

### Explicação para Criança:
Você bate na porta do vizinho. Ele não atende.
Em vez de bater a cada segundo (irritante!), você espera:
- 1ª tentativa: bate → não atende → espera 30s
- 2ª tentativa: bate → não atende → espera 60s  
- 3ª tentativa: bate → não atende → espera 120s

Isso é **backoff exponencial** — respeita o tempo de recuperação!

### Na prática:
```
Tentativa 1 falhou → espera 30s  (30 * 2^0)
Tentativa 2 falhou → espera 60s  (30 * 2^1)
Tentativa 3 falhou → espera 120s (30 * 2^2)
```

---

## 📝 Sistema de Logs Profissional

### Anatomia de uma boa linha de log:
```
[2024-01-15 14:32:01] [INFO] Iniciando transferência de /dados/ para servidor
  └─── timestamp ───┘  └─nivel─┘ └──────────── mensagem ──────────────────┘
```

### Níveis de log (do menos ao mais crítico):
| Nível | Quando usar |
|-------|-------------|
| DEBUG | Detalhes para desenvolvimento |
| INFO  | Informações normais da execução |
| AVISO | Algo inesperado mas não fatal |
| ERRO  | Falha que precisa de atenção |

### Rotação de logs (limpeza automática):
```bash
# Apagar logs com mais de 30 dias
find /var/log/rsync/ -name "*.log" -mtime +30 -delete
```

---

## 🔒 Variáveis no Bash: Boas Práticas

```bash
# CONSTANTES: use readonly (não pode ser alterada acidentalmente)
readonly VERSAO="1.0.0"
readonly MAX_TENTATIVAS=3

# VARIÁVEIS LOCAIS em funções: use 'local' (não vaza para fora da função)
minha_funcao() {
    local RESULTADO="calculado aqui"  # Só existe dentro da função
    echo "$RESULTADO"
}

# VALOR PADRÃO: se a variável não foi definida, usa o padrão
PORTA="${PORTA_SSH:-22}"    # Usa $PORTA_SSH, ou 22 se não definida

# VERIFICAR SE ESTÁ VAZIA:
if [ -z "$VARIAVEL" ]; then
    echo "Variável está vazia!"
fi

# VERIFICAR SE NÃO ESTÁ VAZIA:
if [ -n "$VARIAVEL" ]; then
    echo "Variável tem valor!"
fi
```

---

## 🎯 Pergunta de Entrevista:

**"Como você organizaria um sistema de backup com rsync para rodar automaticamente toda noite?"**

**Resposta Sênior:**
> "Criaria um script com arquivo de configuração externo, sistema de logs com
> rotação automática, retry com backoff exponencial, verificação de espaço antes
> de executar, e notificação por email/Slack ao final.
> Agendaria via cron: `0 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1`
> E monitoraria com alertas se o job não executar ou demorar mais que o esperado."
