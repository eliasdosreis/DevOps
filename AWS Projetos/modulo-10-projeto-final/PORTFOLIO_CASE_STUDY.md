# Case study de portfolio - E-commerce serverless AWS

## Resumo

Este projeto implementa um e-commerce serverless usando AWS. O objetivo e demonstrar uma arquitetura real com frontend, API, banco de dados, fila, notificacao, observabilidade, seguranca e infraestrutura como codigo.

Frase de portfolio:

"Construi um e-commerce serverless na AWS com API Gateway, Lambda, DynamoDB, SQS, SNS, S3, CloudWatch e CloudFormation, priorizando custo baixo, seguranca, resiliencia e automacao."

## Problema

Uma loja precisa receber pedidos online sem manter servidores ligados 24 horas por dia. O sistema precisa:

- exibir um frontend;
- criar e listar produtos;
- receber pedidos;
- processar pedidos de forma assincrona;
- registrar logs;
- notificar resultado;
- ser barato para demonstracao;
- ser facil de destruir para evitar custo.

## Explicacao para crianca de 8 anos

Imagine uma lojinha:

- O site e a vitrine.
- A API e o balcao.
- A Lambda e o atendente.
- O DynamoDB e o caderno dos produtos e pedidos.
- A SQS e a fila de pedidos esperando preparo.
- A SNS e o megafone que avisa quando o pedido ficou pronto.
- O CloudWatch e a camera que mostra se tudo esta funcionando.
- O CloudFormation e a receita que monta a lojinha inteira.

## Arquitetura

```text
Usuario
  -> S3/Frontend
  -> API Gateway
  -> Lambda principal
  -> DynamoDB produtos/pedidos
  -> SQS fila de pedidos
  -> Lambda worker
  -> SNS notificacao
  -> CloudWatch logs/metricas

CloudFormation cria e conecta os recursos.
IAM controla permissoes.
```

## Servicos usados

| Servico | Papel no projeto |
|---|---|
| S3 | Hospedar frontend estatico |
| API Gateway | Expor endpoints HTTPS |
| Lambda | Executar logica de negocio |
| DynamoDB | Persistir produtos e pedidos |
| SQS | Desacoplar processamento de pedidos |
| SNS | Enviar notificacoes |
| CloudWatch | Logs, metricas e alarmes |
| CloudFormation | Criar infraestrutura como codigo |
| IAM | Permissoes de menor privilegio |

## Decisoes tecnicas

### Por que serverless?

Para um portfolio e para cargas variaveis, serverless reduz operacao e custo ocioso. Nao ha servidor para manter ligado, atualizar ou escalar manualmente.

Trade-off:

- positivo: baixo custo, escala automatica, pouca operacao;
- negativo: limites de timeout, cold start e necessidade de boa observabilidade.

### Por que SQS entre pedido e worker?

Porque pedido nao deve depender de processamento imediato. A fila protege o sistema quando chegam muitos pedidos de uma vez.

Trade-off:

- positivo: desacoplamento, retry, absorve pico;
- negativo: consistencia eventual e necessidade de tratar duplicidade.

### Por que DynamoDB?

Porque e gerenciado, escala bem e combina com acesso por chave. Para este projeto, pedidos e produtos podem ser modelados com chaves claras.

Trade-off:

- positivo: baixa latencia e pouca operacao;
- negativo: exige pensar access patterns antes de criar a tabela.

## Seguranca

Boas praticas aplicadas ou recomendadas:

- IAM roles por funcao;
- menor privilegio;
- nao usar credenciais no codigo;
- Secrets Manager para segredos quando necessario;
- CloudTrail para auditoria;
- CORS restrito em producao;
- S3 publico somente se for site estatico e com politica controlada;
- tags para rastrear dono, modulo e ambiente.

Melhoria para producao:

- Cognito para autenticacao;
- WAF para protecao de borda;
- CloudFront com HTTPS e cache;
- KMS customer managed key se houver requisito de compliance.

## Confiabilidade

Pontos fortes:

- SQS absorve pico;
- Lambda pode processar mensagens com retry;
- infraestrutura pode ser recriada via CloudFormation;
- CloudWatch permite investigar falhas.

Melhorias:

- Dead Letter Queue para mensagens com erro persistente;
- idempotencia em criacao/processamento de pedidos;
- alarms para erro Lambda, fila crescendo e latencia alta;
- backup/PITR em DynamoDB se o dado for importante.

## Observabilidade

Evidencias que devem ser coletadas:

- logs da Lambda principal;
- logs da Lambda worker;
- metrica de invocacoes;
- metrica de erros;
- tamanho da fila SQS;
- latencia da API;
- resultado do script de teste end-to-end.

Pergunta senior:

"Um cliente disse que o pedido ficou preso. Como investigar?"

Resposta:

"Eu verificaria API Gateway status/latencia, logs da Lambda principal, item do pedido no DynamoDB, metricas da SQS ApproximateNumberOfMessagesVisible, logs da worker e falhas/DLQ. A ideia e seguir o rastro do pedido de ponta a ponta."

## Custo

Para laboratorio, o projeto deve ficar barato porque usa servicos com Free Tier e serverless. Mesmo assim, podem gerar custo:

- logs CloudWatch com muita retencao;
- Secrets Manager se ficar ativo;
- requisicoes API Gateway em volume;
- dados armazenados;
- recursos esquecidos.

Disciplina FinOps:

- budget antes do deploy;
- tags de custo;
- limpeza apos demonstracao;
- conferir Cost Explorer no dia seguinte.

## Como demonstrar

Roteiro de demo:

1. Mostrar diagrama.
2. Rodar deploy CloudFormation.
3. Abrir frontend.
4. Criar produto.
5. Listar produto.
6. Criar pedido.
7. Mostrar mensagem/processamento.
8. Mostrar logs CloudWatch.
9. Explicar custo e seguranca.
10. Rodar limpeza.

## Evidencias para GitHub

- Print do frontend.
- Output do deploy.
- Output do teste E2E.
- Print dos logs.
- Print do DynamoDB com item criado, ocultando dados sensiveis.
- Print da fila/processamento.
- Print da limpeza ou stack deletada.

## Melhorias futuras

- Cognito para login.
- CloudFront para frontend.
- WAF para API.
- CodePipeline/GitHub Actions para CI/CD.
- DLQ e alarms.
- Dashboard CloudWatch.
- X-Ray para tracing.
- Testes automatizados.
- Ambientes dev/prod.
- ADRs das decisoes principais.

## Resposta curta para entrevista

"Eu escolhi uma arquitetura serverless porque o objetivo era reduzir custo ocioso e operacao. API Gateway recebe as chamadas, Lambda executa a logica, DynamoDB persiste dados e SQS desacopla o processamento de pedidos. O desenho e barato e escalavel, mas exige cuidados com idempotencia, IAM, observabilidade, DLQ e controle de custo."

