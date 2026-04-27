#!/bin/bash
# ==============================================================================
# Aula 09.05: PROJETO FINAL - O Mundo dos Containers Docker (A Fábrica Mágica)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA (Para Uma Criança de 10 Anos Entender!)
# ------------------------------------------------------------------------------
# Sabe Aquelas Caixinhas De Brinquedo LEGO? Cada Uma Tem Tudo Que Precisa Dentro:
# as Pecinhas, o Manual, a Figurinha. Você Abre, Monta e Funciona. Não Importa
# Se Você Tá na Sua Casa, na Casa da Vovó ou na Casa do Amigo... O LEGO Funciona IGUAL!
#
# Isso É Um Container Docker!
# Seu Programa Fica Numa "Caixinha" Com TUDO Que Ele Precisa Pra Funcionar.
# Não Existe Mais Aquele Choro Do Junior: "FUNCIONOU NA MINHA MÁQUINA!"
# Porque Agora a Caixinha Inteira Vai Pro Servidor. E Funciona IDÊNTICO!
#
# VM (Máquina Virtual) = Uma Casa Inteira Com Fundação, Paredes, Telhado.
# Container Docker     = Só O Apartamento Com Seus Móveis. Compartilha O Prédio (Kernel)!
# Por Isso Container Sobe Em 0.3 segundos e VM Demora 2 Minutos! É MUITO MAIS LEVE!

# ------------------------------------------------------------------------------
# 2. O QUE É (Definição Técnica Sênior)
# ------------------------------------------------------------------------------
# Docker É Um Runtime De Containers OCI-Compliant Que Usa Namespaces Linux
# (pid, net, mnt, uts, ipc) E Cgroups v2 Para Isolar Processos Em Espaços
# Lógicos Separados Compartilhando O Mesmo Kernel Host.
# A Imagem É Um Snapshot Imutável De Layers UnionFS (OverlayFS2) Empilhados.
# O Container É A Instância Viva E Efêmera Dessa Imagem Em Execução Com Uma
# Camada Gravável No Topo. O Docker Daemon (dockerd) Gerencia Tudo Via API REST
# Unix Socket `/var/run/docker.sock` E O CLI Docker É Um Client Dessa API!

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO E PRIMEIROS CONTAINERS - MÃO NA MASSA!
# ------------------------------------------------------------------------------

# PASSO 1: INSTALAR O DOCKER ENGINE (A Fábrica de Caixinhas) NO DEBIAN/UBUNTU:
apt update
apt install -y ca-certificates curl gnupg

# Adicionar a Chave GPG Oficial do Docker (Verificação Criptográfica Cega!):
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Adicionar O Repositório Oficial Do Docker No APT Sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# PASSO 2: ADICIONANDO SEU USUÁRIO NO GRUPO DOCKER (Sem Sudo Toda Hora!):
# Aula 2 Grupos!! O Grupo "docker" Tem Acesso Ao Socket /var/run/docker.sock!
usermod -aG docker $USER
# ATENÇÃO: Precisa Fazer Logout e Login Pra Valer! Ou Usar: newgrp docker

# PASSO 3: TESTANDO SE A FÁBRICA TÁ LIGADA:
systemctl enable --now docker
docker run hello-world
# [SAÍDA ESPERADA]: "Hello from Docker!" - A Fábrica Funcionou! Caixinha Aberta!

# PASSO 4: OS COMANDOS ESSENCIAIS DO DIA A DIA SÊNIOR:
docker ps                    # Lista Containers VIVOS Agora (Como o 'ps aux' do Docker)
docker ps -a                 # Lista TODOS (Vivos E Mortos Fantasmas)
docker images                # Lista As Caixinhas (Imagens) Que Você Baixou
docker pull nginx:latest     # Baixa A Imagem Do Nginx Do Docker Hub (A Loja de LEGO!)
docker rmi nginx:latest      # Remove A Imagem Local (Joga a Caixinha No Lixo)
docker logs meu_container    # Ver O STDOUT/STDERR Do Container (Aula 1 Redirecionamento!)

# PASSO 5: SUBINDO UM NGINX EM CONTAINER - O PODER REAL!
docker run -d \
  --name meu_nginx \
  -p 8080:80 \
  --restart always \
  nginx:latest
# -d          = Détaché (Roda Em Background Igual 'nohup' Da Aula 4!)
# --name      = Apelido Pro Container (Sem Isso Fica "thirsty_einstein" Aleatório!)
# -p 8080:80  = Mapeia Porta 8080 Do Host Para Porta 80 Do Container (NAT!)
# --restart   = Se A Máquina Reiniciar, O Container Renasce Sozinho! (Aula 4 Systemd!)

# PASSO 6: CRIANDO SUA PRÓPRIA IMAGEM - O DOCKERFILE (A Receita Da Caixinha!)
# vim Dockerfile
# ============ ARQUIVO DOCKERFILE ABAIXO ============
# FROM ubuntu:22.04
# # FROM = Qual Caixinha Base Você Quer Usar (O Terreno Inicial)
#
# LABEL maintainer="elias@empresa.com"
#
# RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*
# # RUN = Comandos Que Rodam DURANTE A CONSTRUÇÃO Da Caixinha (Não Em Runtime!)
# # rm -rf /var/lib/apt/lists/* = Sênioridade: Limpa Cache APT Pra Imagem Ficar MENOR!
#
# COPY index.html /var/www/html/index.html
# # COPY = Joga Arquivo Do Seu PC Pra Dentro Da Caixinha
#
# EXPOSE 80
# # EXPOSE = Documenta Que O Container Usa Porta 80 (Não Abre Sozinho, Só Documenta!)
#
# CMD ["nginx", "-g", "daemon off;"]
# # CMD = O Comando Que Roda Quando O Container NASCE E Precisa Ficar Vivo!
# # "daemon off" = Fundamental! Docker Mata Container Quando O PID 1 Morre!
# # Se Nginx Virar Daemon (Background), O PID 1 Morre E Derruba O Container!
# ============ FIM DOCKERFILE ============

# Construindo a Imagem a Partir Do Dockerfile:
docker build -t meu-nginx-customizado:v1.0 .
# -t = Tag (Nome:Versão Da Sua Caixinha)
# .  = O Ponto Significa "Dockerfile Está Na Pasta Atual"

# PASSO 7: VOLUMES - PERSISTINDO DADOS (A Gaveta Que Fica Quando a Caixinha Vai Pro Lixo!)
# Containers São EFÊMEROS (Morrem E Nascem Sempre Limpos)! E os Dados?
# Volumes Docker São Pastas No Host Que Ficam Montadas Dentro Do Container!
docker run -d \
  --name meu_banco \
  -v /dados/mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=SenhaForte123 \
  mysql:8.0
# -v /dados/mysql:/var/lib/mysql = A Pasta Do Host:A Pasta Do Container
# Mesmo Que o Container Mysql Morra, Os Dados Ficam Em /dados/mysql No Host!!!
# -e = Variável De Ambiente Injetada (Como Export Da Aula 1, Mas Pro Container!)

# PASSO 8: DOCKER COMPOSE - ORQUESTRANDO VÁRIOS CONTAINERS JUNTOS (A Cidade de LEGO!)
# vim docker-compose.yml
# ============ ARQUIVO DOCKER COMPOSE ABAIXO ============
# version: '3.8'
# services:
#   web:
#     image: nginx:latest
#     ports:
#       - "80:80"
#     depends_on:
#       - app
#     networks:
#       - rede_interna
#
#   app:
#     build: ./app
#     environment:
#       - DB_HOST=banco
#       - DB_PASS=SenhaForte123
#     networks:
#       - rede_interna
#
#   banco:
#     image: mysql:8.0
#     volumes:
#       - dados_mysql:/var/lib/mysql
#     environment:
#       - MYSQL_ROOT_PASSWORD=SenhaForte123
#     networks:
#       - rede_interna
#
# volumes:
#   dados_mysql:      # Volume Nomeado Gerenciado Pelo Docker (Melhor Que Bind Mount!)
#
# networks:
#   rede_interna:     # Rede Interna Isolada! O Banco NÃO É Exposto Pro Mundo!
# ============ FIM DOCKER COMPOSE ============

docker compose up -d      # Sobe TUDO Em Background - A Cidade Inteira De Uma Vez!
docker compose ps         # Status De Todos Os Serviços Da Cidade
docker compose logs -f    # Logs De TODOS Juntos (O Jornalão Da Cidade Ao Vivo!)
docker compose down       # Derruba Tudo (A Cidade Dorme... Mas Os Volumes Ficam!)

# ------------------------------------------------------------------------------
# 4. VALIDAÇÃO E TROUBLESHOOTING SÊNIOR
# ------------------------------------------------------------------------------
# CENA DE PÂNICO: O Container Subiu Mas O Site Não Abre! O Diretor Tá Ligando!
#
# PASSO 1 - ENTRAR DENTRO DA CAIXINHA PRA VER O QUE TÁ ACONTECENDO:
docker exec -it meu_nginx bash
# exec -it = "Execute Interativo Com Terminal" (O SSH Dos Containers!)
# Agora Você Tá DENTRO Do Container! Rode 'ps aux', 'cat /etc/nginx/nginx.conf'!
#
# PASSO 2 - VER OS LOGS EM TEMPO REAL:
docker logs -f meu_nginx
# -f = Follow (Igual 'tail -f' Da Aula 7! Fica Olhando!)
#
# PASSO 3 - INSPECIONAR AS CONFIGURAÇÕES DO CONTAINER (A Ficha Técnica Completa):
docker inspect meu_nginx
# Retorna Um JSON GIGANTE Com IP, Volumes, Variáveis, PortMap, NetworkMode...
# O Sênior Filtra: docker inspect meu_nginx | grep -i "ipaddress"
#
# PASSO 4 - VER QUANTO RECURSO CADA CONTAINER TÁ CONSUMINDO:
docker stats
# O 'htop' Do Docker! CPU%, MEM, NET I/O, BLOCK I/O Em Tempo Real De TODOS!
#
# PASSO 5 - SE O CONTAINER MORREU E VOCÊ QUER SABER POR QUÊ:
docker inspect meu_nginx --format='{{.State.ExitCode}}'
# Exit Code 137 = OOM Killer! O Container Consumiu Toda RAM E o Kernel Matou!
# Solução Senior: docker run --memory="512m" ... (Limitando RAM Via Cgroups!)

# O CONTAINER É A REVOLUÇÃO DA INFRAESTRUTURA MODERNA. AWS ECS, GOOGLE CLOUD RUN,
# KUBERNETES... TUDO É CONTAINER POR BAIXO! PARABÉNS, VOCÊ CHEGOU NA ERA MODERNA!!
