#!/bin/bash
# ==============================================================================
# Módulo 1: Fundamentos de Segurança Linux
# Aula 01 - Permissões Básicas (rwx)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Imagine um clube exclusivo. Há o dono do clube (User Owner), a diretoria 
# (Group) e os clientes convidados (Others). Uma sala dentro do clube pode ter 
# regras diferentes: o dono pode reformar a sala (Write), a diretoria pode 
# entrar e ver a sala (Read e Execute), e os clientes convidados podem apenas 
# olhar pela janela de vidro, mas não podem entrar pela porta e usar os luxos. 
# As permissões no Linux (rwx) são os crachás que o segurança da porta checa 
# para todo e qualquer arquivo do sistema operacional.
#
# 2. O QUE É (definição técnica Senior)
# Todo arquivo/diretório em sistemas POSIX possui 3 bits fundamentais 
# aplicáveis a 3 classes de entidades: dono (u), grupo (g) e outros (o).
# Estes bits são r (Read - 4), w (Write - 2) e x (Execute - 1).
# Em segurança corporativa, configurar permissões rwx baseadas em octal 
# (ex: 644, 755) erroneamente, como um 777 (wrx global), abre as portas 
# para atacantes lerem chaves privadas ou substituírem binários do sistema 
# por malwares (trojans locais) resultando no clássico Privilege Escalation.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Criação de um diretório de teste seguro no /tmp
mkdir -p /tmp/aula_permissoes
cd /tmp/aula_permissoes

echo "Minha senha da AWS" > segredo.txt

# Visualiza as permissões atuais (algo como -rw-r--r-- ou 644)
ls -la segredo.txt

# (Ofensivo/Risco) Mudando a permissão para 777 (R,W,X para TODO MUNDO)
# Jamais faça isso em produção. Qualquer usuário (até o servidor Apache www-data) 
# pode agora sobrescrever seu arquivo.
chmod 777 segredo.txt

# (Defesa) Restringindo para segurança máxima: Somente o Dono pode Ler e Escrever (600)
# Ninguém do grupo e nenhum "outro" usuário sequer verá o que tem dentro.
chmod 600 segredo.txt

# Demonstração de permissão de diretório
# Se um arquivo estiver protegido (600), mas a pasta onde ele está for
# "gravável e executável" por todo mundo, ele pode ser deletado de dentro da pasta.
# Por isso, protegemos também o diretório (700 = rwx apenas pro dono).
chmod 700 /tmp/aula_permissoes

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Como o root (sudo), crie um arquivo em raiz de uma pasta do usuário:
# sudo touch /tmp/arquivo_teste
# Passo 2: Digite `ls -l /tmp/arquivo_teste`. Você verá que o dono é "root".
# Passo 3: Com seu usuário não-root, tente alterar seu texto com `echo "A" > /tmp/arquivo_teste`.
# Passo 4: Esperado: Você receberá "Permission denied". O kernel bloqueou a syscall open() baseada na discricionariedade do arquivo, que pertence ao UIDs de root (0).
# Passo 5: Restaure o ownership para você com `sudo chown $USER:$USER /tmp/arquivo_teste`. O arquivo agora é seu.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# O erro mais comum em servidores Web recém-criados é desenvolvedor tomando:
# "403 Forbidden". Daí ele roda `chmod -R 777 /var/www/html/` em desespero.
# Verifique se o PHP tem acesso ao arquivo avaliando o GRUPO (o do servidor Web é www-data). A solução correta é: 
# `chown -R www-data:www-data /var/www/` e mantê-las em `644` e diretórios `755`.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# A letra `x` ("execute") em um diretório não significa "rodar o arquivo". Em um diretório,
# a permissão de Execução significa o direito de *Atravessar o Path* ou fazer *Search* (entrar nele com o `cd`). 
# Se você der Read (`r`) em uma pasta e remover o `x`, o usuário pode até dar um `ls` pra ver os nomes 
# dos arquivos listados na pasta, mas não consegue abrir ou acessar NENHUM arquivo de dados (nem entrar nela).
# Esta nuance comportamental é frequentemente falha de administradores durante jails e montagens chroot e de SFTP.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se você tem um arquivo chamado `/backups/db.sql` com permissões fortíssimas `---rwx--- (070)` pertencentes ao `root:admin` e você logou na estalção como usuário de sistema e não é root e nem participante do grupo admin, você pode DELETAR permanentemente este arquivo?"
# Resposta Esperada: DEPENDE unicamente do diretório `/backups/`. Quem deleta arquivo no Linux precisa de permissão de Escrita (`w`) na PASTA que o contém, independente de quem é o dono do próprio arquivo individual ou seu rwx interno. Se `/backups/` for 777 (ou seu usuário puder escrever nela), você exclui o db.sql tranquilamente, o que expõe ataques de Negação de Serviço locais em chaves criptográficas mal gerenciadas.
