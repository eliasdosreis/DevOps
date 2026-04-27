# Mapa oficial da prova CLF-C02 e lacunas para reforcar

Fonte-base: guia oficial AWS Certified Cloud Practitioner CLF-C02.

## Como pensar na prova

Imagine que a AWS e uma cidade gigante.

- Computacao e onde as maquinas trabalham.
- Armazenamento e onde as coisas ficam guardadas.
- Banco de dados e uma biblioteca organizada.
- Rede e o caminho das ruas.
- Seguranca e a fechadura, camera e porteiro.
- Cobranca e a conta de luz da cidade.

A prova pergunta: "Para este problema, qual predio da cidade voce deve usar?"

## Dominio 1 - Conceitos de nuvem (24%)

O que ja existe nos modulos:

- Beneficios da nuvem.
- Modelos de servico.
- Modelos de implantacao.
- Well-Architected.
- Infraestrutura global.

O que reforcar:

- AWS Cloud Adoption Framework (AWS CAF).
- Estrategias de migracao.
- Economia de nuvem: custo fixo vs variavel, rightsizing, BYOL, automacao.

Explicacao simples:

- CAF e como um plano de mudanca de casa. Nao e so levar os moveis; tambem precisa combinar dinheiro, pessoas, seguranca, operacao e negocio.
- Rightsizing e comprar um tenis do tamanho certo. Se compra grande demais, paga caro e fica ruim.
- BYOL e levar sua propria licenca de software para a nuvem, como levar seu proprio brinquedo para a escola.

Visao senior:

- A prova pode perguntar "como reduzir risco e melhorar eficiencia operacional na migracao". Isso aponta para AWS CAF.
- Se o cenario fala de servidor superdimensionado, pense em rightsizing ou Compute Optimizer.
- Se fala de licencas existentes, pense em BYOL ou License Manager.

## Dominio 2 - Seguranca e compliance (30%)

O que ja existe nos modulos:

- Modelo de responsabilidade compartilhada.
- IAM.
- MFA.
- Organizations e SCPs.
- Shield, WAF, GuardDuty, Inspector, Macie, KMS, CloudHSM, CloudTrail, Config.

O que reforcar:

- AWS Artifact.
- AWS Audit Manager.
- AWS Security Hub.
- IAM Identity Center.
- Root user.
- Access keys e armazenamento de credenciais.
- Criptografia em repouso vs em transito.
- Onde encontrar informacoes oficiais de seguranca.

Explicacao simples:

- Artifact e a pasta de documentos oficiais da AWS para mostrar que ela segue regras.
- Audit Manager e um ajudante que monta evidencias para auditoria.
- Security Hub e um painel que junta alertas de seguranca.
- IAM Identity Center e uma portaria unica para entrar em varias contas AWS.

Visao senior:

- "Relatorios de conformidade da AWS" quase sempre aponta para AWS Artifact.
- "Centralizar achados de seguranca" aponta para Security Hub.
- "Gerenciar acesso humano a varias contas AWS" aponta para IAM Identity Center.
- "Detectar atividade suspeita" aponta para GuardDuty.
- "Avaliar vulnerabilidade em EC2/container" aponta para Inspector.
- "Dados sensiveis em S3" aponta para Macie.

## Dominio 3 - Tecnologia e servicos (34%)

O que ja existe nos modulos:

- EC2, Lambda, ECS/EKS/Fargate, Beanstalk, Lightsail.
- S3, EBS, EFS, FSx, Storage Gateway, Snow Family.
- RDS, Aurora, DynamoDB, ElastiCache, Redshift, Neptune, DocumentDB, DMS.
- VPC, Route 53, CloudFront, Direct Connect, VPN, Global Accelerator.
- SQS, SNS, EventBridge, Step Functions, API Gateway.
- CloudWatch, CloudTrail, Config, Systems Manager, Trusted Advisor.
- ML basico.

O que reforcar:

- Analytics: Athena, Glue, Kinesis, QuickSight, EMR, OpenSearch.
- Developer tools: CodeBuild, CodePipeline, X-Ray, CLI, SDK, APIs.
- End User Computing: WorkSpaces, AppStream 2.0, WorkSpaces Secure Browser.
- Frontend/mobile: Amplify, AppSync.
- IoT Core.
- Migration Hub, Application Migration Service, Application Discovery Service, Migration Evaluator, SCT.
- PrivateLink, Transit Gateway.
- AWS Backup e Elastic Disaster Recovery.

Explicacao simples:

- Athena faz pergunta em arquivos no S3, como pesquisar em uma caixa de papeis sem tirar tudo de la.
- Glue e a cola que prepara dados para analise.
- Kinesis e uma esteira de dados chegando sem parar.
- QuickSight faz graficos e paineis.
- X-Ray mostra por onde uma requisicao passou quando a aplicacao esta lenta.

Visao senior:

- A prova cobra reconhecimento, nao configuracao.
- Se o cenario fala de "consultar dados no S3 com SQL", escolha Athena.
- Se fala de "pipeline CI/CD", escolha CodePipeline; para compilar/testar, CodeBuild.
- Se fala de "desktop virtual", escolha WorkSpaces; se fala de "streaming de aplicacao", escolha AppStream 2.0.
- Se fala de "GraphQL/API para app", escolha AppSync; se fala de "site/app web full stack facil", escolha Amplify.

## Dominio 4 - Billing, pricing e suporte (12%)

O que ja existe nos modulos:

- Pricing Calculator.
- Cost Explorer.
- Budgets.
- Support Plans.
- Checklist de cobranca.

O que reforcar:

- Savings Plans vs Reserved Instances.
- Spot Instances.
- Dedicated Hosts vs Dedicated Instances.
- Capacity Reservations.
- Data transfer IN vs OUT.
- Cost and Usage Report.
- Cost allocation tags.
- AWS Marketplace.
- AWS Health Dashboard e Health API.
- AWS re:Post, Knowledge Center, Prescriptive Guidance.
- Enterprise On-Ramp.
- AWS Trust and Safety.

Explicacao simples:

- Budgets e o alarme da mesada.
- Cost Explorer e o desenho que mostra onde a mesada foi gasta.
- Pricing Calculator e a calculadora antes de comprar.
- CUR e a nota fiscal gigante com todos os detalhes.

Visao senior:

- "Prever custo antes de criar" aponta para Pricing Calculator.
- "Analisar gasto historico" aponta para Cost Explorer.
- "Receber alerta quando passar limite" aponta para Budgets.
- "Relatorio detalhado para BI/financas" aponta para Cost and Usage Report.
- "Agrupar custo por projeto/time" aponta para cost allocation tags.

