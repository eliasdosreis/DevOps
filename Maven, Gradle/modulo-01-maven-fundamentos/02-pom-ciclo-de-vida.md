# 02 — Ciclo de Vida do Maven

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você está **construindo uma casa**.

Existe uma ordem que NUNCA pode ser quebrada:
1. Primeiro você faz a **planta** (planejamento)
2. Depois constrói a **fundação**
3. Depois levanta as **paredes**
4. Depois coloca o **telhado**
5. Depois faz o **acabamento**
6. Depois entrega ao **cliente**

Você nunca colocaria o telhado antes da fundação, certo?

O Maven funciona exatamente assim: tem um **ciclo de vida** com fases em ordem. Quando você pede para executar uma fase, o Maven executa TODAS as fases anteriores automaticamente.

---

## 2. O QUE É (Definição Técnica Senior)

O Maven possui **3 ciclos de vida built-in**:

1. **default** — o principal, responsável pelo build do projeto
2. **clean** — limpa o diretório de output (`target/`)
3. **site** — gera a documentação do projeto

Cada ciclo de vida é composto por **fases** (phases). As fases são executadas em sequência obrigatória.

**Princípio fundamental:** ao executar uma fase, o Maven executa automaticamente todas as fases anteriores do mesmo ciclo de vida.

```bash
mvn package
# Isso executa: validate → initialize → generate-sources →
#               process-sources → generate-resources →
#               process-resources → compile → process-classes →
#               generate-test-sources → process-test-sources →
#               generate-test-resources → process-test-resources →
#               test-compile → process-test-classes → test → prepare-package → package
```

---

## 3. FASES DO CICLO DE VIDA DEFAULT (as mais importantes)

### Fluxo visual:

```
validate
    ↓
compile
    ↓
test
    ↓
package
    ↓
verify
    ↓
install
    ↓
deploy
```

### Detalhamento de cada fase:

| Fase | O que faz | Quando usar |
|------|-----------|-------------|
| `validate` | Valida que o projeto está correto e toda info necessária está disponível | Automaticamente (não chamada diretamente) |
| `compile` | Compila o código-fonte em `.class` | Desenvolvimento dia a dia |
| `test-compile` | Compila o código de teste | Automaticamente antes do `test` |
| `test` | Executa os testes usando um framework de testes (JUnit, TestNG) | Verificar se tudo passa |
| `package` | Empacota o código compilado em JAR/WAR | Gerar o artefato distribuível |
| `verify` | Executa qualquer verificação para validar o pacote (testes de integração) | CI/CD |
| `install` | Instala o pacote no repositório local (`~/.m2`) | Usar o artefato em outros projetos locais |
| `deploy` | Copia o pacote final para um repositório remoto compartilhado | Publicar a release para a equipe |

---

## 4. COMANDOS PASSO A PASSO

```bash
# ─────────────────────────────────────────
# Ciclo de vida: clean
# ─────────────────────────────────────────

# Remove o diretório target/ completamente
mvn clean
# Saída esperada:
# [INFO] Deleting /caminho/target
# [INFO] BUILD SUCCESS

# ─────────────────────────────────────────
# Ciclo de vida: default (fases principais)
# ─────────────────────────────────────────

# Apenas compila o código-fonte
mvn compile
# Saída esperada:
# [INFO] Compiling 1 source file to /caminho/target/classes
# [INFO] BUILD SUCCESS

# Compila E executa os testes
mvn test
# Saída esperada:
# Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
# [INFO] BUILD SUCCESS

# Compila, testa E gera o JAR
mvn package
# Saída esperada:
# [INFO] Building jar: /caminho/target/hello-maven-1.0.0-SNAPSHOT.jar
# [INFO] BUILD SUCCESS

# Compila, testa, empacota E instala no ~/.m2
mvn install
# O JAR fica disponível em: ~/.m2/repository/com/curso/hello-maven/1.0.0-SNAPSHOT/

# ─────────────────────────────────────────
# Combinações comuns no dia a dia
# ─────────────────────────────────────────

# clean + package: o mais usado no dia a dia
# Garante uma build limpa, sem resíduos de builds anteriores
mvn clean package

# clean + install: build limpa + disponibiliza para outros módulos locais
mvn clean install

# Pular os testes (NÃO recomendado, mas às vezes necessário)
mvn clean package -DskipTests

# Pular a COMPILAÇÃO dos testes também (mais rápido, ainda menos recomendado)
mvn clean package -Dmaven.test.skip=true

# Executar apenas um teste específico
mvn test -Dtest=MinhaClasseTest

# Executar apenas um método específico
mvn test -Dtest=MinhaClasseTest#meuMetodo

# ─────────────────────────────────────────
# Comandos de diagnóstico
# ─────────────────────────────────────────

# Modo verbose: mostra detalhes de cada operação
mvn clean package -X

# Modo silencioso: mostra apenas erros
mvn clean package -q

# Mostra as dependências do projeto em árvore
mvn dependency:tree

# Mostra as fases e goals que seriam executados (sem executar)
mvn clean package -n   # dry-run (não funciona em todas as versões)
```

---

## 5. VERIFICAÇÃO E TROUBLESHOOTING

### Como saber se a build funcionou

```
[INFO] BUILD SUCCESS    ← Tudo certo!
[INFO] BUILD FAILURE    ← Alguma coisa deu errado
```

### Erros comuns e soluções

| Erro | Causa provável | Solução |
|------|----------------|---------|
| `COMPILATION ERROR` | Código Java com erro de sintaxe | Corrija o erro apontado pelo compilador |
| `Tests run: X, Failures: Y` | Testes falhando | Corrija o código ou o teste |
| `Could not find artifact` | Dependência não encontrada | Verifique o GAV da dependência e o repositório |
| `Non-resolvable parent POM` | POM pai não encontrado | Execute `mvn install` no projeto pai primeiro |
| `Plugin execution not covered` | Conflito de plugin com IDE | Configure o `pluginManagement` (ver Módulo 3) |

---

## 6. CONCEITO SENIOR

### Diferença entre `phase` e `goal`

Este é um dos pontos mais confusos para iniciantes, mas é crucial para entrevistas:

- **Fase (phase)**: Uma etapa do ciclo de vida. Ex: `compile`, `test`, `package`
- **Goal**: A tarefa específica executada por um plugin. Ex: `compiler:compile`, `surefire:test`

As fases são pontos de ancoragem onde os plugins "penduuram" seus goals.

```
Fase "compile" → executa o goal "compiler:compile" (do maven-compiler-plugin)
Fase "test"    → executa o goal "surefire:test" (do maven-surefire-plugin)
Fase "package" → executa o goal "jar:jar" (do maven-jar-plugin)
```

**Você pode chamar um goal diretamente**, sem passar pelo ciclo de vida:
```bash
# Executa apenas o goal de árvore de dependências, sem compilar nada
mvn dependency:tree

# Executa apenas o goal de análise, sem compilar
mvn dependency:analyze
```

### Por que `mvn clean package` e não só `mvn package`?

Em builds automatizados (CI/CD), **sempre use `mvn clean`** antes de qualquer fase.

Sem o `clean`, arquivos de builds anteriores podem "contaminar" a build atual:
- Classes antigas que deveriam ter sido removidas permanecem
- O JAR pode incluir código de versões anteriores
- Testes podem passar por usar .class compilados de uma versão anterior do código

### -DskipTests vs -Dmaven.test.skip=true

```bash
# Compila os testes mas não executa → mais rápido encontrar erros de compilação
mvn package -DskipTests

# Não compila nem executa os testes → máximo de velocidade (perigoso!)
mvn package -Dmaven.test.skip=true
```

Em produção/CI, **NUNCA pule os testes**. Se os testes estão lentos, o problema é a arquitetura dos testes, não o processo de build.

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre `mvn install` e `mvn deploy`?**

> **Resposta esperada:** `mvn install` empacota o artefato e o instala no repositório local da máquina (`~/.m2/repository`). Ele fica disponível apenas para projetos na mesma máquina. `mvn deploy` faz tudo que o `install` faz, mas também publica o artefato em um repositório remoto compartilhado (como Nexus ou Artifactory), tornando-o disponível para toda a equipe. `deploy` é usado no final do pipeline de CI/CD para publicar releases.

**Q2: Qual a diferença entre uma `phase` e um `goal` no Maven?**

> **Resposta esperada:** Uma `phase` (fase) é uma etapa do ciclo de vida do Maven (ex: `compile`, `test`, `package`). Um `goal` é a implementação concreta executada por um plugin (ex: `compiler:compile`, `surefire:test`). As fases são sequenciais e os plugins "se registram" para executar seus goals em determinadas fases. Você pode invocar tanto uma fase (`mvn compile`) quanto um goal diretamente (`mvn compiler:compile`). A diferença prática é que ao invocar uma fase, todas as fases anteriores também são executadas; ao invocar um goal diretamente, apenas aquele goal é executado, sem executar as fases anteriores.
