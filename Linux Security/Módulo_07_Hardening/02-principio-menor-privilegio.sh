#!/bin/bash
# ==============================================================================
# Módulo 7: Hardening e Remediação
# Aula 02 - Princípio do Menor Privilégio (Containers e Jails)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Você chama um Eletricista pra arrumar o quadro de luz do subsolo da tua empresa.
# A Abordagem Errada (Super Privilégio): Você dá a ele as Chaves Mestras de Todo o prédio. 
# Ele pode arrumar a luz e ir embora (o app rodar bem), OU ele pode subir e xeretar o seu Quarto e cofre enquto vc nao ve.
# A Abordagem Sênior (Menor Privilégio): Você coloca ele DENTRO DO SUBSOLO apenas, Tira a maçaneta da porta pra 
# que ele NÃO SAI DO SUBSOLO D QLQR FORMA (Chroot Jail). Deixa lá APENAS duas ferramentas de 
# choque alicates e tira até furadeiras (Path restrito). Ele vai reparar o negócio, ms se ele surtar pra invadir a casa, 
# as paredes de acrílico do jaula não dão as paths/comandos p ele quebrar nem a janela.
#
# 2. O QUE É (definição técnica Senior)
# O "Least Privilege" impõe que um Processo/Usuário seja bootado APENAS com Euid fraco "www-data" 
# e que seus escopos de Visão VFS sejam podados pelo sistema via **Chroot Jails**, **Rbash** 
# ou limitadores Cgroups Containers base.
# 
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

echo "[+] Demonstração de Defesa - Criando um Usuário Restrito a Uma Jaula Shell (Rbash)..."

# Criando user q n tem bash original interativo `bin/bash`
# sudo useradd -m visitante_limitado -s /bin/rbash 

# O Restricted Bash (rbash) é uma barreira de shell "Boba". 
# Ele simplesmente desabilita o comando `cd` (Change dir). Ele nao podera navegar por pastas.
# E ele desabilita variaveis PATH. Vc entao limpa os comandos disponiveis dele
# e cria SoftLinks "ln -s" de utilitarios inofensivos q a empresa q q ele use, tipo UM script `reiniciar.sh` ali dentro so!

echo "\n[+] A Verdadeira Jaula Carcerária Chroot (Fake Root Path):"
# o comando CHROOT (Change Root) altera Padrão " / " para enganar o binário.
# sudo mkdir -p /var/jail/
# sudo mkdir -pv /var/jail/{bin,lib64,lib/x86_64-linux-gnu}

# Se quisermos q o sujeito use "ls", eu TEREI que copiar manualmente o /bin/ls DE VERDADA DO PC PRO PRISIONEIRA BURACO e TODAS as libs q ele usa q vi no comando `ldd` do ls!
# cp /bin/bash /var/jail/bin/
# cp /bin/ls /var/jail/bin/ 
# chroot /var/jail /bin/bash  <-- Esse comando Inicia o mundo la dentro. Se o prisoneiro der cd /ele ira pra raiz do jail que finge q eh HD dele original, ele nunca vera ou podera chegar na raiz do OS verdadeiro! (O Pai primario do Container Docker! =D)

# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: No dia a dia, Jails de Bash limitados são usados pra usuários de FTP Externos ou "Git Viewers".
# Passo 2: Mas pra serviços Corporativos? O principio diz pra não roddarmos de root (AULA01 Capabilities).
# Passo 3: Vamos no arquivo global de inicialização `vim /etc/systemd/system/meu_api.service`.
# Passo 4: No bloco [Service], um Engenheiro Master escreve o endurecimento brutal "NoNewPrivileges=yes" e o "ProtectSystem=full". 
# Passo 5: Essa mágica nativa do Kernel Systemd obriga que NENHUMA tentativa de invadir aquela API q rode em python poderá abusar flag bit de SUID root pra hackear (No new privileges desativa setuid sys_calls pra o node inteiro filho!)
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Problema: Sysadmins montam SFTP (Server FTP over ssh) com Chroot no `/etc/ssh/sshd_config` forçando usuários a `/home/jailsftp`. Ao tentar logar FTP, toma "Broken Pipe Connection Closed by Server". Solução: As jails SSHD exigem restições paranóicas de Kernel Unix; A pasta raiz do chrooot configurada TÊM QUE pertencer Absolutamente 100% à root:root e TER chmod Max 755 sem Write pra os outros inclusive do grupo, senão o sshd dropa a sessão crente q o host jail já estava malvado desde seu genesis por writable missconfig dir da / !
#
# 6. CONCEITO SENIOR (o "porquê" profundo)
# "Se Croot/Jails são Tão Bons Ocultando raizes /etc/shadow e pastas do host original, Por que Hackers saem da Jail de Cpanel SFTP nos provedores velhos?". Um exploit clásico "Chroot Escape" ocorre programando diretórios aninhados infinitos em memoria C. Se o usuário Restrito Dentro da cadeia tem Permissäo de compilar e rodar arquivo C usando root-priv lá de dentro, o Hacker dá um call `chroot("nova_pasta")` (chroot_within_chroot). Essa ação joga o diretório atual corrente Pointer pra fórum das tabelas restritas do kernel. Depois o dev mete varios `chdir("../../../../../")` pulando dezenas de parent directories subindo a arvore... Quando ele soltar `chroot(".")` dnovu pra fixar a descida, ESTARÁ NA BARRA NATIVA ` / ` REAL FÍSICA DO HD QUEBRANDO O ISOLAMENTO PRISIONEIRO. Docker escape e Jail escape derivou dessa magica falha logica C CWD ptr kernel unix!
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu sistema de DevOps rodando WebSockets Node no systemd de produção exige de facto que NÂO deve rolar Root privilege de maneira nhma em SystemD, ele usa `User=appuser`. Como tu usa tags hardening modernass do Systemd pra garantir que mesmo q ele escape do bash e vire RCE pro hacker, o hacker n consiga DELETAR OU APAGAR nem 1 byte de log e arquivos do diretório `/home` que não eram da sua API?"
# Resposta Esperada: O super trunfo de mitigação SystemD moderna possui a aba Sandbox Diretives. O admin injeta `ProtectHome=yes`. Instantameamente, pro processo Node pai de api, o `/home`, `/root` e `/run/user` se tornam inacessiveis lógicos pra API e pra qalqr shell q for hackeada dele. Tmb usa-se `ProtectKernelTunables=yes` q blinda ele de dar sysctl e mudar ttl do ping como na aula 03 passada. O Systemd Containerzinho vira um Shield fortissimo usando mount-namespaces automáticos transparente ao dev.
