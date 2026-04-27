# Raio-X Comparatório Arquitetural

Um SysAdmin Senior avalia a sua maturidade DevOps simplesmente lendo
como você estruturou sua imagem do começo ao fim.

## O Jeito JÚNIOR (Inseguro e Pesado)

```dockerfile
# 1. FROM Gigante com CVEs desnecessários.
# Pesa 1GB e tem compiladores inteiros de gcc sobrando ali pra atacantes usarem em reverse shells
FROM ubuntu:latest

# 2. Usuário Root
# Se alguem rodar codigo malicioso no app JS e "escapar" do docker, vai conseguir 
# dar rm -rf no HD físico do host hospedeiro la de fora!

# 3. Layers fragmentadas desnecessarias pesando infinitamente.
RUN apt-get update
RUN apt-get install -y nodejs npm curl wget nano

# 4. Copiando lixo local (A pasta .git e node_modules locais vão pesar mais 2GB juntos)
# Afinal alguem não sabe os motivos de usar .dockerignore.
COPY . /meu_app

# 5. O Cache do NPM NUNCA ENTRA EM AÇÃO!
# Ele colou o COPY antes. Se der Control+S no seu Codigo Fonte ali.. fudeu,
# o apt update inteiro demora 30 min pra rodar de novo na cloud de graca gastando dinheiro.

WORKDIR /meu_app
RUN npm install

CMD ["npm", "start"]
```

<br><hr><br>

## O Jeito SÊNIOR (Blindado e Compacto)

```dockerfile
# 1. Base Menor e Mais Específica (Oft / Alpine / Distroless)
# Pesa 40mb. Contém apenas a VM engined o node. Nada de wget ou apt.
FROM node:20-alpine AS build

WORKDIR /app

# 2. Respeito MÁXIMO da ordem de cacheamento 
# Só quebra a build de baixo se mudar dependencias, salvando 5 min toda vez q da ctr+S
COPY package*.json ./
RUN npm ci

# 3. Restrição de cópia final de modulos limpos e builder stage focado apenas no bundle

COPY . .

# ----------------- FASE FINAL -----------------

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Define USUARIO NAO-ROOT DE SEGURANÇA MÁXIMA
# Se o JS falhar, ele tá restrito e confinado e não tem permissões no Daemon host
USER node

# Traz apenas o Bundle enxugado da step 1!
# Cuidado Senior extra: O COPY exige dar os direitos da pasta do codigo para este usuario fraco tambem!
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/src ./src


CMD ["node", "./src/server.js"]
```
