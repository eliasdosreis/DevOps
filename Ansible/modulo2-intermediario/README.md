# 🏗️ Módulo 2 - Roles, Variables e Templates

## 🧒 Explicação para Criança

> Imagine que você precisa montar 100 computadores iguais.
> Em vez de configurar um por um, você cria um **"kit de montagem"** (Role)
> com tudo dentro: manual, peças, etiquetas.
> Aí é só aplicar o kit em cada computador!

---

## 📁 Arquivos deste Módulo (Estudar nesta ordem!)

| Arquivo/Pasta | O que faz |
|---------------|-----------|
| `01-variaveis-tipos.yml` | Todos os tipos de variáveis |
| `02-variaveis-precedencia.yml` | Qual variável "ganha" quando há conflito |
| `03-template-basico.yml` + `templates/` | Criar arquivos dinâmicos com Jinja2 |
| `04-handlers.yml` | Ações que só rodam quando algo muda |
| `05-role-estrutura/` | Estrutura completa de uma Role |
| `06-role-webserver/` | Role real: instalando e configurando Nginx |

---

## 🎯 Conceitos que você vai dominar

- ✅ Variáveis (vars, defaults, host_vars, group_vars)
- ✅ Precedência de variáveis
- ✅ Templates Jinja2
- ✅ Handlers (notificadores)
- ✅ Roles (organização profissional)
- ✅ Tags

---

## ▶️ Como executar

```bash
cd modulo2-intermediario

# Playbook de variáveis
ansible-playbook -i ../modulo1-fundamentos/01-inventory-simples.ini 01-variaveis-tipos.yml

# Playbook com template
ansible-playbook -i ../modulo1-fundamentos/01-inventory-simples.ini 03-template-basico.yml

# Rodar a role
ansible-playbook -i ../modulo1-fundamentos/02-inventory-grupos.ini 06-role-webserver/site.yml
```
