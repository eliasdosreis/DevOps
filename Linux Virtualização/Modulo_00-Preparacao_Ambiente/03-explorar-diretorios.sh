#!/bin/bash
# ==============================================================================
# 1. ANALOGIA DO DIA A DIA
# Ao entrar em um grande centro de distribuição industrial, tudo tem o seu
# lugar fixo demarcado por fitas amarelas. Os arquivos dos funcionários ficam
# num cofre. O maquinário pesaso numa garagem. No libvirt é igual: a "Planta"
# (arquivos XML das VMs) e o "Estoque de HDs" (imagens de disco) ficam em
# pastas Linux altamente protegidas e separadas. O Síndico (libvirtd) não deixa
# você colocar coisas em pastas erradas sem ter dor de cabeça de permissão.
#
# 2. O QUE É (Definição Técnica Senior)
# O ambiente KVM/Libvirt divide rigidamente o FHS (Filesystem Hierarchy Standard) do
# Linux nas ramificações: /etc/libvirt/ (para definições persistentes e configs de daemon)
# e /var/lib/libvirt/ (para estado, volumes provisonados, e boot images). Entender 
# esses paths é essencial para auditorias e migrações braçais (sem rede).
# ==============================================================================

# ==============================================================================
# 3. ARQUIVO / SCRIPT COMENTADO
# Objetivo: Listar e explicar os diretórios críticos do libvirt
# ==============================================================================

echo "=== 1. O Cofre das Plantas / Configurações (/etc/libvirt) ==="
# Aqui moram os arquivos XML (As "plantas baixas"). Nunca edite eles na mão
# com `vim`. Use sempre `virsh edit`, pois há uma validação de schema em tempo real.
sudo ls -la /etc/libvirt/qemu/
sudo ls -la /etc/libvirt/qemu/networks/
# No 'networks/autostart', ficam os links simbólicos das redes (ex: default.xml)
# Se estiver aqui, a rede sobe no boot.

echo -e "\n=== 2. O Galpão de Discos e ISOs (/var/lib/libvirt) ==="
# Storage Pool padrão (HDDs virtuais das VMs - qcow2, img).
sudo ls -la /var/lib/libvirt/images/
# Storage de imagens base do sistema (às vezes ISOs ou volumes de filesystem provisório)
sudo ls -la /var/lib/libvirt/boot/

echo -e "\n=== 3. O Livro de Ocorrências e Logs (/var/log/libvirt) ==="
# Fundamental para Troubleshooting. Cada VM ganha um arquivo de log único com seu nome!
sudo ls -la /var/log/libvirt/qemu/

echo -e "\n=== 4. A Sala de Contenção de Processos (/run/libvirt ou /var/run) ==="
# Onde ficam os sockets de comunicação PID_files e sockets QMP (QEMU Monitor Protocol)
sudo ls -la /run/libvirt/qemu/

# ==============================================================================
# 4. COMANDOS PASSO A PASSO
#
# Comando: sudo tree /etc/libvirt
# - O que faz: Exibe a ramificação de todas as configurações do hypervisor.
# Se tree não existir: `sudo find /etc/libvirt -type f`
# 
# Pense na divisão principal:
# /etc/libvirt/qemu -> Conf de VMs do driver QEMU
# /etc/libvirt/lxc  -> Conf de containers nativos do LXC (antigos e muito menos usados hoje).
# ==============================================================================

# ==============================================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
#
# Erro comum: Você cria uma nova pasta `/home/usuario/isos`, baixa um Ubuntu.iso ali,
# e pede para o libvirt criar uma VM montando este disco D:\... Ops! A libvirt 
# retorna "Permission Denied: cannot access /home/usuario/isos/ubuntu.iso".
# Causa: O QEMU process, rodando como usuário `qemu` (em sistemas Debian) ou 
# `qemu` / `libvirt-qemu`, não tem poder de atravessar a sua Home e as labels do 
# AppArmor/SELinux estão protegendo de vazamentos.
# Solução de Junior: Dar chmod 777 na home (INSEGURANÇA EXTREMA).
# Solução de Pleno/Senior: Mover a ISO para a pool padrão (/var/lib/libvirt/images)
# ou criar uma Storage Pool nova pelo virsh definindo as permissões apropriadas.
# ==============================================================================

# ==============================================================================
# 6. CONCEITO SENIOR (O "porquê" profundo)
# Existe uma proteção no Libvirt chamada sVirt, ligada ao SELinux.
# Toda vez que a VM inicia, a libvirt "remonta" (relabel) os arquivos de log,
# hd qcow2 e memória num selinux contexto do tipo `svirt_image_t`. A VM rodando
# fica com um rótulo randômico s0:c123,c456. Esse isolamento criptográfico no
# kernel impede que uma VM hackeada consiga ler o HDD de OUTRA VM na mesma pasta:
# `ls -laZ /var/lib/libvirt/images/`. Sem entender a árvore padrão, administradores
# lutam com SELinux e acabam desativando-o em produção, expondo o data center a riscos.
# ==============================================================================

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Senior)
# Pergunta: "Seu sistema de log (HD do SO base) lotou a partição raíz `/`. O `/var` 
# está acoplado ao root. Você decide limpar espaço. O que acontece se você der
# um `rm -rf /var/lib/libvirt/images/*`? Você perdeu também a configuração principal
# da VM que estava no XML?"
# Resposta esperada: "Em `/var/lib/libvirt/images` eu perderei os discos virtuais
# com os sistemas operacionais hospedados (DADOS DESTRUÍDOS), mas a VM (Sua estrutura de 
# hardware, vCPU, RAM e interfaces de rede) continua definida no cache ou em 
# `/etc/libvirt/qemu/nome-vm.xml`. Posso religá-la se conseguir restaurar apenas 
# os arquivos de imagem de um backup e colocar na mesma rota."
# ==============================================================================
