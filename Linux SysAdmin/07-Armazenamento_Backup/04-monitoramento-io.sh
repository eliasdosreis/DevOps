#!/bin/bash
# ==============================================================================
# Aula 07.04: Backup e Storage - Monitoramento Sênior I/O e SMART Tests (HDD/SSD)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Dirigir Um Carro Giga de Luxo "A Cento E Vinte Sem Ver o Painel Em Uma Retona"
# Uma Hora O Tanque Zera.. O Pneu Fura E O Computador Não te Avisou! E Seu Motor (Sistema Operacional) Explode.
# 
# DF/DU -> São os Indicadores Do Seu Painel De Gasolina Humano. (Gás da Partição Root /) Sobrando!
# Smartctl -> É O Analisador de Oleo Do Motor (Avisa Com As Válvulas Se O Seu SSD Da Servidor "SDB_DATA" Vai Morrer Fisicamente Em 3 Dias Por Sobrecarga Escrita Da Placa! Pela Chip Da Samsung Lendo O Termostato Interno Cego!).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Monitoramente de Inodes/Bytes Livres Atrelados Em Tabela FHS do Virtual File Sys local Posix = DF/DU.
# Monitoramente de Vazamentos Da Controladora (I/oStat Waits/Latencia) Em Kernel Ring e Analises Previsivas Falhas Internas Do Silicone/Braços HardDrive (S.M.A.R.T Tools: Self-Monitoring, Analysis, and Reporting Technology Mapeamentos Cego Físico).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# O PAINEL DE COMANDO BÁSICO
# Lista TUDO das pontes (Mounts). Parâmetros "h" (Human Readable MB/GB), "T" (Imprime File Sys Ext4 Certo pra Validacoes Cloud).
df -hTh                       # OBRIGATÓRIO (O Que Eu Mais Digito de 8 as 18h no PC).

# "AONDE TÁ O GASTO DESSES GIGAS NESTA PASTA /VAR?!" (Busca Das Pesadas).
# Você entra lá... Tem 40 Pastas Log/Lib/Run... Como Achar O Ofensor? O Duplicador?
# O "Disk Usage (du)" Pesa 1 por 1 com Parâmetros "Sênior De Summary Máximo de Extensão 1 Unidade Direta". E Usa O "Sort -h" Pra Ordenar Do Maior Pro Menor Na Tela De Top! (As Lincences Do Lixo Acima Enorme No Fundo Top).
du -sh /var/* | sort -rh | head -n 10  # CAÇADOR DE CULLPADOS NUMA LINHA 1 LINUX NATIVE! SÊNIOR ABSOLUTO NAS GAVETAS DE BD! (Você acha o log de Erro de 98 GB Em 1 Segundo com isso!).

# LEITURA DE CHIP DE HARDWARE DA MORTE SMARTCTL:
sudo smartctl -H /dev/sdb     # Faz A Leitura Padrão Health Bruta: RESULTADO "PASSED" OU "FAILED IMMINENT FAILURE!".
sudo smartctl -a /dev/sdb     # Abre O Laudo Completo Em Inglês Dos Metadados Samsung de Erros De Relocated Sector Count Cego E Temperatura E Gasto Vida.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] iostat -dx 1
# [O QUE FAZ] Pacote Sysstat Master. Quando o HD tá Com Gasto Giga Cego... O Sistema Fica Lerdo Que Tudo Trava! Mas Memoria tem... E Cpu Tá 0% Uso?? O Load Da Aula Passada Ta Loto Em Wait Io?
#             Rode isso. Ele Atualizará De 1 Em 1 Segundo `1` A Matriz X De Discos De Leituras Constantes Do Hd E Fila AvgQu-Sz de Gravação De Bytes/Escrever Milisegundos Do IObit!
#             Se A Fila Do (AqU-Sz) Estive Cheia Batendo %UTIL DE MÁXIMO (100%), Seus Discos Não Conseguem Responder Mais Nenhum Select do Banco!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - CENA CLÁSSICA: "MEU BANCO CAIU POR "NO SPACE LEFT ON DEVICE" NA ROOT (/)".
#   Você Fica TENSSO PACAS... Corre NO TECLADO ROOT, e digita O Salvador `df -h`. E LÊ O REPORT:
#   ` /dev/sda1 (ROOT /)     Tamanho 50G.  Livre: 28 GIGABYTES (5% Used!!!!)`.
#
# COMO CARALH#S TEM 20 GIGAS SOBRANDO, O HD TÁ VAZIO.. MAS NÃO GRAVA NEM UMA VÍVEL DO SQL CUSPINDO ERRO DE "NO SPACE LEFT ON REDAÇÃO" NO SYSTEM LOG? TEM VIRUS CORTANDO EU MAGICALMENTE DO HD CEGO?
# O SEGREDO DOS MILENIOS DE I-N-O-D-E-S: 
# Execute Sênior: `df -i`. Ele MOSTRA QUANTOS PAPEIS DE ARQUIVO VOCE USOU NO FHS TAB INODE CEGO!! E VAI DAR `100% USO (15 MILHOES USADOS, 0 LIVRES)`. 
# Um Script de Backup Errante Do Junior Cagou E Vomitou 20 Milhoes de Logs de TEXTOS EM BRANCOS DE CABEÇALHO NA /TMP... ZERO BYTES DE PESO... MAS ESTOUROU O FÍSICO ARQUITETURAL DE LIMITE NUMERICO DA EXT4 MAXIMO DE 15 MILHOES INODES (CRIANCAS REGISTRADAS NA PRANCHETA DA RUA). O ARQUIVE NÃO CABE MAIS LETRA, POIS NÃO EXISTE NUMERACAO NOVA PRA DAR DO REGISTRO DE CARTORIO!! SEU HD ESTA MORTO POR NUMERAÇÃO FILE ID E NÃO DE PESO!! Você Apaga O Lixo Com Um FIND Especial de Arquivos Minúsculos Zero Bytes Vazios e O HD VOLTA!!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Deletar O Log Gigante Em Produção De App Mal Feito Corrodor Sem Crashar O Server Dele:
# Banco E App Produção Rodando. Ele tá em 99% De HD Cheio na raiz. E Faltam Miliseguntos.
# O App Java não Tem Rotação Automática (LogRotate Que veremos). AÍ O JÚNIOR MATA ELE FÍSICO COM `rm -rf arquivo.log`. E O HD NÃO DIMINUI DE GASTO NO DF -H!
# PORQUE? Se O Arquivo File Esta "Opened / Listening By PID" Na CPU Core. O HD FISICO FICA ABERTO COM PONTEIRO FIXO NELE MESMO DEPOIS DE VOCE TIRAR O NOME DELE NA RAIZ E ELE NAO SOLTA NO DF -H JAMAAAIS GASTANDO LÁ INVISIVEL E LOTA E TRAVA! (O Espaço Fantasma File Delete Lsof).
# 
# Você Precisa Parar (Downtime Cego) a Applicação, Ou Esvaziar o Copiado VAZIO COM TRUNCATE NELE ONTHE FLY VIVO (Zeroing EOF Linux Mestre Em Pipe)!
# EXECUTE O COMANDO RAIZ DE DEVTOOLS UNIX > `> /var/log/nomedolog_foda.log`. Pronto!!!! (Truncate Empty Redirection Bash / Echo " " > Log_). Reduz De 10GBs Cego pra 0 Byts Mágicos em Tela e o DF -h Desaba pra Seguro Livrando RAM Sem Derrubar O Docker Core 100% Cego Acoplando I/Operations Flush Liso.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Módulo AWS Storage Alertando Que A Raiz Fhs Está Sofrendo Gargalo Tremeto De Espaço Consumo Na Volume EbS Mapeado Local (Alert 88%). Nossa Engenharia Sênior Lança na Sessão `du -sch /var/log/*` No Datacenter e constata 5 Pastas Acima de 900 GBs Quebradas CADA UNA Ali Na Raiz Listadas Cego. E Uma Delas Chama `/var/log/antigos_Lixos_Docks/`. Pela Exclusão Da Operação Larga Do Script Base Nós Lemos RM em 'Lixos_Docks/*' E Ele Responde Que A Operação Foi Executada Mas Falhou Imediata 'Argument List Too Long Morte' Devolvendo Erro Posix de Variáveis. Como o Sysadmin Sobrevive Extrapolação Terminal Maxima Sem Ferramentas Extras Nativas Base E Resolve Esse Delete?"
#
# Resposta Esperada: "O Problema clássico Argv/Argc Limit Buffer Execution Array Kernel. O utilitário `rm *` Aciona Um Expander Bash No Console (Globbing) De Milhões De Palavras Do Diretorio e Injéta Essas Strings Gigantes Todas Unificadas Pra Dentro Das Arrays Internas Do Cmd Comando RM. Estorando o 'MAX_ARG_STRLEN' Compilado Do C-Language Linux E Vomitanto Argument Too Long Reject Bypassing. O Contorno Oficial Cego É Lidar Com Streams Longas Em Buffer Reduzido E Alimentado Sob Comando Múltiplo Atachado Em Loops Limitados De ForOuFind-Cexec: 
#  `find /var/log/antigos_Lixos_Docks/ -type f -delete` (Execucao de Fila Encadeada Nativista Diretural Pela Array Find Engine Memory Directo C-Syscall). O Limpa Todo Ilimitado Lixo Liso."
