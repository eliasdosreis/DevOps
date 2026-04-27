# Módulo 4 — Credentials e Secrets

## O que você vai aprender

- Gerenciamento de credentials no Jenkins (Credentials Store)
- Tipos de credentials: username/password, secret text, SSH key, certificate
- Usando credentials no pipeline com `withCredentials` e `credentials()`
- Boas práticas: nunca expor secrets no log

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `04-Jenkinsfile-secret-text.groovy` | Usando uma credential do tipo secret text |
| `04-Jenkinsfile-username-password.groovy` | Usando username/password no pipeline |
| `04-Jenkinsfile-ssh-key.groovy` | Autenticação com chave SSH |
| `04-Jenkinsfile-binding-environment.groovy` | Credentials como variáveis de ambiente |
| `04-conceitos.md` | Explicação teórica + guia de cadastro no Jenkins |

## Ordem de estudo

1. Leia `04-conceitos.md` (inclui guia de cadastro via UI)
2. Cadastre as credentials no Jenkins antes de executar os pipelines
3. Execute na ordem: secret-text → username-password → ssh-key → binding
