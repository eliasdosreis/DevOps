# Módulo 5 — Documentação Técnica
## Aula 03: Como documentar uma Decisão Técnica (ADR)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você propôs trocar todas as EC2 machines legadas da AWS por containers (ECS Fargate). A diretoria aprovou verbalmente a ideia. Como um profissional sênior de impacto da engenharia de plataformas, você não simplesmente "sai mudando o código". Você redige um Architecture Decision Record (ADR), um documento formal e amigável para perpetuar na empresa *POR QUE* aquela mudança gigante no ecossistema aconteceu em 2026.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
As ADRs são padronizadas e lidas no mercado global. O inglês das decisões muda radicalmente o tom. Você vai largar o tom solto ("We changed because it's cheaper") e incorporar jargão claro de análise de cenário neutro: "Context" (Contexto do problema), "Decision" (O que faremos focado, "We decided to..."), "Consequences" (Consequências boas e ruins). O inglês desse doc atinge executivos com os dois pés na porta.

**3. OS BLOCOS ESSENCIAIS CONSTRUÍDOS EM INGLÊS**
🟢 **BLOCO 1: CONTEXTO (Context)**
* "Currently, we run our applications on EC2 instances, which requires heavy manual maintenance and OS patching."
  * **Tradução:** Atualmente, nós executamos nossas aplicações em instâncias EC2, o que requer manutenção manual pesada e patcheamento do SO (Mudar versão).
  * **Contexto:** Use "Currently" para expor como as coisas são hoje, ressaltando o peso (heavy/costly).

🟡 **BLOCO 2: DECISÃO (Decision)**
* "We will migrate the compute workloads from EC2 to AWS Fargate to achieve fully managed containerization."
  * **Tradução:** Nós migraremos as cargas de processamento do EC2 para o AWS Fargate para alcançarmos uma conteinerização 100% gerenciada pela AWS.
  * **Contexto:** Assertivo. "We will (Nós iremos)" mostra plano firme. O "to achieve..." reflete o objetivo executivo.

🔵 **BLOCO 3: CONSEQUÊNCIAS / IMPACTO (Consequences)**
* "Positive: Zero infrastructure maintenance overhead. Autoscaling becomes native."
* "Negative: Slightly higher compute cost per hour. Learning curve for the legacy team."
  * **Tradução:** Positiva: Custo-operacional nulo na infraestrutura. Auto-scale vira nativo. / Negativa: Levemente acima (custo de comp.) por hora. Curva de aprendizado pro time legado.
  * **Contexto:** Sinceridade máxima. Ao invés de "It's perfect", você aponta a "learning curve" (expressão amada nos EUA/EU para definir dificuldade técnica).

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso num ADR |
| :--- | :--- | :--- |
| **ADR** | Architecture Decision Record | "I created an **ADR** for this cloud migration." |
| **Overhead** | Custo operacional em energia/dinheiro| "This decision eliminates server **overhead**." |
| **To migrate / to switch**| Migrar / Trocar | "We plan to **switch** from Jenkins to Actions." |
| **Workload** | Processos computacionais ativos | "Hosting our **workloads** in the Cloud." |
| **Learning curve** | Curva de aprendizado (Dificuldade inicial) | "Docker introduces a steep **learning curve**." |

**5. MINI DIÁLOGO REAL**
*[Teams Call - Architecture Sync]*
**TechLead:** Elias, about the migration to Fargate... can you write an ADR before we actually start the Terraform work?
*(Elias, sobre a migração pro Fargate... pode escrever a ADR antes da gente realmente começar o TF?)*

**You:** For sure. I will draft the ADR clearly outlining the context, why we decided to switch, and both the positive and negative consequences. I'll share it on Confluence by EOD.
*(Com certeza. Farei o rascunho do ADR delineando o contexto claramente, por que decidimos mudar, e as conseq. positivas e negativas. Compartilho EOD no Conflu.)*

**TechLead:** Perfect. We need that documentation so the future developers understand the reasoning.
*(Perfeito. Precisamos dessa doc. para os futuros devs entenderem o raciocínio).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Because it's good." / "Because it's easier."** (Extremamente pobre para motivar uma mudança milionária).
✅ **"To reduce the operational overhead"** (Reduzir operação) ou **"To provide high availability."** (Prover alta dispon.).

❌ **"We decided to don't use EC2."** (Tradução e Gramática erradas).
✅ **"We decided to move away from EC2."** (Decidimos nos afastar de / afastar do... ) Muito inglês nativo.

❌ **"It will be more expensive."**
✅ **"There will be a cost increase."** (Terá um aumento de custos. Mais pro/formal doc).

**7. EXERCÍCIO PRÁTICO**
Memorize como justificar uma escolha num DOC corporativo (em vez de usar 'because'). "We decided to migrate to Github Actions **TO REDUCE the operational overhead.**" (Nós decidimos... para reduzir a sobrecarga operacional).

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"We will migrate our workloads to Fargate to eliminate the operational overhead of OS patching."**
*(Vamos migrar nossas cargas para o Fargate para eliminar a fadiga operacional dos patches/atualizações do SO).*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Why is keeping an Architectural Decision Record (ADR) important in a DevOps team?"*
✅ **Resposta modelo:**
"Because teams change constantly. Often, a new engineer looks at a complex Terraform module and asks: 'Why did we do this? It's so weird!'. If there is a well-documented ADR, they can read the 'Context' and the 'Consequences' of that time. ADRs preserve the 'Reasoning' (por quê) rather than just the code. It prevents the team from repeating the exact same architectural mistakes two years down the road."
