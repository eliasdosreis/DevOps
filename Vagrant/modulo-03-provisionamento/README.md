# Módulo 3 — Provisionamento

## 🎯 Objetivo deste módulo
Dominar todos os tipos de provisionamento do Vagrant: Shell inline, Shell script externo, File provisioner, e integração com Ansible, Chef e Puppet.

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você acabou de se mudar para um apartamento novo (a VM está criada). O provisionamento é o trabalho de *mobiliar e decorar* o apartamento:

- **Shell inline** = você mesmo faz as tarefas rapidamente, passando instruções verbalmente enquanto a mudança acontece
- **Shell script externo** = você tem um checklist escrito detalhado que o profissional segue
- **File provisioner** = você traz seus próprios móveis (arquivos de configuração) de casa
- **Ansible** = você contrata uma empresa especializada que tem um manual profissional para montar qualquer apartamento de forma idempotente

---

## 2. O QUE É (definição técnica Senior)

**Provisionamento** é o processo de configurar automaticamente o software e o estado de uma VM após sua criação. O Vagrant executa os provisioners na ordem em que são declarados no Vagrantfile.

**Tipos de provisioners:**

| Provisioner | Linguagem | Idempotente | Uso Típico |
|------------|-----------|-------------|------------|
| `shell` | Bash/Shell | Manual | Scripts simples, bootstrapping |
| `file` | — | Não | Copiar configs, certs, arquivos |
| `ansible` | YAML | ✅ Nativo | Ambientes complexos, produção |
| `chef_solo` | Ruby DSL | ✅ Nativo | Empresas com Chef existente |
| `puppet` | Puppet DSL | ✅ Nativo | Empresas com Puppet existente |

---

## 3. ORDEM DE EXECUÇÃO DOS PROVISIONERS

```
vagrant up (primeira vez)
    └── Cria VM
    └── Configura rede
    └── Executa provisioners EM ORDEM (de cima para baixo)
        1. file provisioner
        2. shell provisioner
        3. ansible provisioner

vagrant provision (reexecuta SEM recriar a VM)
    └── Executa todos os provisioners novamente

vagrant reload --provision (reinicia E reexecuta provisions)
```

---

## 4. CONCEITO SENIOR

1. **Idempotência é obrigatória** — um provisioner deve poder ser executado 10 vezes e sempre produzir o mesmo resultado. `vagrant provision` é usado em CD pipelines. Se o seu script `apt-get install nginx` falha na segunda execução, você tem um problema.

2. **Shell provisioner não é escalável** — para 1-2 softwares, shell está ótimo. Para 10+ configurações complexas, use Ansible. A linha de corte prática: se seu script tem mais de 50 linhas, considere Ansible.

3. **Ordem importa** — File provisioner ANTES do Shell que processa os arquivos copiados.

4. **`run: "always"` vs padrão** — por padrão, provisioners rodam apenas uma vez (na criação). Com `run: "always"`, rodam em todo `vagrant up`.

---

## 5. PERGUNTAS DE ENTREVISTA

**P1: O que é idempotência e por que ela é crítica em provisioners?**

> **R:** Idempotência significa que executar uma operação N vezes produz o mesmo resultado que executar uma vez. É crítica porque `vagrant provision` pode ser chamado múltiplas vezes (em CI/CD, ao adicionar novas configs, etc.). Provisioners shell não-idempotentes podem falhar ou criar estado inconsistente. Ferramentas como Ansible são idempotentes por design — verificam o estado atual antes de fazer mudanças.

**P2: Quando você usaria Ansible em vez de Shell para provisionamento Vagrant?**

> **R:** Uso Ansible quando: (1) a configuração é complexa (múltiplos serviços, usuários, permissões); (2) o mesmo playbook será usado no Vagrant E em produção (reutilização); (3) preciso de idempotência garantida; (4) trabalho em time (YAML é mais legível que script shell longo). Shell é melhor para bootstrapping simples, PoCs rápidos ou quando Ansible não está disponível no host.

---

## 📂 Arquivos deste módulo

```
modulo-03-provisionamento/
├── README.md
├── 01-shell-inline/
│   └── Vagrantfile
├── 02-shell-script/
│   ├── Vagrantfile
│   └── scripts/
│       ├── install.sh
│       └── configure.sh
├── 03-file-provisioner/
│   ├── Vagrantfile
│   └── files/
│       ├── nginx.conf
│       └── app.html
├── 04-ansible/
│   ├── Vagrantfile
│   └── playbook.yml
└── 05-multiplos-provisioners/
    ├── Vagrantfile
    └── scripts/
        └── bootstrap.sh
```
