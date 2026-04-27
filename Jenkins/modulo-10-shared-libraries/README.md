# Módulo 10 — Shared Libraries

## O que você vai aprender

- O que são Shared Libraries e por que usar
- Estrutura de uma Shared Library: vars, src, resources
- Criando funções reutilizáveis em Groovy
- Versionamento de bibliotecas compartilhadas
- Publicando e consumindo uma Shared Library real

## Estrutura da Shared Library de Exemplo

```
shared-library/
├── vars/                    # Funções globais chamadas diretamente no Jenkinsfile
│   ├── buildApp.groovy      # Função de build reutilizável
│   ├── deployApp.groovy     # Função de deploy reutilizável
│   └── notifySlack.groovy   # Função de notificação reutilizável
├── src/                     # Classes Groovy para lógica complexa
│   └── org/company/
│       ├── Build.groovy
│       └── Deploy.groovy
└── resources/               # Arquivos de recurso (scripts, templates)
    └── scripts/
        └── health-check.sh
```

## Arquivos deste módulo

| Arquivo/Pasta | Descrição |
|---------------|-----------|
| `shared-library/` | Estrutura completa de uma Shared Library real |
| `10-Jenkinsfile-usando-library.groovy` | Pipeline que consome a shared library |
| `10-Jenkinsfile-library-versionada.groovy` | Consumindo versão específica da library |
| `10-conceitos.md` | Explicação teórica completa + guia de configuração |

## Ordem de estudo

1. Leia `10-conceitos.md`
2. Explore a estrutura `shared-library/`
3. Configure a library no Jenkins seguindo o guia
4. Execute `10-Jenkinsfile-usando-library.groovy`
