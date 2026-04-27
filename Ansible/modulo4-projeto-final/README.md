# 🏆 Módulo 4 - Projeto Final Sênior

## 🧒 Explicação para Criança

> Imagine construir um shopping completo!
> Tem lojas (app), estoque (banco de dados), segurança (firewall),
> câmeras (monitoramento), e tudo gerenciado por um único "síndico" (Ansible).
> Isso é o projeto final!

---

## 🎯 O que este Projeto Faz

Deploy completo de uma aplicação web em produção com:
- 🌐 **Webservers** com Nginx + SSL
- 🗄️ **PostgreSQL** com backup automático
- 🔐 **Hardening** de segurança (SSH, firewall, fail2ban)
- 📊 **Monitoramento** com Node Exporter (Prometheus)
- 🔒 **Vault** para todas as credenciais

---

## 📁 Estrutura do Projeto

```
modulo4-projeto-final/
├── site.yml                    ← Playbook mestre (o "síndico")
├── ansible.cfg                 ← Configurações do Ansible
├── inventories/
│   ├── producao/               ← Servidores de produção
│   └── staging/                ← Servidores de teste
├── group_vars/                 ← Variáveis por grupo
├── host_vars/                  ← Variáveis por servidor
└── roles/
    ├── app/                    ← Role da aplicação web
    ├── database/               ← Role do banco de dados
    ├── monitoring/             ← Role de monitoramento
    └── security/               ← Role de segurança
```

---

## ▶️ Como Executar

```bash
cd modulo4-projeto-final

# 1. Criar o vault com as senhas
ansible-vault create group_vars/all/secrets.yml

# 2. Deploy completo em staging primeiro
ansible-playbook -i inventories/staging site.yml --ask-vault-pass

# 3. Deploy em produção (com cuidado!)
ansible-playbook -i inventories/producao site.yml --ask-vault-pass

# 4. Só instalar segurança
ansible-playbook -i inventories/producao site.yml --tags security --ask-vault-pass

# 5. Só atualizar a aplicação
ansible-playbook -i inventories/producao site.yml --tags app --ask-vault-pass
```

---

## 🔑 Conceitos Sênior Demonstrados

| Conceito | Onde está |
|----------|-----------|
| Roles organizadas | `roles/` |
| Vault (segredos) | `group_vars/all/secrets.yml` |
| Multi-ambiente | `inventories/producao` e `staging` |
| Tags por componente | Cada role tem suas tags |
| Error handling | `roles/*/tasks/*.yml` |
| Templates avançados | `roles/*/templates/*.j2` |
| Handlers em cadeia | `roles/*/handlers/main.yml` |
| Idempotência | Cada task pode rodar N vezes sem problema |
