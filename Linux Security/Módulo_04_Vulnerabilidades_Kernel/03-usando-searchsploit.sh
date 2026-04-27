#!/bin/bash
# ==============================================================================
# Módulo 4: Vulnerabilidades de Kernel
# Aula 03 - Usando o Searchsploit (O Exploit-DB Local)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você comprou uma Fechadura Magnética Smart da marca "XingLing 8000" para sua empresa.
# E a porta principal travou misteriosamente sem você ver, tem alguém la. 
# Como você não é um criador mundial de chaves mestras e não quer inventar a roda (Desenvolver seu exploit), 
# você vai na "Livraria Master de Chaves Clonadas de Ladrões Mundias" (A Exploit-DB) e busca:
# - Me dá o truque para a 'Fechadura XingLing 8000 V2.0'.
# E a livraria te dá o `.pdf` ou código em arame pronto de como bater embaixo dela.
#
# 2. O QUE É (definição técnica Senior)
# Searchsploit é um cliente CLI super rápido de comando no Kali/Parrot que embute
# o banco de dados OFFLINE do Exploit-Database.com (da Offensive Security).
# Ele provê Provas de Conceito (PoCs) históricas ou recentes, injetores em python e .C
# cobrindo Remote Code Executions, Denials of Services, privescs para qualquer software/sistema.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo/Ofensivo: Procura e Cópia Automática da Internet.
# Instalando nas distribuições com apt, se não tiver: `sudo apt install exploitdb` 

echo "[+] Buscando o termo 'Linux Kernel 2.6 Ubuntu' Localmente no BD SearchSploit..."
# Searchsploit faz um GREP case-insensitive por strings das palavras chaves no banco CSV offline dele.
# searchsploit linux kernel 2.6 ubuntu

# Após achar o ID do codigo do exploit que atende tua build, copiamos pro dir atual!
# digamos que o id achador for '37292.c'
echo -e "\n[+] Baixando/Copiando a chave Mestra pro meu HD p/ análise..."
# searchsploit -m 37292 
# o m de Mrror manda ele copiar o .c cru pra pasta ~/ do seu linux. Vai criar ./37292.c !


# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Digamos q no NMAP vc viu a porta "Vsftpd 2.3.4".
# Passo 2: No terminal do Seu pc, digita: `searchsploit vsftpd 2.3.4`
# Passo 3: O output devolve: "vsftpd 2.3.4 - Backdoor Command Execution  | unix/remote/17491.rb"
# Passo 4: O `.rb` significa q o exploit está implementado para a engine do Metasploit Ruby Framework. Mas e se tiver uma `.py` python Pura? Melhor. Você dá o `searchsploit -m 17491`.
# Passo 5: Inspecione o Código Sempre: `cat 17491.rb`.
# Passo 6: Descubra que o dev q fez essa versao backdoorada injetou que quem der o user ftp com um "Smiley Face" (`USER back:)`) ganha root na shell port 6200! Exploit pronto, a sua vida virou um copy e paste pro servidor.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando a busca do searchSploit retorna milhoes de strings poluidas de Linux de varias coisas, nós usamos os regex flags como o `-t` pra Forçar Puxar somente O Titulo Do Exploit e não as paths completas contendo strings parecidas espalhadas, e usamos o `-w` pra dar o link do site se estiver online pra dar paste no navegador se quizermos! `searchsploit -t apache struts 2.5 -w`. Elem disso mantenha-o atualizado com `searchsploit -u`. O bd ganha cve nova todo os dias!
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# "Por que o Sênior não pega código Python/C do SearchSploit e dá Enter contra a vida do BD do Alvo do cliente direto?" -> Backed-in Trolls e IP Catcheres.
# Exploits Públicos, não raramente são criados por Pesquisadores ou Black Hats q embeddam um pequeno hook IP do DELES LÁ. "Ah, se um Script Kiddie de 14 anos rodar esse meu exploit .py que eu botei de graça na public area, além dele atacar a empresa, a shell de root reverte metade pra ELE, e a outra tela devolve O IP PRA MIM lá pra Romênia". Pior, exploit em C tem offset hardcoded e um `-o ` que deleta o banco de dados inteiro porque o cara tava com raiva de MS SQL na hora de escrever. Sênior AUDITA todas as 300 linhas de C e Python com um olho do falcão procurando maliciouness ou caminhos de destrutos, muda as IPs, reescreve portas nos buffers em HEX com objdump e SÓ ENTÃO lança na rede de clientes. Executar código "grátis" do Searchsploit sem ler é Crime Corporativo na Cibersegurança Auditiva!
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu alvo tem serviço interno HTTP 'CMS Made Simple 2.2.10', você manda pro searchsploit e acha um CVE Sql Injection Automático Pyton nele foda demais pra pegar a adm-password. Você edita, joga o Target IP e Tenta rodar pela CLI de Kali Linux. Mas o console python atira: `ModuleNotFoundError: No module named 'requests' or Termcolor` Ou pior, é python 2.7 mas tu rodou e crachou erro `print syntax`. Como q Sysadmin safa dessa salada velha pra prosseguir a chain attack no CTF sem corromper o teu host limpo?"
# Resposta Esperada: O Exploit-DB acumula arquivos de 2004 até hoje. Ferramentas legadas em Python2 ou dependencias antigas poluem o Python3 seu host (o 'pip' hoje pode até bugar se a versao q roda na ferramenta exige a lib "urllib2" extinta). Nesses casos, a saida senior rápida de um guerreiro de laboratório usa ferramentas do isolamento: Crie um `Virtual Environment no Python venv (--python=python2.7)` restrito onde vc soca as pip installs velhas tipo requests 2.11 e executa só pra aquele tiro, ou usa ferramentas containers limpos do docker do kalinux "docker run -it python:2.7 bash" roda a poc por lá no descartável. E não perde o tracking original .
