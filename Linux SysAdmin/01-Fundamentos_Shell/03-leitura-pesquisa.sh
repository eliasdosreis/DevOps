#!/bin/bash
# ==============================================================================
# Aula 01.03: Fundamentos do Shell - Leitura e Pesquisa (cat, less, tail, grep)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# No Windows se você quer ler um arquivo de texto, você dá dois cliques e abre o
# Bloco de Notas. No Linux CLI (Command Line Interface) não há "abrir janela".
# - `cat`: Funciona como um projetor. Cospe todo o texto na sua cara na parede
#   (tela do terminal) de uma vez só.
# - `less`: É como um livro. Ele abre o arquivo e não suja a tela, 
#   permitindo rolar as páginas usando as setas do teclado.
# - `tail`: É como ir direto para o último capítulo de um livro. Mostra o fim.
# - `grep`: É o "Ctrl+F" ou a barra de pesquisa do seu navegador. 

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Esses são utilitários vitais de I/O de Streams POSIX.
# - `cat` (concatenate): O objetivo original dele era unir arquivos, mas é
#   amplamente usado para dar output de arquivos inteiros no stdout.
# - `less`: Um "pager" avançado (sucessor do `more`) que não precisa carregar o
#   arquivo inteiro na RAM (Crucial em logs de Gigabytes).
# - `tail`: Imprime as últimas 10 linhas padrão. Se usado com `-f`, prende no
#   stdout observando atualizações de Inodes ao vivo.
# - `grep`: Utilitário de pesquisa usando Regex (Expressões Regulares).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# Joga todo o arquivo de senhas/usuários (que tem umas 40 linhas) na sua tela sem
# respeito nenhum por formatação visual.
cat /etc/passwd                 # OBRIGATÓRIO: Ação rápida em arquivos pequenos.

# Abre o mesmo arquivo em modo leitura interativa. 
# (Use setas cima/baixo. Para sair, aperte a letra 'q' de Quit).
less /etc/passwd                # OBRIGATÓRIO: Para arquivos longos!

# Mostra as últimas linhas do log padrão do sistema.
tail /var/log/syslog            # OBRIGATÓRIO: Forma de checar erros recentes. (No RHEL/CentOS é /var/log/messages)

# Mostra o log ao vivo. O terminal fica "preso" e toda vez que cair uma linha
# nova no log, ela pisca na tela. (Cancele com Ctrl+C).
tail -f /var/log/syslog         # OBRIGATÓRIO PARA SYSADMIN: Monitoramento em tempo real.

# O GRANDE E PODEROSO GREP (Global Regular Expression Print).
# Pesquisa a palavra "root" dentro do arquivo /etc/passwd e imprime SÓ a linha 
# onde achou a palavra.
grep "root" /etc/passwd         # OBRIGATÓRIO: Ferramenta que você usará todos os dias.

# --- DICAS PRÁTICAS DO DIA A DIA SÊNIOR ---

# E se eu não quero as ÚLTIMAS linhas, mas sim o CABEÇALHO do arquivo gigante?
head /var/log/syslog            # SALVA-VIDAS: Mostra as primeiras 10 linhas. Excelente pra ver cabeçalho de CSV!

# "Quero ver a cópia finalizando na minha tela ao vivo!"
# O comando `watch` roda N vezes um outro comando para você não precisar ficar dando 'Seta pra cima + Enter'.
watch -n 1 ls -la /tmp/arquivao.iso  # SALVA-VIDAS: Roda o 'ls' a cada 1 segundo enxergando ao vivo o peso aumentar (Aperte Ctrl+C para sair).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] tail -n 50 /var/log/syslog
# [O QUE FAZ] Em vez do padrão (10 linhas), você força mostrar as ÚLTIMAS 50 linhas do log.
# [SAÍDA ESPERADA] As últimas 50 mensagens geradas pelo kernel ou aplicativos.
# [O QUE FAZER SE DER ERRO] Permission Denied: Logs só podem ser abertos pelo
#                           administrador (necessita prefixar com 'sudo').

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# ERROS COMUNS:
# - Usar o `cat` num arquivo binário:
#   Se você tentar `cat /bin/ls` (que é o programa 'ls' compilado em C), sua tela 
#   começará a apitar e cuspir caracteres esquisitos (gibberish). O terminal pode
#   até "travar" ou bugar o teclado. Digite `reset` e dê Enter sem ver para recuperar.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# O erro catastrófico do `cat` em produção:
# Um Júnior precisa pesquisar um Erro X num log de sistema de 20 GB. Ele decide mandar: 
# `cat /var/log/app.log`. 
# O comando tenta jogar todos os 20GB na RAM do servidor de uma vez só pra
# cuspir na tela STDOUT (buffer). Ele estoura a Memória e DEPRIME ou CRASHA o DB Principal.
# O SysAdmin Sênior NUNCA usa `cat` em arquivos gigantes que não sabe o tamanho
# (ou usa 'ls -lh' pra ver o tamanho antes). Ele usa o `less` (que aloca páginas
# de blocos de disco diretamente na memória) ou vai rodar um `grep` paginado rápido.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Nós temos uma aplicação Java legada que cospe logs num arquivo único.
# Ele já tem 10 Gigabytes. O suporte L1 precisa pesquisar o IP de um cliente 
# '192.168.10.25' que falhou neste log, e também quer ver a linha exata imediatamente 
# APÓS a linha desse IP falho para entender o contexto, sem travar nada. Diga o comando."
#
# Resposta Esperada: "Grep com Context Control (After). O comando seria:
# `grep -A 1 '192.168.10.25' /var/log/app.log`
# O `grep` lê o arquivo de forma sequencial otimizada usando stream sem estourar a
# RAM com Buffer OOM. A flag `-A 1` (After 1) dirá ao GNU grep para anexar 1 
# linha subsequente ao matching no STDOUT final da pesquisa. Se fosse linha 
# anterior usaríamos `-B 1` (Before)."
