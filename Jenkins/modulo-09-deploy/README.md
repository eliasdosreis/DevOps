# Módulo 9 — Deploy e Entrega Contínua

## O que você vai aprender

- Estratégias de deploy: rolling, blue-green, canary
- Deploy em servidores via SSH e Ansible
- Deploy em Kubernetes (kubectl, Helm)
- Deploy em cloud: AWS, GCP, Azure (exemplos)
- Aprovação manual com `input` antes de produção
- Rollback automatizado em caso de falha

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `09-Jenkinsfile-deploy-ssh.groovy` | Deploy em servidor via SSH |
| `09-Jenkinsfile-deploy-ansible.groovy` | Deploy orquestrado com Ansible |
| `09-Jenkinsfile-deploy-kubernetes.groovy` | Deploy em cluster Kubernetes |
| `09-Jenkinsfile-deploy-helm.groovy` | Deploy com Helm charts |
| `09-Jenkinsfile-blue-green.groovy` | Estratégia Blue-Green deploy |
| `09-Jenkinsfile-canary.groovy` | Estratégia Canary deploy |
| `09-Jenkinsfile-input-aprovacao.groovy` | Aprovação manual antes de produção |
| `09-Jenkinsfile-rollback.groovy` | Rollback automatizado em caso de falha |
| `09-conceitos.md` | Explicação teórica completa do módulo |

## Ordem de estudo

1. Leia `09-conceitos.md`
2. Execute na ordem: deploy-ssh → deploy-kubernetes → blue-green → input-aprovacao → rollback
