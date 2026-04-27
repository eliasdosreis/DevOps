#!/bin/bash
# ==============================================================================
# Módulo 8: Ferramentas Avançadas
# Aula 01 - Auditoria Automatizada com Lynis
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Hardening de um sistema manualmente (olhar cada permissão, arquivo /etc, sudoers etc)
# é como vistoriar uma mansão de 60 cômodos com uma lanterna vendo quarto por quarto se fechou
# a janela para viajar. O Lynis é o "Robô Inspetor Predial Embutido". Você dá um Play 
# nele na sala, e em 2 minutos ele cospe o laudo de dezenas de métricas estruturadas de ISO 27000, 
# PCI-DSS e Hipaa, avisando detalhadamente qual tranca tá frouxa no teto que vc ia gastar dias pra ver.
#
# 2. O QUE É (definição técnica Senior)
# Lynis é a ferramenta líder Open Source para Auditoria de Host (Host-Based Auditing)
# Diferente de scanners de rede (Nmap), O Lynis Roda Localmente "Dentro" do 
# Sistema Operacional extraindo metadados de daemons, firewalls iptables, montagens FS 
# e gera um Score Hardening Index com warnings focados em remediação profunda real.
# Bastion Hosts e Imagens de SO padrão Corporativa (Golden Images AWS) usam automções com Lynis.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

echo "[+] Obtendo e Rodando a Inspeção Local com Módulo Grátis Lynis:"
# O Sênior Nunca usa "apt install lynis", porque a biblioteca de APT geralmente do SO 
# atrasa até 3 anos do github deles e as assinaturas de Segurança são semanais.
# Então baxamos do root upstream tarball!
# wget https://downloads.cisofy.com/lynis/lynis-3.0.8.tar.gz -O /tmp/lynis.tar.gz
# cd /tmp/ && tar -xzf lynis.tar.gz

echo "[+] Engatilhando Audit Sem Parar pra pedir Enter (Non-Interactive):"
# O -Q e --pentester flag tira a frescura e manda o output contínuro focado p hackings point of view
# cd /tmp/lynis && sudo ./lynis audit system -Q --pentester

echo "[+] Validando o Score de Segurança Gerado:"
# sudo grep "Hardening index" /var/log/lynis-report.dat

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Como root no servidor q voce quer saber se tá compliance, baixa e descompacta a pasta.
# Passo 2: Roda `./lynis audit system`.
# Passo 3: O Terminal pisca em amarelo Warnigs e Erros Vermelhos. Espere ele analisar 100 os testes.
# Passo 4: No final aparece um link e um Hardening Index = 65. (O aceitavel comercialmente é \>80).
# Passo 5: No final, ele imprime "Sugestões": Ex: "Configure a palavra pass_min_days na sua PAM." Ele Te deu de bandeja OQUE falta pra endurecer nos files de config. Você segue as sugestoes 1 por 1, roda dnovo, e ganha index 92!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Por que eu usei sudo ./lynis? Lynis pode rodar como usuário Normal sem root. Ele atua como Analista de Config "limitado". Mas MUITAS configs sensíveis do /etc/pam.d e shadow sao travativas ao scan fraco. Auditar OS profissional sempre pressupõe usar SUDO e testar a integridade real da raiz, senão 50% dos testes pulam (SKIPPED).
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior amar "lynis-report.dat". Em ambientes CI/CD com milhares de Vms, uma pipeline (devsecops ansible) atira o script do lynis logo no deploy automático de Instalação do Nginx novo da squad. Se o score report file `.dat` gerado pro Nginx sair menor q 75, O CI/CD QUEBRA E O CÓDIGO DO DEV NÃO PASSA E CORTA O DEPLOYMENT, mandado msg no Teams/Slack: "Você inseriu uma distro frágil no pool!". É uma esteira de segurança.  
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Sua prova pro time de Blue Team diz: 'Lynis apontou Warning acusando que /tmp e /var/tmp não estao montadas com flags seguras (nodev, nosuid, noexec).' OQ isso significa e como sysadmin corrige essa quebra de compliance boba mas letal q deixa RCE hackers acontecerem faceis nesses folders world-writables onde malware adora esconder binaries suid na aula passada?"
# Resposta Esperada: Essas duas pastas do sistema são 777 liberadas. E O O.S Base ubuntu monta particao sem restrição de FileSystems la. Se um hacker injetar exploits C ali e rodar ./exploit ele ganha root. PRA SANAR o finding do lynis: Editamos `/etc/fstab` local do servidor! Colocamos a tag options "nodev,nosuid,noexec" na montagem da TEMP! Com isso re-botado O KERNEL UNIX SE NEGARÁ VEEMENTEMENTE a deixar um humano digitar `./script` OU A CRIAR/executa arqvs com Bit "S" la dentro (o Kernel castra os perigos fisicamente da particao temp por options no VFS!). Fim de dor de cabeça da Tmp!
