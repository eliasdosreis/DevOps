# ============================================================
# MÓDULO 12 — MONITORAMENTO E OBSERVABILIDADE
# Arquivo: 12-prometheus-grafana.md
# ============================================================

# Monitorando Jenkins com Prometheus + Grafana

---

## 1. COMPONENTES DA STACK

```
Jenkins ──(métricas)──→ Prometheus ──(dados)──→ Grafana
                ↑                                   ↓
        /prometheus                          Dashboard
          endpoint                          (gráficos)
```

---

## 2. INSTALAR O PLUGIN PROMETHEUS NO JENKINS

1. Manage Jenkins → Plugins → Available
2. Buscar: "Prometheus metrics"
3. Instalar e reiniciar

### Verificar endpoint:
```
http://jenkins:8080/prometheus/
```

**Métricas expostas (exemplos):**
```
# Build duration
jenkins_builds_duration_milliseconds_summary{jenkins_job="minha-app"}

# Build result count
jenkins_builds_failed_build_count_total{jenkins_job="minha-app"}

# Agent online/offline
jenkins_node_online_value{node_name="agente-01"}

# Executor usage
jenkins_executor_in_use_value{node_name="agente-01"}

# Plugin count
jenkins_plugins_active
```

---

## 3. CONFIGURAR PROMETHEUS (prometheus.yml)

```yaml
global:
  scrape_interval: 30s

scrape_configs:
  - job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['jenkins:8080']
    # Se Jenkins requer autenticação:
    basic_auth:
      username: 'prometheus-reader'
      password: 'senha-segura'
```

---

## 4. MÉTRICAS MAIS IMPORTANTES

### 4.1 Taxa de Sucesso dos Builds
```promql
# % de builds com sucesso nos últimos 7 dias
rate(jenkins_builds_success_build_count_total[7d]) /
rate(jenkins_builds_build_count_total[7d]) * 100
```

### 4.2 Tempo Médio de Build (por job)
```promql
# Duração média em minutos dos últimos 100 builds
jenkins_builds_duration_milliseconds_summary{quantile="0.5"}
/ 60000
```

### 4.3 Builds Ativos (em execução)
```promql
jenkins_builds_available_executor_count
- jenkins_builds_executor_count
```

### 4.4 Agentes Offline
```promql
count(jenkins_node_online_value == 0)
```

### 4.5 Flaky Tests (builds intermitentes)
```promql
# Jobs que falharam E tiveram sucesso nas últimas 24h
increase(jenkins_builds_failed_build_count_total[24h]) > 0
```

---

## 5. ALERTAS PROMETHEUS

```yaml
# prometheus/rules/jenkins.yml
groups:
  - name: jenkins
    rules:

      # Alerta: Build em produção falhou
      - alert: JenkinsBuildFailed
        expr: |
          increase(jenkins_builds_failed_build_count_total{
            jenkins_job=~"prod.*"
          }[5m]) > 0
        for: 0m
        labels:
          severity: critical
        annotations:
          summary: "Build de produção falhou: {{ $labels.jenkins_job }}"
          description: "O pipeline {{ $labels.jenkins_job }} falhou. Verifique imediatamente."

      # Alerta: Todos os agentes offline
      - alert: JenkinsNoAgentsOnline
        expr: sum(jenkins_node_online_value) == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Jenkins sem agentes disponíveis!"

      # Alerta: Build demorando muito
      - alert: JenkinsBuildTooSlow
        expr: |
          jenkins_builds_duration_milliseconds_summary{quantile="0.9"} > 1800000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Build {{ $labels.jenkins_job }} demorando mais de 30min (p90)"
```

---

## 6. DASHBOARD GRAFANA

### Painéis recomendados:

| Painel | Métrica | Tipo |
|--------|---------|------|
| Taxa de Sucesso (7 dias) | success/total | Gauge |
| Builds por Hora | rate builds | Time Series |
| Tempo Médio de Build | duration p50 | Time Series |
| Builds Ativos Agora | executor usage | Stat |
| Agentes Online | node_online | Table |
| Top 5 Jobs que Mais Falham | failed count | Bar Chart |
| Fila de Builds | queue length | Time Series |

### Importar Dashboard Pré-Configurado:
1. Grafana → + → Import
2. ID do dashboard da comunidade: `9964` (Jenkins Metrics)
3. Selecione o datasource Prometheus
4. Import

---

## 7. PERGUNTAS DE ENTREVISTA

**Q: Que métricas você monitoraria para avaliar a saúde do CI/CD?**

> **Resposta**: As métricas key são:
> (1) **Taxa de sucesso dos builds** — meta: >95% em main
> (2) **Tempo médio de build** — meta: <15min, p90 <30min
> (3) **Lead time** — do commit ao deploy em produção
> (4) **MTTR** (Mean Time to Recovery) — quanto tempo para recuperar após falha
> (5) **Frequência de deploy** — deployments/dia ou semana
> (6) **Flaky tests** — % de testes que falham intermitentemente
> (7) **Executor utilization** — % de uso dos agents (identificar bottleneck)
> Essas métricas mapeiam diretamente para as DORA metrics de DevOps.
