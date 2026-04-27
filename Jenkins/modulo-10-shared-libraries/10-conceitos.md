# ============================================================
# MÓDULO 10 — SHARED LIBRARIES
# Arquivo: 10-conceitos.md
# ============================================================

# Módulo 10: Shared Libraries

---

## 1. ANALOGIA: O Livro de Receitas da Empresa

Shared Libraries são o **livro de receitas padronizado** da empresa:
- **Sem library**: cada time inventa sua própria receita.
  Time A usa `mvn package`, Time B usa `mvn install`, Team C esquece de rodar lint.
- **Com library**: todos usam a mesma função `buildApp(tipo: 'maven')`.
  Uma correção na library se propaga para todos automaticamente.

---

## 2. ESTRUTURA PADRÃO DE UMA SHARED LIBRARY

```
jenkins-shared-library/
├── vars/                      ← Funções globais (chamadas diretamente)
│   ├── buildApp.groovy        ← def call(Map config) → buildApp(...)
│   ├── deployApp.groovy       ← def call(Map config) → deployApp(...)
│   ├── notifySlack.groovy     ← def call(Map config) → notifySlack(...)
│   └── standardPipeline.groovy ← Pipeline completo padrão
├── src/                       ← Classes Groovy (lógica complexa)
│   └── org/
│       └── empresa/
│           └── ci/
│               ├── Builder.groovy
│               └── Deployer.groovy
├── resources/                 ← Arquivos de recurso (scripts, templates)
│   └── scripts/
│       └── health-check.sh
└── test/                      ← Testes unitários da library (Spock)
    └── groovy/
        └── BuildAppTest.groovy
```

---

## 3. VARS vs SRC: QUANDO USAR CADA UM

| Característica | `vars/` | `src/` |
|---------------|---------|--------|
| **Acesso** | Direto: `buildApp(...)` | Via import: `new Org.Builder(this)` |
| **Escopo Pipeline** | ✅ Acesso completo ao pipeline | Limitado (precisa de `this`) |
| **Reutilização** | Por função | Via herança e interfaces |
| **Complexidade** | Simples a média | Complexa (classes, herança) |
| **Quando usar** | 90% dos casos | Lógica muito complexa, OOP |

---

## 4. CONFIGURAR A LIBRARY NO JENKINS

**Manage Jenkins → System → Global Pipeline Libraries → Add**

```
Name:           jenkins-shared-library
Default version: main
Load implicitly: false (recomendado)
Allow default version override: true

Source Code Management:
  Git: https://github.com/sua-org/jenkins-shared-library.git
  Credentials: github-ssh-key
```

---

## 5. VERSIONAMENTO DE LIBRARIES

```groovy
@Library('jenkins-shared-library')          // Versão padrão (main)
@Library('jenkins-shared-library@v2.1.0')   // Tag Git (recomendado para prod)
@Library('jenkins-shared-library@develop')  // Branch
@Library('jenkins-shared-library@abc1234')  // Commit hash (imutável)

// Multiple libraries:
@Library(['lib-a@v1.0', 'lib-b@v2.0']) _
```

**Estratégia de versionamento**:
- Desenvolvimento: `@main`
- Staging: `@v2.1.0`
- Produção: `@v2.0.0` (versão estável testada)

---

## 6. PERGUNTAS DE ENTREVISTA

**Q1: O que é uma Jenkins Shared Library e por que é considerada uma prática Senior?**

> **Resposta**: Uma Shared Library é um repositório Git com código Groovy
> reutilizável que pode ser importado por múltiplos Jenkinsfiles.
> É considerada prática Senior porque: (1) elimina duplicação — lógica de
> CI/CD fica num lugar só, (2) padronização organizacional — todos os pipelines
> seguem as mesmas práticas, (3) versionamento independente do projeto —
> a library pode evoluir sem alterar os projetos, (4) abstração —
> times de dev não precisam saber como o pipeline funciona internamente,
> (5) governança — mudanças na library passam por review centralizado.

**Q2: Qual a diferença entre `vars/` e `src/` numa Shared Library?**

> **Resposta**: `vars/` contém arquivos Groovy com um método `call()` que
> se torna uma função global acessível diretamente no Jenkinsfile pelo
> nome do arquivo (ex: `buildApp()`). Tem acesso completo ao contexto do
> pipeline. `src/` contém classes Groovy tradicionais organizadas em pacotes,
> que precisam ser importadas explicitamente e instanciadas com `new`.
> Melhor para lógica orientada a objetos. Para a maioria dos casos, `vars/`
> é suficiente e mais simples.
