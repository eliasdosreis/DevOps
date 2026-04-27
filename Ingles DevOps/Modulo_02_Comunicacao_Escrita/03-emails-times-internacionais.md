# Módulo 2 — Comunicação Escrita (Slack, E-mail, Tickets)
## Aula 03: E-mails profissionais para times internacionais

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
A cultura do Vale do Silício e das grandes *techs* prioriza a comunicação assíncrona. E-mails são usados para anúncios oficiais corporativos, negociação de orçamentos (budget) da AWS, agendamento de janelas de manutenção (Downtime Windows) com clientes e notificações entre departamentos diferentes. Se o e-mail não for claro ou soar desrespeitoso, pode causar desconfortos diplomáticos sérios.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Um DevOps não escreve e-mails prolixos (longos). Você deve apresentar o problema logo no primeiro parágrafo, usar "bullet points" para listar o que ocorreu e o que precisa ser feito, e finalizar com os próximos passos educadamente. Aprenda a trocar expressões engessadas ("Dear Sir") por tons mais adequados da TI ("Hi team / Hi Sarah").

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "Hi. We need to do maintenance on Sunday. The server will be offline."
  * **Tradução:** Oi. Precisamos fazer manutenção no Domingo. O servidor vai ficar offline.
  * **Contexto:** Prático, mas direto e rude caso seja enviado para um cliente ou diretor.

🟡 **INTERMEDIÁRIO** — Soa profissional (Aviso de manutenção)
* "Hi Team, this is just to inform you that we have a scheduled maintenance this Sunday. Expect about 2 hours of downtime."
  * **Tradução:** Oi time, isso é apenas para informá-los que teremos uma manutenção agendada neste domingo. Esperem cerca de 2 horas de indisponibilidade (downtime).
  * **Contexto:** A expressão "Please expect..." (Por favor aguardem/esperem) prepara a mente das pessoas sem parecer uma ordem agressiva.

🔵 **AVANÇADO** — Soa nativo / Senior
* "Hi everyone, I'm reaching out to inform you regarding a planned infrastructure upgrade on Sunday at 2 AM EST. Please let me know if you have any concerns regarding this window."
  * **Tradução:** Oi pessoal, estou entrando em contato para informá-los a respeito de um upgrade planejado de infraestrutura no domingo às 2 da manhã EST. Por favor me avisem se houver qualquer ressalva/preocupação em relação a essa janela.
  * **Contexto:** O verbo "reach out" é chique, maduro, elegante e amigável para emails diretos a outros setores. O final dele abre as portas para diálogo sem ser autoritário.

⚠️ **QUANDO NÃO USAR:**
Nunca coloque "URGENT" gritando (Caps Lock) no Assunto (Subject) do e-mail. Se for realmente crítico, você não deve usar e-mail, deve acionar a pessoa por PagerDuty, WhatsApp corporativo, ou Slack Tag geral.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em e-mail |
| :--- | :--- | :--- |
| **To reach out (to someone)**| Contatar (alguém) / Entrar em contato | "I am **reaching out** to request access." |
| **Regarding** | A respeito de / Referente a | "I have a question **regarding** the EC2 instances." |
| **Downtime / Outage** | Tempo de inatividade / Queda | "We experienced a 10-minute **downtime**." |
| **Maintenance window** | Janela de manutenção | "The **maintenance window** lasts 3 hours." |
| **Please let me know** | Por favor, me avise | "**Please let me know** if you need anything." |

**5. MINI DIÁLOGO REAL**
*[E-mail real corporativo]*
**Subject:** Planned Maintenance Window - Production Database - Aug 15th
*(Assunto: Janela de Manutenção Planejada - Banco Prod - 15 de Ago)*

**Hi team,**
I am reaching out to inform you that we will be upgrading the RDS instance to a new tier this Saturday, August 15th, from 1:00 AM to 3:00 AM EST.
*(Oi time, estou contatando vocês para informar que daremos update na instância RDS para uma nova classe neste sábado...)*

**Impact:** The purchasing API will experience a brief downtime of roughly 15 minutes during the switchover. 
*(Impacto: A API de compras passará por um breve downtime de mais ou menos 15 min durante a virada.)*

**Action Required:** No action is required on your part. Please let me know if there are any conflicts with your weekend deployments.
*(Ação exigida: Sem ação exigida da parte de vocês. Me avisem caso haja conflito com seus deploys de FDS).*

**Best regards, Elias.**

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Dear Sirs / Dear Mr."** (Muito corporativo do século passado para startups tech).
✅ **"Hi Team," / "Hi everyone," / "Hi Sarah,"**

❌ **"Any doubt, tell me."** (A maldição da palavra 'doubt' novamente).
✅ **"If you have any questions, let me know."**

❌ **"Att," ou "Atenciosamente,"** (Abreviações BR em e-mail).
✅ **"Best regards," / "Best," / "Thanks,"**

**7. EXERCÍCIO PRÁTICO**
Escreva (mentalmente ou numa nota) a linha final de um e-mail. Construa a frase com o clássico da aula de encerramento corporativo: "Por favor, me avise (Let me...) se você tiver qualquer dúvida. Atenciosamente (Best...), Seu Nome".

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I am reaching out regarding the scheduled maintenance. Please let me know if you have any questions."**
*(Estou entrando em contato referente a manutenção agendada. Me avise se tiver dúvidas.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"In a DevOps role, a lot of communication is asynchronous. How do you ensure your emails or written announcements are clearly understood by non-technical teams?"*
✅ **Resposta modelo:**
"I always use a clear subject line and break my emails down with bullet points. I clearly define the 'Context', the 'Impact' (using business terms, not just technical jargon), and a clear section for 'Action Required' from the readers. I finish by saying 'Please let me know if you have any questions', encouraging them to clarify anything they didn't fully grasp."
