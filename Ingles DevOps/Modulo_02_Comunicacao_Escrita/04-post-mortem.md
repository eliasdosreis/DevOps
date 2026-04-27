# Módulo 2 — Comunicação Escrita (Slack, E-mail, Tickets)
## Aula 04: Como escrever um post-mortem (RCA Inicial) em inglês

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
O caos em produção (P0 Incident) terminou. Os sistemas voltaram a ficar "verdes". Você suspirou aliviado, mas o trabalho do SRE/DevOps não acabou. A diretoria quer entender exatamente *por que* o sistema caiu, *como* você o reviveu e o que fará para que isso *nunca mais ocorra*. Isso vem num documento que chamamos de Post-Mortem (ou RCA Inicial).

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Uma cultura saudável de DevOps não aponta o dedo ("O João quebrou o servidor"), conhecemos isso como "Blameless Culture". Você usará o tempo passado (Past Simple) para relatar os fatos de forma objetiva, explicar a causa-raiz (root cause) e listar "Action Items" (tarefas de prevenção).

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender (mas pobre em detalhes)
* "The server crashed because the memory was full. We restarted the server. We will increase the memory."
  * **Tradução:** O servidor crashou porque a memória estava cheia. Reiniciamos o servidor. Aumentaremos a memória.
  * **Contexto:** Relata os fatos, mas o vocabulário é infantil e não analisa a causa real do porquê encheu.

🟡 **INTERMEDIÁRIO** — Soa profissional (Bom para a introdução do doc)
* "The outage was caused by a memory leak in the API. We mitigated the issue by rolling back to the previous version."
  * **Tradução:** A indisponibilidade foi causada por um vazamento de memória na API. Nós mitigamos/aliviamos o problema revertendo (rolling back) para a versão anterior.
  * **Contexto:** Claro, profissional, foca no problema (memory leak) e na mitigação exata.

🔵 **AVANÇADO** — Soa nativo / Senior
* "Root Cause Analysis: A misconfigured pod disruption budget led to node starvation. As an action item, we will implement stricter resource limits and enhance the Datadog alerts."
  * **Tradução:** Análise de Causa Raiz: Um PDB mal-configurado levou à inanição (falta de recursos) do nó. Como um item de ação, implementaremos limites rígidos de recursos e melhoraremos os alertas do Datadog.
  * **Contexto:** Vocabulário sênior com palavras cruciais como "misconfigured" e "mitigated". Extremamente corporativo.

⚠️ **QUANDO NÃO USAR:**
Nunca escreva um Post-Mortem usando a pessoa como causa: "The issue happened because Marcos deployed bad code". Isso é tóxico. Escreva sem nomear culpados: "The issue occurred due to a bug in the recent deployment" ou "A test coverage gap allowed bad code to reach production".

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no Post-Mortem |
| :--- | :--- | :--- |
| **Root Cause** | Causa raiz (verdadeiro motivo) | "The **root cause** was a DNS resolution failure." |
| **To mitigate** | Mitigar (reduzir impacto / conserto primário) | "We **mitigated** the issue by scaling up." |
| **Outage / Incident** | Indisponibilidade longa | "The **outage** lasted for 45 minutes." |
| **Action Items** | Tarefas decorrentes de um evento | "**Action items:** Update the Terraform module." |
| **Misconfigured** | Mal configurado | "A **misconfigured** firewall blocked the traffic." |

**5. MINI DIÁLOGO REAL**
*[Post-Mortem Doc Template / Confluence]*
**Incident Summary:** At 2:00 PM, the login service experienced an outage affecting 15% of users. 
*(Resumo: Às 14h, o serv. de login sofreu uma queda afetando 15% dos usuários).*

**Root Cause:** The database connection pool was misconfigured, leading to connection timeouts.
*(Causa raiz: O connection pool do DB estava mal configurado, levando a esgotamento de conexões).*

**Mitigation:** We temporarily increased the max connection limit and restarted the pods.
*(Mitigação: Aumentamos temporariamente o lim. de conexões e reiniciamos os pods).*

**Action Items:** 
- Implement connection limits at the code level. (Assigned to Backend team).

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"The system failed because the Dev team made a mistake."** (Cultura tóxica/Blaming).
✅ **"The system failed due to a gap in the validation tests."** (Cultura Blameless, ataque o processo e não a pessoa).

❌ **"We resolved the issue."** (Você aliviou o erro, mas o fix permanente nem foi feito ainda).
✅ **"We mitigated the issue."** (Muito mais usado na engenharia. 'Resolve' significa que o problema nunca mais voltará no código).

❌ **"Tasks to do"**
✅ **"Action Items"** (Termo absoluto da indústria para os próximos passos).

**7. EXERCÍCIO PRÁTICO**
Pense mentalmente ou rascunhe: Qual foi o 'Root Cause' do último incidente grave que você viveu no trabalho? Use a estrutura "The root cause was [o que aconteceu]" em vez de culpar quem quer que tenha cometido o erro.

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"We mitigated the issue by rolling back the deployment. The root cause is still under investigation."**
*(Nós mitigamos o problema com rollback do deploy. A causa raiz segue em investigação.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Are you familiar with the concept of a blameless post-mortem? How do you write one?"*
✅ **Resposta modelo:**
"Yes, absolutely. A blameless post-mortem focuses on systems and processes, not individuals. When I write one, I structure it clearly: First, the timeline of the incident. Second, the 'Root Cause', explaining the technical trigger (like a misconfigured router). Third, how we 'Mitigated' the issue. And finally, the 'Action Items', detailing how we'll automate safeguards so that human error cannot break the system in the exact same way again."
