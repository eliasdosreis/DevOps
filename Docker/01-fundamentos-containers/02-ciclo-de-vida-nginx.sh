#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Apresenta a forma em que um Sênior gerencia os states
# de um processo web em andamento real de produção sem
# travar o teclado da pipeline.
# ============================================================

# 1. RUN
# O flag -d (detached) é seu principal aliado. Inicia o web server
# debaixo dos panos, sem cuspir todos os relatorios de requisição HTTP na sua cara
# travando seu shell.
docker run -d --name app-venda nginx

# 2. STATUS (PS)
# Como sabemos que ele subiu se não vimos nada?
# O "ps" (process status) isolado lista os ativos no exato minuto.
docker ps

# 3. LOGS
# Ok, ele esta rodando ali (-d). Mas e se der erro no código lá dentro?
# Um server web loggeia acessos no stdout. Ao invés de precisar dar -it pra bater o olho...
# usamos -f (follow) igual o "tail -f" no linux host native para "seguir" o fluxo
docker logs -f app-venda
# (Aperte Ctrl+C para desgrudar dos logs)

# 4. PARANDO (E NÃO DELETANDO)
# Isso envia um Sinal Unix "SIGTERM" amigável. "Salve os relatórios, vou encerrar as sessoes do banco e ja te apago"
docker stop app-venda

# 5. ONDE ELE FOI PARAR? LIXEIRA VIRTUAL (PS -A)
# O estado agora no File System é "Exited".
docker ps -a

# 6. LIGANDO DA LIXEIRA NOVAMENTE
# Repare que agora NÃO USAMOS O COMANDO RUN. O run era Create + Start.
# O create já foi! Nós apenas startamos novamente. A máquina alavancará a layer salva.
docker start app-venda

# 7. INJEÇÃO DE CODIGO / CHAVE MESTRA
# Seu Nginx ta rodando mas precisou ler um arquivo as pressas?
# O exec injeta um SEGUNDO processo na caixinha aberta. Se sair nao morre!
docker exec -it app-venda sh 
# (digite exit pra sair)

# 8. REMOÇÃO COMPLETA
# Vamos matar ele de vez. Forçando se estiver vivo ainda.
# O Flag -f (Force - SIGKILL 9) nem fala tchau, mete uma facada fulminante no PID 1.
docker rm -f app-venda
