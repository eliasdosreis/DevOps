# Módulo 6 — Entrevistas Técnicas em Inglês
## Aula 03: Perguntas comportamentais (Dominando o método STAR)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
A "Behavioral Interview" (Entrevista Comportamental) da Amazon, Google ou empresas da Europa é infame. Eles vão começar as frases com: "Tell me about a time..." (Me fale de uma vez que...). Se você responder no modo "bate-pronto" (Eu fiz assim e deu certo), o entrevistador joga sua nota técnica no lixo. É mundialmente obrigatório conhecer e responder na estrutura **S.T.A.R. (Situation, Task, Action, Result)**.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Você precisa encadear seus parágrafos em inglês: 
* **S**ituation (O Contexto do caos - O que estava caindo).
* **T**ask (Sua tarefa - O que você tinha que consertar).
* **A**ction (Sua ação técnica e comportamental).
* **R**esults (O Final Feliz com métricas reais).

**3. O MÉTODO NA PRÁTICA BÁSICO**
* **Situation:** "Last year, the production DB dropped during Black Friday."
* **Task:** "I needed to restore it fast."
* **Action:** "I used an automated script to rollback the backup."
* **Result:** "We lost 0 data."

**4. O MÉTODO NA PRÁTICA AVANÇADO / SENIOR (Use em Entrevistas)**
* **Situation (Contexto):** "In my previous role, we faced a critical situation right before a major product launch. The legacy deployment pipeline was failing intermittently, causing extreme stress to the Dev team." 
*(No trampo anterior, encaramops situação crítica antes do lançamento. O pipe velho falhava e causava estresse).*

* **Task (A Missão):** "My specific task was to stabilize the pipeline without delaying the launch date."
*(Minha tarefa era estabilizar o pipeline sem atrasar o lançamento).*

* **Action (A Mágica DevOps):** "I gathered the lead engineers to understand the friction points. I then rewrote the faulty Ansible playbooks from scratch over the weekend, containerized the build agents to ensure environment parity, and added parallel stages to speed it up."
*(Eu juntei os líderes pra entender; reescrevi os playbooks Ansible; dockerizei os agentes de build).*

* **Result (Métrica e Triunfo):** "As a result, we not only met the launch deadline, but the deployment failure rate went from 15% to 0%, and the build speed was increased by twofold. We had zero downtime on launch day."
*(Resultado: taxa de falha de 15% a 0%, velolocidade duplicou).*

**5. EXERCÍCIO COM SEUS VERBOS A CHAVE**
* **To face** - Encarar (I faced an issue)
* **To ensure** - Garantir (I containerized to ensure stability)
* **As a result...** - Como resultado...

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Ah, giving an example, one day my colleague drop the server and I help him."** (Péssimo storytelling. Destruiu a métrica).
✅ Se não lembrar da estrutura inteira, fale pelo menos o **R** (Resultado). Os recrutadores caçam números!

❌ **"We did...", "We fixed...", "We created..."**
✅ Nas entrevistas comportamentais, embora a cultura DevOps seja de "Nós", use a base no **"I"** (Eu) para o recrutador saber o que VOCÊ liderou pessoalmente. "I implemented", "I suggested". 

**7. FRASE PARA MEMORIZAR HOJE**
🗣️ **"My specific task was to stabilize the system. As a result, we achieved zero downtime."**
*(Minha missão específica era estabilizar. Como resultado, alcançamos zero-downtime).*

**8. PERGUNTA CLÁSSICA COMPORTAMENTAL DE ENTREVISTA**
❓ **Pergunta:** *"Tell me about a time you had to learn a completely new technology under pressure."*
✅ **Resposta modelo:**
"**(S)** When our company acquired a startup, their entire stack was on GCP, which was new to our AWS-only team. **(T)** I was tasked to migrate their DBs in 3 weeks. **(A)** I spent my evenings reading official GCP docs and executing sandboxed terraform runs to understand GCP IAM and networking. I scheduled 1:1s with the acquired devs to grasp the architecture. **(R)** As a result, I successfully migrated 100% of the workloads into our ecosystem within the deadline and completely bridged the knowledge gap for my team."
