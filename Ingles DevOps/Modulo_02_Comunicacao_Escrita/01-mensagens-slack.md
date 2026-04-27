# Módulo 2 — Comunicação Escrita (Slack, E-mail, Tickets)
## Aula 01: Mensagens de Slack (Profissionais vs Informais)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
O Slack (ou Teams) é a principal ferramenta do DevOps. Uma mensagem pública em um canal como `#deployments` exige clareza e um tom um pouco mais profissional, enquanto uma DM (Direct Message) para um parceiro de código permite mais informalidade e abreviações. Você precisa equilibrar o uso do inglês escrito e jamais dizer apenas "Hi" e sumir.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Em canais públicos, comunique a ação, o estado e o responsável de forma concisa. Nas mensagens diretas (DMs), você pode ser mais dinâmico. A regra de ouro no Slack americano é: "No hello syndrome". Ou seja, nunca mande "Oi" e espere a pessoa responder para você dizer o problema. Mande o problema inteiro na primeira mensagem.

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "Hey team. The pipeline is broken. I will fix it."
  * **Tradução:** Oi time. O pipeline está quebrado. Eu vou consertar.
  * **Contexto:** Prático, mas muito "robótico" em inglês.

🟡 **INTERMEDIÁRIO** — Soa profissional (Bom para canais)
* "Hey everyone, just a quick heads-up: the deployment pipeline failed. I'm looking into it now."
  * **Tradução:** Oi pessoal, apenas um aviso rápido: o pipeline de deploy falhou. Estou verificando/investigando isso agora.
  * **Contexto:** "Heads-up" (aviso/alerta) é indispensável. A frase é proativa ("looking into it").

🔵 **AVANÇADO / INFORMAL** — Soa nativo / Senior (Bom para DMs)
* "Hey Mark, got a sec? Staging is acting up. Could you DM me when you're free?"
  * **Tradução:** Fala Mark, tem um segundo? O ambiente de staging está esquisito/dando pau. Pode me mandar DM (mensagem) quando estiver livre?
  * **Contexto:** Dinâmico. O uso de "acting up" para um servidor instável é muito nativo.

⚠️ **QUANDO NÃO USAR:**
Nunca misture gírias super informais de internet (ex: "lmao", "bro") num canal `#production-incidents` com o CEO lendo.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em frase real |
| :--- | :--- | :--- |
| **Heads-up** | Aviso prévio / Alerta rápido | "Just a quick **heads-up** about the downtime." |
| **To look into (it)** | Investigar / Verificar | "The server is slow. I'll **look into** it." |
| **A sec (A second)** | Um momento rápido | "Hey, got **a sec** to check this PR?" |
| **To act up** | Agir estranho / Apresentar falha | "The database is **acting up** again." |
| **DM (Direct Message)**| Mensagem direta | "Send me a **DM** with the IP address." |

**5. MINI DIÁLOGO REAL**
*[Slack DM]*
**You:** Hey Sarah, got a sec? The Terraform plan is failing with a 403 error on S3. Any ideas?
*(Oi Sarah, tem um segundinho? O terraform plan está falhando com erro 403 no S3. Alguma ideia?)*

**Sarah:** Hey! Yeah, I changed the IAM role yesterday. Let me check the policies. Give me a minute.
*(Oi! Sim, eu mudei a IAM role ontem. Deixa eu checar as políticas. Me dá 1 minuto.)*

**You:** Awesome, thanks. Let me know when it's fixed so I can trigger the pipeline again.
*(Incrível, obrigado. Me avisa quando estiver consertado para eu disparar o pipeline de novo.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Hello Mark."** (E desaparece esperando o Mark responder "Hi").
✅ **"Hey Mark, the database is down, can you help?"** (Evite a Hello Syndrome. Mande o contexto de uma vez).

❌ **"I am verifying this."** (Muito formal para o Slack).
✅ **"I'm looking into it."** ou **"I'm checking it."**

❌ **"Can we talk fast?"** (Soa autoritário e mal traduzido).
✅ **"Got a sec for a quick call?"** (Tem um segundo para uma call rápida?).

**7. EXERCÍCIO PRÁTICO**
Mande uma DM simulada para a "Emma" avisando: "Oi Emma. Só um aviso rápido: eu vou reiniciar as instâncias EC2, então você pode perder conexão por alguns minutos".

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"Hey team, quick heads-up: I'm looking into the issue and will keep you posted."**
*(Oi time, aviso rápido: estou verificando o problema e manterei vocês informados.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How do you keep your communication effective when working fully remote across different time zones?"*
✅ **Resposta modelo:**
"I rely heavily on async communication and avoid the 'hello syndrome'. When I message a colleague on Slack, I send the full context, the error logs, and what I need from them in a single message. This way, when they wake up in their time zone, they have everything they need to unblock me without the back-and-forth of simply saying 'hi'."
