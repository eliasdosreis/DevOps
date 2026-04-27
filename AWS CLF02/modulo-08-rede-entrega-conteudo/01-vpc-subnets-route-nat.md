# Amazon VPC: subnets, route tables, internet gateway, NAT

## 1. Analogia do Dia a Dia
VPC é como um condomínio fechado: você define as ruas (subnets), portarias (gateways), regras de trânsito (route tables) e quem pode entrar ou sair (NAT, security groups).

## 2. O que é (definição técnica oficial AWS)
Amazon Virtual Private Cloud (VPC) permite criar uma rede virtual isolada na AWS, com controle total sobre endereçamento IP, sub-redes, roteamento e conectividade.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon VPC
DOMÍNIO DO EXAME: Rede e Entrega de Conteúdo (33%)
============================================================

O QUE É:
- Rede virtual isolada na AWS
- Subnets públicas e privadas
- Route tables, internet gateway, NAT gateway

PALAVRAS-CHAVE NA PROVA:
→ "rede virtual isolada"
→ "subnet pública/privada"
→ "internet gateway/NAT"

QUANDO USAR:
✅ Controle total da rede
✅ Separar recursos públicos e privados

QUANDO NÃO USAR:
❌ Workloads simples sem necessidade de isolamento
❌ Ignorar configuração de segurança

DIFERENCIAIS:
- Permite integração com VPN e Direct Connect
============================================================

## 4. Questões de Fixação
1. O que é uma subnet privada em VPC?
A) Tem acesso direto à internet
B) Não tem acesso direto à internet (correta)
C) Só pode ser usada para bancos de dados
D) É igual à subnet pública

Explicação:
- B) Correta: subnet privada não tem acesso direto.
- A), C), D) não são verdade.

Armadilha: confundir subnet pública e privada.

2. Para que serve o NAT Gateway?
A) Permitir que subnets privadas acessem a internet (correta)
B) Criar backups
C) Gerenciar usuários
D) Monitorar custos

Explicação:
- A) Correta: NAT permite saída para internet.
- B), C), D) não são funções do NAT.

Armadilha: achar que NAT permite entrada da internet.

## 5. Conceito Senior
- VPC pode ser conectada a outras redes via VPN ou Direct Connect.
- Boas práticas incluem separar subnets por função e camada.

## 6. Resumo para Revisão
- VPC = rede virtual isolada | subnets públicas/privadas | route tables | internet/NAT gateway | integração VPN/Direct Connect