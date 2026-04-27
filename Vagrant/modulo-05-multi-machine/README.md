# Módulo 5 — Multi-Machine

## 🎯 Objetivo deste módulo
Dominar a criação e gerenciamento de múltiplas VMs em um único Vagrantfile, incluindo comunicação entre VMs e estratégias de organização.

---

## 1. ANALOGIA DO DIA A DIA

Pense em um **condomínio de apartamentos** onde cada apartamento tem uma função específica:
- **Apartamento 101** (web): recebe os visitantes (requests HTTP)
- **Apartamento 102** (app): processa os pedidos (lógica de negócio)
- **Apartamento 103** (db): guarda os pertences (banco de dados)
- **Apartamento 104** (lb): o porteiro que distribui os visitantes (load balancer)

O Vagrantfile multi-machine descreve todos esses apartamentos de uma vez só.

---

## 2. O QUE É (definição técnica Senior)

O Vagrant suporta definição de múltiplas VMs em um único Vagrantfile usando blocos `config.vm.define`. Cada máquina tem sua própria configuração isolada, mas compartilha configurações globais do bloco pai.

**Hierarquia de configuração:**
```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"   # ← GLOBAL para todas as VMs

  config.vm.define "web" do |web|    # ← local para "web"
    web.vm.hostname = "web-server"
    web.vm.network "private_network", ip: "192.168.56.10"
  end

  config.vm.define "db" do |db|      # ← local para "db"
    db.vm.hostname = "db-server"
    db.vm.network "private_network", ip: "192.168.56.11"
  end
end
```

---

## 3. COMANDOS MULTI-MACHINE

```bash
# Opera em TODAS as VMs
vagrant up
vagrant halt
vagrant destroy -f

# Opera em uma VM ESPECÍFICA
vagrant up web
vagrant ssh db
vagrant halt app
vagrant provision lb

# Status de todas as VMs
vagrant status

# Detalhes globais
vagrant global-status
```

---

## 4. CONCEITO SENIOR

1. **Primary machine** — use `primary: true` para definir a VM padrão quando `vagrant ssh` é chamado sem argumento.

2. **Autostart** — `autostart: false` em VMs opcionais que não precisam subir com `vagrant up` (ex: máquinas de teste, ferramentas de debug).

3. **Comunicação entre VMs** — via private_network. As VMs precisam estar no mesmo range de IP para se enxergar.

4. **Recursos do host** — cada VM consome RAM e CPU. Com 4 VMs de 1GB RAM, você precisa de 4GB+ disponível no host. Dimensione com cuidado.

5. **Ordem de boot** — o Vagrant sobe as VMs em paralelo por padrão. Se `db` precisa estar pronta antes de `app`, use provisionamento condicional ou `triggers`.

---

## 5. PERGUNTAS DE ENTREVISTA

**P1: Como garantir que a VM do banco de dados esteja pronta antes do servidor de aplicação no Vagrant?**

> **R:** O Vagrant sobe VMs em paralelo por padrão, sem controle de dependência nativa. As soluções são: (1) usar `vagrant up db` e depois `vagrant up app` manualmente; (2) implementar health checks no provisioner da `app` que espera a DB estar acessível com retry loop; (3) usar `trigger` do Vagrant para sequenciar; (4) considerar que o provisionamento da app deve ser resiliente e capable de retry de conexão com a DB.

**P2: Qual a diferença entre configurações globais e configurações de máquina no Vagrantfile multi-machine?**

> **R:** Configurações no bloco `Vagrant.configure("2") do |config|` se aplicam a todas as VMs (herança). Configurações dentro de `config.vm.define "nome" do |vm|` se aplicam apenas àquela VM e sobrescrevem as globais para ela. A ordem de precedência: config da máquina específica > config global. Isso permite que você defina a box padrão globalmente e sobrescreva em VMs que precisam de SO diferente.

---

## 📂 Arquivos deste módulo

```
modulo-05-multi-machine/
├── README.md
├── 01-duas-vms/
│   └── Vagrantfile
├── 02-web-db/
│   ├── Vagrantfile
│   └── scripts/
│       ├── setup-web.sh
│       └── setup-db.sh
└── 03-cluster-completo/
    ├── Vagrantfile
    └── scripts/
        ├── setup-lb.sh
        ├── setup-web.sh
        ├── setup-app.sh
        └── setup-db.sh
```
