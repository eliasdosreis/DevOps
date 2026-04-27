# Módulo 4 — Synced Folders (Pastas Compartilhadas)

## 🎯 Objetivo deste módulo
Dominar todos os tipos de sincronização de pastas entre host e VM: VirtualBox Shared Folders, NFS, rsync e SMB.

---

## 1. ANALOGIA DO DIA A DIA

Imagine um pen drive conectado simultaneamente ao seu computador e à VM. Você edita um arquivo no seu computador, e a VM vê as mudanças na hora. Isso é uma **synced folder**.

Na prática, você usa seu editor favorito no Windows/macOS e o código é executado dentro da VM Linux — o melhor dos dois mundos.

---

## 2. O QUE É (definição técnica Senior)

**Synced Folders** são mecanismos de compartilhamento de sistema de arquivos entre o host e a VM guest. O Vagrant suporta múltiplos backends com trade-offs diferentes:

| Tipo | Performance | Configuração | Melhor Para |
|------|-------------|--------------|-------------|
| **VirtualBox SF** | ⭐⭐ | Zero | Windows/macOS dev simples |
| **NFS** | ⭐⭐⭐⭐ | Média | Linux host, projetos grandes |
| **rsync** | ⭐⭐⭐⭐⭐ | Média | Sync unidirecional, CI/CD |
| **SMB** | ⭐⭐⭐ | Média | Windows host com SMB |

---

## 3. PASTA PADRÃO

O Vagrant **sempre** sincroniza `/vagrant` na VM com o diretório do Vagrantfile no host. Isso acontece automaticamente, sem configuração.

```bash
# Na VM:
ls /vagrant   # = conteúdo do diretório do seu Vagrantfile
```

---

## 4. CONCEITO SENIOR

1. **VirtualBox Shared Folders é lento** — para projetos com muitos arquivos (`node_modules`, por ex.), a performance cai drasticamente. Use NFS ou rsync em projetos grandes.

2. **NFS no Windows** é complicado e requer configuração extra. No Windows, prefira rsync ou SMB.

3. **rsync é unidirecional** — host → VM apenas. Mudanças na VM não chegam ao host. Use `vagrant rsync-auto` para sincronização automática em background.

4. **O diretório `/vagrant` padrão pode ser desabilitado** com `config.vm.synced_folder ".", "/vagrant", disabled: true`.

---

## 5. PERGUNTAS DE ENTREVISTA

**P1: Por que VirtualBox Shared Folders é mais lento que NFS?**

> **R:** VirtualBox Shared Folders implementa o compartilhamento via VirtualBox Guest Additions com chamadas de sistema que cruzam o limite hypervisor para cada operação de I/O. NFS usa o protocolo de rede diretamente, com caching agressivo no kernel. Para um projeto com `node_modules` (100k+ arquivos), `npm install` pode ser 10x mais lento com VirtualBox SF vs NFS.

**P2: Quando você usaria rsync em vez de NFS para synced folders?**

> **R:** rsync quando: (1) preciso de sincronização unidirecional (build artifacts que só vão para a VM), (2) host é Windows (NFS é problemático no Windows), (3) quero controle granular com `.rsync-exclude` (ignorar `node_modules`, `.git`, etc.), (4) a VM é em cloud (rsync via SSH funciona remotamente). NFS é melhor para dev bidirecional onde você edita e precisa ver mudanças imediatas.

---

## 📂 Arquivos deste módulo

```
modulo-04-synced-folders/
├── README.md
├── 01-default-folder/
│   └── Vagrantfile
├── 02-virtualbox-sf/
│   └── Vagrantfile
├── 03-nfs/
│   └── Vagrantfile
└── 04-rsync/
    ├── Vagrantfile
    └── .rsyncignore
```
