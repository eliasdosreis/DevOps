# Módulo 2 — Rede no Vagrant

## 🎯 Objetivo deste módulo
Dominar todos os tipos de configuração de rede do Vagrant: Forwarded Ports, Private Network, Public Network, hostnames e DNS.

---

## 1. ANALOGIA DO DIA A DIA

Imagine um **condomínio fechado** (sua rede de desenvolvimento):

- **Forwarded Port** = A portaria encaminha visitantes externos para apartamentos específicos. "Quem vier na porta 8080 de fora, mande para o apartamento 80 lá dentro."

- **Private Network** = A rede interna do condomínio. Os moradores (VMs) se falam livremente entre si, mas pessoas de fora não entram diretamente.

- **Public Network** = Tirar a cerca do condomínio. A VM aparece diretamente na sua rede física, como se fosse um computador real conectado ao mesmo switch.

---

## 2. O QUE É (definição técnica Senior)

O Vagrant oferece três modelos de rede, cada um com trade-offs de segurança, performance e acessibilidade:

| Tipo | Acesso Externo | IP Fixo | Dificuldade | Uso Típico |
|------|---------------|---------|-------------|------------|
| **Forwarded Port** | Via porta do host | Não | Fácil | Dev local simples |
| **Private Network** | Não (somente host) | Sim | Médio | Multi-VM, APIs internas |
| **Public Network** | Sim (rede física) | Opcional | Médio | Testes de rede real |

**NAT (padrão):** O VirtualBox sempre adiciona um adaptador NAT. Permite que a VM acesse a internet, mas não é acessível externamente. O SSH do Vagrant usa este adaptador (porta 2222 do host → 22 da VM).

---

## 3. CONCEITO SENIOR

1. **Nunca remova o adaptador NAT** — o Vagrant precisa dele para o SSH funcionar. Se usar `--no-natdnshostresolver1` ou remover o adaptador 1, você quebra o `vagrant ssh`.

2. **Portas abaixo de 1024 no host** exigem root/admin no Linux/macOS. Prefira portas acima de 1024 (ex: 8080, 8443).

3. **Private Network com IP fixo** é a base de qualquer ambiente multi-VM. Defina um range específico (ex: 192.168.56.0/24 é o padrão do VirtualBox host-only).

4. **Public Network é perigoso** em redes corporativas/públicas — a VM fica exposta na rede física com todos os serviços que rodar.

---

## 4. PERGUNTAS DE ENTREVISTA

**P1: Por que `vagrant ssh` usa a porta 2222 do localhost?**

> **R:** O Vagrant configura automaticamente um Forwarded Port do tipo NAT (adapter 1) que mapeia `host:2222 → guest:22`. Isso permite o SSH sem configuração de rede manual. Se tiver múltiplas VMs, o Vagrant detecta colisões e auto-negocia portas alternativas (2200, 2201...).

**P2: Qual a diferença entre `private_network` e `public_network` em termos de segurança?**

> **R:** `private_network` cria uma rede host-only: apenas o host e as VMs nessa rede se comunicam. Nenhum dispositivo externo tem acesso. `public_network` faz a VM participar da rede física via bridge, ficando visível para todos os dispositivos na rede. Em ambientes de produção ou redes corporativas, `public_network` representa risco de segurança significativo pois expõe a VM a toda a rede local.

---

## 📂 Arquivos deste módulo

```
modulo-02-rede/
├── README.md                    ← este arquivo
├── 01-forwarded-ports/
│   └── Vagrantfile
├── 02-private-network/
│   └── Vagrantfile
├── 03-public-network/
│   └── Vagrantfile
└── 04-hostname-dns/
    └── Vagrantfile
```
