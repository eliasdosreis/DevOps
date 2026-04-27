#!/bin/bash
# ==============================================================================
# Aula 04.04: Processos e Recursos - Agendamentos (cron, crontab, anacron)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Pense no Cron como o "Despertador" do seu celular. 
# Você não acorda de madruga, olha pro relógio e diz "Nossa, tenho que regar
# as plantas" e faz o serviço dormindo. O despertador apita 3h da manhã,
# você escuta (o Sistema Base) e roda O SEU SCRIPT de regar as plantas!
# 
# Cada usuário do condomínio tem direito de configurar seu próprio "Despertador" 
# sem o Síndico (O crontab pessoal do usuário de ID comum). 

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Cron é um Daemon de agendamento temporal (Time-Based Job Scheduler).
# Ele lê tabelas ('crontabs') que contêm cinco asteriscos (*) de Posicionamento Cronológico:
# (1.Minuto | 2.Hora | 3.Dia do Mês | 4.Mês | 5.Dia da Semana).
# `0 2 * * *` = Executa rigorosamente às 02h:00m de todos os dias do ano.
# `anacron` = Um utilitário que garante as tasks Cron DADAS COMO 'PERDIDAS' 
#             (Máquina estava Desligada na madrugada) e as Roda Ao Religar o Host!

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# Editamos a nossa Tabela Pessoal (Isso vai abrir o seu VIM/NANO).
crontab -e                  # OBRIGATÓRIO: Forma Segura que testa sintaxe e envia a agenda pra CPU.

# Dentro do EDITOR de Texto, é assim que colocamos um arquivo do Servidor:
# 1. Faça backup do Banco as 3 da Manhã TODOS OS DIAS DO ANO.
# 0 3 * * * /usr/local/bin/backup_banco.sh

# 2. O João envia email de relatórios do Site apenas NAS SEXTAS (Dia 5) às 17:30.
# 30 17 * * 5 /home/joao/scripts/manda_email.py

# Mostra minha lista atual cadastrada "List":
crontab -l                  # OBRIGATÓRIO (MuitosSysAdmins usam `sudo crontab -u maria -l` pra ler do outro).

# Se você quiser EXCLUIR O SEU DESPERTADOR, Pressione:
# crontab -r                  # MORTAL (Remove TUDO sem perguntar Tem Certeza). NUNCA USE!

# AGENDAMENTO "UMA VEZ NA VIDA SÓ"
# Eu não quero ligar a TV de madrugada todo dia, Eu quero ligar SÓ HOJE e esquecer.
# O `at` serve Pra Job Único e Exclusivo (O Cron é Loopers).
# echo "/root/reinicia_banco.sh" | at 03:00  # Só rodará as 3h de hoje e o Ticket some do sistema!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] tail -f /var/log/syslog | grep CRON
# [O QUE FAZ] Como que o Desenvolvedor SABE que as 3 da manhã o script DELE rodou?
#             Ele Não Sabe se não Auditar os Logs! O Log do Cron vive no Syslog do Kernel.
# [SAÍDA ESPERADA] CMD (/usr/local/bin/backup_banco.sh) | (joao) ENDED (0 seconds).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - FIZ O CRON CORRETINHO PARA SALVAR "MUITO LOG DO MEU JOGO", MÁS HOJE FUI VER...
#   ELE TÁ ERRO NO SYSLOG... 'PERMISION DENIED' AO SALVAR. Mas Eu sou o ROOT!!
#   O que Aconteceu? 
#   *Seu Script "meu_jogo.sh"*... FUNCIONA PRA VOCÊ! Você deu CHMOD +X Nele? 
#   Scripts Agendados, se não tiverem o bit Executável ativado, o Daemon do Cron
#   Falha de Injetar eles no CPU, devolvendo erro cego no log! 
#   Sempre teste na Mão o Shell antes de agendar no Relógio!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# A Maldição das Variáveis de Ambiente do Sistema Invisível!
# O Júnior escreve um script: `php /var/www/site/rotina.php`. Ele testa no terminal dele.. FUNCIONA!
# Aí Ele põe no `crontab -e`: `* * * * * php /var/www/site/rotina.php`. 
# Aí... NO OUTRO DIA: O PROGRAMA NÃO RODOU NO CRON! NADA ACONTECEU! 
# E O LOG DIZ: `php: command not found`. MAS O PHP EXISTE NA MÁQUINA! DEU ONTEM!
# O Porquê Sênior da Resposta Certa:
# O Cron Daemon roda Processos EM AMBIENTE SECO, ESTÉRIL, VAZIO, NUM INODE ZERO SEM .BASHRC!
# Ele NÃO Sabe O QUE É O "PHP", Não sabe o que é Variável "DB_SENHA"... ELE LÊ NO LIMBO DO NADA!
#
# REGRA SÊNIOR NO CRONTAB: 
# 1. SEMPRE PASSE O CAMINHO ABSOLUTO DOS BINÁRIOS!
# Em Vez de `php..` Escreva: `/usr/bin/php /var/www/site/rotina.php >> /var/log/php.log 2>&1`.
# 2. SE ESCONDEM SENHAS NO SEU MEU.SH? FAÇA SOURCE ANTES!
# `0 1 * * * source /etc/environment && /scripts/meu.sh`. INJETA A CARGA DO SISTEMA
# ANTES DO CRON FAZER ELE EXPLODIR SEM AS VARIÁVEIS!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa colocar 100 máquinas Ubuntu Server da Nuvem pra 
# Atualizar (Apt Update) as Listas de Segurança sozinhos todos os dias as 00:00.
# Qual a maneira Sênior do Time Operações Fazer isso, sabendo que os nossos 
# Ansible Bots NÃO UTILIZAM Contas de 'Humanos' nem criam 'Crontabs Pessoais root'?"
#
# Resposta Esperada: "A forma Universal é usar os diretórios Globais do Cron 
# `/etc/cron.d/` ou os Hooks do `/etc/cron.daily/`. 
# Um script Shell de Segurança pode ser Solto Fisicamente Dentro da pasta
# do `/etc/cron.daily/` com Permissão Binária +x. O Demônio do Anacron global
# lerá o repositório como código Universal da Distribuição todo santo dia e Startará 
# o Apt Upgrade perfeitamente logando no Journal, sem Atrelar 'Rotinas Fixas de Humanos'
# as listas do Root (Evitando Poluição e Garantindo Versionamento por Git das tarefas)."
