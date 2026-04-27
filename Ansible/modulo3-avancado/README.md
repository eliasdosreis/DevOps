# 🔐 Módulo 3 - Avançado: Vault, Dynamic Inventory, Galaxy & Otimização

## 🧒 Explicação para Criança

> Agora você já sabe construir uma casa.
> Módulo 3 é aprender a:
> 🔐 Colocar cofre com segredo (Vault)
> 🗺️ Descobrir endereços automaticamente (Dynamic Inventory)
> 🏪 Ir na loja de roles prontas (Ansible Galaxy)
> ⚡ Construir mais rápido (paralelismo, tags, otimização)

---

## 📁 Arquivos (Estudar nesta ordem!)

| Arquivo | O que faz |
|---------|-----------|
| `01-vault-basico.yml` | Criptografar senhas e segredos |
| `02-vault-uso.yml` | Usar variáveis criptografadas |
| `03-dynamic-inventory.py` | Inventário que descobre servidores sozinho |
| `04-ansible-galaxy.sh` | Usar roles prontas da comunidade |
| `05-otimizacao-performance.yml` | Rodar tarefas em paralelo, tags, estratégias |
| `06-error-handling.yml` | Tratar erros como um Sênior |
| `07-custom-modules.py` | Criar seu próprio módulo Ansible |

---

## 🎯 Conceitos Senior que você vai dominar

- ✅ Ansible Vault (segurança de credenciais)
- ✅ Dynamic Inventory (AWS, GCP, Azure)
- ✅ Ansible Galaxy (reutilização)
- ✅ Performance e paralelismo (forks, async)
- ✅ Error handling avançado (block/rescue/always)
- ✅ Módulos customizados

---

## ▶️ Como executar

```bash
cd modulo3-avancado

# Criar vault
ansible-vault create secrets.yml

# Rodar com vault
ansible-playbook -i inventario.ini 02-vault-uso.yml --ask-vault-pass

# Com tags
ansible-playbook site.yml --tags "instalar,configurar"
```
