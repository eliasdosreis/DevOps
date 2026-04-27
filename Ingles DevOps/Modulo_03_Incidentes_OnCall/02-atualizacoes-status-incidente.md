# Módulo 3 — Incidentes e On-Call
## Aula 02: Atualizações de status durante incidente (Status Updates)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
O caos está sob controle, mas a diretoria está suando frio. Você está num Zoom (War Room) com os diretores escutando sua respiração enquanto você digita no terminal, ou tem 50 pessoas olhando a *thread* no Slack da queda da AWS aguardando notícias em tempo real. O "Incident Commander" deve dar atualizações regulares (geralmente a cada 15 ou 30 minutos).

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Uma "Status Update" precisa ser rítmica e acalmar os ânimos. Você usará expressões como "Estamos testando um fix" (testando a cura), "Sem mais atualizações", ou o famoso tempo de progresso esperado (ETA). Silenciar durante uma crise é mais assustador do que o log do erro em vermelho.

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "Update: We are still checking the problem. No solution yet."
  * **Tradução:** Status / Atualização: Nós ainda estamos checando o problema. Nenhuma solução ainda.
  * **Contexto:** Honesto, mas passa a sensação de que a equipe está num buraco sem ferramentas.

🟡 **INTERMEDIÁRIO** — Soa profissional (Bom para a Thread a cada 15min)
* "Status Update: The team is currently testing a fix in the staging environment. We will update again in 15 minutes."
  * **Tradução:** Atualização de Status: O time está atualmente testando um conserto no ambiente de staging. Iremos atualizar novamente em 15 minutos.
  * **Contexto:** Tranquiliza a diretoria, indica progresso e dá um prazo real para que parem de fazer perguntas nos próximos 15 minutos.

🔵 **AVANÇADO / COM AVALIAÇÃO DE IMPACTO** — Soa nativo / Senior
* "Quick update: We've identified the bottleneck in the database cluster. We're rolling back the recent migration. ETA for full recovery is 10 minutes. Will keep everyone posted."
  * **Tradução:** Atualização rápida: Identificamos o gargalo no cluster do DB. Estamos revertendo a migração recente. Tempo estimado para rec. total é 10min. Manterei todos informados.
  * **Contexto:** Absoluta perfeição. Usar "identified the bottleneck" (identificamos o gargalo) é lindo tecnicamente, e a promessa "Will keep everyone posted" sela o controle e a senioridade.

⚠️ **QUANDO NÃO USAR:**
Nunca minta dando um "ETA: 2 minutes" puramente para fazer o CEO desligar a câmera no Zoom. O ETA (Estimated Time of Arrival - em português prazo / tempo estimado) é uma promessa forte. Se não sabe, fale "Ainda não temos ETA claro."

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no Slack |
| :--- | :--- | :--- |
| **Bottleneck** | Gargalo de sistema ou tráfego | "The CPU is the main **bottleneck** here." |
| **To keep (you) posted** | Manter-se atualizado/informar | "I will **keep you posted** on the progress." |
| **A fix / To deploy a fix** | Um conserto técnico / deploy curativo | "We are testing a **fix** locally." |
| **Still ongoing / Active** | Ainda ocorrendo (o problema) | "The incident is **still ongoing**." |
| **To roll back** | Reverter a alteração | "We had to **roll back** to the old version." |

**5. MINI DIÁLOGO REAL**
*[War Room - Zoom Call de Crise]*
**Manager:** Elias, it's been 15 minutes since the last update. Do we know what's going on with the API?
*(Elias, fazem 15 minutos desde a última att. Sabemos o que está rolando com a API?)*

**You:** Yes, quick update: we've identified the bottleneck in the Redis cache. We're scaling up the instances now.
*(Sim, att rápida: identificamos o gargalo no Redis. Estamos escalando [aumentando] as instâncias agora.)*

**Manager:** Good. Do we have an ETA for resolution?
*(Bom. Temos um prazo/ETA para resolução?)*

**You:** Once it finishes provisioning, it should take about 5 minutes. I'll keep you posted.
*(Assim que terminar de provisionar, deve levar uns 5 minutos. Vou manter vocês informados.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"I will maintain you informed."** (Tradução robótica do PT para o EN).
✅ **"I'll keep you posted."** ou **"I'll keep you updated."** 

❌ **"We achieved the problem."** ('Achieve' é conquistar/alcançar objetivo, não é achar!).
✅ **"We found the problem."** ou melhor: **"We've grouped/identified the root cause."**

❌ **"The fix is testing."** (Soa como se o conserto tivesse as duas mãos para se autotestar).
✅ **"We are testing a fix."** 

**7. EXERCÍCIO PRÁTICO**
Pratique dizer em voz alta as duas sentenças mais sagradas da administração de crise: "Estou testando o conserto agora. Lhe manterei informado." (I am testing...) e (I'll keep you...).

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"Status update: we are currently testing a fix. I'll keep you posted."**
*(Atualização: estamos devidamente testando um fix. Eu manterei vocês informados.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How do you handle management and stakeholders continuously asking for updates during a critical outage?"*
✅ **Resposta modelo:**
"I am very proactive to prevent that stress. At the beginning of a critical incident, I establish an update cadence, like: 'I will post updates in this channel every 15 minutes'. Then, I provide clear, concise status updates: what failed, the current mitigation steps, and if possible, a realistic ETA. Keeping everyone posted prevents them from distracting the engineers actively fixing the problem."
