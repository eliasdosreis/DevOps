# Servicos faltantes - resumo rapido para prova

## Analytics

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| Athena | Fazer perguntas SQL em arquivos no S3 | Consultar logs/dados no S3 sem criar servidor |
| Glue | Cola que cataloga e transforma dados | ETL, catalogo de dados |
| Kinesis | Esteira de dados em tempo real | Streaming, cliques, logs chegando sem parar |
| QuickSight | Graficos e dashboards | BI, paineis para negocio |
| EMR | Cluster para big data | Hadoop/Spark gerenciado |
| OpenSearch | Busca e analise de logs/texto | Pesquisa, observabilidade, dashboards de logs |

## Developer Tools

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| AWS CLI | Controle da AWS por comandos | Acesso programatico pelo terminal |
| SDKs | Kits para programar usando AWS | Codigo chamando APIs AWS |
| CodeBuild | Robo que compila e testa codigo | Build/test automatizado |
| CodePipeline | Esteira de entrega | CI/CD do codigo ate producao |
| X-Ray | Raio-x de requisicoes | Achar gargalos em app distribuido |

## End User Computing

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| WorkSpaces | Computador virtual na nuvem | Desktop remoto persistente |
| AppStream 2.0 | App rodando por streaming | Entregar aplicativo sem instalar localmente |
| WorkSpaces Secure Browser | Navegador seguro gerenciado | Acesso web protegido para usuarios |

## Frontend, mobile e IoT

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| Amplify | Oficina pronta para app web/mobile | Criar e hospedar frontend rapido |
| AppSync | API GraphQL gerenciada | Apps que precisam sincronizar dados |
| IoT Core | Central de dispositivos | Conectar sensores/dispositivos a AWS |

## Migracao

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| Application Discovery Service | Descobre o que existe no datacenter | Planejar migracao |
| Application Migration Service | Move servidores para AWS | Lift-and-shift de servidores |
| Migration Evaluator | Calcula caso de negocio | Estimar economia da migracao |
| Migration Hub | Painel central da migracao | Acompanhar migracoes |
| SCT | Tradutor de schema de banco | Converter Oracle para PostgreSQL, por exemplo |
| DMS | Caminhao que move dados do banco | Migrar/replicar bancos com pouco downtime |

## Networking

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| PrivateLink | Porta privada para servico | Acessar servicos sem passar pela internet publica |
| Transit Gateway | Rotatoria central de redes | Conectar varias VPCs e redes on-premises |
| Direct Connect | Cabo dedicado para AWS | Conexao privada dedicada |
| VPN | Tunel criptografado pela internet | Conectar rede local a AWS com menor custo |

## Storage e recuperacao

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| AWS Backup | Agenda central de backups | Politicas de backup para varios servicos |
| Elastic Disaster Recovery | Plano de emergencia | Recuperar servidores apos desastre |

## Business e suporte

| Servico | Explicacao simples | Quando cai na prova |
|---|---|---|
| Amazon Connect | Central de atendimento | Call center na nuvem |
| Amazon SES | Envio de email | Email transacional/marketing |
| AWS Marketplace | Loja de softwares | Comprar solucoes de terceiros |
| AWS re:Post | Comunidade de perguntas | Ajuda comunitaria oficial |
| Knowledge Center | Respostas tecnicas oficiais | Artigos de problemas comuns |
| Prescriptive Guidance | Receitas de arquitetura/migracao | Guias recomendados pela AWS |

