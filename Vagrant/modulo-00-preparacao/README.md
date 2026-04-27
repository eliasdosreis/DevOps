# Módulo 0 — Preparação do Ambiente

## 🎯 Objetivo deste módulo
Instalar todas as ferramentas necessárias, entender o que o Vagrant faz, e subir sua primeira VM com sucesso.

---

## 1. ANALOGIA DO DIA A DIA

Imagine que você vai montar um computador novo toda vez que precisar testar algo — comprar peças, instalar o sistema, configurar tudo do zero. Demora horas.

O **Vagrant** é como ter uma "receita de bolo" mágica: você descreve o computador que quer em um arquivo de texto simples, e ele cria, configura e entrega pronto para uso em minutos. Se estragar, joga fora e recria do zero com o mesmo resultado.

---

## 2. O QUE É (definição técnica Senior)

**Vagrant** é uma ferramenta de IaC (Infrastructure as Code) criada pela HashiCorp que automatiza o ciclo de vida de máquinas virtuais através de um arquivo declarativo chamado `Vagrantfile`.

Ele abstrai o provider subjacente (VirtualBox, VMware, Hyper-V, AWS, etc.) e fornece uma interface unificada para criar, provisionar, compartilhar e destruir ambientes de desenvolvimento reproduzíveis.

**Stack de tecnologias envolvidas:**
```
Vagrant (orquestrador)
    └── Provider (VirtualBox, VMware, etc.) → cria a VM
    └── Box (imagem base do SO)
    └── Provisioner (Shell, Ansible, Chef) → configura o SO
```

---

## 3. INSTALAÇÃO PASSO A PASSO

### 3.1 VirtualBox

1. Acesse: https://www.virtualbox.org/wiki/Downloads
2. Baixe a versão para seu SO (Windows/Linux/macOS)
3. Instale com as opções padrão

**Verificação:**
```bash
VBoxManage --version
# Saída esperada: 7.x.x
```

### 3.2 Vagrant

1. Acesse: https://developer.hashicorp.com/vagrant/downloads
2. Baixe o instalador para seu SO
3. Instale e reinicie o terminal

**Verificação:**
```bash
vagrant --version
# Saída esperada: Vagrant 2.4.x
```

### 3.3 Plugins Essenciais (instale após o Vagrant)

```bash
# Mantém as Guest Additions do VirtualBox sincronizadas com a versão instalada
vagrant plugin install vagrant-vbguest

# Atualiza automaticamente o /etc/hosts do host com os hostnames das VMs
vagrant plugin install vagrant-hostsupdater

# Verificar plugins instalados
vagrant plugin list
```

---

## 4. CICLO DE VIDA DE UMA VM VAGRANT

```
vagrant up
    │
    ├── Box existe localmente? ──NÃO──► Baixa do Vagrant Cloud
    │                                         │
    │   SIM ◄────────────────────────────────┘
    │
    ├── VM existe? ──NÃO──► Cria a VM no VirtualBox
    │
    ├── Executa provisioners (shell, ansible, etc.)
    │
    └── VM está pronta! ✅

vagrant halt     → Desliga (como pressionar o botão power)
vagrant suspend  → Suspende (salva estado na RAM)
vagrant resume   → Retoma do suspend
vagrant reload   → halt + up (reaplica Vagrantfile)
vagrant destroy  → Remove a VM permanentemente
```

---

## 5. VERIFICAÇÃO E TROUBLESHOOTING

### Problemas comuns na instalação:

| Erro | Causa | Solução |
|------|-------|---------|
| `VT-x is disabled` | Virtualização desabilitada na BIOS | Habilite VT-x/AMD-V na BIOS |
| `Vagrant command not found` | Variável PATH não atualizada | Reinicie o terminal ou adicione ao PATH |
| `No usable default provider found` | VirtualBox não instalado | Instale o VirtualBox primeiro |
| `SSL certificate problem` | Proxy corporativo | Configure `VAGRANT_INSECURE` ou o proxy |

---

## 6. CONCEITO SENIOR

**O que um Senior sabe que um Junior não sabe:**

1. **Vagrant não é um hypervisor** — ele é apenas um wrapper. O VirtualBox é quem cria a VM de verdade. Vagrant só orquestra.

2. **Boxes são imagens imutáveis** — quando você executa `vagrant up`, o Vagrant **não modifica** a box original. Ele cria uma cópia. A box original fica intacta para reutilização.

3. **O diretório `.vagrant/`** contém o estado local da VM (ID do VirtualBox, chaves SSH, etc.). Nunca commite esse diretório no Git. Sempre adicione ao `.gitignore`.

4. **Ambientes efêmeros** — a filosofia central do Vagrant é: VMs são descartáveis. Se quebrou, `vagrant destroy && vagrant up`. Isso é IaC na prática.

5. **SSH automático** — o Vagrant configura automaticamente uma chave SSH insegura (propositalmente) para acesso de desenvolvimento. Nunca use em produção.

---

## 7. PERGUNTAS DE ENTREVISTA

**P1: Qual a diferença entre `vagrant halt` e `vagrant suspend`?**

> **R:** `vagrant halt` desliga a VM completamente (equivale a desligar o computador). Os dados no disco são preservados, mas a RAM é liberada. `vagrant suspend` salva o estado atual da RAM em disco (como "hibernar") e pausa a VM. O resume é mais rápido, mas consome espaço em disco. Em ambientes de CI/CD, sempre use `vagrant halt` ou `vagrant destroy`.

**P2: Por que o Vagrant usa uma chave SSH "insegure" por padrão?**

> **R:** O Vagrant gera um par de chaves SSH conhecido (insecure keypair) que é idêntico em todas as instalações para facilitar o desenvolvimento. O par real é substituído automaticamente no primeiro boot por um par único gerado on-the-fly. Isso garante segurança sem exigir configuração manual, mantendo a reprodutibilidade do ambiente.

---

## 📂 Arquivos deste módulo

- `README.md` — este arquivo
- `01-primeira-vm/Vagrantfile` — sua primeira VM funcional
