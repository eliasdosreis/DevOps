#!/bin/bash
# ==============================================================================
# Aula 08.03: Segurança e Hardening - Auditoria E Rastreamentos Sênior (Auditd)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Um banco descobre que uma Conta de Milhares sumiu 3 da Manhã Do Domingo (Apagaram a Pasta Critica /var/banco/). E A equipe de TI JÚNIOR Tá Assustada Sem Saber Quem Foi O Estagiario Que Entrou La e Apagou Pq Todos Eles Tem Acesso SUDO CeGO!!
#
# Auditoria Não É Olhar Quem APAGOU no Log Cego Da Pagina Cega (Isso é Impossivel O Linux não Anota Tudo Automatico Na Unha e Apaga!).
# A "Auditoria de Câmera De TETO Do Escritório Que Grava O Teclado". É Ter Uma Mente Blindada Do Sistema Audit.d ou History Append Only Cego Pra Cuidar Das Retençoes Legais (Compliance Militar Data ISO 27001 PCI). 
# Com a Câmera Auditora, Eu Consigo Afirmar Que "IP x Logou" e A Câmera AuditD Conta que O Arquivo `/var/banco` Foi Deletado Pelo Usuario Id 1003 do Elias! E Demitimos A Causa!

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Accounting Facilities (SysAccounting E Auditd).
# Last/Wtmp (System Accounting Local Cego C-Ring Database): Arquivo Binário Furtivo que Retém OS Sockets Logins Entrants TCP do Pc Históricos pra analises Cegas Forensics (Tty Ports).
# Daemom `auditd` FHS: Componente Kernal De Sub-Layer MAC Syscall Rules. Se você configurar Ele Pra Ler Um Evento Cego De C++ E.g. "Monitora A SysCall Posa 'unlink' Neste Diretorio" O Kernel Captura Na CPU a Influxa do Byte Execucional Cego e Lança Cego O Relatório Infálivel De Origem UID TTY PID Pro Disco Indestrutível Sem Cachear Memoria! O Auditor Imune À Hackers Users Cego SUDO Do Ring 0.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# O Diário Mínimo de Entradas Cegas Furtivas (O Famosoz 'Quem Logou As 3 Da Madruga')
last                        # OBRIGATÓRIO (Lê O Banco Cego Binário `/var/log/wtmp` E Descreve Cego A Lista Histórica Inteira de Usuarios Ips SSH Cego De Logins e Se Os Cego Saíram Cego ou Estão Vivo Aqui No Kernel Cego!).
lastlog                     # Mostra A Data Múltipla Da ULLLTTTIIIIIMMMAAA Vez Cega Que Todo Humano Cego Fhs Logou No Pc (Ex: O Estag Saiu Faz 2 Dias Cego Da Vida Da Maquina).

# AS REGRAS DO DETETIVE FEDERAL C/ AUDITD (Você precisa instalar `sudo apt install auditd`).
# Instalou Ele?? O Diretor Ordenou: "Eu Quero Saber QUALQUER CARA CEGO DA EMPRESA COM SUDO MAGICO QUE TENTAR EDITAR O ARQUIVO /ETC/SHADOW Cego FISCAL CEGO HOJE DA MAQUINA BASE CEGA!".

auditctl -w /etc/shadow -p mwa -k espionad_senhas    # REGRA INFALÍVEL SÊNIOR! (A Câmera foi Acoplada!!!)
# O Que Ela Faz Cega?
# -w (Watch Fhs Arch). -p (Permissions Acionadoras: m=Mudança Atribs Chmod, w=Write No Ceo Texto Cego, a=Append Nova Linha Cega File) -k (A Key Etiqueta De Referência Cega Na Busca Cega De Logs Depois "espionad_senhas").

# FUI PROCURAR O BANDIDO CEGO QUEN ALTEROU NOS LOGS DA CAMÊRA (Auséarch Tool Físicas Da Ram)
ausearch -k espionad_senhas # VOMITARÁ EM TEXTO COMPLETO Cego Exclusivo: As TTYs Originais Pids O "UID 1002" Que Fez O Edit Do Arquivo Hoje Do Watcher Do Kernel Base Limpo Da Memória Execucional De Chamadas Cpu! A Demissão Acontece!

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] aureport --tty
# [O QUE FAZ] Ele Lê Cego Todo O Diário Físico Extenso E Gera UM EXTRATO FINANCEIRO De Relatório Clean (Summary Cego)  Com Todos Teclados Inputs Registrados (Keylogger Oculto Auditado e Autorizado Pelo Kernel Base FhS Militar Da Maquina Numa Vistoria Interna ISO2701 CEGA). Cego, Suave Legalmente Usando SysCall Keys Kernel Tty Ring Buffs Das Camadas PTY.

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - FUI AUDITAR UM DEVS Cego. ABRI O HISTÓRICO DELE (`cat /home/junior/.bash_history`).
#   MAS O ARQUIVO HISTORY ESTAVA LIMPÍSSIMO, E ELE SABE CEGO QUE ELE TAVA LÀ E ESCREVEU O RM DELETAR CEGO BANCO! 
#   Como o Dev Filho da Egua Fez isso Cego?
#
# A Maior Piada Dos Arquivos De ".bash_history" Do Gnu (E do PQ Não Se Confia Pra Forense Neles).
# Os Comandos Q Você Digita, Ficão Retidos Na RAM Memory Cache Da Tela Putty Fhs. QUANDO VOCÊ SAI (Sair Dando Exit Clean), Eles CAEM PRO DISCO Salvando O Log.
# Mas Se O Jr Hacker Infiltrado... Digitar Um Espaço ' ' ANTES Dos Comandos. OU Mandar A Variavel Oculta `unset HISTFILE` Ou Dar Um EXIT Abrupto Fechando a Janela NO C-X (Fechou Terminal). As Linhas Frias DA RAM CEGA CEGA MORREM. EVAPORAM SEM PREENCHER O HD CEGO HISTORY!! Por isso History Não Prende Hacker Expert CEGO, O Auditor Sênior USA AUDITD Do Syscalls Que Dispara Em Event Time Ao Lado Arquivo Salvo Pela Rede Cega Local!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Mutabilidade dos Logs e Syslog Remote Sênior Blindado
# Todo Hacker Que Hackea Uma Servidora E Invadi A Maquina Dele Primeiro Passo: Limpar Os Rastros e Logs ("/var/log/auth.log` -> Delete Cego!!"). E Você O Sysadmin Acha Que Ninguém Entrou Porque a Lista Sumiu!! E Nao descobre NUNCA O IP Cego Dele Pq o Arquivo Txt Das Conexoes Se Foi Pra Sempre Em 1 RM-RF.
# 
# ESTRATÉGIA MESTRE NUVEM BLINDADA (REMOTE SYSLOG MUTE FHS UDP)
# O SysAdmin Configura O "RSYSLOG.CONF", Pra "Todas Mensagems De Entradas Ceo Auths E Erros Críticos Kernels" Serem MANDADAS SIMULTANEAMENTE NUMA PORTA Rede UDP Pelo Cabo De Tras Direto Pela DMZ Pra UM SERVIDOR CEGO DE 'LOGS_CENTRALS DA AMAZON 11.0 C/ DISCOS INALTERÁVEIS READONLY (WORM). 
# Assim Que O Hacker Entra Na Maquina Do Site e Executa Um `Su Cego`, A VAGA Informação (Su FAILED IP XXX) JA FOI POSTADA NO AR E GUARDADA NUM S3 BUCKET DISTANTE INVIOLÁVEL DA EMPRESA. Se ele Apagar O "Auth.log" LOCAL, ELE VAI PASSAR VAI FALTAR E RIR DA SUA CARA.. Mas Vc Da Cadeira Central Cega JA TEM O IP, E O TIPO DE DROP DROP DE LOG QUE ELE CAUSOU SEM DELETAR Da Nuvem Auditora Distante Forensics! Cego!!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa Auditar A Rotação Permanente E A Criação Local Dinâmica de Logins TTY FHS 'Login Status Wtmp Files' Com Last No Servidor Red Hat Do DataCenter Antigo Offline Que Teve Picos Acabou Espaço Cego De Particao Cega De Vars Em /Var Cego Hoje Com Disco Morto Fhs Mas Cujo Files Historicos CeGo Log Foram Arquivados Deletados Antigos Pra /BKP/Antigos/wtmp.velho1 De Ontem Devido a Corrupção Da Placa Controladora Storage Array Cega Lotações Inesperadas Arquivo .bz Cego FhS Limit Malloc Erro Cego. Como Usa A CLI Cega Pra Ler Esse Caderno Arquivístico Salvo CEGO Do Ultimo Mês Descompilando O Cpio/Bz Sem Corrompe-lo Pra Ver Quem Sumiu O Storage Logs Daquella Madrugada Cega De SRE Audit Cego?"
#
# Resposta Esperada: "O Binário do Relógio Accounting Local `last` Possui A Diretiva Parametrizada de Arquitetura Passiva File Reader Exata Pra Evidências Mortas `-f` FileTarget Cego. Em vez de ler 'O C-Lib Malloc Padrão do Caminho Absoluto Default Base', Informaríamos explicitamente Para Engine Descopilar A Base Suja Relocada Exata Na Raiz Offline De Backup Pra Descobir Logins De Operacoes Anuais Mortas Com 'last -f /BKP/Antigos/wtmp.velho1'. Podendo Assim Visualizar O Rastro TTY Extrato E UIDs Furtivos Passados Cego Preservado E Extraídos Sem Travar A Ram Cega E C-Syscalls Local Ext4 Cego Nativas Mapeadoras Do Sysadmin Mestre Forense Isolado Cego Cego Base Cego."
