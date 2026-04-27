# ============================================================
# MÓDULO 3 — VARIÁVEIS, PARÂMETROS E ENVIRONMENT
# Arquivo: 03-conceitos.md
# ============================================================

# Módulo 3: Variáveis, Parâmetros e Environment

---

## 1. OS TRÊS MUNDOS DE VARIÁVEIS NO JENKINS

```
┌─────────────────────────────────────────────────────────┐
│                   JENKINS PIPELINE                      │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  VARIÁVEIS BUILT-IN (automáticas)                │   │
│  │  BUILD_NUMBER, JOB_NAME, WORKSPACE, GIT_COMMIT   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  VARIÁVEIS CUSTOMIZADAS (environment { })        │   │
│  │  APP_NAME, IMAGE_TAG, AMBIENTE                   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PARÂMETROS DE USUÁRIO (params.*)                │   │
│  │  params.VERSAO, params.AMBIENTE, params.DEPLOY   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 2. VARIÁVEIS BUILT-IN MAIS IMPORTANTES

| Variável | Tipo | Exemplo | Uso |
|----------|------|---------|-----|
| `BUILD_NUMBER` | String | `"42"` | Tag de artefatos |
| `BUILD_URL` | String | `"http://jenkins/job/app/42/"` | Links em notificações |
| `JOB_NAME` | String | `"minha-app"` | Identificação em logs |
| `WORKSPACE` | String | `"/var/jenkins_home/workspace/app"` | Paths de arquivos |
| `GIT_COMMIT` | String | `"a3f9c12b..."` | Rastreabilidade |
| `GIT_BRANCH` | String | `"main"` | Condicionais de deploy |
| `BRANCH_NAME` | String | `"feature/auth"` | Multibranch Pipeline |
| `NODE_NAME` | String | `"agent-linux-01"` | Debug de ambiente |

---

## 3. TABELA DE TIPOS DE PARÂMETROS

| Tipo | Tag | Quando Usar |
|------|-----|-------------|
| `string` | Input de texto | Versão, nome, URL |
| `text` | Textarea multi-linha | JSON, YAML, scripts |
| `booleanParam` | Checkbox | Flags de ativação |
| `choice` | Lista suspensa | Ambiente, estratégia |
| `password` | Campo mascarado | Tokens ocasionais |
| `file` | Upload de arquivo | Configs específicas |
| `run` | Seleção de build | Pipelines de promoção |

---

## 4. TABELA DE ESCOPOS

| Tipo de Variável | Onde Definida | Escopo | Imutável? |
|-----------------|---------------|--------|-----------|
| Built-in do Jenkins | Automático | Pipeline inteiro | ✅ Sim |
| `environment { }` global | Nível pipeline | Pipeline inteiro | ✅ Sim* |
| `environment { }` stage | Nível stage | Só aquele stage | ✅ Sim* |
| `env.VARIAVEL =` no script | Bloco `script { }` | A partir deste ponto | ❌ Não |
| `def` no `script { }` | Bloco `script { }` | Só aquele bloco | ❌ Não |
| `params.*` | Bloco `parameters { }` | Pipeline inteiro | ✅ Sim |

*Tecnicamente pode ser sobrescrito com `env.NOME = 'novo'` mas não é recomendado.

---

## 5. COMUNICAÇÃO ENTRE STAGES

O maior desafio de variáveis em pipelines é passar valores calculados
de um stage para outro. As soluções, em ordem de preferência:

### Opção 1: `env.*` dinâmico (recomendado)
```groovy
stage('Build') {
  steps {
    script {
      env.IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }
  }
}
stage('Deploy') {
  steps {
    echo "Deploying ${env.IMAGE_TAG}"  // ✅ Funciona!
  }
}
```

### Opção 2: `stash/unstash` para arquivos
```groovy
stage('Build') {
  steps {
    sh 'echo "1.0.0" > version.txt'
    stash name: 'version-file', includes: 'version.txt'
  }
}
stage('Deploy') {
  steps {
    unstash 'version-file'
    sh 'cat version.txt'
  }
}
```

### Opção 3: Arquivo externo (para pipelines complexos)
- Salvar em S3/GCS/Nexus entre stages
- Usar para valores grandes ou binários

---

## 6. CONCEITO SENIOR: Por que params.BOOL != env.BOOL?

```groovy
// params.EXECUTAR_DEPLOY é Boolean (true/false)
if (params.EXECUTAR_DEPLOY == true) { }   // ✅ Comparação correta

// env.EXECUTAR_DEPLOY é SEMPRE String ('true'/'false')
if (env.EXECUTAR_DEPLOY == 'true') { }    // ✅ Use aspas (é string!)
if (env.EXECUTAR_DEPLOY == true) { }      // ❌ Groovy: String != Boolean
if (env.EXECUTAR_DEPLOY.toBoolean()) { }  // ✅ Conversão explícita
```

Isso é causado pelo fato de que variáveis de ambiente do sistema
operacional são **sempre strings**. O Jenkins mantém essa convenção
para consistência com o SO, mas `params` são Groovy native types.

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: Como você passa o valor de uma variável calculada num stage para outro stage diferente?**

> **Resposta**: Usando `env.NOME_VARIAVEL = 'valor'` dentro de um bloco
> `script { }`. Variáveis definidas com `def` têm escopo local ao bloco
> script onde foram criadas e não são visíveis em outros stages. A atribuição
> via `env.*` cria uma variável de ambiente que persiste pelo restante do
> pipeline. Alternativa: usar `stash/unstash` para compartilhar arquivos.

**Q2: Por que um pipeline com `parameters { }` não mostra a tela de parâmetros no primeiro build?**

> **Resposta**: Na primeira execução, o Jenkins ainda não processou o
> Jenkinsfile para descobrir quais parâmetros foram definidos. O Jenkins
> precisa executar o pipeline pelo menos uma vez para indexar os parâmetros
> e exibi-los na interface. A partir do segundo build, a opção
> "Build with Parameters" aparece. Para resolver isso: algumas equipes
> usam um estágio inicial que termina cedo se os parâmetros obrigatórios
> estiverem vazios, ou utilizam o plugin "Job DSL" para pré-configurar
> os parâmetros na criação do job.
