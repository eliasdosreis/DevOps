# Módulo 7 — Docker Swarm (Orquestração a nível Cloud)

Bem-vindo ao mundo dos adultos. Rodar containers numa única máquina é fácil. Mas e se a Black Friday chegar e nosso único servidor estourar de acessos? E se o HD do Host queimar?

Precisamos espalhar nosso App em VÁRIAS Máquinas simultaneamente que agem como uma só. Entra o Orquestrador Nativo: o **Docker Swarm**.

---

### 1. ANALOGIA DO DIA A DIA

**A Rede de Franquias do Fast Food**
- **Docker Normal**: Você é dono de uma hamburgueria de bairro. Tem 1 chapa (Host/VM) e faz X lanches por hora. Se o gás acabar, a lanchonete fecha.
- **Docker Swarm**: Você vira o CEO de uma franquia multinacional de Burger! Você na Mátriz não frita mais hambúrguer, você apenas MANDA (Manager Node). Você diz "Eu QUERO no mínimo 15 hamburguerias iguais operando na cidade. Fritem 5 mil lanches!". Os franqueados (Worker Nodes - outros computadores) ouvem a ordem, abrem lojas (Containers) com a mesma placa idênticas e trabalham. Se o bairro inundar e 3 lojas morrerem, você da matriz vê o painel cair pra 12, liga pro correio e diz "Deu ruim, arrumem mais 3 prédios urgente, o padrão contratual É 15!". 

---

### 2. O QUE É (Definição Técnica Senior)

A orquestração resolve as dores do mundo multi-host: Gerenciamento de Vida (Self-Healing), Descoberta de Serviço Multi-Host e Balanceamento de Cargas.
- **Nodes**: As Máquinas Virtuais EC2 da AWS ou Droplets que vc subiu. Podem assumir o Rôle de **Managers** (Lidam com o algoritmo de Raft Consensus e o banco de dados interno Log pra ditar as regras e eleger líderes) ou **Workers** (Peões estupidos que só rodam containers pra alocar CPU).
- **Service**: Morre o conceito de jogar "dar `run` num container" isolado. Cria-se um `Service`. O Servico é a "vontande do criador". "Quero 10 replicas de Ngix". 
- **Swarm Ingress Network**: Um LoadBalancer L4 Inbutido gratuito. Se 10 máquinas estão no Swarm e apenas 2 estão rodando o seu NGINX Container e a requisição do usuário bater na Porta 80 da Maquina 5 sem container, o Swarm roteia o tráfego oculto pelas veias pra maquina 2 sem que o firewall físico perceba e cospe o pacote processado perfeitamente!

---

### 3. ARQUIVOS COMENTADOS

Abra e inspecione:
- `01-swarm-init.sh`: Transformando sua máquina pacata num Líder do conselho de Orquestração.
- `02-service-update.sh`: Como brincar de "Deus" de auto-escalling.
- `03-swarm-config-secrets.sh`: Como lidar com Senhas Num cluster gigante.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: O Batizado**
`docker swarm init`
* **O que faz**: Ativa o modo swarm inativo por padrão no daemon. Gera certificados TLS mágicos.

**Comando 2: Convite Pra Festa**
`docker swarm join-token worker`
* **O que faz**: Cospe a string exata criptografa com o IP do master pra você colar no prompt de outros computadores da sua empresa. Se eles colarem lá, eles viram seus peões.

**Comando 3: Implantar o Compose file Clássico inteiro lá**
`docker stack deploy -c docker-compose.yml minhastack`
* **O que faz**: O comando LINDO definitivo. Swarm sabe ler arquivos `.yml` de compose sim!! Ele lê o que era restritivo local e converte perfeitamente em "Servicos Mapeados Multiplos". (Ignorando seções de build e requires bind mount absoluto, óbvio!).

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Meu node Worker caiu e o manager mostrou ele offline mas não "puxou de volta" as 3 replicas de NGINX que estavam rodando ali nele pra re-alocar meus Masters, o site perdeu capacidade! Pq demorou?
  **Troubleshooting**: O padrão do algoritmo de Raft do master é aguardar pacientemente um grace period (default em media longos ms). Pois em nuvem, quedas de sinal de internet da máquina ocorrem toda hora por oscilação de pacote por 5 segundos. O Mestre não vai detonar as VMs a toa só pq piscou. Se isso for crítico em High-Frequency Trading, você tuneia as metricas `--task-history-limit` e tempos de heartbeats de re-deployment configs dos services.

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

Por que `docker run` e os Bind Volumes "não funcionam" nativamente do mesmo jeito mágico num Swarm de 5 computadores?
**R: Espacialidade Desconexa**.
Se você der stack num Service dizendo que tem volume atachado da `/minha_pasta_fotos`, o master vai colocar aquilo pra rodar na Maquina X3 por exemplo. Mas... e se a Máquina X3 física for lá em outro país e não tiver TÊR a `/minha_pasta_fotos` no HD formatado dela? Cracha! 
Em Swarm, dados não persistem estaticamente em 1 nodo. Vc precisa atachar **Volumes de NFS (Network File System) na máquina host tipo AWS EFS, GlusterFS, ou AWS S3** e instalar drivers Globais (Plugins) no Swarm parra que toda Maquina Worker que nascer ganhe a rede conectada a um HD em núvem externo real. Sendo assim não importa em qual hardware teu container "Ressucite", ele encosta no HD da Nuvem certinho.

---

### 7. PERGUNTAS DE ENTREVISTA

**Pergunta:** Num cluster de 3 Managers, 2 sofrem queda de hardware ao mesmo tempo. O 1 Manager que sobrou assume tudo ne? E o Cluster fica de pé? 
**Resposta Senior:** Não!! E O cluster Inteiro CRASHA o control-plane, a infra pode ficar corrompida se tentar intervir de imediato. Swarm e K8s usam Algoritmo de "Raft Consensus". Diz que para ocorrer modificações/writes/leader-elections, a Maioria base (A base Quorum de N/2 + 1) OBRIGATORIAMENTE DEVE ESTAR VIVA. Em TRES, O Quorum é Dois! (3/2 = 1.5 + 1). Se 2 morrem at the same time, sobra Um Manager (Menos que o Quorum Dois). O Manager se tranca por segurança, bloqueia todos os updates e aguarda chorando os outros 2 voltarem milagrosamente ou a intervenção da morte do Sysadmin forçando ele mesmo a virar master pelo `force-new-cluster`. Mantenha pelo menos 5 Masters.
