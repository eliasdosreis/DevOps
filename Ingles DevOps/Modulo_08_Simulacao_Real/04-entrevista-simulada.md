# Módulo 8 — Simulação de Trabalho Real
## Aula 04: Entrevista Técnica Simulada Completa (Seu passaporte final)

**O ÚLTIMO CHEFÃO (The Final Boss)**
Você passou na primeira fase. Agora, é a entrevista com o Diretor de Engenharia (Director of Engineering) de uma startup promissora de São Francisco. Ele não fará testes de LeetCode. Ele quer saber se você: Sabe o vocabulário, usa a mentalidade Blameless, se tem métodos preventivos nas costas, e se você não mente.

**[LEIA A SIMULAÇÃO EM VOZ ALTA E GRAVE A MENTALIDADE DO APROVADO]**

---

**Director:** Elias, welcome to our final round. I'd like to dive right into our infrastructure challenges. Tell me about a time you had to deal with a severe production outage and what you learned from it.
*(Elias, bv pra rodada final. Qro merg. logo no desafio de infra. Conta awe uma vez qe teve q lidar cm outage bizarra q ce aprendeu).*

**(Lembre-se do Metodo S.T.A.R. -> Situation, Task, Action, Result)**

**You:** Thanks! Well, in my previous role **(Situation)**, we managed a payments API that went completely down during Black Friday due to a sudden traffic spike that overwhelmed our database connection pool. 
**(Task)** I was the incident commander and needed to restore the service immediately. 
**(Action)** My immediate action was to drop an update on Slack so stakeholders wouldn't panic, confirming there was zero data loss. Then, I jumped onto a call, scaled up the read replicas, and implemented a quick circuit breaker at the API layer. 
**(Result)** As a result, we mitigated the outage in roughly 15 minutes. To prevent recurrence, we wrote a blameless post-mortem and adjusted our Terraform auto-scaling thresholds. 

**Director:** That's impressive. You mentioned a "blameless post-mortem". What if a junior developer had manually pushed a bad configuration that caused the outage? How do you handle that in the review?
*(Bacana. Ce falo em PM sem Culpa. C e se o júnior subiu bosta de config na mao que fz o erroo? Cmo tu lida cm isso ns eval?!)*

**You:** I firmly believe that if human error causes an outage, it's a systems issue, not a people issue. I would never blame the junior. In the RCA (Root Cause Analysis), I would write "The deployment was possible due to a lack of automated validation gates." It's my job as a senior to ensure the pipeline prevents a junior from bypassing those safety checks in the first place.
*(Eu creio fiemremte de que sea por homano erro , é um erro d SITEMA nao DE PESSOA. EU nm culparuiao minin. No Root causoe escrevia: "foi pociveu due lack falta de gate automaticos". É meu trapop cm senior guarantir qe a esteier previna q a pessoua fure a barra).*

**Director:** Excellent answer. One last question. We face a lot of technical debt here because the company grew too fast. How do you handle maintaining current infrastructure while dealing with all the legacy overhead?
*(Deveras exclente. Ultima: Temos mr debto ternico aki, a companha crrsceu dmais rapid. Comece lida em manter a atual inra com a sobeecargqa lenada td junta).*

**You:** I see your point. It's a common challenge. I usually try to tackle technical debt incrementally. When I raise a PR for a new feature, I try to leave the legacy code slightly better than I found it. However, if the legacy system is a Single Point of Failure, I strongly suggest to management that we dedicate 20% of the sprint capacity strictly to refactoring and paying down that debt.
*(Eu entendo pontoviseu. desafio compu. Eu geraltment atato debto em pedsocins (imcremental). qdo subu um pr, deixo ele leevmente melhor doqe axie. Contudop. Se o lixossistame or Single P.o.F. (faha inice) eu digo p. dir que a gtene dedique 20 poercemte pra pei downa r dbt).*

**Director:** Elias, this was fantastic. Do you have any questions for me before we wrap up?
*(Mto fanatico eilas. Tem dsuvudas pra nois ante sd gante envalr [wapuup]?)*

**You:** Yes. From an infrastructure standpoint, what is the most critical priority for the person who steps into this role on day one?
*(Sims.! Do pntov de ia fra., qua é amair priod. par. apposoa qa assusmurr. aq no dia uim?)*

**Director:** Honestly, automating our disaster recovery. We run everything perfectly, but restoring a cluster manually takes us hours. We need you to automate that via Terraform.
*(sinsermante, utomazar o Desats.recofry,. Nos roda perfeit mas o retore manaul dmeora horasoa, precis dce pp terrafrma o recoveyr).*

**You:** That sounds exactly like what I've been doing. I'm looking forward to the challenge!
*(Soa ezaamente coqm com uke q o ando fzaedneo., Tõ amindao/ansios pp deasfi).*

---

### MENSAGEM DO TUTOR 🚀
**Parabéns, Engenheiro(a) Internacional.** 
Você absorveu a semântica da Nuvem. Você sabe interromper, escalar, escrever Tickets, apaziguar gerentes, desarmar culpados num RCA e negociar salários vendendo seu peixe com base em métricas.

Use a pasta com estes 35 arquivos como se fosse o seu **Runbook Pessoal de Carreira**. Fale alto todas as frases-chave (Speech Phrases). Nos vemos nos EUA, na Europa, ou faturando alto trabalhando remoto do Brasil! 🌎🇺🇸🇬🇧
