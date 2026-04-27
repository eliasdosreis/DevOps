# 02 — Estrutura de Diretórios Padrão

---

## 1. ANALOGIA DO DIA A DIA

Imagine uma **biblioteca bem organizada**.

Na biblioteca, cada tipo de livro tem uma seção:
- Ficção científica fica em um corredor
- Biografias ficam em outro
- Revistas ficam na seção de periódicos

Se cada biblioteca inventasse a sua própria organização, ninguém conseguiria encontrar nada ao visitar uma biblioteca nova.

O Maven criou um **padrão de organização** que todos os projetos Java seguem — o **Maven Standard Directory Layout**. Assim, qualquer desenvolvedor que abre um projeto Maven sabe exatamente onde encontrar cada coisa.

O Gradle adotou o mesmo padrão (por isso você vai ver a mesma estrutura nos dois).

---

## 2. O QUE É (Definição Técnica Senior)

O **Maven Standard Directory Layout** é uma convenção de organização de diretórios que define onde colocar:
- Código-fonte principal (`src/main/java`)
- Recursos (properties, XMLs, etc.) (`src/main/resources`)
- Código de teste (`src/test/java`)
- Recursos de teste (`src/test/resources`)
- Arquivos de build gerados (`target/` no Maven, `build/` no Gradle)

Seguir essa convenção é o princípio **"Convention over Configuration"** — ao seguir o padrão, você não precisa configurar nada. O Maven sabe automaticamente onde procurar o código.

---

## 3. ESTRUTURA COMPLETA COMENTADA

```
meu-projeto/
│
├── pom.xml                          ← [MAVEN] Arquivo de configuração principal
├── build.gradle                     ← [GRADLE] Arquivo de build principal
├── settings.gradle                  ← [GRADLE] Nome do projeto e subprojetos
│
├── src/
│   ├── main/                        ← Código que vai para PRODUÇÃO
│   │   ├── java/                    ← Código-fonte Java (.java)
│   │   │   └── com/
│   │   │       └── empresa/
│   │   │           └── App.java
│   │   ├── resources/               ← Arquivos de configuração (application.properties, etc.)
│   │   │   ├── application.properties
│   │   │   └── logback.xml
│   │   └── webapp/                  ← [OPCIONAL] Aplicações web (HTML, CSS, WEB-INF)
│   │       └── WEB-INF/
│   │           └── web.xml
│   │
│   └── test/                        ← Código de TESTE (não vai para produção)
│       ├── java/                    ← Código-fonte dos testes
│       │   └── com/
│       │       └── empresa/
│       │           └── AppTest.java
│       └── resources/               ← Recursos usados apenas nos testes
│           └── test-data.json
│
├── target/                          ← [MAVEN] Gerado automaticamente pelo build
│   ├── classes/                     ← .class compilados do código principal
│   ├── test-classes/                ← .class compilados dos testes
│   ├── meu-projeto-1.0.0.jar        ← JAR final gerado
│   └── surefire-reports/            ← Relatórios de testes
│
└── build/                           ← [GRADLE] Equivalente ao target/ do Maven
    ├── classes/
    ├── libs/
    └── reports/
```

---

## 4. DETALHAMENTO DE CADA DIRETÓRIO

### `src/main/java/`
- **O que é:** Contém todo o código-fonte Java da aplicação
- **Estrutura:** Deve espelhar o `package` das classes
  - Classe `com.empresa.App` → arquivo em `src/main/java/com/empresa/App.java`
- **Por que importa:** O compilador (`javac`) procura os arquivos aqui
- **OBRIGATÓRIO** para projetos Java

### `src/main/resources/`
- **O que é:** Recursos que serão empacotados junto com o código no JAR/WAR
- **Exemplos:** `application.properties`, `logback.xml`, arquivos SQL, templates
- **Por que importa:** Esses arquivos ficam disponíveis no classpath da aplicação em runtime
- **OPCIONAL** (mas quase sempre necessário em projetos reais)

### `src/test/java/`
- **O que é:** Código de teste unitário e integração
- **Convenção:** Nome do arquivo de teste + `Test` (ex: `AppTest.java` testa `App.java`)
- **IMPORTANTE:** Este código **nunca vai para o JAR de produção**
- **OBRIGATÓRIO** em projetos profissionais (projetos sem testes são inaceitáveis)

### `src/test/resources/`
- **O que é:** Recursos usados apenas durante os testes
- **Exemplos:** `application-test.properties`, dados de fixtures, schemas SQL de teste
- **OPCIONAL**

### `target/` (Maven) e `build/` (Gradle)
- **O que é:** Diretório gerado automaticamente pelo build
- **NUNCA commite esses diretórios no Git** — coloque no `.gitignore`
- É seguro deletar — o build os recria

---

## 5. ARQUIVO `.gitignore` ESSENCIAL

```gitignore
# Diretórios de build — gerados automaticamente, não versionar
target/
build/

# Arquivos de IDE (gerados pela IDE, não são do projeto)
.idea/
*.iml
.eclipse/
.project
.classpath
.settings/

# Arquivos de sistema operacional
.DS_Store
Thumbs.db

# Gradle wrapper (EXCETO o jar do wrapper — ele deve ser commitado)
.gradle/
!gradle/wrapper/gradle-wrapper.jar
```

---

## 6. HelloWorld.java — Exemplo de Código

Salve este arquivo em: `src/main/java/com/curso/HelloWorld.java`

```java
// Pacote: deve espelhar a estrutura de diretórios
// src/main/java/com/curso/HelloWorld.java → package com.curso
package com.curso;

/**
 * Classe de exemplo para testar que o ambiente está configurado.
 * Em projetos reais, cada classe tem uma responsabilidade clara.
 */
public class HelloWorld {

    public static void main(String[] args) {
        System.out.println("Ambiente configurado com sucesso!");
        System.out.println("Java version: " + System.getProperty("java.version"));
    }
}
```

**Compilar e executar manualmente (sem Maven/Gradle):**
```bash
# A partir da raiz do projeto:
javac -d target/classes src/main/java/com/curso/HelloWorld.java

java -cp target/classes com.curso.HelloWorld
# Saída: Ambiente configurado com sucesso!
# Saída: Java version: 21.0.x
```

---

## 7. CONCEITO SENIOR

### Por que seguir o padrão é fundamental

Em entrevistas e no trabalho, você verá projetos com estruturas "criativas" que fogem do padrão. Isso é um **sinal vermelho**:

1. **Plugins param de funcionar**: O maven-surefire-plugin procura testes em `src/test/java`. Se você colocar em outro lugar, os testes não são executados — e ninguém percebe.

2. **Integração com IDEs quebra**: IntelliJ IDEA, Eclipse e VS Code reconhecem automaticamente a estrutura padrão. Estruturas customizadas exigem configuração manual e causam problemas no autocomplete.

3. **CI/CD complica**: Pipelines padronizados assumem a estrutura padrão. Fugir dela exige mais configuração no pipeline.

4. **Onboarding de novos devs é mais lento**: Um dev que já conhece Maven pode abrir qualquer projeto Maven e saber onde tudo está. Estruturas criativas quebram esse conhecimento.

### Customizando o diretório de código-fonte (quando realmente necessário)

No Maven, você pode mudar o diretório padrão (não recomendado sem boa razão):
```xml
<build>
    <!-- Só faça isso se tiver uma razão MUITO boa -->
    <sourceDirectory>src/main/meu-codigo</sourceDirectory>
    <testSourceDirectory>src/test/meu-test</testSourceDirectory>
</build>
```

No Gradle:
```groovy
sourceSets {
    main {
        java {
            srcDirs = ['src/main/meu-codigo']  // Só em casos especiais
        }
    }
}
```

---

## 8. PERGUNTAS DE ENTREVISTA

**Q1: O que é o Maven Standard Directory Layout e por que ele existe?**

> **Resposta esperada:** É uma convenção de organização de diretórios criada pelo Maven que define onde colocar código-fonte, testes e recursos. Existe para implementar o princípio "Convention over Configuration" — ao seguir o padrão, as ferramentas (Maven, Gradle, IDEs, plugins) funcionam automaticamente sem configuração adicional. Isso reduz atrito no onboarding, facilita integração entre ferramentas e torna os projetos mais previsíveis e padronizados entre times.

**Q2: Por que o diretório `target/` (ou `build/`) nunca deve ser commitado no Git?**

> **Resposta esperada:** Porque ele é gerado automaticamente pelo processo de build e pode ser recriado a qualquer momento. Commitá-lo causa: (1) aumento desnecessário do repositório; (2) conflitos de merge impossíveis de resolver (arquivos binários compilados); (3) falsa sensação de segurança — arquivos antigos no `target/` podem mascarar erros de compilação. A regra é: tudo que pode ser gerado a partir do código-fonte não deve estar no Git.
