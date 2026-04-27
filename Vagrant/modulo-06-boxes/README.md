# Módulo 6 — Boxes (Criação, Versionamento e Distribuição)

## 🎯 Objetivo deste módulo
Entender profundamente o que são Boxes, como criar boxes customizadas, usar o Vagrant Cloud e distribuir boxes para o time.

---

## 1. ANALOGIA DO DIA A DIA

Uma **Box** é como um molde de bolo (forma). Ao invés de preparar a massa do zero toda vez, você tem um molde pré-configurado. Você cria o molde uma vez e pode fazer o bolo (VM) quantas vezes quiser, sempre idêntico.

- **Box = molde** (imagem base do SO + configurações mínimas)
- **vagrant up = assar o bolo** (criar VM a partir da box)
- **Vagrant Cloud = loja de moldes** (repositório público de boxes)

---

## 2. O QUE É (definição técnica Senior)

Uma **Vagrant Box** é um pacote compactado (.box) contendo:
- Imagem do disco da VM (VMDK/VDI)
- Metadados da box (JSON com versão, provider, etc.)
- Arquivo `Vagrantfile` de configurações padrão da box
- Guest Additions do VirtualBox (ou equivalente)

**Estrutura interna de uma box:**
```
ubuntu-jammy64.box (arquivo tar.gz)
├── box.ovf          (descrição de hardware)
├── box.vmdk         (disco virtual)
├── Vagrantfile      (configurações padrão da box)
└── metadata.json    (nome, versão, provider)
```

---

## 3. ONDE FICAM AS BOXES LOCALMENTE

```
Windows: C:\Users\<user>\.vagrant.d\boxes\
Linux:   ~/.vagrant.d/boxes/
macOS:   ~/.vagrant.d/boxes/

Estrutura:
~/.vagrant.d/boxes/
└── ubuntu-VAGRANTSLASH-jammy64/
    └── 20240301.0.0/
        └── virtualbox/
            ├── box.vmdk
            ├── box.ovf
            └── metadata.json
```

---

## 4. CONCEITO SENIOR

1. **Boxes são imutáveis** — a box original nunca é modificada. O Vagrant cria uma cópia (linked clone ou full clone) para cada VM.

2. **Linked clone vs Full clone** — por padrão VirtualBox usa linked clones (referencia o disco da box, economiza espaço). Full clone é independente mas maior.

3. **Box metadata URL** — você pode hospedar um JSON de metadata que permite `vagrant box update` automático das suas boxes customizadas, mesmo sem o Vagrant Cloud.

4. **Criar boxes limpas** — ao criar uma box customizada, limpe caches, histórico, chaves temporárias. Uma box mal preparada vaza dados sensíveis.

---

## 5. PERGUNTAS DE ENTREVISTA

**P1: Como você distribuiria uma Box customizada para um time sem usar o Vagrant Cloud público?**

> **R:** Três abordagens: (1) **Servidor HTTP simples**: hospedar o arquivo `.box` em qualquer servidor web e usar `config.vm.box_url` apontando para a URL; (2) **Vagrant Cloud privado**: a HashiCorp oferece Vagrant Cloud com organizações privadas (pago); (3) **Artifactory/Nexus**: hospedar boxes como artefatos binários com versionamento, exposto via HTTP para o `box_url`. Para times corporativos, a opção 3 é mais robusta pois integra com CI/CD e tem controle de acesso.

**P2: O que deve ser feito antes de criar uma Box customizada para distribuição?**

> **R:** (1) Limpar cache do apt (`apt-get clean`); (2) remover histórico do bash (`history -c; > ~/.bash_history`); (3) remover a chave SSH insecure e deixar o Vagrant regenerar no primeiro boot; (4) remover arquivos temporários e logs; (5) compactar o disco virtual (`dd if=/dev/zero of=/EMPTY bs=1M; rm /EMPTY`) para reduzir tamanho; (6) `vagrant package --output nome-da-box.box`. Boxes mal preparadas podem ter 3-4x o tamanho necessário.

---

## 📂 Arquivos deste módulo

```
modulo-06-boxes/
├── README.md
├── 01-box-management/
│   └── comandos.md
├── 02-box-customizada/
│   ├── Vagrantfile
│   └── scripts/
│       └── prepare-box.sh
└── 03-box-metadata/
    ├── metadata.json
    └── Vagrantfile
```
