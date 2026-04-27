#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Exemplifica a flag -v no modo BIND absoluto. Aonde você espelha 
# bidirecionalmente a SUA pasta com uma pasta que nascerá la dentro.
# Ideal pra mexer no codigo Node na sua IDE e bater F5 no browser
# e o Server que tá rodando LÁ DENTRO ler imediato, sem re-build.
# ============================================================

# 1. Preparação (Pra evitar dar erro de Not Found no bind)
mkdir -p codigos_meus
echo "console.log('Opa, liguei pelo Bind do Local!');" > codigos_meus/app.js

# 2. RUN
# (HostFolder):(ContainerFolder)
# Substitua $PWD por ${PWD} caso rode isso cru via powershell.
docker run -v $PWD/codigos_meus:/app node:20-alpine node /app/app.js

# 3. Limpeza do ambiente de teste caso queira
# rm -rf codigos_meus
