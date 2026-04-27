# ============================================================
# GABARITO: O DOCKERFILE DEFINITIVO SENIOR EDGE-CASE
# Cobre cache, security limits, e node-prunning.
# ============================================================

# ---------- STAGE 1: COMPILADOR BRUTO ----------
FROM node:20-alpine AS builder

# Atualizações de Seguranca severas de SO no step sujo 
# usando a flag --no-cache que não corrompe o apt-state dps da run
RUN apk upgrade --no-cache

WORKDIR /app

# The Cache Holy Grail
COPY package*.json ./
# O ci apaga TUDO de modulos do host q tenha passado do dockerignore 
# e instala fresco da arvore do lock puro.
RUN npm ci

# Copia o repo inteiro (- os node_modules q vc botou no .dockerignore ne?)
COPY . .

# Simula uma compilação de Typescript pra puro JS na pasta build/
RUN npm run build 

# Limpa o Lixo local de devs do NODE modules dessa layer,
# ja q o compile Typescript rodou.. mantem só pro bundle prod.
RUN npm prune --omit=dev


# ---------- STAGE 2: IMAGEM NUA FINAL A SER ENTREGUE ----------
FROM node:20-alpine AS runner

WORKDIR /app

# Hardcoding variaves ambientais logicas 
ENV NODE_ENV=production
ENV PORT=3000

# Sequestra apenas os modulos e scripts compialdaos da estagio 1.
# Adote chown no pull para garantir a chave Mestra!
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/build ./build

# Metadado
EXPOSE ${PORT}

# Degrada o process tree da JVM pra modo civil blindado (Estagiário)
USER node

# Toca o baile.
CMD ["node", "./build/server.js"]
