#!/bin/bash
# ==============================================================================
# Módulo 1: Fundamentos de Segurança Linux
# Aula 05 - Capabilities do Kernel (Cap_Net_Raw, Cap_Setuid etc)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Antigamente num quartel militar base, só existiam Sargentos Normais (Usuários rwx)
# e o General Supremo (o Root). Se um Sargento do rancho comprasse ingredientes de 
# cantina, ele tinha que pedir pro General assinar o pedido, porque apenas o General 
# tinha poder para mover coisas com a alfândega. Isso tirava o general do sossego 
# fazendo tarefas bobas perigosas. Então o exército introduziu "Badges de Habilidades" (Capabilities).
# Peguem o pacote de Poderes Ominopotentes de Root de deus, pique-os me 40 pequenos pedaços discretos.
# E agora, podemos dar a um usuário júnior como o Analista de Redes apenas o "Poder 
# Específico Mágico de escutar porta" (cap_net_bind_service), SEM lhe dar a coroa de Root para 
# apagar os logs das máquinas do sistema.
#
# 2. O QUE É (definição técnica Senior)
# O Linux capabilities destrói e particiona a unipotência Binária que reinava no root (UID 0).
# Com setcap e getcap, nós associamos pedaços fragmentados da kernel authorization atrelada no binário propriamente dito (metadados FS estendidos do tipo xattr).
# - CAP_NET_BIND_SERVICE: Permite a um binário abrir as famosas Portas Privilegiadas (TCP de 1 até 1024, como porta 80 do Nginx ou 443 do SSL) sem usar o usuário root pra levantar.
# - CAP_NET_RAW: O mais abusado por atacantes pra forjar e abrir Sockets crus IP de baixo nível, permitindo tcpdump ou envios perversos injetados ARP via ping sem root!
# - CAP_SYS_ADMIN: A maldição, é o root disfarçado, permite mount, umount particionamentos e container destruction.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo: Varrer o HD por binários com esses "poderes estendidos" aninhados.
# Isso se assemelha e deve complementar sua caça na auditoria de Arquivos SUID da Aula 2.
echo "[+] Enumerando binários ocultos possuidores de Capabilities Especiais de Bypass:"
# O utilitário do sistema "getcap" e "setcap" lida com a library libcap.
# -r navega de forma recursivamente buscando em todos confins (pode jogar erro 2>/dev/null em pastão s/ perm).
getcap -r /usr/bin /bin /sbin 2>/dev/null

# Ofensivo: Exemplo teórco prático para entender a necessidade (apenas ler se não for admin):
# Imagine o ping nativo (que precisa de sockets curtos e crus de kernel CAP_NET_RAW).
# ls -la /bin/ping -> não possui "s" (SUID root). Ué, como ele pinga na rede se eu não sou admin?
# Porque o time dos devs OS modernos da Canonical injetaram os capabilities em vez de suid nele!
# Teste você mesmo para visualizar isso nas propriedades invisíveis:
getcap /bin/ping
# output esperado: /bin/ping = cap_net_raw+ep

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Digamos você escreveu um mini bot servidor API Web Node.js na porta de web default 80 (HTTP). 
# Passo 2: Mas por rodar com conta fraca sem root ("developer"), o OS recusa levantar as portas TCP  < 1024, atirando EACCES Port In Use or Denined. O Admin amador injeta sudo na invocação, virando a app de alvejamento um risco colossal pro hacker destruir o sistema pela internet.
# Passo 3: Solução Mágica Segura e Sênior do DevSecOps:
# Damos apenas esse micro-poder direto pro NodeJS binário (como root só 1 vez):
# sudo setcap cap_net_bind_service=+eip /usr/bin/node
# Passo 4: Retornando usuário dev normal, você roda ./sua_api_porta80.js, e boom, ligou sozinho!
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Quando um administrador faz update do OS (ex `apt upgrade nodejs`), o Update substitui
# o binário nativo baixando um novo fresco da internet, o metadata dos File Attributes Extended XATTRs 
# é apagado pelo OS. E o app pára de rodar pós update. Portanto, o uso de capabilities
# requer uma infra de automação de Ansible com um Task garantindo refavorecer o setcap a cada upgrade diário/mensal de deploy.
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# O CAP_SETUID tem um design macabro. Na aula 2 (GTFOBins / SUID), o OS protege quem dá escalonamento por bit suid.
# MAS, se um servidor tem o poderoso interpretador **PYTHON do binário** configurado com `cap_setuid+ep` localmente para automatizar tarefas em docker pra um time...
# Hacker acha ele na rede pelo getcap. E o que Hacker faz? Ele roda via python e não bash:
# `python3 -c "import os; os.setuid(0); os.system('/bin/bash')"` e ele escapa e vira root silencioso, anulando sua proteção contra o bit SUID! É assim que Hackers Seniors do Kubernetes exploram helm charts com falhas misconfigs onde os pods levam cap_sys_admin na maldade.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu sistema não possui mais comandos executores listados no SUID (find ... -perm -4000) de falhas GTFOBins comuns vazios além dos essenciais tipo SU. Mas o CTF de Privesc possui uma cópia estática do famoso `/usr/bin/tar` que possui a CAP_DAC_READ_SEARCH definida oculta na bagagem. O que isso muda pras proteções e o que você atacante pode fazer de estragos letais pra extrair pra sua base e domtar a máquina? E como contornaria isso pro defensivo?"
# Resposta Esperada: O `CAP_DAC_READ_SEARCH` é a "chave mestra da Morte (Disable Access Controls)". Este capability força o Kernel a ignorar completamente TODAS as checagens normais de Read/Search e permissões rwx/ACL do ambiente filesystem para os diretores. Assim, eu como um mendigo da rede posso usar ESSE TARR ESPECÍFICO para gerar um .zip `.tar.gz` e abduzir todos os conteúdos escondidos de Shadow, chaves privadas gpg criptografadas e SSH host keys (/root/.ssh), contornando as partições "600". A defesa estipularia purgar via `setcap -r tar` e refinar logs do syscall `openat` com auditd pra travas via SELinux Labels limitados ao path.
