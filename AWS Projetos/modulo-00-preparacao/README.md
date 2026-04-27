# Módulo 0 — Preparação do Ambiente

> **Custo:** $0.00 | **Pré-requisito:** Nenhum | **Duração estimada:** 2-3 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que a AWS é como um **condomínio de prédios gigante**.

- A **conta root** é como a **escritura do imóvel** — você só usa para coisas muito sérias (vender, hipotecar). No dia a dia, você usa a chave do apartamento.
- O **usuário IAM** é como a sua **chave do apartamento** — você usa todo dia, mas ela só abre o que precisa.
- O **AWS CLI** é como o **controle remoto** do condomínio — em vez de ir pessoalmente ao porteiro (Console AWS), você controla tudo da sua casa.
- O **MFA** é como uma **fechadura dupla** — mesmo que alguém roube sua chave, ainda precisa de um segundo código.
- O **Cost Explorer** é como o **extrato do cartão de crédito** — você vê exatamente onde gastou.
- O **Budget Alert** é como um **alarme de limite no cartão** — te avisa antes de você gastar demais.

---

## 2. O QUE É (Definição Técnica Sênior)

**AWS Account:** Contêiner isolado de recursos AWS com faturamento independente.

**IAM (Identity and Access Management):** Serviço global (não tem região) que controla *quem* pode fazer *o quê* em *quais recursos*. Opera no modelo de "negar tudo por padrão" — sem política explícita de ALLOW, o acesso é DENIED.

**MFA (Multi-Factor Authentication):** Segundo fator de autenticação via TOTP (Time-based One-Time Password). Fundamental para conformidade com SOC2, PCI-DSS e ISO 27001.

**AWS CLI:** Interface de linha de comando que chama as mesmas APIs que o Console AWS. Essencial para automação, scripts e IaC (Infrastructure as Code).

**Cost Explorer:** Serviço de visualização de custos e uso da AWS. Permite análise por serviço, região, tag, linked account.

**Budget Alerts:** Alertas proativos baseados em custo real ou previsto.

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 0:
  - IAM:           $0.00  (IAM é sempre gratuito)
  - Budget Alerts: $0.00  (primeiros 2 budgets são gratuitos)
  - Cost Explorer: $0.00  (visualização básica é gratuita)
  - TOTAL:         $0.00
  
  ✅ Nenhum recurso com custo contínuo será criado neste módulo.
```

---

## 3. PASSOS DO MÓDULO

### Passo 1: Criar conta AWS

1. Acesse [https://aws.amazon.com](https://aws.amazon.com) → "Crie uma conta da AWS"
2. Use um email válido (será o email root — guarde bem!)
3. Escolha o plano **Free (gratuito)**
4. Insira um **cartão de crédito** (necessário, mas não será cobrado no Free Tier)
5. Verifique o email e complete o cadastro

> ⚠️ **IMPORTANTE:** A senha da conta root deve ter no mínimo 16 caracteres. Guarde em um gerenciador de senhas (Bitwarden, 1Password, etc.)

---

### Passo 2: Ativar MFA na conta Root

1. Faça login com a conta root em [https://console.aws.amazon.com](https://console.aws.amazon.com)
2. Clique no seu nome (canto superior direito) → **Security credentials**
3. Seção **Multi-factor authentication (MFA)** → **Assign MFA device**
4. Escolha **Authenticator app**
5. Instale o **Google Authenticator** ou **Authy** no celular
6. Escaneie o QR Code e insira 2 códigos consecutivos para confirmar
7. Clique em **Add MFA**

> ✅ **Verificação:** Faça logout e login novamente — o sistema deve pedir o código MFA.

---

### Passo 3: Criar usuário IAM para uso diário

Veja o arquivo [`01-criar-usuario-iam.sh`](./01-criar-usuario-iam.sh) para os comandos completos.

**No Console AWS (alternativa visual):**
1. Pesquise **IAM** na barra de busca
2. Menu esquerdo → **Users** → **Create user**
3. Nome: `admin-pessoal` (ou seu nome)
4. Marque: **"Provide user access to the AWS Management Console"**
5. Crie uma senha e desmarque "must change password"
6. Next → **Attach policies directly**
7. Busque e selecione: `AdministratorAccess`
8. Next → **Create user**
9. **Guarde as credenciais geradas!**

> ⚠️ Em produção real, NUNCA use AdministratorAccess para usuários normais. Para aprendizado, usamos para simplificar. O Módulo 7 ensina como criar políticas com least privilege.

---

### Passo 4: Ativar MFA no usuário IAM

1. Vá em IAM → Users → `admin-pessoal`
2. Aba **Security credentials** → **Assign MFA device**
3. Repita o processo do Passo 2 (com outro token no app)

---

### Passo 5: Instalar e configurar o AWS CLI

**No Windows:**
```powershell
# Baixe e instale o AWS CLI v2:
# https://awscli.amazonaws.com/AWSCLIV2.msi

# Verifique a instalação:
aws --version
# Saída esperada: aws-cli/2.x.x Python/3.x.x Windows/...
```

**Configure com as credenciais do usuário IAM:**
```bash
aws configure
# AWS Access Key ID [None]: AKIA... (cole seu Access Key)
# AWS Secret Access Key [None]: ...  (cole seu Secret Key)
# Default region name [None]: us-east-1
# Default output format [None]: json
```

**Verifique se funcionou:**
```bash
# Este comando retorna quem você é na AWS:
aws sts get-caller-identity

# Saída esperada:
# {
#     "UserId": "AIDA...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/admin-pessoal"
# }
```

> ✅ Se aparecer seu ARN, a CLI está configurada corretamente!

---

### Passo 6: Criar Budget Alert (OBRIGATÓRIO antes de qualquer módulo)

Veja o arquivo [`02-budget-alert.sh`](./02-budget-alert.sh) para criar via CLI.

**No Console AWS:**
1. Pesquise **Billing** na barra de busca
2. Menu esquerdo → **Budgets** → **Create budget**
3. Escolha **Use a template** → **Monthly cost budget**
4. Budget name: `limite-aprendizado`
5. Budgeted amount: `$5`
6. Email recipients: seu email
7. **Create budget**

> ✅ Agora você receberá um email se seus gastos chegarem a $5. Proteção ativa!

---

### Passo 7: Entender o Free Tier

```
FREE TIER AWS — O que é gratuito e por quanto tempo:

SEMPRE GRÁTIS (sem expiração):
  ✅ Lambda:      1M invocações/mês + 400.000 GB-segundos
  ✅ DynamoDB:    25 GB + 25 WCU + 25 RCU
  ✅ S3:          5 GB + 20.000 GET + 2.000 PUT por mês
  ✅ CloudWatch:  10 métricas + 5 GB logs + 10 alarmes
  ✅ SNS:         1M publicações/mês
  ✅ SQS:         1M requisições/mês
  ✅ API Gateway: 1M chamadas REST/mês (HTTP API)
  ✅ IAM:         ilimitado (sempre grátis)
  ✅ CloudFormation: grátis (paga pelos recursos criados)

12 MESES GRÁTIS (a partir da criação da conta):
  ⏰ EC2:         750h/mês t2.micro ou t3.micro
  ⏰ RDS:         750h/mês db.t2.micro (MySQL, PostgreSQL, etc.)
  ⏰ ELB:         750h/mês
  
CUIDADO — NÃO são grátis:
  ❌ NAT Gateway: ~$0.045/hora + dados (~$32/mês ligado 24h!)
  ❌ ECS/EC2:     EC2 cobra por hora de uso
  ❌ RDS Multi-AZ: cobra o dobro
  ❌ Secrets Manager: $0.40/segredo/mês
```

---

### Passo 8: Configurar Cost Explorer

1. No Console AWS, vá em **Billing** → **Cost Explorer**
2. Clique em **Enable Cost Explorer** (primeira vez)
3. Aguarde 24h para os dados aparecerem
4. Explore: **Service** → veja o custo por serviço
5. Marque os filtros: últimos 7 dias, por serviço

> 💡 **Dica Sênior:** Sempre ative **Cost Allocation Tags** em projetos reais. Isso permite ver o custo por projeto, time ou cliente.

---

## 4. VERIFICAÇÃO FINAL DO MÓDULO 0

Execute este checklist antes de avançar:

```bash
# 1. CLI funcionando:
aws sts get-caller-identity

# 2. Você NÃO está usando root (verifique o ARN — deve ter "user/", não "root"):
# ✅ Correto:   "arn:aws:iam::123456789012:user/admin-pessoal"
# ❌ Incorreto: "arn:aws:iam::123456789012:root"

# 3. Região configurada:
aws configure get region
# Saída esperada: us-east-1

# 4. Budget criado:
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text)
```

---

## 5. 🧠 CONCEITO SÊNIOR

### O que um Sênior sabe que um Júnior não sabe:

**1. Root é sagrado — nunca use no dia a dia**
Em incidentes reais de segurança, credenciais root comprometidas causaram perda de MILHÕES de dólares (cryptomining, ransomware). Trate as credenciais root como a "chave mestre do cofre" — só em emergências.

**2. Least Privilege não é opcional em produção**
`AdministratorAccess` é aceitável para aprendizado, mas em produção cada Lambda, EC2, ECS Task precisa de uma Role IAM com apenas as permissões que ela realmente usa. Isso limita o "blast radius" de um ataque.

**3. Access Keys são um risco**
Em produção moderna, raramente se usa Access Keys. Prefere-se:
- Instance Profiles para EC2
- Execution Roles para Lambda/ECS
- OIDC Federation para GitHub Actions
- AWS SSO para usuários humanos

**4. Budget Alerts não são suficientes sozinhos**
Combine com: Service Control Policies (SCP) em Organizations, CloudTrail para auditoria, e AWS Config para conformidade contínua.

**5. Multi-region e multi-account**
Empresas sérias usam AWS Organizations com múltiplas contas (dev, staging, prod) e políticas SCP para impedir que desenvolvedores criem recursos caros acidentalmente.

---

## 6. PERGUNTAS DE ENTREVISTA

**Q: Qual a diferença entre um usuário IAM e uma Role IAM?**
> **Resposta esperada:** Um usuário IAM representa uma identidade permanente (pessoa ou aplicação) com credenciais de longo prazo (usuário/senha ou access keys). Uma Role IAM é uma identidade temporária assumida por outros serviços AWS, aplicações, usuários federados ou contas. Roles não têm credenciais permanentes — emitem tokens temporários via AWS STS (Security Token Service) com validade configurável. Roles são a forma preferida de autenticação em ambientes modernos por eliminar o risco de vazamento de credenciais de longo prazo.

**Q: O que é o princípio do Least Privilege e como você o implementa na AWS?**
> **Resposta esperada:** Least Privilege significa conceder a cada identidade (usuário, role, serviço) apenas as permissões estritamente necessárias para sua função, no momento em que precisa. Na AWS, implemento via: (1) Políticas IAM específicas por recurso usando ARNs, (2) Conditions para restringir por IP, MFA, hora ou tag, (3) Revisão periódica com IAM Access Analyzer e credential reports, (4) Permission Boundaries para limitar o escopo máximo que um administrador delegado pode conceder, (5) Service Control Policies em Organizations para guardrails em nível de conta.

---

## ✅ Próximo Módulo

Quando completar este checklist, avance para:
👉 **[`../modulo-01-s3/README.md`](../modulo-01-s3/README.md)**
