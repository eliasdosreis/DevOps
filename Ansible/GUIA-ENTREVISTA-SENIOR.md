# 🎯 Guia de Entrevista Técnica Sênior - Ansible
## Por Alex DevOps Coach

---

## 🧒 Como usar este guia

> Leia cada pergunta, tente responder sozinho PRIMEIRO.
> Depois confira a resposta ideal.
> Repita até conseguir explicar para uma criança de 10 anos!

---

## 🔴 Perguntas Nível Sênior (as mais cobradas)

---

### 1. O que é idempotência e por que é fundamental no Ansible?

**Resposta ideal:**
> Idempotência significa que você pode rodar o mesmo playbook
> **N vezes** e o resultado é sempre o mesmo — sem efeitos colaterais.
>
> Exemplo: `state: present` numa task de instalar pacote.
> Se o pacote já existe, o Ansible **não reinstala**. Se não existe, instala.
> Rodar 1 vez ou 100 vezes = mesmo resultado final.
>
> **Por que importa?** Porque em produção, playbooks rodam frequentemente.
> Um playbook não-idempotente causaria danos acumulativos.

**Como demonstrar no código:**
```yaml
# ✅ IDEMPOTENTE - pode rodar N vezes
- name: "Criar pasta"
  file:
    path: /opt/app
    state: directory   # Se já existe, não faz nada!

# ❌ NÃO idempotente - acumula dados
- name: "Append em arquivo"
  shell: echo "nova linha" >> /etc/config.txt  # Adiciona toda vez!
```

---

### 2. Qual a diferença entre `import_tasks` e `include_tasks`?

**Resposta ideal:**
| | `import_tasks` | `include_tasks` |
|---|---|---|
| Quando carrega | **Estático** (na compilação) | **Dinâmico** (em tempo de execução) |
| Suporte a `when` no import | Aplica em TODAS as tasks | Só aplica na inclusão |
| Suporte a loops | ❌ Não | ✅ Sim |
| Tags funcionam dentro | ✅ Sim | ⚠️ Parcialmente |
| Uso ideal | Estrutura fixa | Inclusão condicional/loop |

**Regra sênior:** Use `import_tasks` por padrão. Só use `include_tasks` quando precisar de dinâmica (loop ou condição no include).

---

### 3. Explique a ordem de precedência de variáveis (da menor para maior prioridade)

**Resposta ideal (simplificada):**
```
1. role defaults        ← menor prioridade (plano Z)
2. inventory vars
3. group_vars/all
4. group_vars/[grupo]
5. host_vars/[host]
6. play vars
7. role vars
8. task vars (set_fact)
9. extra vars (-e)      ← MAIOR prioridade (sempre ganha!)
```

**Dica de entrevista:** "Em caso de conflito, `-e` na linha de comando sempre vence. Por isso é perfeito para sobrescrever valores em CI/CD sem mudar o código."

---

### 4. Como você faria um deploy zero-downtime com Ansible?

**Resposta ideal:**
```yaml
- hosts: webservers
  serial: 1           # Um servidor de cada vez!

  pre_tasks:
    - name: Remover do load balancer
      uri:
        url: "http://lb/remove/{{ inventory_hostname }}"
        method: POST

  roles:
    - app             # Deploy na app

  post_tasks:
    - name: Verificar saúde da aplicação
      uri:
        url: "http://{{ inventory_hostname }}/health"
        status_code: 200

    - name: Readicionar ao load balancer
      uri:
        url: "http://lb/add/{{ inventory_hostname }}"
        method: POST
```

**Conceitos demonstrados:** `serial`, `pre_tasks`, `post_tasks`, health check, LB integration.

---

### 5. O que é Ansible Vault e quando usar?

**Resposta ideal:**
> Vault criptografa dados sensíveis com AES-256.
> Use para: senhas, tokens, chaves SSH, API keys, certificados.
>
> **Boas práticas sênior:**
> - Prefixo `vault_` nas variáveis secretas
> - Arquivo separado `secrets.yml` criptografado
> - Versionar o arquivo criptografado no Git é **seguro e recomendado**
> - Em CI/CD, usar `--vault-password-file` com arquivo protegido
> - Nunca expor variáveis vault com `debug`

---

### 6. Qual a diferença entre Role e Collection?

**Resposta ideal:**
| | Role | Collection |
|---|---|---|
| O que é | Organização de tasks/handlers/templates | Pacote de roles + módulos + plugins |
| Escopo | Uma funcionalidade (ex: instalar nginx) | Domínio completo (ex: amazon.aws) |
| Distribuição | Ansible Galaxy | Ansible Galaxy ou Automation Hub |
| Exemplo | `geerlingguy.nginx` | `community.postgresql` |

---

### 7. Como você testa playbooks Ansible? (Pergunta que separa sênior de pleno)

**Resposta ideal:**
```bash
# 1. Syntax check (validação básica)
ansible-playbook site.yml --syntax-check

# 2. Dry-run (simula sem executar)
ansible-playbook site.yml --check

# 3. Molecule (testes com containers/VMs reais)
molecule test

# 4. ansible-lint (boas práticas e code style)
ansible-lint site.yml

# 5. Testinfra/Goss (verificar estado final do servidor)
# Após deploy, verificar se nginx está rodando, porta aberta, etc.
```

---

### 8. O que é `become` e quando NÃO usá-lo?

**Resposta ideal:**
> `become: true` executa como outro usuário (geralmente root via sudo).
>
> **NÃO use** quando:
> - A task não precisa de privilégios (maioria das tasks de leitura)
> - Usar em `gather_facts` pode ser desnecessário
> - Tasks com `delegate_to: localhost` normalmente não precisam
>
> **Melhor prática:** Defina `become: true` **por task**, não no play inteiro.
> Princípio do menor privilégio!

---

## 💼 Projetos para colocar no Portfolio

1. **Este projeto** - Deploy completo multi-role com vault
2. Pipeline CI/CD com Ansible (GitLab CI ou GitHub Actions)
3. Dynamic inventory para AWS/GCP com boto3
4. Ansible + Terraform juntos (infra + configuração)
5. Molecule + Testinfra para testes automatizados de roles

---

## 🚀 Checklist Sênior Final

- [ ] Consigo explicar idempotência com exemplo prático
- [ ] Sei a diferença import_tasks vs include_tasks
- [ ] Conheço precedência de variáveis
- [ ] Implementei vault em pelo menos 1 projeto
- [ ] Criei pelo menos 1 role do zero
- [ ] Fiz deploy zero-downtime com `serial`
- [ ] Usei block/rescue/always para error handling
- [ ] Testei playbooks com `--check` e `ansible-lint`
- [ ] Criei inventário dinâmico (ou sei explicar como funciona)
- [ ] Tenho projeto no GitHub para mostrar na entrevista ✅ (este aqui!)
