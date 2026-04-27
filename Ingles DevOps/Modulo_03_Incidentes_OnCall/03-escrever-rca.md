# Módulo 3 — Incidentes e On-Call
## Aula 03: Como escrever o RCA técnico avançado e Prevenções

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
A fase do Post-Mortem onde a gente explica "The Root Cause Analysis (RCA)" não diz apenas que "algo falhou" (Aula 4 Modulo 2). Agora você submeteu o seu doc à engenharia Sênior/Staff dos EUA, e você precisa explicar tecnicamente detalhes de infraestrutura aprofundados. O seu inglês precisa brilhar usando causa e consequência. ("We did X, which resulted in Y").

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Como conectar fatos num RCA avançado? Você usa palavras fundamentais de conexão e fluxo cronológico em inglês como: *due to* (devido a), *led to* (levou a), *which triggered* (o que disparou), e *preventive measures* (medidas preventivas). O seu inglês não será só frase curta aqui. Exigirá relatar uma sequência lógica de quedas estruturais (O que nós chamamos no DevOps de "Cascading Failure").

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Simples causa e efeito
* "The server restarted because memory was high."
  * **Tradução:** O servidor reiniciou porque a memória estava alta.
  * **Contexto:** Verdade, mas falta robustez técnica.

🟡 **INTERMEDIÁRIO** — Flow natural corporativo
* "The incident occurred due to an unexpected memory spike, which triggered an Out-of-Memory (OOM) kill on the primary pod."
  * **Tradução:** O incidente ocorreu devido a um inesperado pico de memória, a qual disparou a morte (kill) por Falta-de-Memória no pod primário.
  * **Contexto:** A palavra "triggered" (disparar engrenagem / acionar erro) é seu vocabulário base de falhas na nuvem.

🔵 **AVANÇADO / STAFF ENGINEER LEVEL** — Causa e consequência densa
* "The root cause was a cascading failure initiated by a bottleneck in the load balancer, leading to severe latency and subsequent connection timeouts. To prevent recurrence, we will adjust the auto-scaling thresholds."
  * **Tradução:** A causa raiz foi uma falha em cascata iniciada por um gargalo no balanceador de carga, originando/levando a uma latência severa e subsequentes timeouts de conexão. Para prevenir recorrência, iremos ajustar os limiares (limites engatilhados) do auto-scaling.
  * **Contexto:** Essa é uma frase de ouro que você colaria debaixo de um Confluence Document que ganha o aplauso calmo até do CEO.

⚠️ **QUANDO NÃO USAR:**
Nunca faça um RCA baseado em advinhação. Se não tem evidência, não escreva. Se for uma hipótese, use: "We suspect the issue was triggered by..." e não tente forjar fatos usando jargão difícil.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no RCA |
| :--- | :--- | :--- |
| **Cascading failure** | Falha em cascata | "The timeout caused a **cascading failure**." |
| **Which triggered** | O qual acionou/disparou | "Cpu reached 100%, **which triggered** the reboot." |
| **Due to** | Devido a | "It failed **due to** a network partition." |
| **Threshold** | Limite/Limiar (de auto-scaling, etc)| "Memory hit the upper **threshold**." |
| **To prevent recurrence** | Prevenir voltar a acontecer | "**To prevent recurrence**, we added automated tests." |

**5. MINI DIÁLOGO REAL**
*[Slack thread - Discutindo Documento com o Gerente]*
**Manager:** Elias, I read the RCA draft. What exactly triggered the pod termination?
*(Elias, li o rascunho. O que exatamente disparou a morte daquele pod?)*

**You:** It happened due to an unhandled exception in the code, which triggered a memory leak.
*(Aconteceu devido a uma exceção não-tratada no código, que disparou vazamento de memória.)*

**Manager:** Understood. What are the preventive measures?
*(Entendido. Quais as medidas de prevenção?)*

**You:** To prevent recurrence, we are setting memory thresholds lower, so it scales out before crashing.
*(Para prevenir que volte, rebaixaremos os thresholds de mem., para ele escalar/multiplicar antes de morrer.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Because of that..."** (Apesar de ok verbalmente, num RCA escrito soa informal e primário).
✅ **"Consequently,..."** ou **"Which led to..."** (O qual levou a...)

❌ **"To don't happen again..."** (Gramática severamente errada 'To don't...').
✅ **"To prevent recurrence..."** ou **"To avoid future occurrences..."**

❌ **"Fail in cascade."**
✅ **"Cascading failure."** (Sempre!).

**7. EXERCÍCIO PRÁTICO**
Sua vez de atuar de forma sênior. Responda mentalmente o RCA do por que o site caiu sexta-feira. 
Use: "The issue occurred DUE TO a bad configuration, WHICH TRIGGERED a cascading failure."

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"The failure happened due to a CPU spike, which triggered a server restart."**
*(A falha ocorreu devido a um pico de CPU, o que engatilhou um pulo de servidor.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Give me an example of an RCA you investigated. How did you explain the Root Cause and what was the preventive measure?"*
✅ **Resposta modelo:**
"In a recent incident, the cluster went down 'due to' an aggressive traffic spike 'which triggered' out-of-memory errors on all nodes. It was a classic cascading failure. When writing the RCA, I explained the technical bottleneck without blaming anyone. 'To prevent recurrence', I added an action item to refine our Horizontal Pod Autoscaler thresholds so the cluster reacts much earlier to traffic bursts."
