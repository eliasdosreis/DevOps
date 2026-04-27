# 01 — Estrutura de Projeto Multi-Módulo

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você está construindo um **shopping center**.

Um shopping tem várias lojas, mas todas compartilham:
- A mesma **estrutura física** (paredes, telhado, estacionamento)
- O mesmo **sistema elétrico** (fonte de energia)
- As mesmas **regras do shopping** (horário de funcionamento, segurança)

Cada loja é independente para seu negócio, mas compartilha a infraestrutura.

Em projetos Maven multi-módulo:
- O **POM pai** é o shopping — define a infraestrutura compartilhada
- Os **módulos filhos** são as lojas — têm código próprio mas herdam as regras do pai

### Por que isso é necessário?

Sem multi-módulo, você teria um projeto gigante com tudo misturado:
- API + implementação + aplicação web + bibliotecas utilitárias
- Impossível de reusar partes isoladas
- Build lento porque sempre recompila tudo

Com multi-módulo:
- Cada módulo tem uma responsabilidade clara
- Módulos podem ser reutilizados em outros projetos
- Build incrementaL: só recompila o que mudou

---

## 2. O QUE É (Definição Técnica Senior)

Um projeto Maven multi-módulo consiste em:

### POM Pai (Aggregator POM)
- Tem `<packaging>pom</packaging>` (não gera JAR/WAR)
- Declara os módulos filhos em `<modules>`
- Centraliza configurações via `<dependencyManagement>` e `<pluginManagement>`
- Responsável por dois papéis distintos: **aggregation** e **inheritance**

### Aggregation (Agregação)
O POM pai AGREGA os módulos — ao executar `mvn install` no pai, ele executa em todos os filhos automaticamente.

### Inheritance (Herança)
Os filhos HERDAM configurações do pai via `<parent>` — não precisam repetir properties, dependências gerenciadas, configurações de plugins, etc.

### POM Filho
- Declara `<parent>` apontando para o POM pai
- Herda todas as configurações do pai
- Pode ter suas próprias dependências e plugins adicionais

---

## 3. QUANDO USAR MULTI-MÓDULO

| Situação | Multi-módulo? |
|----------|---------------|
| Projeto pequeno com 1-3 devs | Geralmente NÃO — adiciona complexidade |
| Separar API de implementação | SIM — permite trocar implementação sem afetar clientes |
| Compartilhar código entre microserviços | SIM — módulo compartilhado como JAR |
| Monorepo com múltiplas aplicações | SIM — build centralizado |
| Separar testes de integração | SIM — módulo `test-integration` separado |
| Biblioteca com múltiplos adapters | SIM — core + adapter-spring + adapter-quarkus |

---

## 4. ORDEM DE BUILD

O Maven determina a ordem automaticamente baseado nas dependências entre módulos:

```
modulo-api    → sem dependências internas, builda PRIMEIRO
modulo-core   → depende de modulo-api, builda SEGUNDO
modulo-app    → depende de modulo-core, builda TERCEIRO
```

**O Maven usa uma análise de grafo (DAG) para determinar a ordem.**
Se você declarar uma dependência circular (A depende de B, B depende de A), o Maven falhará com erro.

---

## 5. PERGUNTAS DE ENTREVISTA

**Q1: Qual a diferença entre aggregation e inheritance em um projeto Maven multi-módulo?**

> **Resposta esperada:** São dois conceitos distintos que costumam andar juntos. Aggregation é quando o POM pai lista os módulos em `<modules>` — isso permite que `mvn install` no pai execute todos os filhos na ordem correta. Inheritance é quando os filhos declaram `<parent>` — isso permite que herdem configurações como `<dependencyManagement>`, `<properties>` e `<pluginManagement>` sem precisar repeti-las. Um projeto pode ter os dois juntos (o caso mais comum) ou separados: um POM pode agregar sem ser pai (sem herança), e um filho pode herdar sem ser agregado.

**Q2: Como o Maven determina a ordem de build em um projeto multi-módulo?**

> **Resposta esperada:** O Maven analisa as dependências entre os módulos e constrói um DAG (Directed Acyclic Graph). Módulos sem dependências internas são buildados primeiro; módulos que dependem de outros só são buildados depois que suas dependências foram instaladas no repositório local. Se houver dependência circular, o Maven falha com erro. É possível paralelizar o build com `mvn -T 4 install` para módulos que não dependem entre si, respeitando o DAG.
