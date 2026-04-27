#!/bin/bash
# ==============================================================================
# Módulo 3: Vulnerabilidades em Serviços
# Aula 02 - HTTP/S: Diretórios Expostos e Credenciais Default
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# A página inicial de um site (O Index) é a Vitrine Bonita de uma padaria, feita 
# para o cliente. Mas se você empurrar a porta disfarçada que tem atrás do balcão, 
# vai achar os sacos de farinha, as contas a pagar no escritório e talvez a 
# mochila do gerente largada na cadeira. O Directory Brute-Forcing é um exército de 
# formigas que rapidamente empurra "todas as portas dos comodos da casa pra ver qual 
# delas não estava trancada na planta e acha os arquivos ocultos de log e senhas 
# que o dev esqueceu em .zip".
#
# 2. O QUE É (definição técnica Senior)
# A Superfície Web (80/443) concentra 80% das falhas críticas. Os vetores mais "low hanging fruits":
# 1. Directory Listing Ativo (Indexes): O Apache/Nginx expõe uma pasta tipo `/images/` sem arquivo index.php final. O browser automaticamente desenha todos os arquivos da pasta para o Hacker debulhar.
# 2. LFI (Local File Inclusion) via paineis Default desatualizados.
# 3. Forced Browsing (Fuzzing): Ferramentas como Gobuster enviam 10 mil verbos HTTP GET adivinhando Pastas Ocultas como `/admin/`, `/.git/`, ou `/backup.sql`.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

TARGET="http://127.0.0.1" 

# Ferramenta GOBUSTER -> O Mestre da Força-bruta Web.
# dir = modo diretório. -u = URL. -w = wordlist de caminhos comuns (SecLists é o deus delas).
# -t 50 = threads paralelas. -x php,txt,zip = forçar ele a buscar alem de diretorios, tb a combinacao "/admin.php" ou "/secret.txt".
echo "[+] Iniciando Fuzzing Mapeando Pastas Fantasmas HTTP..."
# gobuster dir -u $TARGET -w /usr/share/wordlists/dirb/common.txt -t 50 -x php,txt,bak

# Ferramenta NIKTO -> O scanner raiz de vulns antigas de Servidor CGI
# Nikto sabe os defaults path de milhares de Servidores IoT / Roteadores ou Apache struts velhos.
# Ele testará cgi-bins e métodos perigosos como HTTP PUT abertos.
echo "[+] Executando Nikto para falhas de Servidor e Headers..."
# nikto -h $TARGET -Tuning 123b

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: O NMAP detecta a porta 80. Abra no Firefox `http://IP`.
# Passo 2: A tela só mostra "It works! Apache". Parece inútil.
# Passo 3: Mas você roda um Dirbusting: `ffuf -w wordlist.txt -u http://IP/FUZZ` ou gobuster. 
# Passo 4: O Gobuster cospe os códigos de resposta HTTP.  `/admin (Status: 401)` (Opa, painel protegido!). E `/phpmyadmin (Status: 200)` (Aha! Painel do banco aberto e rendenderizado).
# Passo 5: Você descobre um `/config.php.bak` retornando Status 200. Download nele. O source code puro contem o hardcoded password `mysql_connect('root','senha123')`! Hackeado by information disclosure.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Um erro comum de juniores é esquecer as Flag Host (Vhosts). Se hospedar o site na AWS, acessar via `http://IP/` retornará "Erro 403" ou apache padrao. Mas, se bater `http://empresa.com.br/` (que roteia pro mesmo ip na internet real), cai na pagina sensivel. Isso é VirtualHost Routing no cabecalho HTPP. Use ffuf para brute-force de Host Headers para descobrir subdominios ocultos internamente.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um prêmio massivo que Hackers Sêniors sempre checam em infraestrutura Web moderna CI/CD: O diretório exposto `/.git/` ou `/.env`. Em stacks NodeJS e Laravel, programadores rodam `git pull` direto nos servidores live de /var/www. O Apache as vezes não bloqueia bloqueia a pastinha oculta `.git` da raiz. Nós pegmos a ferramenta `GitTool` pro website, apontamos pra lá, e ele faz o dump RESTAURANDO todo source code fonte perfeito, reescrevendo a arvore de commits toda em offline com todos os access-keys da Amazon AWS limpas que o dev meteu num log escondido em commtis de 2 meses atrás q o mundo n via na renderização, mas o histórico git guarda vivo! Um erro do Devops Layer 7 desarmou o castelo de nuvem infraestructure account inteira em 10 segundos.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu gobuster retornou 20 itens. Você achou `http://10.0.0.1/dashboard.php`. Ele te bloqueia, renderizando e cuspindo `<html>Você não é Administrador</html>` com código HTTP 200 OK. Como burlar uma validação básica sem senha por um Proxy tipo Burp Suite e virar Admin provando vulnerabilidade Bypass de Controle de Acesso?"
# Resposta Esperada: Se a autenticação foi programada porosamente por cookies e não serveless tokens, eu capturo o pacote e visualizo no header `Cookie: role=user; auth=0`. Usando o Burp/OWASP ZAP, eu forjo na malícia manualmente alterando `role=admin; auth=1` em vôo e devolvo pro servidor. O Servidor confia no cookie falso vindo do meu lado client e plota o painel completo de Dashboard como master super admin, consagrando que a falha real não é a porta 80, e sim a Session Management quebrada (Broken Access Control OWASP #1).
