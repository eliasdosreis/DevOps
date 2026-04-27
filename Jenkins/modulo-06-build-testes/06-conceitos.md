# ============================================================
# MÓDULO 6 — BUILD E TESTES
# Arquivo: 06-conceitos.md
# ============================================================

# Módulo 6: Build e Testes

---

## 1. FERRAMENTAS DE BUILD — COMPARAÇÃO

| Ferramenta | Ecosistema | Comando CI | Arquivo Config |
|-----------|-----------|-----------|----------------|
| **Maven** | Java | `mvn clean verify -B` | `pom.xml` |
| **Gradle** | Java/Kotlin | `./gradlew build` | `build.gradle` |
| **npm** | Node.js | `npm ci && npm test` | `package.json` |
| **pip/pytest** | Python | `pip install -r req.txt && pytest` | `setup.py/pyproject.toml` |
| **cargo** | Rust | `cargo test` | `Cargo.toml` |
| **dotnet** | .NET | `dotnet build && dotnet test` | `*.csproj` |

---

## 2. SONARQUBE: AS 7 CATEGORIAS ANALISADAS

| Categoria | O que é | Impact |
|-----------|---------|--------|
| **Bugs** | Erros que causarão falha em runtime | 🔴 Alto |
| **Vulnerabilities** | Falhas de segurança exploráveis | 🔴 Alto |
| **Security Hotspots** | Código que precisa revisão de segurança | 🟡 Médio |
| **Code Smells** | Código difícil de manter | 🟡 Médio |
| **Coverage** | % do código coberto por testes | 🟡 Médio |
| **Duplications** | Código duplicado | 🟢 Baixo |
| **Size** | Tamanho e complexidade do projeto | 🔵 Info |

---

## 3. QUALITY GATE: O CONCEITO MAIS IMPORTANTE

Um **Quality Gate** é um conjunto de condições que o código deve
satisfazer para "passar" pelo portão e seguir para o próximo ambiente.

```
Código → Build → Testes → [QUALITY GATE] → Deploy
                              ↓
                          APROVADO? → Continua
                          REPROVADO? → Para aqui
```

Quality Gate padrão do SonarQube:
- Coverage em novo código ≥ 80%
- Duplicação em novo código ≤ 3%
- Maintainability Rating: A
- Reliability Rating: A
- Security Rating: A

---

## 4. ARTEFATOS: QUANDO USAR CADA UM

```
Build → Artefato →┬→ archiveArtifacts (download permanente)
                  ├→ stash (passar para stage/agente diferente)
                  ├→ Nexus/Artifactory (repositório corporativo)
                  └→ Docker Registry (imagens de container)
```

---

## 5. PERGUNTAS DE ENTREVISTA

**Q1: Por que usar `npm ci` em vez de `npm install` em pipelines CI?**

> **Resposta**: `npm ci` é projetado especificamente para ambientes CI/CD.
> Diferenças chave: (1) usa exatamente as versões do `package-lock.json`
> sem resolver dependências, (2) remove `node_modules` antes de instalar
> (ambiente limpo garantido), (3) falha se `package-lock.json` não estiver
> sincronizado com `package.json`, (4) é mais rápido. `npm install` pode
> atualizar `package-lock.json` e resolver versões diferentes, criando
> builds não-determinísticos ("funciona na minha máquina").

**Q2: O que é um Quality Gate no SonarQube e como integrá-lo no Jenkins?**

> **Resposta**: Um Quality Gate é um conjunto de thresholds de qualidade
> que o código deve atingir para poder avançar no pipeline. Integração:
> (1) configure um webhook no SonarQube apontando para Jenkins
> (`http://jenkins/sonarqube-webhook/`), (2) execute a análise com
> `withSonarQubeEnv('...')`, (3) use `waitForQualityGate()` para aguardar
> o resultado assincronamente, (4) se o status não for `OK`, o pipeline
> falha. Isso garante que código abaixo do padrão nunca chega à produção.
