#!/bin/bash
# ==============================================================================
# Aula 06.02: Gerenciamento de Software - DNF/YUM e o Mundo RedHat (RHEL)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Se o Debian é um carro esportivo com a placa "APT", o RedHat é um Caminhão
# Blindado Mílitar que as Corporações Bancárias (Itaú, Bradesco, Governos) 
# compram com contrato de R$ 50 mil Dólares. 
# 
# A placa desse caminhão hoje se chama `DNF` (Dandified YUM) e substituiu o Velho `YUM` (Yellowdog).
# Ao contrário da leveza do APT, o DNF é pesado, robusto, e baixa os Metadados em SQLLite! 
# O pacote "Arquivo Mestre" do caminhão não é o (.deb), o formato militar deles 
# é histórico: o arquivo (.rpm) RedHat Package Manager.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# `.rpm` é o formato nativo compilado de Cpio-Archives contendo Header-Tags criptográficas. 
# O `rpm` puro (Baixo nível) sofre do mesmo mal do `dpkg`: "Dependency Hell" 
# (Inferno de dependência quebrada), e recusa instalar sem internet se faltar 1 byte de biblioteca.
# 
# O `DNF` é o ecossistema C++ novo (substituindo o antigo YUM escrito em Python lento).
# Ele calcula as Árvores Sat (SAT Solver Booleano Matemático), resolve conflitos pesados
# do RPM, baixa via Curl liberação RPMs de mirroes externos, e engata no disco!

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). Num servidor CentOS/Fedora/Rocky/AlmaLinux.

# Instalando o pacote clássico do Servidor Apache Web (No RHEL não chama 'apache2'!! Chama 'httpd').
dnf install httpd -y        # OBRIGATÓRIO (Yum install ainda funciona pois é um SymLink alias pra DNF).

# O DNF não tem o "apt update". Ele é Inteligente!
# Ao mandar 'dnf install', ele testa sozinho se a lista de Cloud dele Expirou a Validade Cache. 
# Se SIM, ele baixa os Megabytes do SQL Mestre SQLite na HORA pra ram.

# Fazendo a limpeza pesada de kernel velhos e pacotes inúteis:
dnf autoremove              # OBRIGATÓRIO NA VIRADA DO ANO DA EMPRESA!

# Comando Historiador do Mundo RedHat (MAGNIFICO REVERTER)
# O Dnf grava CADA COISA QUE VOCÊ FEZ COMO ROOT (Transações). Você pode reverter
# uma ca$@#da de instalação gigantesca dando "Undo" Transacional (Coisa que o APT não tem fácil).
dnf history                 # OBRIGATÓRIO (Exibe: Transação 45: Installed PHP-8).
dnf history undo 45         # A MAGIA DO SENIOR! Desfaze TUDO o que o cabaço fez na ID 45!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] rpm -ivh /tmp/jdk_oracle.rpm
# [SAÍDA ESPERADA] Verifying... ################################# [100%]
#                  Preparing... ################################# [100%]
# [O QUE FAZ] Como o DPKG -i instala um .deb baixado local, o RPM purista usa  
#             -i (install), -v (verbose falante), -h (Mostra barra de HASH na tela Bonito).

# [COMANDO] rpm -qa | grep "nginx"
# [O QUE FAZ] Interroga O BANCO DE DADOS LOCAL do Kernel Redhat (Query All) 
#             Pra listar TUDO que tem dentro do HD do servirdor instalado. 
#             MUITO ÚTIL pra auditar malwares escondidos.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: Eu rodo 'dnf install python3' e trava aparecendo:
#   `Error: Failed to download metadata for repo 'appstream': Cannot prepare internal mirrorlist`
#
# O Terror dos servidores CentOS 8 Mortos! 
# Em 2021 a RedHat ASSASSINOU O CENTOS 8 do nada! A URL do mirror Oficial (`mirrorlist.centos.org`) 
# Parou De responder Pings na internet E o DNF Ficou Cego Cuspindo Erro! (Repository End Of Life).
# A Correção de Guerra Sênior: Edite o `/etc/yum.repos.d/` de AppStream com VIM e troque 
# E FORÇE apontar o URL base para os Servidores Velhos de Arquivo Morto (Vault.centos.org). 
# Depois Migre de Sistema O MAIS RÁPIDO POSSIVEL PARA O ALMALINUX com O Script ELEVATE.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# EPEL-Release (Extra Packages for Enterprise Linux).
# O RHEL e a Empresa RedHat é S-U-P-E-R Quadrada Mente Fechada Rigorosa.
# Eles Colocam NO REPOSITORIO DELES DE DNF Apenas Uns 3 Mil Pacotes Ultra Certificados de Estabilidade!
# Se você der `dnf install htop`, Ele não acha!! O DNF Fala: "Htop? Jamais Validamos Isso como Corporativo!".
#
# O que o Sênior Faz Pra Instalar As Facilidades modernas numa Máquina Corporativa Quadrada?
# Ele Injeta "O Repositório Comunitário Aprovado Pelo Fedora O EPEL.
# Roda Primeiro `dnf install epel-release -y`.
# Daí o DNF conecta Nos Espelhos da Faculdade Fedora que tem MAIS DE 10 MIL Pacotes extras da Web OpenSource.
# Aí você dá `dnf install htop nginx python-pip` E a Mágica Flui!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está escrevendo uma infraestrutura Declarativa Redhat para Subir Máquina limpas.
# A documentação de segurança oficial diz que devemos executar explicitamente 
# 'dnf install kernel-devel build-essential' caso formos compilar drivers do Banco.
# Contudo, ao ler a doc oficial do DNF nós sabemos que ele tem um módulo chamado 
# `dnf group install`. Qual o ganho arquitetural em velocidade e padronização usando Groups?"
#
# Resposta Esperada: "A utilização da suite YUM/DNF Groups diminui a fragilidade
# Extrema da quebra de pacotes em Major Updates e economiza dezenas de Linhas no YAML
# de Ansible. Em vez de passarmos Uma String Hardcoded Com '20 nomes de softwares de Compilar C' que
# Pode mudar de nome na versao 9 do Rhel, nós passamos 1 Metapacote Lógico Oculto:
# `dnf group install 'Development Tools'`. O Kernel RedHat se encarregará de engolir O GroupID 
# atualizado Daquela Versão Do Ano de todas as Ferramentas (gcc, make, autoconf) blindando a 
# Idempotência sem que nos importemos com Dependências Menores (SubDependency Tracking)."
