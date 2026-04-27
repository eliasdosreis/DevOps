# Módulo 4 — Code Review e Pull Requests
## Aula 01: Como comentar um PR de forma construtiva

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você foi marcado como revisor no GitHub/GitLab em um Pull Request (PR) de alteração massiva de Terraform. Ao ler o código, você bate o olho em uma variável "hardcoded" de banco de dados (senha no texto limpo). Se você simplesmente comentar "Wrong" ou "Change this", o desenvolvedor pode se ofender. Code Review estrangeiro é pura diplomacia; é o lugar onde você mais usará o "modal" da sugestão. 

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Em vez de usar imperativos (Faça isso, mude aquilo), o inglês de revisão de código usa perguntas (E se fizermos assim?) ou sugestões (Você não acha que seria melhor usar...). A palavra-chave da diplomacia técnica é: "I wonder if..." (Eu me pergunto se...).

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Simples causa e efeito
* "Please change this password. It is not secure."
  * **Tradução:** Por favor, mude esta senha. Não é seguro.
  * **Contexto:** Funciona para times pequenos locais, mas pode soar como uma "patada" vindo de um sênior, soando ditatorial.

🟡 **INTERMEDIÁRIO** — Soa profissional (Sugestão suave)
* "Could we extract this hardcoded password into an environment variable instead?"
  * **Tradução:** Poderíamos extrair esta senha cravada (hardcoded) para uma variável de ambiente em vez disso (instead)?
  * **Contexto:** Usar "Poderíamos" ou "Nós" e incluir no fim da frase a palavra "instead" tira o peso total do erro da pessoa, tornando a alteração um conselho de time.

🔵 **AVANÇADO / DIPLOMATA** — Soa nativo / Senior
* "I wonder if we should pull these credentials from AWS Secrets Manager here. WDYT? Hardcoding them might pose a security risk."
  * **Tradução:** Eu imagino (me pergunto) se nós deveríamos puxar essas credenciais do Secrets Manager aqui. O que você acha (WDYT)? Hardcodear isso pode apresentar um risco de segurança.
  * **Contexto:** Altíssimo nível de etiqueta Dev. "WDYT?" (What do you think?) é essencial em finais de revisão. Mostra que o PR é uma colaboração, não uma auditoria policial.

⚠️ **QUANDO NÃO USAR:**
Nunca seja 'diplomata' se o erro for fatal e ele for "mergar" naquele instante quebrando tudo. Numa crise, vá de: *"Hold the merge. Pushing this hardcoded value will break security compliance!"*

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no GitHub |
| :--- | :--- | :--- |
| **WDYT?** | O que você acha? (Acrônimo) | "Let's use an array. **WDYT?**" |
| **I wonder if...** | Eu imagino se (sugestão polida)| "**I wonder if** this loop is necessary." |
| **Hardcoded** | Valor na cara do código | "This IP is **hardcoded**." |
| **To extract** | Extrair/Tirar para fora do trecho | "Let's **extract** this logic into a function." |
| **To pose a risk** | Apresentar/gerar um risco | "This update **poses a risk**." |

**5. MINI DIÁLOGO REAL**
*[GitHub PR Comment - Line 45]*
**You:** Good job on the logic here! Just one minor thing: I wonder if we should extract this API key to a `.env` file? Pushing keys directly into the repo poses a security risk. WDYT?
*(Bom trabalho na lógica aqui! Apenas uma coisa mínima: eu me pergunto se não deveríamos extrair essa API key para um `.env`? Fazer push de chaves direto no repo apresenta risco. O que você acha?)*

**Developer (Reply):** Ah, good catch! I completely forgot to add it to the `.gitignore`. I will extract it and update the PR shortly. Thanks!
*(Ah, bem reparado! Eu esqueci compl. de add no gitignore. Vou extrair e atualizar o PR em breve. Obg!)*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"This code is wrong."** (Rude e fere egos).
✅ **"There might be an issue with this approach."** (Pode haver um problema com essa abordagem).

❌ **"Do that." / "Fix this."**
✅ **"Could we do that?" / "Let's fix this..."** (Mude o Faça para Podemos Fazer).

❌ **"In the line 45..."**
✅ **"On line 45..."** (Linhas de código levam On, não In).

**7. EXERCÍCIO PRÁTICO**
Simule mentalmente a correção abaixo. 
Você achou uma porta 3306 aberta no script Terraform. Diga diplomaticamente:
"Eu imagino se deveríamos restringir (restrict) a porta 3306. O que você acha?"

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I wonder if we should extract this into a variable. WDYT?"**
*(Eu pergunto-me se deveríamos extrair isso para uma variável. O que acha?)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How do you approach code reviews when someone writes poor code?"*
✅ **Resposta modelo:**
"I believe code reviews are about code quality, not ego. I always start by highlighting something positive. When pointing out an issue, I avoid harsh commands like 'fix this'. Instead, I use phrasing like: 'Good job here, but I wonder if we could optimize this loop to save memory? WDYT?'. This invites collaboration and gets the developer to reflect, rather than feeling attacked."
