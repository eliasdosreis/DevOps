#!/bin/bash
# ==============================================================================
# Aula 07.03: Backup e Storage - A Imortalidade RAID (Mdadm SysAdmin)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Imagine que você é um bilionário E Escreve Uma Agenda Mágica Fìsica. 
# Se você Perder a agenda de papel, Suas Contas Suíças Se Evaporam. Você chora.
# Mas.. E se você pagar 2 Secretários Especiais E Colocar "Cada Secretário Numa Casa".
# E Você Escrever: O "Dado Físico De Contas Suíças".  NA HORA Que Você Ditar a palavra..
# Os DOIS SECRETÁRIOS NAS CASAS DIFERENTES COPIAM A FRÁSE EM PARALELO NAS AGENDAS DELES (Espelhamento!)
# Se o Secretário 1 For Sequestrado Por Ladrões E Morto Pífiuo... O Secretário 2 Traz O Livrinho E A Empresa Continuar de Pé Intacta Num Segundo (Tempo Zero!)! 
# Nós Chamamos Esse Milagre Dos DataCenters Bancários E Da Amazon de RAID (Matriz Redundante De Discos Independentes).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Um Storage Físico Pobre. Arrays Independentes Discos De baixo custo (Acrônimo Antigo Baratos).
# Topologias (Os Níveis):
# - RAID 0 (Striping do Kamikase): Dois discos viram Um Maior. Dobra sua Velocidade da Placa Mae, porque 1 Byte
#   é dividido e atirado metade na via do HD1 Metade Na do HD2. SE 1 HD PIFAR? VOCÊ PERDE OS METADADOS DOS DOIS HDs COMPLETOS DA EMPRESA E TUDO EVAPORA INTEIRO (SECA)! ZERO SEGURANÇA.
# - RAID 1 (Mirroing Padrão Básico): O Mesmo Dado Escrito, Cai Dobrado nos dois HDs Idênticos. Caiu O HD principal de boot? O HD2 assume E o LVM Levanta Comemoração!
# - RAID 5/6 (A Matemática Impossível Da Paridade Segura): Precisa de 3 ou+ HDs. Ele "Embaralha e calcula um Valor Matemático De Checksum Inverso" e Deposita Esse Check Cego No Terceiro E nos Outros!
#   Se um Disco INTEIRO VAZIO (Morto) Se For. O COMPUTADOR FAZ A VOLTAR OS DADOS TODOS EM BASE DOS BLOCOS RESTANTES USANDO CALCULOS DE X-OR Binário em tempo de CPU Pra Restauram Um HD Novo VAZIO ENFIADO NA BAIA DELE EM HORAS CUSPINDO O FANTASMA! E o Site Continua ON!!

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). E pacote 'mdadm' pré-instalado.

# Criando Um Caminhão Espelhado de RAID 1 com dois HDs Virgens de 1 Terabyte (sdb e sdc).
# A Saída Do Script Produz Uma Entidade De Bloco Nova "md0" (Multiple Device 0) !
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc   # OBRIGATÓRIO (Associações Ocorridas).

# Vendo o Resgate Fìsico Do Raid em Andamento (Status Live Cego Mestre)!
cat /proc/mdstat              # OBRIGATÓRIO (Traz A Barra Bruta de Sincronismo da C-Lib Kernel!).
# Ex: personalities: [raid1] -> md0 : active raid1 sdc[1] sdb[0] -> 98% [=====>_] .. (Ele tá terminando de clonar).

# Formatamos a Entidade Fictícia MD0 (O Kernel Acha que A Entidade É Um HD PURO DE METÁL E MENTE FÁCIL: 'SIM PATRAO!')
mkfs.ext4 /dev/md0            # Asfaltando o Nosso Array RAID! E Agora Vai Pro /ETC/FSTAB Pra Ganharmos 1 Ponto Gênio Seguro De Montagem!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] mdadm --detail /dev/md0
# [O QUE FAZ] Ele Verifica o Mestre De Discos Array Cega de SGBD (Sate State Health).
#             [SAÍDA MARAVILHOSA]: Active Devices : 2 | Working Devices : 2 | Failed Devices: 0.
#             "Tudo Suave no DataCenter C-Level".

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - PÂNICO DE MADRUGADA SRE DO PLANTÃO: A Luz de LED Vermelha apitou no Rack! Deu `Failed Devices: 1` No Detail! E Agora Sênior? O Servidor Desliga?
# Não. Se você usou RAID 1/RAID5, Sua empresa Sobrevivendo Na Boa e Vendas Batendo e Web Rodando No HD Secundario Silencioso! O LVM Não Sabe o que Passou!
# 
# Rotina de Salvação Ao Vivo (Hot Swap Em 30 Segundos do Novo SDB):
# 1. Puxe a gaveta do Defunto Com a Mão Fora No Ar e Jogue o HD No Lixo (Ou 'mdadm --manage /dev/md0 --fail /dev/sdb && mdadm --manage /dev/md0 --remove /dev/sdb').
# 2. Pegue Um HD LACRADO DA SAMSUNG NOVO "1 TB" C/ MESMO NUMERO FÍSICO (Tamanho do Sector Gasto). E Enfie Na Gaveta SATA Livre Da Mãe Placa. (Hotplugging!).
# 3. Mande A Magia Do Restore Militar Corporativo Array Rebuild Completo LVM: 
#    `mdadm --manage /dev/md0 --add /dev/sdb`
# E PRONTO!!!!!! O KERNEL TIRA LOGS E REACENDE TODAS AS PARTIÇÕES CEGAS NA HORA DA MAQUINA PRO SEU SSD VAZIO E RECONTROI OS DADOS DO BKP COM CHECK!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# O Mito Assassino Delirante: RAID É GARANTIA DE BACKUP CEGO! (Mentira Morte de Júnior Empregados Anuais!)
# 
# A Empresa Fazia "RAID 1". Tinha Dois HDs Fodões Se Copiando O Dia Todo C\ Paridades.
# O JÚNIOR IDIOTA FOI NO LINUX Nginx E Deu Um Comando Errado E A P A G O U Todo O Banco de Dados de Produção De Forma Errada Acidental Lendo No Putty As Seis da Tarde. (rm -rf /banco).
# E Agora? O Junior Diz: "Temos o Raid 1, Salvem Ele!! Liga O HD DOIS! A Gente Tem Duas Cópias de Tudo Garantida Pelo Linux!!".
# E O SÊNIIO CAI EM LÁGRIMAS NA MESA DO CAFÉ CHORANDO E PEDINDO CONTA PRA TODOS: "SEU ANIMAL, RAID ESPELHA A SUA ALMA NA HORA DA INEXECUÇÃO FÍSICA! QUANDO VOCÊ APAGOU NO DISCO UM, O LINUX DEU ORDEM SIMULTANEA NO DISCO 2.. **O HD DOIS DELETOU COPIADO TODA A BENDITA PRODUÇÃO INSTANTANEAMENTE EXATAMENTE IDÊNTICA EM 1 MICRO-SEGUNDO**".
# 
# O ÚNICO ACIDENTE QUE RAIDS COBREM É A FALHA ELÉTRICA DA PARTE DE DISCOS CAUSA (AGULHA QUEBRAR, METAL MOLDADO FUNDIDO). 
# DADOS DELETADOS OU HACKINGS, O RAID É NULO INÚTIL POIS ESPELHA O ERRO JUNTO COM O CAOS DA RUA A FRENTE! USE BACKUPS OFF-SITES DE RÓTULO EXTERNO VIA RSYNC EM MÍDIAS DO FUSO HORÁRIO ANTERIOR DA NUVEM!!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você está projetando do Zero um Servidor NAS Pesadíssimo Multi-Node Custo Base Para Um Storage Arquivo Físico Da AWS S3 Clone Nosso. Queremos Redundância de 2 HDs Podendo MORRER de 10 Baías sem Perder o Cluster DataLake Geral Inteiro da Empresa. Qual nível nós arquitetaremos a montagem na CLI Sem HardWare Controladores Múltiplos Caros Superiores?"
#
# Resposta Esperada: "A configuração Padrão para Redundância Dual-Disk de Tolerânica é o RAID 6 de Estipulações Longas Da Academia. E Não O Famoso RAID 5 (Que Só Sobrevive a 1 Falição Física De Baia HD Moribunda) Nos Custos.
# A Mdadm Arquitetura Dupla-Paridade Stripping No Nível 'Level=6' Nos Permite Configurar Com Segurança O Volume. Porém A Equipe Deve Ser Notificada: O Nível Seis Utiliza Carga Pesadíssima Computacional Extensiva Sobre O Cpu Principal da MotherBoard Em Software Raid (BitWise XOR operations x2 nas gravações longas Write do I/O Wait). Portanto Instanciaríamos Com Mais Núcleos Físicos Locais Para A Mitigação de Alta Gravação Em Write Paralelos no Syslog de Storage."
