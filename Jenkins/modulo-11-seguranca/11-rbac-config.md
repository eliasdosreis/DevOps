# ============================================================
# MÓDULO 11 — SEGURANÇA E GOVERNANÇA
# Arquivo: 11-rbac-config.md
# ============================================================

# Configurando RBAC (Role-Based Access Control) no Jenkins

---

## 1. ANALOGIA: Níveis de Acesso no Banco

- **Anônimo**: só vê a placa na porta do banco
- **Desenvolvedor**: vê builds, não mexe em configurações
- **Tech Lead**: aprova builds manuais, vê tudo de sua equipe
- **DevOps Engineer**: configura jobs, não pode deletar outros usuários
- **Admin**: faz tudo, inclusive cria outros admins

---

## 2. PLUGINS NECESSÁRIOS

```
Role-based Authorization Strategy
(Plugin: role-strategy)
```

Instale em: Manage Jenkins → Plugins → Available → "Role-based Authorization Strategy"

---

## 3. CONFIGURAR AUTORIZAÇÃO POR MATRIZ (Matrix Authorization)

### Ativar o plugin:
1. Manage Jenkins → Security → Authorization
2. Selecione: **"Role-Based Strategy"**
3. Save

---

## 4. CRIAR ROLES (Perfis de Acesso)

### Caminho: Manage Jenkins → Manage and Assign Roles → Manage Roles

### Role: `viewer` (Somente Leitura)
```
Overall:
  ✅ Read

Job:
  ✅ Read
  ✅ Workspace

View:
  ✅ Read
```

### Role: `developer` (Desenvolvedor)
```
Overall:
  ✅ Read

Job:
  ✅ Build
  ✅ Cancel
  ✅ Read
  ✅ Workspace

View:
  ✅ Read

Run:
  ✅ Delete
  ✅ Replay
  ✅ Update
```

### Role: `tech-lead` (Tech Lead / Aprovador)
```
# Tudo do developer mais:

Job:
  ✅ Configure  (pode editar jobs)
  ✅ Create     (pode criar jobs)

Build:
  ✅ Approve input  (pode aprovar builds manuais)
```

### Role: `devops` (DevOps Engineer)
```
# Tudo do tech-lead mais:

Overall:
  ✅ Administer (para configurações específicas de infra)

Node:
  ✅ Configure
  ✅ Connect
  ✅ Create
  ✅ Delete
  ✅ Disconnect
```

### Role: `admin` (Administrador Total)
```
Overall:
  ✅ Administer  (todas as permissões)
```

---

## 5. ROLES DE PROJETO (Project Roles)

Permite restringir quem acessar QUAIS jobs usando padrões regex:

```
Role:    time-backend
Pattern: (backend|api|service).*   ← Regex que combina com nomes de jobs

Assign:  usuarios do time backend
```

```
Role:    time-frontend
Pattern: (frontend|web|app).*

Assign:  usuarios do time frontend
```

Com isso:
- Time Backend vê e executa apenas jobs de backend
- Time Frontend vê e executa apenas jobs de frontend
- Times não interferem um no outro

---

## 6. ATRIBUIR ROLES AOS USUÁRIOS

### Caminho: Manage Jenkins → Manage and Assign Roles → Assign Roles

**Global Roles:**
| Usuário | Role |
|---------|------|
| `admin` | admin |
| `devops-1` | devops |
| `tech-lead-1` | tech-lead |
| `dev-1` | developer |
| `qa-1` | viewer |

**Project Roles:**
| Usuário | Padrão | Role |
|---------|--------|------|
| `dev-1` | `backend.*` | time-backend |
| `dev-2` | `frontend.*` | time-frontend |

---

## 7. BOAS PRÁTICAS DE SEGURANÇA

### Princípio do Menor Privilégio
```
❌ Dar permissão de admin para todos "porque é mais fácil"
✅ Dar apenas as permissões necessárias para a função
```

### Separação de Ambientes
```
# jobs de produção: apenas devops e admin podem configurar
Pattern: prod.*   → Role: devops, admin

# jobs de staging: devs e tech leads podem configurar
Pattern: staging.*  → Role: developer, tech-lead, devops, admin
```

### Auditoria Regular
- Revisar permissões trimestralmente
- Remover usuários que saíram da empresa imediatamente
- Registrar todas as mudanças de permissão
