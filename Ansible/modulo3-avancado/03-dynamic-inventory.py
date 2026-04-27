#!/usr/bin/env python3
# ==============================================================
# ARQUIVO: 03-dynamic-inventory.py
# MÓDULO 3 - Avançado
# ==============================================================
#
# 🧒 EXPLICAÇÃO SIMPLES:
# Inventário estático = lista de amigos escrita no papel.
# Inventário dinâmico = seu celular que mostra automaticamente
# quem está online agora!
#
# Em empresas reais, servidores sobem e morrem a todo momento.
# O inventário dinâmico pergunta para a AWS/GCP: "quais VMs existem?"
# e monta a lista automaticamente. Zero manutenção!
#
# ▶️  COMO USAR:
# ansible-playbook -i 03-dynamic-inventory.py site.yml
# ou
# ansible -i 03-dynamic-inventory.py all --list-hosts
# ==============================================================

import json
import subprocess
import sys

def get_inventory():
    """
    Esta função SIMULA um inventário dinâmico.
    
    Na vida real, aqui você faria chamadas para:
    - AWS: boto3.client('ec2').describe_instances()
    - GCP: google-cloud SDK
    - Azure: azure SDK
    - VMware: pyVmomi
    - API interna da sua empresa
    """

    # ---- SIMULAÇÃO: em produção, viria de uma API ------------
    # Imagine que consultamos a AWS e ela retornou estes servidores:
    servidores_da_aws = [
        {
            "id": "i-001",
            "ip": "10.0.1.10",
            "nome": "web-prod-1",
            "tags": {"Ambiente": "producao", "Funcao": "webserver"},
            "tipo": "t3.medium"
        },
        {
            "id": "i-002",
            "ip": "10.0.1.11",
            "nome": "web-prod-2",
            "tags": {"Ambiente": "producao", "Funcao": "webserver"},
            "tipo": "t3.medium"
        },
        {
            "id": "i-003",
            "ip": "10.0.2.10",
            "nome": "db-prod-1",
            "tags": {"Ambiente": "producao", "Funcao": "database"},
            "tipo": "r5.large"
        },
        {
            "id": "i-004",
            "ip": "10.0.3.10",
            "nome": "web-staging-1",
            "tags": {"Ambiente": "staging", "Funcao": "webserver"},
            "tipo": "t3.small"
        },
    ]

    # ---- Estrutura que o Ansible espera ----------------------
    # O Ansible precisa de um JSON com este formato exato:
    inventario = {
        # "_meta" = variáveis por host (hostvars)
        "_meta": {
            "hostvars": {}  # Preenchemos abaixo
        },
        # "all" = todos os hosts
        "all": {
            "children": ["producao", "staging"]
        },
        # Grupos separados
        "producao": {
            "children": ["webservers_prod", "databases_prod"]
        },
        "staging": {
            "children": ["webservers_staging"]
        },
        "webservers_prod": {"hosts": []},
        "databases_prod": {"hosts": []},
        "webservers_staging": {"hosts": []},
        # Grupo especial por tipo de instância
        "tipo_t3_medium": {"hosts": []},
        "tipo_r5_large": {"hosts": []},
        "tipo_t3_small": {"hosts": []},
    }

    # ---- Processar cada servidor da AWS ----------------------
    for servidor in servidores_da_aws:
        ip = servidor["ip"]
        funcao = servidor["tags"]["Funcao"]
        ambiente = servidor["tags"]["Ambiente"]
        tipo = servidor["tipo"].replace(".", "_")  # t3.medium → t3_medium

        # Adicionar o servidor ao grupo correto
        if funcao == "webserver" and ambiente == "producao":
            inventario["webservers_prod"]["hosts"].append(ip)
        elif funcao == "database" and ambiente == "producao":
            inventario["databases_prod"]["hosts"].append(ip)
        elif funcao == "webserver" and ambiente == "staging":
            inventario["webservers_staging"]["hosts"].append(ip)

        # Adicionar ao grupo de tipo de instância
        grupo_tipo = f"tipo_{tipo}"
        if grupo_tipo not in inventario:
            inventario[grupo_tipo] = {"hosts": []}
        inventario[grupo_tipo]["hosts"].append(ip)

        # Adicionar variáveis específicas por host em _meta
        inventario["_meta"]["hostvars"][ip] = {
            "ansible_host": ip,
            "ansible_user": "ubuntu",
            "ansible_python_interpreter": "/usr/bin/python3",
            # Variáveis customizadas que vêm da AWS
            "instance_id": servidor["id"],
            "instance_type": servidor["tipo"],
            "nome_servidor": servidor["nome"],
            "ambiente": ambiente,
            "funcao": funcao,
        }

    return inventario


def main():
    """
    O Ansible chama este script com:
    --list  = retornar todos os grupos e hosts
    --host  = retornar variáveis de um host específico
    """

    # Se chamado com --list, retorna o inventário completo
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print(json.dumps(get_inventory(), indent=2))

    # Se chamado com --host <ip>, retorna vars do host
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        inventario = get_inventory()
        host = sys.argv[2]
        # Pegar variáveis do host específico
        hostvars = inventario["_meta"]["hostvars"].get(host, {})
        print(json.dumps(hostvars, indent=2))

    else:
        print("Uso: {} --list | --host <ip>".format(sys.argv[0]))
        sys.exit(1)


if __name__ == "__main__":
    main()
