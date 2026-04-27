# Módulo 0 — Preparação do Ambiente

## O que você vai aprender

- Instalar o Jenkins via Docker (sem poluir a máquina local)
- Configurar plugins essenciais e usuário admin
- Entender a arquitetura Jenkins: Controller, Agents, Executor
- Criar o primeiro job freestyle para conhecer a interface

## Arquivos deste módulo

| Arquivo | Descrição |
|---------|-----------|
| `00-docker-compose.yml` | Sobe o Jenkins via Docker Compose |
| `00-plugins.txt` | Lista dos plugins essenciais |
| `00-job-freestyle.md` | Guia passo a passo do primeiro job freestyle |
| `00-arquitetura.md` | Explicação da arquitetura Controller/Agent/Executor |

## Pré-requisitos

- Docker Desktop instalado e rodando
- Git instalado
- Porta 8080 disponível na máquina

## Ordem de estudo

1. Leia `00-arquitetura.md` (entenda antes de instalar)
2. Execute `00-docker-compose.yml`
3. Instale os plugins de `00-plugins.txt`
4. Siga `00-job-freestyle.md`
