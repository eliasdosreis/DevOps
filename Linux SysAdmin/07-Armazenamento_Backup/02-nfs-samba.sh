#!/bin/bash
# ==============================================================================
# Aula 07.02: Backup e Storage - Compartilhamento de Rede (NFS, Samba/CIFS)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# A empresa compra uma "Caixa Monstruosa" de HDs Pela qual Todos Os Programadores
# devem Trabalhar Ao Mesmo Tempo Em Aquivos Gigantes. 
# Se Usarmos FTP? O Cara tem Que "Baixar" O Powerpoint, "Editar No PC" DeLe, E Subir Tudo De Novo E O Mais Lerdo Pega o Pior (Duplicação Desagradável).
#
# Com Network Compartilhadas: O "Disco da Caixa Gigante" É PROJETADO MAGICALMENTE  
# EM TEMPO REAL via REDE DE FIBRAS NO EXPLORER (Drive Z:) DO JOÃOZINHO! 
# O Joãozinho edita A Linha "3" De Um Documento Lá Dentro... A Agulha Da Caixa
# Gigante Grava Essa Linha 3 na HORA EXATA NA FISICA DELE. (A Mágica da Camada de Redes VFS).
#
# Se O Mundo For TUDO LINUX/UNIX = Nós Usamos NFS (Network File System) de graça, raiz e blindado.
# Se A Empresa Tem Windows Desktop = Nós Usamos Samba (SMB/CIFS Protocol) porque A Microsoft Criou Pra Ela!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Shared Cluster Storage over TCP Network. (Armazenamento em Rede LAN/WAN).
# O NFS (Desenvolvido Pela SUN Systems) Mapeia Mount Points Remotos sobre RPC (Remote Proc Calls). 
# O NFSv4 Moderno Usa Porta Cega (2049/TCP) que Evita as Tralhas Inseguras Do Passado e permite Firewall Elegante.
#
# Cifs (Common Internet File System - O Protocolo Velho Da MS), sendo hoje Abstraido
# Pelo Daemon Mágico `smbd` E `samba` Pra Escutar na Porta (445/TCP) de Arquétipos Ativos Directories.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). 

# ====== NFS DO LADO DO SERVIDOR (A CAIXA GIGANTA QUE TEM OS DISCOS) ======
# O Sênior Edita o Arquivo Base De Exportações: O Abençoado `/etc/exports`
# Linha Mágica Incluída Nele: 
# `/var/compartilhado  192.168.10.0/24(rw,sync,no_root_squash)`
# OBRIGATÓRIO EXPLICAR (Apenas A Subrede "10.0" do andar De Desenvolvedores Inteiro Pode Acoplar na Porta. 
# A Gravação será "Rw=Write", e "Sync=Asíncrona Pra Perder Dados Zero na Queda de Luz").
#
# Recarrega a Tabela Sem Derrubar O Linux pra Publicar Na Lan!
exportfs -arv                 # OBRIGATÓRIO (Publish/Export o diretório pros clientes Atacarem).

# ====== NFS DO LADO DO CLIENTE 01 (O Desktop Do Linux Do Dev) =============
# O Junior Chegou No Linux Dele Da Mesa (IP 10.3). Pra Ele Enxergar A Pasta Do Servidor Oculto:
# Ele Monta O IP Do Servidor Físico (1.50) Seguida Dois Pontos e O Caminho lá! Na PASTA VAZIA LOCAL DELE (/mnt)!
mount -t nfs 192.168.1.50:/var/compartilhado /mnt/pasta_vazia_do_junior    

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# SERVIDOR SAMBA WIN-COMPATIBLE: 
# (Arquivo de Deus O `/etc/samba/smb.conf`) (Para A População Ter o Drive Z:\ No Windows)
# [COMANDO] samba-tool testparm
# [O QUE FAZ] (Checador De Sintaxe). O Samba Tem 42.069 Diretivas Possíveis Nos Tempos Críticos. O Sênior
#             Salva O Arquivo e Dá "testparm". Ele Limpará A Mente Vazia e Te Cuspirá SOMENTE AS Linhas
#             Tóxicas Que Vão Deixar Hackers Enxergar A Senha Das Pastas Contabeis da C-Level!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Criei A Regra Nfs De Um Cliente Físico! DEU `NFS STALE FILE HANDLE!` (ALÇA DE ARQUIVO PODRE!)
#   E AGORA? TODAS AS JANELAS DE TODOS OS LINUX NO DEPARTAMENTO DE TI TRAVARAM!  
#   A TELA CONGELA 100% E O PONTEIRO DO MOUSE GIRA NO CENTOS DO DEVS SEM VOLTAR.
# 
# Isso se Dá Por Interrupção Violenta da RPC Roto-VFS.
# O Administrador Lá no Servidor Caixa Maior APAGOU ou RENOMEOU A PASTA /var/compartilhada. 
# OU O Roteador da Vivo Caiu 5 Milisegundos Da Perna Do Switch Cego. 
# O NFS É "Hard Mounting Target". Se a Caixa Desvanece.. Os Programas Windows/Linux Cliente Entram no 
# Sleep Interropivel Absoluto (CANCERÍGENO DO KERNEL 'D') porque ElA Acha Q O Fhs HD Travara E Tão Crendo.
#
# Solução de Mestre: Monte a Porra do NFS NO FSTAB do Linux Do Junior SEMPRE com `soft,timeo=30` parameters.
# E pra Salvar O Jr Travado: Force Uma Faca De Kill Assincrona Ejetável Na RAM: `umount -f -l /mnt/pasta_vazia`. (Lazy Unmount Oculto!).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# "A Morte Iminente da Opção `no_root_squash`".
# 
# Pense BEM: O "Junior Da Máquina Dell_22" Loga no Desktop Linux dele da vida real como O Dono Dele (Root Cego do C-level na casa dele).
# Se ele Tentar Apagar Um Arquivo Do `mount` Do Servidor Gigante Que Nós Colocamos? O Root Do Jr Vai Atravessar A LAN
# Passar Pelas Portas.. ESBARRA na Árvora Do Sr... E A CAIXA MAGNIFICA ASSUME Q SE "FOI O ROOT DE ALGUEM, ELE ENTÃO
# APAGA COISAS COMO UM ROOT OFICIAL DA NOSSA CAIXA E ESTACIONA TODO TRABALHO DE TODOS!"!
# 
# ISSO É TERROR INFINITO DE SEGURANÇA. O Hacker Quebrou a MÁQUINA DE RECEPCIONISTA BOBONA, Ele VIRA O ROOT NELA! E DE LÁ
# ELE DELETA OS BACKUPS NFS DO NOSSO DATACENTER VIA REDE COM ETIQUETA 'ROOT' (Exploração Por Root Squashing).
# Solução SÊNIORIDADE:
# TODA e qualquer Pasta De NFS Exportada Em Servidor Central tem O PARAMETRO NFS: (root_squash).
# Isso Significa "Se Um Idiota Da Lan De 192.. Atacar Meus Arquivos Falando "Opa Eu Sou o ROOT Daí". O Nfs Dá Uma Martela
# Nele, Zera o Credencial Pra ("Nobody Usuario Lixo Vagante sem Direitos") e devolve Pra Rede: "Vá Pastar Ninguém Deletta aqui!". 

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está provisionando a Topologia Clássica do SMB pra uma 
# filial de engenharia. E Nossa Regra Crítica da Matriz Americana diz Exclusivamente: 'Nenhuma Porta Da
# Subrede Local Pode Conexão Atrevida Ao Portão 139 Ou 445 No Kernel Base Cego SEM FIREWALL EXTERNAL'.
# Mas Se eu Instalar o Pacote do Samba puro e Iniciar A Master Service Na AWS/VM Local Ubuntu, Ele abre Pela Topologia
# o Soquete Nas Interfaces Internas, Externas e De DMZ Daquela Mesma Placa De I/O Físico Espalhando Samba no Mundo.
# Como Fechar E Orquestrar Cego Sem Usar IPTables?"
#
# Resposta Esperada: "Usaríamos A Blindagem Intrinseca Do Protocolo Daemon De Abstração Local (`smb.conf`)!
# Ao invés de dependermos Furtivamente de Regras Do UFW, Definimos Estático E HardCoded A Configuração '[global]'
# pra Ouvir Apenas 'bind interfaces only = yes' e Exigimos Que O Demon Amarre A Socket String Apenas Em 
# Obras Da Rede Lan Mapeada de Engenharia 'interfaces = 10.0.50.0/24 lo'. O Samba Daemon, Assim Instanciado, Recusa 
# Passos Interativos na Sub-rede Externa (Internet 172..) por Ignorância Ativada na C-Lib, Despreocupando o Cloud Admin."
