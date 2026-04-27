# Módulo 7: Hardening e Remediação
## Aula 03 - AppArmor e SELinux (Mandatory Access Control)

### 1. ANALOGIA DO DIA A DIA
Se o sistema `rwx` (Permissões de Usuário UGO comuns) é um "Juiz Baseado em Pessoas" (ex: Pablo pode entrar na Sala X, Joana Nao), o Mac (SELinux / AppArmor) é o "Juiz Baseado em Regras e Profissão Imutáveis". 
Se o Pablo tem a permissão de "Limpar com a faca" lá no FileSystem comum, tá tudo ok. MAAAAS... E se o Pablo enlouquecer e tentar usar TUA FACA pra "Cortar Papel no Escitório da Sala Z" ?
O MAC System diz: **CALA BOCA**. Não me importa se quem invadiu ou mandou era Root ou Pablo com bit especial.  A REGRA DIZ QUE 'Faca de açougueiro' NO MODO TRABALHO APENAS PERMITE AÇÃO 'CORTAR CARNE' NO 'FRIGORIFICO'. Ponto final!!.
Se tentar Cortar Papel no RH, o Sistema Operacional trava o braço dele. A política de Controle de Acesso Mandatório foca no *Comportamento do Binário e no Objeto* e quem rege é Deus (Perfil/Labels), nem Deus Root burla a label, salvando empresas de Exploits Zero-Day de Web Servers q viram root do nada e tentam roubar db .

### 2. O QUE É (definição técnica Senior)
Os MAC (Mandatory Access Control) são módulos de segurança integrados nativos ao Kernel do Linux via hooks da LSM (Linux Security Modules API). Eles agem *Depois* da verificação discricionária normal rwx. Se o rwx do host permitir, a LSM intervem por segundo, se a label LSM for Reject, o kernel da kernel-drop na action.
- **AppArmor:** Abordagem de MAC por "Name-Based/Path-Based". (Canonical / Ubuntu base). Facílimo de configurar e usa Cammnhos Absolutos `/usr/bin/nginx` pra definir profiles do que ele poee ler de rede, bindar TCP e files rw.
- **SELinux (Security-Enhanced Linux):** Criado pela NSA; Abordagem MAC por Label/Context-Based. Extremamente poderoso e complexo (RHEL / CentOS). Utiliza tags "unconfined_u:object_r:httpd_sys_content_t:s0". Se você puser um arquivo de Web root mas n possuir o Contexto Label de tipo `http_sys_content` de web cravado nos inodos dele metada, o Apache NUNCA VAI LER MESMO SE TIVER 777 DE RWX NO DISCO FÍSICO DA PASTA!! É MÁGICA.

### 3. SCRIPT / COMANDO COMENTADO
Como é configuração em texto paramétrico de regras, segue a base do sysadmin de segurança:

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Demonstra os cheks basicos de quem usa SELinux (RHEL) e AppArmor (Debian/Ubuntu)
# e como forçar o AppArmor de Complain pra Enforce de perfis 100% blindados de apps!
# ============================================================

#!/bin/bash

# ============= Checando o Status Global LSM =============
echo "Tô de escudo nativo? Vendo AppArmor:"
sudo aa-status
# No rhel ver selinux é: getenforce 

# O AppArmor possui Profiles das Aplicações (Nginx, Mysql). Eles ficam em `/etc/apparmor.d/`
# Quando estao em 'Complain Mode', ele avisa no Log, Mas DEIXA o hacker agir (Testing/Homologação p n quebrar app default da empresa). 

# Como Ativar a Restricao ABSOLUTA da ApparMar Enforce:
# sudo aa-enforce /etc/apparmor.d/usr.sbin.nginx

# ============ Gerando Perfil Custom Automagico =============
# Vc programou uma API web super perigosa em Python q nao conheciamos? E n sabemos q file vc mexe?! 
# Nos botamos o sistema Aprendedor (Gen) Profile tool de observação q gravará q arquivos a api toca em 1 hr d uso e gerará as rules bloqueantes seguras baseadas nisso!!!
echo "Executando o motor Gen de app... "
# sudo aa-logprof 
```

### 4. PASSO A PASSO
**Passo 1 (Exemplo SELinux de Dores):** O Admin instala Nginx do RedHat dnovo. O arquivo de configuração web dele `/var/www/html/index.php` ta lá. Ele loga na web 80 "403 Forbidden".
**Passo 2:** Ele checa chmod `777`. Tenta dnovo, 403!! E se desespera.
**Passo 3:** O Admin de Respeito Sênior, digite `ls -Z /var/www/html/index.php` (A flag -Z checa contextos de LSM labels). A saída: `-rwxrwxrwx root root unconfined_u:object_r:user_tmp_t`. Aaaaha!! 
**Passo 4:** O arquivo copiou erradamente a label de `usuario_tmp_t` de ser baixado temp. O WebServer HTTPD só foi ensinado pela NSA a permlir leitura de labels chamadas httpd_t.
**Passo 5:** O SysAdmin Roda Comando Mágico: `setenforce 0` (Bypass desligando a segurança inteira pra ver se funciona -> e funciona e vaza banco - NUNCA FAÇA ISSO Sêniormente em PROD kk). A Solução Correta é restaurar o contexto base: `restorecon -Rv /var/www/` e o selinux religa permitinho a liberação e restrição nativa.

### 5. VERIFICAÇÃO E TROUBLESHOOTING
O comando `dmesg -T | grep -i apparmor` (ou grep -i AVC pro selinux access vectors) revela AS PROVAS da ação do Escudo bloqueando! Se voce vê no log "apparmor DENIED mmap of libc.so... request_mask=x for perfil Nginx", Significa LITERALMENTE que NGINX (Insalubre na mão de um Hacker após RCE exploit) TENTOU dar Execução no Sistema de código livre na memória, e o Seu Perfil de Config bloqueou a chamada. O Hack morreu ali calado sem Rootar servidor.! 

### 6. CONCEITO SENIOR (o "porquê" profundo)
O Sysadmin preguiçoso na internet jura: "Selinux quebra minha app docker e apache do kubernetes, primeira config q eu ensino eh Editar `vim /etc/selinux/config` e por pra `SELINUX=disabled`". SEI QUE É CHATO CONFIGURAR CONTEXTO PRA PASTAS REDES E PORTAS EXTRAS. MAS SELINUX DESATIVADO PERMITIRÁ 0-DAYS DE SHELL REVERERSO NA MEMÓRIA E OVERFLOWS! É crime O Selinux vir ativado de fábrica do O.S. Pq é um Bastante de Camada Secundária Inviolável. Mante-lo Permissive (avisando apenas) é ok homologacao, ms disabled é desleixo e tira o Linux da compliance ISO27k bancario q obriga Mandotary Controlls accessiveis! NUNCA Disable. Configure via seause module rules! 

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Seu banco de dados PostgreSql rodando em Ubuntu está em modo Enforce do Apparmor. O hacker achou falha RCE de SQL query file injection, e sabe q vai rolar pq a porta de rede liberará reverse shell pra net atacante. Como a label do profile Apparmor vai se comportar e pq o reverse shell morre de time out sem cair no Kali Linux host Hacker se nada do Firewall Externo e Iptables droppou o tcp?"
**Resposta Esperada:** Profiles Otimizados MAC / Apparmor como do DBs restringem não apenas READ Files `r`, mas eles possuem network scope Rules! Um Postgre que está feito pra atuar internamente possui tag na config q so libera redes bind de `network inet tcp bind`. Mas para O POSTGRES CUSPir a conexao REVERSAMENTE pra uma internet, ele precisa do scope ativo tcp_connect syscall capabilitys!. O AppArmor vê uma anomalia do deamon db iniciando conexao ativa pra net e Corta a syscall connect() Kernel no berço e cospe DENIED audit access. Morte do Reverse Shell Network Based!
