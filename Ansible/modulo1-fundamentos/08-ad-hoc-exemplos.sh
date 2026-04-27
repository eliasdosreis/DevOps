#!/bin/bash
# ==============================================================
# ARQUIVO: 08-ad-hoc-exemplos.sh
# MÓDULO 1 - Fundamentos
# ==============================================================
#
# 🧒 EXPLICAÇÃO SIMPLES:
# Comandos ad-hoc são como MENSAGENS DE VOZ!
# Você manda uma instrução rápida, sem escrever uma receita inteira.
# "Oi servidor, me diz qual é seu IP!" - sem criar um playbook.
#
# FORMATO: ansible [hosts] -i [inventário] -m [módulo] -a "[argumentos]"
# ==============================================================

echo "=== 🚀 Exemplos de Comandos Ad-hoc Ansible ==="

# ---- 1. PING: Testar conexão com todos os servidores ---------
# Como perguntar "Oi, está aí?" para todos
echo ""
echo "--- Teste de Ping ---"
# ansible all -i 02-inventory-grupos.ini -m ping

# ---- 2. COMMAND: Rodar comando rápido -----------------------
echo ""
echo "--- Comandos Rápidos ---"

# Ver hostname de todos os webservers
# ansible webservers -i 02-inventory-grupos.ini -m command -a "hostname"

# Ver uso de disco em todos os servidores
# ansible all -i 02-inventory-grupos.ini -m command -a "df -h"

# Ver memória livre
# ansible all -i 02-inventory-grupos.ini -m command -a "free -m"

# ---- 3. SHELL: Comandos com pipes ---------------------------
echo ""
echo "--- Shell com Pipes ---"

# Quantos processos estão rodando?
# ansible all -i 02-inventory-grupos.ini -m shell -a "ps aux | wc -l"

# Ver os 5 processos que mais consomem CPU
# ansible webservers -i 02-inventory-grupos.ini -m shell -a "ps aux --sort=-%cpu | head -5"

# ---- 4. COPY: Enviar arquivo rapidamente --------------------
echo ""
echo "--- Copiar Arquivo ---"

# Enviar um arquivo local para todos os servidores
# ansible all -i 02-inventory-grupos.ini -m copy -a "src=/tmp/meuarquivo.txt dest=/tmp/meuarquivo.txt"

# ---- 5. APT/YUM: Instalar pacote sem playbook ---------------
echo ""
echo "--- Instalar Pacote ---"

# Instalar curl em servidores Ubuntu (precisa de -b para sudo)
# ansible webservers -i 02-inventory-grupos.ini -m apt -a "name=curl state=present" -b

# Atualizar todos os pacotes
# ansible all -i 02-inventory-grupos.ini -m apt -a "upgrade=yes update_cache=yes" -b

# ---- 6. SERVICE: Gerenciar serviços -------------------------
echo ""
echo "--- Gerenciar Serviços ---"

# Verificar status do nginx
# ansible webservers -i 02-inventory-grupos.ini -m service -a "name=nginx state=started"

# Reiniciar nginx
# ansible webservers -i 02-inventory-grupos.ini -m service -a "name=nginx state=restarted" -b

# ---- 7. GATHER_FACTS: Ver informações do servidor -----------
echo ""
echo "--- Informações do Servidor ---"

# Ver TODAS as informações (muito detalhado!)
# ansible localhost -m gather_facts

# Ver só o IP
# ansible localhost -m setup -a "filter=ansible_default_ipv4"

# Ver só info de memória
# ansible localhost -m setup -a "filter=ansible_memory_mb"

# ---- 8. USER: Gerenciar usuários ----------------------------
echo ""
echo "--- Gerenciar Usuários ---"

# Criar usuário
# ansible all -i 02-inventory-grupos.ini -m user -a "name=deploy state=present" -b

# Remover usuário
# ansible all -i 02-inventory-grupos.ini -m user -a "name=deploy state=absent" -b

# ---- DICAS IMPORTANTES --------------------------------------
echo ""
echo "=== 💡 Dicas Importantes ==="
echo "-i    = inventário (qual arquivo de servidores)"
echo "-m    = módulo (qual ferramenta usar)"
echo "-a    = argumentos (as opções do módulo)"
echo "-b    = become (rodar como sudo)"
echo "-k    = pedir senha SSH"
echo "-K    = pedir senha do sudo"
echo "--limit= limitar a um servidor específico"
echo ""
echo "Exemplo limitado: ansible all -i inventario.ini -m ping --limit web1"
