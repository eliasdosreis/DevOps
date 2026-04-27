# ============================================================
# MÓDULO 9 — DEPLOY E ENTREGA CONTÍNUA
# Arquivo: 09-conceitos.md
# ============================================================

# Módulo 9: Deploy e Entrega Contínua

---

## 1. ESTRATÉGIAS DE DEPLOY: COMPARAÇÃO COMPLETA

| Estratégia | Downtime | Risco | Rollback | Complexidade | Custo de infra |
|-----------|---------|-------|----------|-------------|---------------|
| **Recreate** | ✅ Sim | Alto | Lento | Baixa | Normal |
| **Rolling** | ❌ Não | Médio | Médio | Média | Normal |
| **Blue-Green** | ❌ Não | Baixo | Instantâneo | Alta | 2x |
| **Canary** | ❌ Não | Mínimo | Rápido | Alta | 1.1x |
| **A/B Testing** | ❌ Não | Mínimo | Rápido | Muito Alta | 1.x |

---

## 2. ROLLING DEPLOY (Kubernetes padrão)

```
Pods:  [v1][v1][v1][v1]  → Deploy v2
       [v1][v1][v1][v2]  → + 1 pod v2, - 1 pod v1
       [v1][v1][v2][v2]  → progride...
       [v2][v2][v2][v2]  → 100% na v2
```

`maxSurge`: quantos pods extras durante o deploy  
`maxUnavailable`: quantos pods podem ficar indisponíveis

---

## 3. BLUE-GREEN DEPLOY

```
ANTES:  LB → [Blue v1][Blue v1][Blue v1]  (100% tráfego)
             [Green --][Green --][Green--]  (vazio)

DEPLOY: LB → [Blue v1][Blue v1][Blue v1]  (100% tráfego continua)
             [Green v2][Green v2][Green v2] (novo deploy aqui)

SWITCH: LB → [Blue v1][Blue v1][Blue v1]  (standby para rollback)
                ↑ switch do load balancer ↑
             [Green v2][Green v2][Green v2] (100% tráfego)

ROLLBACK (instantâneo): switch de volta para Blue
```

---

## 4. CANARY DEPLOY

```
Inicial:  LB → [v2: 10%][v1: 90%]
Análise:       Monitorar erros, latência, métricas de negócio
Aprovar:  LB → [v2: 50%][v1: 50%]
Análise:       Monitorar novamente
Final:    LB → [v2: 100%]
```

**Ferramenta**: Argo Rollouts, Flagger (Flagger + Prometheus = automático)

---

## 5. INPUT: BOAS PRÁTICAS

```groovy
// ✅ Sempre use timeout — builds não devem ficar parados para sempre
timeout(time: 24, unit: 'HOURS') {
  input(
    message: "Confirma deploy?",
    submitter: 'admin,tech-lead',     // Controle de quem pode aprovar
    ok: 'Aprovar Deploy'
  )
}

// ✅ Capture o aprovador
def aprovador = input(
  message: "Deploy em produção?",
  submitter: 'admin',
  submitterParameter: 'APROVADO_POR'  // Nome do usuário que aprovou
)
```

---

## 6. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre Rolling Deploy e Blue-Green? Quando usar cada um?**

> **Resposta**: Rolling Deploy substitui pods gradualmente (sem downtime,
> mas com versões mistas durante o processo). Melhor para: casos onde
> o custo de infra é limitante e pode-se tolerar versões mistas brevemente.
> Blue-Green mantém dois ambientes completos; o switch é instantâneo e
> o rollback é imediato. Melhor para: sistemas onde versões mistas causam
> problemas (ex: mudanças de schema de banco), onde rollback rápido é crítico.
> Desvantagem do Blue-Green: requer 2x a infra durante o deploy.

**Q2: Como implementar rollback automático em um pipeline Jenkins?**

> **Resposta**: Após o deploy, executar verificações (health check, taxa de
> erro no Prometheus, smoke tests). Se as métricas estiverem fora do threshold:
> `kubectl rollout undo deployment/app` para Kubernetes; `helm rollback app`
> para Helm; ou `kubectl set image` com a versão anterior. Marcar o build
> como FAILURE e enviar alerta. O segredo é ter health checks automatizados
> e thresholds bem definidos antes do deploy acontecer.
