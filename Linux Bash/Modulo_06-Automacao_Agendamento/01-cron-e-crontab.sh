#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Módulo de Automação! Mostra a sintaxe letal do Cron, como 
# ele gerencia PATHS invisíveis e a maneira Sênior de injetar
# rotinas diárias e logar erros sem silenciar falhas.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O crontab é o despertador do seu celular.
# Em vez de tocar um som, ele aperta o botão "Rodar Script".
# A sintaxe tem 5 engrenagens (Minuto, Hora, DiaMês, Mês, DiaSemana).
# "Toda segunda-feira as 04:00 da manhã eu quero que a faxina do banco aconteça".
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# `cron` é um time-based job scheduler daemon (processo de vida eterna background)
# em sistemas Unix-like. Usuários configuram `crontabs` onde instalam tabelas de 
# comandos atrelados a campos de Match de datas C-time UTC/Locais.
# O maior "gotcha" dele é a nulidade do Execution Environment (Ele carece de TTY e ENVVars).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Agendamento Clássico com CRON ==="

# Para acessar o "relógio"/despertador do linux: `crontab -e`
# Abaixo mostramos a Sintaxe de Linha que o dev digita dentro do arquivo e salva:

# Exemplo 1: Sintaxe Base Completa
# Minuto (0-59) | Hora (0-23) | Dia do Mês (1-31) | Mês (1-12) | Dia da Semana (0-7, 0 e 7 são domingo)
# 30 02 * * 1 /caminho/do/meu/backup.sh
echo "1. Exemplo de cron para: [Todo Domingo e Segunda (1) as 02:30 da manhã]:"
echo "   -> 30 02 * * 1 /scripts/backup_database.sh"

echo ""
echo "2. O Operador Divider 'A Cada N Tempos'"
# A Cada 15 Minutos, Faça XYZ.
echo "   -> */15 * * * * /scripts/monitor_cpu.sh"

echo ""
echo "3. O Maior Erro com Cron: ROTAS (Environment) MUDAS!"
# O Cron NÃO tem "Seu Profile bash". Ele não sabe onde tá seu python, nem o comando AWS, nem seu NVM. 
# O $PATH dele é minúsculo (Cai no /bin). 
# REGRA SÊNIOR PRA CRON: Sempre use ABSOLUTE PATHS para tuuudo (/usr/local/bin/python3 vs apenas python3).
echo "   -> * * * * * /usr/local/bin/aws s3 sync /dados s3://meubucket/ > /var/log/backup.log 2>&1"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Ver sua lista de jobs do seu usuário: `crontab -l`
# - Editar a lista abrindo o VI/Nano: `crontab -e`
# - Quer que o job ligue JUNTO quando o linux der Boot na máquina (Em vez de hora fixa)?
#   Use o alias @reboot : `@reboot /scripts/sobe_app.sh &`
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu script roda BEM na minha mão. Mas no Cron ele falha misteriosamente toda vez que bate a meia noite. PQP!
#   O que é: "A Maldição do Environment / TTY". O seu script está abrindo ou lendo algo que exige um TTY interativo, ou ele usa bibliotecas (ex: Python/Pipenv/Npm) que estavam declaradas no BASHRC na variavel $PATH da sua conta.
#   A Solução Sênior Dupla: No crontab declare na Linha 1 o PATH gigante dele: `PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`. 
#   Ou faça o cron carregar seu profile antes de rodar seu script (Wrapper technique): `0 0 * * * /bin/bash -c 'source ~/.bash_profile && /caminho/do_script.sh'`. Assim o script acordará conhecendo tudo!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe algo melhor que cron pra tasks periódicas em sistemas monolíticos Enterprise Modernos?
# Sim. O `cron` sofre de uma deficiência nativa chamada *Process Overlap e Missed Fires*!
# Se seu Job roda a cada 5 Min. E seu job levou 6 Minutos pra fazer bkp pq tava lerdo!
# O Cron vai ATIRAR de novo cego os 5 min e abríra um CLONE do seu script pra começar um Backup por cima do backup inacabado (Overlap File Lock Race Condition)! O Disco lota, da pane e a empresa perde DB!
# Sêniores lidam com iss usando `flock` nos cronjobs: `*/5 * * * * /usr/bin/flock -n /tmp/meu.lock /script.sh` (Onde flock garante que o cron só deixará subir um por vez!). Ou abortam tudo e usam as moderníssimas "SystemD Timers".
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu colocar no crontab `* * * * * meu_script.sh` mas ele der erro silencioso. Pra onde vai os erros emitidos em StdErr de um daemon como cron que por ser background root daemons não tem terminal gráfico do usuario pra cuspir as letras?"
# Resposta Sênior: O Default cron de muitos Unix manda a Standard Output (fd1) e Errors (fd2) ejetada direto para o SERVIÇO LOCAL DE E-MAIL (MTA - postfix/sendmail) emulando um mail file atrelado ao usuário-owner da tab (`/var/mail/root` ou `/var/spool/mail/user`). Os Administradores vêm seu disco esgotado com um gigantesco email morto na inbox de dezenas de megabytes! A resposta pra previnir Lixo Mails é redirecionar `> /dev/null 2>&1` no script cron final.
# ============================================================
