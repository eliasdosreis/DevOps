#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Prova de conceito do Auto Scaling zero-downtime da arquitetura Cloud do Swarm.
# É obrigatório testar após o `docker swarm init` ativado na sua máquina local.
# ============================================================

# 1. Starta o serviço na versão 1.0 com UMA UNICA máquina operando 
# (Lembre-se: docker 'service' substitui docker 'run' no modo swarm. Ele vira o seu "State Desejado")
docker service create --name meu_website --publish 8080:80 nginx:1.24.0

# 2. BLACK FRIDAY (ESCALONAMENTO MANUAL DE GRAÇA)
# A blackfriday é amanha e precisa aguentar. O Manager vai receber essa request 
# e na mesma hora olhar pro switch de cluster "Me de mais 4 maquinas". E distribuirá pelas outras ligadas.
docker service scale meu_website=5

# O comando de debug agora é o "ps" do service. E não "ps" normal de container.
docker service ps meu_website

# 3. O UPDATE SEM QUEDA DO SITE E DOS CLIENTES
# No outro mes saiu a versao 1.25 do Nginx.
# Em vez de darmos STOP geral derrubando site na madruga e dando RUN com tag nova..
# O swarm faz um "Rolling Update". Ele mata 1 do pool. Fica com 4. Atualiza 1 pela 1.25 nova. Da Run. Entrou no ar? Ok!  
# Vai pra 2, mata... att e da run.. NUNCA derrubando site nos checkups.
docker service update --image nginx:1.25.0 meu_website

# 4. DEU MERDA!! (ROLLBACK SÊNIOR)
# Caramba o site caiu com Bug no node no codigo novo fudeu!! Back for good!!
# Volte IMEDIATAMENTE PRA TRAS para a image 1.24 de onteeeem!!!!!!
docker service update --rollback meu_website

# Limpeza 
# docker service rm meu_website
