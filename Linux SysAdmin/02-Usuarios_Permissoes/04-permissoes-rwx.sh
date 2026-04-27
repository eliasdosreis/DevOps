#!/bin/bash
# ==============================================================================
# Aula 02.04: Usuários, Grupos e Permissões - O Poderoso RWX (chmod, chown)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Imagine cada arquivo Linux como um "Cofre" com 3 tipos de travas de acesso:
# 1ª Trava (Dono): O Dono do cofre (Aquele único que comprou ele).
# 2ª Trava (Grupo): Os Sócios do Dono (O Grupo Vip de pessoas da equipe dele).
# 3ª Trava (Outros): Qualquer pessoa que entre da rua (O Mundo todo).
#
# Para CADA uma dessas 3 travas de pessoa, existem 3 "botões" físicos R W X:
# [r] Read (Olhar): Deixa a pessoa ver o que tem dentro do cofre.
# [w] Write (Escrever): Deixa a pessoa enfiar/tirar coisas do cofre de verdade.
# [x] Execute (Correr): Deixa a pessoa "Dá Start" num arquivo como se fosse .EXE.
#
# O administrador ajusta e vira essas argolas o dia todo pra manter o Linux blindado.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# As Permissões Estritas POSIX usam bits de notação Octal (Mundo Binário) no Inode de metadados.
#
# r = 4 (O bit 2^2 ativado, 100)
# w = 2 (O bit 2^1 ativado, 010)
# x = 1 (O bit 2^0 ativado, 001)
# 
# A soma desses bits te dá as famosas "Permissões de Linux":
# 7 = 4+2+1 (Ler, Escrever, Executar: O cara é rei absoluto).
# 6 = 4+2   (Lê e Edita o código. Muito comum pra texto).
# 5 = 4+1   (Lê e Executa o Script. Não edita).
# 4 = 4     (Apenas Lê e olha no CAT).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# CHMOD (Change Mode - Modificar Argolas do rwx e Travar o Banco de Dados)
# Arquivo Secreto "chaves.txt": Dá poder 6 (rw) pro Dono, e zera o resto do Universo (0 e 0).
chmod 600 /tmp/chaves.txt            # OBRIGATÓRIO (SSHD Exige isso ou te desconecta na marra).

# Arquivo "Avisos" 644: Dono PODE ler/editar (6), Equipe lê(4), e Visitante lê(4).
chmod 644 /tmp/avisos.txt            # OBRIGATÓRIO EM PRODUÇÃO GERAL (PADRÃO SEGURO EM 95% DOS ARQUIVOS DE SERVIDOR DE WEBSITES EXTERNOS).

# O FAMOSO CHMOD 777: Totalitarismo Anárquico Absoluto. Causa Justa de Demissão de JÚNIORS!
# O Dono Lê, Edita e Roda Scripts Virais. A equipe idem, e "Qualquer Usuário do Universo" tbem.
chmod 777 /tmp                       # NÃO RECOMENDADO EM NADA EXTERNO, EXTREMAMENTE PERIGOSO PARA WEBROOTS!

# CHOWN (Change Owner - Passar a Escritura da Propriedade pra Outra Pessoa/Grupo Vital).
# Um Root criou um log file que ninguém lê. Precisamos dar essa escritura (Ownership) pro software "Nginx" que pertence ao grupo orgânico "www-data" dele.
chown nginx:www-data /var/log/app.log # OBRIGATÓRIO (Sem isso, o Nginx não joga os logs de erro dele no arquivo).

# CHMOD MÁGICO "+X" (O Expresso de Executar). 
# Você baixou um script de Python que você precisa dar Dois Cliques "Play". O Linux recusa Scripts Sem a marca d'água Executável Ativada. Você injeta à força:
chmod +x meuarquivo.sh               # OBRIGATÓRIO PARA BASH SCRIPTS DE DEPLOY E MIGRATION DE APPS DA ESTRUTURA.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] ls -la
# [O QUE FAZ] Ele não só lista, ele imprime EXATAMENTE os botões setados hoje.
# [SAÍDA ESPERADA] -rw-r--r-- 1 root root 15 Jan 1 10:00 /tmp/teste
# [VISÃO DO SENIOR PRA ESSA SAÍDA DE LIXO ACIMA?]
#           - rw- r-- r-- = Arquivo Padrão | Dono RW (6) | Equipe R(4) | Universo R(4). 
#           Isso quer dizer que /tmp/teste é um arquivo intocado de valor 644! Sorteado!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: "Permission Denied ao executar Meu Script" 
#   Solução: `chmod +x meu_script.py`
# - DEU UM COMANDO de CHMOD RECURSIVO '-R' EM CIMA DE PASTA:
#   Você roda: `chmod -R 644 /minha_pasta`. AÍ VOCÊ TENTA ENTRAR NA PASTA E DÁ PERMISSION DENIED!
#   Por acaso, você esqueceu que, EM UMA *PASTA*, O BIT 'X' NÃO SIGNIFICA 'EXECUTÁVEL'.
#   Em Pastas, o 'x' (número 1 / Entrar) é O QUE DEIXA O COMANDO 'cd' ATRAVESSAR E ABRIR ELA!
#   Se dar chmod 644 (sem x) pra dono de pasta (4+2 = rw), você TRAVA A PASTA até pra você.
#   Por isso, pastas SEMPRE são: chmod 755 (Elas PRECISAM do número ímpar 1 pra ter Entrar).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Como o Sênior cria arquivos do zero "Seguros"? O conceito de UMASK (User file-creation Mode Mask).
# O Pleno acha que o Ubuntu "chuta" que o arquivo txt nasce sendo 644 puramente com a sorte.
# NÃO. Todos os processos do Kernel herdam um "Umask de Segurança" que debita números
# iniciais do "777 Abordagem Desnuda".
# A umask padrao raiz é `0022`. Logo o Linux debita 777 bruto das pastas e faz: 777-022 = Pastas Nascem `755`.
# O mesmo Linux faz de arquivos puritanos (666 limpo de perigo): 666-022 = Arquivos nascem `644`.
# O Sênior manipula o `umask` direto no `.bashrc` da Infra Automática do Terraform pra garantir compliance!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você deu chmod 644 no arquivo estático /var/www/secret.txt. Ou
# seja, o nosso grupo Web não tem Write, apenas 'Read' (4). Você verifica que os
# outros usuários continuam apagando o secret.txt toda manhã. Por que se a
# permissão W(2) sumiu?"
#
# Resposta Esperada: "No UNIX VFS Directory System, o ato de 'apagar' fisicamente ou
# renomear O NOME de um arquivo ("rm file.txt") não requer Write(2) no PRÓPRIO ARQUIVO txt!
# Quem guarda a lista de nomes é o INODE DA PASTA MÃE! O invasor está usando o Write na pasta
# /var/www inteira e recriando diretórios. Logo, o CHMOD correto de segurança deveria atuar
# bloqueando O DIRETÓRIO /var/www."
