#!/bin/bash
# ==============================================================================
# Aula 04.03: Processos e Recursos - O Monstro/Deus SystemD (systemctl)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Nos anos 2000, quando o Linux ligava, o Painel Geral (Init) lia uma lista 
# burra (.sh) mandando ligar Serviços Um a Um (Rede, depois Banco de Dados, etc).
# Se o Banco caísse à tarde, o SysAdmin corria, digitava 'iniciar' e cruzava os
# dedos pra ele não cair num Domingo de novo.
#
# Isso acabou. O **SystemD** é o Deus Orquestrador (Mãe Natureza). 
# Ele Liga DEZENAS de coisas Simultâneas no Boot. E mais importante: 
# Se o Banco cair 3 da manhã de Sábado NUM EXCEPTION ERROR C++?
# O SystemD vê o caixão do Banco baixar a terra, e **Ressuscita ele em 1 Milissegundo!**
# É Alta Disponibilidade Pura e Nativa de Kernel Sênior!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Systemd é o Gerenciador de Sistema de Processos `PID 1`. Ele adota OHD (Orphaned
# Hardware Dæmons) do sistema (tudo roda "debaixo da asa" dele). 
# Composto de Cgroups (Control Groups, o coração do Docker), ele limita CPU 
# de serviços, rastreia filhos PIDs, injeta Variáveis Ambientais Limpas Isoladas 
# para os Softwares (Separation of Concerns). 
# 
# Ele controla Unidades (.service, .timer, .socket, .mount). E os Logs dele 
# são binários ultra-rápidos (JournalD).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo).

# Vamos descobrir se nosso servidor WEB (Nginx) tá vivo agora e se O DEUS 
# reanimará caso der pani (enabled).
systemctl status nginx      # OBRIGATÓRIO: Mostra Logs Vermelhos/Verdes de Vida ou Morte.

# O servidor Nginx foi instalado mas não Liga com a Placa Mãe (Boot Habilitado)?
# Como ligar ele pra vida Eterna:
systemctl enable nginx      # OBRIGATÓRIO: Liga no StartUp Default Target do Prédio.
systemctl start nginx       # OBRIGATÓRIO: Liga O Serviço Agora Neste Minuto na sua Frente.
systemctl restart nginx     # OBRIGATÓRIO: Restart Duro (Mata Conexões, Perde Clientes Web do Https Momentaneamente).

# Como os Seniores reiniciam WebServers SEM DADOS DE CLIETES CAIREM? (O Roteamento Sem Perca)
systemctl reload nginx      # SÊNIORIDADE ABSOLUTA: Reload (SIGHUP suave)!!
# Ele LÊ as novas confs, mantêm as theads dos TCPs de Pagamento abertas vivas, 
# E Só inicia Worker de threads limpos para clientes Novos HTTPs do loadbalancer!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] journalctl -u nginx --since "1 hour ago" -f
# [O QUE FAZ] Ler LOGS Binários do SystemD (-u = Unit name).
#             O Sênior não fica dando `cat` em syslog pra achar o que foi cuspido pelas
#             Entidades do Mágico SystemD. Ele filtra os Logs de 1 HORA ATRÁS (--since)
#             da UNIDADE Nginx, e trava a Tela Segurando Ao Vivo (-f, Follow)!

# [COMANDO] systemctl list-units --type=service --state=failed
# [SAÍDA ESPERADA] UNIT               LOAD   ACTIVE SUB    DESCRIPTION
#                  apache2.service    loaded failed failed LSB: O servidor ta quebrado.
# [O QUE FAZ] Cheguei num Banco de Dados Desconhecido e a empresa disse que 1 coisa bugou.
#             Rodo isso: Ele cuspe APENAS QUAISQUER ERROS FATAIS DO SISTEMA EM VERMELHO! 
#             Você resolve a bucha em 30 segundos!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Criei meu serviço "AplicativoPythonDaEmpresa" do zero, com arquivo .service, E ELE NÃO LIGA!
#   `systemctl start aplpython`
#   Ele chora: "Warning: The unit file, source configuration file or drop-ins of aplpython.service 
#   changed on disk. Run 'systemctl daemon-reload' to reload units."
#
#   Sempre, Sempre que O ARQUIVO-TEXTO DA ORQUESTRA (o meu_app.service dentro de `/etc/systemd/system`) 
#   MUDAR 1 LETRA (Você usou o Nano lá pra consertar env de password, ou atualizou o código), 
#   O SystemD Recusa Mudar o App! A RAM DELE CONTINUA COM A REGRA VELHA CACHEADA.
#   Ele MANDA você RELACIONAR O DEUS À TERRA (Re-Parse do file).
#   Isso é feito com: `systemctl daemon-reload`. DEPOIS rode o "start"!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Porque Containers Docker NATIVOS (EntryPoints) não lidam bem rodando DENTRO de CentOS com SystemD?
# O Container do Docker é a representação PID 1 daquela aplicação em Si (Isolamento total).
# O Systemd Tenta SER o Deus. O Docker também. 
# Quando você tem o Systemd, Ele rastreia "Zombies de forks". Se você manda o SystemD startar um
# Script vagabundo em `/opt/tenta_ai.sh` sem dar tipo 'Type=forking', o SystemD detecta que
# a execução finalizou (`return 0`), ACREDITA QUE SEU SCRIPT FOI PRO CÉU E ENCERRA TODOS OS "SUBPROCESSOS FILHOS" CAÇANDO TODOS ELES NO CGROUP MATANDO SUAS THREADS COM O SIGKILL.
# 
# Isso se previne mudando para `Type=notify` ou criando unidades Service Corretas. Um Sênior domina 
# os states do daemon (ExecStart, Restart=always, ProtectSystem=full).

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você ligou o Systemctl habilitado na máquina 'mysqld.service'. Tudo rodava bem. 
# Súbito a sala de Servidores pegou fogo, e a máquina Rebootou Suja à Força. 
# Quando retornou do Linux Boot, O Banco Mysql INICIOU com SUCESSO. Contudo, todos os 
# Desenvolvedores PHP dizem que o Site Deletou Tudo ou tá com Banco Vazio! E no 
# systemctl, o Daemon logou 'Mysql Success - IP: 127.0.0.1 porta 3306'. Qual foi a burrada
# Arquitetural de inicialização e dependências?"
#
# Resposta Esperada: "O erro residiu no Unit File ausente de Dependencies.
# O Mysqld precisa montar uma San / Rede de Hardware Remota (`Target Network-online.target`). 
# E o administrador esqueceu a diretiva `After=network-online.target` e a montagem remota
# nas dependências cruzadas (Fstab iSCSI) não tava atrelada e exigida (`Requires=`). 
# Logo, O Deus Systemd engatilhou o StartUP do BINÁRIO DO BANCO '1 Microsegundo ANTES' 
# da Placa de Rede ganhar o DHCP Router da Internet!
# O MySQL subiu no vazio, inicializou um HD Virgem porque o Fstab de Rede Lenta
# nem havia finalizado Montagem da Storage de Banco Verdadeiro da Empresa!
# Modificaríamos o Unit MySQL Drop-In para: 'After=network-online.target mount-meuHD.mount'."
