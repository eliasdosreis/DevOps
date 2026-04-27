# ============================================================
# MÓDULO 12 — MONITORAMENTO E OBSERVABILIDADE
# Arquivo: 12-conceitos.md
# ============================================================

# Módulo 12: Monitoramento e Observabilidade

---

## 1. AS 4 DORA METRICS — O PADRÃO SENIOR

**DORA** (DevOps Research and Assessment) definiu 4 métricas que
medem a maturidade de um time de DevOps:

| Métrica | O que mede | Elite | Alto | Médio | Baixo |
|---------|-----------|-------|------|-------|-------|
| **Deployment Frequency** | Com que frequência é deploiado | Múltiplas vezes/dia | 1x/semana | 1x/mês | < 1x/mês |
| **Lead Time for Changes** | Do commit até produção | < 1 hora | 1 dia | 1 semana | 1 mês |
| **Change Failure Rate** | % de deploys que causam incidentes | < 5% | 10% | 15% | > 15% |
| **MTTR** | Tempo para recuperar de falha | < 1 hora | < 1 dia | < 1 semana | > 1 mês |

---

## 2. OBSERVABILIDADE vs MONITORAMENTO

```
Monitoramento: "Sei que algo está errado" (dashboards, alertas)
Observabilidade: "Entendo POR QUE está errado" (logs, traces, métricas)

Os 3 pillares da Observabilidade:
┌──────────┐  ┌──────────┐  ┌──────────┐
│  MÉTRICAS │  │   LOGS   │  │  TRACES  │
│ Prometheus│  │  ELK/    │  │  Jaeger  │
│  Grafana  │  │ Loki/    │  │  Zipkin  │
│           │  │ Splunk   │  │          │
└──────────┘  └──────────┘  └──────────┘
```

---

## 3. POLÍTICA DE RETENÇÃO DE BUILDS

```groovy
// No pipeline (pipeline-level):
options {
  buildDiscarder(logRotator(
    numToKeepStr:         '30',   // Mantém últimos 30 builds
    daysToKeepStr:        '60',   // Mantém builds dos últimos 60 dias
    artifactNumToKeepStr: '5',    // Mantém artefatos de 5 builds
    artifactDaysToKeepStr: '30'   // Mantém artefatos por 30 dias
  ))
}
```

**Regra**: Builds de main/develop retêm mais; feature branches retêm menos.

---

## 4. PERGUNTAS DE ENTREVISTA

**Q: Se o p99 de latência de um endpoint aumentou 300% logo após um deploy, como você investigaria usando o Jenkins?**

> **Resposta**: (1) No Jenkins, verifico o build correspondente pelo timestamp
> do aumento de latência. (2) Uso o fingerprint do artefato para identificar
> exatamente qual versão foi deployada. (3) Comparo o diff do código entre
> a versão atual e a anterior (`git diff v1.0-prev v1.0-curr`). (4) Verifico
> os logs do build para warnings de performance. (5) Disparo o rollback
> automático via `kubectl rollout undo`. (6) Após estabilizar, analiso
> o código problemático com profiling. O Jenkins é o hub central: liga
> o alerta de produção ao artefato, ao commit e ao desenvolvedor responsável.
