#!/bin/bash
# ==============================================================================
# Aula 04.02: Processos e Recursos - Background Jobs (&, bg, fg, Ctrl+Z)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Você liga para o atendimento do banco (Terminal Shell).
# O Atendente atende, e você pede: "Faça um cálculo imenso na minha conta".
# O atendente diz: "Aguarde na linha..." (Processo Foreground). Você fica 30
# minutos ouvindo musiquinha, sem poder usar o celular pra mais nada, e se 
# a linha cair (SSH fechar), o cálculo aborta!
#
# Com o Job Control do Linux:
# Você liga, dá a ordem, pede o Protocolo, e diz "Faça o cálculo mas EU DESLIGO 
# AGORA (+&). Mande a resposta pro meu email (arquivo de log) quando acabar!".
# O atendente faz (Background Job), e sua linha de telefone fica **Livre 
# na mesma hora** pro próximo comando `ls`!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O Shell POSIX possui um rastreador de Sessões de Jobs.
# Um Job (Trabalho) não é um Processo puro. Ele é Parente de Sessão do seu Bash
# atual. Se o binário engolir o TTY Inteiro (Foreground/Frente das Luzes), ele
# bloqueia o Input Stdin do teclado até ter Retorno 0 ou 1.
# Rodar processos em 'Background (bg)' desacopla o Stdin dele do terminal e
# retorna o Prompt (#) instantaneamente pra você agir em paralelo.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# INICIANDO JÁ DESCONECTADO (&).
# O Ampersand 'E Comercial' no final do comando é o Ouro dos SysAdmins.
tar -czf site_backup.tar.gz /var/www/site &  # OBRIGATÓRIO: Compacta 100GB Mas sua tela libera na HORA.

# O COMANDO PARALISADOR: Ctrl + Z
# Você esqueceu o Ampersand (&) gordo e digitou `tar` de 100 Gigas.
# A tela travou preta! Tá compactando e não deixa você trabalhar!
# Como eu coloco ele pra fundo SEM MATA-LO COM CTRL+C? 
# 1. Aperte CLTR + Z. (O Linux vai "CONGELAR" no Tempo/Stop Signal o zipador).
# 2. Depois rode:
bg                          # OBRIGATÓRIO: (Background) Manda o job que você pausou VOLTAR a rodar no mundo das sombras.

# LISTANDO AS SOMBRAS DO SEU TERMINAL (Jobs Ativos amarrados aqui)
jobs                        # OBRIGATÓRIO: A resposta será: [1]+  Running   tar -czf ...
# Tem o número 1 mágico ali? (Job ID=1)

# TRAZENDO DAS SOMBRAS DE VOLTA PRA TELA (Foreground).
# Você quer assistir o tar finalizar pra ler na tela a resposta?
fg %1                       # OBRIGATÓRIO: O comando Background Volta pra Frente engolindo sua TTY do Job 1.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] nohup /root/limpeza_gigante.sh &
# [O QUE FAZ] 'nohup' (No Hang-Up). Desliga o Signal Sessão (SIGHUP) do Linux.
#             "Por que usar Nohup e '&' Juntos, Sênior?"
# [VISÃO SÊNIOR] Porque Jobs Ativos normais com '&' estão AMARRADOS na sua tela PuTTY atual!
#                Se a internet da sua casa cair e o Windows fechar o SSH, 
#                O Linux manda um SIGHUP em CASCATA e MATA aquele ZIP de 10 Horas na 9ª hora!!
#                O prefixo `nohup` deixa o Job órfão imortal pro Init Adotar (1), e o SO não
#                o encerra jamais, mesmo que sua internet evapore. A saída dele 
#                vai sorrateiramente escrita por padrão no arquivo `nohup.out` ao invés da tela morta.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: Eu digitei um Job com o Ampersand `atualizar_site > log.txt 2>&1 &`. Ele deu Retorno
#   `[2] 24515` E VOLTOU O PROMPT PRA MIM! Mas logo abaixo o prompt Cuspiu um monte de Enter.
#   Por quê? 
#
#   O Backgroud Job só desacopla O INPUT (O TECLADO). ELE NÃO DESACOPLA OUTPUT DE TELA!
#   Se o app tiver Outputs na string de Código C lá dentro de "Echo Isso, Echo Aquilo",
#   Esses Echos vão voar por cima das suas linhas do Prompt de comando causando caos visual 
#   enquanto você tenta digitar! SEMPRE esconda ` > /dev/null 2>&1 ` na assinatura do Ampersand 
#   pra processos tagarelas (O Nosso Descarte /dev/null visto na Aula 1.4).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# A maldição do "Nohup" legados vs Multiplexadores de Terminal modernos (Screen / Tmux).
# Um Desenvolvedor hoje não roda coisas de 10 horas com `nohup`.
# Uma das melhores coisas que um SysAdmin / Segurança Sênior faz quando acessa em Produção
# O Linux remoto é rodar `tmux` ANTES DE FAZER DEPLOYs PESADOS. 
# O Tmux cria um "Windows Virtual Persistente" no terminal Server Side. Se a internet dele cair
# A Tela que tá atualizando o Linux (apt upgrade) lá no Datacenter CONTINUA LÁ RODANDO. 
# Ele do 4G no aeroporto conecta de volta, roda `tmux attach` E TRAZ A TELA DE DEPLOY 
# PRA CONTINUAR OLHANDO OS ERROS exatamente de onde parou. O Background Job amadureceu
# para Multiplexadores TTY para administradores sérios!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você executou 3 processos 'find' pesados no seu PuTTY pra pesquisar 
# senhas da auditoria sem usar o gerenciador 'screen', todos foram varridos pro fundo
# apenas com '&' puros. Todos eles caíram pro Status 'Stopped (TTOU/TTIN)' instantaneamente 
# quando você usou os 'jobs' no bash. Mas o CPU da máquina está zerado, nenhum CPU consumido.
# O que paralisou meus três scripts simultâneos em estado Suspenso?"
#
# Resposta Esperada: "O sinal SIGTTIN foi recebido. Processos em Background POSIX 
# (Job Controls) são suspensos pelo Kernel OBRIGATORIAMENTE assim que os 
# mesmos tentam Ler o STDIN (Um prompt solicitando que o usuário digite a senha 
# ou escolha Yes/No). Como eles foram desacoplados do terminal e não podem 
# travar sua tela com o Prompt Interativo, o Shell aciona o Pause congelando eles. 
# Para eles destravarem, devem ser trazidos de volta à superfície usando 'fg %id', 
# ser alimentados com a digitação ou Yes e devolvidos ao background com 'Ctrl+Z e bg'."
