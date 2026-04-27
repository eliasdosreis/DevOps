# Comparativos que mais caem na CLF-C02

## CloudWatch vs CloudTrail vs Config

Explicacao para crianca:

- CloudWatch e o relogio/termometro: ve se esta tudo funcionando.
- CloudTrail e a camera: mostra quem fez o que.
- Config e o inspetor: ve se as coisas estao do jeito combinado.

Visao senior:

| Cenario | Servico |
|---|---|
| CPU alta, alarme, metrica, log de aplicacao | CloudWatch |
| Quem deletou o bucket? Quem chamou a API? | CloudTrail |
| O recurso mudou configuracao? Esta em conformidade? | Config |

Pegadinha:

- "Monitorar performance" nao e CloudTrail.
- "Auditar chamadas de API" nao e CloudWatch.
- "Historico de configuracao" nao e CloudTrail, e Config.

## GuardDuty vs Inspector vs Macie vs Security Hub

Explicacao para crianca:

- GuardDuty e o vigia que percebe comportamento estranho.
- Inspector e o medico que examina se a maquina tem fraqueza.
- Macie e o detetive que acha documentos secretos no S3.
- Security Hub e a TV central que mostra alertas de varios lugares.

Visao senior:

| Cenario | Servico |
|---|---|
| Ameaca, comportamento suspeito, conta comprometida | GuardDuty |
| Vulnerabilidade em EC2, container image, Lambda | Inspector |
| PII/dados sensiveis no S3 | Macie |
| Centralizar findings de seguranca | Security Hub |

## S3 vs EBS vs EFS vs FSx

Explicacao para crianca:

- S3 e uma caixa de brinquedos enorme.
- EBS e o HD grudado em um computador.
- EFS e uma pasta compartilhada por varios computadores Linux.
- FSx e uma pasta especial pronta para Windows, Lustre, NetApp ou OpenZFS.

Visao senior:

| Cenario | Servico |
|---|---|
| Arquivos/objetos, backup, site estatico, data lake | S3 |
| Disco de uma EC2 | EBS |
| File system Linux compartilhado por varias EC2 | EFS |
| File system Windows ou alta performance especializada | FSx |

Pegadinha:

- S3 nao e disco de EC2.
- EBS normalmente fica preso a uma AZ.
- EFS e regional e pode ser montado por varias instancias.

## EC2 vs Lambda vs Fargate vs Elastic Beanstalk vs Lightsail

Explicacao para crianca:

- EC2 e alugar um computador inteiro.
- Lambda e pedir para alguem fazer uma tarefa rapidinha quando algo acontece.
- Fargate e rodar container sem cuidar do servidor.
- Beanstalk e entregar o codigo e deixar a AWS montar a casa.
- Lightsail e um servidor simples com preco previsivel.

Visao senior:

| Cenario | Servico |
|---|---|
| Controle total do servidor | EC2 |
| Evento, serverless, execucao curta | Lambda |
| Container sem gerenciar servidor | Fargate |
| Deploy simples de app web com plataforma gerenciada | Elastic Beanstalk |
| VPS simples para site pequeno/MVP | Lightsail |

## RDS vs Aurora vs DynamoDB vs Redshift vs ElastiCache

Explicacao para crianca:

- RDS e uma planilha organizada em tabelas.
- Aurora e um RDS turbo da AWS.
- DynamoDB e uma caixa muito rapida de chave e valor.
- Redshift e uma sala enorme para analisar muitos dados.
- ElastiCache e um bloquinho de anotacoes super rapido para nao perguntar tudo de novo.

Visao senior:

| Cenario | Servico |
|---|---|
| Banco relacional gerenciado | RDS |
| Relacional compativel MySQL/PostgreSQL com alta performance AWS | Aurora |
| NoSQL, baixa latencia, escala massiva | DynamoDB |
| Data warehouse/analytics | Redshift |
| Cache em memoria | ElastiCache |

## SNS vs SQS vs EventBridge vs Step Functions

Explicacao para crianca:

- SNS e um megafone.
- SQS e uma fila.
- EventBridge e um organizador de eventos.
- Step Functions e uma receita passo a passo.

Visao senior:

| Cenario | Servico |
|---|---|
| Enviar notificacao para varios assinantes | SNS |
| Desacoplar sistemas com fila | SQS |
| Roteamento de eventos entre apps/SaaS/AWS | EventBridge |
| Orquestrar workflow com etapas | Step Functions |

## Route 53 vs CloudFront vs Global Accelerator

Explicacao para crianca:

- Route 53 e a agenda que transforma nome em endereco.
- CloudFront e uma lanchonete perto de voce com copia do lanche.
- Global Accelerator e uma pista expressa ate a aplicacao.

Visao senior:

| Cenario | Servico |
|---|---|
| DNS e registro de dominio | Route 53 |
| CDN/cache de conteudo | CloudFront |
| Melhorar rota global para app TCP/UDP, IPs anycast | Global Accelerator |

## Athena vs Glue vs Kinesis vs QuickSight

Explicacao para crianca:

- Athena pergunta coisas para arquivos no S3.
- Glue arruma os dados baguncados.
- Kinesis recebe dados em movimento.
- QuickSight desenha graficos.

Visao senior:

| Cenario | Servico |
|---|---|
| SQL direto em dados no S3 | Athena |
| ETL/catalogo de dados | Glue |
| Streaming de dados em tempo real | Kinesis |
| BI, dashboards, visualizacao | QuickSight |

## Pricing Calculator vs Budgets vs Cost Explorer vs CUR

Explicacao para crianca:

- Pricing Calculator calcula antes.
- Budgets avisa durante.
- Cost Explorer explica depois.
- CUR mostra a conta completa nos minimos detalhes.

Visao senior:

| Cenario | Servico |
|---|---|
| Estimar custo antes de usar | Pricing Calculator |
| Alerta de gasto/orcamento | Budgets |
| Analisar historico e tendencias | Cost Explorer |
| Relatorio detalhado de uso e custo | Cost and Usage Report |

