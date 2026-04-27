# Roteiro de evidencias para portfolio

Este roteiro ajuda a provar que o projeto funcionou.

## Pasta sugerida por modulo

Crie uma pasta local de evidencias quando executar:

```text
evidencias/
  modulo-01-s3/
    01-stack-created.png
    02-bucket-config.png
    03-site-online.png
    04-cloudwatch-or-cli-output.txt
    05-cleanup.png
```

Nao suba prints com account id, email pessoal, tokens, nomes reais de clientes ou informacoes sensiveis.

## Evidencias por tipo de projeto

### S3

- bucket criado;
- bloqueio publico quando aplicavel;
- versionamento/lifecycle;
- site acessando;
- limpeza do bucket.

### Lambda

- funcao criada;
- role IAM anexada;
- teste de invocacao;
- logs no CloudWatch;
- metrica de invocacao/erro.

### API Gateway

- endpoint criado;
- chamada via `curl`;
- resposta de sucesso;
- CORS se houver frontend;
- logs/metricas.

### DynamoDB

- tabela criada;
- chave primaria e sort key;
- item inserido;
- query funcionando;
- exemplo de erro evitado: scan desnecessario.

### SNS/SQS

- topico/fila criada;
- mensagem publicada;
- mensagem recebida;
- DLQ configurada ou explicada;
- alarme sugerido para fila crescendo.

### CloudFormation

- stack criada;
- outputs;
- evento de deploy;
- drift detection ou validacao;
- stack deletada.

### IAM/Secrets

- policy com menor privilegio;
- secret criado sem expor valor;
- acesso via role;
- exemplo de acesso negado esperado;
- limpeza do secret.

### Containers

- imagem Docker buildada;
- container rodando local;
- push para ECR;
- task/service ECS;
- health check passando.

### CloudWatch

- log group;
- query Logs Insights;
- dashboard;
- alarm;
- exemplo de investigacao.

### Projeto final

- arquitetura completa;
- deploy da stack;
- frontend carregando;
- API criando produto;
- pedido passando por SQS;
- email/notificacao SNS ou evidencia equivalente;
- dashboard/metricas;
- limpeza final.

## Como escrever legenda de evidencia

Use frases curtas:

"Stack CloudFormation criada com sucesso. O output mostra a URL da API e o nome dos recursos principais."

"Teste end-to-end criando produto e pedido. A resposta HTTP 201 confirma criacao, e o log da Lambda mostra processamento sem erro."

"Limpeza executada ao final. O objetivo e evitar custo residual e mostrar disciplina operacional."

## Evidencia que impressiona em entrevista

Uma evidencia forte mostra causa e efeito:

1. Eu chamei a API.
2. A Lambda registrou log.
3. O DynamoDB recebeu o item.
4. A fila recebeu a mensagem.
5. O worker processou.
6. O status mudou.
7. Eu limpei tudo.

Isso conta uma historia de engenharia, nao apenas uma lista de prints.

