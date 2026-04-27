# 04 — Resolução de Conflitos de Versão

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você está organizando uma festa e pediu para três amigos trazerem refrigerante:
- Amigo A traz Coca-Cola 200ml
- Amigo B traz Coca-Cola 350ml
- Amigo C traz Coca-Cola 600ml

Você só pode servir um tamanho. Quem decide qual fica?

No Maven, quando duas dependências pedem versões diferentes de uma terceira, existe uma **regra clara** para decidir qual versão "fica": a **Nearest Definition Wins** (quem está mais perto da raiz vence).

---

## 2. O QUE É (Definição Técnica Senior)

O Maven usa duas estratégias para resolver conflitos de versão:

### Regra 1: Nearest Definition Wins (Mais Próximo Vence)

A dependência com menor profundidade na árvore de dependências vence.

```
Seu projeto (profundidade 0)
├── Biblioteca A (profundidade 1)
│   └── Biblioteca C v1.0 (profundidade 2)
└── Biblioteca B (profundidade 1)
    └── Biblioteca C v2.0 (profundidade 2)
```

**Resultado**: Empate de profundidade (ambas em nível 2).

### Regra 2: First Declaration Wins (Primeiro Declarado Vence)

Em caso de empate de profundidade, a dependência declarada PRIMEIRO no pom.xml vence.

Se Biblioteca A é declarada antes de B → C v1.0 vence.

### Solução definitiva: Declaração Explícita

Declare a dependência **diretamente** no seu pom.xml. Isso a coloca em profundidade 1, sempre vencendo sobre transitivas (profundidade 2+).

---

## 3. EXEMPLOS PRÁTICOS

### Cenário de conflito real

```xml
<!-- ════════════════════════════════════════════════
  Cenário: Conflito entre versões do Jackson
  App → A → jackson-databind:2.14.0
  App → B → jackson-databind:2.15.3
  
  Ambas em profundidade 2 = EMPATE
  Quem for declarada primeiro no pom.xml vence.
  ════════════════════════════════════════════════ -->

<dependencies>

  <!-- Declarada primeiro → sua transitiva do Jackson "vence" -->
  <dependency>
    <groupId>com.biblioteca</groupId>
    <artifactId>biblioteca-a</artifactId>
    <version>1.0.0</version>
    <!-- Traz jackson-databind:2.14.0 como transitiva -->
  </dependency>

  <dependency>
    <groupId>com.outra</groupId>
    <artifactId>biblioteca-b</artifactId>
    <version>2.0.0</version>
    <!-- Traz jackson-databind:2.15.3 como transitiva -->
  </dependency>

</dependencies>
```

### Solução: Force a versão explicitamente

```xml
<dependencies>

  <dependency>
    <groupId>com.biblioteca</groupId>
    <artifactId>biblioteca-a</artifactId>
    <version>1.0.0</version>
  </dependency>

  <dependency>
    <groupId>com.outra</groupId>
    <artifactId>biblioteca-b</artifactId>
    <version>2.0.0</version>
  </dependency>

  <!-- SOLUÇÃO: declare explicitamente a versão desejada -->
  <!-- Profundidade 1 → sempre vence sobre as transitivas (profundidade 2) -->
  <!-- Esta é a forma CORRETA e EXPLÍCITA de resolver conflitos -->
  <dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.15.3</version>
    <!-- Use SEMPRE a versão MAIS RECENTE (compatível) em conflitos -->
  </dependency>

</dependencies>
```

---

## 4. COMANDOS PARA DIAGNOSTICAR CONFLITOS

```bash
# Ver a árvore de dependências
mvn dependency:tree

# Ver em modo verboso - mostra versões OMITIDAS (conflitos)
# Linhas com "(omitted for conflict with X.Y.Z)" = conflito resolvido
mvn dependency:tree -Dverbose

# Filtrar para ver apenas conflitos de uma lib específica
mvn dependency:tree -Dverbose -Dincludes=com.fasterxml.jackson.core:jackson-databind

# Exemplo de saída com conflito:
# [INFO] +- com.biblioteca:biblioteca-a:jar:1.0.0:compile
# [INFO] |  \- com.fasterxml.jackson.core:jackson-databind:jar:2.14.0:compile
# [INFO] \- com.outra:biblioteca-b:jar:2.0.0:compile
# [INFO]    \- com.fasterxml.jackson.core:jackson-databind:jar:2.15.3:compile (omitted for conflict with 2.14.0)
#
# "omitted for conflict" = esta versão FOI PERDIDA pelo conflito
# Jackson 2.14.0 ganhou porque biblioteca-a foi declarada primeiro

# Verificar artefatos com múltiplas versões (Maven Enforcer)
mvn enforcer:enforce -Drules=dependencyConvergence
```

---

## 5. MAVEN ENFORCER PLUGIN — O GUARDIÃO DE VERSÕES

O `maven-enforcer-plugin` pode fazer o build **falhar automaticamente** se houver conflitos de versão. Isso é uma prática Senior essencial para manter a base de código saudável.

```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-enforcer-plugin</artifactId>
      <version>3.4.1</version>
      <executions>
        <execution>
          <id>enforce-versions</id>
          <!-- Vincula à fase validate — falha cedo se houver conflito -->
          <phase>validate</phase>
          <goals>
            <goal>enforce</goal>
          </goals>
          <configuration>
            <rules>
              <!-- Falha se houver mais de uma versão da mesma dependência -->
              <dependencyConvergence/>

              <!-- Exige versão mínima do Maven -->
              <requireMavenVersion>
                <version>[3.8.0,)</version>
              </requireMavenVersion>

              <!-- Exige versão mínima do Java -->
              <requireJavaVersion>
                <version>[17,)</version>
              </requireJavaVersion>
            </rules>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

---

## 6. CONCEITO SENIOR

### O que um Senior faz que um Junior não faz

**Junior**: Ignora conflitos até o código quebrar em produção.

**Senior**: 
1. Usa `mvn dependency:tree -Dverbose` regularmente para detectar conflitos
2. Usa `maven-enforcer-plugin` com `dependencyConvergence` para que o CI falhe em caso de conflito
3. Usa BOMs para garantir compatibilidade de versões em ecossistemas grandes
4. Sempre atualiza para a versão MAIS RECENTE (e compatível) no conflito, nunca para a mais velha
5. Documenta o raciocínio quando força uma versão específica

### Armadilha comum: "Funcionar na minha máquina"

Conflitos de versão não geram erros na COMPILAÇÃO. Geram `ClassNotFoundException`, `NoSuchMethodError` ou `IncompatibleClassChangeError` em RUNTIME — às vezes apenas em produção, com código específico que ativa a dependência conflitante.

**Por isso**: Use `dependencyConvergence` no Enforcer Plugin em TODOS os projetos profissionais.

### Quando usar `<exclusion>` vs declaração explícita

| Situação | Solução |
|----------|---------|
| Quer remover a dependência completamente | `<exclusion>` |
| Quer forçar uma versão específica | Declaração explícita em `<dependencies>` |
| Quer centralizar versões de muitos módulos | `<dependencyManagement>` |
| Quer garantir versões compatíveis de frameworks | BOM com `scope=import` |

---

## 7. PERGUNTAS DE ENTREVISTA

**Q1: Como o Maven resolve conflitos quando dois módulos exigem versões diferentes da mesma dependência?**

> **Resposta esperada:** O Maven usa "Nearest Definition Wins" — a versão mais próxima da raiz na árvore de dependências vence. Se duas versões estão na mesma profundidade, a declarada primeiro no pom.xml vence (First Declaration Wins). A melhor prática é declarar a versão desejada EXPLICITAMENTE em `<dependencies>`, pois isso a coloca na profundidade 1, garantindo que sempre vença. Outra opção é usar `<dependencyManagement>` para centralizar o controle de versões.

**Q2: Como você detecta e evita conflitos de dependência em um projeto Maven de médio/grande porte?**

> **Resposta esperada:** Primeiro, uso `mvn dependency:tree -Dverbose` para visualizar conflitos (linhas "omitted for conflict"). Para prevenir automaticamente, configuro o `maven-enforcer-plugin` com a regra `dependencyConvergence` — isso faz o build falhar se houver versões divergentes, garantindo que conflitos sejam detectados no CI antes de chegar em produção. Para gerenciar versões em projetos com muitas dependências correlatas (Spring, Jackson, etc.), uso BOMs via `scope=import` em `<dependencyManagement>`.
