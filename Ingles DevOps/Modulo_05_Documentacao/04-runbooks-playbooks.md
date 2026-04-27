# Módulo 5 — Documentação Técnica
## Aula 04: Como entender Runbooks, Playbooks e Guias Operacionais em inglês

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
É seu plantão de *On-Call* Sábado às 4 da manhã. O alarme *P1 "Kafka Cluster Down"* dispara e seu celular berra. Você entra na empresa agora e tem apenas um link fornecido pelo alerta: O tal do "Runbook". Ponto de tensão: Se a linguagem do *Runbook* for complexa ou ambígua e você não dominar os verbos de imperativo absoluto do inglês, um comando mal executado pode zerar os tópicos em produção. 

**2. O QUE VOCÊ PRECISA SABER (objetivo da aula)**
Um **Runbook** (ou Playbook) é uma receita de bolo ("Passo a passo") criado para ser lido com os olhos turvos de sono. Você precisa dominar o formato *If this, then do that* (Se isso ocorrer, então execute X). Nessa linguagem, você raramente verá gerúndio ("running", "testing"); tudo é mandato imperativo: *Run*, *Test*, *Check*, *Verify*, *Do not*.

**3. OS COMANDOS (VERBOS) DE OURO EM INGLÊS DE RUNBOOK**
Sempre que você olhar um Playbook corporativo gringo, os blocos iniciarão com as seguintes ordens:

🟢 **VERIFY / CHECK** (Fase de Averiguação Tática)
* "Verify the current memory state on Datadog." (Verifique o estado atual...)
* "Check if the pod is in CrashLoopBackOff." (Cheque/Verifique secamente se o pod encontra-se em OOM...)

🟡 **EXECUTE / RUN** (Fase de Comando Físico)
* "Run the bash script located in `/scripts/restart.sh`." (Rode/Execute o script situado em...)
* "Execute the terraform apply as a dry-run first." (Execute o tf como dry-run/teste seco antes...)

🔵 **ESCALATE / ROLLBACK** (Fase de Acionamento Grave / Volta Atrás)
* "If the issue persists, escalate the paging alert to the Database Lead via Slack." (Se o problema persistir, escale o alarme pager p/ o Líder de Banco de Dados via Slack).
* "Rollback the cluster to the last known working image." (Reverta o cluster pra a última imagem de trabalho reconhecida).

⚠️ **QUANDO VOCÊ FOR ESCREVER UM EM INGLÊS:**
Nunca adicione parágrafos enormes explicando contexto num runbook. É "Passo 1", "Passo 2", "Erro caso 1". Textão em inglês às 4h da madrugada só irá atrapalhar quem tá chorando com erro P0.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso num Runbook |
| :--- | :--- | :--- |
| **Runbook / Playbook**| Manual Operativo Padrão Passo-a-passo| "Follow the **runbook** to restart the cache." |
| **If... persists** | Se o ploblema persistir | "**If the error persists**, escalate it." |
| **To escalate** | Acionar/chamar poder superior/Lider | "**Escalate** immediately to the Network Team." |
| **Mandatory** | Obrigatório (Comando a não pular) | "Rebooting the service is **mandatory**." |
| **To bypass** | Furar/Esquivar/Pular/Atravessar o fluxo | "DO NOT **bypass** the proxy layer." |

**5. CENA DE LEITURA RÁPIDA (Roteiro Real de "War Room")**
*[Você lê correndo um alert attachment de PagerDuty]*

**Incident Triggered:** High CPU Usage Database
**Runbook instructions:**
1. **Verify** current CPU % metric in CloudWatch. If > 90%, proceed to step 2.
2. **Execute** scaling command on Bastion Host: `aws rds modify-db...`
3. Wait 10 minutes. **Verify** metrics again.
4. **If the issue persists**, **escalate** the alert to DBA-Support.

_Fácil, linear mental e claro._

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Please, you run the script now."** (Se ensinando ao escrever - Inútil pro Runbook).
✅ **"Run the script."** (Ordem seca é vida em SRE Docs).

❌ **"Send a message to the boss."** (Genérico de botequim americano).
✅ **"Escalate to the Engineering Manager."** ("Escalar" indica trâmite correto de acionamento em crises/incidentes).

❌ **"Go back to the version before."** (Infantilizado/Leigo).
✅ **"Rollback the pipeline to the previous successful version."** (Mecânica e léxico impecável de Dev).

**7. EXERCÍCIO PRÁTICO**
Crie mentalmente as primeiras duas ordens do seu próprio runbook básico para ligar a máquina do estágio:
"1. **Check** (Verifique) the variables. 
 2. **Execute** (Execute) terraform init. 
 3. Se falhar, **escalate** (escale) to Elias."

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"If the restart command fails, rollback the deployment and escalate the alert to the backend team."**
*(Se o comando restart engasgar, escale/reverta o deploy e alerte o time de Backend).*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"We have a lot of legacy systems. How do you ensure that when you are on vacation, other junior engineers can handle basic system failures?"*
✅ **Resposta modelo:**
"Operational knowledge can't live purely in my head. I write very clean, step-by-step 'Runbooks' for known issues. A good runbook must use direct, imperative English commands like 'Run this', 'Verify that', and have clear branching logic: 'If the issue persists, escalate here'. That empowers junior engineers to mitigate simple outages safely, even at 3 AM in the morning, without needing my approval."
