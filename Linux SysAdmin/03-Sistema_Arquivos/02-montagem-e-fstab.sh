#!/bin/bash
# ==============================================================================
# Aula 03.02: Sistema de Arquivos - Montagem e Arquivo fstab (mount / umount)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Lembra da aula passada que colocamos "Asfalto" (Ext4) no terreno novo (`/dev/sdb1`)?
# Aquele asfalto já existe, mas se você der o comando "cd", você não consegue
# "entrar" nele! Por quê? 
# Porque ele é uma ILHA separada da Cidade Principal (Root `/`). 
# Montagem (Mount) é VOCÊ CONSTRUIR UMA PONTE da ilha até a cidade!
#
# Você cria uma porta vazia (Pasta vazia /mnt/dados_empresa), e diz pro Linux:
# "Tudo que a galera jogar dentro dessa pasta /dados_empresa, NA VERDADE 
# você joga pela ponte e cai no disco SDB1 (O HD Novo Físico)".
# ISSO É FANTÁSTICO. O usuário nem percebe que a pasta tá abrindo 
# portas pra outro hardware físico num rack diferente!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# A Árvore de Diretórios (FHS) exige que todos os file systems sejam embutidos nela.
# O `mount` atrela o Inode Raiz de um Dispositivo de Bloco de Armazenamento a um 
# DIRETÓRIO ponto de montagem (Mount Point) existente.
# Se o ponto `/mnt/dado` tinha textos inúteis do disco padrão, após montar o 
# /dev/sdb1 em cima dele, esses textos ficarão "ofuscados", e o conteúdo que 
# aparecerá é o real conteúdo formatado do disco sdb1.
# O `/etc/fstab` (File System Table) guarda o registro Permanente de Montagem.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Todos os comandos abaixo exigem Privilégios Root (Sudo).

# Passo 1 (Criar a Porta / Pasta Vazia pra ancorar a Ponte)
mkdir /mnt/dados_empresa    # OBRIGATÓRIO (Em vez de /mnt, as vezes é um Backup Directory /bak).

# Passo 2 (Montagem Volátil ao vivo)
# O sdb1 já foi asfaltado com mkfs na aula passada.
mount /dev/sdb1 /mnt/dados_empresa  # OBRIGATÓRIO: Liga fisicamente o HW na Árvore.

# Quer verificar o que tem plugado agora e quanto de espaço gasta?
# O Disk Free Mostra em Human Readable File (-h) (Mb, Gb) e o Tipo do FS (-T).
df -hTh                     # OBRIGATÓRIO A TODA HORA! Seu painel de carro de armazenamento.

# O disco engasgou por corrupção ou o Inode falhou? E agora?
# Desmonte com 'umount'. O 'u'mount é Único (não tem a letra N!! É 'U').
umount /mnt/dados_empresa   # SEGURO: Fecha a ponte. Você pode remover o PenDrive com Segurança.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# O CÓDIGO DA IMORTALIDADE DO SERVIDOR O `/ETC/FSTAB`:
# [COMANDO] cat /etc/fstab
# [O QUE FAZ] Ele lista O CADERNO DE BOTAS DO LINUX. Todo servidor que liga no DataCenter
#             LÊ ESSE ARQUIVO e monta as pontes das pastas físicas Sozinho.
# [SAÍDA ESPERADA EXTREMA]
# UUID=1e7b6d19-d /         ext4    errors=remount-ro 0       1
# UUID=c7f9999a   /mnt/dado ext4    defaults          0       2

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: "umount: target is busy"
#   VOCÊ TENTA DESMONTAR o disco USB pra ir almoçar, E O LINUX MANDA VOCE ESPERAR O 
#   TARGET DESOCUPAR! E Agora? Que programa invisível tá com a USB lendo ela?
#
#   O comando do hacker Sênior é o `lsof` (List Open Files) ou o abençoado `fuser`.
#   COMANDO: `fuser -m /mnt/dados_empresa`
#   Com isso ele exibe O PID ESPECÍFICO NUMÉRICO do processo travando. (PID: 1442).
#   Aí eu vejo que o "Chrome" ou um "Script do João" ta lendo arquivo lá. 
#   Aí é so Matar ele: `kill -9 1442` e dar 'umount' tranquilo e ejetar a USB.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# A Destruição Completa do Mundo SysAdmin e O Por que o Sênior NUNCA usa /dev/sdb1.
# O JÚNIOR vai no `vim /etc/fstab` e escreve: 
# `/dev/sdb1   /var/lib/mysql   ext4   defaults   0  0`
# E salva. E diz: Eu automatizei o disco novo do Banco pra montar no Boot! Show!
# 
# O Problema: No Natal, o Servidor é desligado. Um Técnico tira a poeira e na 
# hora de reconectar os 40 HDs de gaveta, inverte o HD da porta SATA 1 pra SATA 2.
# Quando a placa mãe acorda (Kernel), O HD QUE ANTES SE CHAMAVA "SDB", AGORA SE
# CHAMA "SDC" (Porque mudou de porta USB/SATA hardware!).
# E o HD VAZIO E FORMATADO "SDB" MONTA A PORCARIA VAZIA EM CIMA DO MYSQL DO BANCO DADOS DE NATAL DA EMPRESA!
#
# O Sênior apaga tudo que tem /dev/sdb1 e copia o Número Espiritual Imutável daquele 
# microchip de armazenamento, o `UUID`. 
# O FSTAB do Sênior tem escrito: `UUID=8e3e4a2b-92f /var/lib/mysql (...)`. 
# O Kernel pode jogar o HD no telhado, se ele continuar lá, o UUID vai bater 
# perfeito com a montagem, previnindo colapso geral de partição flutuante.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Mudei O UUID e editei cinco novas linhas no FSTAB na mão hoje e fechei o 'vi'. 
# Se eu reiniciar o servidor Agora, qual o meu Risco?"
#
# Resposta Esperada: "Você quebrou a regra principal de Administração de Sistemas.
# O risco não é dar Kernel Panic, mas sim Entrar no 'Emergency Mode Local'.
# Você jamais pode alterar as pontes físicas (/etc/fstab) e dar reboot sem TESTAR 
# se você não errou UMA VÍRGULA/ESPAÇO naquela sintaxe.
# A melhor prática é Sempre: Editar fstab, Salvar e Rodar Imediatamente o comando `mount -a`. 
# Ele é o simulador All que engole o seu arquivo. Se ele travar ou não der saída alguma,
# significa que está Impecável pra ser reiniciado. Se disser 'Failed parse linha 2',
# Ele acabou de impedir que vc sofresse pra arrumar o servidor remotamente pelo painel cloud."
