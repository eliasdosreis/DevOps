# Módulo 8 — Observabilidade e Operação

Sua aplicação foi pra produção, e de repente o Linux congelou, a AWS tá cobrando 10 mil dólares de Disco SSD e o site não abre. A culpa é do Sênior que não fez o arroz com feijão operacional.

---

### 1. ANALOGIA DO DIA A DIA

**O Condomínio sem Síndico**
Quando você não limita e não monitora, os Containers viram moradores fora de controle.
- **Limites Físicos (Cgroups)**: Se um morador ligar 50 ar-condicionados, a luz da rua inteira cai (Out of Memory - OOM Kill do Host Server). O Síndico (Docker Limits) instala disjuntores pra *cortar só a luz daquele apartamento* mantendo os outros 10 ativos!
- **Healthchecks**: É o Síndico interfonando a cada 30 segundos. "Ta vivo?". Se o morador não gritar de lá de dentro por 3 vezes seguidas, ele arromba a porta, mata ele e bota outro no lugar (Restart Automático).
- **Prune (A limpeza)**: São os moradores que se mudam e deixam sofás e geladeiras estragadas no corredor do prédio (Imagens dangling e Volumes órfãos lotando seu Disco de Host físico aos poucos).

---

### 2. O QUE É (Definição Técnica Senior)

A operação exige três blocos fundamentais de dia a dia:
1. **Metrics**: Consumo Raw Lógico visualizavel em tempo real via CLI ou Datadog/Prometheus (Cgroups isolation bounds).
2. **Liveness/Readiness probes (Healthchecks)**: Checagens TCP/HTTP feitas na interface interna do app. Não basta o processo do Node (PID1) estar vivo, o Node tem que poder retornar um Status 200 pro daemon provando conectividade interna sem dead-locks de thread!
3. **Log Drivers**: O Docker não usa arquivos `.txt` por padrão. Ele usa o Driver `json-file` infinito. Se deixar rolando um DB malucão, em 1 mês o log json terá ocupado 350GB do seu HD na pasta de Daemon sem você ver! Rotação é mandatória.

---

### 3. ARQUIVOS COMENTADOS

Abra e inspecione:
- `01-docker-stats-limits.sh`: Vendo sua maquina sofrendo e estipulando barreiras de memoria.
- `02-healthchecks-in-compose.yml`: O YAML re-feito ensinando ao compose O QUE é um servidor online de verdade.
- `03-maintenance-prune.sh`: O script base pra colocar no Crontab de todo servidor Linux do mundo pra faxinar o disco sozinho aos domingos.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: O "Gerenciador de Tarefas" Matrix Hacker**
`docker stats`
* **O que faz**: Trava o terminal numa tela de Dashboard live-reload. Mostrando pra cada Container Vivo a exata % de CPU usando, quantos de RAM e a banda passante subida/descida I/O em tempo real. Essencial para debugar Gargalos de Banco de Dados.

**Comando 2: Limpando Todo o Lixo Residual com 1 enter**
`docker system prune -a --volumes`
* **O que faz**: O comando da purificação de alma (e medo em PROD). Deleta da Lixeira e do host ABSOLUTAMENTE TUDO que não estiver com 1 App Verde rodando atachado nele. Imagens penduradas das versoes velhas, containers excluidos e parados da semana passada.. e Volumes desatrelados de banco.

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Eu dei um "docker system prune" atarde e apagou imagens q eu não queria apagar e demorou milenios baixar de nv!
  **Troubleshooting**: Essa é clássica e perigosa. O `--volumes` força apagar os pen-drives se nao atrelados (Péssimo se deu stop num banco e ia dar Up agorinha de novo e apressado deu prune, perdeu banco).
  O sinal de `-a` na frente do prune é: Apague ATÉ imagens legitimas finalizadas "Ubuntu" se Elas não estiverem num container ligado agora. Sem o `-a`, ele apaga APENAS *Dangling Images*. (Imagens "Pedaços" orfãs descritivas de texto <none><none> lixos gerados na quebra do Dockerfile step do NPM que ficaram no lixo na RAM). Evite flag `-a` indiscriminadamente.

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

O Memory Limit estipulado na config de host `deploy: resources: limits: memory: 512M` significa algo pra imagem Java?
**R: A Tragédia do processo vs JVM cega.**
O Docker impõe que, se o App extrapolar e bater em 513Mb na RAM do hospedeiro por 1 sec, O Kernel da máquina lança o raio da morte OOMKill no container fulminante.
Muitas linguages antigas (ou Node antigo no V8 Engine limites default e o JRE 8 Java) eram "Cegas" pra containers (Namespaces). A Maquina JVM Java olhava e via "Opa.. o servidor fisico da AWS tem 32 GB de RAM! Vou dar malloc expansivo alocando 8 GB pre-cache!". O Docker olhava o limite de 512mb escrito no dockerfile dele e *CRASH*. O OOMKill mandava matar. Cuidado com processos antigos e passe FLAGs internas nas liguagens de Cgroup awarenss pra elas "entenderem a bolha" que tao rodando e se limitarem.

---

### 7. PERGUNTA DE ENTREVISTA

**Pergunta:** Num arquivo Compose pra produção, no serviço do meu log, deixei tudo em modo "json-file" padrão do próprio docker. Meses depois me chamaram e a máquina EC2 inteira travou o disco Root em 100%. Quando logamos na pasta do docker, o log lá do NGINX tem 240 Giga em um único arquivo... como resolvo isso pra NUNCA mais ocorrer no YAML raiz?
**Resposta Senior:** Adicionando o bloco OBRIGATORIO "logging:" dentro do contexto daquele service web no Compose com as propriedades mágicas: `max-size: "10m"` e `max-file: "3"`.
Dessa forma voce dita "O DockerDaemon vai salvar em json normal.. porem se o txt bater 10 megas redondo no HD físico, não espanda, crie um arquivo novo `log.2`. Se bater 3 files estourados de velhos, DELETE/ROLETA o file número mais velho e va empurrando em fila indiana mantendo perpetuamente apenas míseros 30 MB máximos fixos no meu HD sem estourar e me matar de custo de EBS".
