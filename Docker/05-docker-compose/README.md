# Módulo 5 — Docker Compose

Vocẽ percebeu como rodar 1 App com 1 Banco no CLI já começou a ficar insano?
`docker run -d --name banco --network minha_red -v bk:/var/lib ..blabla`. Imagina lembrar e rodar isso toda manhã. O Docker Compose é o fim do CLI gigantesco.

---

### 1. ANALOGIA DO DIA A DIA

**O Diretor da Orquestra**
- Os **Containers**: São os músicos (Violino, Celista, Baterista). Sozinhos no quarto (CLI Shell) eles tocam bem. Mas quem garante quem começa a tocar antes de quem?
- O **Docker Compose**: É o Maestro com a partitura completa (`docker-compose.yml`) escrita na mao. Ele bate a vaquina e manda o violino sentar, cria a rede pros músicos se ouvirem e abaixa o braço puxando todo mundo ao mesmo tempo no compasso perfeito.

---

### 2. O QUE É (Definição Técnica Senior)

Docker Compose é uma ferramenta (Que agora é embutida no proprio CLI `docker compose`) em fomação YAML para infraestrutura *Declarativa*. 
Em vez de comandos "Imperativos" (Faça isso, depois faça isso via Bash Script), nós "Declaramos" o **Estado Final Desejado** da infraestrutura. Se exigirmos 1 BD, 1 Web e uma custom Network. O Compose lê, deduz o que falta na máquina, e orquestra a criação, conexão via DNS default automático e a sequencia de boot baseada em DAGs recursivos (`depends_on`).

---

### 3. ARQUIVOS COMENTADOS

Abra e entenda a evolução do YAML proceduralmente:
- `01-compose-um-servico.yml`: A base da base substituindo o bash básico.
- `02-compose-com-volumes.yml`: Adicionando persistência ao banco de forma legível.
- `03-compose-com-rede.yml`: Interligando duas coisas. E O DNS é de graça!
- `.env.example`: O conceito vital de Injeção de dependência de Sênior via parser nativo do compose.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: Levantar a Infra Inteira**
`docker compose -f 03-compose-com-rede.yml up -d`
* **O que faz**: O comando de ouro inteiro da sua vida daqui pra frente. Lê a partitura. Cria a rede Bridge customizada dele default para aquele arquivo sub-isoldando eles. Sobe os processos baseados na árvore de dependências.

**Comando 2: Parar o expediente sem perder mesas**
`docker compose stop`
* **O que faz**: Dá SIGTERM em todos sem destruir a rede criada por ele nem esvaziar/deletar os containers.

**Comando 3: Destruição (Tear Down)**
`docker compose down` e `docker compose down -v`
* **O que faz**: O `down` mata e deleta os containers além de desmontar a rede custom criada pra eles. Porém os named-volumes do stack FICAM VIVOS para num próximo `up` os dados existirem. E se você passar a flag `-v`, a bomba atomica é ativada. Ele da shutdown, delata a rede, e detona os volumes do disco de brinde. Cuidado em prod.

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Eu subo o `up`... mas ai o App web capota porque conectou no banco que "tá levantando o binario mas nao ta pronto ora receber request".
  **Troubleshooting**: Isso ocorre porque usar o simples `depends_on` YAML SÓ obriga o Compose a esperar o processo PID 1 do banco "iniciar (state runing)". Mas um banco real de gigabytes por demorar 40 segundos depois de ativo para abrir a porta TCP! A solução moderna/Sênior é usar **Healthchecks condition** no depends on, obrigando ao compose esperar a health-probe dar OK TCP port open antes de dar boot no APP WEB. Veremos mais a fundo no modulo 8.

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

Você vai se deparar com vagas pedindo "Docker Compose pra Produção" e gente falando "Docker Compose JAMAS EM PROD". Quem tá certo?
**R: A nuvem e você.**
O Compose clássico atacha todos os serviços **apenas em 1 Maquina Host (Seu Node EC2 ou Kernel)** local. Ele foi feito para uso restrito em Desenvolvimento! Você sobe o App+BD na marte da IDE local, cusa e dps joga `down`.
Em produção, se essa host cair ou tiver de alocar em 3 hosts para balanceamento... o compose se quebra, não estende multi-host nativo sem drivers obscuros. Mas se a empresa for pequena e usar um único PC de R$50/mes de VPS gigante na Digital Ocean.. rodar docker compose em prod é completamente aceitável e normal.

---

### 7. PERGUNTA DE ENTREVISTA

**Pergunta:** Eu recebi na empresa o docker-compose e tem váriaveis em plain text senha de banco na seção `- environment:`. O Junior commitou isso pro GitHub da empresa exposto. Como consertar provendo envs secrets do jeito certo sem quebrar o YAML e rodando apenas o `docker compose up -d` pra funcionar?
**Resposta Senior:** Primeiramente, apago essas senhas raw do YAML. Eu troco de `MYSQL_PASS=123` para a sintaxe de interpolação: `MYSQL_PASS=${DB_PASSWORD}`. Então, eu crio um arquivo `.env` na RAIZ daquela pasta local de deploy. O binário do `docker compose` tem um parser default que lê tudo que ta no `.env` e cospe pra dentro da memoria as variaveis de interpolation do YAML e injeta com segurança lá dentro pro container ser buildado no Up sem passar por logs maliciosos de repositório git. O arquivo `.env` a gente bota no .gitignore!
