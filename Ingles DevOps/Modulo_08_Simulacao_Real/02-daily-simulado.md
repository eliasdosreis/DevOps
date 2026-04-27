# Módulo 8 — Simulação de Trabalho Real
## Aula 02: Daily Standup Simulado (Roleplay de Quarta-Feira)

**ROLEPLAY DO DIA: Quarta-Feira, 10:00 da manhã**
**Atores:** `Scrum Master (Mark)`, `Você (Elias)` e `DBA (Sarah)`.
**Cenário Real:** Você estava configurando permissões IAM para os bancos de dados, mas Sarah subiu uma mudança bloqueante nos acessos. Você precisa dar update da Daily e, sem ser ofensivo, jogar o "bloqueio" pra cima da Sarah na frente do chefe para destravar a esteira.

*Leia o script em voz alta* 🗣️

---

**[O ZOOM COMEÇA / Câmeras abrem]**

**Scrum Master (Mark):** Alright everyone, lets go ahead and kick off the standup. Elias, do you want to start?
*(Bora galera, vamos tocar/iniciar o standup. Elias, quer começar?)*

**You (Elias):** Sure. Yesterday I successfully wrapped up the Jenkins runner configuration. It's up and running smoothly. 
*(Claro. Ontem eu envolvi/concluí com suc. a config do runner Jenkins. Tá de pé e rodando lisinho).*

**You:** Today, I am focusing on attaching the new IAM roles to the staging RDS databases. 
*(Hoje, to focando em anexar as novas roles IAM pros bancos RDS em staging).*

**You:** However, I currently have a blocker. It seems the database subnet was locked down yesterday, and my terraform apply is hitting a timeout. Sarah, I'm blocked by this network policy. Could we jump on a quick call right after this?
*(Contudo, tenho um bloqueio no mom. Parece que a subnet do db foi trancada ontem, e meu tf apply tá batendo num timeout. Sarah, to blocked por essa polity de net. Podemos pular num callzinha matadora dps daqui?)*

**DBA (Sarah):** Oh, good catch Elias. I totally forgot to whitelist your agent IP. We don't even need a call, I will push the change right now. You should be unblocked in 5 minutes.
*(Ih, bem notado. Eu eqqueci total de liberar o IP do teu agent. Nem precisa ligar, eu vou dar um push na mudança agora msm. Vc deve tar destravado em 5m).*

**You:** Awesome, thanks! No other blockers on my end, Mark. Back to you.
*(Irado, vlw. Nem mais 1 bloqueio do meu ladom, Marcão. Volta pro cê).*

**Scrum Master (Mark):** Beautiful. Thanks Elias. Next up, Sarah...

---

### 🔥 ANALISANDO A JOGADA SÊNIOR
Repare a precisão verbal deste evento que durou incríveis **45 segundos**:
1. Você cravou o que fez usando um advérbio chique (*smoothly*) e o pão com manteiga (*Wrapped up*).
2. Você cravou o seu hoje com um verbo focado contínuo (*focusing on*).
3. Você descreveu a falha atual do terraform com exatidão técnica (*hitting a timeout* / *subnet locked down*).
4. Em vez de atacar a companheira ("Sarah broked my work!"), você usou o coringa diplomata ("I am blocked by this network policy. Could we jump on a quick call?"). Ao pedir ajuda para a call, você empurra gentilmente o problema pra ela sem gerar clima estranho na empresa inteira.
