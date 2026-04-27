# VPC Peering, VPN, AWS Direct Connect

## 1. Analogia do Dia a Dia
VPC Peering é como abrir uma passagem entre dois condomínios. VPN é como um túnel seguro entre sua casa e o escritório. Direct Connect é como uma linha exclusiva de fibra óptica entre sua empresa e a AWS.

## 2. O que é (definição técnica oficial AWS)
- VPC Peering: conecta duas VPCs para tráfego privado.
- VPN: conexão segura e criptografada entre rede local e AWS.
- Direct Connect: conexão física dedicada entre data center local e AWS.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: VPC Peering, VPN, Direct Connect
DOMÍNIO DO EXAME: Rede e Entrega de Conteúdo (33%)
============================================================

O QUE É:
- Peering: tráfego privado entre VPCs
- VPN: túnel seguro via internet
- Direct Connect: link dedicado, alta performance

PALAVRAS-CHAVE NA PROVA:
→ "tráfego privado entre VPCs"
→ "conexão segura VPN"
→ "link dedicado Direct Connect"

QUANDO USAR:
✅ Integração entre ambientes AWS
✅ Conexão segura com data center local

QUANDO NÃO USAR:
❌ Workloads 100% na nuvem sem integração externa
❌ Ignorar requisitos de segurança

DIFERENCIAIS:
- Direct Connect oferece menor latência e maior banda
============================================================

## 4. Questões de Fixação
1. O que faz o VPC Peering?
A) Conecta VPCs para tráfego privado (correta)
B) Cria backups
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- A) Correta: Peering conecta VPCs.
- B), C), D) não são funções do Peering.

Armadilha: confundir Peering com VPN.

2. Quando usar Direct Connect?
A) Para conexão dedicada e alta performance (correta)
B) Para workloads simples
C) Para backups
D) Para CDN

Explicação:
- A) Correta: Direct Connect é para alta performance.
- B), C), D) não são casos de uso de Direct Connect.

Armadilha: achar que VPN sempre basta.

## 5. Conceito Senior
- Direct Connect pode ser combinado com VPN para redundância.
- Peering não permite transitive routing.

## 6. Resumo para Revisão
- Peering = conecta VPCs | VPN = túnel seguro | Direct Connect = link dedicado | escolha depende de segurança e performance | sem transitive routing no Peering