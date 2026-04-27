#!/bin/bash
# ==============================================================================
# Aula 08.04: Segurança e Hardening - A Criptografia SSL/TLS e OpenSSL
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# O TCPDump da Aula 5 Faz O Que Cego? Ele Lê O Cabo Cego De Acesso Da Nuvem Física e VE TODAS as SENHAS DOS USUARIOS Digitando E COMPRANDO CARTÃO CLARO Cego NA RUA CEGA!.
# Você precisa de um ENVELOPE Cego (UMA BLINDAGEM CEGA NO MEIO DA RUA Cega Que o Correio Leve Sem Ninguem Abrir No Caminho O Papel).
# 
# Isso e O TLS/SSL Cego(Certificado Do Cadeadinho Verde Cego Do Naveagdor).
# O Certificado é Feito em Matemática de Chaves Ceagas Pub/Priv Assimetricas Cegas Inviolávis Cego Matemáticas Computadores Quanticos Limite E Cifra De Chaves Privadas (Private Keys .Key Files Cego E Public Certs Cego Falsificados Fhf. O Sênior CeGo Emitem, Reemitim E Criam Seus Próprios Ca Cego!).

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# OpenSSL TLS Libraries Oculto Layer 4 Ceo Fhs. A Autoridade Cetificadora Cega Mundial (Google CA Root Trust Ocultos Kernel Fhs Base) Autentica Criptográficamente E Vinculam O SEU IP Cego Com O SEU DNS Empresarial Pela Estrutura X509 Criptografia Pki Ceo. Gerando Uma Private Key Indescriptavel RSA/EC Elliptic 2k Cego RSA 4096 E O Pem Certificate.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------
# ATENÇÃO. Em Produção, exige Root Cego (Sudo). 

# GERANDO UM CERTIFICADO AUTO ASSINADO PRA TESTE INTERNO EMPRESA (SELF-SIGNED 10 ANOS Sênior CEGO Magico!):
# Usado pra Proteger Base Logs Morte e Dashboards de Administradores Sem Internet Mundial: 
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout minha_empresa_secreta.key -out minha_empresa_secreta.crt
# (Ele Cria O 'Minha_secreta.Key' O SEGREDO DO CADEADO QUE NINGUÉM PODE ROUBAR Cego DA EMPRESA CEGO! 
# Y O .crt A Fechadura Pra por No NGINX Cego Site e Entregar Pra Qualquer Cliente Na Rua! Cego!).

# TESTADOR DE CADEADOS DA INTERNET VIVA DIRETO DA CLI Sênior S_CLIENT:
# Seu Nginx ta dando SSL Erro 502 E A Pagina nao Carga Falsificada! Qual ValidDate Acabou A Compra Do Ceo Cego? Lê Mágica Cego:
openssl s_client -connect google.com:443 -servername google.com  # OBRIGATÓRIO (Diagnóstico de Certificados Server-Side Remotos Em Testes de Vencimento E HandShakes CA Expirados Ceo).

# O CERTBOT MUNDIAL GRAÇAS A DEUS NGINX E LETSENCRYPT OPEN Cego:
# Os Certificados Custavam 4 Mil Reais Antigamente O C-Level Pagava Pró Banco.
# O Let'S_Encrypt Trouxe DE GRAÇA OS Cadeadinhos Pro Mundo (Com Validade De 3 Meses Cego).
apt install certbot python3-certbot-nginx   # Modulos Mágicos Automáticos De Assinatura LetS.
certbot --nginx -d meusite.com.br           # Ele Lança Um Desafio "Challenge TXT Http" Pro Servidor Mundial Gringo Da LetsEncript, O Gringo Bate Na Sua Porta 80. Valida Que VOCE MANDA NO DOMINIO Cego DA RUA. E Emito E AUTO-INJETA Nas Configuracoes Cegas do Seu Servidor Web o Caminho Dos Certificados Privados Perfeitos Do Pki World E O Site Acende VIVO O CADEADINHO FHS!!.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] openssl x509 -in certificado_empresa_suspeito.crt -text -noout
# [O QUE FAZ] Ele Lêr o Arquivo Ilegível do Certificado '.crt' Falso Assinado Misticamente Em Base64 e CUSPIRE Cego Em LINHAS HUMANAS A Data de VALIDADE CEGA, O NOME DA EMPRESA, E O ALGORITMO RSA MATEMÁTICO USADOS SEM COLOCAR NENHUMA CONEXÃO DA RAM CEGA DO NGiNX! Auditoria Estática Mágica FHS!

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - CENA CEGA ABSURDA: O "minha_empresa_secreta.key" QUE VOCE GEROU CAIU NAS MÃOS DO "CAIO DO FINANCEIRO" MISTERIOSAMENTE NUM ATAQUE CEGO DA FIRMA DE ESTAGIARIOS USB!! O Q ACONTECEU E O QUE VAI CAUSAR Cego?
#
# O PRIVATE KEY Cego É A CHAVE CEGA ABSOLUTA MATEMÁTICA QUE ABRE A BLINDAGEM EM TCPDUMPS CEGOS DE REDE!! Qualquer Hacker Cego Que Tiver A '.KEY' DE UMA EMPRESA "CAIO".. Ele Consegue Sentar No Café WIFI E Ler AS COMPRAS CEGAS CARTAO DE CREDITO DE TODO MUNDO DO SEU SITE SENDO COMPRADO NA RUA CEGA FHS EM TEMPO REAL FAZENDO REVERSÃO LOCAL TLS HANDSHAKE DECRIPT DE CACHE EXATO! As Chaves Privádas Fhx Devem Ficar Cegas E Muted Cegas E Chmod 400 Roots Somentes Em Vault Cego Cloud Segregados!! 

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# O Fim dos SSLv3 e Tlsv1 e os Hardening Suites Cipher Cego (SSLLabs Sênior Grade A).
#
# Se O Nginx Sênior Colocar O Cadeado Da Sua Empresa E Rodar O Certificado Com Sucesso Fhs. O Sysadmin Pleno CEGa FICA FELIZ Cego "Estou Seguro TLS Abriu e A Pagina Funciona Viva".
# Mas O Auditor De Cyber Security Testa E Te DA NOTA F Cega Morte!! E Manda Tirar Do Ar A Empresa Cega!! Pq?
# Pq O Sênior NÃO DESLIGOU OS PROTOCOLOS OBSOLETOS TLS 1.0 e TLS 1.1 NOS CONFIGS DO NGINX CEGO!! Protocolos Velhos Tão Quebrados Em Colisao Matématica Em Dois Dias O Bot Russo Racha E Lê A Ttala Exata DO TCPDUMP Fhs.
# A C-Life Configuration Sênior Injeta Na Porta 443 Configuração Cega Absoluta De Negar "TLSv1 TLSV1.1" e Obrigatar Somente Cifras Modernas "TLSV1.2 TLSV1.3 Cego" Ocultas Da ChaCha20 Em AES GCM Sênior. Forçando Modernidade Pura e Nota "A+ SecLabs Cego" Da Rua.

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você precisa Acoplar Múltiplos Certificados De TLS E Dezenas de Subdominios ('painel.com, banco.com, api.com') Diferentes Assinados Para Somente Exatamente 1 Servidor Ip Cego Público Host FrontEnd Virtual Do Datacenter Local Na Mesma Porta Base Extrema De DMZ 443 Blindada De Escalonamentos Cloud Cego Fhs Ext. Contudo, Historicamente Antigos TLS Cego Nativista HandShakes Clientes Reclamavam Q Se Duas Paginas Distintas Usavam MESMA Porta E IP O Servidor Entregava Certificado Errado Txt (Primeirona Raiz Oculta Pki Cega) Para Todas As Chamadas Fhs Criando Conflito Morte Certificado Fraudulento. Qual Invenção de Negociações Múltiplas Resolve Este Casamento Físico Sem Add Milhoes IPs Fixos Caros Do IPv4 E Como Habilitamos Cego FHS?"
#
# Resposta Esperada: "Usaríamos a funcionalidade de Casamento SNI Extencions Absoluta Extensões de Nome Servidor Cegas (Server Name Indication). O SNI Opera Mágicamente Dentro Dos Fluxos Iniciais TLS ClientHello Blindado Extensões Cegas Iniciais Do Browser Moderno Acusando Ao Host Daemon Incomun Exatamente O 'Domain Label DNS Cego HostName' Pelo Qual O Usuario Pediu Originalmente Cego. O Kernel Servidor Lendo As Letras Fhs Disparando Entregas Assincronas Cegas Virtuais VirtualHosts Fhs Em Arquitetura Nginx Cega, Separando e Acoplando Os Certificados Crt PKI Certos Baseados Unicamente Em Lógicas Strings Dominals, Desobrigando Exigência Histórica Cara Extra IPs Cegas Para Assinaturas Certs Distintas Ceogs!"
