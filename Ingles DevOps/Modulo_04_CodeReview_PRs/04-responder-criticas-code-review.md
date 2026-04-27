# Módulo 4 — Code Review e Pull Requests
## Aula 04: Como responder críticas no code review sem ego

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você abriu um PR com a arquitetura EKS perfeita, demorou duas semanas de trabalho insano. Aí chega o Arquiteto e te dá um block no review escrevendo: *"This configuration is not optimal, please use NodeGroups instead of Fargate for this module."* O sangue BR ferve, mas responder com ataque ou ressentimento quebra a avaliação comportamental. 

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Se você não sabe receber "review" internacional, sua vida na Nuvem será um inferno. O primeiro passo é o princípio da 'Aceitação' e 'Validação'. Em inglês, aceitar as críticas (mesmo que discorde internamente) e propor uma troca pacífica usa os famosos termos *"Good catch"* (Bem notado) ou *"Make sense"* (Faz sentido / Concordo). E, se discordar, mostre por que de forma neutra.

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Simples causa e efeito (Se vc for refazer a tarefa)
* "You are right. I will change this now."
  * **Tradução:** Você está certo. Eu vou mudar isso agora.
  * **Contexto:** Prático e mostra que você abaixou a cabeça, mas é um inglês pobre de argumentação.

🟡 **INTERMEDIÁRIO** — Soa profissional
* "Good catch! I missed that detail. Let me update the PR and I'll ping you once it's done."
  * **Tradução:** Bem observado! Eu deixei passar (missed) esse detalhe. Deixa eu atualizar o PR e marco você quando estiver feito.
  * **Contexto:** "Good catch" demonstra que você agradece pela percepção do outro. "I missed that" é melhor que dizer "Eu errei" (I made a mistake).

🔵 **AVANÇADO / COM DISCORDÂNCIA LEVE** — Soa nativo / Senior
* "That's a valid point about NodeGroups. However, my reasoning for using Fargate here was to entirely remove the operational overhead. Given that requirement, should we still switch?"
  * **Tradução:** Esse é um argumento válido sobre NodeGroups. Contudo/entretanto, o meu raciocínio para utilizar Fargate aqui foi remover inteiramente o custo-operacional. Dado este requerimento (condição), nós ainda deveríamos trocar?
  * **Contexto:** Maravilhoso e irretocável. Confirma sua validade, impõe a sua arquitetura baseada no negócio (remove operational overhead), e então devolve pra ele repensar. Zero ofensa.

⚠️ **QUANDO NÃO USAR:**
Nunca use respostas agressivas numa caixa de GitHub (onde fica público pra sempre). Nada de: "But I did exactly what Jira asked!" (Mas fiz do jeito do ticket!). A discussão precisa ser sobre o código.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no GitHub |
| :--- | :--- | :--- |
| **Good catch** | Bem notado / Bem observado | "**Good catch**! I will fix the loop." |
| **My reasoning (for)** | Meu raciocínio / motivo de | "**My reasoning** was to save money." |
| **To miss (something)** | Deixar passar batido (não-intencional) | "I completely **missed** that config file." |
| **Overhead** | Gasto de energia / Processo pesado | "That tool adds too much **overhead**." |
| **To switch (to)** | Mudar/Trocar de ideia ou via | "Should we **switch** to the new standard?" |

**5. MINI DIÁLOGO REAL**
*[GitHub PR Comments]*
**Senior DevOps:** Hey, using a `*` wildcard in this IAM Policy is too permissive. Can we scope it down strictly to the specific S3 buckets?
*(Ei, usar asterisco na política IAM é muito permissivo. Podemos fechar escopo apenas para buckets específicos?)*

**You (Reply):** Ah, good catch! I definitely missed that. My initial reasoning was to keep it generic for the prototype, but you are right regarding security. I'll switch it to the specific ARNs and update the PR.
*(Ah, ótima obs! Eu com certeza deixei passar. Meu raciocínio inicial era deixar genérico no protótipo, mas vc tem razão pra segurança. Vou trocar pros ARNs e att o PR).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Why you didn't say this before?"** (Arroio inútil).
✅ **"I understand. Let's align on this for future deployments."** 

❌ **"Sorry for my mistake, I am dumb."** (Excesso de pedido de desculpas / inferioridade do BR).
✅ **"Ah, good catch! I'll update the PR."** (Nativos raramente ficam chorando pedindo desculpas no PR. Apenas agradeça "Good catch" e corrija o código!).

❌ **"Make sense."** (Gramática quebrada).
✅ **"That makes sense." / "Makes sense to me."**

**7. EXERCÍCIO PRÁTICO**
Um revisor pegou um token no meio do seu bash script. Escreva amigavelmente (Good catch!) que você "deixou passar" (missed that) e que vai atualizar o PR.

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"Ah, good catch! I completely missed that detail. I'll update the PR right away."**
*(Ah, bem observado! Eu esqueci compl. esse detalhe. Vou att o PR agora mesmo.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Tell me about a time you received negative or critical feedback on a Code Review/Pull Request. How did you react?"*
✅ **Resposta modelo:**
"I view PRs as a collaborative learning tool, not an audit of my ego. Recently, a senior engineer completely blocked my deployment because my IAM roles were too permissive. Instead of getting defensive, I replied 'Good catch, thanks for pointing that out. I missed it.' Then I asked for a 5-minute call to fully understand his security reasoning. I fixed the code according to his feedback, merged it smoothly, and we ended up trusting each other a lot more."
