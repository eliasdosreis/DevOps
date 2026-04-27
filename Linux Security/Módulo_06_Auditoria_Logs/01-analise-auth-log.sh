#!/bin/bash
# ==============================================================================
# Módulo 6: Auditoria e Análise de Logs
# Aula 01 - Análise de Auth.log e Journald (Caçando Brute Force)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# O log é o "Livro de Ponto" do Porteiro do prédio. Se o porteiro anota certinho
# "O Sr João do apto 40 entrou as 2am", O Blue Team no dia seguinte sabe
# quem mijou no tapete do saguão. Um ataque de Brute Force é um doído 
# fantasiado de Entregador que bateu na portaria 400 vezes numa tarde e o
# porteiro negou 399x ("Failed Password") e depois DEIXOU ele entrar 1x
# ("Accepted Password"). O segredo da detecção não é impedir a dor, mas LER O LIVRO.
#
# 2. O QUE É (definição técnica Senior)
# PAM Logging: Pluggable Authentication Modules direcionam os registros de sessões
# locais e remotas para o Syslog. No Debian habitam em `/var/log/auth.log` e no RHEL
# habitam em `/var/log/secure`. Serviços modernos usam o Systemd/Journald, 
# cujo log é binário em disco e consultado via `journalctl`.
# Na rotina Blue Team, filtramos regex e strings clássicas (Accepted, Failed, Invalid user).
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo Sênior: Script Rápido pra Extrair "Sucessos após Falhas" (Pattern)
echo "[+] Caçando IPs com 'Failed passwords' excessivas no auth.log..."

# Pegar Top IPs ofensores de falhas em Debian
# zgrep ou grep pq logs podem estar zipados "auth.log.1.gz" na rotação de sysadmin.
# Expressoes em Pipeline: ACHAMOS "Failed Pwd". EXTRAIMOS os ips usando grep E regex.
# O sort | uniq -c os conta e agrupa por volume!
# sudo grep "Failed password" /var/log/auth.log | grep -aEo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq -c | sort -nr | head -n 10

echo -e "\n[+] Listando Logins SUCEDIDOS recentemente pro SSH:"
# sudo grep "Accepted password\|Accepted publickey" /var/log/auth.log 

# Utilizando a Ferramenta Systemd moderna (Journalctl) que lê binários unificados nativos s/ cat.
# -u especifica a unit de servico. -f é o follow (live tail streaming!)
echo -e "\n[+] Assistindo Live Logins via JournalCtl_SSH..."
# sudo journalctl -u sshd -f

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Você é o Analista SOC. Tem suspeita de invasão no SRV01.
# Passo 2: Roda o primeiro comando e descobre que o IP 172.16.5.21 errou 3.000 senhas de ontem pra hj. (O cara rodou Hydra lá do kali dele!).
# Passo 3: Mas "tentar" não é crime consumado. Crime consumado é entrar.
# Passo 4: Você pega esse mesmo IP Ofensor, e faz a busca reversa de SUCESSO. `sudo grep "Accepted" /var/log/auth.log | grep 172.16.5.21`.
# Passo 5: A tela cospe: `Mar 23 10:45:01 SVR01 sshd[123]: Accepted password for root from 172.16.5.21`.
# Passo 6: SOC Red Alert! O cara acertou as 10:45! Vc deve puxar o plug da internet e isolar a máquina!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Problema: Seus arquivos de auth.log e syslog estão de repente com "0 bytes" tamanho VAZIO total hoje.
# Solução: Hackers experientes usando privesc na aula passada usaram bash command `echo "" > /var/log/auth.log` apagando evidências (Timestomp). A infraestrutura NUNCA pode ter Logs locais como unica fonte da verdade corporativa. O Syslog DEVE mandar uma COPIA imutável na mesma hora pela porta UDP 514 (Rsyslog Remoto) pra uma máquina trancada em cofre S3 q o hacker n alcança, chamado Centralized Splunk / SIEM Log Server. O log local morreu, o remoto ta lá preservadinho acusando qm apagou.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro fail2ban ler logs de /var/log/auth. O Sênior não fica reagindo e dando grep manualmente. Nós integramos uma engine de heurística Fail2Ban ou CrowdSec. Quando o `auth.log` acusa 5 strings de "Failed password" de 1 IP, o daemon do Fail2ban dinamicamente e injeta DROP regra na tabela RAW do IPtables do Linux, cortando o atacante no cabo sem ele sequer terminar a Hydra de porta, banindo-o da subnet!. A defesa ATIVA baseada em parser de log.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Estou lendo o tail do /var/log/auth.log ao vivo e meu colega loga de SSH certo pra testar no escritório. Aparece uma linha e logo dpois de 2 milisegundos aparece uma segunda mensagem muito sombria: `session opened for user root by (uid=0)`. E então ele logou. Que operação maluca de troca de contas q cria 'Sessao aberta pro root, PELO root uid 0' aconteceu se meu IP é limpo?"
# Resposta Esperada: Nenhum hacker bizarro. É a famosa operação do PAM processando 'cron_tabs' agendados como root a cada minuto, OU mais comumente, é o Sysadmin que entrou num usuário normal 'joao' e digitou `su -` (switch user). O auth log registra q joao pediu auth root. Mas logo apos o bash do root invocado engole os profiles /root/.bashrc aciona sessoes TTY filhas derivadas e plota o tracking process q root spawn root. É comportamente legitimo q assusta junior.
