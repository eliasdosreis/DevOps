# Módulo 9: Projeto Final Senior
## Aula 04 - O Checklist Sênior e o Fim da Jornada (Cheat Sheet)

Guarde essas linhas num post-it, na mesa do seu escritório SOC, ou na wiki da corporação que você proteja. Isso não é um PDF de internet; é o sangue acumulado das centenas de invasões nos módulos descritos neste curso para sua mesa corporativa de Hardening Linux Server.

### ✅ Nível 1: Higiene da Superfície e Camada Física VFS
- [ ] Partições Sensíveis(`/tmp`, `/var`): Configurar Montagem do Ext4 em `/etc/fstab` com flags de imobilização de script (`nodev`, `nosuid`, `noexec`), inibindo Criação de Privesc Shell exploits nelas.
- [ ] SUID/SGID Scan Audit Diário: O CRON Root acorda 2am e Roda Script varrendo em `find / -perm -u=s` e checando na API com diff se há "Novo Arquivo q não tava listado com FLAG vermelha" e atira Teams/Slack.
- [ ] SSH Bastião Sudoers: Log remoto permitido APENAS por Keys Cryptográficas RSA/ED25519; `PermitRootLogin` rigidamente restrito à 'no'; Disable `UsePAM` unless 2FA config está deployado!

### ✅ Nível 2: Escudo de Privilégios Mestre em Sistema e Processos.
- [ ] O famigerado ALL=ALL no Admin `visudo`: JAMAIS usar curingas regex `*` nem liberar binários Pagings interativas interativas (`vi`, `less`, `more`, `awk`, `find`, `nmap`).
- [ ] Serviços de Api Web / Banco Docker Containers Bootados pela Stack Systemd com Tags de Jaula e Castração do Daemon:
  - Definir explicitamente `User=www-data` no bloco de Service config nativo.
  - Abençoar app com `NoNewPrivileges=true` e `ProtectHome=yes` e `ProtectSystem=full` na config root de Systemd. 
  - Cap_Net_bind_Services no binario local isolado do container caso a app insista portas.
- [ ] SELinux Enforcement State ativo e logado centralizadamente para hooks syscall via File/Name Context. 

### ✅ Nível 3: Egress Routing e Network Tracing
- [ ] Os pacotes Nativos de Mapeadores NFS `rpcbind` e Compartilhadores default de Samba devem ser Desativados de Systemctl no host (`systemctl disable rpcbind`) se Não estão sendo utilmente usados em rede da LAN corporativa Interna pra evitar Enumeração UDP 111 de Zero-day ou Brute-Force da DMZ.
- [ ] Egress FireWalling IPS: TUDO q Sai Do sistema pra Fora deve nascer no DROP POLICY; e o firewall de host librtar apenas TCP ports SANTAS DE API `443` de requests essenciais AWS pro Microservico funcionar, quebrando reverse shells diretas em tcp 9001 e bash tcp pings do ncat do Módulo 0! 

### ✅ Nível 4: A Prova dos Forensics Sábios SIEM
- [ ] Logs Imutáveis: TODO o trafego de sys_call de Execucoes `/var/log/audit/auditd.log` e do Porteiro `sshd/Journaldauth` não podem parar Em HD de SSD de 20GB local da Box que foi Invadida e apgaada via TTY spoof; A Box jorra e espelha em Rsyslog TCP TLS encriptado para um Balde Cofre (S3 ou Splunk) onde A conta AWS q roda a EC2 n tem IAM Write Acess no bucket da sec-team. Time de App n apaga log do SIEM. Time de Red n manipula mtimes remotas !

---

# 🚀 VOCÊ CHEGOU LÁ! 
Se você entende as linhas de cada checkpoint deste `Módulo 9`, por que os SUIDs fode o sistema no Módulo 5, e a maneira de interceptar os exploits com Systemctld do modulo 7.. Você tem o conhecimento base pra argumentar nos painéis e desenhar redes pra Bancos e Fintechs. **Bateu no teto de Analista Segurança Pleno e rompeu as muralhas do Sênior Defesivo/Ofensivo.** Use e abuse da Virtual Box com calma até que vire músculo natural da cabeça.

**The Matrix is Yours. Keep Hunting ! 🎩🛡️**
