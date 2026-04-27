# 03 — Primeiros Comandos

---

## Comandos para Verificar o Ambiente

Execute cada um destes comandos no terminal. Todos devem retornar sem erros.

```bash
# ─────────────────────────────────────────
# VERIFICAÇÃO DO JAVA
# ─────────────────────────────────────────

# Verifica a versão do Java instalada
java -version
# Saída esperada: openjdk version "21.0.x" ...

# Verifica o compilador Java
javac -version
# Saída esperada: javac 21.0.x

# Mostra o JAVA_HOME configurado
# No Windows (PowerShell):
echo $env:JAVA_HOME
# No Linux/macOS:
echo $JAVA_HOME
# Saída esperada: caminho para o diretório do JDK

# ─────────────────────────────────────────
# VERIFICAÇÃO DO MAVEN
# ─────────────────────────────────────────

# Verifica a versão do Maven E o Java que ele está usando
mvn -version
# Saída esperada:
# Apache Maven 3.9.x (...)
# Maven home: /caminho/para/maven
# Java version: 21.0.x, vendor: Eclipse Adoptium

# Lista os goals disponíveis do Maven (modo help)
mvn help:describe -Dplugin=help
# Saída esperada: Descrição do plugin help

# ─────────────────────────────────────────
# VERIFICAÇÃO DO GRADLE
# ─────────────────────────────────────────

# Verifica a versão do Gradle E o Java que ele está usando
gradle -version
# Saída esperada:
# Gradle 8.x
# JVM: 21.0.x (Eclipse Adoptium ...)

# ─────────────────────────────────────────
# CRIANDO SEU PRIMEIRO PROJETO MAVEN
# (apenas para testar — não é o projeto principal)
# ─────────────────────────────────────────

# Cria um projeto Maven do zero usando o archetype quickstart
mvn archetype:generate \
  -DgroupId=com.curso \
  -DartifactId=hello-maven \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DarchetypeVersion=1.4 \
  -DinteractiveMode=false

# Entra no projeto criado
cd hello-maven

# Compila o projeto
mvn compile
# Saída esperada: BUILD SUCCESS

# Executa os testes
mvn test
# Saída esperada: BUILD SUCCESS (com 1 teste passando)

# Empacota em um JAR
mvn package
# Saída esperada: BUILD SUCCESS
# Arquivo gerado: target/hello-maven-1.0-SNAPSHOT.jar

# ─────────────────────────────────────────
# CRIANDO SEU PRIMEIRO PROJETO GRADLE
# ─────────────────────────────────────────

# Cria um projeto Gradle do zero (modo interativo — responda as perguntas)
mkdir hello-gradle
cd hello-gradle
gradle init

# Ou de forma não-interativa:
gradle init \
  --type java-application \
  --dsl groovy \
  --test-framework junit-jupiter \
  --project-name hello-gradle \
  --package com.curso

# Executa os testes
./gradlew test    # Linux/macOS
gradlew.bat test  # Windows
# Saída esperada: BUILD SUCCESSFUL

# Compila o projeto
./gradlew build
# Saída esperada: BUILD SUCCESSFUL
```

## Troubleshooting Rápido

| Erro | Solução |
|------|---------|
| `mvn: command not found` | Maven não está no PATH — verifique M2_HOME e PATH |
| `gradle: command not found` | Gradle não está no PATH — verifique a instalação |
| `BUILD FAILURE` no `mvn compile` | Verifique o pom.xml e a versão do Java |
| `Could not find or load main class` | Verifique o classpath e o package da classe |

## Próximos Passos

Você está pronto para o Módulo 1! 🎉

Agora você vai entender o **coração do Maven**: o arquivo `pom.xml` e o ciclo de vida de build.
