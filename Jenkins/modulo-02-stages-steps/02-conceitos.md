# ============================================================
# MÓDULO 2 — STAGES, STEPS E FLOW CONTROL
# Arquivo: 02-conceitos.md
# ============================================================

# Módulo 2: Stages, Steps e Flow Control

---

## 1. O QUE É UM STAGE?

**Analogia**: Um stage é como uma **estação numa linha de montagem**.
Cada estação tem um propósito único: soldar, pintar, testar, embalar.
Nenhuma estação começa antes de a anterior terminar (a peça precisa
estar pronta para passar para a próxima etapa).

**Técnico**: Um `stage` é uma unidade lógica de agrupamento dentro de um
pipeline. Cada stage aparece como uma coluna na Stage View do Jenkins,
permite visualização do progresso e isola falhas para facilitar o debug.

---

## 2. STEPS MAIS IMPORTANTES

| Step | Plataforma | Uso Principal |
|------|-----------|---------------|
| `echo` | Todas | Imprimir mensagens de log |
| `sh` | Linux/Mac | Executar comandos shell |
| `bat` | Windows | Executar comandos batch |
| `script` | Todas | Código Groovy no Declarativo |
| `dir` | Todas | Mudar diretório de trabalho |
| `withEnv` | Todas | Variáveis de ambiente temporárias |
| `timeout` | Todas | Cancelar se ultrapassar tempo |
| `retry` | Todas | Retentar em caso de falha |
| `sleep` | Todas | Aguardar um tempo fixo |
| `error` | Todas | Forçar falha com mensagem |
| `catchError` | Todas | Capturar erro sem quebrar o build |
| `unstable` | Todas | Marcar build como instável |
| `archiveArtifacts` | Todas | Salvar arquivos do build |
| `stash/unstash` | Todas | Compartilhar arquivos entre stages |

---

## 3. BLOCO POST — ORDEM DE EXECUÇÃO

A ordem de avaliação das condições do `post` é:

```
always → changed → fixed → regression → aborted →
failure → success → unstable → unsuccessful → cleanup
```

Múltiplas condições podem ser verdadeiras ao mesmo tempo
(ex: `always` e `success` executam juntos quando o build passa).

---

## 4. DIRETIVA WHEN — CONTROLE DE FLUXO

O `when` é o "portão" de cada stage. Sem `when`, o stage sempre executa.
Com `when`, você define condições que devem ser verdadeiras.

```
pipeline sem when = fábrica sem controle de qualidade
pipeline com when = fábrica com checklist antes de cada etapa
```

**Boas práticas com when**:
- Use `expression { }` para condições complexas
- Use `beforeAgent true` para economizar recursos
- Combine `allOf` e `anyOf` para condições compostas

---

## 5. PARALLEL — ECONOMIA DE TEMPO

O paralelismo reduz o tempo total de pipeline executando tarefas
independentes simultaneamente.

**Cálculo de ganho**:
```
Sequencial: Build(5min) + Tests-Unit(8min) + Tests-Integration(10min) = 23min
Paralelo:   Build(5min) + max(Tests-Unit(8min), Tests-Integration(10min)) = 15min
Ganho: 35% de redução no tempo total
```

**Limitações do parallel**:
1. Cada branch do `parallel` precisa de um executor disponível
2. Tarefas com dependência de dados entre si NÃO devem ser paralelas
3. Excesso de paralelismo pode sobrecarregar o agente (CPU/memória)

---

## 6. CONCEITO SENIOR: stash e unstash

Quando stages paralelos precisam compartilhar arquivos:

```groovy
stage('Build') {
  steps {
    sh 'mvn package'
    stash name: 'app-jar', includes: 'target/*.jar'  // Guarda arquivo
  }
}

stage('Testes em Paralelo') {
  parallel {
    stage('Test A') {
      steps {
        unstash 'app-jar'  // Recupera o arquivo do Build
        sh 'java -jar target/*.jar --test=A'
      }
    }
    stage('Test B') {
      agent { label 'agente-diferente' }  // Agente diferente!
      steps {
        unstash 'app-jar'  // Funciona mesmo em agente diferente
        sh 'java -jar target/*.jar --test=B'
      }
    }
  }
}
```

`stash` é como um **armário temporário** no Jenkins Controller.
`unstash` busca os arquivos de qualquer agente, em qualquer stage.
Os stashes são limpados ao final do build.

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre `post { always }` e `post { cleanup }`?**

> **Resposta**: Ambos sempre executam, mas `cleanup` é garantido de ser
> o ÚLTIMO a executar dentro do bloco post. `always` executa em sua
> posição na ordem de avaliação das condições. Use `cleanup` para
> limpeza crítica que deve acontecer depois de todas as notificações
> e ações do post.

**Q2: Como você compartilharia um arquivo compilado no stage 'Build'
com dois stages paralelos que rodam em agentes diferentes?**

> **Resposta**: Usando `stash` no stage Build e `unstash` em cada
> stage paralelo. O `stash` armazena o arquivo no Jenkins Controller,
> tornando-o acessível de qualquer agente via `unstash`. Alternativa
> para arquivos grandes: usar um artefato compartilhado externo como
> um S3 bucket, Nexus ou Artifactory.

**Q3: O que é `failFast: true` no parallel e quando usar?**

> **Resposta**: `failFast: true` cancela todos os branches paralelos
> assim que um deles falha. Sem essa opção, o Jenkins espera todos
> os branches terminarem mesmo após uma falha. Use quando: (1) o tempo
> de pipeline é crítico, (2) o resultado de um branch invalida os demais,
> (3) quer feedback rápido em pipelines de PR. Não use quando: precisa
> de todos os resultados para análise completa de falhas.
