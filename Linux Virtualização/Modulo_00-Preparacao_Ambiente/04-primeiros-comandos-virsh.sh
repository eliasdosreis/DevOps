#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# A ferramenta 'virsh' (Virtual Shell) é como um rádio de comunicação usado
# pelo gerente (Você) para dar ordens ao síndico do prédio (libvirtd). 
# Em vez de você bater na porta do apartamento de cada morador (ir lá no
# processo do QEMU ou do Linux rodando na porta PID 5543), você pega o rádio 
# e grita: "Síndico, desliga a força geral da casa 32!" (virsh destroy vm32).
#
# 2. O QUE É (Definição Técnica Senior)
# O `virsh` é a CLI principal interativa da API libvirt C. Ele abstrai comandos 
# brutos de monitor do QEMU (via QEMU Monitor Protocol - QMP) enviando chamadas 
# RPC sobre Sockets UNIX/TCP para o daemon local ou remotamente operado.
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Validar conectividade e uso dos comandos de consulta
# ==============================================================================

# O comando mais usado de todos. A flag --all mostra máquinas Desligadas
# (shut off) e as máquinas rodando (running).
# Sem o --all, só mostra as rodando, o que confunde muita gente achando
# que a máquina sumiu.
echo "1. Listando todas as Maquinas Virtuais:"
virsh list --all

# Mostra informações vitais sobre o hypervisor FÍSICO atual (O servidor host).
# Usado para dimensionamento e cálculo de capacidade.
echo -e "\n2. Relatório de Capacidade do Nó Hospedeiro:"
virsh nodeinfo

# O daemon cria sub-estruturas para isolar configurações. Rede é um exemplo.
# Mostramos as redes virtuais disponíveis e seus estados.
echo -e "\n3. Listando redes virtuais criadas pelo libvirt:"
virsh net-list --all

# ==============================================================================
# 4. COMANDOS PASSO A PASSO
#
# Comando 1: virsh nodeinfo
# - O que esperar: Você verá a arquitetura, cores por socket, e a RAM FÍSICA
# disponível total no nó.
# 
# Pulo do gato do `virsh`: Você pode usar ele no modo shell interativo!
# Comando 2: Basta digitar `virsh` no terminal e apertar ENTER.
# Ele mudará seu prompt para `virsh #`. Ali dentro, você tem autocompletar e
# não precisa ficar re-digitando a palavra "virsh" nos comandos (ex: list --all 
# direto dentro dele). Para sair, digite 'quit'.
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você executa `virsh list --all` e está VAZIO, mas no virt-manager
# você VÊ as VMs na interface gráfica! Magia?
# Causa: Contexto de URI (Uniform Resource Identifier).
# Quando você, 'Elias', roda 'virsh', por padrão conecta ao daemon de usuário 
# (qemu:///session), mas o virt-manager pode estar conectado ao daemon de sistema 
# raiz (qemu:///system). VMs rodam em mundos isolados e invisíveis uma da outra.
# Solução: Crie as VMs no context system `virsh -c qemu:///system list --all`.
# Como root (sudo), ele sempre usa systemd:///system.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# O URI connection é a chave mestra em times grandes. Você pode usar o `virsh`
# da SUA MÁQUINA para listar as VMs num servidor no Canadá se você tiver a chave
# ssh. O Senior escreve scripts rodando na máquina local que manipulam VMs em
# dezenas de clusters rodando:
# `virsh -c qemu+ssh://root@10.0.0.5/system list --all`
# Essa é a mesma API subjacente que OpenStack e oVirt utilizam por baixo dos
# panos para construir cloud públicas gigagantes, abstraindo essa URL.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Sua equipe de engenharia usa libvirt para desenvolver localmente
# e também nos servidores de CI/CD. Qual a diferença de usar a virtualização atrelada
# a `qemu:///session` versus `qemu:///system` e quando você escolheria usar cada?"
# Resposta esperada: "O URI 'qemu:///session' invoca um daemon a nível de usuário,
# que é excelente (e seguro) para desenvolvedores testarem laboratórios locais 
# em sua pasta Home sem privilégios de root, porém com acesso degradado a rede avançada
# e a pass-through de hardware ou bridges limpas. Já 'qemu:///system' executa 
# todo o fluxo pelo daemon principal de root, sendo mandatório para Servidores de
# Produção, onde precisamos plugar em bridges Vlan corporativas ou iniciar no 
# systemctl isolados."
# ==============================================================================
