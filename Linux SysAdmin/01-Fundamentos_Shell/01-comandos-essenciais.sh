#!/bin/bash
# ==============================================================================
# Aula 01.01: Fundamentos do Shell - Comandos Essenciais (pwd, cd, ls)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Pense no terminal Linux como uma enorme biblioteca escura, e você é uma 
# pessoa vendada lá dentro. 
# O comando `pwd` responde: "Em qual corredor e andar eu estou agora?"
# O comando `ls` funciona como uma lanterna rápida: ilumina e mostra o que tem 
# ao seu redor naquele corredor.
# E o comando `cd` representa você caminhando para outro corredor ou andar.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# O Shell (bash, zsh, sh) é o interpretador de comandos. Sem interface gráfica, 
# a navegação depende inteiramente do Entendimento do Caminho (Pathing).
# - O 'pwd' (Print Working Directory) expõe o caminho Absoluto atual.
# - O 'ls' (List Segments) lista conteúdos do diretório via chamadas de sistema (syscalls).
# - O 'cd' (Change Directory) muda a variável de ambiente $PWD e altera seu nó atual.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# Tente rodar estes comandos um por um no seu terminal SSH:

# Print Working Directory: Mostra onde estou EXATAMENTE desde a raiz (/)
pwd                         # OBRIGATÓRIO: Sempre o 1.º comando ao entrar num server.

# Change Directory: Caminha da sua posição atual (ex: /home/elias) para a pasta /tmp.
cd /tmp                     # OBRIGATÓRIO: Forma de navegar. O / no início significa "Caminho Absoluto" (partindo da raiz).

# Voltamos para nossa home base. O til (~) é uma variável mágica que aponta pro seu /home/usuario
cd ~                        # OPCIONAL: Atalho amado por todos os SysAdmins. 

# List: Lista de forma simples os arquivos onde você está no momento.
ls                          # OBRIGATÓRIO: Lista o que tem ao redor

# List com detalhes (-l de Long formato) e arquivos ocultos (-a de All). 
# Todos os parâmetros do Linux podem ser juntados: `-l -a` se torna `-la`.
ls -la                      # OBRIGATÓRIO PARA SYSADMINS: Você SÓ usará "ls" no formato "-la" na vida real.

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# O "Lembrete Mágico" (history)
# Você digitou um comando gigantesco ontem e não anotou. 
history                     # Lista tudo o que você digitou na sua vida na máquina.

# Busca Reversa: Pressione `Ctrl + R` no seu teclado e comece a digitar uma parte daquele 
# comando longo. O Bash buscará instantaneamente no histórico e auto-completará!

# Bateu e esqueceu o Sudo? `!!`
# Se você der `ls /root` e tomar Permission Denied, não redigite tudo.
sudo !!                     # SALVA-VIDAS: Roda o ÚLTIMO comando batido, mas agora injetando o 'sudo' antes.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] pwd
# [SAÍDA ESPERADA] /home/usuario
# [COMANDO] ls -la
# [O QUE FAZ] Lista todos os arquivos, incluindo os que começam com "ponto" (ocultos).
#             Mostra permissões, dono, peso e data de criação.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# ERROS COMUNS:
# - Cifrão ($) no prompt: O prompt de um usuário normal termina em `$`. 
#   O prompt do administrador (root) termina em `#`.
# - Espaços na pasta: Se quiser dar `cd` pra uma pasta com espaço, você falhará.
#   `cd Minha Pasta` tentará ir para a pasta "Minha" com parâmetro "Pasta" e dará erro.
#   Solução: `cd "Minha Pasta"` ou `cd Minha\ Pasta` (escapando o caractere de espaço).

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Por que SysAdmins Sêniores têm calafrios se um júnior não usa pwd/ls toda hora?
# Porque no Linux, as ações destrutivas (como apagar uma pasta, `rm -rf`) 
# assumem o SEU CAMINHO ATUAL como o alvo por padrão na CLI.
# Um erro clássico que tira grandes empresas do ar é: o desenvolvedor acha que está
# na pasta `/tmp/lixo`, dispara um comando destrutivo, mas na verdade a sessão
# dele havia caído para `/var/lib/mysql` (o banco de dados principal).
# Sempre saiba onde você está. Use pwd passivamente. O ls -la também expõe
# os arquivos ocultos (.bashrc, .ssh), onde 90% das configurações vitais moram.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Estou no diretório /var/log/nginx. Preciso voltar EXATAMENTE 
# para o diretório anterior em que eu estava antes de dar esse 'cd', que era 
# escondido no meio de /opt/app/scripts/deploy/antigo. Como voltar para essa
# pasta sem teclar toda a string absoluta de novo?"
#
# Resposta Esperada: "Basta digitar `cd -`. O travessão diz ao interpretador de
# comandos (shell) para ler a variável especial de ambiente '$OLDPWD' e retornar
# para o diretório anterior armazenado pelo bash em sua pilha/histórico."
