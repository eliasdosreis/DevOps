# 03 — Gradle Wrapper

---

## 1. ANALOGIA DO DIA A DIA

Mesma analogia do Maven Wrapper (Módulo 1):

O projeto vem com seu próprio "mini-Gradle embutido". Não importa se você tem Gradle instalado ou qual versão — o wrapper baixa e usa a versão correta automaticamente.

No ecossistema Gradle, o wrapper é ainda mais importante:
- O Gradle lança versões novas frequentemente
- Scripts de Gradle Groovy em versões antigas podem não funcionar em versões novas
- Em projetos sérios, o wrapper é **MANDATÓRIO** — você nunca usa `gradle` diretamente

---

## 2. ESTRUTURA DOS ARQUIVOS DO WRAPPER

```
meu-projeto/
├── gradle/
│   └── wrapper/
│       ├── gradle-wrapper.jar          ← O bootstrap do wrapper
│       └── gradle-wrapper.properties   ← Qual versão usar e de onde baixar
│
├── gradlew          ← Script Linux/macOS (use: ./gradlew build)
├── gradlew.bat      ← Script Windows (use: gradlew.bat build)
│
├── build.gradle (ou build.gradle.kts)
└── settings.gradle (ou settings.gradle.kts)
```

---

## 3. CONTEÚDO DO gradle-wrapper.properties

```properties
# ============================================================
# ARQUIVO: gradle/wrapper/gradle-wrapper.properties
#
# O QUE ESTE ARQUIVO FAZ:
# Define qual versão do Gradle o wrapper deve usar
# e de onde baixar.
# ============================================================

# distributionBase + distributionPath: onde salvar o Gradle baixado
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists

# URL de onde baixar o Gradle:
# -bin   = apenas o binário (menor, recomendado para CI)
# -all   = binário + código-fonte + documentação (para IDE offline)
# Use -bin em produção/CI, -all para desenvolvimento(IDE resolve fontes)
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip

# zipStoreBase + zipStorePath: onde salvar o ZIP antes de extrair
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists

# (Gradle 7.4+) SHA256 do ZIP para verificação de integridade
# Obtém o hash em: https://gradle.org/release-checksums/
# networkTimeout=10000
# validateDistributionUrl=true
```

---

## 4. COMO GERAR O WRAPPER

```bash
# Pré-requisito: ter o Gradle instalado globalmente (APENAS para gerar o wrapper)
# Após gerar, nunca mais precisará do Gradle global

# Gerar wrapper com a versão padrão instalada
gradle wrapper

# Gerar wrapper com versão específica (RECOMENDADO)
gradle wrapper --gradle-version 8.5

# Gerar wrapper com distribuição completa (código + docs para IDE)
gradle wrapper --gradle-version 8.5 --distribution-type all

# Atualizar wrapper de um projeto EXISTENTE (sem Gradle global)
./gradlew wrapper --gradle-version 8.6
./gradlew wrapper --gradle-version 8.6 --distribution-type bin
```

---

## 5. COMO USAR O WRAPPER

```bash
# Linux/macOS — substitua 'gradle' por './gradlew'
./gradlew --version          # Mostra a versão (baixa se necesário)
./gradlew build              # Build completo
./gradlew clean build        # Build limpa
./gradlew test               # Apenas testes
./gradlew tasks              # Lista todas as tasks
./gradlew tasks --all        # Lista todas as tasks com detalhes
./gradlew help --task build  # Ajuda sobre uma task específica

# Windows — use 'gradlew.bat' ou 'gradlew' no PowerShell
gradlew.bat build
gradlew build  # PowerShell encontra gradlew.bat automaticamente

# Modo offline (sem internet — usa cache local)
./gradlew build --offline

# Forçar redownload das dependências
./gradlew build --refresh-dependencies
```

---

## 6. O QUE COMMITAR NO GIT

```gitignore
# .gitignore para Gradle

# Diretórios gerados (não commitar)
.gradle/
build/

# COMMITAR estes arquivos (fazem parte do projeto):
# gradlew                             → SEMPRE commitar
# gradlew.bat                         → SEMPRE commitar
# gradle/wrapper/gradle-wrapper.jar   → SEMPRE commitar
# gradle/wrapper/gradle-wrapper.properties → SEMPRE commitar
```

---

## 7. CONFIGURAÇÕES DO GRADLE EM gradle.properties

O arquivo `gradle.properties` (na raiz do projeto) define configurações do Gradle:

```properties
# ============================================================
# gradle.properties — Configurações do Gradle para o projeto
# ============================================================

# Aumenta a memória disponível para o Gradle daemon
# Projetos grandes podem precisar de mais (ex: -Xmx4g)
org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError

# Habilita o Gradle daemon (reutiliza a JVM entre builds — MUITO mais rápido)
# Padrão já é true, mas bom ser explícito
org.gradle.daemon=true

# Habilita build paralelo (executa tasks independentes em paralelo)
org.gradle.parallel=true

# Habilita o build cache (reutiliza outputs de tasks anteriores em builds)
org.gradle.caching=true

# Habilita o Configuration Cache (fase experimental — pula re-configuração)
# org.gradle.configuration-cache=true

# Habilita warnings de depreciação
# org.gradle.warning.mode=all

# Versão do Java para o processo do Gradle (não confundir com toolchain)
# org.gradle.java.home=/caminho/para/jdk
```

---

## 8. CONCEITO SENIOR

**Por que `./gradlew` e não `gradle`?**

Em ambientes profissionais, a regra é absoluta: **sempre use `./gradlew`**. Razões:

1. **Reproducibilidade**: A versão do Gradle é parte do código-fonte. Se funciona localmente, funciona no CI.

2. **Zero configuração**: Devs novos só precisam do JDK. O wrapper baixa o Gradle automaticamente.

3. **Compatibilidade de API**: O Gradle 8.x tem APIs diferentes do 7.x. Builds que funcionam em um podem quebrar em outro. O wrapper garante a versão certa.

4. **CI/CD mais simples**: Seu Dockerfile e pipeline não precisam instalar o Gradle — apenas JDK + o wrapper faz o resto.

---

## 9. PERGUNTAS DE ENTREVISTA

**Q1: Qual é a diferença entre o `gradle` instalado globalmente e o `./gradlew`?**

> **Resposta esperada:** `gradle` global usa qualquer versão instalada na máquina — diferente entre desenvolvedores e ambientes CI. `./gradlew` é o Gradle Wrapper: um script que baixa e usa EXATAMENTE a versão definida em `gradle/wrapper/gradle-wrapper.properties`. Em projetos profissionais, sempre se usa `./gradlew` para garantir reproducibilidade. O Gradle global é usado apenas UMA VEZ para gerar o wrapper inicial (`gradle wrapper --gradle-version X`).

**Q2: Quais arquivos do Gradle Wrapper devem ser commitados no Git e por quê?**

> **Resposta esperada:** Devem ser commitados: `gradlew` (script Unix), `gradlew.bat` (script Windows), `gradle/wrapper/gradle-wrapper.jar` (bootstrap) e `gradle/wrapper/gradle-wrapper.properties` (define a versão e URL). Esses arquivos garantem que qualquer pessoa ou sistema que clonar o repositório possa executar `./gradlew build` sem instalar nada além do JDK. O diretório `.gradle/` (cache local) e `build/` (artefatos gerados) NÃO devem ser commitados.
