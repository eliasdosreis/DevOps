# ============================================================
# MÓDULO 11 — SEGURANÇA E GOVERNANÇA
# Arquivo: 11-conceitos.md
# ============================================================

# Módulo 11: Segurança e Governança

---

## 1. MODELO DE SEGURANÇA DO JENKINS

```
┌─────────────────────────────────────────────────────┐
│  CAMADA 1: Autenticação                             │
│  "Quem é você?" → LDAP, SAML, OAuth, Local DB       │
├─────────────────────────────────────────────────────┤
│  CAMADA 2: Autorização                              │
│  "O que você pode fazer?" → RBAC, Matrix            │
├─────────────────────────────────────────────────────┤
│  CAMADA 3: Script Security                          │
│  "O que o código pode executar?" → Sandbox          │
├─────────────────────────────────────────────────────┤
│  CAMADA 4: Credentials Security                     │
│  "Quais secrets você pode usar?" → Credentials Scope│
├─────────────────────────────────────────────────────┤
│  CAMADA 5: Audit                                    │
│  "Quem fez o quê?" → Audit Trail Plugin             │
└─────────────────────────────────────────────────────┘
```

---

## 2. PERGUNTAS DE ENTREVISTA

**Q1: O que é o Script Security Plugin e por que é importante?**

> **Resposta**: O Script Security Plugin cria um "sandbox" (caixa de areia)
> para scripts Groovy executados no Jenkins. Sem ele, qualquer desenvolvedor
> com acesso ao Jenkinsfile poderia executar código arbitrário no Controller
> (ler arquivos do sistema, executar comandos, acessar a rede). Com o plugin,
> métodos não aprovados são bloqueados. Admins revisam e aprovam explicitamente
> cada método novo usado em scripts. Isso implementa o princípio do menor
> privilégio para código no Jenkins.

**Q2: Como você controlaria que apenas o time de produção pode fazer deploy em produção?**

> **Resposta**: Com Role-Based Access Control (RBAC) via plugin role-strategy:
> (1) criar uma role `producao-deploy` com permissão de input approval,
> (2) usar Project Roles com padrão regex `prod.*` para restringir quais jobs
> essa role vê, (3) atribuir essa role apenas ao time de produção/DevOps,
> (4) no pipeline, usar `input(submitter: 'user1,tech-lead')` para restringir
> quem pode aprovar o deploy. Assim, mesmo que um dev tenha acesso ao job,
> não consegue aprovar o stage de produção.
