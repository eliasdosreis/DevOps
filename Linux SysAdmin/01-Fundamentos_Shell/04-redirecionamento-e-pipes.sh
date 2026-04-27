#!/bin/bash
# ==============================================================================
# Aula 01.04: Fundamentos do Shell - Redirecionamento e Pipes (>, >>, |, 2>&1)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Imagine que um comando do Linux é uma máquina de fazer suco. Você joga laranjas 
# nela, ela faz barulho, e joga o suco na sua cara (a tela do terminal).
# 
# Pense no **Pipe (|)** como um cano plástico: Você conecta o cano na boca da
# máquina, e leva o suco DIRETO para uma forma de picolé (outro comando), sem
# sujar a tela. Ex: Laranja | Maquininha_Suco | Freezer = Picolé.
#
# Pense no **Redirecionamento (>)** como jogar o suco direto dentro de uma Garrafa
# (um arquivo no HD) para ninguém mais ver.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Processos POSIX possuem 3 canais de comunicação I/O padrão numéticos (File Descriptors):
# - 0: STDIN  (Standard Input) - O que entra via teclado para o programa.
# - 1: STDOUT (Standard Output) - A resposta/saída de sucesso do programa pra tela.
# - 2: STDERR (Standard Error) - A mensagem que relata um erro pra tela.
# Nós podemos redirecionar explicitamente esses descritores para arquivos ou outros
# processos via RAM (usando Fifo Pipes), sem tocar no HD.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# > (Sinal Maior Que): Redireciona o STDOUT substituindo TUDO do arquivo alvo.
# Sobrescreve "Ola" no arquivo (se não existe arquivo, ele cria na hora).
echo "Ola" > /tmp/teste.txt         # OBRIGATÓRIO: Destrói o arquivo alvo pra jogar dados novos.

# >> (Dois Sinais Maior Que): Redireciona Fazendo APPEND (Agregando no final).
# Adiciona "Mundo" na linha debaixo de "Ola", preservando os dados anteriores.
echo "Mundo" >> /tmp/teste.txt      # OBRIGATÓRIO: Adiciona ao log/arquivo.

# O | (Pipe, a barra vertical do teclado): Pega o STDOUT da esquerda, e injeta
# como STDIN no comando da direita em RAM (em tempo real).
# 'ls /usr/bin' tem uns 2 mil programas. Se você dar na tela, ele voa até o fim.
# Então eu envio a lista toda pro comando 'less' que vai me deixar ler como livro.
ls /usr/bin | less                  # OBRIGATÓRIO: Encadeamento que chuta o dado pra mão do seu colega.

# Pega todos os processos do sistema (ps aux) e joga eles via ralo pro 'grep' achar o Nginx.
ps aux | grep nginx                 # OBRIGATÓRIO: Filtrando o que você quer ver de forma elegante.

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# O "Encanamento Duplo" com o TEE (Letra T do Encanador)
# E se você quiser LER O SUCO NA TELA enquanto a máquina também ENFIA ELE NA GARRAFA (Arquivo)?
# O `>` cega sua tela. O `tee` duplica a mangueira!
apt update | tee /tmp/update.log    # SALVA-VIDAS: Processa o STDOUT para a sua visão (tela) mas ao mesmo tempo copia fisicamente pro log.txt

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] cat /var/log/syslog | grep error >> /tmp/meus_erros.txt
# [O QUE FAZ] (1) Lê o log inteiro, (2) passa pelo pipe pro grep separar SÓ o
#             que for erro crítico, (3) pega apenas as falhas e INSERE E SALVA 
#             num arquivo pessoal /tmp dizendo respeito apenas aos erros reais.
# [SAÍDA ESPERADA] Nenhuma! A tela vai ficar na linha em branco. A saída verdadeira
#                  foi secretamente desviada pro arquivo '.txt'.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# ERROS COMUNS:
# - Ao digitar `ls /pacote-que-nao-existe > log.txt`, e ir ver o arquivo, 
#   ele estará *Vazio*. Mas na sua tela apareceu brilhando "Arquivo Inexistente". 
#   Por quê? 
#   Você redirecionou apenas o `1` (STDOUT/Sucesso). Erros são jogados no
#   Canal `2` (STDERR), então o erro burlou o canal '> log.txt', porque não era Sucesso,
#   e voou pra "sua cara" (tela, output padrão de erros).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Um Júnior vai preencher um pen-drive rodando um instalador: `install > log.txt`.
# Meia hora depois, o chefe viu na tela uns erros bizarros que subiram e apitaram,
# e pede o arquivo `log.txt` pra investigar. O júnior entrega achando que sabe tudo. 
# Quando o chefe abre, *o erro não está lá*. Aí ele descobre que o Júnior não entende
# File Descriptors Linux e é demitido por inaptidão. (Exagero, mas acontece frustração!)
#
# Um Sênior DEVE unificar os File Descriptors em rotinas autônomas e backups.
# Ele roda: `install > log.txt 2>&1`
# O mágico `2>&1` significa: "Linux, por favor, redirecione o tubo do Erro (2) ENFIANDO 
# ele por dentro do cano do Sucesso (1). E como o número (1) já está indo pro arquivo,
# os dois cairão misturados pro meu chefe ler a vida real depois".

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa rodar um shell script gigante `/opt/scripts/migrate.sh`
# por 3 horas no nosso Banco de Produção, que ficará jogando Output e Errors o 
# tempo inteiro. Você precisa rodar no background. Mas nós não queremos NEM o STDERR
# e NEM o STDOUT salvos em disco pois estão estourando o Limite de Inodes do disco /var/log.
# Como eu lanço esse executável enterrando a saída?"
#
# Resposta Esperada: "Devemos descartar toda a saída usando o Black Hole do Linux
# com o arquivo null. O comando seria: `/opt/scripts/migrate.sh > /dev/null 2>&1 &`.
# Redirecionamos a saída padrão pro Lixo (/dev/null), conectamos as saídas de Erro (2)
# à Saída Padrão Lixo (1), e o Amperstand (&) executa no Background (Desacoplado) pra
# podermos fechar nosso terminal em paz."
