# Módulo 1 — Fundamentos Maven

## O que você vai aprender neste módulo

- O que é o Maven e por que ele foi criado
- O ciclo de vida de build e suas fases
- A estrutura do pom.xml (coordenadas GAV)
- Repositórios: local, central e remotos
- O Maven Wrapper (mvnw) e por que usar

## Arquivos deste módulo

| Arquivo | Conceito |
|---------|----------|
| `01-pom-minimo.xml` | pom.xml mais básico possível — coordenadas GAV |
| `02-pom-ciclo-de-vida.md` | Explicação das fases do ciclo de vida Maven |
| `03-pom-repositorios.xml` | Como configurar repositórios remotos |
| `04-maven-wrapper.md` | O que é o mvnw e como configurar |

## Ordem de leitura

1. `01-pom-minimo.xml` → entenda a estrutura básica
2. `02-pom-ciclo-de-vida.md` → entenda as fases de build
3. `03-pom-repositorios.xml` → entenda de onde vêm as dependências
4. `04-maven-wrapper.md` → como garantir consistência de versão

## Comandos do módulo

```bash
# Compilar o projeto
mvn compile

# Executar os testes
mvn test

# Empacotar em JAR
mvn package

# Instalar no repositório local
mvn install

# Ver todas as fases disponíveis
mvn help:describe -Dplugin=lifecycle
```
