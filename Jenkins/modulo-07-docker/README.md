# Módulo 7 — Docker e Containers no Pipeline

## O que você vai aprender

- Build de imagem Docker dentro do pipeline
- Push para registry (Docker Hub, ECR, GCR, Harbor)
- Usando Docker como agente de pipeline (agent docker)
- Docker Compose para testes de integração
- Scan de vulnerabilidades na imagem (Trivy, Snyk)

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `07-Jenkinsfile-docker-build.groovy` | Build de imagem Docker dentro do pipeline |
| `07-Jenkinsfile-docker-push.groovy` | Push de imagem para Docker Hub |
| `07-Jenkinsfile-docker-agent.groovy` | Rodando o pipeline dentro de um container |
| `07-Jenkinsfile-docker-compose.groovy` | Testes de integração com Docker Compose |
| `07-Jenkinsfile-trivy-scan.groovy` | Scan de vulnerabilidades com Trivy |
| `07-Dockerfile-exemplo` | Dockerfile de exemplo para os exercícios |
| `07-docker-compose-teste.yml` | Docker Compose para ambiente de testes |
| `07-conceitos.md` | Explicação teórica completa do módulo |

## Ordem de estudo

1. Leia `07-conceitos.md`
2. Execute na ordem: docker-build → docker-push → docker-agent → docker-compose → trivy
