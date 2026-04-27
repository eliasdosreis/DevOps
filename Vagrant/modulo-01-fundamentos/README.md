# Módulo 1 — Fundamentos do Vagrantfile

## 🎯 Objetivo deste módulo
Entender a estrutura do Vagrantfile, o que são Boxes, Providers e versões de API. Saber ler e escrever qualquer Vagrantfile com confiança.

---

## 1. ANALOGIA DO DIA A DIA

Um **Vagrantfile** é como a planta baixa de uma casa. A planta não é a casa — ela **descreve** como a casa deve ser construída. Qualquer pedreiro (provider) que receba essa planta vai construir exatamente a mesma casa.

- **Vagrantfile** = planta baixa (declaração de como deve ser)
- **Box** = o terreno com a fundação já pronta (SO pré-instalado)
- **Provider** = o pedreiro (VirtualBox, VMware, etc.)
- **Provisioner** = o decorador de interiores (Shell, Ansible, etc.)

---

## 2. O QUE É (definição técnica Senior)

O **Vagrantfile** é escrito em Ruby (DSL — Domain Specific Language) e descreve declarativamente o estado desejado de uma ou mais VMs. Ele é processado de cima para baixo pelo Vagrant runtime.

**Hierarquia de Vagrantfiles (merge order):**
```
~/.vagrant.d/Vagrantfile          (global do usuário — menor prioridade)
    ↓
/caminho/do/projeto/Vagrantfile   (do projeto — maior prioridade)
```

**Box:** imagem base compactada contendo um SO pré-instalado + configurações mínimas para o Vagrant funcionar (chave SSH, usuário vagrant, VirtualBox Guest Additions).

**Provider:** plugin que implementa a interface de criação/gerenciamento de VMs para um hypervisor específico.

---

## 3. VAGRANTFILES DESTE MÓDULO

### 01-estrutura-basica/
Estrutura mínima de um Vagrantfile funcional

### 02-box-versions/
Fixando versões de box para reprodutibilidade

### 03-provider-virtualbox/
Configurações específicas do VirtualBox

### 04-api-versions/
Entendendo o `Vagrant.configure("2")`

---

## 📂 Arquivos deste módulo

```
modulo-01-fundamentos/
├── README.md                    ← este arquivo
├── 01-estrutura-basica/
│   └── Vagrantfile
├── 02-box-versions/
│   └── Vagrantfile
├── 03-provider-virtualbox/
│   └── Vagrantfile
└── 04-api-versions/
    └── Vagrantfile
```

---

## 6. CONCEITO SENIOR

1. **O Vagrantfile é carregado como Ruby real** — você pode usar variáveis, condicionais, loops e qualquer feature da linguagem Ruby. Isso é poderoso e perigoso ao mesmo tempo.

2. **Fixe sempre a versão da box** — usar `config.vm.box_version` garante que todos do time usem exatamente a mesma imagem, evitando o clássico "funciona na minha máquina".

3. **O `Vagrant.configure("2")`** — o `"2"` não é a versão do Vagrant, é a versão da **API de configuração**. A versão `"1"` é obsoleta. Sempre use `"2"`.

4. **Boxes são cacheadas localmente** em `~/.vagrant.d/boxes`. Uma box baixada fica disponível para todos os projetos que a referenciam.

---

## 7. PERGUNTAS DE ENTREVISTA

**P1: O que acontece se dois arquivos Vagrantfile conflitam na configuração?**

> **R:** O Vagrantfile do projeto tem prioridade sobre o global do usuário (`~/.vagrant.d/Vagrantfile`). Dentro do mesmo arquivo, a última configuração definida para uma propriedade vence. O Vagrant faz um merge das configurações, não uma substituição total.

**P2: Como garantir que todos do time usem exatamente a mesma Box?**

> **R:** Usando `config.vm.box_version` para fixar a versão exata da box, e idealmente mantendo um box hash/checksum. Em ambientes corporativos, o melhor é hospedar as boxes em um servidor interno (Vagrant Cloud privado ou HTTP simples) e referenciar via `config.vm.box_url`, eliminando dependência de internet.
