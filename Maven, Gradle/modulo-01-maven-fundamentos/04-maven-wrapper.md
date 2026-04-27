# 04 — Maven Wrapper (mvnw)

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você recebe uma receita de bolo e a primeira linha diz:
> "Use um forno modelo X-2000, temperatura 180°C"

O problema: você tem um forno diferente em casa. A receita pode não funcionar corretamente.

A solução seria a receita vir com um **mini-forno embutido** — assim, não importa qual forno você tem, a receita funciona igual em qualquer lugar.

O **Maven Wrapper** (mvnw) é exatamente isso: uma versão do Maven embutida no projeto, que garante que TODOS (desenvolvedores, CI/CD, produção) usem **exatamente a mesma versão do Maven**.

---

## 2. O QUE É (Definição Técnica Senior)

O **Maven Wrapper** é um script de shell (`mvnw` no Linux/macOS, `mvnw.cmd` no Windows) que:

1. Lê a versão do Maven definida em `.mvn/wrapper/maven-wrapper.properties`
2. Verifica se essa versão está no cache local (`~/.m2/wrapper/`)
3. Se não estiver, baixa automaticamente
4. Executa o Maven com a versão correta

**Por que é importante:**
- Elimina o problema "funciona na minha máquina" por diferença de versão do Maven
- Desenvolvedores não precisam instalar o Maven manualmente
- CI/CD usa sempre a versão correta sem configuração adicional
- Projetos open source garantem que todos os contribuidores usam o mesmo setup

**Analogia técnica:** É similar ao `gradlew` (Gradle Wrapper) — a solução que o Gradle popularizou e o Maven adotou depois.

---

## 3. ESTRUTURA DOS ARQUIVOS DO WRAPPER

```
meu-projeto/
├── .mvn/
│   └── wrapper/
│       ├── maven-wrapper.jar         ← O mini-Maven que baixa a versão correta
│       └── maven-wrapper.properties  ← Qual versão do Maven usar
│
├── mvnw          ← Script para Linux/macOS (use: ./mvnw clean package)
├── mvnw.cmd      ← Script para Windows (use: mvnw.cmd clean package)
└── pom.xml
```

---

## 4. CONTEÚDO DO maven-wrapper.properties

```properties
# ============================================================
# ARQUIVO: .mvn/wrapper/maven-wrapper.properties
#
# O QUE ESTE ARQUIVO FAZ:
# Define qual versão do Maven o wrapper deve usar.
# Este arquivo DEVE ser commitado no Git.
# ============================================================

# URL de onde baixar o Maven caso não esteja no cache local
# Aponta para a versão específica que o projeto requer
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.zip

# (Opcional) Define onde armazenar o Maven baixado
# Por padrão usa: ${user.home}/.m2/wrapper/dists/
# wrapperUrl=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar
```

---

## 5. COMO GERAR O WRAPPER

```bash
# Na raiz do projeto (onde está o pom.xml):

# Opção 1: Gerar o wrapper para a versão padrão
mvn wrapper:wrapper

# Opção 2: Gerar o wrapper para uma versão específica
mvn wrapper:wrapper -Dmaven=3.9.6

# Resultado: cria os arquivos mvnw, mvnw.cmd e .mvn/wrapper/
```

---

## 6. COMO USAR O WRAPPER

```bash
# Linux/macOS — substitua "mvn" por "./mvnw" em todos os comandos
./mvnw --version          # Verifica a versão (baixa se necessário)
./mvnw clean package      # Build limpa
./mvnw clean install      # Build + instala no repositório local
./mvnw test               # Executa os testes

# Windows — use "mvnw.cmd" ou apenas "mvnw" no PowerShell
mvnw.cmd --version
mvnw.cmd clean package
```

---

## 7. O QUE COMMITAR NO GIT

```gitignore
# .gitignore para o wrapper:

# NÃO commitar o cache do wrapper
.mvn/wrapper/maven-wrapper.jar.sha256

# COMMITAR estes arquivos (são parte do projeto):
# .mvn/wrapper/maven-wrapper.properties  ← SEMPRE commitar
# .mvn/wrapper/maven-wrapper.jar         ← SEMPRE commitar
# mvnw                                   ← SEMPRE commitar
# mvnw.cmd                               ← SEMPRE commitar
```

---

## 8. CONCEITO SENIOR

### Por que o mvnw é OBRIGATÓRIO em projetos sérios

Em times profissionais, **NUNCA** se usa `mvn` diretamente — sempre `./mvnw`. Por quê?

1. **Reproducibilidade de build**: Um pipeline de CI funcionando hoje pode quebrar amanhã se alguém atualizar o Maven globalmente. Com o wrapper, a versão está fixada no código.

2. **Zero friction onboarding**: Um dev novo só precisa do JDK. O wrapper baixa o Maven automaticamente.

3. **Compatibilidade com plugins**: Alguns plugins exigem versões mínimas específicas do Maven. O wrapper garante isso.

4. **Auditoria**: Fica registrado no Git qual versão do Maven o projeto usa e quando foi atualizada.

### Atualizar a versão do Maven no wrapper

```bash
# Atualizar para uma nova versão:
mvn wrapper:wrapper -Dmaven=3.9.8

# Após isso, commite os arquivos modificados:
git add .mvn/wrapper/maven-wrapper.properties mvnw mvnw.cmd
git commit -m "build: upgrade Maven wrapper to 3.9.8"
```

### Gradle popularizou, Maven adotou

O Maven Wrapper foi inspirado no Gradle Wrapper, que existiu primeiro. O plugin `wrapper` foi adicionado ao Maven 3.7.0+ oficialmente. Em projetos mais antigos, você pode ver o wrapper feito manualmente ou usando o plugin `maven-wrapper-plugin` de terceiros.

---

## 9. PERGUNTAS DE ENTREVISTA

**Q1: O que é o Maven Wrapper e por que ele é preferido ao Maven instalado globalmente?**

> **Resposta esperada:** O Maven Wrapper (mvnw) é um script que acompanha o projeto e baixa automaticamente a versão correta do Maven definida em `.mvn/wrapper/maven-wrapper.properties`. Ele é preferido ao Maven global porque garante que todos os desenvolvedores e ambientes de CI/CD usem EXATAMENTE a mesma versão do Maven, eliminando o problema "funciona na minha máquina" causado por diferenças de versão. Isso é crítico para reproducibilidade de builds.

**Q2: Quais arquivos do Maven Wrapper devem ser commitados no Git?**

> **Resposta esperada:** Devem ser commitados: `mvnw` (script Linux/macOS), `mvnw.cmd` (script Windows), `.mvn/wrapper/maven-wrapper.properties` (define a versão) e `.mvn/wrapper/maven-wrapper.jar` (o bootstrap do wrapper). Estes arquivos são PARTE do projeto e garantem que qualquer um que clone o repositório tenha o ambiente correto sem instalar o Maven manualmente.
