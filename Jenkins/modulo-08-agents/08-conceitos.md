# ============================================================
# MÓDULO 8 — AGENTS E NODES
# Arquivo: 08-conceitos.md
# ============================================================

# Módulo 8: Agents e Nodes

---

## 1. TIPOS DE AGENTES

| Tipo | Como Conecta | Persistente? | Melhor Para |
|------|-------------|-------------|-------------|
| **Built-in** | Embutido no Controller | Sim | Apenas testes locais |
| **SSH** | Controller → Agent via SSH | Sim | VMs permanentes |
| **JNLP** | Agent → Controller | Sim | Agentes atrás de firewall |
| **Docker** | Container criado por build | Não (efêmero) | Isolamento, ferramentas |
| **Kubernetes** | Pod criado por build | Não (efêmero) | Cloud-native, scale |

---

## 2. EFÊMERO vs PERSISTENTE

```
PERSISTENTE (SSH, JNLP):
┌─────────────────────┐
│  Agent VM           │  Sempre ligando, esperando builds
│  Custo: 24/7        │  Estado pode acumular entre builds
│  Warm: Rápido       │  Bom para builds com muita cache
└─────────────────────┘

EFÊMERO (Docker, Kubernetes):
┌─────────────────────┐
│  Container/Pod      │  Criado ao iniciar o build
│  Custo: apenas uso  │  Estado zerado em cada build
│  Cold start: ~30s   │  Sempre ambiente limpo garantido
└─────────────────────┘
```

**Tendência**: Agentes efêmeros Kubernetes é o padrão em empresas modernas.

---

## 3. LABELS: CONVENÇÕES

```
# Por Sistema Operacional:
linux, windows, macos

# Por Ferramenta disponível:
docker, kubectl, helm, maven, gradle, nodejs, python

# Por Ambiente:
dev, staging, producao

# Por Capacidade hardware:
gpu, high-memory (64GB+), ssd, fast-network

# Por Região geográfica:
us-east, eu-west, ap-southeast

# Por Equipe/Projeto:
time-backend, time-frontend, time-dados
```

---

## 4. agent none: PADRÃO SENIOR

```groovy
// ❌ Junior: agent any (tudo no mesmo agente)
pipeline {
  agent any  // Todos os stages no mesmo lugar
  stages {
    stage('Build') { ... }   // Linux OK
    stage('Windows Test') { ... }  // ❌ Roda no Linux também!
  }
}

// ✅ Senior: agent none + agent por stage
pipeline {
  agent none
  stages {
    stage('Build') {
      agent { label 'linux' }
      steps { /* ... */ }
    }
    stage('Windows Test') {
      agent { label 'windows' }  // ✅ Roda no Windows de verdade!
      steps { /* ... */ }
    }
  }
}
```

---

## 5. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre agentes efêmeros e persistentes? Quando usar cada um?**

> **Resposta**: Agentes **persistentes** (SSH/JNLP) são VMs ou máquinas
> físicas sempre disponíveis. Vantagens: rápidos (sem cold start), bons
> para cache de dependências (Maven, npm). Desvantagens: custo fixo,
> estado pode acumular entre builds, não escalam automaticamente.
> Agentes **efêmeros** (Docker/Kubernetes) são criados por demanda para
> cada build e destruídos ao final. Vantagens: ambiente sempre limpo,
> escala automática de 0 a N, custo proporcional ao uso. Desvantagens:
> cold start de ~30s, cache precisa de volume persistente. **Em produção**,
> use Kubernetes para builds padrão e agentes persistentes para builds
> que precisam de machine learning, GPU ou caches muito grandes.

**Q2: O que acontece se você especificar `agent none` no nível do pipeline mas não definir agent em algum stage?**

> **Resposta**: O build falha com o erro "No agent was specified for
> stage X". Quando `agent none` é usado globalmente, CADA stage deve
> definir seu próprio agente explicitamente. Apenas o bloco `post` do
> pipeline pode executar sem agent definido por stage (ele usa o último
> agente alocado ou um agente builtin).
