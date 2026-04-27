# 📦 Módulo 1 - Fundamentos do Ansible

## 🧒 Explicação para Criança

> Imagine o Ansible como um **chef de cozinha robô**.
> Você escreve a **receita** (playbook), lista os **ingredientes** (inventário),
> e o robô prepara tudo automaticamente em vários computadores ao mesmo tempo!

---

## 📁 Arquivos deste Módulo (Estudar nesta ordem!)

| Arquivo | O que faz |
|---------|-----------|
| `01-inventory-simples.ini` | Lista de servidores (sua agenda de contatos) |
| `02-inventory-grupos.ini` | Servidores organizados por grupo |
| `03-inventory-variaveis.ini` | Servidores com configurações próprias |
| `04-playbook-hello.yml` | Primeiro playbook (oi mundo!) |
| `05-playbook-modulos-basicos.yml` | Módulos essenciais do Ansible |
| `06-playbook-condicoes.yml` | Tomando decisões (if/else) |
| `07-playbook-loops.yml` | Repetindo tarefas (for loop) |
| `08-ad-hoc-exemplos.sh` | Comandos rápidos sem playbook |

---

## 🎯 Conceitos que você vai dominar

- ✅ O que é inventário
- ✅ O que é playbook
- ✅ Módulos mais usados (ping, copy, apt, service, etc)
- ✅ Condicionais (when)
- ✅ Loops (loop/with_items)
- ✅ Comandos ad-hoc

---

## ▶️ Como executar

```bash
# Entrar na pasta
cd modulo1-fundamentos

# Testar conectividade
ansible -i 01-inventory-simples.ini all -m ping

# Rodar playbook
ansible-playbook -i 01-inventory-simples.ini 04-playbook-hello.yml
```
