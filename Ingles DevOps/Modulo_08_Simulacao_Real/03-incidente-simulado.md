# Módulo 8 — Simulação de Trabalho Real
## Aula 03: Incidente Simulado com Comunicação Completa (P0 Firebase)

**ROLEPLAY DO DIA: Sexta-Feira, 16:30**
**Cenário Real:** O aplicativo de produção que envia notificações Push parou misteriosamente. Mensagens falhando repetidamente no Gateway. Você é o SRE On-call encarregado de conduzir a crise sob alta tensão (o CEO entrou no chat).

*Ligue o cronômetro. Sinta a tensão do momento e leia a sequência:* 🗣️

---

### Minuto 01: O Slack de Alerta 
**Alarme do Datadog dispara:** `[P0] FIREBASE NOTIFICATIONS - 100% FAILURE RATE`

**Você (no Slack #war-room):** 
"@here Critical heads-up: We are experiencing a major outage on the Push Notification service. Error logs indicate a 100% failure rate connecting to Firebase. I am declaring an incident and looking into the Gateway metrics right now."
*(Aviso Crítico: Estamos sofrendo uma P0 aqui nos push. Taxa de fallha de 100% lincadno c/ Firebase. Deklarando incidente e ja to enfiado nas metricas do Gtw. agr).*

### Minuto 05: A Invasão da Diretoria
**VP of Product (Slack):** 
Elias, what is the scope? Are we losing user's unsent messages? 
*(Escopo? Estamos perdendo as msg não envidas dos guri?)*

**Vocẽ (Modo Tradutor Stakeholder):**
"I am assessing the scope right now. The good news is: all unsent messages are safely queued in our dead-letter topic (DLQ). There is ZERO data loss. The messages are just delayed."
*(Eu to avalino o scope. Boas Nwas: TUDO tá engavetado com seguran na DLQ nossa. ZERO perda. Sò tem atraso).*

### Minuto 12: A Causa e a Cura temporária
**Você (Ligando Zoom com o Tech Lead - Voice):**
"Hey John, good catch finding that log. It seems the connection pool to Firebase is maxed out. I wonder if we should manually scale out the notification pods by 20 to clear the queue?"
*(Eae Jhow, bem visto o log. Parece que pool maxed out pro fogo base. Penso aki se eu devia da scale-out (mais pods p/ lado) emns 20x pra limpar essa fila?)*

**John:** 
"That makes sense. Go ahead. Let's see if it stops the cascading failure."
*(Faz sent. Manda brasa. Vamo ve se barra a quebra de cascaa).*

### Minuto 20: A Resolução com Promessa / Post-Mortem.
**Você (no Slack #war-room - Atestado Final):**
"Status update: The issue has been mitigated. We manually scaled out the pods, and the pending message queue is now draining correctly back to the users. Our ETA for complete system normalcy is 5 minutes. 
I will draft the RCA (Root Cause) by Monday to prevent recurrence."
*(Status att: BO foi mitigado. Demos scale out nos baguio, a fila pendurada tá drenando p/ user lindinha. Tempo pra volta top ETTA: 5ming. Desenhei o rascunho RCA P/segunda nunk mais occoer).*

---
**Lição moral do SRE Gringo:** A calma do seu inglês, o uso de "Zero data loss" alivia o chefe, enquanto "maxed out" / "cascading failure" comunica a engenharia. Você estancou o sangue com a mitigação ("mitigated") e prometeu a resolução pra segunda ("RCA").
