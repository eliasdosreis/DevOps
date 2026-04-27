# 01 — Instalação e Variáveis de Ambiente

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você é um chef de cozinha.

- O **JDK** é a **cozinha equipada** — sem ela, você não consegue cozinhar nada.
- O **Maven** é o **livro de receitas que organiza os ingredientes automaticamente** — você fala "quero fazer um bolo" e ele busca os ingredientes no mercado pra você.
- O **Gradle** é o **chef assistente mais moderno** — faz tudo que o Maven faz, mas de forma mais rápida e flexível.

Antes de cozinhar qualquer coisa, você precisa montar a cozinha. Isso é o Módulo 0.

---

## 2. O QUE É (Definição Técnica Senior)

### JDK (Java Development Kit)
O JDK é o conjunto de ferramentas necessárias para **desenvolver** aplicações Java. Inclui:
- `javac` — compilador Java (transforma `.java` em `.class`)
- `java` — JVM (executa o `.class`)
- `jar` — empacotador de arquivos
- `javadoc` — gerador de documentação

> ⚠️ **JDK vs JRE**: JRE (Java Runtime Environment) serve só para *executar* apps Java. JDK serve para *desenvolver*. Sempre instale o JDK.

### JAVA_HOME
Variável de ambiente que aponta para o diretório raiz do JDK instalado.
Maven e Gradle precisam dela para saber onde o Java está.

### Maven
Ferramenta de build e gerenciamento de dependências baseada em **convenção sobre configuração**.
Usa XML (`pom.xml`) como linguagem de configuração.

### Gradle
Ferramenta de build moderna baseada em **Groovy DSL** ou **Kotlin DSL**.
Mais flexível e performático que o Maven para projetos grandes.

---

## 3. INSTALAÇÃO PASSO A PASSO

### 3.1 Instalar o JDK

**Opção recomendada: Eclipse Temurin (OpenJDK)**
- Site: https://adoptium.net
- Escolha: **JDK 21 LTS** (versão de suporte de longo prazo mais recente)

**Windows:**
1. Baixe o instalador `.msi` do site acima
2. Execute o instalador (marque a opção "Set JAVA_HOME variable")
3. Reinicie o terminal

**Verificar:**
```bash
java -version
# Saída esperada:
# openjdk version "21.0.x" ...

javac -version
# Saída esperada:
# javac 21.0.x
```

---

### 3.2 Configurar JAVA_HOME (se não foi configurado automaticamente)

**Windows (PowerShell como Administrador):**
```powershell
# 1. Descubra onde o JDK foi instalado
# Normalmente em: C:\Program Files\Eclipse Adoptium\jdk-21.x.x.x-hotspot

# 2. Configure a variável de ambiente do sistema
[System.Environment]::SetEnvironmentVariable(
    "JAVA_HOME",
    "C:\Program Files\Eclipse Adoptium\jdk-21.0.0.0-hotspot",
    "Machine"
)

# 3. Adicione ao PATH
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
[System.Environment]::SetEnvironmentVariable(
    "PATH",
    "$currentPath;%JAVA_HOME%\bin",
    "Machine"
)

# 4. Reinicie o terminal e verifique
echo $env:JAVA_HOME
```

**Linux/macOS (~/.bashrc ou ~/.zshrc):**
```bash
# Adicione estas linhas ao final do arquivo ~/.bashrc ou ~/.zshrc
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64  # ajuste o caminho
export PATH=$JAVA_HOME/bin:$PATH

# Recarregue o arquivo
source ~/.bashrc
```

---

### 3.3 Instalar o Maven

1. Acesse: https://maven.apache.org/download.cgi
2. Baixe o **Binary zip archive** (ex: `apache-maven-3.9.x-bin.zip`)
3. Extraia em um local permanente (ex: `C:\Tools\maven`)

**Windows (PowerShell como Administrador):**
```powershell
# Configure M2_HOME apontando para a pasta do Maven
[System.Environment]::SetEnvironmentVariable(
    "M2_HOME",
    "C:\Tools\maven\apache-maven-3.9.x",
    "Machine"
)

# Adicione ao PATH
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
[System.Environment]::SetEnvironmentVariable(
    "PATH",
    "$currentPath;%M2_HOME%\bin",
    "Machine"
)
```

**Linux/macOS:**
```bash
# Extraia o Maven
tar -xzf apache-maven-3.9.x-bin.tar.gz -C /opt/

# Adicione ao ~/.bashrc
export M2_HOME=/opt/apache-maven-3.9.x
export PATH=$M2_HOME/bin:$PATH

source ~/.bashrc
```

**Verificar:**
```bash
mvn -version
# Saída esperada:
# Apache Maven 3.9.x (...)
# Maven home: C:\Tools\maven\apache-maven-3.9.x
# Java version: 21.0.x, vendor: Eclipse Adoptium
# Java home: C:\Program Files\Eclipse Adoptium\jdk-21.x.x.x-hotspot
```

---

### 3.4 Instalar o Gradle

1. Acesse: https://gradle.org/releases/
2. Baixe o **Binary-only** (ex: `gradle-8.x-bin.zip`)
3. Extraia em um local permanente (ex: `C:\Tools\gradle`)

**Windows (PowerShell como Administrador):**
```powershell
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
[System.Environment]::SetEnvironmentVariable(
    "PATH",
    "$currentPath;C:\Tools\gradle\gradle-8.x\bin",
    "Machine"
)
```

**Linux/macOS:**
```bash
tar -xzf gradle-8.x-bin.zip -C /opt/

export GRADLE_HOME=/opt/gradle-8.x
export PATH=$GRADLE_HOME/bin:$PATH

source ~/.bashrc
```

**Verificar:**
```bash
gradle -version
# Saída esperada:
# Gradle 8.x
# Build time: ...
# JVM: 21.0.x (Eclipse Adoptium ...)
```

---

## 4. VERIFICAÇÃO FINAL

Execute todos os comandos abaixo. Todos devem retornar versões sem erros:

```bash
java -version      # ex: openjdk version "21.0.x"
javac -version     # ex: javac 21.0.x
echo $JAVA_HOME    # ex: C:\Program Files\Eclipse Adoptium\...
mvn -version       # ex: Apache Maven 3.9.x
gradle -version    # ex: Gradle 8.x
```

---

## 5. TROUBLESHOOTING

| Problema | Causa | Solução |
|----------|-------|---------|
| `java: command not found` | JAVA_HOME/bin não está no PATH | Adicione `$JAVA_HOME/bin` ao PATH e reinicie o terminal |
| `mvn: command not found` | Maven bin não está no PATH | Adicione `$M2_HOME/bin` ao PATH |
| Maven encontra Java errado | Múltiplas JVMs instaladas | Defina JAVA_HOME explicitamente apontando para a correta |
| `JAVA_HOME not set` ao rodar mvn | Variável de ambiente ausente | Configure JAVA_HOME como descrito acima |
| Versão do Java incompatível | JDK muito antigo | Use JDK 11+ (recomendado: JDK 21 LTS) |

---

## 6. CONCEITO SENIOR

### O que um Senior sabe que um Junior não sabe

**Sobre versões do JDK:**
- Use sempre versões **LTS** (Long Term Support): 11, 17, 21
- Em projetos legados corporativos, você pode encontrar JDK 8 ainda em produção
- Ferramentas como **SDKMAN** (Linux/macOS) ou **Scoop** (Windows) permitem gerenciar múltiplas versões do JDK com facilidade:
  ```bash
  # Com SDKMAN:
  sdk install java 21.0.1-tem
  sdk use java 21.0.1-tem
  ```

**Sobre Maven vs Gradle:**
- Maven domina em empresas mais antigas e projetos Spring Boot corporativos
- Gradle é padrão no ecossistema Android e está crescendo em projetos modernos
- Em projetos novos, Gradle geralmente oferece builds mais rápidos (especialmente com cache)
- Maven tem XML verboso mas é **previsível e padronizado** — fácil de ler código de terceiros
- Gradle é mais flexível mas pode virar um "spaghetti" se não houver disciplina

**Sobre JAVA_HOME:**
- Ferramentas como IntelliJ IDEA têm seu próprio JDK embutido — o JAVA_HOME do sistema pode ser diferente
- Em CI/CD (GitHub Actions, Jenkins), o JAVA_HOME é configurado pelo ambiente automaticamente usando actions como `setup-java`
- Sempre verifique qual Java o Maven/Gradle está usando com `mvn -version` / `gradle -version`

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre JDK, JRE e JVM?**

> **Resposta esperada:** JVM (Java Virtual Machine) é o motor que executa bytecode Java. JRE (Java Runtime Environment) inclui a JVM + bibliotecas padrão para *rodar* aplicações. JDK (Java Development Kit) inclui o JRE + ferramentas de desenvolvimento como o compilador `javac`. Para desenvolver, sempre use o JDK. Em produção (apenas executar), o JRE seria suficiente — porém, hoje em dia a Oracle não distribui mais o JRE separado, então instala-se o JDK mesmo em produção.

**Q2: Por que o JAVA_HOME é importante para o Maven e o Gradle?**

> **Resposta esperada:** O Maven e o Gradle precisam saber qual JDK usar para compilar o código. Eles lêem a variável `JAVA_HOME` para localizar o `javac` e a JVM. Sem ela definida corretamente, a build pode usar uma versão inesperada do Java ou falhar. Em ambientes com múltiplas JVMs instaladas (comum em times de desenvolvimento híbridos), `JAVA_HOME` garante consistência. Em CI/CD, essa variável é configurada automaticamente pelos runners de build.
