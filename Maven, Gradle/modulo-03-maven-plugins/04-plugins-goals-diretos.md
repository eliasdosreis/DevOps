# 04 — Goals de Plugins Executados Diretamente

---

## 1. ANALOGIA DO DIA A DIA

Pense nos plugins do Maven como uma caixa de ferramentas.

Quando você faz o processo de build normal (`mvn package`), é como usar uma **linha de montagem** — cada máquina executa na ordem certa.

Mas às vezes você quer usar apenas **uma ferramenta específica** sem rodar a linha toda. Por exemplo: quer só medir o quanto a loja cresceu (relatório de dependências) sem produzir nada.

Executar um goal diretamente é como pegar uma ferramenta da caixa e usar sem ligar a linha de produção.

---

## 2. COMO EXECUTAR GOALS DIRETAMENTE

```bash
# Sintaxe: mvn groupId:artifactId:versão:goal
# Forma abreviada: mvn prefixo:goal

# EXEMPLOS PRÁTICOS:

# ─────────────────────────────────────────────────────
# Plugin: maven-dependency-plugin
# ─────────────────────────────────────────────────────

# Ver árvore de dependências
mvn dependency:tree

# Ver árvore com detalhes de conflitos
mvn dependency:tree -Dverbose

# Filtrar por artifact específico
mvn dependency:tree -Dincludes=org.springframework:*

# Analisar dependências: usadas/não declaradas, declaradas/não usadas
mvn dependency:analyze

# Copiar todas as dependências para target/dependency/
mvn dependency:copy-dependencies

# Copiar dependências de escopo runtime para target/libs/
mvn dependency:copy-dependencies -DincludeScope=runtime -DoutputDirectory=target/libs

# ─────────────────────────────────────────────────────
# Plugin: versions-maven-plugin
# Um dos mais úteis no dia a dia!
# ─────────────────────────────────────────────────────

# Adicione ao pom.xml (pluginManagement) para usar:
# <plugin>
#   <groupId>org.codehaus.mojo</groupId>
#   <artifactId>versions-maven-plugin</artifactId>
#   <version>2.16.2</version>
# </plugin>

# Mostra quais dependências têm versões mais recentes disponíveis
mvn versions:display-dependency-updates

# Mostra quais plugins têm versões mais recentes disponíveis
mvn versions:display-plugin-updates

# Atualiza automaticamente as versões das dependências
# (criar branch antes!)
mvn versions:use-latest-releases

# Atualiza versões de properties (ex: <junit.version>)
mvn versions:update-properties

# ─────────────────────────────────────────────────────
# Plugin: maven-help-plugin
# ─────────────────────────────────────────────────────

# Descreve um plugin e seus goals disponíveis
mvn help:describe -Dplugin=compiler

# Com detalhes de configuração de cada parâmetro
mvn help:describe -Dplugin=compiler -Ddetail

# Descreve um goal específico
mvn help:describe -Dplugin=compiler -Dgoal=compile

# Mostra o POM efetivo (após herança, interpolação, etc.)
mvn help:effective-pom

# Mostra as configurações efetivas de um plugin
mvn help:effective-settings

# Mostra o sistema de versões ativo
mvn help:system

# ─────────────────────────────────────────────────────
# Plugin: maven-enforcer-plugin
# ─────────────────────────────────────────────────────

# Executa as regras do enforcer manualmente
mvn enforcer:enforce

# ─────────────────────────────────────────────────────
# Plugin: exec-maven-plugin
# Executa uma classe Java main() sem empacotar
# ─────────────────────────────────────────────────────

# Configuração no pom.xml (opcional, facilita o comando):
# <plugin>
#   <groupId>org.codehaus.mojo</groupId>
#   <artifactId>exec-maven-plugin</artifactId>
#   <version>3.1.1</version>
# </plugin>

# Executa uma classe com main():
mvn exec:java -Dexec.mainClass="com.curso.App"

# Com argumentos:
mvn exec:java -Dexec.mainClass="com.curso.App" -Dexec.args="arg1 arg2"

# ─────────────────────────────────────────────────────
# Plugin: maven-source-plugin
# Empacota o código-fonte em um JAR
# ─────────────────────────────────────────────────────

mvn source:jar
# Gera: target/nome-projeto-1.0.0-SNAPSHOT-sources.jar

# ─────────────────────────────────────────────────────
# Plugin: maven-javadoc-plugin
# Gera documentação JavaDoc
# ─────────────────────────────────────────────────────

mvn javadoc:javadoc
# Gera: target/site/apidocs/index.html

mvn javadoc:jar
# Gera: target/nome-projeto-1.0.0-SNAPSHOT-javadoc.jar

# ─────────────────────────────────────────────────────
# Plugin: maven-checkstyle-plugin
# Verifica se o código segue as regras de estilo
# ─────────────────────────────────────────────────────

mvn checkstyle:check
# Falha o build se houver violações

mvn checkstyle:checkstyle
# Gera relatório sem falhar o build
```

---

## 3. CONCEITO SENIOR — Prefixo de Plugins

O Maven resolve `dependency:tree` para o groupId correto porque existe um arquivo de "prefixos" publicado no Maven Central:

```
dependency → org.apache.maven.plugins:maven-dependency-plugin
compiler   → org.apache.maven.plugins:maven-compiler-plugin
surefire   → org.apache.maven.plugins:maven-surefire-plugin
versions   → org.codehaus.mojo:versions-maven-plugin
exec       → org.codehaus.mojo:exec-maven-plugin
```

Para plugins fora desses dois groupIds, você precisa usar o groupId completo:

```bash
# Plugin de terceiro sem prefixo mapeado:
mvn com.spotify:docker-maven-plugin:1.2.2:build

# Mas você pode configurar um prefixo no plugin (avançado):
# Adicione extension=true ou configure o prefixo no plugin descriptor
```

---

## 4. PERGUNTAS DE ENTREVISTA

**Q1: Como você verifica se alguma dependência do projeto tem uma versão mais recente disponível?**

> **Resposta esperada:** Uso o `versions-maven-plugin` com o goal `display-dependency-updates`: `mvn versions:display-dependency-updates`. Esse comando consulta o repositório Maven e lista todas as dependências que têm versões mais recentes disponíveis, mostrando a versão atual e a mais recente. Para plugins, uso `versions:display-plugin-updates`. Em projetos com CI/CD, posso configurar o `dependabot` ou `renovate` para criar PRs automáticos com atualizações.

**Q2: Qual a diferença entre executar `mvn package` e `mvn jar:jar` diretamente?**

> **Resposta esperada:** `mvn package` é uma FASE do ciclo de vida — ele executa TODAS as fases anteriores antes de chegar no package: validate, compile, test, etc. `mvn jar:jar` é um GOAL de plugin executado DIRETAMENTE — ele apenas empacota o que já está compilado em `target/classes/` sem compilar nem testar. Isso é útil em casos específicos (como reempacotar após modificações manuais no classpath), mas perigoso em uso geral porque pode criar JARs com código desatualizado. Em 99% dos casos, use `mvn package`.
