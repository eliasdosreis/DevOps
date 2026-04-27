# Módulo 0 — Preparação do Ambiente e Arquitetura do Docker

Bem-vindo ao início da sua jornada rumo ao nível Sênior no Docker. Antes de rodarmos nosso primeiro container, precisamos entender como o Docker "conversa" internamente. 

Vamos analisar a **Arquitetura Cliente-Servidor** do Docker.

---

### 1. ANALOGIA DO DIA A DIA

Imagine o Docker como um grande **Restaurante**.
- O **Você (Docker Client)**: É o garçom. Você anota o pedido e repassa. Você não cozinha nada, só envia comandos.
- O **Cozinheiro (Docker Daemon/Engine)**: Fica escondido na cozinha. Ele é quem pega a receita, junta os ingredientes e prepara o prato de fato (cria e gerencia os containers).
- O **Livro de Receitas na Biblioteca (Docker Registry / Docker Hub)**: Quando o cozinheiro não sabe fazer um prato, ele baixa uma receita padrão (imagem) da internet para poder prepará-la na cozinha.

Você (garçom) e o cozinheiro podem estar no mesmo lugar (sua máquina local) ou em lugares diferentes (Docker num servidor remoto e você acessando do seu terminal).

---

### 2. O QUE É (Definição Técnica Senior)

A arquitetura do Docker é dividida de forma estrita em três componentes principais através de uma API REST:
* **Docker Client (`docker`)**: É a CLI (Command Line Interface). Seu único trabalho é formatar solicitações via chamadas de API e enviá-las.
* **Docker Daemon (`dockerd`)**: O processo de background (servidor) que escuta as requisições do client e gerencia os objetos do Docker: Images, Containers, Networks e Volumes.
* **Docker Registry**: O repositório onde as imagens estão armazenadas (ex: Docker Hub privado/público, AWS ECR). O Daemon fala diretamente com o Registry para fazer o *pull* das imagens.

---

### 3. ARQUIVO COMENTADO

Veja o arquivo `01-verifica-ambiente.sh` na mesma pasta. Ele realiza a verificação de saúde dessa comunicação.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: Qual a versão do meu Client?**
`docker --version` ou `docker -v`
* **O que faz**: Mostra rapidamente apenas a versão do Client (a CLI do garçom). Ele nem sequer tenta falar com a cozinha (Daemon).
* **Saída esperada**: `Docker version 24.x.x, build xxxxx`

**Comando 2: O Garçom e o Cozinheiro estão se comunicando?**
`docker info`
* **O que faz**: Obriga o Client a bater na porta do Daemon e compilar um baita relatório sobre ele. Mostra quantos containers existem, versão do Kernel, Storage Driver sendo usado, etc.
* **Saída esperada**: Uma longa lista de informações de sistema começando com `Client:` e terminando mostrando os status do `Server:`.

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

Como confirmar que você está pronto para seguir aos próximos módulos? Execute o comando `docker info`.
Se a tela mostrar uma lista de plugins e depois do bloco "Client" mostrar um bloco longo do "Server", você tem 100% de sucesso.

**Erros mais comuns no ambiente de desenvolvimento:**
* `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`
   **Problema**: O Client (Garçom) tentou gritar, mas a cozinha (Daemon) está fechada. O processo `dockerd` não está rodando.
   **Solução (Windows/Mac)**: Abra o aplicativo Docker Desktop.
   **Solução (Linux native)**: Rode `sudo systemctl start docker`.

* `permission denied while trying to connect to the Docker daemon socket [...]`
   **Problema**: Apenas o usuário root, ou usuários do grupo especial `docker` podem falar com o Daemon (por questões de segurança severa).
   **Solução**: Rode com `sudo` ou adicione seu usuário ao grupo do docker: `sudo usermod -aG docker $USER`.

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

Por que a separação Client/Daemon é tão genial?
**Desacoplamento e Segurança**. Um Sênior sabe que em servidores de produção reais, NINGUÉM entra nas máquinas por SSH para rodar comandos `docker run`. 
O Client `docker` frequentemente roda na máquina do CI/CD (ex: GitHub Actions) apontando para o host remoto de produção apenas por chamadas de rede TCP seguras usando os flags `DOCKER_HOST`. 
O Docker Desktop do seu Windows faz algo parecido: O Client é um `.exe` rodando no Windows puro, mas a "cozinha" (Daemon) está blindada lá dentro do WSL2 (VM Linux leve). Para eles se comunicarem eles usam named pipes ou sockets expostos pelas costas.

---

### 7. PERGUNTAS DE ENTREVISTA

**Pergunta:** O processo do Docker no host caiu ("crashou" / morreu). O que acontece com os containers que estavam rodando?
**Resposta Sênior:** Depende de uma feature avançada chamada "Live Restore". Historicamente, se o Daemon morresse, todos os processos containerizados também morriam. Hoje em dia, boas práticas de Sênior preveem ativar a configuração `live-restore: true` no `/etc/docker/daemon.json`. Se essa feature estiver ligada, o Daemon morre e ressuscitá não afeta os containers em andamento, mantendo o uptime da arquitetura.
