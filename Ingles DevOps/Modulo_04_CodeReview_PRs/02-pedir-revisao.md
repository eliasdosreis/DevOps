# Módulo 4 — Code Review e Pull Requests
## Aula 02: Como pedir revisão do seu próprio PR proativamente

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você finalizou 4 horas intensas atualizando as *policies* do IAM e abriu um Pull Request na sexta-feira às 15h. Porém, todos da equipe estão 'ocupados'. Se você não correr atrás das aprovações (Approve), a *pipeline* não rola e sua entrega da sprint atrasa. No Slack, jogar o link sem contexto só fará com que as pessoas te ignorem.

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Quando for pedir revisão do seu PR para o seu time, nunca envie só o link do GitHub. Você deve pedir um favor gentilmente no canal da equipe, informar a finalidade (ex: "Conserto do Banco") e dizer qual é a complexidade ou urgência ("É só uma linha", ou "Gasta uns 10 minutos para analisar"). Isso tranquiliza o revisor.

**3. FRASES ESSENCIAIS (do básico ao avançado)**
🟢 **BÁSICO** — Serve para conseguir revisão (mas pode soar seco)
* "Can someone review my PR?" (Insira o link).
  * **Tradução:** Alguém pode revisar meu PR?
  * **Contexto:** É muito direto. Ninguém se sente motivado a revisar algo que parece "jogado".

🟡 **INTERMEDIÁRIO** — Soa profissional
* "Hey team, could someone take a look at this PR when you have a chance? It's a minor Terraform update."
  * **Tradução:** Oi time, alguém poderia dar uma olhada nesse PR quando vocês tiverem uma chance? É uma atualização menor de Terraform.
  * **Contexto:** Ao usar "quando tiverem a chance", retira pressão. Ao dizer "é apenas uma att menor", ganha a simpatia (leva 1 min).

🔵 **AVANÇADO / COM URGÊNCIA** — Soa nativo / Senior
* "Hey folks, I just raised a PR to fix the database latency issue. It's a bit heavy, but I'd appreciate some fresh eyes on it before we merge. Could anyone review it by EOD?"
  * **Tradução:** Oi pessoal, acabei de levantar (Raise) um PR para consertar o problema de latência do banco. É um pouquinho pesado, mas eu apreciaria (um novo par de olhos) nisso antes do merge. Alguém poderia revisar isso até o final do dia (EOD)?
  * **Contexto:** Perfeito. O verbo 'Raise' para tickets/PRs é lindo. "Fresh eyes" é a expressão corporativa americana ideal para pedir "análise não tendenciosa". Dá limite de prazo (EOD) para evitar gargalos na sprint.

⚠️ **QUANDO NÃO USAR:**
Nunca marque (`@`) uma única pessoa especificamente para revisar urgentemente um PR, a menos que isso seja estritamente necessário ou ela seja o Tech Lead, sob o risco de expor o colega que pode estar em outra ligação ou focado (Deep Work).

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no Slack |
| :--- | :--- | :--- |
| **To raise a PR** | Criar/Abrir um Pull Request | "I just **raised a PR** for the fix." |
| **To take a look** | Dar uma olhada | "Could you **take a look** at this issue?" |
| **A minor update** | Atualização pequena (rápida) | "Don't worry, it's just a **minor update**." |
| **Fresh eyes** | Olhar externo/Novo par de olhos | "I need some **fresh eyes** on this code." |
| **To merge** | Mesclar (incorporar o PR) | "I will **merge** it once it's approved." |

**5. MINI DIÁLOGO REAL**
*[Slack Channel - #dev-team]*
**You:** Hey team! I've just raised a PR updating the NodeJS docker image. It's a minor change, but it fixes the CVE vulnerability. Could someone take a look when they have a sec?
*(Ei time! Acabei de subir o PR att a imagem Docker do node. É uma mudança mínima, mas conserta a vulnerabilidade. Alguém pode dar uma olhada quando tiver um seg?)*

**Teammate:** Sure thing! I'll review it right after my current meeting. Give me 10 minutes.
*(Claro que sim! Irei revisar logo após minha reunião de agora. Me dê 10 minutos.)*

**You:** Awesome, thanks. Let me know if you want me to walk you through it.
*(Incrível, valeu. Me avisa se eu quiser que eu "passe por ele com você" / mostre o caminho na call).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Please review my code now."** (Ordem de comando; soa rude).
✅ **"Could someone please review this PR when possible?"** (Sempre em forma de pedido se não for incidente crítico).

❌ **"I made a PR."**
✅ **"I opened a PR"** ou **"I raised a PR."** (Nós não 'fazemos' PR, nós abrimos/levantamos).

❌ **"Can you fast look this?"**
✅ **"Can you take a quick look at this?"**

**7. EXERCÍCIO PRÁTICO**
Crie a estrutura dessa mensagem mentalmente:
"Oi time, alguém poderia **dar uma olhada** (take...) neste PR rápido? Eu apreciaria muito uns **olhos novos** (fresh...) nisso."

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"Could someone take a quick look at this PR? I'd appreciate some fresh eyes on it."**
*(Alguém pode dar uma rápida olhada nesse PR? Apreciaria muito novos olhos/revisão em cima.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Imagine your PR has been sitting without reviews for two days and it's blocking the deployment. What do you do?"*
✅ **Resposta modelo:**
"I never wait two days passively. If a PR is blocking a deployment, I proactively drop a message in the team's Slack channel saying: 'Hey folks, this PR is critical for tomorrow's release. I know everyone is busy, but could someone please review it by EOD? I can jump on a quick call if you need a walkthrough.' I take ownership to unblock myself respectfully."
