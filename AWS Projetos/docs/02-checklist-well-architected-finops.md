# Checklist Well-Architected e FinOps para portfolio

Base conceitual: AWS Well-Architected Framework, boas praticas de CloudFormation e ferramentas AWS de custo.

## Explicacao simples

Pense em construir uma casa:

- Operacao: consigo cuidar da casa todo dia?
- Seguranca: portas e janelas estao protegidas?
- Confiabilidade: se uma lampada queima, a casa continua funcionando?
- Performance: a casa atende bem sem desperdicio?
- Custo: nao estou pagando por quartos vazios?
- Sustentabilidade: uso so o necessario?

## Checklist por pilar

### 1. Excelencia operacional

- [ ] O deploy e repetivel com CloudFormation/script.
- [ ] Existe comando claro de teste.
- [ ] Existe comando claro de limpeza.
- [ ] Logs sao enviados para CloudWatch.
- [ ] O README explica troubleshooting comum.
- [ ] Mudancas sao versionadas no Git.

Pergunta senior:

"Como voce faria rollback se a mudanca quebrasse?"

Resposta esperada:

"Eu versionaria o template/codigo, usaria change sets quando aplicavel, monitoraria alarmes e faria rollback para a versao anterior do stack/codigo."

### 2. Seguranca

- [ ] Nao ha credenciais no repositorio.
- [ ] IAM usa menor privilegio.
- [ ] Dados sensiveis usam Secrets Manager ou Parameter Store.
- [ ] S3 publico somente quando necessario.
- [ ] Buckets tem Block Public Access quando aplicavel.
- [ ] Logs de auditoria sao considerados com CloudTrail.
- [ ] MFA e budget estao configurados na conta.

Pergunta senior:

"O que voce faria se uma access key vazasse?"

Resposta esperada:

"Desativaria e rotacionaria a key, revisaria CloudTrail, validaria uso suspeito, reduziria permissao e moveria o fluxo para role temporaria quando possivel."

### 3. Confiabilidade

- [ ] Existe tratamento de erro.
- [ ] Existe retry ou DLQ quando ha fila/eventos.
- [ ] Recursos podem ser recriados via IaC.
- [ ] O projeto documenta limites e cotas relevantes.
- [ ] Dados importantes tem backup ou estrategia de recuperacao.

Pergunta senior:

"O que acontece se a Lambda falhar enquanto processa mensagem?"

Resposta esperada:

"A mensagem pode voltar para a fila apos visibility timeout. Depois de varias falhas, deve ir para uma DLQ para analise sem perder o evento."

### 4. Eficiencia de performance

- [ ] Servico escolhido combina com o padrao de acesso.
- [ ] DynamoDB evita Scan em caminho critico.
- [ ] Lambda tem memoria/timeout pensados.
- [ ] API tem limites/throttling considerados.
- [ ] Cache e CloudFront sao considerados para leitura frequente.

Pergunta senior:

"Como voce reduziria latencia?"

Resposta esperada:

"Eu analisaria metricas p95/p99, logs e traces; depois ajustaria memoria Lambda, reduziria chamadas externas, melhoraria chaves DynamoDB e adicionaria cache quando o padrao permitir."

### 5. Otimizacao de custo

- [ ] Ha estimativa antes do deploy.
- [ ] Ha budget configurado.
- [ ] Recursos caros sao evitados no laboratorio.
- [ ] Tags de custo sao usadas.
- [ ] Existe limpeza automatizada/manual documentada.
- [ ] Cost Explorer e usado depois do laboratorio.

Pergunta senior:

"Qual a diferenca entre Pricing Calculator, Budgets e Cost Explorer?"

Resposta esperada:

"Pricing Calculator estima antes, Budgets alerta durante, Cost Explorer analisa historico depois."

### 6. Sustentabilidade

- [ ] Recursos ociosos sao removidos.
- [ ] Serverless e usado quando faz sentido.
- [ ] Ambientes de laboratorio sao temporarios.
- [ ] Retencao de logs e lifecycle sao configurados.

Pergunta senior:

"Como reduzir desperdicio sem perder qualidade?"

Resposta esperada:

"Removendo recursos ociosos, ajustando retencao, usando lifecycle, escolhendo serverless para demanda irregular e medindo custo por transacao."

## Checklist FinOps rapido

Antes do projeto:

- [ ] Budget ativo.
- [ ] Regiao definida.
- [ ] Estimativa de custo registrada.
- [ ] Tags definidas: `Project`, `Module`, `Owner`, `Environment`.

Durante:

- [ ] Validar recursos criados.
- [ ] Anotar tempo de execucao.
- [ ] Registrar prints de evidencia.

Depois:

- [ ] Rodar limpeza.
- [ ] Conferir recursos orfaos.
- [ ] Conferir Cost Explorer no dia seguinte.
- [ ] Atualizar README com custo real.

## Fontes oficiais uteis

- AWS Well-Architected Framework: https://docs.aws.amazon.com/wellarchitected/
- CloudFormation best practices: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html
- AWS Pricing Calculator: https://docs.aws.amazon.com/pricing-calculator/
- AWS Budgets: https://aws.amazon.com/aws-cost-management/aws-budgets/
- AWS Cost Explorer: https://aws.amazon.com/documentation-overview/cost-explorer/

