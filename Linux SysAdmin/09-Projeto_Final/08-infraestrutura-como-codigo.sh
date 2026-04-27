#!/bin/bash
# ==============================================================================
# Aula 09.08: PROJETO FINAL - Infraestrutura Como Código (Terraform + Ansible)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA (Para Uma Criança de 10 Anos Entender!)
# ------------------------------------------------------------------------------
# Imagina Que Você Quer Construir Uma Cidade De LEGO Igual Em Vários Lugares.
# Jeito Júnior:  Você MONTA MANUALMENTE Peça Por Peça Em Cada Lugar. Demora Semanas!
#               Se Você Errar Uma Peça, A Cidade Fica Torta E Diferente Em Cada Lugar!
#
# Jeito Sênior: Você Escreve Um LIVRO DE RECEITAS MÁGICO!
#              "Coloque 10 Peças Azuis Aqui. 5 Vermelhas Ali. 1 Torre No Centro."
#              Aí Você Dá O Livro Pra QUALQUER PESSOA Em QUALQUER LUGAR...
#              E Elas Constroem A Mesma Cidade IDÊNTICA! Sempre Igual! Sempre Certo!
#
# TERRAFORM = O Livro De Receitas Do Prédio (A Infraestrutura Física: Servidores, Redes, DNS)
#            "Crie 5 Máquinas Na AWS, Libere A Porta 443, Crie O Banco De Dados..."
#
# ANSIBLE   = O Livro De Receitas Do Interior (O Que Instalar E Configurar Dentro!)
#            "Instale O Nginx, Configure O PHP, Crie O Usuário Deploy, Abra O Firewall..."
#
# Juntos: Terraform Constrói O Prédio Vazio. Ansible Decora E Mobilia Por Dentro!

# ------------------------------------------------------------------------------
# 2. O QUE É (Definição Técnica Sênior)
# ------------------------------------------------------------------------------
# IaC (Infrastructure as Code) É O Paradigma De Gerenciar Infraestrutura Através
# De Arquivos De Configuração Versionados No Git (Assim Como Código De Software).
# Terraform É Uma Ferramenta HCL Declarativa Com State Machine: Ele Compara O
# "Estado Desejado" (Seus .tf) Com O "Estado Real" (terraform.tfstate) E Calcula
# O Plano Mínimo De Mudanças (Diff) Pra Convergir. Idempotente Por Design!
# Ansible É Um Configuration Management Tool Agentless (SSH Puro!) Que Executa
# Playbooks YAML Com Módulos Idempotentes: Roda 1 Vez Ou 100 Vezes, Resultado Igual!

# ------------------------------------------------------------------------------
# 3. TERRAFORM - CRIANDO INFRAESTRUTURA NA AWS - MÃO NA MASSA!
# ------------------------------------------------------------------------------

# PASSO 1: INSTALAR O TERRAFORM
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform
terraform -version
# [SAÍDA ESPERADA]: Terraform v1.X.X   ← Instalado!

# PASSO 2: ESTRUTURA DE ARQUIVOS TERRAFORM (Organização Sênior!)
mkdir -p infra-terraform/{modules/webserver,environments/{dev,prod}}
# ├── main.tf          ← Recursos Principais (O Que Criar)
# ├── variables.tf     ← As Variáveis (Os Parâmetros Configuráveis)
# ├── outputs.tf       ← O Que Mostrar Na Tela Depois De Criar (IPs, URLs...)
# ├── provider.tf      ← Qual Cloud (AWS, GCP, Azure...)
# └── terraform.tfvars ← Os Valores Das Variáveis (NÃO Commitar Esse Com Senhas!)

# ============================================================
# ARQUIVO: provider.tf (Qual Cloud Usar)
# ============================================================
# vim provider.tf
# ======= CONTEÚDO provider.tf =======
# terraform {
#   required_version = ">= 1.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"       # Trava A Versão Para Não Quebrar (Semver!)
#     }
#   }
#   # BACKEND REMOTO: Guarda O Tfstate Na Nuvem (Não No Seu PC!)
#   # Se Guardar No PC, Só Você Consegue Rodar O Terraform! Catástrofe Em Time!
#   backend "s3" {
#     bucket         = "empresa-terraform-state"
#     key            = "producao/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"  # Lock: Impede 2 Pessoas Rodando Ao Mesmo Tempo!
#     encrypt        = true               # O Tfstate Tem Senhas! Criptografe Sempre!
#   }
# }
# provider "aws" {
#   region = var.aws_region
# }
# ======= FIM provider.tf =======

# ============================================================
# ARQUIVO: main.tf (Os Recursos A Criar)
# ============================================================
# vim main.tf
# ======= CONTEÚDO main.tf =======
# # -----------------------------------------
# # VPC (A Rede Privada Da Empresa Na Nuvem)
# # -----------------------------------------
# resource "aws_vpc" "principal" {
#   cidr_block           = "10.0.0.0/16"   # 65.536 IPs Disponíveis!
#   enable_dns_hostnames = true
#   tags = {
#     Name        = "vpc-${var.ambiente}"   # Tags São Obrigatórias Em Empresa! ($$$)
#     Ambiente    = var.ambiente
#     Responsavel = "infra-team"
#   }
# }
#
# # -----------------------------------------
# # SECURITY GROUP (O Firewall Da AWS - Aula 5!)
# # -----------------------------------------
# resource "aws_security_group" "web" {
#   name   = "sg-web-${var.ambiente}"
#   vpc_id = aws_vpc.principal.id   # Referencia O ID Da VPC Criada Acima!
#
#   ingress {                       # Regra De ENTRADA
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # De Qualquer IP Do Mundo!
#   }
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.ip_escritorio]  # SSH SÓ DO IP DO ESCRITÓRIO! Aula 8!
#   }
#   egress {                        # Regra De SAÍDA (Tudo Liberado)
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# # -----------------------------------------
# # EC2 INSTANCE (O Servidor De Verdade!)
# # -----------------------------------------
# resource "aws_instance" "webserver" {
#   count         = var.quantidade_servidores   # Cria QUANTOS Você Quiser! (1 Linha!)
#   ami           = "ami-0c55b159cbfafe1f0"     # Ubuntu 22.04 LTS Na AWS
#   instance_type = var.tipo_instancia          # "t3.micro", "c5.4xlarge", etc
#
#   vpc_security_group_ids = [aws_security_group.web.id]
#   key_name               = aws_key_pair.deploy.key_name  # A Chave SSH Da Aula 5!
#
#   # USER DATA: Script Que Roda Quando O Servidor Liga Pela Primeira Vez!
#   user_data = base64encode(templatefile("${path.module}/scripts/init.sh", {
#     ambiente = var.ambiente
#   }))
#
#   tags = {
#     Name = "webserver-${var.ambiente}-${count.index + 1}"
#   }
# }
# ======= FIM main.tf =======

# PASSO 3: CICLO DE VIDA DO TERRAFORM (O Ritual Sagrado Sênior):
terraform init      # Baixa Os Plugins (Providers) Necessários (Só Na 1a Vez!)
terraform validate  # Verifica Erros De Sintaxe Nos .tf (Antes De Qualquer Coisa!)
terraform plan      # MOSTRA O Q VAI CRIAR/MODIFICAR/DESTRUIR SEM FAZER NADA!
                    # SEMPRE REVISE O PLAN ANTES DE APLICAR! NUNCA APLIQUE CEGO!
terraform apply     # Executa O Plan (Vai Pedir Confirmação: Digite "yes")
terraform destroy   # DESTROI TUDO Q O TERRAFORM CRIOU! (Cuidado! Irreversível!)

# DICA SÊNIOR: Em Pipeline CI/CD Automático, Use:
terraform apply -auto-approve -var="ambiente=producao"
# -auto-approve = Não Pede Confirmação (Pois O Pipeline Já Validou O Plan Antes!)

# ------------------------------------------------------------------------------
# 4. ANSIBLE - CONFIGURANDO OS SERVIDORES - MÃO NA MASSA!
# ------------------------------------------------------------------------------

# PASSO 4: INSTALAR O ANSIBLE
apt install -y ansible
ansible --version

# PASSO 5: INVENTÁRIO (A Lista Dos Servidores Que O Ansible Vai Configurar)
# vim inventario.ini
# ======= CONTEÚDO inventario.ini =======
# [webservers]
# 10.0.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/deploy_key
# 10.0.1.11 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/deploy_key
#
# [bancos]
# 10.0.2.10 ansible_user=ubuntu
#
# [todos:children]   # Grupo Que Contém Todos Os Grupos!
# webservers
# bancos
# ======= FIM inventario.ini =======

# PASSO 6: O PLAYBOOK SÊNIOR (A Receita De Como Configurar O Servidor)
# vim playbook-webserver.yml
# ======= CONTEÚDO PLAYBOOK =======
# ---
# - name: Configurar Servidores Web Em Producao
#   hosts: webservers          # Roda Em Todos Os Servidores Do Grupo 'webservers'
#   become: yes                # Usar Sudo (Aula 2 Sudoers!)
#   vars:
#     php_version: "8.2"
#     nginx_worker_processes: "auto"
#
#   tasks:
#     - name: Atualizar Cache APT (apt update)
#       ansible.builtin.apt:
#         update_cache: yes
#         cache_valid_time: 3600   # Só Atualiza Se O Cache Tem Mais De 1h (Eficiência!)
#
#     - name: Instalar Nginx, PHP e Dependencias
#       ansible.builtin.apt:
#         name:
#           - nginx
#           - "php{{ php_version }}-fpm"
#           - "php{{ php_version }}-mysql"
#           - fail2ban              # Aula 8! Segurança Sempre!
#         state: present           # "present" = Instale Se Não Estiver. Idempotente!
#
#     - name: Copiar Configuracao Nginx Customizada
#       ansible.builtin.template:
#         src: templates/nginx.conf.j2     # Template Jinja2 Com Variaveis!
#         dest: /etc/nginx/nginx.conf
#         owner: root
#         group: root
#         mode: '0644'
#       notify: Recarregar Nginx   # Se O Arquivo Mudou, Aciona O Handler!
#
#     - name: Criar Usuario Deploy (Aula 2 Usuarios!)
#       ansible.builtin.user:
#         name: deploy
#         shell: /bin/bash
#         groups: www-data
#         append: yes
#
#     - name: Garantir Que Servicos Estao Habilitados No Boot (Aula 4 Systemd!)
#       ansible.builtin.systemd:
#         name: "{{ item }}"
#         state: started
#         enabled: yes
#       loop:                      # Loop! Roda Pra Cada Item Da Lista!
#         - nginx
#         - "php{{ php_version }}-fpm"
#         - fail2ban
#
#   handlers:                      # Handlers São Tarefas Q Só Rodam Se Notificadas!
#     - name: Recarregar Nginx
#       ansible.builtin.service:
#         name: nginx
#         state: reloaded          # reload (Suave) Não restart (Mata Conexoes Vivas!)
# ======= FIM PLAYBOOK =======

# PASSO 7: RODAR O ANSIBLE:
ansible-playbook -i inventario.ini playbook-webserver.yml
# [SAÍDA ESPERADA DE SÊNIOR]:
# PLAY RECAP *******
# 10.0.1.10  : ok=7  changed=3  unreachable=0  failed=0
# 10.0.1.11  : ok=7  changed=0  unreachable=0  failed=0
# "changed=0" No Segundo Servidor = IDEMPOTÊNCIA! Ele Já Estava Configurado!

# Testar Conexão Com Todos Os Servidores Antes De Rodar:
ansible all -i inventario.ini -m ping
# [SAÍDA]: 10.0.1.10 | SUCCESS => {"ping": "pong"}  ← Conexão OK!

# Rodar Só Uma Task Específica (Sem Rodar O Playbook Inteiro):
ansible-playbook -i inventario.ini playbook-webserver.yml --tags "nginx"

# ------------------------------------------------------------------------------
# 5. VALIDAÇÃO E TROUBLESHOOTING SÊNIOR
# ------------------------------------------------------------------------------
# CENA: "O Terraform Apply Deu Erro: 'Error: Error launching source instance:
#        VcpuLimitExceeded'"
#
# Diagnóstico: A Conta AWS Tem Limite De vCPUs! Você Tentou Criar Mais Do Que O Limite!
# Solução Sênior:
# 1. Ver O Limite Atual: aws service-quotas get-service-quota --service-code ec2 \
#    --quota-code L-1216C47A
# 2. Abrir Ticket AWS Pra Aumentar O Limite (Service Quotas Console)
# 3. Ou Reduzir o count No Terraform: count = 2 (Em Vez De 10)

# CENA: "O Ansible Falhou Em 1 Servidor Com 'UNREACHABLE'"
# Diagnóstico: O Ansible Não Conseguiu Fazer SSH No Servidor!
# Solução Sênior:
ansible all -i inventario.ini -m ping --timeout=5  # Testar Conectividade SSH
# Causas: Security Group Bloqueando SSH (Aula 5!), Chave SSH Errada (Aula 5!),
#         IP Mudou Após Restart Da Instância (Use Elastic IP Na AWS!)

# TERRAFORM + ANSIBLE = O DUO MAIS PODEROSO DO MUNDO DEVOPS!
# TERRAFORM CRIA. ANSIBLE CONFIGURA. VOCÊ DORME TRANQUILO!
# ISSO É O QUE EMPRESAS COMO NUBANK, IFOOD E MERCADO LIVRE USAM TODO DIA!
# VOCÊ AGORA FAZ PARTE DESSE CLUBE EXCLUSIVO! PARABÉNS, SÊNIOR!!!
