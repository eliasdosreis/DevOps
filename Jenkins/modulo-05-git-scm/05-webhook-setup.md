# ============================================================
# MÓDULO 5 — INTEGRAÇÃO COM GIT E SCM
# Arquivo: 05-webhook-setup.md
# ============================================================

# Configurando Webhooks: Trigger Automático no Jenkins

---

## O QUE É UM WEBHOOK?

**Analogia**: Um webhook é como o **campainha de uma porta**.
Quando alguém faz um push no GitHub (aperta a campainha), o GitHub
automaticamente avisa o Jenkins (toca a campainha). O Jenkins então
inicia o build imediatamente — sem precisar ficar verificando se tem
novidades (polling).

**Técnico**: Um webhook é uma notificação HTTP POST enviada pelo GitHub/
GitLab para o Jenkins quando um evento ocorre (push, PR, tag, etc.).

---

## COMPARAÇÃO: Webhook vs Polling SCM

| Aspecto | Webhook | Polling SCM |
|---------|---------|------------|
| **Latência** | Instantânea (< 1s) | Até 5 minutos |
| **Carga no Jenkins** | Mínima (apenas quando há evento) | Alta (verifica constantemente) |
| **Carga no Git** | Mínima | Alta (centenas de chamadas/dia) |
| **Confiabilidade** | Depende do servidor Git estar ativo | Funciona mesmo com instabilidade |
| **Configuração** | Mais trabalhosa | Simples (apenas o Jenkinsfile) |
| **Recomendado** | ✅ Produção | ⚠️ Dev/teste ou fallback |

---

## CONFIGURAÇÃO: GITHUB → JENKINS

### Pré-requisitos
- Jenkins acessível publicamente (não localhost)
- Plugin "GitHub" instalado no Jenkins
- Token de acesso pessoal no GitHub com escopo `admin:repo_hook`

### Passo 1: Gerar Token no GitHub
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Escopos necessários: `repo`, `admin:repo_hook`
4. Copie o token gerado

### Passo 2: Configurar no Jenkins
1. Manage Jenkins → System → GitHub
2. Add GitHub Server
3. API URL: `https://api.github.com`
4. Credentials: Add → Secret text → cole o token do GitHub
5. Test connection → deve mostrar "Credentials verified"
6. Save

### Passo 3: Configurar o Webhook no GitHub
1. Vá no repositório GitHub → Settings → Webhooks
2. Add webhook:
   ```
   Payload URL: http://SEU-JENKINS:8080/github-webhook/
   Content type: application/json
   Secret: (opcional, mas recomendado — configure o mesmo no Jenkins)
   Which events: Just the push event (ou escolha outros)
   Active: ✅
   ```
3. Add webhook

### Passo 4: Configurar o Job no Jenkins
Em um Pipeline job:
1. Aba "Build Triggers"
2. Marque: "GitHub hook trigger for GITScm polling"
3. Save

Em um Multibranch Pipeline:
- Automático quando o plugin GitHub Branch Source está instalado

### Verificar Funcionamento
1. Faça um commit no repositório
2. GitHub → Webhook → Recent Deliveries → deve mostrar `200 OK`
3. Jenkins deve iniciar um build automaticamente

---

## CONFIGURAÇÃO: GITLAB → JENKINS

### Passo 1: Plugin GitLab
Instale o plugin "GitLab" no Jenkins.

### Passo 2: Webhook URL no Jenkins
```
http://SEU-JENKINS:8080/project/NOME-DO-JOB
```

### Passo 3: Criar Webhook no GitLab
1. Projeto GitLab → Settings → Webhooks
2. URL: `http://SEU-JENKINS:8080/project/NOME-DO-JOB`
3. Secret Token: (gere um token no Jenkins e coloque aqui)
4. Trigger: Push events, Merge request events
5. Add webhook

### Passo 4: Configurar Job Jenkins
No Build Triggers, marque "Build when a change is pushed to GitLab"

---

## SEGURANÇA DO WEBHOOK

### Verificação de Assinatura (HMAC)
Sem verificação, qualquer pessoa pode enviar um POST falso ao Jenkins
e disparar builds. Configure um Secret Token:

**No GitHub:**
1. Defina um Secret no webhook (string aleatória segura)
2. GitHub assina cada payload com esse secret usando HMAC-SHA256

**No Jenkins:**
1. Add Credentials → Secret text → cole o mesmo secret
2. Configure o plugin GitHub para verificar a assinatura

**Equivalente manual** (se precisar verificar):
```bash
# GitHub envia o header: X-Hub-Signature-256: sha256=HASH
# Verificação:
echo -n "payload" | openssl sha256 -hmac "seu-secret"
```

---

## NGINX como Proxy Reverso (Jenkins atrás de firewall)

Se Jenkins não é acessível diretamente da internet:

```nginx
server {
    listen 443 ssl;
    server_name jenkins.empresa.com;

    ssl_certificate     /etc/ssl/jenkins.crt;
    ssl_certificate_key /etc/ssl/jenkins.key;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

---

## PERGUNTAS DE ENTREVISTA

**Q: Por que webhook é melhor que polling SCM em produção?**

> **Resposta**: O polling verifica o Git a cada N minutos,
> independente de haver mudanças — gera carga desnecessária no
> Jenkins e no servidor Git, e tem latência de até N minutos.
> O webhook é uma notificação push: o GitHub/GitLab avisa o Jenkins
> instantaneamente quando há um evento. Resultado: builds mais
> rápidos, menos carga nos sistemas, e feedback mais ágil.
