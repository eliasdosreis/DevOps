#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Demonstra o uso de um container interativo efemero. Excelente para 
# debugar problemas em host ou compilar algo e destruir logo em seguida.
# ============================================================

echo "Este script apenas lista os exemplos. Para a real experiência, copie e cole os comandos no seu terminal."
echo ""

# -------------------------------------------------------------
# COMANDO 1: CONTAINER INTERATIVO E INTRODUÇÃO À MORTE DO MESMO
# -------------------------------------------------------------
# docker run         -> Junta O create + start em uma única tacada
# --rm               -> OPCIONAL POREM RECOMENDADO: Assim que esse container for "morto", ele é excluido do disco automaticamente (não fica sujando lixeira)
# -i                 -> OBRIGATORIO: Mantém o canal de STDIN (Teclado) aberto mesmo não atachado.
# -t                 -> OBRIGATORIO: Falsa um pseudo Terminal interativo TTY visual.
# --name meu-ubuntu  -> OPCIONAL: Para voce não precisar usar IDs confusos depois.
# ubuntu             -> OBRIGATORIO: A Imagem base no Hub a ser baixada e usada.
# bash               -> OBRIGATORIO (neste caso): O processo a rodar como base!
# -------------------------------------------------------------

# Experimente rodar agora mesmo:
# docker run --rm -it --name meu-ubuntu ubuntu bash

# Lembre-se: se você sair do "bash" (digitando exit dentro do container), 
# O processo acaba e portanto o container para na hora. Devido a flag --rm, 
# você nem sequer verá ele no `docker ps -a`. Ele evaporou na matrix.
