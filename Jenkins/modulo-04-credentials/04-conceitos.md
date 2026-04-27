# ============================================================
# MÓDULO 4 — CREDENTIALS E SECRETS
# Arquivo: 04-conceitos.md
# ============================================================

# Módulo 4: Credentials e Secrets

---

## 1. ANALOGIA DO DIA A DIA

O Credentials Store do Jenkins é como um **cofre bancário corporativo**:

- O **cofre** (Credentials Store) guarda todos os segredos
- Cada **item no cofre** (Credential) tem um endereço único (ID)
- Os **funcionários** (jobs/pipelines) não sabem o que está no cofre — apenas usam a chave
- O **gerente do banco** (Jenkins admin) decide quem pode abrir qual gaveta
- Os **logs** registram quando cada gaveta foi acessada (auditoria)

---

## 2. TIPOS DE CREDENTIALS

| Tipo | Quando Usar | Variáveis Geradas |
|------|-------------|-------------------|
| **Secret Text** | Tokens de API, webhooks | `NOME` |
| **Username/Password** | Login em registries, databases, APIs | `NOME_USR`, `NOME_PSW` |
| **SSH Username with Private Key** | Acesso a servidores, clone SSH | `KEY_FILE`, `USERNAME` |
| **Secret File** | Arquivos JSON (GCP SA), certificados | `NOME` (caminho do arquivo) |
| **Certificate (PKCS#12)** | Autenticação mútua TLS | `KEYSTORE_FILE`, `PASSWORD` |
| **GitHub App** | GitHub Actions integration | Token gerado automaticamente |

---

## 3. GUIA: CADASTRANDO CREDENTIALS NA INTERFACE

### Caminho: `Manage Jenkins → Credentials → System → Global credentials (unrestricted)`

### Passo a Passo para Secret Text:
1. Clique em **"Add Credentials"**
2. **Kind**: Secret text
3. **Scope**: Global (visível para todos os jobs)
4. **Secret**: Cole o valor do token
5. **ID**: `slack-webhook-token` (use sempre snake-case)
6. **Description**: Descrição humana do que é essa credential
7. **Create**

### IDs Recomendados (convenção de nomenclatura):

```
# Padrão: ambiente-servico-tipo
prod-docker-hub-token
staging-aws-access-key
global-slack-webhook
dev-postgres-credentials
github-deploy-ssh-key
sonarqube-analysis-token
```

---

## 4. COMO O JENKINS MASCARA SECRETS NOS LOGS

O Jenkins mantém uma lista de todos os valores de credentials
usados em um build. Qualquer ocorrência desses valores no log
é substituída por `****`.

```
# Log REAL que o Jenkins gera:
Enviando request para API...
Authorization: Bearer ****
Response: 200 OK

# O que você veria sem o mascaramento:
Authorization: Bearer meu-token-super-secreto-abc123
```

**Limitações**: O Jenkins mascara strings exatas. Se o token for
dividido em partes (`${TOKEN:0:5}` + `${TOKEN:5}`), pode não ser mascarado!

---

## 5. FORMAS DE USAR CREDENTIALS (comparação)

### Forma 1: environment { credentials() }
```groovy
environment {
  TOKEN = credentials('meu-token')  // Disponível em todo o pipeline
}
```
**+** Simples e conciso  
**-** Fica disponível em todos os stages (escopo amplo)

### Forma 2: withCredentials { }
```groovy
withCredentials([string(credentialsId: 'meu-token', variable: 'TOKEN')]) {
  // TOKEN só existe aqui dentro
}
```
**+** Escopo controlado (mais seguro)  
**+** Mais explícito — fica claro onde o secret é usado  
**-** Mais verboso

### Qual usar?
- **environment**: Credentials usadas em múltiplos stages
- **withCredentials**: Credentials pontualmente em um bloco específico

---

## 6. CONCEITO SENIOR: Hierarquia de Credentials

```
Jenkins Controller
└── System Credentials (apenas plugins Jenkins)
└── Global Credentials (todos os jobs)
└── Folder/Org Credentials (jobs da pasta)
    └── Job Credentials (apenas este job)
```

**Boas práticas de organização:**
- Use **Folders** (plugin CloudBees) para isolar credentials por equipe/ambiente
- Credentials de `prod` nunca devem ser visíveis para o pipeline de `dev`
- Cada equipe gerencia suas próprias credentials dentro da sua pasta

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: Como você garante que uma senha nunca aparece no log do Jenkins?**

> **Resposta**: Usando o Credentials Store do Jenkins e referenciando
> via `credentials()` ou `withCredentials`. O Jenkins automaticamente
> mascara todos os valores de credentials registrados nos logs. Além disso:
> (1) nunca concatenar a senha em strings de log, (2) usar `--password-stdin`
> em vez de argumentos `-p` em linha de comando, (3) remover arquivos
> temporários com secrets no bloco `post { always { } }`.

**Q2: Qual a diferença entre escopo Global e System no Credentials Store?**

> **Resposta**: O escopo **System** é para credentials internas do Jenkins
> (ex: configuração de servidor SMTP), não acessíveis nos pipelines.
> O escopo **Global** torna a credential acessível para todos os jobs e
> pipelines. Em ambientes com múltiplas equipes, é recomendado usar
> **Folders** (plugin CloudBees Folders) para criar escopos mais granulares:
> cada pasta pode ter suas próprias credentials, visíveis apenas para
> jobs dentro dessa pasta.
