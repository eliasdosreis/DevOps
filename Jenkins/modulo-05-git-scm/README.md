# Módulo 5 — Integração com Git e SCM

## O que você vai aprender

- Configurando integração com GitHub/GitLab/Bitbucket
- Checkout de repositórios no pipeline
- Webhooks: trigger automático no push/PR
- Multibranch Pipeline: pipeline por branch automaticamente
- Estratégias de branching: GitFlow, trunk-based development

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `05-Jenkinsfile-checkout.groovy` | Checkout básico de repositório Git |
| `05-Jenkinsfile-checkout-avancado.groovy` | Checkout com opções avançadas (shallow, sparse) |
| `05-Jenkinsfile-multibranch.groovy` | Configuração para Multibranch Pipeline |
| `05-Jenkinsfile-gitflow.groovy` | Pipeline adaptado para estratégia GitFlow |
| `05-webhook-setup.md` | Guia de configuração de webhooks GitHub/GitLab |
| `05-conceitos.md` | Explicação teórica completa do módulo |

## Ordem de estudo

1. Leia `05-conceitos.md`
2. Configure um repositório Git de teste
3. Execute na ordem: checkout → checkout-avancado → multibranch → gitflow
4. Configure o webhook seguindo `05-webhook-setup.md`
