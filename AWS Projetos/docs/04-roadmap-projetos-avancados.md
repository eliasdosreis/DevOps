# Roadmap de projetos avancados para evoluir o portfolio

Esta trilha atual ja cobre a base. Para deixar o portfolio mais forte, adicione evolucoes graduais.

## Nivel 1 - Portfolio essencial

Meta: provar que voce sabe criar, testar e limpar recursos.

- S3 site estatico.
- Lambda hello world com logs.
- API Gateway + Lambda.
- DynamoDB CRUD.
- SNS/SQS.
- CloudFormation.

Resultado esperado:

"Consigo construir pequenos blocos AWS com seguranca e custo controlado."

## Nivel 2 - Portfolio profissional

Meta: mostrar operacao e boas praticas.

Adicionar:

- tags padrao em todos os templates;
- alarms CloudWatch;
- dashboard por projeto;
- DLQ em fluxos assincronos;
- README com evidencias;
- script unico de deploy/test/cleanup;
- ADRs para decisoes importantes.

Resultado esperado:

"Consigo entregar projeto operavel, nao apenas recurso funcionando."

## Nivel 3 - Portfolio senior

Meta: defender arquitetura em entrevista.

Adicionar:

- autenticacao com Cognito;
- WAF em front/API quando aplicavel;
- CloudFront na frente do S3/API;
- CI/CD com GitHub Actions ou CodePipeline;
- testes automatizados;
- ambiente dev/prod via parametros;
- least privilege revisado;
- cost allocation tags;
- runbook de incidente;
- diagrama C4 simples.

Resultado esperado:

"Consigo explicar trade-offs de seguranca, custo, resiliencia e performance."

## Projetos extras recomendados

### 1. URL Shortener Serverless

Servicos:

- API Gateway;
- Lambda;
- DynamoDB;
- CloudWatch;
- CloudFormation.

O que demonstra:

- baixa latencia;
- modelagem NoSQL simples;
- redirecionamento HTTP;
- custo quase zero.

### 2. Pipeline de imagens

Servicos:

- S3;
- Lambda;
- SQS;
- DynamoDB;
- CloudWatch.

O que demonstra:

- evento de upload;
- processamento assincrono;
- fila para desacoplar;
- status de processamento.

### 3. Mini data lake

Servicos:

- S3;
- Glue;
- Athena;
- QuickSight ou outputs SQL;
- CloudFormation.

O que demonstra:

- analytics;
- dados em camadas;
- consulta SQL em S3;
- custo controlado.

### 4. API containerizada

Servicos:

- Docker;
- ECR;
- ECS Fargate;
- ALB;
- CloudWatch.

O que demonstra:

- container;
- health check;
- deploy gerenciado;
- diferenca entre serverless function e container.

### 5. E-commerce serverless com autenticacao

Servicos:

- S3/CloudFront;
- Cognito;
- API Gateway;
- Lambda;
- DynamoDB;
- SQS/SNS;
- CloudWatch.

O que demonstra:

- arquitetura real;
- autenticacao;
- fluxo assincrono;
- observabilidade;
- historia forte para entrevista.

## Como priorizar

Se o objetivo e emprego rapido:

1. Finalize o projeto final.
2. Crie case study.
3. Adicione evidencias.
4. Publique no GitHub.
5. Faça um post no LinkedIn.
6. Prepare respostas de entrevista.

Se o objetivo e nivel senior:

1. Adicione Cognito.
2. Adicione CI/CD.
3. Adicione alarms e dashboard.
4. Adicione WAF/CloudFront.
5. Adicione ADRs.
6. Escreva runbook de incidente.

