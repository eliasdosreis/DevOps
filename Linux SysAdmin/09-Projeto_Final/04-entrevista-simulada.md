# ==============================================================================
# Aula 09.04: PROJETO FINAL - Entrevista Técnica Simulada Sênior (Linux/SysAdmin/SRE)
# ==============================================================================

Você Passou Por 8 Módulos Reais Cego Das Engrenagens Posix.
Em Um Case Técnico (Live Coding Ou Technical Screen Entrevistador AWS/B3), Eles Focaram NA RESOLUÇÃO DE PRESSÃO CEGA. Tente Fazer E Responder Na sua Mente. As Respostas Estão Abaixo de forma Sênior Blindadas!

---

### DESAFIO 1: FIRE-FIGHT DE PRODUÇÃO (DISCO MORTO)
**CENÁRIO DO ENTREVISTADOR:** "Elias, Nosso banco PostgreSQL parou às 3AM acusando 'No space left on device'. O `df -h` mostra `/dev/sdb1 mounted on /var/lib/pgsql` como 100% full (Uso: 1 TB). E 0 Bytes Livres. Como você, SysAdmin da nossa Empresa, resolveria isso EM 3 MINUTOS sem reiniciar a máquina e Sem Tempo Hábil pra fazer um Backup E Resize no HD Inteiro FhS Do Banco Na Calada Da Noite Cega Mágica?"

**-> RESPOSTA SÊNIORIDADE ALTA:**
1. A Causa Pode não ser o Arquivo DB PostgreSQL GIGANTE Cego, Mas Sim Logs de Erro TXT Enchendo o Fundo Daquele Mount!
2. Roda Cego Direto: `du -sh /var/lib/pgsql/* | sort -rh | head` pra Caçar Rápido Na Mosca Qual Log Tá Entupindo Tudo Em Miliseundos. O Culpado De 30Gigas Provavelmente Log de Erros Da App.
3. ACHOU O LOG GATO: `/var/lib/pgsql/data/pg_log/postgre_fatal_erro.log`. 
4. O TIRO DE JÚNIOR E O ERRO DO PÂNICO: Eu (O Entrevistado Crendo Cego) *NUNCA* Apagaria ELE COM `rm -rf`. Por quê? Porque A Engenharia Daemon TCP do PostgreSQL *Ainda Tá VIVA Cega na RAM Escrevendo Nele Acoplado Open FD FileDescriptor* Cego Na FileTAb. Se eu Deletar, O OOM Fantasma File Continuaria Loto No Disk `df -h` e a Maquina Continua Caída! E o Banco Morre Mute!!
4. A MAGIA FHS: "Eu Utilizaria o Truncamento Ao Vivo Base UNIX do Arquivo Físico Da Memória Redirecionado Lendo Base Mute Cega. Comando `> /var/lib/pgsql/data/pg_log/postgre_fatal_erro.log`. Esvaziando FhS Os Pids Do Descriptor Zero Pra Vazio! A Tela Retorna '200gb Livres' em 1 Segundo Cego C-System Call Base Ext4 Tty E a Máquina Retorna Operacional Ao Vivo Na Calada Noturna Pela DMZ Da Equipe!".

---

### DESAFIO 2: O SUMIÇO DO SSH NA NUVEM DE MESTRE
**CENÁRIO DO ENTREVISTADOR:** "O Desenvolvedor Novo Abriu o arquivo `/etc/ssh/sshd_config` Com Editor Nano Pra Fazer O Seu 'Módulo 5' Da Empresa e Add Seu Public Key File Base. Mas Ele Acidentalmente Excluiu Um Dos Caracteres Chaves Escritos Com Erro De Sintaxe Absurdo ('PrmitRooooLogin'). Ele Salvou O Erro. Ele Deu `systemctl restart sshd`. Ao Tentar Logar DNV De Fora Cego A Porta Cega Caiu Time Out Deu Error Failed Config FhS Daemon Refusal. ELE ESTA PRESO FORA DA AMAZON CLOUD NA RUA EM SHUTDOWN DE REDE!! Como O DevOps Root Da Empresa Pode Salva-Lo Se ELE Nãp TA MAIS Lá Dentro Pra Consertar Pelo SSH?"

**-> RESPOSTA SÊNIORIDADE ALTA:**
1. Eu Explicaria Ao CTO As Vias Alternativas De Recuperação De Acordo Com O Vendor Cloud Do Hardware. O Bug Impede 100% Novas Shells Entrantes Camda 4 Ocultas. Mas O Sistema S.O. Linux TA INTÁCTO LIGADO NA MÁQUINA Cego BASE.
2. Na AWS Nuvem Base, Nós Utilizaríamos O EC2 "User-Data Fhs Script On ReBoot Inject". Ou As Ferramentas De Agente SSMS Systems Manager Shell Agent (Que roda Pela PORTA HTTP 443 Por Trás Da Placa E não Depende do Serviço Daemonic SSH Daemon Puxar FFS) Pra Enviar Um Cmd Cego TTY Local Limpo.
3. Comando Cego Scriptado Pelo SSM Direto Da Interface Web Cloud: `sed -i 's/PrmitRooooLogin/PermitRootLogin/g' /etc/ssh/sshd_config && systemctl start sshd`.
4. Os Agentes Locais Da Placa Mae (SSM) Interceptam No Kernel Limpando A Cagada do Nano Do Garoto, Iniciam A Engine Com Código Do Kernel Sucesso 'Ok', A Via do SSH Abre Para Mundo FHS De Novo E O Acesso Da Equipe Vinga Retificado Muted Base.

---

### DESAFIO 3: O GARGALO MAGNIFICO DE REDE TCP PÂNICO IP PORT LACK
**CENÁRIO DO ENTREVISTADOR:** "O nosso Apache NGNIX É Um Proxy De Sucesso Enormemente Físico (Roteando Transações HTTP Cegas P/ Fora Para APIs Gringas De Payment). A CPU Do Servidor Está Linda e Fria 'Idle 90% Livres'. Tem Giga Cego RAMS. Mas TODOS OS Clientes Do Fundo Da Nossa API Tão Reclamando Timeout 'Não Conectou Gateway Timeout'. Quando Batemos `ss -anp` Na Maquina Oculta, Vemos Mais de '30 MIL Conexões Mortas Em TIME_WAIT State Socket Oculto Lixo'. E Nenhuma Conexao Nova Vai. A CPU Ta Cega Fria Mas O Serviço Tá Morto! O QUE MATOU O LINUX BASE MAGICO DUM Proxy TTY Limpo?"

**-> RESPOSTA SÊNIORIDADE ALTA:**
1. A Causa Matématica Incontestavel De Port Exhautstion Cega (Esgotamento Extremo Ephemeral Port Allocation NetFilter C-Limits Fhs Kernel P-TCP).
2. O Servidor Cria 1 Porta Cega Oculta Pra Fazer A Transação Externa (Conexão Temporárias de Saídas). 
3. Quando O Apache Termina, Ele Fecha O TCP FLAG MAGICO FIN-ACK. O Kernel Linux POSIX PÕE A SUA CONEXÃO NUM ESTADO CADEIA NO PURGATÓRIO "TIME_WAIT" Durante 60 Segundos Padrões De Fábrica! (Para Esperar Míseseigndos Atrasados da Net).
4. Sendo Um Proxy De 30 Mil Disparou Por Segundos... O Purgatório Acumulou De Todos Acabados Numa C-Array De TCP Sockets Base Lixo Em 60s.. E ESGOTOU TODAS AS 65535 MIL PORTAS FÍSICAS DA MÁQUINA DISPONIVEIS PRA ACIRRAMENTO Cego Novo! Ele MORRE DE ESTATISTICA "LIMIT TCP PORTS REACHED FHS".
5. O Famoso Fix Cego TCP SysCtl Tnnig Sênior: "Eu Abriria o Cérebro Kernel Base Cega FHS TTY do Padrão Limpo `/etc/sysctl.conf`. E Injetaria:
   `net.ipv4.tcp_tw_reuse = 1` 
   E Encurtaria a Faixa De Portas Furtivas:
   `net.ipv4.ip_local_port_range = 10000 65000`. Depois Um `sysctl -p`. E A Mágica Acontece: O Kernel Recicla Instantaneamente OTIME_WAITS Na Milissegundada Permitiendo Milhões De Compras Clientes Concorrentes CeGas Escapadas Limpas SEM CPU BURDEN! TTY Salva!."

**CONCLUSÃO: Parabéns. A Mão na Massa Criou a Lógica do Verdadeiro Mestre de Infraestuturas SysAdmin Modernas SRE Cegas Base!**
