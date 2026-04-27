# Módulo 0 — Sobrevivência no Primeiro Dia
## Aula 03: Como dizer que não entendeu sem parecer despreparado

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você está em uma call de Troubleshooting e o Gerador de Incidentes da AWS (um engenheiro com forte sotaque britânico ou indiano) começa a falar muito rápido sobre um erro na tabela de rotas da VPC. Você perdeu a linha de raciocínio e precisa que ele repita a informação técnica de forma mais clara, mas sem parecer que você é tecnicamente inapto.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Você precisa pedir educadamente para a pessoa repetir ou clarificar algo, jogando parte da "culpa" na qualidade do áudio ou confessando humildemente que você não pegou a última frase. Jamais fique em silêncio se não entendeu uma instrução crítica num ambiente de DevOps.

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "Sorry, can you repeat that?"
  * **Tradução:** Desculpe, você pode repetir isso?
  * **Contexto:** Funciona, mas soa muito "escolar" e direto demais em reuniões corporativas.

🟡 **INTERMEDIÁRIO** — Soa profissional
* "I'm sorry, I didn't catch the last part about the VPC routing. Could you go over that again?"
  * **Tradução:** Me desculpe, eu não peguei a última parte sobre o roteamento da VPC. Você poderia repassar/explicar isso de novo?
  * **Contexto:** Excelente. O verbo "catch" (pegar) é o mais comum para dizer "não entendi o que você disse".

🔵 **AVANÇADO** — Soa nativo / Senior
* "Could you clarify what you meant by restricting the inbound traffic? Just to make sure we're on the same page."
  * **Tradução:** Você poderia clarificar o que quis dizer sobre restringir o tráfego de entrada? Só para ter certeza de que estamos na mesma página.
  * **Contexto:** Super sênior. Em vez de dizer "eu não entendi", você está dizendo que quer garantir o alinhamento.

⚠️ **QUANDO NÃO USAR:**
Nunca use apenas "What?" (O quê?). Isso soa extremamente mal-educado, agressivo e antiprofissional. Em inglês, quando não ouvimos algo, não dizemos "What?". Dizemos "Excuse me?" ou "Sorry?".

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em frase real |
| :--- | :--- | :--- |
| **To catch** | Pegar/Entender algo que foi dito | "I missed it. I didn't **catch** the error message." |
| **To go over (something)** | Repassar/Revisar algo | "Can we **go over** the deployment steps again?" |
| **To clarify** | Esclarecer/Explicar melhor | "Could you **clarify** this metric for me?" |
| **On the same page** | Na mesma página/Alinhados | "Let's review the configs so we are **on the same page**." |
| **To break up (audio)** | Cortar (quando o áudio trava) | "Sorry, you're **breaking up**. Can you say that again?" |

**5. MINI DIÁLOGO REAL**
*[Zoom Call - Incident Response]*
**Dev:** Elias, I need you to flush the Redis cache and restart the worker nodes, but only for the European cluster, otherwise we'll drop active sessions.
*(Elias, preciso que você limpe o cache do Redis e reinicie os nós worker, mas apenas para o cluster Europeu, senão derrubaremos sessões ativas.)*

**You:** I'm sorry, you were breaking up a bit. Could you repeat the part about the worker nodes?
*(Me desculpe, seu áudio estava falhando um pouco. Você poderia repetir a parte sobre os nós worker?)*

**Dev:** Oh, sure. I said you need to restart the worker nodes on the EU cluster only.
*(Ah, claro. Eu disse que você precisa reiniciar os worker nodes apenas no cluster EU.)*

**You:** Got it. Flushing Redis and restarting EU worker nodes. Doing it now.
*(Entendido. Limpando Redis e reiniciando worker nodes do EU. Fazendo isso agora.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"I didn't understand."** (Literal e direto demais, pode soar áspero/firme).
✅ **"I didn't catch that." / "I'm not sure I follow."** (Mais suave e educado).

❌ **"Can you say again?"**
✅ **"Could you repeat that, please?"** ou **"Could you say that again?"**

❌ **"I have a doubt about the instructions."**
✅ **"I need some clarification on the instructions."**

**7. EXERCÍCIO PRÁTICO**
Durante a call do projeto (Planning), alguém explica o fluxo do novo pipeline do GitHub Actions, mas fala muito baixo e rápido. Crie uma frase suave de nível intermediário (usando "catch" ou "go over") pedindo para a pessoa repassar a ideia sobre o pipeline.

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I'm sorry, I didn't catch the last part. Could you go over that again?"**
*(Me desculpe, não peguei a última parte. Poderia repassar/repetir isso?)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How do you handle situations where a stakeholder gives you ambiguous or unclear requirements for an infrastructure setup?"*
✅ **Resposta modelo:**
"Communication is critical in DevOps. If the requirements are unclear, I never make assumptions. I schedule a quick call or reply formally via Jira, asking them: 'Could you clarify what you meant by [specific point]? Just to make sure we are on the same page before I start provisioning resources.' This saves hours of rework and prevents incidents."
