# Módulo 8 — Agents e Nodes

## O que você vai aprender

- Arquitetura Controller/Agent em detalhe
- Configurando agentes: via SSH, JNLP, Docker, Kubernetes
- Labels de agentes e seleção inteligente
- Agentes efêmeros vs persistentes: trade-offs
- Pipeline em múltiplos agentes simultaneamente

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `08-Jenkinsfile-agent-any.groovy` | Execução no agente padrão (any) |
| `08-Jenkinsfile-agent-label.groovy` | Seleção de agente por label |
| `08-Jenkinsfile-agent-docker.groovy` | Agente Docker efêmero |
| `08-Jenkinsfile-agent-kubernetes.groovy` | Agente Kubernetes (pod efêmero) |
| `08-Jenkinsfile-multi-agent.groovy` | Pipeline rodando em múltiplos agentes |
| `08-agente-ssh-setup.md` | Guia de configuração de agente via SSH |
| `08-conceitos.md` | Explicação teórica completa do módulo |

## Ordem de estudo

1. Leia `08-conceitos.md`
2. Configure um agente SSH seguindo `08-agente-ssh-setup.md`
3. Execute na ordem: agent-any → agent-label → agent-docker → multi-agent
