# Módulo 3 — Incidentes e On-Call
## Aula 04: Comunicar impacto para stakeholders não-técnicos

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Seu diretor de vendas (Stakeholder/Business level) notou que transações caíram. Você ativou a sala de crise. Ele entra na call de camisa social suando frio e pergunta: "O banco de dados quebrou? Perdemos faturas? Por que não vendemos nada pela AWS?". Você não pode responder com uma tela preta cheia de "Regex Syntax Error on DynamoDB Partition key threshold". Você precisa traduzir jargão duro de nuvem para a linguagem que importa para gerência de negócios: Risco de dados, usuários afetados e prazo para voltar a faturar.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Uma comunicação de DevOps sênior voltada a executivos tem a chamada Regra B.I.A (Business Impact Analysis). O que deve ser dito: 
1. Estão afetados X% dos clientes. 
2. Os dados de cartão e banco continuam íntegros! (Security and Data Loss Zero). 
3. Estamos resolvendo. 

A empatia é vital com frases como "We understand the urgency" (nós entendemos a urgência).

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Simples causa e efeito
* "The system has an error. Users cannot buy anything right now."
  * **Tradução:** O sistema tem um erro. Usuários não podem comprar nada agora.
  * **Contexto:** Honesto, mas gela a espinha do empresário. Não diz o grau e a segurança.

🟡 **INTERMEDIÁRIO** — Soa profissional
* "Currently, our payment system is down, impacting all live transactions. Our engineering team is fully prioritizing this recovery."
  * **Tradução:** Atualmente, nosso sistema de pagamentos está fora, impactando todas as transações ao vivo. Nossa engenharia está totalmente priorizando esta recuperação.
  * **Contexto:** Excelente. Usa termos com peso executivo: "impacting live transactions", "fully prioritizing recovery". 

🔵 **AVANÇADO / STAFF ENGINEER LEVEL** — Comunicação B.I.A. de risco Zero
* "To clarify the scope, this outage only affects new checkout sessions; existing user data and payments remain completely secure. We are spinning up backup servers now."
  * **Tradução:** Para clarificar o impacto (escopo), essa queda afeta apenas novas sessões de checkout/carrinho; os dados de usuário existentes e pagamentos continuam completamente seguros. Estamos levantando servidores de backup agora.
  * **Contexto:** Sensacional. O SRE resolveu a pauta mais grave do cérebro não-técnico: "E os dados de ontem?". Resposta: "Seguros!". Mostra muita comunicação tática em crise.

⚠️ **QUANDO NÃO USAR:**
Nunca minta "Acho que 10 usuários caíram", se você não olhou o log. Se você não sabe o número exato, diga "We are assessing the full scope of the impact" (Nós estamos avaliando o escopo total do impacto).

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no Slack |
| :--- | :--- | :--- |
| **Stakeholder** | Parte interessada (Dir., Cliente e Vendas) | "Update the **stakeholders** on Slack." |
| **Scope / Impact** | Tamanho do dano gerado | "We are analyzing the **scope** of the failure." |
| **Remain secure / intact** | Seguem seguros/íntesgros | "Don't worry, the database records **remain intact**." |
| **To assess** | Avaliar (danos/vistos/riscos) | "We need to **assess** the root cause first." |
| **Data loss** | Perda permanente de dados das tabelas | "I confirm there is absolutely zero **data loss**." |

**5. MINI DIÁLOGO REAL**
*[Zoom Call - Incident Report with VP of Sales]*
**VP of Sales:** Elias, the support team is telling me no one can log in! What's the impact on our revenue right now?
*(Elias, Suporte diz que ninguem loga. Qual o impacto na nossa receita agora?)*

**You:** I understand the urgency. Right now, the authentication service is down, but the good news is: all databases remain completely intact, so zero data loss.
*(Entendo a urgência. Agr msm o serviço de Auth caiu, mas boa noticia: o banco de dados segue inteiramente integro, portanto Sem perda de Dados).*

**VP of Sales:** That's a relief. Any idea when we can operate again?
*(Isso é um alívio. Alguma ideia de quando voltamos a operar?)*

**You:** We are assessing the logs, but our ETA for full recovery is 20 minutes. I will keep you posted closely.
*(Avaliando [Assessing] os logs, mas estimamos (ETA) voltar todos em 20 min. Deixo vc avisado de perto.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"The Database broke down for real."** (Soa juvenil e desesperador).
✅ **"The Database is currently unreachable."** (Soa mais corporativo, neutro e técnico).

❌ **"I don't know the impact yet."** (Seco e inseguro).
✅ **"We are assessing the full scope of the impact now."** ('Assessing' traz muito ar de auditoria séria).

❌ **"We lost nothing."**
✅ **"There is no data loss."** ou **"The data remains intact."** 

**7. EXERCÍCIO PRÁTICO**
Pense mentalmente a famosa fala de Ouro do SRE acalmando o gerente de marketing.
"O site caiu por conta da foto que subiram. Mas: **não há perda de dados** (No...). **Eu estou investigando** (investigating) isso agora."

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"We are assessing the impact right now. The good news is that there is zero data loss."**
*(Estamos avaliando o impacto. A boa notícia é de que tivemos perda nula de dados.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Imagine a critical product goes down. How do you communicate this to non-technical stakeholders like Sales or Management?"*
✅ **Resposta modelo:**
"I avoid technical jargon like 'VPC peering failure' and focus on the business impact. I immediately set up a status channel and communicate three things: 1. The visible impact on users (e.g., 'checkouts are failing'), 2. Reassurance about data integrity (e.g., 'zero data loss'), and 3. The precise ETA for recovery. I make sure to validate their stress by keeping updates regular so they don't feel left in the dark."
