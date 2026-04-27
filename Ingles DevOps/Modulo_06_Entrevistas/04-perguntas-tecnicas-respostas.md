# Módulo 6 — Entrevistas Técnicas em Inglês
## Aula 04: Perguntas Técnicas de DevOps em Inglês e Respostas Modelo

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Metade da sua entrevista será uma "Technical Deep Dive" (Mergulho Profundo Técnico). Os engenheiros do outro lado farão perguntas abertas que não têm só "Sim/Não" como resposta. Eles perguntarão "Como você faria X?" ou "Explique o conceito Y". Suar frio e responder com 2 palavras te reprova imediatamente. Você precisa argumentar com jargão em inglês em voz alta.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Uma excelente resposta técnica mostra clareza, compara ferramentas conhecidas (Trade-offs) e não tem medo de falar que 'depende do contexto' ("It depends on the use case"). Aqui, praticaremos as perguntas arquiteturais mais cobradas em DevOps na gringa e suas lógicas.

**3. O TOP 3 DE PERGUNTAS DE ENTREVISTA BRUTA**

❓ **Pergunta 1: "Explain the difference between a virtual machine and a container."**
*(Explique a diferença entre uma VM e um container)*
✅ **Resposta Elite:**
"A Virtual Machine packages an entire Operating System, including its own kernel, which makes it heavier and slower to boot. A container, like Docker, shares the host's OS kernel and packages only the application code and its dependencies. This makes containers extremely lightweight, ephemeral, and perfect for microservices architecture where fast scaling is required."

❓ **Pergunta 2: "If you type a URL in the browser, what happens behind the scenes from a DevOps perspective?"**
*(Se uma URL é digitada, o que ocorre nos bastidores do ponto de vista do DevOps?)*
✅ **Resposta Elite:**
"First, DNS resolution converts the domain into an IP address. The request hits our cloud Load Balancer or Ingress Controller. The Load Balancer terminates the SSL certificate and distributes the traffic to a healthy backend pod in an EKS cluster. The pod processes the request, potentially querying a managed RDS database or Redis cache, and returns the HTTP output back through the same path to the user."

❓ **Pergunta 3: "What is Infrastructure as Code (IaC) and why use Terraform instead of clicking around the AWS console?"**
*(O que é IaC e pq usar Terraform no lugar de clicar na console?)*
✅ **Resposta Elite:**
"IaC is the process of provisioning infrastructure using code instead of manual processes. We use Terraform rather than manual 'ClickOps' to ensure immutability, reproduceability, and to keep an audit trail via Git. If the region goes down, I can spin up the exact same infrastructure in another region in minutes."

**4. VOCABULÁRIO TÉCNICO DA AULA (VOCABULÁRIO MILIONÁRIO)**
| Palavra/Expressão | Significado em Português | Exemplo de uso |
| :--- | :--- | :--- |
| **Ephemeral** | Efêmero/Morre rápido (Pilar Cloud)| "Containers must be purely **ephemeral**." |
| **Trade-offs** | Prós e contras / Compensações | "We need to discuss the architectural **trade-offs**." |
| **Immutability** | Imutabilidade do infra | "**Immutability** prevents configuration drift." |
| **ClickOps** | Clicar na tela ao invés de codar | "We strictly ban **ClickOps** in production." |
| **Audit trail** | Rastro de auditoria / Log | "Git provides a perfect **audit trail**." |

**5. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Because Terraform is good."** (Seu inglês congelou a capacidade cognitiva do seu português Sênior).
✅ **"Because Terraform provides idempotency and reproducibility."** (Use os termos corretos universais da Cloud).

❌ **"In the Amazon interface..."**
✅ **"In the AWS Management Console..."** (Chame o jargão original pelo nome oficial).

**6. EXERCÍCIO PRÁTICO**
Responda mentalmente a pergunta "Por que usar Docker?".
Diga a resposta matadora do SRE: "Porque eles são leves (lightweight) e perfeitos para a arquitetura de microserviços (microservices architecture)."

**7. FRASE PARA MEMORIZAR HOJE**
🗣️ **"We use IaC to ensure immutability and prevent configuration drift across environments."**
*(Usamos IaC para garantir imutabilidade e prevenir variação de configurações através dos ambientes).*
