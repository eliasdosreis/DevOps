# Módulo 6 — Infraestrutura como Código: CloudFormation

> **Custo:** ~$0.00 | **Pré-requisito:** Módulos 1-5 concluídos | **Duração estimada:** 5-6 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que o **CloudFormation é uma receita de bolo muito precisa**.

- A **receita (template YAML)** descreve **exactamente** o que fazer: "1 bucket S3 privado, 1 Lambda Python com 128 MB, 1 API Gateway HTTP conectado à Lambda..."
- O **chef (CloudFormation)** lê a receita e cria o bolo (infraestrutura) automaticamente
- Se você quiser 10 bolos iguais: usa a mesma receita 10 vezes (múltiplos environments: dev, staging, prod)
- Se a receita mudar: o chef atualiza **apenas o que mudou** (não refaz o bolo inteiro)
- Se der errado durante o preparo: o chef **desfaz tudo** automaticamente (rollback)

**Sem CloudFormation (ClickOps):**
- "Cliquei no console, criei o bucket, depois a Lambda, depois esqueci como configurei..."
- Difícil reproduzir, difícil auditar, fácil errar

**Com CloudFormation (IaC):**
- "Execute este template YAML e a infraestrutura estará idêntica em qualquer conta, qualquer região"

---

## 2. O QUE É (Definição Técnica Sênior)

**AWS CloudFormation:** Serviço de Infrastructure as Code (IaC) que permite modelar e provisionar recursos AWS e de terceiros usando templates declarativos (JSON ou YAML). Você descreve o estado desejado; CloudFormation determina e executa a sequência correta de operações.

**Conceitos fundamentais:**
- **Template:** Arquivo YAML/JSON que descreve os recursos a criar (o "código")
- **Stack:** Instância de um template (o "ambiente" criado pelo template)
- **Change Set:** Preview das mudanças antes de aplicar (como um "diff" da infraestrutura)
- **Drift:** Diferença entre o template e o que realmente existe (mudança manual)
- **Cross-Stack Reference:** Exportar/importar valores entre stacks

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 6:
  - CloudFormation:  $0.00  (o serviço em si é GRATUITO)
  - Recursos criados: depende dos recursos nos templates
    (neste módulo, recriamos os Módulos 1-5 = ainda ~$0.00)
  - TOTAL:           ~$0.00
  
  ✅ CloudFormation não cobra pelo serviço — apenas pelos recursos que cria!
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-meu-primeiro-template.yaml`](./01-meu-primeiro-template.yaml) | Stack S3 básica | Template anatomy, Sections |
| [`02-parameters-e-outputs.yaml`](./02-parameters-e-outputs.yaml) | Template com parâmetros | Parameters, Outputs, Pseudo-parameters |
| [`03-conditions-e-mappings.yaml`](./03-conditions-e-mappings.yaml) | Lógica condicional | Conditions, Mappings, If functions |
| [`04-cross-stack-references.yaml`](./04-cross-stack-references.yaml) | Valores entre stacks | Export, ImportValue, Cross-Stack |
| [`05-nested-stacks.yaml`](./05-nested-stacks.yaml) | Stacks aninhadas | Nested Stacks, modularidade |
| [`06-deploy-e-update.sh`](./06-deploy-e-update.sh) | Deploy, atualização, drift | CLI CloudFormation commands |
| [`07-limpeza.sh`](./07-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. ANATOMIA DE UM TEMPLATE CLOUDFORMATION

```yaml
# Estrutura completa de um template (seções marcadas como obrigatório/opcional)

AWSTemplateFormatVersion: '2010-09-09'  # [OBRIGATÓRIO] Sempre este valor
Description: 'descrição do template'    # [OPCIONAL] aparece no console

# [OPCIONAL] Metadados extras (ex: configurações do AWS Console)
Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups: [...]

# [OPCIONAL] Valores de entrada que o usuário fornece ao criar a stack
Parameters:
  NomeBucket:
    Type: String
    Default: meu-bucket

# [OPCIONAL] Lógica condicional (if/else para recursos)
Conditions:
  EhProducao: !Equals [!Ref Ambiente, prod]

# [OPCIONAL] Mapeamentos chave-valor estáticos
Mappings:
  AmbienteConfig:
    dev:
      MemoriaLambda: 128

# [OBRIGATÓRIO] Os recursos a criar
Resources:
  MeuBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Ref NomeBucket

# [OPCIONAL] Valores retornados após criação (visíveis no console e exportáveis)
Outputs:
  ARNBucket:
    Value: !GetAtt MeuBucket.Arn
    Export:
      Name: !Sub "${AWS::StackName}-bucket-arn"
```

---

## 5. FUNÇÕES INTRÍNSECAS — O "vocabulário" do CloudFormation

```yaml
!Ref NomeParametro         # Referencia um Parameter ou Resource
!GetAtt Recurso.Atributo  # Pega um atributo de um recurso
!Sub "texto ${Variavel}"  # Interpolação de string (como f-string Python)
!Join ["-", [a, b, c]]    # Junta lista com separator: "a-b-c"
!Select [0, [a, b, c]]    # Seleciona por índice: "a"
!If [Cond, ValorTrue, ValorFalse]  # Condicional
!Equals [Valor1, Valor2]  # Retorna true/false
!And [Cond1, Cond2]       # Lógica AND
!Or [Cond1, Cond2]        # Lógica OR
!Not [Condicao]            # Negação
!FindInMap [Map, Key1, Key2]  # Lookup no Mappings section
!ImportValue NomeExport    # Importa Output de outra stack

# Pseudo-parameters (valores automáticos da AWS):
!Ref AWS::AccountId        # ID da conta (ex: 123456789012)
!Ref AWS::Region           # Região (ex: us-east-1)
!Ref AWS::StackName        # Nome da stack atual
!Ref AWS::NoValue          # Remove o atributo (útil em condicionais)
```

---

## 6. 🧠 CONCEITO SÊNIOR

**1. Change Sets — Nunca atualize uma stack sem revisar o Change Set**  
```bash
# ERRADO (vai diretamente):
aws cloudformation update-stack --stack-name minha-stack --template-body file://template.yaml

# CORRETO (revise antes!):
aws cloudformation create-change-set \
    --stack-name minha-stack \
    --change-set-name minha-mudanca \
    --template-body file://template.yaml

aws cloudformation describe-change-set \
    --stack-name minha-stack \
    --change-set-name minha-mudanca

# Após revisar:
aws cloudformation execute-change-set \
    --stack-name minha-stack \
    --change-set-name minha-mudanca
```

**2. Tipos de Update no CloudFormation**  
- **No interruption:** Recurso atualizado sem downtime (ex: mudar tag)
- **Some interruption:** Breve interrupção (ex: mudar tipo de instância EC2)
- **Replacement:** O recurso é DELETADO e recriado (ex: mudar o nome do bucket S3)
  → ⚠️ Replacement de banco de dados em produção = downtime! Sempre verifique no Change Set.

**3. Stack Policies — Proteção extra em produção**  
Evita que updates acidentais deletem ou substituam recursos críticos como bancos de dados:
```bash
aws cloudformation set-stack-policy --stack-name prod-stack --stack-policy-body '{
  "Statement": [{
    "Effect": "Deny",
    "Action": ["Update:Replace", "Update:Delete"],
    "Resource": "LogicalResourceId/BancoDeDados"
  }]
}'
```

**4. Drift Detection — Auditoria de mudanças manuais**  
```bash
# Detecta se alguém mudou recursos manualmente no console:
aws cloudformation detect-stack-drift --stack-name minha-stack
aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id ID
aws cloudformation describe-stack-resource-drifts --stack-name minha-stack
```

---

## 7. PERGUNTAS DE ENTREVISTA

**Q: Qual a diferença entre CloudFormation e Terraform? Quando usaria cada um?**
> **Resposta esperada:** CloudFormation é nativo AWS: integrado profundamente com todos os serviços AWS, sem custo adicional, suporta todos os tipos de recurso AWS instantaneamente, e o state é gerenciado pela própria AWS (sem S3 backend manual). Terraform é multi-cloud (AWS, Azure, GCP, K8s, DataDog...) com HCL como linguagem. Escolheria CloudFormation em: ambiente 100% AWS, times sem experiência Terraform, quando conformidade com AWS-native é obrigatória. Terraform em: infra multi-cloud, necessidade de recursos não-AWS (ex: Cloudflare DNS, PagerDuty), times com expertise HCL, estados complexos com módulos reutilizáveis. Na prática: muitas empresas usam CDK (AWS Cloud Development Kit) — constrói CloudFormation com Python/TypeScript, melhor DX.

**Q: O que é drift no CloudFormation e como você preveniria numa equipe de 20 devs?**
> **Resposta esperada:** Drift é quando o estado real dos recursos AWS diverge do que está no template CloudFormation — causado por mudanças manuais no console ou via CLI. Prevenção: (1) AWS Config Rules que detectam mudanças fora do CloudFormation; (2) SCPs (Service Control Policies) no Organizations que bloqueiam modificações em recursos tagueados como Managed=CloudFormation; (3) CI/CD: todo change passa por Pull Request com CloudFormation Linter (cfn-lint) e deploy automatizado; (4) CloudTrail + Lambda que detecta mudanças manuais e envia alerta ao Slack; (5) Drift Detection semanal automatizado via EventBridge; (6) Cultura: obrigar IaC em code review — changes manuais não são aceitos.

---

## ✅ Próximo Módulo

👉 **[`../modulo-07-iam-secrets/README.md`](../modulo-07-iam-secrets/README.md)**
