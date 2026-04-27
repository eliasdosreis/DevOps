# ============================================================
# MÓDULO 1 — FUNDAMENTOS DE PIPELINE
# Arquivo: 01-conceitos.md
#
# Leia ANTES dos arquivos .groovy deste módulo
# ============================================================

# Módulo 1: Fundamentos de Pipeline

---

## 1. ANALOGIA DO DIA A DIA: O que é um Jenkinsfile?

Imagine que você tem uma pizzaria e vai contratar um funcionário.
Você pode explicar o processo de fazer pizza **verbalmente** toda vez
que um pedido chega (Job Freestyle), ou pode criar um **Manual de
Procedimentos** que o funcionário segue:

```
Manual da Pizza Margherita:
1. Prepare a massa                    → stage('Build')
2. Adicione os ingredientes           → stage('Test')
3. Leve ao forno por 15 minutos      → stage('Deploy')
4. Embale e entregue                 → stage('Notify')
```

O **Jenkinsfile** é esse Manual de Procedimentos.
Fica no Git junto com o código da aplicação, é versionado,
revisado em Pull Requests, e executado automaticamente.

---

## 2. O QUE É — Definição Técnica Senior

### Jenkinsfile

Um arquivo de texto no formato **Groovy DSL** (Domain-Specific Language)
que define a lógica completa de um pipeline CI/CD. Características:

- **Versionado**: fica no repositório Git, junto com o código da aplicação
- **Code as Infrastructure**: o pipeline é código, não configuração em UI
- **Rastreável**: cada mudança no pipeline tem histórico de commit/PR
- **Pipeline as Code (PaC)**: paradigma onde infraestrutura de CI/CD é código

### Pipeline Declarativo

Introduzido no Jenkins 2.x. Usa uma estrutura rígida e opinionada:

```
pipeline → agent → stages → stage → steps
```

O Jenkins valida a estrutura ANTES de executar — se a sintaxe estiver
errada, o erro aparece imediatamente, sem executar nenhum step.

### Pipeline Scripted

Estilo original, baseado em código Groovy puro. Usa `node { }` como
bloco raiz. Mais poderoso e flexível, porém:
- Sem validação prévia de sintaxe
- Sem suporte nativo a `post`, `when`, `parallel` declarativos
- Mais difícil de ler e manter

---

## 3. ESTRUTURA MÍNIMA OBRIGATÓRIA

```groovy
pipeline {      // Palavra-chave raiz — sempre presente no Declarativo
  agent any     // Obrigatório: onde executar
  stages {      // Obrigatório: container de stages
    stage('Nome') {  // Pelo menos 1 stage
      steps {        // Pelo menos 1 step
        echo 'Olá'   // O step mais simples
      }
    }
  }
}
```

Qualquer pipeline Declarativo deve ter exatamente estes 5 elementos
na hierarquia correta. O Jenkins rejeita qualquer variação.

---

## 4. HIERARQUIA COMPLETA DO PIPELINE DECLARATIVO

```
pipeline {
  agent { }           ← OBRIGATÓRIO (no nível pipeline)
  options { }         ← opcional
  triggers { }        ← opcional
  parameters { }      ← opcional
  environment { }     ← opcional
  tools { }           ← opcional (instala ferramentas como Maven, JDK)
  stages {            ← OBRIGATÓRIO
    stage('X') {      ← OBRIGATÓRIO (mínimo 1)
      agent { }       ← opcional (sobrescreve o global)
      when { }        ← opcional
      options { }     ← opcional
      environment { } ← opcional
      tools { }       ← opcional
      steps { }       ← OBRIGATÓRIO (ou parallel)
      post { }        ← opcional
    }
  }
  post { }            ← opcional
}
```

---

## 5. CONCEITO SENIOR: Por que o Jenkinsfile fica no repositório da aplicação?

Esta é uma decisão arquitetural importante com várias implicações:

### Coesão
O pipeline pertence à aplicação. Se a aplicação muda de tecnologia
(ex: Java → Go), o pipeline muda junto, no mesmo commit.

### Revisão e Aprovação
Mudanças no pipeline passam por Pull Request e são revisadas pela
mesma equipe que revisa o código. Um Pipeline Script direto na
interface do Jenkins não tem esse controle.

### Recuperação de Desastres
Se o Jenkins for reinstalado do zero, basta apontar para o Git
e todos os pipelines são reconstruídos automaticamente.

### Rastreabilidade
`git log Jenkinsfile` mostra exatamente quando e por que o pipeline
mudou. Fundamental para compliance e auditoria.

### Multi-Branch
O Multibranch Pipeline cria automaticamente um job por branch que
contenha um Jenkinsfile. Isso permite que cada branch tenha seu
próprio comportamento de CI/CD sem configuração manual.

---

## 6. ANATOMIA DO BUILD LOG

Quando um pipeline executa, o log segue este padrão:

```
Started by user admin                ← Quem/o que iniciou o build
Obtained Jenkinsfile from git...     ← Jenkins baixou o Jenkinsfile do Git
[Pipeline] Start of Pipeline         ← Início da execução
[Pipeline] node                      ← Alocou um executor/agent
[Pipeline] {                         ← Bloco aberto
[Pipeline] stage                     ← Iniciou um stage
[Pipeline] { (Build)                 ← Nome do stage
[Pipeline] echo                      ← Executou um step 'echo'
Compilando a aplicação...            ← Saída do comando
[Pipeline] }                         ← Bloco fechado
[Pipeline] // stage                  ← Stage concluído
[Pipeline] }                         ← Node finalizado
[Pipeline] End of Pipeline           ← Pipeline terminado
Finished: SUCCESS                    ← Status final
```

O formato `[Pipeline] step` indica o tipo de step executado.
O `{ }` indica abertura e fechamento de blocos.

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: O que é Pipeline as Code e por que é importante?**

> **Resposta**: Pipeline as Code é a prática de definir a lógica de
> CI/CD em arquivos de código versionados no Git, em vez de configurar
> pela interface gráfica. É importante porque: (1) permite rastreabilidade
> de mudanças via git log, (2) possibilita code review do pipeline,
> (3) facilita recuperação em desastres, (4) garante que o pipeline
> evolua junto com a aplicação no mesmo ciclo de desenvolvimento.

**Q2: Qual a diferença fundamental entre Pipeline Declarativo e Scripted?**

> **Resposta**: O Declarativo usa uma estrutura rígida e opinionada
> (`pipeline → agent → stages → stage → steps`) com validação prévia
> de sintaxe e suporte nativo a `post`, `when`, `parallel`, `environment`.
> O Scripted é código Groovy puro dentro de `node { }`, sem estrutura
> predefinida. O Declarativo é o padrão moderno e recomendado; o Scripted
> é usado em casos específicos que exigem lógica complexa não suportada
> pelo Declarativo. Uma boa prática é usar o Declarativo com blocos
> `script { }` internos para fugir de limitações pontuais.
