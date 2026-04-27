# Módulo 7 — Inglês no Cotidiano DevOps
## Aula 01: Terminologia Crucial da Cloud (AWS, GCP, Azure)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você precisa pedir permissões novas na nuvem para o arquiteto chefe no Slack ou numa conversa, e, se você usar traduções amadoras em português adaptadas pro inglês (ex: "My container is not opening the porta", "I need VPC hole"), o time nativo de Ops nunca tratará seu pedido com autoridade técnica. Você precisa respirar os nomes gringos como se fossem nomes dos seus filhos.

**2. O QUE VOCÊ PRECISA SABER (objetivo da aula)**
A Cloud fala as seguintes línguas universais: Compute (Máquinas), Storage (Arquivamento), Networking (Linhas de rede), Identity (Identidade/Permissões) e Observability (Acompanhamento). Dominar os termos em inglês, com as junções prontas, te faz fluir com senioridade máxima.

**3. OS TERMOS QUE O DEV SÊNIOR DEVE DOMINAR (Em frases prontas)**
🟢 **COMPUTING (Máquinas/Pod/EC2/Lambdas)**
* **Spike in compute utilization:** "We had a severe *spike in compute utilization* last night." (Tivemos um forte pico de utilização de computação ontem).
* **To scale out vs To scale up:** *Scale out* é adicionar mais pods (Horizontal). *Scale up* é aumentar a RAM/CPU da mesma máquina (Vertical). Em inglês gringo: "Let's scale out naturally via HPA."

🟡 **NETWORKING (Redes/VPC/Router)**
* **Public/Private Subnet:** "The Database must strictly reside in the private subnet."
* **Inbound / Outbound rules:** (Sua porta 80). *Inbound* (Tráfego vindo pra dentro). *Outbound* (Trafego saindo pro mundo). "We blocked inbound traffic on port 22."
* **Peering:** Usado ao invés da palavra "connection" chula para comunicar DUAS redes gigantes. "Establish a VPC Peering."

🔵 **IDENTITY / SECURITY (IAM)**
* **Principle of Least Privilege:** A frase mais importante do IAM no mundo. Entregue exatamente a menor permissão possível. "Always follow the *least privilege factor* when creating IAM Roles."
* **Policies and Roles:** A Policy (política) descreve "o que" / A Role (papel/vestimenta) você veste na Máquina para usar a policy. 
* **Hardcoded credentials:** (Vimos na aula de Revisão). Senha nua no código. Péssimo e amador.

**4. VOCABULÁRIO TÉCNICO COMPLEMENTAR DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso Corporativo |
| :--- | :--- | :--- |
| **Stateless** | Sem manutenção de Estado/Memória (Morre sem dó) | "REST API must be horizontally scalable and **stateless**." |
| **Stateful** | Guarda a carga real (Banco de dados)| "RDS is a **stateful** component." |
| **Fault Tolerant** | Tolerante a falhas (Resiliência) | "The architecture must be **fault tolerant**." |
| **Single Point of Failure (SPOF)**| Ponto Único de Falha (Nó mestre caído mata a app toda) | "Having only one NAT Gateway creates a **SPOF**." |

**5. MINI DIÁLOGO REAL**
*[Whiteboarding / Reunião de Arquitetura no Draw.io]*
**Architect:** The current backend logic represents a single point of failure. If the EC2 dies, we are doomed.
*(O backend atual representa um SPOF (Ponto único falho). Se a EC2 morrer, tamos lascados).*

**You:** I totally agree. We need to implement a stateless architecture and scale out the containers horizontally across multiple Availability Zones. That ensures it's highly fault tolerant.
*(Concordo total. Precisamos implementar arquitet. STATELESS e dar scale-out nos cantainers cruzando várias Zonas de Dispon. Isso garante Resiliência de falha).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Open the firewall door."** (Literalidade tosca "Porta do firewall").
✅ **"Open the inbound port."** (As portas lógicas em TI são ports, não doors. Cuidado!).

❌ **"Increase the machine."**
✅ **"Scale up the instance."** (Verbo maduro de SRE).

❌ **"Put more servers."**
✅ **"Scale out the compute capacity."** (Inglês da NASA pra você).

**7. FRASES PARA MEMORIZAR HOJE**
🗣️ **"We must establish a VPC peering connection and follow the principle of least privilege."**
*(Nós devemos estabilizar a conex. Peering VPC e seguir o Princípio de Menor Privilégio).*
