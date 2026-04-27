# Módulo 6 — Entrevistas Técnicas em Inglês
## Aula 02: Como explicar sua experiência com projetos DevOps reais

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
"Walk me through your resume" (Navegue pelo seu currículo). O entrevistador quer que você pegue uma bala de prata do seu currículo (aquela migração cabulosa) e explique sem ler a tela. O desafio é não se perder no detalhe técnico irrelevante (ex: versão do NGINX) e focar no Business Value (o que a empresa lucrou/economizou com a sua arquitetura).

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Uma experiência vendável não é "Eu subia máquina EC2", e sim "Eu automatizei o provisionamento de servidores, reduzindo 4 dias de trabalho manual para 10 minutos". Use verbos de impacto: Arquitetar, Provisionar, Automatizar, Otimizar, Reduzir (Architect, Provision, Automate, Optimize, Reduce). 

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "I made the CI/CD pipeline."
  * **Contexto:** Muito fraco. Fazer = Make (pra bolo/artesanato). Em software nós "construímos" (build) ou "implementamos" (implement).

🟡 **INTERMEDIÁRIO** — Soa profissional
* "In my last project, I built the entire CI/CD pipeline using GitLab, which made the deployment much faster."
  * **Contexto:** Correto e mostra a ferramenta, mas peca pela falta de "métrica final" na ponta.

🔵 **AVANÇADO / SENIOR** — Soa nativo / Impactante
* "I spearheaded the design and implementation of an automated CI/CD pipeline. By standardizing the build process, we eliminated manual errors and decreased deployment time by 60%."
  * **Tradução:** Eu liderei (fui a ponta da lança) o design e a implantação de um pipeline CI/CD... eliminamos erros manuais e reduzimos o tempo em 60%.
  * **Contexto:** "To spearhead" é "liderar a fundo". Reduzir tempo com "%" demonstra que você tem cabeça de Tech Lead e acompanha KPIs.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso |
| :--- | :--- | :--- |
| **To design / architect** | Desenhar a arquitetura | "I **architected** the new VPC layout." |
| **To streamline** | Otimizar/Tornar mais fluido| "I **streamlined** the delivery process." |
| **To cut costs (by)** | Cortar/reduzir custos | "We **cut AWS costs by** 30%." |
| **To deploy / Provision** | Implantar e Criar Infra | "I **provisioned** the nodes via Terraform." |
| **To spearhead** | Liderar (ser ponta de lança)| "I **spearheaded** the Docker initiative." |

**5. MINI DIÁLOGO REAL**
*[Teams Call - Tech Interview]*
**Interviewer:** I see here on your resume that you migrated a major application to Kubernetes. Tell me a bit about the challenges you faced there.
*(Vejo que você migrou uma grande app para Kubernetes. Me fale dos desafios.)*

**You:** Sure. The biggest challenge was containerizing an old stateful monolithic app. I spearheaded the initiative to decouple the database from the app layer first. Once decoupled, I provisioned an EKS cluster with Terraform. It took 3 months, but we streamlined the releases and achieved true zero-downtime deployments.
*(Tirei o banco da camada da app... Streamlined as releases... Alcancei zero-downtime).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"I created an auto-scaling very big."**
✅ **"I implemented a robust auto-scaling solution."** (O adjetivo "robust" substitui o uso fútil de "very big").

❌ **"We spend less money."**
✅ **"We reduced the cloud costs"** ou **"We optimized the infrastructure spending."** (Inglês executivo chique!).

**7. EXERCÍCIO PRÁTICO**
Pense num problema recente do trampo resolvido por você. Traduza mentalmente a frase base: "Eu implementei o [Ferramenta], o que reduziu [Algum problema] do time."

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I streamlined the deployment process, which significantly cut our development time."**
*(Eu otimizei o processo de deploy, o que reduziu significativamente o tempo de dev).*

**9. PERGUNTA EXTENSÓRIA DE ENTREVISTA**
❓ **Pergunta:** *"Can you describe a time when an architectural choice you made failed?"*
✅ **Resposta modelo:** "Early in my career, I provisioned massive EC2 instances instead of setting up Auto-Scaling, trying to keep it 'simple'. Eventually, a traffic spike brought the server down. I learned the hard way that 'simple' doesn't mean 'resilient'. I immediately fixed it by implementing an ASG, and since then, high availability is always my baseline."
