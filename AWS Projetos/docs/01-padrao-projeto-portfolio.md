# Padrao de projeto para portfolio

Use este arquivo como molde para revisar cada modulo.

## 1. Resumo executivo

Explique em 5 linhas:

- O que foi construido.
- Qual problema resolve.
- Quais servicos AWS foram usados.
- Quanto custa para demonstrar.
- Como limpar.

Exemplo:

"Este projeto cria uma API serverless usando API Gateway, Lambda e DynamoDB. Ele resolve o problema de expor um CRUD simples sem gerenciar servidores. A infraestrutura pode ser criada com CloudFormation, testada via CLI e removida ao final para evitar custo."

## 2. Explicacao para crianca de 8 anos

Modelo:

"Imagine que voce tem uma loja de brinquedos. O cliente fala com o balcao, o balcao chama um ajudante, o ajudante procura no caderno e responde. Na AWS, o balcao e o API Gateway, o ajudante e a Lambda e o caderno e o DynamoDB."

## 3. Explicacao senior

Modelo:

"A arquitetura usa componentes gerenciados para reduzir operacao. API Gateway recebe chamadas HTTPS, Lambda executa logica sob demanda, DynamoDB fornece persistencia NoSQL com baixa latencia e CloudWatch centraliza logs/metricas. O desenho minimiza custo ocioso, mas exige atencao a IAM, limites de concorrencia, modelagem de chaves e alarmes."

## 4. Arquitetura minima

Inclua sempre:

```text
Usuario
  -> Servico de entrada
  -> Computacao
  -> Dados/Mensageria
  -> Logs/Metricas
```

## 5. Evidencias obrigatorias

Para cada modulo, guarde:

- print do stack CloudFormation criado;
- print ou output do comando de teste;
- print de logs no CloudWatch;
- print do recurso principal funcionando;
- print do custo ou Budget;
- print da stack deletada ou script de limpeza executado.

## 6. Seguranca

Responda no README:

- Qual role/policy foi criada?
- A policy esta com menor privilegio possivel?
- Existe dado sensivel?
- Existe criptografia?
- Existe recurso publico?
- Como auditar quem fez alteracao?

## 7. Custo

Responda:

- Quais recursos podem gerar cobranca?
- O que fica no Free Tier?
- Qual recurso e mais perigoso esquecer ligado?
- Qual comando limpa?
- Como validar no Cost Explorer/Budgets?

## 8. Observabilidade

Inclua:

- onde ver logs;
- quais metricas importam;
- qual alarme faria sentido;
- como investigar erro comum.

## 9. Melhorias futuras

Use linguagem de arquiteto:

- autenticacao;
- CI/CD;
- testes automatizados;
- WAF;
- CloudFront;
- DLQ;
- multi-ambiente;
- tags de custo;
- dashboards;
- disaster recovery.

## 10. Frase de entrevista

Sempre termine com uma frase forte:

"A principal decisao tecnica deste projeto foi escolher servicos gerenciados para reduzir operacao e custo ocioso, mantendo rastreabilidade com logs, controle de acesso com IAM e limpeza automatizada para evitar cobranca desnecessaria."

