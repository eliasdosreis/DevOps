# Módulo 5 — Fundamentos Gradle

## O que você vai aprender neste módulo

- O que é o Gradle e como ele difere do Maven
- Groovy DSL vs Kotlin DSL — quando usar cada um
- Estrutura do build.gradle e settings.gradle
- O DAG (Directed Acyclic Graph) de tasks
- Gradle Wrapper (gradlew) — por que é obrigatório

## Arquivos deste módulo

| Arquivo | Conceito |
|---------|----------|
| `01-maven-vs-gradle.md` | Comparação detalhada: quando escolher cada um |
| `01-build-minimo.gradle` | build.gradle mínimo funcional (Groovy DSL) |
| `01-build-minimo.gradle.kts` | Equivalente em Kotlin DSL |
| `02-settings.gradle` | Configuração do projeto no settings.gradle |
| `03-gradle-wrapper.md` | Gradle Wrapper: configuração e uso |

## Comandos importantes

```bash
# Ver todas as tasks disponíveis
./gradlew tasks

# Com detalhe
./gradlew tasks --all

# Compilar
./gradlew compileJava

# Testar
./gradlew test

# Build completo
./gradlew build

# Limpar
./gradlew clean

# Ver dependências
./gradlew dependencies

# Ver propriedades do projeto
./gradlew properties
```
