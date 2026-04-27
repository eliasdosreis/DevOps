# Módulo 11 — Conceitos Sênior: Idempotência, Roles e Boas Práticas Ansible

## 1. O CONCEITO DE IDEMPOTÊNCIA — O CORAÇÃO DO ANSIBLE

### Por que idempotência é crítica em IaC?

```bash
# ❌ SCRIPT SHELL NÃO IDEMPOTENTE (PERIGOSO):
mkdir /etc/libvirt/custom    # Erro se já existe!
useradd qemu-operator        # Erro se usuário já existe!
virsh net-define rede.xml    # Erro se rede já definida!

# ✓ ANSIBLE IDEMPOTENTE (SEGURO):
- ansible.builtin.file:
    path: /etc/libvirt/custom
    state: directory           # Cria SE não existir, não faz nada se existir
    mode: "0755"

- ansible.builtin.user:
    name: qemu-operator
    state: present             # Garante que existe — não cria duplicata

- community.libvirt.virt_net:
    name: rede-producao
    state: present             # Define SE não definida, atualiza SE changed
    xml: "{{ lookup('file', 'rede.xml') }}"
```

**A regra de ouro:** Se executar o playbook 10 vezes, o resultado deve ser  
idêntico à primeira execução. Nenhum erro, nenhum dado duplicado.

---

## 2. ESTRUTURA DE ROLE ANSIBLE PARA KVM

Uma **Role** é a unidade máxima de organização e reuso do Ansible.  
Pense nela como um "pacote" que pode ser compartilhado no Ansible Galaxy.

```
roles/
└── kvm_provision/
    ├── tasks/
    │   ├── main.yml          # Entry point — importa os outros
    │   ├── dependencies.yml  # Instalar qemu, libvirt, etc.
    │   ├── storage.yml       # Criar pools e discos
    │   ├── network.yml       # Criar redes virtuais
    │   ├── vm.yml            # Definir e iniciar VM
    │   └── cloudinit.yml     # Configurar cloud-init seed
    ├── handlers/
    │   └── main.yml          # Restart libvirtd, reload firewall, etc.
    ├── defaults/
    │   └── main.yml          # Valores padrão editáveis pelo usuário
    ├── vars/
    │   └── main.yml          # Variáveis internas (não editáveis)
    ├── templates/
    │   ├── vm-domain.xml.j2  # Template Jinja2 do XML da VM
    │   └── user-data.yaml.j2 # Template cloud-init
    ├── files/
    │   └── network-isolated.xml  # XML estático da rede
    └── meta/
        └── main.yml          # Metadata: dependências de outras roles
```

---

## 3. TEMPLATES JINJA2 — XMLS DINÂMICOS

A força do Ansible: gerar XMLs de VM dinamicamente baseados em variáveis.

```xml
{# templates/vm-domain.xml.j2 #}
<domain type='kvm'>
  <name>{{ vm_name }}</name>
  <uuid>{{ 999999 | random | to_uuid }}</uuid>
  <memory unit='MiB'>{{ vm_memory_mb }}</memory>
  <vcpu placement='{{ 'static' if vm_cpu_pinning else 'auto' }}'>{{ vm_vcpus }}</vcpu>

  {% if vm_cpu_pinning %}
  {# NUMA/Pinning apenas para VMs de alta performance #}
  <cputune>
    {% for i in range(vm_vcpus) %}
    <vcpupin vcpu='{{ i }}' cpuset='{{ vm_cpu_pinning_start + i }}'/>
    {% endfor %}
  </cputune>
  {% endif %}

  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    {% if vm_uefi %}
    <loader readonly='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.fd</loader>
    {% endif %}
  </os>

  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='{{ vm_disk_cache | default("writethrough") }}'/>
      <source file='{{ vm_disk_path }}'/>
      <target dev='vda' bus='virtio'/>
    </disk>

    <interface type='network'>
      <source network='{{ vm_network }}'/>
      <model type='virtio'/>
      {% if vm_vhost_queues is defined %}
      <driver name='vhost' queues='{{ vm_vhost_queues }}'/>
      {% endif %}
    </interface>
  </devices>
</domain>
```

---

## 4. INVENTORY DINÂMICO — DESCOBRINDO HOSTS AUTOMATICAMENTE

```ini
# inventory/hosts.ini — Inventário estático básico
[hypervisors]
kvm-node-a ansible_host=10.0.1.10 ansible_user=root
kvm-node-b ansible_host=10.0.1.11 ansible_user=root

[hypervisors:vars]
ansible_ssh_private_key_file=~/.ssh/kvm_rsa
ansible_python_interpreter=/usr/bin/python3
```

```python
# inventory/libvirt_inventory.py — Inventário DINÂMICO das VMs
# Gera automaticamente um inventory com todas as VMs rodando!
# ansible-inventory -i inventory/libvirt_inventory.py --list

import libvirt
import json

conn = libvirt.open("qemu:///system")
domains = conn.listAllDomains()

inventory = {"_meta": {"hostvars": {}}, "vms": {"hosts": []}}

for dom in domains:
    if dom.isActive():
        inventory["vms"]["hosts"].append(dom.name())
        inventory["_meta"]["hostvars"][dom.name()] = {
            "vm_state": "running",
            "vm_memory": dom.maxMemory() // 1024,  # MB
            "vm_vcpus": dom.maxVcpus(),
        }

print(json.dumps(inventory, indent=2))
```

---

## 5. HANDLERS — AÇÕES REATIVAS E EFICIENTES

```yaml
# handlers/main.yml
---
- name: "restart libvirtd"
  ansible.builtin.service:
    name: libvirtd
    state: restarted
  # Handlers só executam UMA VEZ ao final do play, mesmo se notificados 10x!
  # Evita o anti-pattern de reiniciar o serviço a cada task

- name: "reload firewall rules"
  ansible.builtin.command: firewall-cmd --reload

- name: "reload apparmor"
  ansible.builtin.service:
    name: apparmor
    state: reloaded
```

```yaml
# tasks/main.yml — Notificando handlers
- name: "Modificar configuração do QEMU"
  ansible.builtin.template:
    src: qemu.conf.j2
    dest: /etc/libvirt/qemu.conf
    mode: "0600"
  notify: "restart libvirtd"    # Handler só roda se ESTA task mudou algo!

- name: "Modificar outra configuração"
  ansible.builtin.template:
    src: libvirtd.conf.j2
    dest: /etc/libvirt/libvirtd.conf
  notify: "restart libvirtd"    # Mesmo handler — executará apenas UMA vez!
```

---

## 6. BOAS PRÁTICAS SÊNIOR

| Prática                              | Por quê                                              |
|--------------------------------------|------------------------------------------------------|
| Usar `state: present/absent`         | Força idempotência — não `command: mkdir`            |
| `changed_when: false` em queries     | Não marca "changed" em tasks de leitura              |
| `failed_when` explícito             | Controla o que é realmente um erro                   |
| Vault para senhas e chaves SSH       | `ansible-vault encrypt_string 'senha'`               |
| Tags nas tasks (`tags: [vm, prod]`) | Executar subset: `ansible-playbook -t vm`             |
| `check_mode: true` antes de aplicar | Dry-run sem mudanças: `ansible-playbook --check`     |
| Molecule para testar roles           | Testes unitários de roles com containers/VMs         |

---

## 7. PERGUNTA DE ENTREVISTA (Nível Sênior)

**Pergunta:** "Seu time tem um Ansible Playbook que provisiona VMs KVM.  
O playbook roda bem na primeira execução, mas ao re-executar numa VM existente  
ele falha na task de `virt-install` com 'domain already defined'.  
Como você corrigiria para garantir idempotência real?"

**Resposta esperada:**  
"O problema clássico é usar `ansible.builtin.command: virt-install ...`  
que não tem estado — ele sempre tenta executar, independente da VM existir.

A solução em camadas seria:
1. **Usar o módulo nativo** `community.libvirt.virt` com `command: define`  
   e `xml:` — ele é idempotente por design (compara o XML atual com o desejado)

2. **Adicionar verificação de existência** com `from_xml` antes e condicional:
```yaml
- community.libvirt.virt:
    command: list_vms
  register: vm_list

- ansible.builtin.command: virt-install ...
  when: vm_name not in vm_list.list_vms
```

3. **Para VMs com parâmetros que mudam** (ex: memória atualizada):
   Usar `virsh setmem` via módulo command com `changed_when` baseado  
   em diferença entre memória atual e desejada — não recriar a VM.

4. **Testar com `--check` (dry-run)** antes de qualquer execução em produção.

O princípio sênior: qualquer automação que não possa ser re-executada  
com segurança não é automação — é um script com timing."
