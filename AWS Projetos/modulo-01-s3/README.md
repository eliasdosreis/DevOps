# Módulo 1 — Storage: Amazon S3

> **Custo:** ~$0.00 | **Pré-requisito:** Módulo 0 concluído | **Duração estimada:** 3-4 horas

---

## 1. ANALOGIA DO DIA A DIA

Imagine que o **S3 é um armazém infinito do Correios**.

- O **Bucket** é como uma **caixa postal com nome único no mundo** — ninguém mais pode ter o mesmo nome.
- Os **Objetos** são as **cartas e pacotes** guardados dentro da caixa.
- A **Política do Bucket** é como as **regras de acesso** — quem pode pegar o quê.
- O **Versionamento** é como um **arquivo fotográfico** — você guarda cada versão de uma foto tirada no mesmo lugar.
- O **Lifecycle** é como uma **política de descarte** — "档案 com mais de 30 dias vão para o arquivo morto; com mais de 90 dias, deletar".
- O **Static Website Hosting** é como transformar sua caixa postal em uma **vitrine de loja** — qualquer pessoa pode ver o que está exposto.

---

## 2. O QUE É (Definição Técnica Sênior)

**Amazon S3 (Simple Storage Service):** Object storage com durabilidade de 99.999999999% (11 noves). Armazena dados como objetos (até 5 TB cada) dentro de buckets. É a base de praticamente toda arquitetura AWS moderna.

**Características fundamentais:**
- **Durabilidade:** 99.999999999% — a AWS replica automaticamente em múltiplas AZs
- **Disponibilidade:** 99.99% SLA (Standard class)
- **Consistência:** Strong read-after-write consistency (desde dezembro 2020)
- **Escalabilidade:** Ilimitada — sem provisioning manual
- **Storage Classes:** Standard, IA, Glacier, Deep Archive (diferença de custo e retrieval time)

---

## 💲 CUSTO ESTIMADO DESTE MÓDULO

```
💲 CUSTO ESTIMADO — MÓDULO 1:
  - S3 Storage:    $0.00  (Free Tier: 5 GB/mês por 12 meses)
  - S3 Requests:   $0.00  (Free Tier: 20.000 GET + 2.000 PUT/mês)
  - Data Transfer: $0.00  (saída até 100 GB/mês é grátis para internet)
  - TOTAL:         ~$0.00
  
  ⚠️  Cuidado após 12 meses: $0.023/GB (região us-east-1)
  ⚠️  Lembre-se de destruir os recursos ao final!
```

---

## 3. PROJETOS DESTE MÓDULO

| Arquivo | O que cria | Conceito ensinado |
|---------|-----------|-------------------|
| [`01-bucket-s3.yaml`](./01-bucket-s3.yaml) | Bucket S3 básico privado | Buckets, nomenclatura, regiões |
| [`02-bucket-versionamento.yaml`](./02-bucket-versionamento.yaml) | Adiciona versionamento ao bucket | Versioning, proteção contra delete |
| [`03-bucket-lifecycle.yaml`](./03-bucket-lifecycle.yaml) | Regras de ciclo de vida | Lifecycle rules, storage classes |
| [`04-site-estatico.yaml`](./04-site-estatico.yaml) | Hospedagem de site estático | Static Website, public access |
| [`05-bucket-policy-publica.yaml`](./05-bucket-policy-publica.yaml) | Política pública de leitura | Bucket Policies, JSON IAM |
| [`06-upload-e-teste.sh`](./06-upload-e-teste.sh) | Upload de arquivos e testes | CLI S3, sync, presigned URLs |
| [`07-limpeza.sh`](./07-limpeza.sh) | Destroi todos os recursos | Cleanup obrigatório |

---

## 4. FLUXO DE APRENDIZADO

```
[01] Criar bucket privado
         ↓
[02] Ativar versionamento
         ↓
[03] Adicionar regras de lifecycle
         ↓
[04] Habilitar hospedagem de site estático
         ↓
[05] Criar política pública de leitura
         ↓
[06] Fazer upload e testar via CLI
         ↓
[07] 🧹 LIMPEZA (sempre!)
```

---

## 5. CONCEITOS FUNDAMENTAIS DO S3

### 5.1 Nomenclatura de Buckets
```
Regras OBRIGATÓRIAS:
  ✅ Entre 3 e 63 caracteres
  ✅ Letras minúsculas, números e hífens apenas
  ✅ Deve começar com letra ou número
  ✅ GLOBALMENTE ÚNICO em toda a AWS (não só na sua conta!)
  ❌ Não pode ter letras maiúsculas
  ❌ Não pode ter underscores
  ❌ Não pode ser um endereço IP (ex: 192.168.1.1)

Boa prática de nomenclatura:
  {propósito}-{conta-ou-projeto}-{região}-{ambiente}
  Exemplo: uploads-meuapp-us-east-1-dev
```

### 5.2 Storage Classes — O que cada uma significa

```
STANDARD          → Acesso frequente. ~$0.023/GB
                    Durabilidade: 11 noves, 3+ AZs

STANDARD-IA       → Acesso infrequente. ~$0.0125/GB
                    Mas cobra $0.01/GB a cada retrievl!
                    Use para: backups, disaster recovery

ONE ZONE-IA       → Como Standard-IA mas em 1 AZ apenas.
                    Mais barato (~$0.01/GB) mas menos resiliente
                    Não use para dados críticos

GLACIER INSTANT   → Acesso raro (~1x por trimestre), retrieval: ms
                    ~$0.004/GB

GLACIER FLEXIBLE  → Acesso muito raro, retrieval: minutos-horas
                    ~$0.0036/GB  

DEEP ARCHIVE      → Arquivamento de longo prazo, retrieval: 12h
                    ~$0.00099/GB (o mais barato!)
                    Use para: conformidade, registros financeiros

INTELLIGENT-TIERING → AWS move automaticamente entre tiers
                       Cobra $0.0025/objeto para monitoramento
                       Bom quando o padrão de acesso é imprevisível
```

### 5.3 ARN do S3
```
Formato:  arn:aws:s3:::nome-do-bucket
          arn:aws:s3:::nome-do-bucket/pasta/arquivo.txt

Note: S3 não tem região no ARN (é global)
      S3 não tem Account ID no ARN
```

---

## 6. VERIFICAÇÃO E TROUBLESHOOTING COMUNS

### Erro: "BucketAlreadyExists"
```
Causa: O nome do bucket já existe em ALGUMA conta AWS do mundo
Solução: Adicione sufixo único (ex: -2024, -seunome, random)
```

### Erro: "Access Denied" ao acessar o site
```
Causa: Block Public Access ainda ativo, ou política não aplicada
Solução:
  1. Verifique se o Block Public Access está desativado
  2. Verifique se a bucket policy permite s3:GetObject para *
  3. Verifique se o arquivo foi carregado com o nome correto (index.html)
```

### Erro: "NoSuchBucket"
```
Causa: Nome do bucket errado ou bucket em outra região
Solução: 
  aws s3 ls → lista todos os buckets
  Verifique a região: aws s3api get-bucket-location --bucket nome-do-bucket
```

---

## 7. 🧠 CONCEITO SÊNIOR

### O que um Sênior sabe que um Júnior não sabe:

**1. S3 não é "apenas storage" — é um sistema de computação distribuída**
O S3 suporta S3 Select (queries SQL em objetos), S3 Object Lambda (transforma dados na leitura), e Event Notifications. Em produção, S3 é o "hub" de pipelines de dados.

**2. Segurança em camadas (Defense in Depth)**
Um Sênior configura 3 camadas:
- Block Public Access (nível de conta E bucket)
- Bucket Policy (quem pode acessar O QUÊ)
- Object ACLs (desabilitado em buckets modernos — use Bucket Policies)
- KMS encryption at rest (SSE-KMS para dados sensíveis)

**3. Performance patterns**
Para alto throughput (>3.500 PUT/s), use prefixos randômicos:
  - ❌ `uploads/2024/01/arquivo.jpg` (tutti os objetos no mesmo prefixo)
  - ✅ `a9f2/2024/01/arquivo.jpg` (hash no início distribui a carga)

**4. Custo oculto: Lifecycle mal configurado**
Mover 1 objeto para Glacier ANTES de 30 dias na Standard gera cobrança duplicada (minimum storage duration). Sempre leia a documentação de "minimum storage requirements" de cada classe.

**5. Presigned URLs vs Bucket Policy**
Para compartilhar arquivos temporariamente (ex: link de download por 1 hora), use presigned URLs — nunca torne o bucket público. A URL expira automaticamente.

**6. Replication para compliance**
CRR (Cross-Region Replication) e SRR (Same-Region Replication) para disaster recovery, conformidade regulatória (dados no Brasil, réplica no exterior), e redução de latência para usuários globais.

---

## 8. PERGUNTAS DE ENTREVISTA

**Q: Qual a diferença entre uma Bucket Policy e uma ACL no S3? Qual você prefere e por quê?**
> **Resposta esperada:** Bucket Policies são documentos JSON baseados em IAM que controlam acesso a nível de bucket ou objeto usando ações, recursos e condições. ACLs (Access Control Lists) são um mecanismo legado no nível de objeto. Amazon recomenda desabilitar ACLs (Object Ownership = Bucket Owner Enforced) e usar apenas Bucket Policies e IAM Policies. Prefiro Bucket Policies pois são mais expressivas (suportam Conditions, MFA, IP ranges), são auditáveis via CloudTrail, e seguem o mesmo modelo IAM do resto da AWS. ACLs ficaram obsoletas em agosto de 2021.

**Q: Como você organizaria o S3 para uma empresa com dados de múltiplos clientes garantindo isolamento?**
> **Resposta esperada:** Usaria um bucket por cliente (com nome como `dados-cliente-{id}`) ou prefixos por tenant com Bucket Policies que restringem acesso por prefixo usando condições `s3:prefix`. Em produção, prefiro contas AWS separadas por cliente usando AWS Organizations (isolamento total). Para isolamento por prefixo, uso IAM Roles com `Condition: {"StringLike": {"s3:prefix": "cliente-X/*"}}`. Adicionaria KMS CMK por cliente para criptografia com chaves isoladas. Habilitaria S3 Access Logs e CloudTrail Data Events para auditoria.

---

## ✅ Próximo Módulo

Quando terminar e executar a limpeza:
👉 **[`../modulo-02-lambda/README.md`](../modulo-02-lambda/README.md)**
