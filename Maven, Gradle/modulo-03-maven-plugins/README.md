# Módulo 3 — Plugins Maven

## O que você vai aprender neste módulo

- O que são plugins e como funcionam no Maven
- Plugins essenciais: compiler, surefire, failsafe, jar, shade
- Como configurar o maven-compiler-plugin para Java moderno
- Como criar um JAR executável com maven-shade-plugin
- Como executar goals de plugins diretamente

## Arquivos deste módulo

| Arquivo | Conceito |
|---------|----------|
| `01-pom-plugins-essenciais.xml` | Plugins principais: compiler, surefire, jar |
| `02-pom-plugin-shade.xml` | Criando um uber-JAR executável com shade |
| `03-pom-plugin-failsafe.xml` | Testes de integração com failsafe |
| `04-plugins-goals-diretos.md` | Executando goals de plugins diretamente |

## Comandos importantes

```bash
# Executar testes unitários
mvn test

# Executar testes de integração
mvn verify

# Gerar JAR executável (fat jar)
mvn clean package

# Executar goal de um plugin diretamente (sem ciclo de vida)
mvn dependency:tree
mvn versions:display-dependency-updates
mvn enforcer:enforce
```
