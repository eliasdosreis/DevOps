# ============================================================
# MÓDULO 7 — DOCKER E CONTAINERS
# Arquivo: 07-conceitos.md
# ============================================================

# Módulo 7: Docker e Containers no Pipeline

---

## 1. PADRÕES DE TAG DE IMAGEM DOCKER

| Padrão | Exemplo | Quando Usar |
|--------|---------|-------------|
| `:latest` | `minha-app:latest` | Nunca em produção! Apenas dev |
| `:build-number` | `minha-app:42` | CI básico (não-semântico) |
| `:commit-hash` | `minha-app:a3f9c12b` | Rastreabilidade imutável |
| `:semver` | `minha-app:v1.2.3` | Releases oficiais |
| `:branch-build` | `minha-app:main-42` | Multibranch |
| `:date` | `minha-app:2024-01-15` | Builds diários |

**Melhor prática senior**: `{APP}:{VERSION}-{SHORT_COMMIT}`
Ex: `minha-app:v1.2.3-a3f9c12b` — versionado E rastreável

---

## 2. DOCKER AGENT: `reuseNode`

```groovy
// COM reuseNode: true
agent { docker { image 'node:18'; reuseNode true } }
// → Mesmo workspace do pipeline principal
// → Arquivos do checkout disponíveis
// → Mesmo agente físico

// SEM reuseNode (default: false)
agent { docker { image 'node:18' } }
// → Novo workspace vazio
// → Pode ser qualquer agente disponível
// → Precisa de checkout ou stash/unstash
```

---

## 3. TRIVY: SEVERIDADES DE CVE

| Severidade | Descrição | Ação |
|-----------|-----------|------|
| CRITICAL | Exploitável remotamente, trivial | Bloquear deploy imediatamente |
| HIGH | Exploitável com algum esforço | Bloquear deploy (threshold padrão) |
| MEDIUM | Exploitável com condições | Investigar, planejar correção |
| LOW | Impacto mínimo | Informativo |
| UNKNOWN | Sem classificação | Investigar |

---

## 4. MULTI-STAGE BUILD: BENEFÍCIOS

```
Imagem Builder (maven:3.9):  ~600MB
  ↓ (apenas o JAR)
Imagem Produção (jre-alpine): ~180MB
Economia: 70% de espaço + menor superfície de ataque
```

---

## 5. PERGUNTAS DE ENTREVISTA

**Q1: Por que nunca usar `:latest` como tag de imagem em produção?**

> **Resposta**: `:latest` é mutável — aponta para imagens diferentes ao
> longo do tempo. Se você deploiar `minha-app:latest` hoje e amanhã
> uma nova imagem for publicada com essa tag, um rollback buscaria a
> nova imagem, não a antiga. Em produção, use tags imutáveis como
> SHA do commit ou versão semântica. Assim, um rollback garante
> exatamente a mesma imagem que estava em produção.

**Q2: Qual a diferença entre montar o socket Docker (`/var/run/docker.sock`) e usar Docker-in-Docker real?**

> **Resposta**: **Socket mount** compartilha o daemon Docker do host com o
> container Jenkins — simples, rápido, mas perigoso: o container tem
> acesso total ao Docker do host (pode destruir qualquer container).
> **Docker-in-Docker (DinD)** roda um daemon Docker próprio dentro do
> container — mais isolado, mas mais complexo, mais lento e requer
> `--privileged`. Para CI, o socket mount é o mais comum porém exige
> controles de segurança rigorosos. Alternativa moderna: **Kaniko**
> (build sem Docker daemon, sem privilégios).
