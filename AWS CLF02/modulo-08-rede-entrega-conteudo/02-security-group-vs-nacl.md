# Security Groups vs NACLs (pegadinha clássica)

## 1. Analogia do Dia a Dia
Security Group é como um porteiro que só deixa entrar quem está na lista. NACL é como uma cancela automática na entrada do condomínio, com regras para todos que passam.

## 2. O que é (definição técnica oficial AWS)
- Security Group: firewall de instância, controla tráfego de entrada/saída a nível de recurso.
- NACL (Network ACL): firewall de subnet, controla tráfego de entrada/saída a nível de rede, com regras explícitas de permitir e negar.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Security Groups vs NACLs
DOMÍNIO DO EXAME: Rede e Entrega de Conteúdo (33%)
============================================================

O QUE É:
- Security Group: firewall stateful, nível de instância
- NACL: firewall stateless, nível de subnet

PALAVRAS-CHAVE NA PROVA:
→ "stateful vs stateless"
→ "firewall de instância/subnet"
→ "permitir/nega tráfego"

QUANDO USAR:
✅ Security Group: controle fino por recurso
✅ NACL: regras gerais por subnet

QUANDO NÃO USAR:
❌ Usar só NACL para segurança fina
❌ Ignorar ordem das regras em NACL

DIFERENCIAIS:
- Security Group só permite, NACL permite e nega
============================================================

## 4. Questões de Fixação
1. O que caracteriza um Security Group?
A) Stateless
B) Stateful (correta)
C) Nível de subnet
D) Só nega tráfego

Explicação:
- B) Correta: Security Group é stateful.
- A), C), D) não são verdade.

Armadilha: confundir stateful/stateless.

2. O que caracteriza um NACL?
A) Stateful
B) Stateless (correta)
C) Nível de instância
D) Só permite tráfego

Explicação:
- B) Correta: NACL é stateless.
- A), C), D) não são verdade.

Armadilha: confundir NACL com Security Group.

## 5. Conceito Senior
- NACLs são úteis para bloquear ranges inteiros de IP.
- Security Groups são mais usados no dia a dia.

## 6. Resumo para Revisão
- Security Group = firewall stateful | NACL = stateless | SG = nível instância | NACL = nível subnet | SG só permite, NACL permite/nega