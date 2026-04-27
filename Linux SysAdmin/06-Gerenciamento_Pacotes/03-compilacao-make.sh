#!/bin/bash
# ==============================================================================
# Aula 06.03: Gerenciamento de Software - A Trindade da Compilação (Source Code)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# `apt` e `dnf` é Você Ir no Mercado E Comprar O BOLO PRONTO ENLATADO! 
# (Fácil, Mas é Do Gosto Da Fábrica Debian).
#
# Se um App não tá em loja NENHUMA? Ou O Desenvolvedor Chefe da Empresa fala "Eu
# Preciso Desse NGINX Modificado C/ UM MÓDULO EXCLUSIVO BRASILEIRO QUE FIZ NO PC".
# E AGORA? VOCE VAI COMPRAR CANJIQUINHA, FARINHA E FERMENTO E VAI ASSAR 
# O SEU BOLO (`Compilar o Kernel` do Zero no FORNO/Processador!).
# O Linux Compila o Código C Puro pra Código-Binário Da SUA PRÓPRIA MÁQUINA DE METAL.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# Distribuição via Código Fonte (`.tar.gz`). Onde o programador Gringo Manda 
# centenas de arquivos brutos *.cpp e *.h
# A máquina Linux Local precisa ter o Kit De Ferramentas `gcc`, `glibc`, `make` (Development Tools) 
# pra Iniciar um Compiler.
# O Formato tradicional GNU de Compilação exige O Sagrado Tripé "Configure, Make, Make Install":
# 1. Configurar (Sondar o Hardware se aguenta).
# 2. Make (Triturar Arquivo à Arquivo no Compiler C virando Object File ELF).
# 3. Install (Joga Na arvore FHS Binários e /etc finais).

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. O Compilamento nunca é feito de Root. Só O Instale.

# Passo 1: O Pré-Requisito que A Loja Da Fabrica te negava: Seu Forno!
sudo apt install build-essential    # OBRIGATÓRIO (Debian) (No redhat é Group "Development Tools"). (Traz o sagrado compilador gcc)

# Extrai o tarball (A Gaveta Com o Lixo do Programador C gringo).
tar -xzf meu_programa_v3.tar.gz     
# ENTRA NA PASTA NOVA DE Código.
cd meu_programa_v3                  

# A SANTA TRINDADE DO SOFTWARE LIVRE NATIVO:
# O Script de Bash `./configure`. (Criado pelo GNU Autoconf gringo). 
# Ele Testará A SUA PLACA MÃE, e TUDO que ELA TEM pra adaptar o Código a SUA VIDA ÚNICA LOCAL! 
./configure                         # OBRIGATÓRIO: Sem isso, o Compiler C Falha em 2 Segundos.

# Depois Que O Config deu Verde E gerou "O Caderno Inteligente (o Arquivo Makefile)".
# O Comando `Make` Ocupa 100% Do CPU... E Cria O .EXE (Binário ELF de Linux) durante as Horas e Minutos.
make                                # OBRIGATÓRIO (É nessa hora que Servidores esquentam ao máximo o Cooler no Rack).

# O Programa Tá Pronto. Mas ta Dentro da Pasta "/Downloads/lixo" do Desenvolvedor!
# Vira Deus ROOT pra Mandar As Peças Oficiais Pras Pastas Universais FHS `/usr/local/bin` / `/etc`.
sudo make install                   # OBRIGATÓRIO: A Instalação Global para a População.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] make -j$(nproc)
# [O QUE FAZ] (Job Limit Paralelo). O 'make' sozinho é Burro: Se seu Intel Xeon tem 32 NÚCLEOS DE PROCESSADOR... 
#             O `make` BURRO VAI COMPILAR 1 POR 1 NO NUCLEO ZERO!!!! LEVANDO 6 HORAS.
#             O Sênior Da O Comando de Varável do Kernel $(nproc) e passa O Flag de Threading J.
#             "MAKE J=32!!" A MÁQUINA PULA TODOS OS 32 CORES PRA 100% USANDO PTHREADS!
#             AS 6 HORAS VIRAM 5 MINUTOS GERAIS DE COMPILAÇÃO MONSTRA PARALELIZADA COM SUCESSO!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - FENÔMENO MACABRO NO ./CONFIGURE DO LPI JUNIOR: "Missing dependency: openssl-devel required error stop".
#   Você Fica Revoltado E Vai No APT. Você Manda: `apt install openssl`. Instala Rápido, com SUcesso.
#   Aí Você Volta No Bash da Compilação e Roda de Novo `./configure`. O ERRO CONTINUA O MESMOOOO E PARA DE NOVO!
#
#   O Porquê Físico: O Seu pacote `apt install openssl` INSERE O BINÁRIO COMUM (O Carro Final) NO LINUX.
#   O Código-Fonte do Dev não Quer o Carro Pronto! O Código Do Deno Quer o **MANUAL DE INSTRUÇÕES DE C++ DO CARRO 
#   PRA CONVERSAR/LINKAR C-LIBS COM ELE!! ELE QUER DEVEL HEADERS FILES!**
#   Se Der problema Cego de "Missing Dep C", VÁ NO APT e PROCURE OS NOMES DE ENGENHARIA "*-dev" ou "*-devel"!
#   Solução Magística: `apt install libssl-dev`. (RedHat é "openssl-devel").
#   VOLTE NO CONFIGURE, ELE PULA PRA FRENTE COM ALEGRIA C++.

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Por que Fugimos Da 'Tridade Makefile' Nas Empresas E Oramos Pelo Docker Image?
# O Sênior Da Compilação É o Sênior De Cabelos Brancos.
# Eram chamados na Era da Pedra Do TI "DLL HELL" (Inferno de Bibliotecas) e "Dependency Tracking Nightmare".
# Se você 'compila de Fonte' e BANCAR O CARA RAIZ `sudo make install`: 
# Quando houver vulnerabilidade CVE (ZeroDay) Mundial.. SEU SOFTWARE CUSTOM COMPILADO *NÃO* VAI APARECER NO RADAR
# DO "APT UPDATE" QUE Cobre A BUNDA Da Instituição Bancaria Contra Invasões!!! A Loja Não Vai Cuidar Da Sua Falha! 
# O Arquivo foi FEITO Na Sua Mão, O Hacker Entra Nele Anos Depois Pq Ele NUNCA Mais ganhou Patch de Segurança APT!!
# 
# Soluções Sênior Cloud Native Hoje: Nunca Faça Make Installs Pra Prod!
# Construa A Ferramenta Rara Isolada Via "DockerFile" (Container Isolé Que Nunca Toca o FHS) !!
# Container Virtual garante reprodutibilidade Total E Você Controla as CVEs Pelo Pipeline de Scanners de Image CI/CD.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você compilou e deu Deploy 'make install' Da Versão Mais Customizada de um NGINX Exclusivo 
# feito sob Demanda de um Dev Chinês em nos `/usr/local/nginx/`. Hoje o Dev C Faleceu, e o time pediu Para 
# DESLOGAR (Remover) ele Do Servidor Urgente Porque Tinha Porta dos Fundos. Não temos mais 'Yum Remove' Pra Ele! 
# Nós Entramos Na Pasta Dele Da Compilacão de 1 ano atrás E... Como Mandamos Tudo Que Ele Vomitasse No Servidor
# voltar com mágica C pra Apagar Perfeitamente do S.O. FHS Localmente?"
#
# Resposta Esperada: "Geralmente (Cerca de 90%) se o Engenheiro Fonte GNU preparou decentemente o Makefile Header
# Declarando as Target Trees 'install', ele também obrigatoriamente declarou o Phony Target Reverso Unhooked.
# Nós Navegamos até a Exata pasta '/Downloads/meu_programa_v3/' ONDE ESTEJA AINDA O EXATO ARQUIVO DE TEXTO 'Makefile' Antigo de Membro, 
# Entramos como Root/Sudo e Chamamos Específico do GNU Make Diretiva CleanUp Absoluta:
# `sudo make uninstall`
# Essa Alavanca do make Lerá a tabela reversa do texto e Fará o Kernel Remover 'RM' as Peças Embutidas Exatas nas Oito 
# Bibliotecas Secretas Lib() Que Estipulou Em toda FHS de Servidor. O Lixo Sai Inteiro!"
