# Módulo 2 — Dependências com Maven

## O que você vai aprender neste módulo

- Declarar dependências e entender os escopos
- Dependências transitivas e como controlá-las
- Excluir dependências indesejadas
- BOM (Bill of Materials) e `dependencyManagement`
- Resolver conflitos de versão

## Arquivos deste módulo

| Arquivo | Conceito |
|---------|----------|
| `01-pom-dependencias.xml` | Declarando dependências com escopos |
| `02-pom-dependencias-transitivas.xml` | Transitivas, exclusões e resolução |
| `03-pom-bom.xml` | Bill of Materials e dependencyManagement |
| `04-conflitos-de-versao.md` | Como o Maven resolve conflitos de versão |

## Comandos importantes

```bash
# Ver arvore completa de dependências (incluindo transitivas)
mvn dependency:tree

# Ver dependências com conflitos de versão
mvn dependency:tree -Dverbose

# Analisar dependências usadas e não declaradas
mvn dependency:analyze

# Forçar re-download de todas as dependências
mvn clean install -U
```
