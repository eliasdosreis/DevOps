# AWS Global Accelerator

## 1. Analogia do Dia a Dia
Global Accelerator é como um pedágio expresso: ele encontra o caminho mais rápido e menos congestionado para você chegar ao destino, desviando de engarrafamentos na internet.

## 2. O que é (definição técnica oficial AWS)
AWS Global Accelerator é um serviço que otimiza o tráfego global de aplicações, usando a rede da AWS para reduzir latência e melhorar a disponibilidade, roteando usuários para a região mais próxima e saudável.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Global Accelerator
DOMÍNIO DO EXAME: Rede e Entrega de Conteúdo (33%)
============================================================

O QUE É:
- Otimização de tráfego global
- Redução de latência e failover automático
- Usa rede global da AWS

PALAVRAS-CHAVE NA PROVA:
→ "otimização de tráfego global"
→ "redução de latência"
→ "failover automático"

QUANDO USAR:
✅ Aplicações globais com usuários em várias regiões
✅ Necessidade de alta disponibilidade

QUANDO NÃO USAR:
❌ Workloads locais sem usuários globais
❌ Ignorar requisitos de performance

DIFERENCIAIS:
- Failover instantâneo e IP fixo global
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Global Accelerator?
A) Gera relatórios de custos
B) Otimiza tráfego global e reduz latência (correta)
C) Serviço de armazenamento de objetos
D) Load balancer

Explicação:
- B) Correta: Global Accelerator otimiza tráfego.
- A), C), D) não são funções do Global Accelerator.

Armadilha: confundir com CloudFront.

2. Quando usar Global Accelerator?
A) Para aplicações globais e alta disponibilidade (correta)
B) Para workloads locais
C) Para backups
D) Para banco de dados

Explicação:
- A) Correta: Global Accelerator é para apps globais.
- B), C), D) não são casos de uso de Global Accelerator.

Armadilha: achar que é igual a CloudFront.

## 5. Conceito Senior
- Global Accelerator oferece failover instantâneo entre regiões.
- IP fixo facilita integração com firewalls e parceiros.

## 6. Resumo para Revisão
- Global Accelerator = otimização de tráfego global | redução de latência | failover automático | IP fixo global | ideal para apps globais