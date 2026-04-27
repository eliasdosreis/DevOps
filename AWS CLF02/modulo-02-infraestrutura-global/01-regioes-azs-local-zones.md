# Regiões (Regions), Zonas de Disponibilidade (AZs), Local Zones

## 1. Analogia do Dia a Dia
Pense em uma rede de hotéis:
- Região: cada cidade onde há hotéis
- Zona de Disponibilidade: diferentes prédios/hotéis na mesma cidade
- Local Zone: um hotel menor em um bairro específico para atender clientes locais

## 2. O que é (definição técnica oficial AWS)
- Região: área geográfica com múltiplos datacenters isolados
- Zona de Disponibilidade (AZ): um ou mais datacenters dentro de uma região, isolados de falhas
- Local Zone: extensão da região, próxima de grandes centros urbanos, para latência ultra baixa

## 3. Ficha de Estudo Comentada
============================================================
TEMA: Infraestrutura Global AWS
DOMÍNIO DO EXAME: Infraestrutura Global (Domínio 1 + 3)
============================================================

O QUE É:
- Região: conjunto de AZs
- AZ: datacenters isolados
- Local Zone: extensão local da região

PALAVRAS-CHAVE NA PROVA:
→ "alta disponibilidade"
→ "redundância"
→ "latência baixa"

QUANDO USAR:
✅ Para alta disponibilidade
✅ Reduzir latência
✅ Atender requisitos de compliance

QUANDO NÃO USAR:
❌ Ignorar redundância
❌ Escolher região só pelo preço

DIFERENCIAIS:
- Serviços podem não estar em todas as regiões
============================================================

## 4. Questões de Fixação
1. O que é uma Zona de Disponibilidade (AZ)?
A) Região inteira
B) Datacenter isolado dentro de uma região (correta)
C) Extensão local da região
D) Serviço de rede

Explicação:
- B) Correta: AZ é datacenter isolado.
- A), C), D) não são AZ.

Armadilha: confundir AZ com região.

2. Para que servem as Local Zones?
A) Reduzir latência em áreas urbanas (correta)
B) Backup de dados
C) Gerenciar contas
D) Monitorar custos

Explicação:
- A) Correta: Local Zone é para latência baixa.
- B), C), D) não são funções de Local Zone.

Armadilha: achar que Local Zone é igual a AZ.

## 5. Conceito Senior
- Escolher a região certa impacta preço, latência e compliance.
- Nem todos os serviços estão disponíveis em todas as regiões.

## 6. Resumo para Revisão
- Região = área geográfica | AZ = datacenter isolado | Local Zone = extensão local | escolha afeta latência, preço e compliance