# Módulo 8 — Projeto Final Senior 🏆

## 🎯 Objetivo deste módulo
Integrar todos os conceitos aprendidos em um ambiente multi-máquina completo e profissional, com provisionamento via Ansible e simulação de entrevista técnica Senior.

---

## 📐 Arquitetura do Projeto Final

```
                    ┌─────────────────────────────────────┐
                    │        Host (sua máquina)           │
                    │        localhost:8080                │
                    └────────────────┬────────────────────┘
                                     │ VirtualBox Network
                    ┌────────────────▼────────────────────┐
                    │    LOAD BALANCER (Nginx)             │
                    │    IP: 192.168.100.10               │
                    │    lb.dev.local                      │
                    └──────┬──────────────┬───────────────┘
                           │              │
           ┌───────────────▼──┐     ┌────▼──────────────────┐
           │   WEB SERVER 1   │     │   WEB SERVER 2         │
           │   Nginx + PHP    │     │   Nginx + PHP           │
           │   192.168.100.11 │     │   192.168.100.12        │
           │   web1.dev.local │     │   web2.dev.local        │
           └──────────────────┘     └────────────────────────┘
                    │                         │
                    └──────────┬──────────────┘
                               │
                    ┌──────────▼────────────────┐
                    │   APP SERVER (Node.js)     │
                    │   IP: 192.168.100.13       │
                    │   app.dev.local            │
                    └──────────┬───────────────┘
                               │
                    ┌──────────▼────────────────┐
                    │   DATABASE (MySQL)         │
                    │   IP: 192.168.100.14       │
                    │   db.dev.local             │
                    └───────────────────────────┘
```

---

## 🛠️ Stack do Projeto Final

| Componente | Tecnologia | VM | IP |
|-----------|-----------|-----|-----|
| Load Balancer | Nginx (upstream) | lb | 192.168.100.10 |
| Web Server 1 | Nginx + PHP | web1 | 192.168.100.11 |
| Web Server 2 | Nginx + PHP | web2 | 192.168.100.12 |
| App Server | Node.js 20 + Express | app | 192.168.100.13 |
| Database | MySQL 8 | db | 192.168.100.14 |

---

## 📋 Diferenciais Nível Senior

1. **Configuração centralizada** — um único arquivo `config.yml` controla todos os IPs, recursos e variáveis
2. **Ansible roles** — cada serviço tem sua própria role com tasks isoladas
3. **Idempotência total** — pode `vagrant provision` N vezes com o mesmo resultado
4. **Health checks** — scripts que verificam o estado de cada serviço
5. **Documentação inline** — tudo comentado e explicado
6. **Segurança** — senhas via variáveis de ambiente, headers de segurança no Nginx

---

## 🚀 Como Inicializar

```bash
# 1. Instale os plugins necessários
bash install-plugins.sh

# 2. Copie o arquivo de variáveis de ambiente
cp .env.example .env
# Edite o .env com suas configurações

# 3. Suba o ambiente por ordem
vagrant up db          # Banco de dados primeiro
vagrant up app         # App depois
vagrant up web1 web2   # Web servers
vagrant up lb          # Load balancer por último

# OU suba tudo (scripts têm retry automático)
vagrant up

# 4. Verifique o ambiente
vagrant status
curl http://localhost:8080/health
```

---

## 🎯 Simulação de Entrevista Senior

Veja o arquivo `entrevista-senior.md` para 20 perguntas de entrevista com respostas completas cobrindo todos os tópicos do curso.

---

## 📂 Estrutura do Módulo

```
modulo-08-projeto-final/
├── README.md                    ← este arquivo
├── Vagrantfile                  ← Vagrantfile principal (Senior level)
├── config.yml                   ← Configuração centralizada
├── .env.example                 ← Template de variáveis sensíveis
├── install-plugins.sh           ← Script de setup de plugins
├── ansible/
│   ├── playbook.yml             ← Playbook principal
│   ├── inventory                ← Inventário gerado dinamicamente
│   └── roles/
│       ├── common/              ← Role: configurações base
│       ├── nginx-lb/            ← Role: Load Balancer
│       ├── nginx-web/           ← Role: Web Server
│       ├── nodejs-app/          ← Role: App Node.js
│       └── mysql-db/            ← Role: Banco de Dados
└── entrevista-senior.md         ← Simulação de entrevista
```
