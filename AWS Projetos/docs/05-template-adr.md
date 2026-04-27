# Template ADR - Architecture Decision Record

Use um ADR quando tomar uma decisao importante de arquitetura.

## ADR-000X - Titulo da decisao

Data: YYYY-MM-DD

Status: Proposta | Aceita | Substituida

## Contexto

Qual problema estamos tentando resolver?

Exemplo:

"Precisamos criar uma API de baixo custo para um portfolio, com pouca operacao e capacidade de escalar automaticamente."

## Decisao

O que foi escolhido?

Exemplo:

"Usaremos API Gateway + Lambda em vez de EC2."

## Explicacao simples

Como explicar para uma crianca de 8 anos?

Exemplo:

"Em vez de deixar um computador ligado o dia todo esperando alguem pedir algo, chamamos um ajudante so quando alguem bate na porta."

## Motivos senior

- Menor custo ocioso.
- Menor responsabilidade operacional.
- Escala automatica.
- Integracao nativa com IAM e CloudWatch.
- Bom para trafego variavel.

## Alternativas consideradas

| Alternativa | Por que nao foi escolhida agora |
|---|---|
| EC2 | Mais controle, mas exige patching, rede, escala e custo ligado |
| ECS Fargate | Bom para containers, mas mais complexo para este modulo |
| Elastic Beanstalk | Simples para app web, mas menos direto para funcoes por evento |

## Consequencias

Positivas:

- Menos operacao.
- Custo baixo para laboratorio.
- Deploy simples.

Negativas:

- Cold start pode existir.
- Limites de timeout/concorrrencia precisam ser conhecidos.
- Observabilidade precisa ser bem configurada.

## Como validar

- Teste via `curl` ou AWS CLI.
- Logs no CloudWatch.
- Metricas de erro e latencia.
- Limpeza do recurso apos teste.

