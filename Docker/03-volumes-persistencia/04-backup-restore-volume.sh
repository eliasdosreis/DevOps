#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Prova definitiva de como fazer Backup de Named Volumes para fora,
# para que você possa salva-los num Google Drive e restaurar depois.
# ============================================================

# 1. CRIANDO O VOL E POPULANDO
docker volume create meu_bd_volume
# Ligamos um container qualquer só pra gravar 1 texto lá dentro do volume.
docker run --rm -v meu_bd_volume:/dados alpine sh -c "echo 'Arquivo super importante de 2026' > /dados/arquivo.txt"

echo "--------------------------------------------------------"
echo "O VOLUME TEM A MENSAGEM. AGORA VAMOS FAZER O BACKUP (.TAR)"
echo "--------------------------------------------------------"

# 2. FAZENDO BACKUP PRA MAQUINA HOSPEDEIRA HOST (C://)
# Explicando o truque Senior:
# Usamos o 'ubuntu'.
# -v meu_bd_volume:/volume_alvo (Leva nosso db pra dentro dele)
# -v PWD:/pasta_de_backup_na_minha_maquina_c (Leva a nossa pasta local de fora tbm)
# Rodamos um comando bash "tar" la dentro dele, zipando as coisas de uma pasta pra outra.
docker run --rm \
  -v meu_bd_volume:/volume_alvo \
  -v $PWD:/pasta_de_backup_na_minha_maquina_c \
  ubuntu tar cvf /pasta_de_backup_na_minha_maquina_c/backup_bd_oficial.tar /volume_alvo

echo "Gerou arquivo backup_bd_oficial.tar na sua pasta atual!"

# 3. O FIM DO MUNDO (Seu servidor AWS pegou fogo, vamos reformatar)
docker volume rm meu_bd_volume

echo "--------------------------------------------------------"
echo "FOI PARA O ESPAÇO. VAMOS RESTAURAR EM UM VOLUME NOVO DO 0"
echo "--------------------------------------------------------"

# 4. RESTAURAÇÃO DE DESASTRE (Disaster Recovery)
# Nasceu um volume virgem
docker volume create volume_virgem_recuperado

# Usamos a mesma maracutaia: montamos o volume num linux burro temporario, e injetamos
# O Nosso TAR de backup C:// tambem nele. Extraimos o TAR com `tar xvf` de voltra pra dentro!
docker run --rm \
  -v volume_virgem_recuperado:/volume_alvo \
  -v $PWD:/pasta_de_backup_na_minha_maquina_c \
  ubuntu bash -c "cd /volume_alvo && tar xvf /pasta_de_backup_na_minha_maquina_c/backup_bd_oficial.tar --strip 1"

# 5. TESTE DE FOGO
# Entrando nesse volume recuperado pra ver se o texto mora la!
docker run --rm -v volume_virgem_recuperado:/dados alpine cat /dados/arquivo.txt

# Limpa o txt gerado aqui fora localmente
# rm backup_bd_oficial.tar
