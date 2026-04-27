# ============================================================
# MÓDULO 0 — ARQUITETURA JENKINS
# Arquivo: 00-arquitetura.md
#
# Leia este arquivo ANTES de instalar qualquer coisa.
# Entender a arquitetura é o que separa o Senior do Junior.
# ============================================================

# Arquitetura Jenkins: Controller, Agents e Executors

---

## 1. ANALOGIA DO DIA A DIA

Imagine uma **fábrica de carros**:

- O **Controller** é o **gerente da fábrica**: ele recebe os pedidos
  (builds), decide quem vai fazer o trabalho, acompanha o progresso
  e registra os resultados. Ele **NÃO faz o trabalho braçal**.

- Os **Agents** são as **linhas de montagem**: cada uma é especializada
  (uma monta motor, outra pinta, outra faz testes). São elas quem
  realmente executam o trabalho.

- Os **Executors** são os **operários de cada linha**: cada linha pode
  ter 1, 2 ou mais operários trabalhando ao mesmo tempo (em paralelo).

- O **Jenkinsfile** é a **ordem de serviço**: descreve exatamente o
  que deve ser feito, em que ordem, em qual linha de montagem.

---

## 2. DEFINIÇÃO TÉCNICA SENIOR

### Controller (Master)

O Controller é o processo central do Jenkins. Suas responsabilidades:

- **Scheduling**: Recebe requisições de build e decide quando e onde executar
- **Orquestração**: Distribui trabalho para os Agents via protocolo JNLP ou SSH
- **Persistência**: Armazena configurações, histórico de builds, credentials
- **Interface**: Serve a UI web e a API REST
- **Plugin Engine**: Carrega e gerencia todos os plugins instalados

> ⚠️ **O Controller NUNCA deve executar builds em produção.**
> Builds no Controller consomem seus recursos e criam riscos de segurança.
> Configure `agent none` nos pipelines e use agents dedicados.

### Agent (Worker / Node)

Um Agent é qualquer máquina conectada ao Controller para executar builds.
Pode ser:

| Tipo | Descrição | Caso de uso |
|------|-----------|-------------|
| **Permanente** | Máquina física ou VM sempre disponível | Builds longos, ambientes fixos |
| **Efêmero (Docker)** | Container criado para um build, destruído após | Isolamento, limpeza garantida |
| **Efêmero (Kubernetes)** | Pod criado para um build, destruído após | Scale automático, cloud-native |
| **Built-in** | O próprio Controller (NÃO use em produção) | Apenas dev/teste local |

### Executor

Um Executor é uma **thread de execução** dentro de um Agent.

- 1 Agent com 2 Executors = pode rodar 2 builds simultaneamente
- Configurado em: `Manage Jenkins → Nodes → <agent> → Number of Executors`
- O número ideal de executors = número de CPUs do agente (evita sobrecarga)

### Job / Pipeline

A unidade de trabalho no Jenkins. Tipos principais:

| Tipo | Descrição |
|------|-----------|
| **Freestyle** | Job simples via interface gráfica (poucos recursos) |
| **Pipeline** | Job definido em Groovy via Jenkinsfile (recomendado) |
| **Multibranch Pipeline** | Pipeline automático por branch do Git |
| **Organization Folder** | Escaneia toda uma organização GitHub/GitLab |

---

## 3. FLUXO DE UM BUILD (do início ao fim)

```
1. Trigger (webhook, cron, manual)
       ↓
2. Controller recebe a requisição
       ↓
3. Controller lê o Jenkinsfile do repositório Git
       ↓
4. Controller escolhe um Agent disponível com o label correto
       ↓
5. Agent baixa o workspace do Git
       ↓
6. Agent executa cada stage/step do Jenkinsfile
       ↓
7. Agent envia resultados de volta ao Controller
       ↓
8. Controller salva logs, artefatos e status do build
       ↓
9. Controller dispara notificações (email, Slack, etc.)
```

---

## 4. CONCEITO SENIOR: Por que separar Controller e Agent?

### Segurança
- O Controller tem acesso a credentials, configs e toda a infra
- Código desconhecido de PRs deve rodar APENAS em agents isolados
- Um agent comprometido não afeta o Controller

### Escalabilidade
- Você pode adicionar agents dinamicamente conforme a demanda cresce
- Agents podem ser destruídos após o build (sem estado sujo acumulado)
- Kubernetes agents escalam de 0 a N pods conforme a fila de builds

### Especialização
- Agent Linux com Docker para builds de containers
- Agent Windows para builds .NET
- Agent com GPU para builds de ML (machine learning)
- Cada agent tem apenas o que precisa instalado

### Resiliência
- Se um Agent cair, o Controller redistribui o build para outro Agent
- O Controller continua funcionando mesmo com agents offline

---

## 5. PERGUNTAS DE ENTREVISTA

**Q1: Por que não se deve executar builds no Controller do Jenkins?**

> **Resposta esperada**: O Controller é o cérebro do Jenkins — gerencia
> configurações, credentials, plugins e orquestração. Executar builds nele
> cria riscos de segurança (código arbitrário com acesso a tudo), consome
> recursos que deveriam ser dedicados ao gerenciamento, e pode derrubar
> o Controller inteiro caso um build consuma muita memória ou CPU.
> A boa prática é definir `agent none` no nível do pipeline e especificar
> agents dedicados em cada stage.

**Q2: Qual a diferença entre um Executor e um Agent?**

> **Resposta esperada**: Um Agent é uma máquina (física, VM ou container)
> conectada ao Controller Jenkins. Um Executor é uma thread de execução
> dentro desse Agent — ou seja, um Agent pode ter múltiplos Executors
> rodando builds em paralelo. Por exemplo, uma máquina com 4 CPUs pode
> ter 4 Executors, permitindo 4 builds simultâneos.
