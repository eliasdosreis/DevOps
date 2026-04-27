# Módulo 7 — Plugins e Customizações Avançadas

## 🎯 Objetivo deste módulo
Dominar o sistema de plugins do Vagrant, os mais importantes para uso profissional, e recursos avançados como triggers e hooks.

---

## 1. ANALOGIA DO DIA A DIA

O Vagrant base é como um smartphone saído de fábrica. Funciona bem, mas é os **plugins** que o transformam em algo poderoso:

- **vagrant-vbguest** = app que atualiza automaticamente os drivers
- **vagrant-hostsupdater** = app que gerencia seus contatos automaticamente
- **vagrant-disksize** = app que gerencia o armazenamento
- **Triggers** = alarmes e lembretes automáticos

---

## 2. O QUE É (definição técnica Senior)

O sistema de plugins do Vagrant é construído sobre **RubyGems**, permitindo que qualquer pessoa crie e distribua extensões. Plugins podem:

- Adicionar novos providers (AWS, Azure, VMware, Docker)
- Adicionar novos provisioners (Salt, Ansible Galaxy)
- Modificar o comportamento do ciclo de vida (triggers)
- Adicionar novos comandos ao CLI

**Triggers** são hooks que executam comandos antes/após eventos do Vagrant:
- `:up`, `:halt`, `:destroy`, `:provision`, `:reload`, `:ssh`

---

## 3. PLUGINS ESSENCIAIS

| Plugin | Função | Instalação |
|--------|--------|-----------|
| `vagrant-vbguest` | Sincroniza VirtualBox Guest Additions | `vagrant plugin install vagrant-vbguest` |
| `vagrant-hostsupdater` | Gerencia /etc/hosts automaticamente | `vagrant plugin install vagrant-hostsupdater` |
| `vagrant-disksize` | Redimensiona disco da VM | `vagrant plugin install vagrant-disksize` |
| `vagrant-reload` | Adiciona provisioner de reload | `vagrant plugin install vagrant-reload` |
| `vagrant-env` | Carrega variáveis de `.env` | `vagrant plugin install vagrant-env` |

---

## 4. CONCEITO SENIOR

1. **Plugins são instalados por usuário**, não por projeto. Isso causa problemas em times onde pessoas têm versões diferentes de plugins. Solução: documentar no README da versão exata (`vagrant plugin list`).

2. **`Vagrant.has_plugin?()`** — sempre verifique antes de usar um plugin. Permite que o Vagrantfile funcione mesmo sem o plugin instalado (degradação graciosa).

3. **Triggers > Provisioners para hooks de ciclo de vida** — se você precisar executar algo antes do `vagrant destroy` (ex: backup de dados), use triggers, não provisioners.

4. **Versão em equipe** — crie um script `bootstrap.sh` que instala todos os plugins necessários antes do `vagrant up`. Isso garante consistência.

---

## 5. PERGUNTAS DE ENTREVISTA

**P1: Como garantir que todos do time têm os plugins Vagrant necessários instalados?**

> **R:** Três abordagens: (1) Documentar versões exatas no README e ter um script `install-plugins.sh` que todos executam antes do primeiro `vagrant up`; (2) Usar o bloco `required_plugins` no Vagrantfile (idioma comum na comunidade) que verifica e instala se necessário; (3) Em ambientes corporativos, usar um Vagrantfile wrapper que verifica plugins e instala automaticamente com `system("vagrant plugin install ...")`. A abordagem 2 é a mais comum em projetos open source.

**P2: Qual a diferença entre usar `config.vm.provision "shell"` e um Trigger para executar algo no `vagrant up`?**

> **R:** Provisioners executam **dentro** da VM (ou controlam o que acontece na VM) e têm comportamento padrão de "apenas na primeira vez". Triggers executam **no host** (máquina local) antes ou após eventos, e sempre se repetem. Use provisioner quando precisa configurar a VM; use trigger quando precisa fazer algo no host (ex: notificar Slack, registrar em banco de dados, fazer backup, mudar configuração de firewall do host).

---

## 📂 Arquivos deste módulo

```
modulo-07-plugins/
├── README.md
├── 01-plugins-essenciais/
│   ├── Vagrantfile
│   └── install-plugins.sh
├── 02-triggers/
│   └── Vagrantfile
└── 03-disksize-env/
    ├── Vagrantfile
    └── .env.example
```
