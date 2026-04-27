# 🚀 Curso Completo de Vagrant — Do Zero ao Senior

> Aprenda Vagrant de forma prática, incremental e profunda, com foco em entrevistas técnicas de nível Senior.

---

## 📁 Estrutura do Curso

```
Vagrant/
├── modulo-00-preparacao/          → Instalação e primeiro contato
├── modulo-01-fundamentos/         → Vagrantfile, Boxes, Providers
├── modulo-02-rede/                → Forwarded Ports, Private/Public Network
├── modulo-03-provisionamento/     → Shell, File, Ansible, Chef, Puppet
├── modulo-04-synced-folders/      → Pastas compartilhadas host ↔ VM
├── modulo-05-multi-machine/       → Múltiplas VMs no mesmo Vagrantfile
├── modulo-06-boxes/               → Criação, versionamento e distribuição
├── modulo-07-plugins/             → Plugins essenciais e customizações
└── modulo-08-projeto-final/       → Ambiente Senior completo com Ansible
```

---

## 🎯 O que você vai dominar

| Habilidade | Nível |
|---|---|
| Criar VMs reproduzíveis | ✅ Básico → Senior |
| Configurar redes complexas | ✅ Básico → Senior |
| Provisionamento automatizado | ✅ Básico → Senior |
| Multi-machine environments | ✅ Senior |
| Box customization | ✅ Senior |
| Ansible + Vagrant integration | ✅ Senior |
| Troubleshooting avançado | ✅ Senior |

---

## 🧠 Regra de Ouro

**Um conceito por pasta. Um propósito por Vagrantfile.**

Nunca misture conceitos novos no mesmo arquivo.
Aprenda devagar, entenda profundamente, avance com segurança.

---

## ⚡ Pré-requisitos

- Windows 10/11 ou Linux
- VirtualBox 7.x instalado
- Vagrant 2.4.x instalado
- 8 GB RAM mínimo (16 GB recomendado)
- 50 GB de espaço em disco livre

---

## 📚 Como estudar este curso

1. Siga os módulos em ordem sequencial
2. Leia o `README.md` de cada módulo antes de qualquer coisa
3. Execute cada Vagrantfile na ordem numerada
4. Responda as perguntas de entrevista de cabeça ANTES de ver a resposta
5. Não avance enquanto não entender completamente o módulo atual

---

## 🛠️ Comandos Essenciais (referência rápida)

```bash
vagrant up          # Sobe a VM (cria se não existir)
vagrant halt        # Desliga a VM (mantém estado)
vagrant destroy -f  # Remove a VM permanentemente
vagrant ssh         # Acessa a VM via SSH
vagrant status      # Mostra estado das VMs
vagrant reload      # Reinicia e reaplica configuração
vagrant provision   # Executa provisioners sem reiniciar
vagrant box list    # Lista boxes instalados localmente
```

---

*Curso criado para estudo progressivo do Vagrant — Zero ao Senior.*
