# Módulo 0: Preparação do Ambiente
## Aula 03 - Ferramentas Base

### 1. ANALOGIA DO DIA A DIA
Imagine que o sistema operacional é um carro de corrida fechado. Aos olhos comuns, ele apenas "está andando rápido" ou "está parado". Mas, para você atuar como os engenheiros nos bastidores da F1, você não olha para o formato do carro, você conecta cabos e olha a "telemetria" (as faixas de sinal de rádio). As ferramentas como `nmap`, `netcat`, `strace` e `curl` são os leitores do motor, dos faróis, e dos fios elétricos. Elas te dizem as correntes exatas onde há vazamentos, portas sem travamento, ou rotinas que gastam mais memória. Sem as ferramentas, o Pentester é cego diante de uma porta metálica sem visão do outro lado; o Analista de Forense nunca entende o sangramento.

### 2. O QUE É (definição técnica Senior)
Ferramentas de Base Unix e SysAdmin representam o canivete suíço de binários nativos de auditoria interativa de um sistema corporativo. Trata-se da infraestrutura binária (binários de `/usr/bin/`) utilizada não apenas para administrar, mas sim abusar e analisar estado, inspecionando descritores de rede (sockets), chamadas procedurais do kernel (syscalls) ou manipulando dados raw (netcat e curl). A distinção do Sênior reside no fato de dominar utilitários "NATIVOS" quando não é possível subir scripts `.py` cheios de bibliotecas, pois durante escalações de privilégios ou post-exploitation, um atacante precisa viver do que a terra proporciona (Living off the Land).

### 3. SCRIPT / COMANDO COMENTADO
Vamos focar hoje num mini-guia de canivetes primários para testar de rede e kernel:

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Demonstra os usos MAIS CLÁSSICOS do dia a dia Sênior com as 4 ferramentas 
# de base, as pedras de fundamental do Pentest Linux e Troubleshooting.
# Execute cada bloco conforme a necessidade, são tutoriais, não um script de um-ciclo.
# ============================================================

#!/bin/bash
# =========================================================
# Ferramenta 1: NETCAT (nc) - O Canivete Suiço do TCP/UDP
# =========================================================
# Defensivo: Verificar de forma crua se a porta 80 do IP responde
nc -vz 127.0.0.1 80

# Ofensivo: Escutar localmente para receber conexões shell reversas (-l escuta, -v detelhado, -p porta)
# nc -lvp 4444 

# =========================================================
# Ferramenta 2: CURL - Manipulação de Requesições HTTP
# =========================================================
# Defensivo: Ver apenas o código HTTP que o site devolveu (ex: 200, 403 Forbidden) silenciosamente (-s)
curl -s -o /dev/null -w "%{http_code}\n" http://google.com

# Ofensivo: Fazer uma requisição customizada forjando os cabeçalhos User-Agent, simulando que é um Android e pedindo verb OPTIONS
# curl -X OPTIONS -H "User-Agent: Mozilla/5.0 (Android)" http://banco-vulneravel.lab/api/users

# =========================================================
# Ferramenta 3: STRACE - Trace de Syscalls (Depuração)
# =========================================================
# Um comando clássico para descobrir aonde um programa bugado está falhando
# -e openat,read -> limita a output gigante do trace apenas a eventos de leitura de arquivos ou abrimento
# -p PID -> attach em um processo vivo; util p/ investigar comportamento do malware ativo

# strace -e openat,read cat /etc/passwd

# =========================================================
# Ferramenta 4: NMAP - Escopo rápido
# =========================================================
# Comando Sênior Rápido para Ping Sweep e Varredura básica stealth TCP (SEM resolução de DNS n, T4 rápido)
# nmap -sn 10.0.0.1-254
```

### 4. PASSO A PASSO
**Passo 1:** No seu Linux, digite `man nc` e `man strace` para validar que estão instalados e conferir a sintaxe local (`CentOS` vs `Debian` pode diferir as flags do nc entre `ncat` e `netcat-traditional`).
**Passo 2:** Rode `nc -lvp 9000` em um terminal do seu sistema host. Deixe a janela quieta. Ela representa um Listener.
**Passo 3:** Em *outra* janela no mesmo ambiente, abra um `nc 127.0.0.1 9000` e comece a digitar algo. Pressione enter. O outro lado vai replicar a mensagem. *Parabéns, você criou um canal C2 (Command & Control) cego cru.*

### 5. VERIFICAÇÃO E TROUBLESHOOTING
- **nc: command not found?** Distribuições modernas estão removendo o nativo `nc`. Instale-o com `sudo apt install netcat-traditional` (Debian/Kali) ou instale o pacote `nmap-ncat` no RHEL, que possui um `nc` com suporte nativo superior inclusive a SSL.

### 6. CONCEITO SENIOR (o "porquê" profundo)
O `strace` é venerado pela Blue Team e Pesquisadores. Um analista júnior que recebe um servidor que misteriosamente a configuração Nginx quebra por "Permission Denied" mesmo quando roda de `root`, vai dar chown cego pra tentar resolver. O analista Sênior emite `strace -f -p $(pgrep nginx)` para descobrir o PID pai e filhotes exatos e interceptar *em qual descritor de arquivo do SO a syscall openat* recebe o código numérico `EACCES (Permission Denied)`. Ele então resolve o problema forense sem achismos. Na via do ataque, um processo com SUID setado pode rodar comandos em modo invisível na RAM, mas com um strace anexado (se o usuário for capaz), é capturável a leitura do /etc/shadow, permitindo criar vazamento das credencias secretas durante execução ou encontrar os famigerados "buffer overflow" lances sem precisar carregar o programa no pesado GDB inicialmente.

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Durante um processo de Pentest em um container muito minimalista e restrito (Alpine Linux image), você verifica que **nem o `ping`, nem o `nc`, ou até `curl`** existem nele. Você só possui ferramentas básicas do kernel `/bin/bash` nativo pra interagir. Como você faz um port-scan primitivo reverso no modo Living-Off-The-Land via bash cru na rede interna deles?"
**Resposta Esperada:** Bash possui suporte puro para pseudo-devices embutidos sob dev/tcp que criam sockets pelo própio bash! O recurso é `/dev/tcp/<ip>/<porta>`. Pode-se criar uma checagem (um redirecionador e echo string pro caminho `/dev/tcp/10.0.0.10/80` ) para ver o código de retorno de erro se falhar no Socket establishment. `(echo >/dev/tcp/10.0.0.10/80) &>/dev/null && echo "Aberta" || echo "Fechada"` dentro de um mini loop `for` do bash garante varredura furtiva impecável sem baixar nenhum executável extra, bypassando controles que monitorariam a invocação e execução das assinaturas de utilitários como nc ou nmap no Sysmon/Auditd.
