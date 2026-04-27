#!/bin/bash
# ==============================================================================
# Aula 01.05: Fundamentos do Shell - Variáveis de Ambiente (export, env, .bashrc)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Imagine que você é um cozinheiro recém-contratado num restaurante. Quando 
# alguém diz: "Pegue a faca boa!", você não sabe que faca é essa nem onde ela 
# fina. As **Variáveis de Ambiente** são "placas" espalhadas pela cozinha do 
# restaurante. Tem uma placa chamada FACA_BOA="/gaveta2/faca_chefe".
# Assim, qualquer funcionário (programa) que entre na cozinha sabe onde achar 
# as coisas sem perguntar.
#
# O `.bashrc` (script de carga oculto) é o "Treinamento Matinal" que o restaurante 
# te obriga a ler todo dia que você bate o ponto e entra pra trabalhar (inicia seu bash).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# As Variáveis de Ambiente (ENV) são pares de Chave-Valor dinâmicos (key-value)
# do Escopo Global que afetam a forma como os processos rodam no SO.
# Como o Shell executa aplicativos, ele passa suas próprias variáveis para os 
# aplicativos "filhos". Ex: O pacote Java precisa da `$JAVA_HOME` para inicializar
# o Classpath do Tomcat sem erro. O Git precisa do `$USER` para logar commits, etc.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# O comando `env` (environment) imprime todas as suas variáveis atuais carregadas.
env                         # OBRIGATÓRIO: Forma de descobrir os parâmetros carregados do seu user atual.

# Imprimindo apenas UMA variável com o "echo" e o "$" (leitor de valor da chave)
echo $HOME                  # Imprime aonde é sua casa base (/home/elias)
echo $USER                  # Imprime "elias"
echo $PATH                  # Essa é a variável Mais Crítica do SO (falaremos na Entrevista).

# Criando uma Variável Temporária na mão
MEU_NOME="Elias Silva"
echo $MEU_NOME              # Vai imprimir: Elias Silva

# Se abrirmos UM OUTRO PROGRAMA filho, ele NÃO VERÁ a MEU_NOME. Ela está "Local".
# Para disponibilizar a variável Globalmente (para todos os filhos desse shell)
export MEUBANCO="10.0.0.5"  # OBRIGATÓRIO: Variáveis do nível de SO precisam de 'export'.
                            # Porem, ao fechar (logoff) o Terminal/SSH, AMBAS VARIAVEIS MORREM.

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# Cansou de digitar comandos repetitivos o tempo inteiro? Use Aliases (Apelidos)!
alias ll="ls -la"           # Agora se eu bater só "ll", ele executa um ls -la.
alias logs="tail -f /var/log/syslog" # SALVA-VIDAS: Digita 'logs' e já vai direto pra matriz!
# Como variáveis normais, para ele não evaporar ao dar Reboot, coloque seus Aliases
# preferidos ocultos no final do seu arquivo mágico `~/.bashrc`.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# Para tornar a Variável Permanente (sobreviver ao boot), você deve forçar que 
# o Shell "re-digite" aquele valor cada vez que você abre o SSH no provedor Cloud.
#
# [COMANDO 1] echo 'export BANCO_PRODUCAO="192.168.10.55"' >> ~/.bashrc
# [O QUE FAZ] Insere secretamente no final do arquivo de configuração do seu Bash (~/.bashrc)
#             aquele export. 
# [COMANDO 2] source ~/.bashrc
# [O QUE FAZ] (Source): Recarrega o seu terminal ao vivo, injetando os poderes
#             novos sem precisar desligar o seu PuTTY/SSH e relogar do zero.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# ERROS COMUNS:
# - Criei variavel TESTE="123", digitei `echo TESTE` (sem o $)
#   A tela devolve literal a string: `TESTE` e não os dados "123".
#   No Linux bash script, nome duro é String. Nome prefixado com cifrão ($) 
#   puxa dados do bloco de memória para STDOUT. (Linguagem C derivada posix).
# 
# - ERRO CLÁSSICO: Minha variável evapora depois do Boot.
#   Você não colou as definições nos arquivos universais do SO 
#   como no arquivo global: `/etc/environment` , e nem no seu perfil isolado: `~/.bashrc` / `.profile`.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Um Desenvolvedor Júnior insere as credenciais do Banco de Dados no Git do projeto 
# dele e empurra (Push) o arquivo app.js escrito: "senha=123". Ele compromete e 
# aposta a segurança de toda a corporação pra qualquer hacker que pegar o zip desse Git.
#
# O Sênior usa as melhores práticas (12-Factor App methodology).
# O código do Sênior tem escrito: `senha = process.env.DB_PASSWORD;`
# O código (app) NUNCA sabe a senha! A senha é exposta PELO SISTEMA OPERACIONAL
# como uma Variável de Ambiente (`export DB_PASSWORD=123`) em Produção. Se roubarem
# o código-fonte inteiro, só vão achar a string "DB_PASSWORD" (o nome da Placa do restaurante), 
# mas não sabem para onde a placa aponta até entrarem na própria VM logados no Linux!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Nós instalamos o binário do Hashicorp Terraform baixando um `.zip`
# customizado na posta /opt/terraform. Quando o usuário digita 'terraform' como num passe
# de mágica de qualquer lugar, o Linux acusa que o comando 'não foi encontrado'.
# Por que ocorre esse erro e como o sistema Sabe qual pasta ele deve ler pra achar NGINX, 
# mas não sabe do Terraform?"
#
# Resposta Esperada: "O bash falha na identificação do hash de PATH. Nós temos uma
# variável de ambiente hiper-crítica chamada estritamente de `$PATH` (caminho).
# Ela carrega um conjunto de pastas no formato: `/bin:/usr/bin:/usr/local/bin:/sbin`.
# Ao invés do bash ler o disco inteiro (15 milhões de arquivos, matando o disco) atrás da
# palavra 'terraform', ele navega apenas restrito nos diretórios colonizados ($PATH).
# O utilitário foi colocado em '/opt/terraform'. Para consertar permanentemente, eu
# abriria o `~/.bash_profile` (ou rc) deste usuário, e faria um append da env:
# `export PATH=$PATH:/opt/terraform`. Isso concatena a lista antiga com o novo diretório final."
