# Módulo 1 — Fundamentos de Containers

Temos a cozinha operando, mas ainda não pedimos nenhum prato. Chegou a hora de rodarmos (e entendermos) nossos primeiros containers fatiando em pormenores o clímax da máquiana: os comandos de inicialização e ciclo de vida.

---

### 1. ANALOGIA DO DIA A DIA

**Container vs. Máquina Virtual (VM)**

Imagine que você precise morar em um lugar por alguns dias:
- **Máquina Virtual (VM)**: Você **compra o terreno**, cava as fundações, sobe as paredes, instala a fiação, o encanamento, compra os móveis exatos que precisa e entra para morar. Tudo é exclusivamente seu, pesado e demorado de iniciar. Cada "VM" tem o seu próprio "Encanamento Base" (Guest Operating System inteiramente próprio).
- **Container**: Você aluga um **Quarto de Hotel**. O encanamento do prédio, a fiação e o sistema central já existem (Kernel do Host Linux). Você entra no seu quarto (Container), fecha a porta e tem a *ilusão* de estar isolado do mundo. Se precisar de outro quarto, a recepção te dá a chave instantaneamente. É absurdamente rápido e compartilha recursos base.

---

### 2. O QUE É (Definição Técnica Senior)

- **Container**: Ao contrário do que muitos pensam, um container *não é uma tecnologia singular*. Ele é uma abstração a nível lógico do Linux baseada na composição de duas features do Kernel:
    1. **Namespaces**: Isolamento de visibilidade (ex: isola o que um processo consegue "enxergar" da rede, arquivos, montagens, inter-processos ou usuários).  
    2. **Cgroups (Control Groups)**: Isolamento de uso de recursos físicos (ex: CPU, memória RAM limite por processo).
    Se você junta Namespaces e Cgroups debaixo de um "guardião" que puxa um sistema de arquivos externo via chroot, parabéns, você inventou um Container.
- **Ciclo de vida**: Pense em estados bem definidos: _Created_ (iniciado os metadados), _Running_ (Processo PID 1 ligou), _Exited/Stopped_ (Processo principal morreu, a festa acabou) e _Deleted_ (Tirado da lixeira).

---

### 3. ARQUIVOS COMENTADOS

Inspecione os arquivos na sequência:
- `01-run-ubuntu.sh`: Como entrar modo interativo que se mantém vivo pelo terminal.
- `02-ciclo-de-vida-nginx.sh`: Como operar servicos de background em modo daemon.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: O Clássico (Foreground & Interativo)**
`docker run -it ubuntu bash`
* **O que faz**: O comando \`run\` é uma junção disfarçada de um comando de \`create\` e depois \`start\`. O \`-i\` avisa que você quer manter o input de teclado aberto e o \`-t\` aloca pseudo interface visual terminal TTY nela, conectando o STDIN/STDOUT na sua frente. E o \`bash\`? É processo PID 1 principal rodando ali dentro. E o \`ubuntu\` é a imagem.
* **Saída esperada**: Você será arrastado de vez para dentro de um prompt de linha de comando \`root@uma_hash_qualquer:/\`.
* **O que fazer lá**: Digite \`ls / \`. Veja os arquivos base (isolamento). Digite \`exit\`. Se o processo principal morrer (bash ao dar exit), **o container morre na mesma hora**.

**Comando 2: O modo correto de Serviços (Background / Detached)**
`docker run -d --name meu-site nginx`
* **O que faz**: O \`-d\` (detached mode) solta processo principal rodando num shell independente nas sombras. Retorna o número de ID longo dele e não agarra seu terminal para si.

**Comando 3: Checando e Removendo**
`docker ps` (Exibe os ligados) e `docker ps -a` (Exibe todos, mesmo os mortos na lixeira).
`docker stop meu-site` (Fornece tempo hábil SIGTERM para o container limpar recursos).
`docker rm meu-site` (Manda pra vala de vez do disco, se antes tiver dado o stop ou passasse a flag \`-f\`).

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Se você der \`docker run ubuntu\` de novo. Ele vai conectar e te dar o shell? Nãaaao!
- **Troubleshooting**: Diferente do \`run -it\` mágico, rodar o `ubuntu` (imagem que tem como default criar processo bash) isolado e sem \`-it\` faz o bash abrir, ver que não tem mouse/teclado para ler... e morrer isolado no mesmo microssegundo sendo jogado na zona de mortos. Lembre-se, Containers _existem_ apenas equanto seu processo principal estiver sobrevivendo ativamente!

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

A principal grande quebra de paradigma de quem vem de VM para Container é o "processo em background e a morte eterna". Note: Containers não foram feitos para atuar perfeitamente como VPS/Sistemas onde 10 pessoas acessam, rodam 10 programinhas dentro, etc... (Isso era o LXC / VMs padrão). **Containers Docker seguem o princípio de um processo único**. (One process per container model). 

Se você mandar rodar um DB no container do seu app Django... de quem vai ser o PID 1 para o Docker entender se morreu ou não? Vai dar ruim na escala ou no uso de recursos. Cada container deve ter uma única responsabilidade atrelada nativamente ao seu processo principal de vida!

---

### 7. PERGUNTAS DE ENTREVISTA

**Pergunta:** Eu liguei um container Nginx com `docker run -d nginx`. Como eu faço para entrar nele para ver um log ou editar uma config rapidinho durante um _incident_ de produção agora que ele ta rodando oculto no background?
**Resposta Sênior:** Você usa o \`docker exec -it NOME_DO_CONTAINER sh\` (ou \`bash\`). O \`exec\` não cria um container novo e nem interrompe o PID 1 do \`run\`. Ele pede licença ao Kernel e injeta um "Processo Adjacicional Novo" (um novo bash iterativo) DENTRO dos Namespaces do container em uso atual. Podendo sair quebrar sem matar o Host principal deles.

**Pergunta:** Se eu uso o `rm` num container parado os dados que gerei nele morrem. Como um container é mais eficiente que VM se as imagens tem 2, 4GB que teremos de "baixar" e instalar sempre quando iniciar um outro do zero ali do lado?
**Resposta Sênior:** Graças ao conceito imaculavelmente performático das *Layers Read-Only* e o *Copy-on-Write* File System (UnionFS/Overlayfs2). As VMs gastam gigas sempre separadas. O container não clona! Se você iniciar 1.000 containers do mesmo "Ubuntu", o disco dele é read-only vindo direto daquela imagem intocável! Apenas os "arquivos modificados/criados" ganham o peso extra em uma pequena camada de read-and-write em cima usando tecnologia de Overlay virtual, economizando absurdos de espaço e velocidade.
