# Módulo 7 — Segurança: IAM Avançado + Secrets Manager

> **Custo:** ~$0.05 | **Pré-requisito:** Módulo 6 concluído | **Duração estimada:** 5-6 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine a **segurança de um aeroporto**.

- **IAM Roles** = o **crachá de acesso** de cada funcionário:
  - O piloto (Lambda de voo) acessa a cabine, não o setor de bagagens
  - A atendente de check-in acessa o sistema de embarque, não a torre de controle
  - O segurança acessa todas as áreas, mas com câmeras registrando tudo

- **Secrets Manager** = o **cofre de senhas** no departamento de TI:
  - Não está escrito em post-it na mesa (não está hardcoded no código!)
  - O piloto só acessa a senha do sistema de bordo, não a de outros sistemas
  - A senha é trocada automaticamente a cada 90 dias (rotação automática)
  - Toda vez que alguém abre o cofre, fica registrado em log (CloudTrail)

- **IAM Conditions** = as **regras específicas** de cada área:
  - "Acesso à cabine permitido apenas entre 6h-22h (Condition: horário)"
  - "Acesso ao cofre apenas com dois crachás (Condition: MFA required)"
  - "Acesso ao terminal apenas da rede interna (Condition: IP range)"

---

## 2. O QUE É (Definição Técnica Sênior)

**AWS IAM (Advanced):** Além de usuários e roles básicas (Módulo 0), o IAM avançado inclui:
- **Permission Boundaries:** Limitam o máximo de permissões que uma role pode ter (mesmo que a policy dê mais)
- **IAM Conditions:** Restrições contextuais em policies (por IP, MFA, hora, tag, região...)
- **Service Control Policies (SCP):** Guardrails no nível de conta (Organizations)
- **Attribute-Based Access Control (ABAC):** Controle de acesso por tags dos recursos
- **Cross-Account Access:** Assumir roles em outras contas AWS

**AWS Secrets Manager:** Gerenciamento centralizado de credenciais com rotação automática. Suporta: senhas de banco de dados (RDS, Redshift), API keys, OAuth tokens. Cada secret pode ter múltiplas versões (current, previous, custom).

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 7:
  - IAM:              $0.00  (IAM é sempre gratuito)
  - Secrets Manager:  ~$0.40/segredo/mês
    (Para 2-3 dias de aprendizado: ~$0.04-0.06)
  - Lambda:           $0.00  (Free Tier)
  - CloudTrail:       $0.00  (primeiros 90 dias de eventos gratuitos)
  - TOTAL:            ~$0.05
  
  ⚠️  Secrets Manager: $0.40/segredo/mês + $0.05/10.000 chamadas API
  ⚠️  EXECUTE A LIMPEZA imediatamente após o módulo para minimizar custos!
  ⚠️  Cada secret pro-rata: ~$0.013/dia
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-role-com-conditions.yaml`](./01-role-com-conditions.yaml) | Role IAM com Conditions complexas | StringLike, IpAddress, MFA conditions |
| [`02-permission-boundary.yaml`](./02-permission-boundary.yaml) | Permission Boundary | Max permissions, delegation segura |
| [`03-secret-basico.yaml`](./03-secret-basico.yaml) | Secret no Secrets Manager | Secret creation, versioning |
| [`04-secret-com-rotacao.yaml`](./04-secret-com-rotacao.yaml) | Rotação automática de secret | Rotation Lambda, rotation schedule |
| [`05-lambda-usando-secret.py`](./05-lambda-usando-secret.py) | Lambda que lê segredos | boto3 secrets, caching |
| [`06-abac-por-tags.yaml`](./06-abac-por-tags.yaml) | Controle de acesso por tags | ABAC, aws:ResourceTag |
| [`07-cloudtrail-auditoria.yaml`](./07-cloudtrail-auditoria.yaml) | CloudTrail para auditoria | API logging, S3 storage |
| [`08-limpeza.sh`](./08-limpeza.sh) | Destrói todos os recursos | Cleanup obrigatório |

---

## 4. CONCEITOS FUNDAMENTAIS

### 4.1 IAM Conditions — Controle granular

```yaml
# Exemplos de Conditions em políticas IAM:

# 1. Exigir MFA para ações sensíveis
Condition:
  BoolIfExists:
    "aws:MultiFactorAuthPresent": "true"

# 2. Restringir por IP (ex: só da rede corporativa)
Condition:
  IpAddress:
    "aws:SourceIp": ["203.0.113.0/24", "10.0.0.0/8"]

# 3. Restringir por tag do recurso (ABAC)
Condition:
  StringEquals:
    "aws:ResourceTag/Ambiente": "${aws:PrincipalTag/Ambiente}"
    # A Role só acessa recursos com a mesma tag de Ambiente
    # Ex: Role tagueada Ambiente=dev só acessa S3 com tag Ambiente=dev

# 4. Restringir por hora do dia
Condition:
  DateGreaterThan:
    "aws:CurrentTime": "2024-01-01T06:00:00Z"
  DateLessThan:
    "aws:CurrentTime": "2024-12-31T22:00:00Z"

# 5. Só permite da mesma VPC
Condition:
  StringEquals:
    "aws:SourceVpc": "vpc-12345678"

# 6. Obrigar TLS (HTTPS)
Condition:
  Bool:
    "aws:SecureTransport": "false"
Effect: Deny   # DENY se NÃO for HTTPS!
```

### 4.2 Como o Secrets Manager funciona

```
FLUXO DE ACESSO A UM SECRET:

Lambda/App → Secrets Manager API → retorna o valor atual

VERSIONING:
  AWSCURRENT  = versão atual em uso
  AWSPENDING  = nova versão durante rotação
  AWSPREVIOUS = versão anterior (mantida para rollback)

ROTAÇÃO AUTOMÁTICA:
  1. Lambda de rotação cria nova senha no sistema (banco, API, etc.)
  2. Secrets Manager armazena como AWSPENDING
  3. Lambda testa a nova senha
  4. Se OK: AWSPENDING vira AWSCURRENT; AWSCURRENT vira AWSPREVIOUS
  5. AWSPREVIOUS é mantido por 1 ciclo para rollback
  
CACHING NA APLICAÇÃO:
  Em vez de chamar a API a cada request (custo + latência):
  - Use o SDK Secrets Manager Cache (Java, Python disponíveis)
  - Ou implemente cache próprio com TTL de 5 minutos
```

---

## 5. 🧠 CONCEITO SÊNIOR

**1. Diferença entre Resource-based Policy e Identity-based Policy**  
Identity-based: anexada a uma identity (usuário, role). Diz "o que esta identidade pode fazer".  
Resource-based: anexada a um recurso (S3 bucket, KMS key, SNS topic). Diz "quem pode acessar este recurso". Ambas devem ALLOW para o acesso acontecer (exceto root e cross-account que só precisam de uma).

**2. aws:PrincipalOrgID — O guardrail mais importante**  
Restringir acesso a recursos públicos (S3, SNS) apenas a contas da sua Organization:
```json
"Condition": {
  "StringEquals": {
    "aws:PrincipalOrgID": "o-xxxxxxxxxxxx"
  }
}
```
Evita que buckets públicos sejam acessados por contas externas mesmo que acidentalmente deixados públicos.

**3. Não guarde secrets em variáveis de ambiente Lambda!**  
Variável de ambiente Lambda é visível para qualquer um com `lambda:GetFunctionConfiguration`. Para strings sensíveis, use Secrets Manager e recupere dinamicamente.

**4. IAM Access Analyzer**  
Detecta automaticamente: recursos compartilhados publicamente, permissões não utilizadas (nos últimos 90 dias), e políticas com permissões excessivas. Integrar ao CI/CD para detectar antes do deploy.

---

## 6. PERGUNTAS DE ENTREVISTA

**Q: Qual a diferença entre IAM Role, Permission Boundary e SCP?**
> **Resposta esperada:** São três camadas de controle independentes: (1) IAM Role/Policy (Identity-based): define O QUE a identidade pode fazer — é o grant de permissão. Para que uma ação seja permitida, DEVE existir um Allow explícito na policy. (2) Permission Boundary: define o MÁXIMO de permissões que uma role pode ter. Se a policy diz Allow:s3:* mas a boundary só permite s3:GetObject, o resultado efetivo é s3:GetObject. Usada quando você delega criação de roles para devs mas quer limitar o escopo máximo que eles podem conceder. (3) SCP (Service Control Policy) no Organizations: guardrail no nível de conta que se aplica a TODOS os usuários/roles, incluindo root. Se o SCP nega Lambda em uma conta, ninguém naquela conta pode usar Lambda, mesmo com IAM Allow. Hierarquia de permissão efetiva: SCP AND Permission Boundary AND Identity Policy.

**Q: Por que não usar variáveis de ambiente para senhas em Lambda? Como você gerenciaria isso?**
> **Resposta esperada:** Variáveis de ambiente Lambda são: (1) visíveis via aws lambda get-function-configuration (qualquer um com acesso à Lambda vê); (2) aparecem em logs do CloudTrail quando a função é configurada; (3) não têm rotação automática; (4) se a senha vazar, não há como saber quem acessou. Solução correta: AWS Secrets Manager — a Lambda tem uma Role IAM com secretsmanager:GetSecretValue para um secret específico por ARN. O valor nunca está no código ou config. Adicionalmente: cache o secret por 5 minutos na memória Lambda para evitar chamadas excessivas à API (custo). Para múltiplos serviços: Parameter Store (SSM) para configurações não-sensíveis (gratuito), Secrets Manager para credenciais (pago mas com rotação).

---

## ✅ Próximo Módulo

👉 **[`../modulo-08-containers/README.md`](../modulo-08-containers/README.md)**
