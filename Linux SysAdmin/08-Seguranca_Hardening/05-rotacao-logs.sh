#!/bin/bash
# ==============================================================================
# Aula 08.05: Segurança e Hardening - Rotação e Log Agregation (Logrotate)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Seu Barzinho Começou A Ficar Muito Famoso Na Cidade Cega De Noite. O Caixa 
# Tem O Livro De Transações Oculto Fhs Da Mesa. Você Anota TUDO O Que Ocorre (O 'LOG').
# No Dia 1 E 2... Um Livro De 80 Paginas Cabe De Boas...
# No Dia 50.. Num Bar Gigante Cego Do Ano Todo.. Como Vc Faz Pra Anotar E Procurar Uma Cerveja Que Vendeu Em JANEIRO Num Livro DE 80 MIL KILOS DE PAGINAS PESADOS?! O LIVRO ESTOURA A MESA!
#
# Isso Ocorre Nas Aplicações Do Server (Syslog, Ngninx, Docker). Se Ele Ficar Escrevendo Naquele Texto Puro Cego 8 Meses Sênior... O Texto Chega A Ter '50 GIGAS DE TAMANHO NATIVO CEGO' DO ARQUIVOS LENDO!
# O LOGROTATE É o Assistente Que as 2 da Manhã "Arquiva Os Dados Mensais Num Caderno Novo Menor Zipado E Dá Um Caderno Em Branco Novo De Graça Cego Pro Bar Vazio Sem Demorar O Espaço Mesas Do Salao Ceog Base!".

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Gerenciamento Logístico Daemon Utility System de LogFiles (Logrotate.d).
# O Core Unix Cego Não Compacta Lixos Automáticamente! O SysLog O Daemon Cego Syslog/rsyslog Mapeiam Dumps de Errors Facilities Pposix Fhs Nos Arquitetos /var/log/.
# O Scheduler Oculto 'Cron Base Cego' Executa O Utilitário Diariamente Lendo a Pasta `/etc/logrotate.d/`. Aplicando 'Compression (gz)', 'Rentention Days Cego (Keep 5 Files)', 'Create New Mates Cega Base', Em Todos Os Logs Definidos De Aplicações Saneando HDDs e Ram Buffers Em Servidores Produçóes Ocultos TTY!

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root Cego (Sudo). 

# O CELEBRE ARQUIVO DE ROTACAO CEGO DA SUA EMPRESA (O Desenvolvedor Junior Subiu UM App Java Python Sem Cuidado). E Criou Uma Configuração De Logrotate Sênior Fhs Pra Ele:
# sudo vim /etc/logrotate.d/app_python_meu       <-- O Sênior Edita Esse Arquivo Cego Novo Configurando As Regras Arquivísticas FHS Base Dele.

# O Que Tem Dentro De Um Config Logrotate Do Sênior Cego Fhs Base Limitada?
# /var/log/app_python_meu/*.log {
#     daily            <-- Roda Todo Dia Fhs.
#     missingok        <-- Se O LOG NÃO EXISTIR NAO DÁ ERRO PRA PARAR O CRON DEPOIS (Bug Fhs).
#     rotate 14        <-- GUARDE OS ÚLTIMOS 14 DIAS ZIPADOSS ANTIGOS PRO AUDITOR FORESNC, Delete OS DO MES PASSADO (Limpesa Disco Automática Absoluta!)
#     compress         <-- USA GZIP MAGICO Pra Compactar Texts Cego e Poupar 90% Base HD!
#     delaycompress    <-- Sênior!! NÃO COMPACTE O ARQUIVAO DA ONTEM CEGO CEGO NATIVO QUE O APP ANTIGO POSSA AINDA ESTAR COM CONEXOES TERMINAIS LENDOO!! ESTRANGULA O SO DO APP EM TUDO!! O GZIP FHS ZIPA APENAS O 'APP_LOG.3 E APP_LOG.4 ANTIGO BASE'.
#     notifempty       <-- Se O TEXTO Estiver Vazio Sem Erros Cego Do Fhs Aquele Dia, Não Gira O Txt Bobo Oculto TTY Em Vao Criando Lixos Vazaio CEGo!
#     create 640 root adm <-- DA O PERMISSION CADEADO DE VOLTA PRO TEXT INICIANTE ZERO DA MAQUINA C-LEVEL NO LUGAR ONDE ELE ESTAVA!
# }

# O Teste DO VOO SECO Sem Cortar Cabeças (Dry-Run Militar):
logrotate -d /etc/logrotate.d/app_python_meu       # OBRIGATÓRIO (Avisa Se O Script Tá Sem Sintaxe Errada, Ou Se Os Tamanho Do Dia Cego Vão Passar Dos Logs Na Teoria E Debug).

# FORÇANDO A ROTAÇAO (GIRAR OS ARQUIVOS ONTHEFLY VIVO SRE CEGO EMERGENCIA HD ZERO BYTES):
logrotate -f /etc/logrotate.conf                  # OBRIGATÓRIO (Estourando o Servidor Log Apache, Voce Da Um Force Força Mágica Na Hora Ele Zipa E Limpa Os Erros Enromes Bases Do Disco Sem Esperar O Relogio Do Cron Do System Cego Sys! A Empresa Sobrevive).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] zcat /var/log/syslog.2.gz | grep "Out Of Memory"
# [O QUE FAZ] (Sempre Têm Ess Símbolo: O Sênior Quer Ler Erro de Ontem Cego... Mas Ele Foi Roteado E Zipado Pelo Sistema. O Sênior Vai Fazer Puxar Extrair Arquivo No Temp? NÃO! Ele Roda O Famoso ZCAT Fhs Pipeline. Ele LÊ e Desenrola Txt Direto Do Arquivo Zipado Compressado Gzip NA RAM e Manda Cego Pipeline Pro Grep Procurar A Frase "Out Of Memory" Em Segundos Cego Muted Base Limpas Absolutamente Forensica Ceag).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - CENA CEGA: "O JUNIOR CRIOU UM LOGROTATE. O SCRIPT DA PYTHON PYTHON ROTA CORRETAMENTE E GERA O ARQUIVO NOVO... MAS O APP DO JUNIOR JAVA CAIIIIIU DANDO ERRO QUANDO ELA VAI ESCREVER NO LOG NOVO ZERO MÁGICO E NAO ACHA O CONTEXTO CEGO DE ESCRITA DELE FHS NO DIA SEGUINTE!!!".
#
# Isso É A Ignorância Cega Desse Junior Em C-Syscall I-NOde FileDescryptors Bases Mortos. 
# Quando O LogRotate Cego "RENOMEIA / MOve O Arquivo .LOG Pra .1 Cego". O APP DA RAM JAVA Fica Segurando O Endereço Memória Físico Físico Ceo Antigo e tenta Escrever Num Local Q O Zip Já levou Emborta e Perde FhS Referência Morte Do Processo FhS Lendo TTY Aberto No Chão. 
# 
# SOLUÇÃO SÊNIORIDADE: Script PostRotate Exato Oculto Cego:
# `postrotate`
#   `systemctl reload meu_app_python`
# `endscript`
# Ele Corta O Log Zipado Novo Bonitinho De Madruga e... DÁ UM SIGHUO 'RELOAD' MAGICO NO APP DO JR JAVA/NGINX PRA ELE MENTALIZAR Q ELE DEVE RECRIAR O SEU SOCKET LENDO O LOG VAZIO ZERO RECÉM POSTO Cego! Sem Bug Nenhum Cego!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Por Que LogRotate Em Datacenters Modernos Nuvem AWS Morreram Do Nada Muerte? E Qual o Caminho Sênior?
# Em Infra Estruturas Efemeas Cloud Kubernettes, Os CONTAINERS Docker Não Tem /VAR/LOG Praficar Fazendo LogRotates Com Cron. Se A VM EC2 Apagar Tudo O q Tava No Disco Vai Pro Chão Pro Nada E A Empresa Fica Sem Auditories E Logins De Segurança FhS Na Amazon!!! 
# A Cultura Arquitetural Sênior Adota 'Logs Como Eventos Estremos Streamming stdout FhS Mestre'. Os Dockers E Systemds Cospe O Log Diretamente Para Fora Do Container Pelo (StdOut Tela Pipeline). Um Coletor SideCar Da Infra Fluente Externo Logstax (Ex: FluentD, Splunk/ElastickSeach) Sugue As Linhas Da Memoria E REMETE Exato PRA OUTRO SERVIDOR DISTANTE BANCO DE DADOS DISTRIBUIDO PRA CONSULTAS GIGANTES E DESTRÓI O ARQUIVO LOCAL NUNCA USANDO LOGROTATE LOCAL E MINIMIZANDO O GASTO DA VM AWS CEGA BÁSICOS HD LIMITES Oculto Base Tyy Forensic!! 

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está lidando com UMA MÁQUINA CEGO GIGANTE QUE TEM 1 ARQUIVO FHS ARQUIVÍSTICO GIGANTE CRÍTICO BINÁRIO CEGO `arquivo_de_Banco.db`. MAS DE FORMA ALGUMA Nós Podemos PERMITIR QUE O APP SEJA RELOAD DO FHS 'SIGHUP', NEM Q O ARQUIVO SEJA MOVIDO, DELETADO NEM FECHADO NEM SOFRA CORTES NOS ENDEREÇOS DO INDEX MEMORIAL DE INODES FHS. E Nós PRECISAMOS DA LIMPEZA DIÁRIA NELA NO LOGROTATE PRA DIMINUIR TAMANHO PRA NAO EXPLODIR O DISCO FHS LOCAL SSD EXTREMO NAS ESTAÇÕES DE LEITURAS CEGAS INVASIVAS? Como LogRotatamos Sem Quebrar As Conexeõs de Leitura C-Syscalls Vivas Limitantes Nas Engine Memória Abusivas Ceo Do Sistema?"
#
# Resposta Esperada: "Habilitaríamos no Corpo Da Instrução O Magnífico Recurso Flag Nativista Do File Descriptor Linux Sênior Oculto Base Cega: `copytruncate`. 
# O Parâmteto 'copytruncate' Instruirá O O Sistema Utilitário Rotate Base Cego A Efetivamente 'Dar um Cópia Leve Cp Absurda' Do Arquivo Atual Para O Backup Mensal `.1.gz` Mantendo a Origem Base Instante. Após Clona-Lo Pela Ram Cega, A Mágica Manda Cego O I-Node System Dar Um 'Echo Vazio Cego Local Truncate Do Próprio Tamanho Dele 0 Byte Local No Ficheiro Físico Orginal Cego' Diminuindo Cego Espaço Pra ZeRO No DF Cego Do Disco. Não Matanto Fd Pids Originais Fhs Abertos! Sem Necessidade de Reiniciar Demônios Vivos Reloders Complicated Local Cego Exatos Limites Ocultos Syscalls Das Árvores C-Levels Oom Fhs Ceo!!"
