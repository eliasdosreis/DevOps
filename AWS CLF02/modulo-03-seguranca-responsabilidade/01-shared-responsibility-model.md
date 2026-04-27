# Shared Responsibility Model (Modelo de Responsabilidade Compartilhada)

## 1. Analogia do Dia a Dia
É como alugar um apartamento mobiliado: o prédio cuida da estrutura (portaria, elevador, segurança do prédio), mas você é responsável pelo que acontece dentro do seu apartamento (trancar portas, não deixar o fogão ligado).

## 2. O que é (definição técnica oficial AWS)
O Shared Responsibility Model define o que é responsabilidade da AWS (segurança da nuvem) e o que é do cliente (segurança na nuvem). A AWS protege a infraestrutura, o cliente protege seus dados, aplicações e configurações.

## 3. Ficha de Estudo Comentada
============================================================
TEMA: Shared Responsibility Model
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Divisão clara de responsabilidades entre AWS e cliente
- AWS: segurança da nuvem (infraestrutura)
- Cliente: segurança na nuvem (dados, apps, permissões)

PALAVRAS-CHAVE NA PROVA:
→ "responsabilidade compartilhada"
→ "segurança da nuvem vs na nuvem"
→ "quem protege o quê"

QUANDO USAR:
✅ Sempre que usar AWS
✅ Para entender limites de responsabilidade

QUANDO NÃO USAR:
❌ Ignorar responsabilidades do cliente
❌ Assumir que AWS protege tudo

DIFERENCIAIS:
- É o conceito mais cobrado da prova
============================================================

## 4. Questões de Fixação
1. O que é responsabilidade da AWS?
A) Gerenciar dados do cliente
B) Proteger infraestrutura física (correta)
C) Definir políticas de acesso do cliente
D) Configurar firewalls de aplicação

Explicação:
- B) Correta: AWS cuida da infraestrutura.
- A), C), D) são do cliente.

Armadilha: achar que AWS protege tudo.

2. O que é responsabilidade do cliente?
A) Segurança física dos datacenters
B) Gerenciar usuários e permissões (correta)
C) Manutenção de hardware
D) Monitorar energia elétrica

Explicação:
- B) Correta: cliente gerencia usuários.
- A), C), D) são da AWS.

Armadilha: confundir "na nuvem" com "da nuvem".

## 5. Conceito Senior
- O modelo muda conforme o serviço (IaaS, PaaS, SaaS).
- Falhas de configuração do cliente são causa comum de incidentes.

## 6. Resumo para Revisão
- Shared Responsibility = AWS cuida da nuvem | cliente cuida do que está na nuvem | conceito mais cobrado | muda conforme serviço | atenção às configurações