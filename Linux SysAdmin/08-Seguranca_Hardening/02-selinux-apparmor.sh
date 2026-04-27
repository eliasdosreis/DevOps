#!/bin/bash
# ==============================================================================
# Aula 08.02: Segurança e Hardening - A Prisão do MAC (SELinux e AppArmor)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# "Por que o Sênior do Redhat tem SELINUX se o FHS Root Permissoes ja é Forte 'Chmod'?"
# 
# Pense BEM Na Teoria Do Júnio Cego. O Hackers Cego Quebraram O Seu Nginx (Servidor Do Site Web Apache Porta 80). 
# O Processo 'Nginx' Roda No Seu CPU Sob o Dono de Privilégios Mestre "ROOT". 
# O Hacker Executa Um Script Dentro Do Nginx Cego Que Aciona A Ferramenta Bash Local De Linux Que diz:
# "Apague A Pasta De Documentos Da Recepção Inteira (/var/documentos)!". E Como Ele Controla O Mestre Root (Porque Quebrou a Escada Nginx). A Permissão Padrão DAC (Discretionary) DO UBUNTU DIZ: "Amém Senhor Dono Cego. VOU APAGAR!!" 
# 
# DESTRUIÇÃO TOTAL. O Ubuntu é Bonzinho com os Filhos e Deuses Dele.
#
# SELINUX (Agencia De Segurança Nacional) = Controle OBRIGATÓRIO (MAC).
# Ele Coloca Uma ETIQUETA INVISIVEL NO NGINX: 'httpd_t'.
# Ele Fala Em Suas REGRAS ESCRITAS MAC: "Você NGNIX Só e SOMENTE SÓ, Tem DEUS Cego Direitos ABSOLUTOS de Ler AS Pastas com a etiqueta 'httpd_sys_content_t' E MAJS NADA.".
# AI O Hacker No Servidor REDHAT Pede Pra O Deus NgNIX Dele Apagar A pasta Recepção...
# O SELINUX VEM E DÁ O TAPA DA MORTE A NIVEL DE KERNEL SYSTEM CALL MENTAL: "OPA! ACESSO NEGADO!! O Programa Da Web De Deus NUNCA Teve a MINHA ETIQUETA DE FHS PRA TOcar Aqui!! EU NÃO LIGO ASSUMO QUE Mande De Deus (Root)!". E Seu Site É INVADIDO MAS A MÁQUINA Cego SOBREVIVE Intacta Inpenetrálve! MAGNIFICO!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# MAC (Mandatory Access Control). Implementação Criptográfica Inicial da NSA Cego Em cima
# do LSM (Linux Sec Modules Kernel). 
# Os Administradores Rotulam Contextos Booleanos e Types Nos C-Arch de Sistema. Redefinese
# o Perímetro de "Quem e Qual PIDs (Processos) Faz o quê Ao Alvo". O SELinux Encontra-se
# Em Ambientes Severos RHEL/CentOs/Alma. E O 'AppArmor' Sua Versão Mastigada No Mundo Debian/Ubuntu Base Profile.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root (Sudo). Num servidor CentOS/Fedora/Rocky/AlmaLinux.

# Qual A Posição Do Seu Prédio Militar Hoje Cego?
sestatus                                 # OBRIGATÓRIO (State: Enforcing(Multando O Pessoal Cego)/ Permissive(Alarme Cego Visual, Mas Não Multa)/ Disabled(JÚNIOR MORTALMENTE EXPULSO)).

# MUDANDO AS ETIQUETAS DO DISCO MAGICO (Context):
# O Júnior copiou o Site de Backup Em "/tmp/" Local Cego pra dentro da pasta do Apache "/var/www/html" e O SITE DEU ACESSO PROIBIDO Cego MAS AS PERMISSÕES DE CHMOD TAVAM LISAS!! (O SELINUX BARROU, POIS O ARQUIVO CARREGAVA A ETIQUETA HERDADA CEGA DE '/TMP_T CEGO'!)
# Restaure As Etiquetas Do Padrão Web Site Daquele Caminho FHS De Deus:
restorecon -Rv /var/www/html             # A MAGIA PURA DO SENIOR (Restore O Contexto Da Default Base Local de Recursividade!! SITE VOLTA VIVO!).

# ===== UBUNTU APPARMOR==================
# Pra quem ta No Ubuntu/Debian O Negócio é o APPARMOR:
# Quais Prisoes Isoladas Esse Pc Tá Usando?
aa-status                                # OBRIGATÓRIO. "24 profiles are in enforce mode". Os Binários Cego Blindados Na Via Fhs. (Ex: O Cupsd E Mysql Confinados na Cage dEle).

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] setenforce 0
# [O QUE FAZ] ATENÇÃO NO CHORO DE SANGUE Cego: O Servidor Redhat Bugou Tudo. O Docker Não Comunica Rede FHS Cego! O Banco MYSQL Caiu! E Nada Explica Cego Nos Logs Limpos. Sênior Roda "SetEnforce 0" E DESLIGA O SELINUX PRA STATE DE ALARMBRO PERMISSIVE (SÓ OBSERVAÇÃO) DA RAM IMEDIATAMENTE!!
# Se As Coisas Ligarem Com "SetEnfoce 0" Significa Q O PROBLEMA NÃO ERA PERMISSOES FHS DE LINUX!! MAS SIM ERRO DE ETIQUETAS E PORTAS ROTULADAS DO AGENTE DA NSA (Selinux Cego) BARRANDO TUDO. (Use MODO PERMISSIVO Cego Só "P/ Testes De Bug Fix Cego Diagnóstico" Nunca Cego Prod Final).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - "MUDEI O SELINUX PRA 'DISABLED' NO /etc/selinux/config !! E A MAQUINA NAO SUBIU O BOOT!!"
# O Erro Extremo Da Decada Cega.
# 
# Pular de Enabled Pra Disabled E Rebootar o PC Num REDHAT Cego FAZ As Etiquetas Herdadas Virarem POEIRA NA CABEÇA DO KERNEL EM FHS. 
# Quando Você se Arrepender De Cego... E Tentar LIGAR De Volta e Der "Enforcing e REBOOT" DE NOVO.. ELA VAI CRAXHAAR NA TELA PRETA DO GRUB. 
# Porque Ele Terá FHS System E Libs Fiscais SEM ROTULOS CEGOS DE SEGURANÇA FISICOS. O BOOT NAO SABE QUEM É QUEM Cego E CANCELA O Init Dando Panic Cego Fatal Em Boot. 
#
# (Se Vc Fez Isso Em Desespero.. Crie Um Arquivo Abençoado `touch /.autorelabel` Na Root Da MAquina E Reinicie O S.O. E Aguarde HORAS Enquanto O PC Relé E Carimba Cada Dedo De Seus 40GB HD Novamente!)

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# "Booleanos Da Vóvó Selinux".
# Você Quer Que O Seu Apache Gringo (httpd) Consiga Conectar Pela REDE CEGA No BANCO DE DADOS EXTERNO MYSQL (10.0.0.8 Cego Da Lan!). 
# Você Faz O Teste Do Apache Conectar Num App E DA FALLHA! ERROR CONECTION. Você Puxa Os Cabelos. 
# Motivo Cego Sênior: Os Booleanos Do Cego.
# O Selinux Tem Chavezinhas Lógicas Na RAM De Segurança Nacional. Um Servidor HTTP CEGO (Na Regra Booleana Dele) DEVE SER BURRO E LER HTML! ELE NÃO DEVE ESCRAPAR ARQVOS Da REDE TCP! ELE SÓ VOA.
# Sênior Ativa Ou Desliga Chaves Mágicas pra Permitir Milagres de Funcionalidades Nas Regras Duras Dele E Redefinir "Network Allowances Cego":
# `setsebool -P httpd_can_network_connect 1` (-P = Permanente Magica Fhs).
# Feito isso.. O Seu Site Wordpress Cego VOLTOU A FALAR E A CONECTAR NO BANCO TCP NAS ESCURAS DA NOITE. E O Sysdmin Pode Dormir!.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você é O Auditor Físico E Recebeu Ordem Da Infra Redhat Da Filial Europa Pra Validar Se Existe Algum 'Avc Denial' (Alarme De Acesso Negado Silencioso Escondido E Suprimido Pelo SELinux Em Máquinas Da Matriz C/ Base Nginx E DBs Corporativos Ocultos Causando Travamentos Ocultos FhS Longe De Nossos Zabbix Sem Desativar A Guarda Do C-SysCall Cego Nivel 3. Em Qual Local O Profissional Consultaria The Logs De Negação Base Da Abstração FHS Pra Mapear Exatamente A Interface MAC Denied Cego?"
#
# Resposta Esperada: "Leriamos e Consultaríamos Exclusivamente O Ficheiro de Log Audit Cego Da Suíte de Segurança em `/var/log/audit/audit.log` (Via Ferramentas Da Raíz Como Aureport ou Ausearch Mais Limpas). O SELinux Loga todas Punições AVC ('Access Vector Cache Denials') Exclusivamente ali Denotando Detalhes Cruciais Como PID Dono, Etiqueta SContext De Origem, E O TContext Target Da Pastas Q O Software Tentou Ler Inutilmente Barrocando O File De Erro Das Aplicações CEGOS Inativos Cego (Permission Denied FHS Falso)."
