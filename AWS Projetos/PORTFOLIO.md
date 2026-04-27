# Guia de portfolio - AWS Projetos

Objetivo desta pasta: transformar cada modulo em uma prova publica de habilidade.

Um projeto bom de portfolio nao mostra apenas "eu rodei comandos". Ele mostra:

- problema de negocio;
- arquitetura escolhida;
- decisao tecnica;
- seguranca;
- custo;
- observabilidade;
- evidencia de funcionamento;
- limpeza para nao gerar cobranca;
- explicacao simples, como para uma crianca de 8 anos;
- explicacao senior, como em entrevista.

## Como explicar esta pasta em entrevista

"Eu montei uma trilha pratica de AWS com projetos pequenos, baratos e destrutiveis. Cada modulo treina uma habilidade real: S3, Lambda, API Gateway, DynamoDB, mensageria, CloudFormation, IAM, containers, observabilidade e um e-commerce serverless final. O foco foi aprender como um engenheiro senior: pensando em custo, seguranca, operacao, falha, logs e limpeza."

## Padrao de portfolio para cada modulo

Use este roteiro em todos os modulos:

| Secao | O que escrever |
|---|---|
| Problema | Qual dor real o projeto resolve |
| Solucao | Quais servicos AWS foram usados |
| Arquitetura | Fluxo simples de ponta a ponta |
| Como executar | Comandos minimos e pre-requisitos |
| Evidencias | Prints, logs, outputs e testes |
| Seguranca | IAM, criptografia, menor privilegio |
| Custo | Estimativa, recursos pagos, limpeza |
| Observabilidade | Logs, metricas, alarmes, troubleshooting |
| Melhorias futuras | O que faria em producao |
| Entrevista | 3 respostas fortes sobre decisoes tecnicas |

## Mapa de modulos para projetos publicaveis

| Modulo | Nome de portfolio sugerido | Entrega forte |
|---|---|---|
| 00 | AWS Landing Zone pessoal de baixo custo | usuario IAM, MFA, budget, checklist Free Tier |
| 01 | Site estatico seguro com S3 | bucket privado/publico controlado, lifecycle, site |
| 02 | Automacao serverless com Lambda | Lambda, logs, permissao IAM, teste via CLI |
| 03 | API HTTP serverless | API Gateway + Lambda + CORS + testes |
| 04 | CRUD NoSQL com DynamoDB | tabela, chaves, query vs scan, CRUD Boto3 |
| 05 | Mensageria resiliente com SNS e SQS | fan-out, fila, DLQ, retry, desacoplamento |
| 06 | Infraestrutura como codigo com CloudFormation | templates reutilizaveis, parametros, outputs |
| 07 | Seguranca com IAM e Secrets Manager | least privilege, secrets, rotacao conceitual |
| 08 | API containerizada no ECS/Fargate | Docker, ECR, ECS, health check |
| 09 | Observabilidade com CloudWatch | logs, metricas, alarms, queries |
| 10 | E-commerce serverless completo | case study final para entrevista |

## Nivel crianca de 8 anos

Pense nos projetos como uma cidade:

- S3 e um armario gigante para guardar arquivos.
- Lambda e um ajudante que aparece, faz uma tarefa e vai embora.
- API Gateway e a porta de atendimento.
- DynamoDB e um caderno magico super rapido.
- SQS e uma fila de tarefas.
- SNS e um megafone que avisa varias pessoas.
- CloudFormation e uma receita que monta tudo igual sempre.
- IAM e a chave certa para a pessoa certa.
- CloudWatch e o painel que mostra se a cidade esta bem.

## Nivel senior

Em cada modulo, responda:

- Qual falha este desenho tolera?
- Qual custo escondido pode aparecer?
- Qual permissao IAM poderia ser reduzida?
- Onde ficam os logs?
- Como eu provo que funcionou?
- Como eu destruo tudo com seguranca?
- O que mudaria para producao?

## Checklist antes de publicar no GitHub

- [ ] Removi credenciais, account id sensivel, emails pessoais e tokens.
- [ ] Coloquei um `README.md` claro no modulo.
- [ ] Adicionei diagrama simples.
- [ ] Adicionei comandos de deploy e limpeza.
- [ ] Adicionei evidencia de teste.
- [ ] Expliquei custo estimado.
- [ ] Expliquei seguranca e IAM.
- [ ] Expliquei melhorias futuras.
- [ ] Rodei limpeza na AWS.

## Sugestao de post para LinkedIn

Hoje finalizei um projeto pratico de AWS focado em arquitetura real e custo controlado.

O que construi:

- infraestrutura como codigo;
- servicos serverless;
- controle de custo;
- seguranca com IAM;
- logs e metricas;
- limpeza automatizada.

Principal aprendizado: em AWS, subir recurso e facil. O diferencial e saber operar com seguranca, custo previsivel, observabilidade e decisao tecnica defensavel.

