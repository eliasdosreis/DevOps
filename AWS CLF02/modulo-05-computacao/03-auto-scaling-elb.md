# Auto Scaling e Elastic Load Balancer (ALB, NLB, CLB)

## 1. Analogia do Dia a Dia
Auto Scaling é como contratar garçons extras em um restaurante só quando o movimento aumenta. Load Balancer é como um gerente que distribui os clientes igualmente entre os garçons para ninguém ficar sobrecarregado.

## 2. O que é (definição técnica oficial AWS)
- Auto Scaling: ajusta automaticamente a quantidade de instâncias EC2 conforme a demanda.
- Elastic Load Balancer (ELB): distribui o tráfego entre múltiplas instâncias. Tipos: ALB (camada 7), NLB (camada 4), CLB (legado).

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Auto Scaling e ELB
DOMÍNIO DO EXAME: Computação (33%)
============================================================

O QUE É:
- Auto Scaling: escala automática de instâncias
- ELB: balanceamento de carga
- ALB: HTTP/HTTPS, NLB: TCP/UDP, CLB: legado

PALAVRAS-CHAVE NA PROVA:
→ "escala automática"
→ "balanceamento de carga"
→ "ALB = HTTP"
→ "NLB = TCP/UDP"

QUANDO USAR:
✅ Aplicações com variação de demanda
✅ Alta disponibilidade

QUANDO NÃO USAR:
❌ Workloads fixos sem variação
❌ Usar CLB para novos projetos

DIFERENCIAIS:
- Auto Scaling reduz custos e aumenta resiliência
============================================================

## 4. Questões de Fixação
1. O que faz o Auto Scaling?
A) Cria backups
B) Ajusta número de instâncias conforme demanda (correta)
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- B) Correta: Auto Scaling ajusta instâncias.
- A), C), D) não são funções do Auto Scaling.

Armadilha: confundir Auto Scaling com ELB.

2. Qual Load Balancer usar para HTTP/HTTPS?
A) NLB
B) ALB (correta)
C) CLB
D) S3

Explicação:
- B) Correta: ALB é para HTTP/HTTPS.
- A), C), D) não são para HTTP/HTTPS.

Armadilha: confundir ALB com NLB.

## 5. Conceito Senior
- Auto Scaling pode ser baseado em métricas customizadas.
- ALB suporta regras avançadas de roteamento.

## 6. Resumo para Revisão
- Auto Scaling = escala automática | ELB = balanceamento de carga | ALB = HTTP | NLB = TCP/UDP | CLB = legado | aumenta disponibilidade e reduz custos