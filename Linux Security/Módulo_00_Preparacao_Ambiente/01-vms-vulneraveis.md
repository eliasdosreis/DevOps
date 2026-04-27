# Módulo 0: Preparação do Ambiente
## Aula 01 - VMs Vulneráveis

### 1. ANALOGIA DO DIA A DIA
Imagine que você quer aprender a ser um chaveiro especialista ou um investigador de roubos. Você não pode sair praticando em fechaduras de vizinhos reais (isso é crime!). Em vez disso, você compra portas e fechaduras "de teste", coloca na sua garagem e pratica arrombá-las com suas ferramentas e técnicas em um ambiente controlado, de onde você sabe que nenhum dado ou bem de terceiros será prejudicado. VMs vulneráveis são exatamente as suas "portas de teste" na garagem.

### 2. O QUE É (definição técnica Senior)
VMs vulneráveis são imagens de sistemas operacionais pré-configuradas intencionalmente com falhas de segurança conhecidas (ex: softwares desatualizados, má configuração de permissões, senhas hardcoded, etc). Elas servem como "targets" (alvos) para estudos CTF (Capture The Flag) e treinamentos de pentest em um laboratório isolado ("sandboxed"). O objetivo primário não é causar dano, mas entender os mecanismos de ataque (exploitabilidade) e de defesa (detecção, logs).

### 3. SCRIPT / COMANDO COMENTADO
Embora essa aula seja mais teórica de laboratório, se fossemos automatizar o download, faríamos:

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Prepara a sua máquina Host para baixar e descompactar a famosa
# VM Metasploitable2 e criar um diretório padrão de máquinas alvo.
# ============================================================

#!/bin/bash

# Criação do diretório isolado de laboratório
mkdir -p ~/Laboratorio_Seguranca/Targets
cd ~/Laboratorio_Seguranca/Targets

# Download da máquina Metasploitable 2 via SourceForge (Exemplo)
# O wget pode ser usado para automatizar downloads do VulnHub.
# Atenção: Executar com consciência de armazenamento livre!
echo "[+] Baixando Metasploitable 2..."
# wget https://storage.googleapis.com/.../metasploitable-linux-2.0.0.zip 

# Descompactação
# unzip metasploitable-linux-2.0.0.zip
echo "[+] VM Preparada no diretório Targets."
```

### 4. PASSO A PASSO
**Passo 1:** Baixe o VirtualBox ou VMware Player.
**Passo 2:** Acesse o site do VulnHub (`vulnhub.com`) ou baixe o Metasploitable 2.
**Passo 3:** Extraia a imagem (geralmente `.ova` ou `.vmdk`).
**Passo 4:** Importe a VM para dentro do seu gerenciador (VirtualBox).
**Regra Crucial:** Ao configurar a rede da VM vulnerável, coloque em modo **Rede Interna (Internal Network)** ou **Host-Only**, NUNCA em Bridge nativa para sua rede de casa ou internet.
**Passo 5:** Ligue a máquina; ela mostrará uma tela de terminal e um IP de teste se tudo deu certo.

### 5. VERIFICAÇÃO E TROUBLESHOOTING
- **A VM travou na tela do GRUB?** Certifique-se de que ativou a virtualização (VT-x/AMD-V) na BIOS/UEFI do seu computador real.
- **A VM não tem rede/IP?** Como está em modo isolado, talvez o DHCP do VirtualBox não esteja ativado para essa rede. É melhor fixar IPs ou usar a interface do Host-Only Manager.

### 6. CONCEITO SENIOR (o "porquê" profundo)
Sêniors entendem que uma VM vulnerável, uma vez ligada na rede errada (como "Bridged" em rede corporativa), pode ser comprometida lateralmente por ransomwares reais ou atores ruins da mesma LAN, espalhando caos. É por que a isolação de rede L2/L3 no *hypervisor* é a essência principal de construir um laboratório. Além disso, a capacidade de gerar "Snapshots" rápidos da VM permite reverter as alterações que seus testes destrutivos farão à máquina alvo.

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Se eu coloco uma VM Metasploitable em Bridge numa rede de Wi-Fi pública de Aeroporto e levanto o serviço do Docker, qual é o principal risco prático disso?"
**Resposta Esperada:** Ao usar modo Bridge, a VM recebe um IP válido da rede local do aeroporto, expondo os serviços propositalmente vulneráveis da sua VM para qualquer atacante no saguão. Isso pode transformar seu laptop num ponto de pivotamento, ou na melhor das hipóteses, resultar na invasão rápida e comprometimento dos próprios serviços do Metasploitable, incluindo um root backdoor que vai comprometer os recursos da sua máquina hospedeira. Sempre isole VMs alvo em redes locais que só a sua VM "atacante" consiga acessar.
