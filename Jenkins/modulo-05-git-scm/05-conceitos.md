# ============================================================
# MÓDULO 5 — INTEGRAÇÃO COM GIT E SCM
# Arquivo: 05-conceitos.md
# ============================================================

# Módulo 5: Integração com Git e SCM

---

## 1. CHECKOUT: AS 3 FORMAS PRINCIPAIS

| Forma | Código | Quando Usar |
|-------|--------|-------------|
| Automático | `checkout scm` | Sempre — em pipelines "from SCM" |
| Simples | `git url: '...', branch: 'main'` | Repos adicionais simples |
| Completo | `checkout([...])` | Configurações avançadas |

**Regra de ouro**: Use `checkout scm` na maioria dos casos.
O Jenkins já conhece o repo pelo qual encontrou o Jenkinsfile.

---

## 2. MULTIBRANCH PIPELINE

Um Multibranch Pipeline:
- Escaneia todos os branches do repositório
- Cria um job automaticamente para cada branch com Jenkinsfile
- Remove o job automaticamente quando o branch é deletado
- Permite comportamentos diferentes por branch via `when { branch }`

```
Jenkins
└── minha-app (Multibranch Pipeline)
    ├── main        ← Job criado automaticamente
    ├── develop     ← Job criado automaticamente
    ├── feature/auth ← Job criado automaticamente
    └── hotfix/bug-123 ← Job criado automaticamente
```

---

## 3. GITFLOW vs TRUNK-BASED DEVELOPMENT

### GitFlow
```
main ←────────────────────────────────────── produção
  ↑
develop ←─────────────────────────────────── integração
  ↑
feature/ ─────────────────────────────────── funcionalidades
release/ ─────────────────────────────────── preparação
hotfix/  ─────────────────────────────────── emergências
```

**Prós**: Múltiplas versões em produção, releases planejadas  
**Contras**: Merges complexos, branches de longa duração, merge hell

### Trunk-Based Development
```
main ←─────────────────────────────────────── único branch permanente
  ↑
feature/ ─────────────────────────────────── vida curta (< 2 dias)
```

**Prós**: Integração contínua real, sem merge hell, feedback rápido  
**Contras**: Exige feature flags, time disciplinado, testes maduros

**No mercado hoje**: Enterprise usa GitFlow; startups e times maduros usam Trunk-Based.

---

## 4. VARIÁVEIS GIT DISPONÍVEIS NO PIPELINE

| Variável | Disponível em | Valor Exemplo |
|----------|--------------|---------------|
| `GIT_BRANCH` | Após `checkout` | `origin/main` |
| `GIT_COMMIT` | Após `checkout` | `a3f9c12b...` |
| `GIT_URL` | Após `checkout` | `https://github.com/org/repo.git` |
| `GIT_AUTHOR_NAME` | Após `checkout` | `João Silva` |
| `BRANCH_NAME` | Multibranch Pipeline | `main` ou `feature/auth` |
| `CHANGE_ID` | Multibranch + PR | `42` |
| `CHANGE_TARGET` | Multibranch + PR | `main` |
| `CHANGE_BRANCH` | Multibranch + PR | `feature/auth` |

---

## 5. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre `checkout scm` e `git url: '...'` no pipeline?**

> **Resposta**: `checkout scm` usa as configurações do próprio job Jenkins
> (o repositório e branch definidos em "Pipeline script from SCM"). É dinâmico
> e não precisa de URL hardcoded. `git url: '...'` especifica explicitamente
> o repositório — útil para clonar repositórios adicionais. Para o repositório
> principal do pipeline, sempre prefira `checkout scm`.

**Q2: Como funciona o Multibranch Pipeline do Jenkins?**

> **Resposta**: O Multibranch Pipeline escaneia todos os branches de um
> repositório Git e cria um job Jenkins para cada branch que contenha um
> Jenkinsfile. Quando um branch é criado, o job é criado automaticamente.
> Quando o branch é deletado, o job é arquivado/removido. Cada branch
> executa seu próprio pipeline de forma independente, mas todos compartilham
> o mesmo Jenkinsfile (que pode ter comportamento condicional usando
> `BRANCH_NAME` e a diretiva `when`).
