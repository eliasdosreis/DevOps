# Módulo 1 — Daily Standup e Reuniões
## Aula 03: Como concordar, discordar e dar feedback em inglês

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você está em uma sessão de "Post-Mortem" após uma queda em produção. Um colega propõe usar uma versão recém-lançada de um Message Broker alternativo no lugar do Kafka para "economizar". Você **discorda** veementemente, porque não há documentação estável dessa ferramenta, e você quer argumentar a favor do serviço gerenciado (MSK) da nuvem, mas sem soar prepotente.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Dar feedbacks ou discordar frontalmente de um colega são momentos onde o não-nativo corre o risco de ofender ou parecer agressivo por usar traduções diretas e secas (ex: "I disagree. It is bad."). Aprender a discordar de forma corporativa e polida constata o seu peso de "Senior Engineer".

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "I agree with you." / "I don't think that is a good idea."
  * **Tradução:** Eu concordo com você. / Eu não acho que essa é uma boa ideia.
  * **Contexto:** É aceitável, mas pode soar afiado ("too blunt").

🟡 **INTERMEDIÁRIO** — Soa profissional (Feedback construtivo)
* "I see your point, but I'm a bit concerned about the documentation for this new tool."
  * **Tradução:** Eu vejo/entendo o seu ponto, mas eu estou um pouco preocupado sobre a documentação dessa nova ferramenta.
  * **Contexto:** "I see your point, but..." é o coringa número um no mundo corporativo estrangeiro. Ele valida a outra pessoa antes de atacá-la.

🔵 **AVANÇADO** — Soa nativo / Senior
* "That's a fair point, however, considering the production risks, I'd strongly suggest we stick with the managed service rather than gambling on a new tool."
  * **Tradução:** Esse é um ponto justo, contudo, considerando os riscos de produção, eu fortemente sugeriria mantermos o serviço gerenciado em vez de apostarmos ("dar uma de jogador") numa nova ferramenta.
  * **Contexto:** Diplomaticamente massacrante. Mostra um alto grau de domínio do idioma e do cenário arquitetural.

⚠️ **QUANDO NÃO USAR:**
Se a pessoa falou um absurdo gritante de segurança (ex: abrir porta 22 para 0.0.0.0), você não precisa usar de diplomacia excessiva ("I see your point"). Você pode subir o tom e usar: **"I strongly advise against this from a security perspective."** (Aconselho fortemente contra isso...).

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em frase real |
| :--- | :--- | :--- |
| **I see your point** | Eu entendo seu raciocínio | "**I see your point**, but it's expensive." |
| **To be concerned about** | Estar preocupado com algo | "I'm **concerned about** the memory limits." |
| **To stick with (something)** | Manter / Continuar com | "Let's **stick with** Kubernetes 1.25 for now." |
| **A fair point / Fair enough**| Um argumento válido / Justo | "You said the SLA is 99%, **fair enough**." |
| **To advise against** | Aconselhar não fazer | "I **advise against** hardcoding passwords." |

**5. MINI DIÁLOGO REAL**
*[Teams Call - Tooling Discussion]*
**Dev:** Since Docker Desktop is paid now, we should all switch to this new obscure tool I found on GitHub.
*(Já que o Docker Desktop agora é pago, todos nós deveríamos trocar para esta nova ferramenta obscura que achei no GitHub).*

**You:** I see your point regarding the cost, but I'm concerned about the community support.
*(Eu entendo o seu ponto em relação ao custo, mas me preocupo com o suporte da comunidade.)*

**You:** I'd suggest we look into Rancher Desktop instead. It's stable.
*(Eu sugeriria darmos uma olhada no Rancher Desktop em vez disso. Ele é estável.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"I am agree."** / **"I am disagree."** (Verbo concorda não existe dessa forma com To Be).
✅ **"I agree."** / **"I disagree."**

❌ **"You are wrong."** (Um tiro de bazuca corporativo).
✅ **"I think there might be an issue with that approach."** (Eu acho que pode haver um problema com essa abordagem).

❌ **"I don't like this code."**
✅ **"I have some concerns regarding this code."** (Eu tenho algumas preocupações/receios...).

**7. EXERCÍCIO PRÁTICO**
Alguém do seu time disse que testar o Terraform antes de aplicar é 'perda de tempo' (Waste of time) em ambientes de Dev. Usando o coringa da aula ("I see your point..."), construa uma frase discordando e dizendo que a infra deve ser segura (secure) sempre.

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I see your point, but I have a few concerns regarding the security."**
*(Entendo seu raciocínio, mas tenho algumas preocupações a respeito da segurança.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Describe a time when you disagreed with a colleague or lead about a technical implementation. How did you handle it?"*
✅ **Resposta modelo:**
"In a past project, my lead wanted to use a raw EC2 approach to save time, but I knew containerizing the app via ECS would allow automated scaling and lower maintenance. Instead of simply saying 'no', I gathered the metrics, set up a meeting, and said: 'I see your point about time to market, but considering long-term scalability, I strongly recommend using containers'. Once I showed the data, they completely agreed with my feedback, and the deployment went smoothly."
