# Módulo 3 — Incidentes e On-Call
## Aula 01: Como reportar uma falha em produção (The P0)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você está fazendo deploy na sexta à tarde ou acabou de ser acordado pelo PagerDuty às 3 da manhã. Os alarmes mostram 500 Server Errors subindo, os pings caíram e a base de dados não responde. Você é o *Incident Commander* (ou primeiro na linha). Você precisa mandar a mensagem crucial num canal da empresa como o `#war-room` para acionar a brigada de especialistas. O pânico na fala é inútil. Clareza técnica salva vidas (e o uptime).

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Em incidentes graves, o jargão domina. Você precisa informar O QUE quebrou, QUAL É o impacto, se você está investigando ou se precisa escalar (chamar) um Dev específico. Adjetivos desnecessários ("Oh meu Deus, deu ruim tudo") são trocados por verbos de ação eficientes ("The server is down. I'm investigating").

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente (o susto inicial)
* "Production is down. I am looking at it."
  * **Tradução:** Produção está caída/fora. Eu estou olhando isso.
  * **Contexto:** Prático, rápido. Mas "Produção" é ampla demais; de um sinal de fumaça onde exatamente é o incêndio.

🟡 **INTERMEDIÁRIO** — Soa profissional (Aviso clássico do PagerDuty)
* "Hey team, we're currently experiencing an outage on the payment gateway. I'm investigating the logs now."
  * **Tradução:** Oi time, estamos atualmente experienciando uma indisponibilidade no gateway de pagamentos. Estou investigando os logs agora.
  * **Contexto:** Relata que começou o incidente e comunica o ponto cirúrgico (payment gateway).

🔵 **AVANÇADO / COM ACIONAMENTO** — Soa nativo / Senior
* "CRITICAL: We're seeing a severe spike in 5xx errors across the EU region. Database CPU is maxed out. I'm declaring an incident. Could we get a Database Admin online immediately?"
  * **Tradução:** CRÍTICO: Estamos vendo um pico severo em erros 5xx através da região EU. A CPU do DB esgotou. Estou declarando um incidente. Podemos conseguir um Admin de Banco online imediatamente?
  * **Contexto:** Essa é a postura Sênior clássica de SRE: expõe a métrica (spike em 5xx), o local (EU region), a causa visual (DB CPU maxed out) e o comando de pedir ajuda específica (Database Admin online).

⚠️ **QUANDO NÃO USAR:**
Nunca use palavras como "P0", "CRITICAL" ou "@here/everyone" se a queda for leve num ambiente de staging (teste). Um alarme falso em produção desgasta a saúde mental dos on-call (fatigue alarm).

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no Slack |
| :--- | :--- | :--- |
| **Outage** | Queda/Indisponibilidade grave | "We had a major **outage** today." |
| **To be down** | Estar fora do ar | "The primary server is **down**." |
| **Spike** | Pico (de erros, tráfego, CPU) | "There is a massive **spike** in latency." |
| **To declare an incident** | Abrir sala de crise oficialmente | "I'm **declaring an incident** in PagerDuty." |
| **To page / to ping someone**| Acionar rapidamente (via celular/msg)| "Can someone **page** the billing team?" |

**5. MINI DIÁLOGO REAL**
*[Slack Channel - #production-alerts]*
**You:** @here Heads-up: We're experiencing a major outage. The main website is returning 502 Bad Gateway errors. I'm looking into the ingress controllers now.
*(Aviso: Estamos experienciando uma queda grave. O site resp. erros 502. Investigando os ingress controllers).*

**TechLead:** Acknowledged. Do you need an extra pair of eyes?
*(Reconhecido / Ciente. Você precisa de um par a mais de olhos [alguém para ajudar]?)*

**You:** Yes. Could you ping the network team? Traffic is not reaching the cluster pods at all.
*(Sim. Pode chamar [ping] o time de redes? O tráfego não está chegando de jeito nenhum nos pods).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"The system is offline."** (Pode soar como se estivesse desligado de propósito).
✅ **"The system is down"** ou **"We have an outage."** (Indica queda).

❌ **"The CPU is 100% full."** 
✅ **"The CPU is maxed out"** ou **"The CPU is spiking."** (Termos nativos do ambiente Linux/Métricas).

❌ **"I will call the backend team."** 
✅ **"I'll page the backend team."** (No On-Call, a gente "page" e não "liga").

**7. EXERCÍCIO PRÁTICO**
A métrica do servidor de cache (Redis) atingiu 100% de uso de memória e a aplicação caiu de "costas". Imagine digitando no canal "Alertas": Reporte o "pico" de memória, avise que o sistema está "down" e que você está investigando agora.

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"We're experiencing an outage on the main server. I'm investigating the logs right now."**
*(Estamos tendo uma indisponibilidade no server princ., investigando os logs agora.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Walk me through the first 5 minutes of your response when a critical P0 incident drops."*
✅ **Resposta modelo:**
"In the first 5 minutes, my priority is communication and triage. First, I acknowledge the alert in PagerDuty. Then, I drop a message in the war room channel saying 'I'm experiencing an outage and investigating the dashboard'. Once I confirm it's a real P0 affecting users, I'll page the necessary tech leads to join a live Zoom bridge. Lastly, I focus on mitigating the impact, not perfectly solving the issue immediately."
