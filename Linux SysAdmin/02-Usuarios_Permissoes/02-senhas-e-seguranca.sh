#!/bin/bash
# ==============================================================================
# Aula 02.02: Usuários, Grupos e Permissões - Políticas de Senhas e Segurança
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Se `useradd` é colocar o nome do morador na portaria do condomínio seguro, 
# o comando `passwd` é o ato de dar O CONTROLE REMOTO DA GARAGEM pra ele.
# E o comando `chage` é o ato do síndico dizer "Esse controle vence em 30 
# dias por segurança contra cópias, você precisará recadastrar depois disso".
# Se o morador tiver o nome na lista (usuário existente) mas não tiver 
# controle configurado na mão dele, *ele fica travado na guarita da frente*.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# A autenticação POSIX tradicional requer um hash de password válido salvo no
# arquivo restrito `/etc/shadow`. 
# Quando um usuário é criado cru com `useradd`, ele tem o campo de hash (coluna 2
# separada por ':' no shadow) como um "!" (Exclamation mark/Locked). Isso significa 
# que matematicamente NINGUÉM pode quebrar e digitar essa Hash válida de login 
# via SSH, e a conta fica em modo "Não Interativo SSH/Local" até que o Root
# force ativamente a utilidade do binário `passwd` a injetar um Hash válido.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# O usuário João está trancado para fora do Bash dele (Locked Password).
# Definimos a senha do usuário "joao" de forma interativa.
# ATENÇÃO: Ao rodar isso e digitar a senha, ELA NÃO VAI PISCAR/MOSTRAR NA TELA (Mecanismo Cego).
passwd joao                 # OBRIGATÓRIO: Sem senha, usuário local humano é "morto vivo".

# Como ver em qual "modelo de criptografia" a senha foi salva?
# O arquivo /etc/shadow é o guardião sagrado. (Só root consegue usar CAT nele).
cat /etc/shadow | grep joao # OBRIGATÓRIO PARA AUDITORIA.
# O output dirá algo tipo: joao:$y$j9T$xyz...:19245:0:99999:7:::
# O '$y' ou '$6' é o Algoritmo Hash (SHA-512 ou Yescript moderno) 
# seguido pela Salt (pimenta) e depois o Hash Salgado final (xyz...).

# COMO TRAVAR ALGUÉM SEM DELETAR A CONTA:
# A conta de um funcionário suspeito deve ser Lock(L) bloqueada
passwd -l joao              # OBRIGATÓRIO: O Hash no shadow vira "!" de novo, negando Logins.

# E para Unlock (Desbloquear)?
passwd -u joao              # OBRIGATÓRIO: O "!" some e a senha salva VOLTA a valer!

# POLICY SENIOR: "Age of Password" (Idade obrigatória da Senha com `chage`).
# Force o João a trocar a senha (que o TI acabou de setar temporariamente genérica)
# NO EXATO SEGUNDO que o teclado dele logar via SSH e apertar Enter pela 1ª vez.
# Isso tira a responsabilidade judicial da senha do SysAdmin e a transfere pro usuário (Auditoria pura).
chage -d 0 joao             # OBRIGATÓRIO ONBOARD: (Last Day = 0 = Invalidada a senha atual).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] id joao
# [COMANDO] chage -l joao
# [O QUE FAZ] Lista (list = -l) todas as propriedades de Ciclo de Vida do João.
# [SAÍDA ESPERADA]
# Last password change                  : password must be changed
# Password expires                      : password must be changed
# Minimum number of days between password change : 0
# Maximum number of days between password change : 99999
# Account expires                       : never

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Fui forçar a troca no primeiro login `chage -d 0 joao`. Mas ele tá reclamando!
# ERRO: `You must choose a longer password / BAD PASSWORD / Too simple`
#
# Isso é o módulo **PAM (Pluggable Authentication Modules)** do núcleo do Linux.
# É o cão de guarda da corporação! Se você tentar dar `passwd` e setar "123mudar",
# ele vai checar o dicionário local em `/etc/pam.d/common-password`, usar as 
# regras de `libpam-pwquality` (exigir 8 chars, 1 maiuscula e 1 número), 
# e te bloquear de ferrar o servidor. O Sênior que instala e edita esse módulo
# para o seu Compliance do Banco Central exigido!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# É um Pecado Capital do SysAdmin Sênior deletar apressadamente o usuário do chefe 
# que acabou de sair de férias com o clássico `userdel -r`.
# Por quê? 
# Contas locais frequentemente são os proprietários legais (Owners) de arquivos, 
# pastas de NFS vitais ou CRONTABS agendados na partição /var/spool/cron/crontabs.
# Se você detona o João, os crontabs dele de "Backup da Empresa às 3 da manhã" E VÃO PRO CÉU E PARAM DE RODAR.
# Solução de quem já bateu o rosto:
# 1. TRAVE O USUÁRIO do João para ele não entrar de Curaçao (`passwd -l joao`).
# 2. ESPERE a poeira baixar, audite com cuidado o que ele automatizou com o UID dele, 
#    migre a propriedade (`chown`) vital para a conta Técnica "admin-bkp", 
# 3. Aí sim você destrói fisicamente de forma segura (`userdel`).

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você provisionou uma Virtual Machine pra uma nova agência, 
# mas o Diretor vai demorar 3 meses para assumir a conta temporária que geramos. 
# Queremos que essa conta `diretor-bh` EXPIRE DE VERDADE as 23:59h do dia 31 de 
# Dezembro de 2025, de forma autônoma sem precisarmos lembrar de dar o 'Lock' nela
# naquela noite. Como isso é feito globalmente?"
#
# Resposta Esperada: "Usando a utilidade de expiração absoluta do PAM. O comando
# é `usermod -e 2025-12-31 diretor-bh` (Expire). Isso injetará a data hardcoded
# da expiração inativando a conta até do nível de chamadas de shell via PAM, 
# garantindo conformidade com a ISO 27001 independentemente da data do Último Login 
# ou qualidade da password (uma bomba-relógio funcional pra apagar seu fogo)."
