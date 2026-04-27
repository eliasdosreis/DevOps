#!/bin/bash
# ==============================================================================
# Aula 02.01: Usuários, Grupos e Permissões - Gerenciamento de Usuários
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Pense no servidor como um condomínio residencial fechado de altíssimo luxo.
# Quando alguém chega para morar lá (um novo desenvolvedor ou a instalação do
# banco de dados PostgreSQL), o síndico (o usuário 'root') precisa registrar 
# essa pessoa na portaria.
# - 'useradd': É a caneta do síndico anotando na prancheta que a pessoa existe.
# O porteiro então consulta essa prancheta todo dia para ver quem pode ou não
# entrar pelo portão.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# No UNIX, tudo é um arquivo e todo processo pertence a um Usuário. 
# Usuários não são "contas visuais", são Identificadores Numéricos (UID - User ID).
# Quando você dá o comando 'ls -la', o Linux na verdade lê o ID interno do 
# dono do arquivo (ex: UID 1002) e cruza os dados com o arquivo banco de dados
# em `/etc/passwd` para traduzir o UID humano na tela para "elias".
# O UID 0 é restrito hardcoded no Kernel (é o SuperUser Root).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# Os comandos a seguir exigem privilégio de Root. Se testar localmente, coloque 
# `sudo` antes de cada um, mas em scripts SysAdmin, assumimos acesso Root `#`.

# Criação Limpa (Apenas anota no arquivo /etc/passwd). Não cria uma "casa" pra ele.
useradd visitante               # NÃO RECOMENDADO: Usuário nasce sem pasta local e sem shell padrão.

# Criação de um Desenvolvedor Padrão (O jeito correto e seguro)
# -m : Cria o diretório (Make Home) em /home/joao
# -s : Define o Shell interpretador padrão para o Bash Seguro (se não ele vai pro antigo /bin/sh falho)
# -c : (Comment) O nome completo do dono verdadeiro dessa conta para auditoria futura.
useradd -m -s /bin/bash -c "Joao da Silva Dev" joao    # OBRIGATÓRIO: Forma Sênior de instanciar conta.

# Verifica se ele foi criado. O comando `id` mostra o UID/GID matemáticos dele.
id joao                         # Saída: uid=1001(joao) gid=1001(joao) groups=1001(joao)

# Se o Joao casar e mudar de sobrenome ou você quiser trocar o shell dele?
# O comando usermod (Modify) altera regras On The Fly (ao vivo).
usermod -c "Joao Silva e Santos" joao  

# O Joao foi demitido as 17:00 da Sexta. E agora?
# -r : CUIDADO! Esse flag remove o usuário E TODA A PASTA /home/joao DELETANDO 
#      todos os dados e códigos que estavam salvos dentro dela de forma irreversível!
userdel -r joao                 # OBRIGATÓRIO PARA OFFBOARDING: Limpa o usuário e o lixo em disco dele.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] id
# [O QUE FAZ] Sem passar nomes, ele avalia você mesmo. Mostra quem EU sou agora.
# [SAÍDA ESPERADA] uid=0(root) gid=0(root) groups=0(root)

# [COMANDO] cat /etc/passwd | tail -n 2
# [O QUE FAZ] Lê os dois últimos registros globais da portaria de usuários do sistema para conferir a criação.
# [SAÍDA ESPERADA] joao:x:1001:1001:Joao Silva e Santos:/home/joao:/bin/bash

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - Fui deletar o desenvolvedor "joao" com `userdel joao` e o erro disse: 
#   "userdel: user joao is currently used by process 12455"
#
# Isso significa que o João DEIXOU um script ou um banco rodando no background na 
# máquina. O Linux protege processos órfãos e recusa apagar um usuário que está
# com softwares em execução! O SysAdmin deve usar `kill -9 12455` para matar o 
# processo do João, e SÓ ENTÃO apagar a conta com `userdel`.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Contas de Serviço (System Accounts) vs Contas de Sessão.
# Por que quando o NGINX é instalado ele lança um `useradd nginx`? O Nginx é um 
# humano que vai logar via teclado? NÃO. Um Sênior entende que cada Software rodando
# no servidor *DEVE TER SUA PRÓPRIA CONTA DE USUÁRIO ISOLADA*.
# Se o Nginx rodar como "Root", um hacker que explorar pelo navegador uma falha do 
# Nginx vai virar Root instantaneamente.
# Se o Nginx roda num usuário bobo "nginx" travado sem /home, o hacker só toma os
# direitos de um usuário que não pode nem listar os arquivos das partições vitais.
# Por isso rodamos: `useradd -r -s /usr/sbin/nologin nginx` (Conta de sistema).

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você roda 'cat /etc/passwd' numa máquina de um desenvolvedor do 
# nosso time e, por alguns segundos de desatenção, um fornecedor tira foto da 
# sua tela em uma reunião. Nessa tela apareciam todas as linhas do arquivo de 
# senhas (/etc/passwd). Precisamos girar (resetar) as chaves inteiras dessa 
# máquina ou esse vazamento é inócuo?"
#
# Resposta Esperada: "O vazamento do /etc/passwd é inócuo a nível de senhas puras,
# pois desde o ano 2000, o Linux implementou Shadowed Passwords. Na linha do
# /etc/passwd haverá apenas o caractere 'x' (placeholder) onde moraria o Hash
# real. O verdadeiro Hash criptográfico de senhas mora em `/etc/shadow`, que
# possuí travas duras e SÓ pode ser lido pelo UID 0 (Root). Portanto, não 
# ocorreu vazamento de segredos de autenticação, apenas os nomes de contas 
# (enumeração de contas válidas)."
