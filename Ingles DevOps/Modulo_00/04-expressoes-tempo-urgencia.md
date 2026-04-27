# Módulo 0 — Sobrevivência no Primeiro Dia
## Aula 04: Expressões de tempo e urgência

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
O gerente de Produto quer saber quando a nova infraestrutura na AWS vai estar pronta. O banco de dados caiu e o diretor pergunta quanto tempo vai levar para o restore terminar. Na DevOps, tudo se resume a ETA (Estimated Time of Arrival) e priorização. Você precisa saber como passar prazos técnicos de forma precisa.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Você precisa ser capaz de prometer prazos ("Até amanhã", "No fim do dia", "Em 10 minutos"), classificar a urgência (Alta, Baixa) e informar quando algo será concluído, além de entender perfeitamente quando os gringos usam siglas como EOD e ETA.

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "I will finish this tomorrow."
  * **Tradução:** Eu vou terminar isso amanhã.
  * **Contexto:** Direto, mas soa pouco corporativo.

🟡 **INTERMEDIÁRIO** — Soa profissional
* "I should have this done by the end of the day."
  * **Tradução:** Eu devo ter isso pronto/feito até o final do dia.
  * **Contexto:** "By the end of the day" (muitas vezes abreviado como EOD) é o termo rei no mercado de TI nos Estados Unidos e Europa.

🔵 **AVANÇADO** — Soa nativo / Senior
* "This is a high-priority issue. Our ETA for a full recovery is roughly 30 minutes."
  * **Tradução:** Este é um problema de alta prioridade. Nosso tempo estimado para recuperação total é de mais ou menos 30 minutos.
  * **Contexto:** Super assertivo e calmo em meio a um incidente em produção. Usa os termos chave (ETA, roughly).

⚠️ **QUANDO NÃO USAR:**
Nunca use "As soon as possible" (ASAP) para o seu próprio chefe em uma estimativa de incidente, a não ser que você não faça a menor ideia de quanto tempo vai demorar. Dê um tempo aproximado (ETA).

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em frase real |
| :--- | :--- | :--- |
| **ETA (Estimated Time of Arrival)** | Prazo estimado de conclusão/chegada | "Do we have an **ETA** on the database restore?" |
| **EOD (End of Day)** | Fim do dia (expediente corporativo) | "I'll push the Terraform changes by **EOD**." |
| **By (tomorrow / Friday)** | ATÉ (tal momento) | "The cluster upgrade must be done **by** Friday." |
| **Shortly** | Em breve / Logo | "The API will be back up **shortly**." |
| **Roughly** | Aproximadamente | "It will take **roughly** 15 minutes to run the pipeline." |

**5. MINI DIÁLOGO REAL**
*[Slack thread - #incidents]*
**ProductManager:** Hey DevOps team, the payment gateway staging environment is down. Do we have an ETA for a fix?
*(Oi time de DevOps, o ambiente de staging do gateway de pagamentos caiu. Temos um prazo/ETA para a correção?)*

**You:** We've identified the issue. It was a misconfigured security group. We are fixing it right now.
*(Identificamos o problema. Foi um security group mal configurado. Estamos corrigindo isso agora mesmo.)*

**ProductManager:** Thanks! When do you expect it to be back online?
*(Obrigado! Quando você espera que volte a ficar online?)*

**You:** Our ETA is exactly 10 minutes. It should be fully operational shortly.
*(Nosso ETA é de exatamente 10 minutos. Deve estar totalmente operacional em breve.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"I will deliver this until Friday."** 
*(Até = Until, mas "until" define ação contínua. Para "prazo de entrega final", use "By").*
✅ **"I will deliver this by Friday."**

❌ **"In the end of the day..."** (O termo corporativo correto usa 'At' antes e não 'In').
✅ **"By EOD (End of Day)"** ou **"By the end of the day."**

❌ **"It will take more or less 20 minutes."** 
*(Soa muito literal, nativo de tech quase nunca fala mais ou menos assim).*
✅ **"It will take roughly 20 minutes." / "It will take about 20 minutes."**

**7. EXERCÍCIO PRÁTICO**
Escreva uma mensagem no Slack para o seu time informando que o script de migração falhou, você está investigando os logs agora e espera ter atualizações "até o final do dia" (use a sigla). 

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I'm working on it right now. I'll have an update for you by EOD."**
*(Estou trabalhando nisso agora mesmo. Terei uma atualização para você até o final do dia.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How do you handle multiple urgent tasks assigned to you at the same time?"*
✅ **Resposta modelo:**
"I evaluate the impact of each task on production. Critical incidents with actual downtime always get top priority. Then, I communicate clearly with my manager and stakeholders, providing realistic ETAs for each task. If I know a less urgent task will be delayed, I proactively say: 'I need to prioritize this production issue today, but I will deliver your request by tomorrow EOD'."
