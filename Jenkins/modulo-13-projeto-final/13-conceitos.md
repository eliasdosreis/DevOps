# ============================================================
# MÓDULO 13 — PROJETO FINAL SENIOR
# Arquivo: 13-conceitos.md
#
# Visão arquitetural completa do Projeto Final
# ============================================================

# Módulo 13: Projeto Final Senior — Visão Arquitetural

---

## 1. ARQUITETURA DO PIPELINE FINAL

```
┌──────────────────────────────────────────────────────────────────┐
│                    PIPELINE SENIOR COMPLETO                       │
│                                                                  │
│  [Git Push/PR]                                                   │
│       ↓                                                          │
│  📦 Checkout ──→ 🔨 Build ──→ ┬→ 🧪 Testes Unitários           │
│                               ├→ 🔗 Testes Integração  (paralelo)
│                               └→ 📋 Lint & Code Style            │
│                                      ↓ (tudo OK)                │
│                               📦 Package (JAR/WAR)              │
│                                      ↓                          │
│                               🔍 Quality Gate (SonarQube)       │
│                                      ↓ (aprovado)               │
│                               🐳 Docker Build                    │
│                                      ↓                          │
│                               🔒 Security Scan (Trivy)           │
│                                      ↓ (sem CVEs críticos)      │
│                               📤 Push Registry                   │
│                                      ↓                          │
│                               🧪 Deploy Staging                  │
│                                      ↓                          │
│                               🔬 Testes E2E                      │
│                                      ↓ (passou)                 │
│                               ⏳ Aprovação Manual                │
│                                      ↓ (aprovado)               │
│                               🚀 Deploy Produção                 │
│                                      ↓                          │
│                               ✅ Smoke Tests                     │
│                                      ↓ (OK) / ↓ (FALHOU)       │
│                               🎉 SUCESSO   / 🔄 Rollback        │
│                                      ↓                          │
│                               📢 Notificação Slack               │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. TECNOLOGIAS UTILIZADAS NO PROJETO FINAL

| Camada | Tecnologia | Propósito |
|--------|-----------|-----------|
| **SCM** | GitHub/GitLab | Versionamento |
| **CI** | Jenkins | Orquestração |
| **Build** | Maven/Gradle/npm | Compilação |
| **Qualidade** | SonarQube | Quality Gate |
| **Container** | Docker | Empacotamento |
| **Security** | Trivy | Scan CVE |
| **Registry** | Docker Hub/ECR | Armazenamento |
| **Deploy** | kubectl/Helm | Kubernetes |
| **Testes E2E** | Cypress/Selenium | Validação |
| **Notif.** | Slack/Email | Comunicação |
| **Monit.** | Prometheus/Grafana | Observabilidade |
| **Library** | Groovy Shared Library | Reuso |

---

## 3. DIFERENÇAS ENTRE UM PIPELINE JUNIOR E SENIOR

### Pipeline Junior:
```groovy
pipeline {
  agent any
  stages {
    stage('Build') { steps { sh 'mvn package' } }
    stage('Deploy') { steps { sh 'scp app.jar server:/opt/' } }
  }
}
```

### Pipeline Senior (o que construímos):
- ✅ `agent none` com agents específicos por stage
- ✅ Parallel para testes (economia de tempo)
- ✅ Quality Gate (nunca vai código ruim para prod)
- ✅ Security Scan (nunca vai CVE crítico para prod)
- ✅ Blue-Green com rollback automático
- ✅ Aprovação manual com submitters específicos
- ✅ Smoke tests pós-deploy com rollback automático
- ✅ Notificações ricas (Slack com contexto)
- ✅ Shared Library (código reutilizável)
- ✅ DORA metrics monitorados
- ✅ Tags imutáveis de imagem Docker
- ✅ Timeout em cada stage
- ✅ Política de retenção de builds
- ✅ Limpeza de workspace no post

---

## 4. COMO ESTUDAR ESTE MÓDULO

1. **Leia o pipeline final inteiro** (13-Jenkinsfile-projeto-final.groovy)
2. **Identifique cada parte**: onde está o Quality Gate? O rollback? A aprovação?
3. **Trace o fluxo**: o que acontece se os testes unitários falharem? E se o Trivy encontrar CVE?
4. **Tente recriar do zero**: sem olhar o arquivo, monte o pipeline no papel
5. **Estude as entrevistas**: hasta conseguir responder todas sem consultar
6. **Ensine para alguém**: se conseguir explicar cada decisão do pipeline, você é Senior

---

## 5. PRÓXIMOS PASSOS APÓS COMPLETAR O MÓDULO

1. **Jenkins Configuration as Code (JCasC)**: versionar TODA a configuração do Jenkins
2. **Argo CD / Flux**: GitOps para deploy contínuo em Kubernetes
3. **Tekton**: pipelines nativas de Kubernetes (alternativa ao Jenkins)
4. **GitHub Actions**: CI/CD nativo do GitHub (use junto com Jenkins para CD)
5. **Jenkins X**: Jenkins reimaginado para Kubernetes (cloud-native)
6. **Certificações**: CKA (Kubernetes) + estudo para entrevistas FAANG

---

*"Um Senior não é alguém que sabe todas as respostas.*
*É alguém que fez as perguntas certas o suficiente para saber*
*onde procurar e quando pedir ajuda."*
