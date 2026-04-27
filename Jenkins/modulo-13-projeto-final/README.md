# Módulo 13 — Projeto Final Senior

## O que você vai construir

Um pipeline **completo e production-ready** de uma aplicação multi-camadas:

```
Checkout → Build → Test → Quality Gate → Docker Build
→ Push para Registry → Deploy em Staging → Testes E2E
→ Aprovação Manual → Deploy em Produção → Notificação
```

## Diferenciais Senior neste projeto

- ✅ Shared Library para código reutilizável
- ✅ Agentes Docker e Kubernetes
- ✅ Deploy Blue-Green com rollback automático
- ✅ Quality Gate com SonarQube
- ✅ Scan de vulnerabilidades com Trivy
- ✅ Notificações Slack com status detalhado
- ✅ Parâmetros de pipeline para controle flexível

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `13-Jenkinsfile-projeto-final.groovy` | Pipeline completo production-ready |
| `13-Jenkinsfile-staging.groovy` | Pipeline específico do ambiente staging |
| `13-Jenkinsfile-producao.groovy` | Pipeline específico do ambiente produção |
| `shared-library/` | Shared Library usada pelo projeto final |
| `k8s/` | Manifests Kubernetes para deploy |
| `13-simulacao-entrevista.md` | Perguntas e respostas para entrevista Senior |
| `13-conceitos.md` | Visão arquitetural do projeto final |

## Como usar este módulo

1. **Certifique-se de ter concluído todos os módulos anteriores**
2. Leia `13-conceitos.md` para entender a arquitetura
3. Execute o pipeline e depure qualquer erro encontrado
4. Estude `13-simulacao-entrevista.md` até conseguir responder sem consultar
5. Tente recriar o pipeline do zero sem olhar o arquivo
