# Módulo 12 — Monitoramento e Observabilidade

## O que você vai aprender

- Monitorando Jenkins com Prometheus + Grafana
- Alertas de falha por email, Slack, Teams
- Build metrics: duração, taxa de sucesso, flaky tests
- Log management e retenção de builds
- Plugin de Monitoring e Metrics do Jenkins

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `12-Jenkinsfile-notificacao-email.groovy` | Notificações por email |
| `12-Jenkinsfile-notificacao-slack.groovy` | Notificações no Slack |
| `12-Jenkinsfile-notificacao-teams.groovy` | Notificações no Microsoft Teams |
| `12-prometheus-grafana.md` | Guia de setup Prometheus + Grafana para Jenkins |
| `12-docker-compose-monitoring.yml` | Stack de monitoramento completa em Docker |
| `12-grafana-dashboard.json` | Dashboard Grafana pré-configurado para Jenkins |
| `12-conceitos.md` | Explicação teórica completa do módulo |

## Ordem de estudo

1. Leia `12-conceitos.md`
2. Suba a stack de monitoramento com `12-docker-compose-monitoring.yml`
3. Importe o dashboard `12-grafana-dashboard.json` no Grafana
4. Execute os pipelines de notificação
