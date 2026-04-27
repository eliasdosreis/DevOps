# Amazon Route 53 — DNS gerenciado

## 1. Analogia do Dia a Dia
Route 53 é como uma lista telefônica moderna: você digita o nome de uma empresa (domínio) e ele te mostra o número (endereço IP) para onde ligar.

## 2. O que é (definição técnica oficial AWS)
Amazon Route 53 é um serviço gerenciado de DNS, registro de domínios e roteamento de tráfego global, com alta disponibilidade e integração com outros serviços AWS.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Route 53
DOMÍNIO DO EXAME: Rede e Entrega de Conteúdo (33%)
============================================================

O QUE É:
- DNS gerenciado e registro de domínios
- Roteamento global e health checks
- Suporte a vários tipos de roteamento (latência, geolocalização, failover)

PALAVRAS-CHAVE NA PROVA:
→ "DNS gerenciado"
→ "registro de domínio"
→ "roteamento global"

QUANDO USAR:
✅ Gerenciar domínios e DNS
✅ Roteamento inteligente de tráfego

QUANDO NÃO USAR:
❌ Workloads sem necessidade de DNS customizado
❌ Ignorar configurações de health check

DIFERENCIAIS:
- Integração com CloudFront, S3, ELB
============================================================

## 4. Questões de Fixação
1. O que faz o Amazon Route 53?
A) Gerencia bancos de dados
B) DNS gerenciado e roteamento global (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: Route 53 é DNS gerenciado.
- A), C), D) não são Route 53.

Armadilha: confundir Route 53 com ELB.

2. O que são health checks no Route 53?
A) Monitoram a saúde de recursos e roteiam tráfego (correta)
B) Criam backups
C) Gerenciam usuários
D) Monitoram custos

Explicação:
- A) Correta: health checks monitoram recursos.
- B), C), D) não são funções dos health checks.

Armadilha: achar que health check é só para EC2.

## 5. Conceito Senior
- Route 53 suporta roteamento baseado em latência, geolocalização e failover.
- Pode ser usado para balanceamento global de aplicações.

## 6. Resumo para Revisão
- Route 53 = DNS gerenciado | registro de domínios | roteamento global | health checks | integra com CloudFront/ELB/S3