# Gerenciamento de Boxes — Referência Completa

## Comandos Essenciais

### Listar e Buscar Boxes
```bash
# Lista todas as boxes instaladas localmente
vagrant box list

# Saída esperada:
# ubuntu/jammy64   (virtualbox, 20240301.0.0)
# ubuntu/focal64   (virtualbox, 20230615.0.0)

# Buscar boxes no Vagrant Cloud (via browser)
# https://app.vagrantup.com/boxes/search
```

### Adicionar e Remover Boxes
```bash
# Adicionar box do Vagrant Cloud (sem criar VM)
vagrant box add ubuntu/jammy64

# Adicionar versão específica
vagrant box add ubuntu/jammy64 --box-version 20240301.0.0

# Adicionar box de URL direta (servidor interno)
vagrant box add minha-box-customizada \
  https://servidor.interno/boxes/ubuntu-customizado.box

# Adicionar box de arquivo local
vagrant box add minha-box /caminho/para/arquivo.box

# Remover box específica (todas as versões)
vagrant box remove ubuntu/jammy64

# Remover versão específica
vagrant box remove ubuntu/jammy64 --box-version 20230615.0.0

# Remover todas as boxes antigas (mantém apenas a mais recente de cada)
vagrant box prune
```

### Atualizar Boxes
```bash
# Verificar se há atualização (sem atualizar)
vagrant box outdated

# Verificar atualizações de todas as boxes instaladas
vagrant box outdated --global

# Atualizar box do projeto atual
vagrant box update

# Atualizar box específica
vagrant box update --box ubuntu/jammy64
```

### Criar e Exportar Boxes
```bash
# Empacotar VM atual como box (VM deve estar rodando ou parada)
vagrant package --output minha-box.box

# Empacotar com Vagrantfile incluído
vagrant package --vagrantfile Vagrantfile.box --output minha-box.box

# Empacotar VM específica (multi-machine)
vagrant package web --output web-server.box
```

---

## Localização das Boxes no Sistema

```
# Windows
C:\Users\<user>\.vagrant.d\boxes\

# Linux / macOS
~/.vagrant.d/boxes/

# Estrutura interna
~/.vagrant.d/boxes/
└── ubuntu-VAGRANTSLASH-jammy64/      ← nome da box (/ é convertido em VAGRANTSLASH)
    ├── 20240301.0.0/                  ← versão
    │   └── virtualbox/               ← provider
    │       ├── box.vmdk              ← disco virtual
    │       ├── box.ovf               ← definição de hardware
    │       └── metadata.json         ← metadados
    └── 20230615.0.0/                 ← versão anterior (prune para remover)
```

---

## Vagrant Cloud

```bash
# Login no Vagrant Cloud (para publicar boxes)
vagrant login

# Publicar box (requer conta no app.vagrantup.com)
# Interface web: https://app.vagrantup.com

# Namespacing:
# usuario/nome-da-box    → ex: hashicorp/bionic64
# organizacao/nome-da-box → ex: minha-empresa/ubuntu-base
```

---

## Dicas Senior

| Situação | Solução |
|----------|---------|
| Box muito grande | Compacte o disco antes de empacotar (veja prepare-box.sh) |
| Box sem internet | Use `box_url` apontando para servidor interno |
| Atualização controlada | Fixe `box_version` no Vagrantfile |
| Box corporativa | Publique no Artifactory/Nexus como artefato binário |
| Box desatualizada em CI | `vagrant box update` no início do pipeline |
