#!/bin/bash

# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Mestre dos magos nas entrevistas técnicas. Qual a diferenca entre
# ENTRYPOINT e CMD na hora de quem usa a sua imagem? Mostaremos aqui.
# ============================================================

# Imagine que eu criei a iamgem com a flag base asimm:
echo 'FROM alpine' > Dockerfile.teste
# Ela SÓ TEM CMD. Que por padrao se alguem sobrepscrever no run "echo hello", obedece quem escreveu.
echo 'CMD ["echo", "Sou o default"]' >> Dockerfile.teste
docker build -t image_com_cmd_teste -f Dockerfile.teste .


# Imagine que eu criei a imagem com ENTRYPOINT
echo 'FROM alpine' > Dockerfile.teste2
# Ela TEM ENTRYPOINT. Ele é IMUTAVEL. Se um cara passar "echo" ali embaixo, ele pega a string echo e joga como ARGUMENTO DO PING!! E quebra! Ele tranca a roda base.!
echo 'ENTRYPOINT ["ping", "-c", "2"]' >> Dockerfile.teste2
docker build -t image_com_entrypoint_teste -f Dockerfile.teste2 .

echo "--------------------------------------------------------"
echo "O RESULTADO NA MESA:"
echo "--------------------------------------------------------"

# 1. Comportamento do RUN no CMD normal que todo mundo usa:
# O Que acontece? Ele vai rodar o "echo 'FuiHackeado'". O CMD antigo foi substituido covardemente.
docker run --rm image_com_cmd_teste echo 'FuiHackeado e ignorei o default'

# 2. Comportamento do RUN no ENTRYPOINT
# O Que acontece se o Usuario quiser forcar pra quebrar o software? E Tentar dar echo?
# Ele vai TENTAR DAR EXECUCAO DO PING NO DESTINO DA PALAVRA 'echo' E FALHA PERFEITAMENTE SEGURANDO O APP no formato padrao!!
# (Ele converte seu 'echo' virando => ping -c 2 echo ... e dá bad address!)
docker run --rm image_com_entrypoint_teste echo

# Se o dev usar com a palavra certa de Argumento, o Entrypoint aceita e completa:
docker run --rm image_com_entrypoint_teste google.com

# rm Dockerfile.teste*
