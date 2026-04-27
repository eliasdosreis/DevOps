# Módulo 4 — Projetos Multi-Módulo com Maven

## O que você vai aprender neste módulo

- Estrutura de projeto pai e filhos
- POM pai: seção modules e dependencyManagement
- Herança vs Agregação — diferenças e quando usar cada uma
- Ordem de build e dependências entre módulos
- Casos de uso reais (microserviços, libs compartilhadas)

## Estrutura Deste Módulo

```
modulo-04-maven-multi-modulo/
│
├── README.md                          ← Este arquivo
│
├── 01-estrutura-multi-modulo.md       ← Conceito e visão geral
│
└── projeto-exemplo/                   ← Projeto multi-módulo real
    ├── pom.xml                        ← POM pai (02-pom-pai.xml)
    ├── modulo-api/
    │   └── pom.xml                    ← POM filho: interfaces e DTOs
    ├── modulo-core/
    │   └── pom.xml                    ← POM filho: implementação (depende de api)
    └── modulo-app/
        └── pom.xml                    ← POM filho: aplicação final (depende de core)
```

## Arquivos deste módulo

| Arquivo | Conceito |
|---------|----------|
| `01-estrutura-multi-modulo.md` | Conceito, analogia e quando usar |
| `projeto-exemplo/pom.xml` | POM pai com aggregation + inheritance |
| `projeto-exemplo/modulo-api/pom.xml` | Módulo filho: API (interfaces/DTOs) |
| `projeto-exemplo/modulo-core/pom.xml` | Módulo filho: implementação |
| `projeto-exemplo/modulo-app/pom.xml` | Módulo filho: aplicação principal |

## Comandos importantes

```bash
# Na raiz do projeto (onde está o POM pai):

# Build de TODOS os módulos em ordem
mvn clean install

# Build de apenas um módulo (e os que ele depende)
mvn clean install -pl modulo-core -am

# Build com paralelismo (cuidado com dependências entre módulos)
mvn clean install -T 4  # 4 threads

# Pular um módulo específico
mvn clean install -pl !modulo-app

# Ver a ordem de build
mvn dependency:tree
```
