# Módulo 2 — Comunicação Escrita (Slack, E-mail, Tickets)
## Aula 02: Como abrir e fechar tickets (Jira, Linear, GitHub Issues)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você encontrou uma vulnerabilidade na imagem Docker base usada em toda a empresa, mas no momento está apagando um incêndio crítico. Você precisa abrir um ticket no Jira (ou GitHub Issue) para não perder o rastro do problema e conseguir que outro Dev puxe essa tarefa na próxima sprint. Além disso, você precisa fechar o ticket que acabou de concluir comentando a solução.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Um ticket bem escrito é a documentação viva da empresa. Títulos ambíguos ("Fix bug") são odiados. Você precisa aprender o jargão do ticket: Expected behavior (Comportamento esperado), Actual behavior (Comportamento atual), Steps to reproduce (Passos para reprodução) e Workaround (Contorno temporário).

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para se fazer entender rapidamente
* "TITLE: Fix error in Docker. / The image has a bug. We need to update to version 1.2."
  * **Tradução:** TÍTULO: Consertar erro no Docker. / A imagem tem um bug. Nós precisamos atualizar para a versão 1.2.
  * **Contexto:** Pobre em detalhes. Um gerente de projeto vai decolar de raiva com a falta de contexto.

🟡 **INTERMEDIÁRIO** — Soa profissional
* "TITLE: Update base Docker image to fix security vulnerability. / I noticed that the current image has outdated packages. Let's upgrade it to v1.2."
  * **Tradução:** TÍTULO: Atualizar imagem Docker base para corrigir vulnerabilidade de segurança. / Eu reparei que a imagem atual tem pacotes desatualizados. Vamos promovê-la para a v1.2.
  * **Contexto:** Bom título, o "I noticed" (eu notei/reparei) é um verbo muito usado em aberturas de tickets, além de definir claramente o porquê.

🔵 **AVANÇADO (TEMPLATE PARA TICKETS)** — Soa nativo / Senior
* "TITLE: Update Alpine base image to address CVE-2024-XXXX"
* "**Current Behavior:** The frontend build pipe fails during the security scanning stage."
* "**Expected Behavior:** The pipe should pass the vulnerability scan."
* "**Workaround:** Skipped the Trivy step temporarily."
  * **Tradução:** TÍTULO: Atualizar imagem base Alpine para tratar a falha CVE... / Comportamento Atual: O pipe falha. / Comportamento Esperado: O pipe deve passar no scan. / Contorno (Gambiarra temporária): Pulei o Trivy temporariamente.
  * **Contexto:** Nível altíssimo de clareza corporativa na engenharia.

⚠️ **QUANDO NÃO USAR:**
Não use jargões avançados num ticket se a tarefa for extremamente trivial, como "Update spelling in README". Pode só colocar: "Fixed a typo in the README file".

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em ticket |
| :--- | :--- | :--- |
| **Workaround** | Contorno provisório (Gambiarra elegante) | "As a **workaround**, I hardcoded the IP." |
| **To address (an issue)** | Tratar / Lidar com (um problema) | "This PR **addresses** the memory leak." |
| **Steps to reproduce** | Passos para reproduzir o erro | "**Steps to reproduce:** 1. Run docker build..." |
| **To track / tracking** | Rastrear / Acompanhar trabalho | "I created this ticket to **track** the migration." |
| **To assign (to)** | Atribuir (para alguém) | "Could you **assign** this ticket to me?" |

**5. MINI DIÁLOGO REAL**
*[Fechando o Ticket no Jira - Comentário]*
**You (Comentário Final no Ticket Jira 144):**
"I've successfully updated the Alpine image in all microservices. The security scan is now passing. Closing this ticket. See PR #42 for details."
*(Atualizei com sucesso a imagem Alpine em todos os microserviços. O scan de segurança está passando agora. Fechando este ticket. Veja o PR #42 para detalhes.)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"I will make a task for this."**
✅ **"I will open a ticket for this." / "I will create an issue for this."** (Usamos open ou create para tickets).

❌ **"The system is doing a bizarre thing."**
✅ **"The system is exhibiting unexpected behavior."** (Soa mais corporativo e preciso).

❌ **"Gambiarra"**
✅ **"Workaround"** ou **"Quick fix"**.

**7. EXERCÍCIO PRÁTICO**
Crie mentalmente ou escreva o comentário final para fechar de um ticket, avisando que o "Problema de permissões com o bucket AWS foi resolvido" (The permission issue) e "As políticas foram atualizadas" (The policies have been updated). E por fim: "Fechando o ticket".

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I've opened a ticket to track this issue. I'll drop the link in the chat."**
*(Abri um ticket para rastrear esse problema. Vou jogar o link no chat.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How do you document bugs or architecture improvements you find while doing ongoing work?"*
✅ **Resposta modelo:**
"If it's a minor change, I apply a quick fix and mention it in the PR. If it's a larger issue, I don't try to fix it instantly, because that breaks scope. I create a detailed ticket in Jira with the 'Actual Behavior', 'Expected Behavior', and any immediate 'Workarounds'. I then bring it to the next grooming session to prioritize it with the team."
