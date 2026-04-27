# Simulado senior comentado - CLF-C02

Use como treino final. Responda primeiro sem olhar o gabarito.

## Questoes

### 1. Uma empresa quer estimar o custo mensal antes de criar recursos na AWS. Qual servico usar?

A) AWS Budgets  
B) AWS Pricing Calculator  
C) AWS Cost Explorer  
D) AWS CloudTrail

### 2. Uma empresa quer receber alerta quando o gasto passar de um limite definido. Qual servico usar?

A) AWS Budgets  
B) AWS Artifact  
C) Amazon Inspector  
D) AWS X-Ray

### 3. Quem registra chamadas de API para responder "quem fez o que" na conta AWS?

A) Amazon CloudWatch  
B) AWS CloudTrail  
C) AWS Config  
D) AWS Trusted Advisor

### 4. Qual servico ajuda a verificar se recursos estao em conformidade com regras de configuracao?

A) AWS Config  
B) AWS Shield  
C) Amazon SNS  
D) Amazon Route 53

### 5. Uma aplicacao precisa consultar arquivos no Amazon S3 usando SQL, sem gerenciar servidor. Qual servico usar?

A) Amazon Athena  
B) Amazon RDS  
C) Amazon ElastiCache  
D) Amazon EFS

### 6. Uma empresa quer detectar dados sensiveis em buckets S3. Qual servico usar?

A) Amazon Macie  
B) AWS WAF  
C) AWS Shield  
D) AWS IAM Identity Center

### 7. Uma empresa quer centralizar achados de seguranca vindos de varios servicos. Qual servico usar?

A) AWS Security Hub  
B) AWS Artifact  
C) AWS Pricing Calculator  
D) AWS CodeBuild

### 8. Qual servico e melhor para fila entre sistemas desacoplados?

A) Amazon SQS  
B) Amazon SNS  
C) Amazon CloudFront  
D) AWS Direct Connect

### 9. Qual servico e melhor para notificacao pub/sub para varios assinantes?

A) Amazon SNS  
B) Amazon SQS  
C) Amazon EBS  
D) AWS Config

### 10. Qual opcao e ideal para workloads tolerantes a interrupcao com menor custo em EC2?

A) On-Demand  
B) Reserved Instances  
C) Spot Instances  
D) Dedicated Hosts

### 11. Uma empresa precisa de desktop virtual persistente para usuarios. Qual servico usar?

A) Amazon WorkSpaces  
B) Amazon AppStream 2.0  
C) AWS Lambda  
D) Amazon Route 53

### 12. Uma empresa quer transmitir uma aplicacao para usuarios sem instalar localmente. Qual servico usar?

A) Amazon AppStream 2.0  
B) Amazon WorkSpaces  
C) Amazon S3 Glacier  
D) AWS KMS

### 13. O que protege melhor a conta root?

A) Criar access key para root  
B) Ativar MFA e evitar uso diario do root  
C) Compartilhar senha do root com administradores  
D) Usar root para todas as tarefas

### 14. Qual servico fornece relatorios de conformidade da AWS?

A) AWS Artifact  
B) AWS Lambda  
C) Amazon DynamoDB  
D) AWS Batch

### 15. Uma aplicacao precisa rodar codigo em resposta a eventos, sem gerenciar servidor. Qual servico usar?

A) AWS Lambda  
B) Amazon EC2  
C) AWS Outposts  
D) Amazon EBS

### 16. Qual servico entrega conteudo com baixa latencia usando cache em edge locations?

A) Amazon CloudFront  
B) AWS Direct Connect  
C) Amazon VPC  
D) AWS IAM

### 17. Qual servico e DNS gerenciado da AWS?

A) Amazon Route 53  
B) Amazon CloudWatch  
C) AWS Glue  
D) Amazon Aurora

### 18. Banco relacional gerenciado compativel com engines comuns como MySQL/PostgreSQL aponta para:

A) Amazon RDS  
B) Amazon DynamoDB  
C) Amazon S3  
D) Amazon Kinesis

### 19. Banco NoSQL de baixa latencia e escala massiva aponta para:

A) Amazon DynamoDB  
B) Amazon Redshift  
C) Amazon EFS  
D) AWS DMS

### 20. Data warehouse para analytics aponta para:

A) Amazon Redshift  
B) Amazon RDS  
C) Amazon EBS  
D) AWS WAF

### 21. Qual servico gerencia acesso humano centralizado a varias contas AWS?

A) AWS IAM Identity Center  
B) Amazon GuardDuty  
C) AWS CloudHSM  
D) Amazon Textract

### 22. Uma empresa quer conectar varias VPCs e redes locais por um hub central. Qual servico usar?

A) AWS Transit Gateway  
B) AWS Client VPN  
C) Amazon CloudFront  
D) Amazon SES

### 23. Qual servico permite conexao dedicada privada entre datacenter e AWS?

A) AWS Direct Connect  
B) AWS VPN  
C) AWS WAF  
D) Amazon SNS

### 24. Qual servico e usado para criar dashboards de BI?

A) Amazon QuickSight  
B) Amazon SQS  
C) AWS Shield  
D) AWS Systems Manager

### 25. Qual servico cria pipelines de CI/CD?

A) AWS CodePipeline  
B) AWS CodeBuild  
C) AWS X-Ray  
D) AWS Artifact

### 26. Qual servico compila e testa codigo?

A) AWS CodeBuild  
B) AWS CodePipeline  
C) Amazon Route 53  
D) Amazon Macie

### 27. Qual servico ajuda a visualizar gargalos em aplicacoes distribuidas?

A) AWS X-Ray  
B) AWS Budgets  
C) AWS Organizations  
D) Amazon S3 Glacier

### 28. Qual conceito reduz desperdicio ao ajustar recursos para o tamanho correto?

A) Rightsizing  
B) Multi-AZ  
C) Federation  
D) Data sovereignty

### 29. Qual servico centraliza backups de varios servicos AWS?

A) AWS Backup  
B) AWS Snowball  
C) AWS Glue  
D) AWS Shield

### 30. Qual servico ajuda a migrar bancos com pouco downtime?

A) AWS DMS  
B) AWS KMS  
C) AWS WAF  
D) Amazon Polly

## Gabarito comentado

1. B - Pricing Calculator calcula antes de usar. Budgets avisa depois que voce definiu limites.
2. A - Budgets e o alarme de gasto.
3. B - CloudTrail e a camera das chamadas de API.
4. A - Config avalia configuracao e conformidade.
5. A - Athena consulta dados no S3 com SQL.
6. A - Macie descobre dados sensiveis no S3.
7. A - Security Hub centraliza findings de seguranca.
8. A - SQS e fila.
9. A - SNS e pub/sub/notificacao.
10. C - Spot e barato, mas pode ser interrompido.
11. A - WorkSpaces e desktop virtual.
12. A - AppStream 2.0 faz streaming de aplicacoes.
13. B - Root deve ter MFA e uso minimo.
14. A - Artifact fornece relatorios e documentos de compliance.
15. A - Lambda roda codigo por evento sem servidor.
16. A - CloudFront e CDN em edge locations.
17. A - Route 53 e DNS gerenciado.
18. A - RDS e banco relacional gerenciado.
19. A - DynamoDB e NoSQL gerenciado de baixa latencia.
20. A - Redshift e data warehouse.
21. A - IAM Identity Center centraliza acesso humano.
22. A - Transit Gateway funciona como hub de redes.
23. A - Direct Connect e conexao dedicada privada.
24. A - QuickSight cria dashboards de BI.
25. A - CodePipeline orquestra CI/CD.
26. A - CodeBuild compila e testa.
27. A - X-Ray rastreia requisicoes e gargalos.
28. A - Rightsizing ajusta tamanho/capacidade para reduzir desperdicio.
29. A - AWS Backup centraliza politicas de backup.
30. A - DMS migra/replica bancos com pouco downtime.

