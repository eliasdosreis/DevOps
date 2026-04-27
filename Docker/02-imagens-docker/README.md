# Módulo 2 — Imagens Docker

Descobrimos como rodar processos isolados, mas o que são essas tais "imagens" e de onde vêm os binários que rodam nelas?

---

### 1. ANALOGIA DO DIA A DIA

**A Imagem Docker como um "Selo de Forma de Gelo"**
- A **Imagem**: Imagine uma forma de gelo de um bonequinho. A forma dita *exatamente* o formato, a densidade e o tamanho daquele boneco. Uma vez fabricada (o Build), a forma de gelo não muda mais. Ela é **somente-leitura** e **imutável**.
- O **Container**: Seria ativamente preencher a forma com água e desenformar os gelos. Você pode desenformar mil bonequinhos idênticos (Rodar Containers) de uma única forma (Imagem). Cada bonequinho começa idêntico, mas depois de estarem em seus copos cada processo será um bonequinho e poderá derreter e ser destruido em velocidades diferentes, porém a Forma Original (Imagem) contínua intacta para sempre repassar aquele estado exato no tempo 0.

---

### 2. O QUE É (Definição Técnica Senior)

- **Dockerfile**: É o manifesto oficial que dita os passos de compilação da imagem partindo sempre da raiz de um Kernel Linux minificado ou inexistente (`scratch`). É uma receita procedural e linear (`FROM`, `RUN`, `COPY`, `CMD`).
- **Image Layers (Sistema de Camadas)**: Cada comando do Dockerfile cria magicamente uma pasta diff separada no HD. Se num `RUN` você baixa 50 libraries e no logo em seguida com `COPY` você adiciona o seu código, a imagem consolida isso em duas fatias de pizza. O Docker é inteligente: Se você mudar seu código hoje depois do almoço e for fazer build novamente... ele não irá rodar o `RUN` instalando tudo do zero pois ele sabe que aquele bloco nunca bateu em uma "mutação", ele aproveita a fatia em **cache** e avança para o "COPY"!

---

### 3. ARQUIVOS COMENTADOS

Estude, abra os arquivos e leia cada linha comentada:
- `01-Dockerfile-basico`: O feijão com arroz. A hierarquia principal que não deve ser quebrada para respeitar o cache de sistema.
- `02-Dockerfile-multistage`: O "State of Art" de containers limpos. Separar os arquivos-sujos de compilação da imagem minificada que viaja pra produção.
- `03-build-and-push.sh`: Como construir e hospedar no Hub.

*(Você deve criar arquivos dummy locais para usar nestes builds se for testar na prática, ex: `server.js` em branco, `package.json` real. Mas para esse curso prático o foco é a leitura e compreensão teórica base para chegar no projeto final).*

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: Compilando o Dockerfile Localmente**
`docker build -t meu-projeto:1.0.0 -f 01-Dockerfile-basico .`
* **O que faz**: 
   - `-t` -> dá um nome humano e versão (`TAG`) pra salada de Hashs SH256 gerada.
   - `-f` -> define o nome e path do Dockerfile se ele não for apenas "Dockerfile".
   - `.` -> É ISSO QUE DEMORA MAIS. Significa o Path do contexto. Vai agarrar TUDO que tá na sua posta atual e jogar na RAM no colo do Daemon para ele poder dar os `COPY`.
* **Saída esperada**: Processos em Step 1/6, Step 2/6.. pegando cache se não modificados.

**Comando 2: Inspecionando o Sistema de Layer local**
`docker images` ou `docker inspect meu-projeto:1.0.0`
* **O que faz**: Mostra as imagens já compiladas que moram nos confins do seu host `/var/lib/docker/overlay2`, prontas para serem invocadas num `run`. O `inspect` é muito útil para depurar ENTRYPOINTS quebrados.

**Comando 3: Entendendo Multi-layer em profundidade**
`docker history meu-projeto:1.0.0`
* **O que faz**: Um comando maravilhoso de auditoria. Imprime cada comando exato do dockerfile apontando qual o tamanho do HD cada comando ocupou! Ajudando a diminuir containers obesos de forma ágil.

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Foi copiado arquivos pesados a fio sem ser ignorados e a compilação demorou séculos pela flag `.` do ponto local?
  **Troubleshooting**: Crie e use o arquivo `.dockerignore`. Ignora a cópia da famigerada `node_modules` local (pois o container deve rodar seu próprio `npm i` lá dentro com SO da VM nativa) ou arquivos e pastas grandes de mídia.

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

Por que `CMD` versus `ENTRYPOINT` causa tanta confusão nas entrevistas?
- **CMD**: É o comando "sugerido" caso quem dê `docker run` seja preguiçoso e não passe nada! EX: Se tem `CMD ["npm", "start"]` e eu rodar `docker run ubuntu bash`... meu `bash` subistituiu por completo e aniquilou a vontade do `CMD`. Ele obedeceu quem chamou!
- **ENTRYPOINT**: É um contrato mais "Sênior". Aquilo VAI e É o core invocado principal. Ele amarra a roda e o que eu rodar no docker run será injetado como ARGUMENTO do Entrypoint. EX: `ENTRYPOINT ["npm"]` e no CMD deixo vazio. Se alguem der um run rodando `docker run site run test` a mágica engole isso e roda internamente na base garantida do NPM virando `npm run test`!

---

### 7. PERGUNTAS DE ENTREVISTA

**Pergunta:** Num Dockerfile focado em um projeto Javascript/NPM, por que copiamos apenas o (`package.json`) primeiro, rodamos o comando (`npm install`), e só depois, como ultimo passo copiamos o nosso código inteiro (`COPY . . `)? Se eu copiar o projeto todo `.` lá na linha de cima pra já matar logo esse passo, isso influencia na imagem final?
**Resposta Sênior:**  Sim, afeta e destruirá a pipeline do CI! O poder do build reside no sistema rígido de Cache das Layers em cascata. Sempre que algo "mudou" em uma linha os bytes assinam diferente, ela mata o cache de TOODAS DAÍ PRA BAIXO. Como nós codamos e salvamos nossos códigos sujos centenas de vezes por dia... se o `COPY . .` do source estiver acima do passo de Instalar Bibliotecas Pesadas.. ele aniquilará o cache de cima a baixo toda vez forçado os runners ou sua máquina a rebaixar o Github/NPM pacotes mil vezes ao dia (5mins vs 1seg de build), quando na verdade não houve alteração no packge.json e apenas o código Javascript sofreu bump de linha de caracter. Portanto, arquivos muito engessados como o manifesto (Requirements.txt / Package.json) sobem, e o arquivo super volátil é o último a subir na pilha.
