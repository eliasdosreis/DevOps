#!/bin/bash
# ==============================================================================
# Módulo 6: Auditoria e Análise de Logs
# Aula 02 - Monitoramento Contínuo com Auditd (O Vigia do Sistema)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# O Syslog/AuthLog da Aula 1 é o porteiro do prédio, anotando *quem passa pela porta*.
# Mas e se um funcionário que NUNCA passa pela porta principal pois dorme no prédio
# (processos rodando como Root em Background) pegar uma marreta e quebrar as paredes de tras?
# O Porteiro não vai ver.
# O `auditd` é uma rede de **Câmeras de Segurança Mágicas de Raio-X** instaladas DENTRO 
# DO CÉREBRO do General do prédio (o Kernel). Se *qualquer pessoa* tentar "tocar num arquivo" (open)
# ou "dar um passo suspeito", a câmera de raio-X filma o movimento molecular da Célula!
# Ele audita SystemCalls nativas em real-time, impossivel bypassar calado.
#
# 2. O QUE É (definição técnica Senior)
# Audit Daemon (auditd): Componente nativo de kernel hook. Ao invés de dependermos 
# que o `Apache` tenha a bondade cívica de gerar um log string dizendo q sofreu erro fatal.... 
# O Auditd senta entre o Apache e a Ram C/ Disco Rigído (Via interceptor de sys_calls hook). 
# Toda vez que um binário pedir p `sys_openat("/etc/shadow")` o Kernel pisca uma bandeira e o auditd loga:
# "O PID X, executando binY, tocou no hashZ numa terca.". Regras paramétricas criam a conformidade do governo (CIS).
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo: Instalar o vigia (vem by default em RedHats. Em debian precise install auditd).
# sudo apt install auditd

echo "[+] Ativando a Regra de Ouro (Monitorar Alterações do arquivo de cofre de senhas):"
# auditctl manipula as regras via RAM de forma volátil até reboot. 
# -w (watch/olhe) /etc/shadow.  -p (permissions de escrita wa - write/append/attributechange). 
# -k (key tag) -> Marcamos o log dessa regra com nome 'pwd-edit' para ser achavel pelo SOC team dpois.
# sudo auditctl -w /etc/shadow -p wa -k pwd-edit
# sudo auditctl -w /etc/passwd -p wa -k pwd-edit

echo "[+] Ativando Monitoramento de Comandos Suspeitos Rodados (Execve sys_call) por roots logados:"
# Monitorar SE ALGUM root invocar o `nc` netcat ou coisas doblescas
# sudo auditctl -a always,exit -F arch=b64 -S execve -F euid=0 -k root-commands

# VENDO OS FRUTOS: Buscando os alertas gerados a partir do banco de dados auditd. 
# ausearch -> ferramenta pra ler as tags geradas. (NUNCA LEIA LOGS cat audit.log puro, eh codigo em HEX doidao as vezes e ilegivel!)
echo -e "\n[!] Alguém mexeu nos arquivos de senhas?"
# sudo ausearch -k pwd-edit | grep "type=PATH"

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Digite a regra pra gravar quem mudar a passwd e shadow via auditctl do bloco acima.
# Passo 2: Abra um terminal e se finja de um hacker ou script sysadmin alterando a senha `sudo passwd elias`.
# Passo 3: O log foi processado calado pelo auditd em `/var/log/audit/audit.log`.
# Passo 4: O Analista SOC usa pra plotar a auditoria unificada formatada e bonita por terminal GUI de dash local, usando o repórter: `sudo aureport --key`. Ele vai cuspir uma tabela top-view dizendo: "Key: pwd-edit teve 1 hits de 3 acessos suspeitos na data H.".  Isso poupa milhares de minutos ao analista perito.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando o auditd "Trava o servidor e cracha a base" no meio do dia do banco (downtime). Porque? Admins novatos logam regra como `auditctl -S openat` ou seja, Audite a chamada de "abrir arquivos". MEU AMIGO, o sistema operacional abre 1.6 milhoes de arquivos vitais por MINUTO da RAM em servidores ocupados! O disco log write vai chegar a 500MB/s e vai matar todo CPU ou encher particao `/` em duaa horas, num ataque Denial os Service feito por sí próprio. Regras auditd tem q ser EXTREMAMENTE granulares no `-F` com paths restritos de bypass pra nao morrer por log exhaustion!
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro audit.rules (Arquivo estático onde botamos as regras pra ele auto-carregar no boot da máquina) ter uma tag final chamada `-e 2` (Emulate Immutable Mode). Um hacker, se ele for rootar a maqna e conseguir RCE, a primeira coisa q o espertinho faz na tela dele na pressa as escuras é: `auditctl -D` q DELATA TODAS s regras vigias da pm, e ent deixa ele livre pra hackear dpois! MAS... Se o blue team ativou The Immutable Flag (-e 2) as 8h da manham O KERNEL bloqueia DELETIONS E EDITIONS de regras DA PRÓPRIA engine Auditd PARA TODOS INCLUSIVE DO ROOT! A engine só se desbloqueará e o hacker so poderá desligar as cameras se ele DER SHUTDOWN total fisisco do Server. 10 de QI.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Se tudo é sys_call para o auditd, quando um maluco roda 'rm /pasta/secreta/*', o log não grava o texto em branco contendo 'rm' bonitinho como log Syslog faz. Ele grava apenas strings HEXA ou numeros de syscall q matam leigo. Como o 'ausearch' lê as conversões cruas pro ingles puro pra te salvar tempo e vc achar rápido O Comand exato digitado?"
# Resposta Esperada: O usearch possui a tag mágica `-i` de `--interpret`. Usando `ausearch -i`, aquela conversão HEXA bizarra nativa cru de kernel como `proctitle=7368002D63002F62696E` eh destraduzida e revertida instantâneamente pra formato legivel humano no console entregando a bomba q era um "sh -c /bin/bash".
