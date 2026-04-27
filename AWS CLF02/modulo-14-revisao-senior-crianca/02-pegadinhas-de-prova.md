# Pegadinhas de prova CLF-C02

## 1. Mais gerenciado geralmente ganha

Se a pergunta pede menos administracao, pense em servico gerenciado.

Exemplos:

- Banco relacional sem cuidar de servidor: RDS, nao EC2 com MySQL.
- Codigo por evento sem servidor: Lambda, nao EC2.
- Container sem servidor: Fargate, nao ECS em EC2.

## 2. Responsabilidade compartilhada muda por servico

Explicacao para crianca:

- Em EC2, voce ganha uma casa vazia e cuida de muita coisa.
- Em Lambda, voce so entrega a tarefa e a AWS cuida da casa.

Visao senior:

| Servico | AWS cuida mais de | Cliente cuida mais de |
|---|---|---|
| EC2 | Datacenter, hardware, virtualizacao | Sistema operacional, patches, app, dados |
| RDS | Banco gerenciado, backups, patching do engine | Dados, acesso, configuracao |
| Lambda | Servidor, runtime gerenciado | Codigo, permissao, dados |
| S3 | Infraestrutura do storage | Bucket policy, dados, classificacao, lifecycle |

## 3. Root user quase nunca deve ser usado

Use root apenas para tarefas que exigem root.

Para o dia a dia:

- Crie usuarios/roles IAM.
- Ative MFA no root.
- Nao crie access key para root.
- Use least privilege.

## 4. Entrada de dados geralmente e gratis, saida costuma custar

Explicacao simples:

- Colocar coisas na AWS costuma ser como entrar em uma loja: normalmente nao paga entrada.
- Tirar dados para fora ou mandar entre lugares pode gerar custo.

Na prova:

- Data transfer IN: geralmente sem custo.
- Data transfer OUT para internet: geralmente tem custo.
- Entre regioes: geralmente tem custo.

## 5. Alta disponibilidade nao e igual a backup

Explicacao simples:

- Alta disponibilidade e ter outra bicicleta pronta se a sua furar o pneu.
- Backup e ter uma foto/peca guardada para restaurar depois.

Visao senior:

- Multi-AZ: continuidade dentro de uma regiao.
- Multi-Region: desastre, baixa latencia global ou soberania de dados.
- Backup: recuperacao de dados.
- Disaster Recovery: plano de volta depois de grande falha.

## 6. Security Group vs NACL

Explicacao simples:

- Security Group e o seguranca na porta do quarto.
- NACL e o portao do condominio.

Visao senior:

| Item | Security Group | NACL |
|---|---|---|
| Nivel | Instancia/ENI | Subnet |
| Estado | Stateful | Stateless |
| Regras deny | Nao | Sim |
| Ordem das regras | Nao importa | Importa |

## 7. IAM Policy vs SCP

Explicacao simples:

- IAM Policy da permissao para uma pessoa.
- SCP coloca limite maximo para uma conta inteira.

Visao senior:

- SCP nao concede permissao sozinho.
- SCP limita o que contas em AWS Organizations podem fazer.
- Mesmo admin da conta nao passa do limite imposto por SCP.

## 8. Reserved Instances vs Savings Plans vs Spot

Explicacao simples:

- On-Demand: pagar por uso, sem promessa.
- Reserved: prometer usar uma instancia por periodo.
- Savings Plans: prometer gastar por hora.
- Spot: usar sobra barata, mas pode ser interrompido.

Visao senior:

| Necessidade | Melhor opcao |
|---|---|
| Flexibilidade maxima | On-Demand |
| Carga previsivel por 1 ou 3 anos | Reserved Instances ou Savings Plans |
| Maior flexibilidade de computacao | Savings Plans |
| Trabalho tolerante a interrupcao | Spot |
| Licenca por socket/core ou host fisico dedicado | Dedicated Host |

## 9. AWS Artifact nao e auditoria automatica

- Artifact: baixa relatorios e acordos de compliance.
- Audit Manager: ajuda a coletar evidencias.
- Config: avalia configuracao dos recursos.
- CloudTrail: registra chamadas de API.

## 10. Trusted Advisor nao e monitoramento de metrica

Trusted Advisor verifica boas praticas em categorias como:

- Custo.
- Performance.
- Seguranca.
- Tolerancia a falhas.
- Limites de servico.

CloudWatch monitora metricas/logs/alarmes.

