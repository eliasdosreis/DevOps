# Módulo 0: Preparação do Ambiente
## Aula 04 - Estrutura do Sistema de Arquivos Linux (/proc, /sys, /etc)

### 1. ANALOGIA DO DIA A DIA
Imagine a sua casa como uma empresa. O andar de cima (Diretoria) toma as decisões e define orçamentos, mas é no subsolo (sala das máquinas, fiação exposta, bombas de água) que a empresa realmente funciona fisicamente de forma perigosa e ruidosa. No Linux, a regra central arquitetural de sua gênese era: **"Tudo é um arquivo"**. Portanto, quando você precisa conversar com o gerente (o kernel, o hardware), eles não mandam alertas complexos; eles deixam "folhas de papel" nas gavetas em corredores assustadores no subsolo mágico, onde ler esse papel consome e mapeia a memória viva ou reativa do hardware. O sistema não é apenas "disco rígido" cheio de fotos; é uma interface de texto viva para a Alma da máquina (o Kernel), disposta em diretórios de árvore previsíveis.

### 2. O QUE É (definição técnica Senior)
A arquitetura Hierárquica Base de Sistemas de Arquivos (FHS - Filesystem Hierarchy Standard) impõe onde cada artefato deve existir. E mais importante na segurança são os Pseudo-Filesystems:
- **`/etc`**: Base estática. Todos os arquivos texto de configurações, regras de senhas, boot e serviços habitam em /etc (é o grande álbum de receitas).
- **`/proc`** (Process Information): O Pseudo-filesystem da Vida. Não há nada gravado no seu disco SSD quando você entra nesse lugar. Ao ler com um `cat` um arquivo lá, o Kernel responde a você despejando memória da RAM fresca e dados da CPU ou processo instantaneamente de forma textular. Nele vive tudo sendo executado por PID (Identificador de Processos) ou do sistema (`/proc/cpuinfo`, `/proc/version`).
- **`/sys`**: Mapeamentos de sysfs; um export de artefatos quentes voltadas a *Drivers* e tunagens nativas do Subsistema/Kernel (placas de rede de barramento, estado das baterias).  
- **`/dev`**: (Device F.) A abstração que provê o acesso aos discos brutos como descritores (`/dev/sda`).
- **`/tmp` / `/dev/shm`**: Diretórios de gravação para usuários mortais, muito usados por malware para deixar executáveis furtivos e voláteis.

### 3. SCRIPT / COMANDO COMENTADO

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Um mini walk-trough script interativo e inofensivo para sondar 
# e extrair dados vitais e processuais de sua máquina hospedeira
# lendo em tempo real árvores mágicas de `/proc` e `/etc`.
# ============================================================

#!/bin/bash

# Extrai o nome/versão do SO do mapa central de identidades
echo "[!] Qual Linux é esse real:"
cat /etc/os-release | grep "PRETTY_NAME"

echo -e "\n[!] Kernel Version (Muito sensível pra CVEs!):"
cat /proc/version

echo -e "\n[!] Comandos inteiros de um processo em execução atual (ex PID 1 que orquestra tudo, o systemd/init):"
# O campo cmdline em proc guarda exatamento a string q invocou ele em memoria. O tr \0 converte espaços vazios a enter visual
cat /proc/1/cmdline | tr '\0' '\n'

echo -e "\n[!] Informação do Hardware das interfaces (vNICs virtuais):"
ls -la /sys/class/net/
```

### 4. PASSO A PASSO
**Passo 1:** Dê `cd /etc` e tente procurar onde o software de SSH fica configurado: `ls -la | grep ssh`. Provavelmente você verá um diretório inteiro pra ele. Entre nele.
**Passo 2:** Vá pro `/proc` com `cd /proc`. Se você der `ls`, verá uma selva de pastas amarelas numéricas.
**Passo 3:** Descubra o código (PID) da sua própria sessão de bash rodando o comando genérico mágico: `echo $$`. Memorize esse número (digamos 1204).
**Passo 4:** Entre na pasta `cd 1204` dentro de proc.
**Passo 5:** Dê `cat environ`. Ele revelará, daquela sessão Bash, toda estrutura secreta em variáveis daquele exato momento. É assim que atacantes que tem acesso root localizam senhas injetadas em docker `DB_PASS="secreta"` expostas aos outros nos logs ambientais. `cat /proc/PID/environ`.

### 5. VERIFICAÇÃO E TROUBLESHOOTING
- **Você tenta ler um `cat /proc/PID/environ` e toma "Permission denied".** Isso é o clássico controle de acesso. Apesar das pastas serem listáveis, ler a memória viva e ambiente de outras contas não autoriza PIDs que possuam uid diferente do dono origil / root. A própria tentativa fica monitorável e é sinal de intrusão lateral.

### 6. CONCEITO SENIOR (o "porquê" profundo)
Malwares baseados em Kernel (Rootkits LKM - Loadable Kernel Modules), como o diamorphine e Reptile ou falhas, baseiam sua magia em corromper, camuflar, forjar, e "desengatar" processos das chamadas do /proc. Essencialmente, se o seu Linux tem uma rotina e você digita `ps aux`, o `ps` e top estão internamente listando as pastas dentro do `/proc`. Se um atacante faz enganar em baixo nível a VFS do processo `/proc` pra "pular" o número dele, ele fica cronicamente invisível aos detectores usuais. Sêniors não olham apenas `/var/log` (podem ser apagados), mas investigam em `/proc/sys` tunagens TCP ilícitas (IP Forwarding ativado que não estava), e inspecionam a memória volátil na via `cat /proc/kmsg`.

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Durante seu Response plan (IR), Você pegou um rootkit/malware Linux no meio que ainda está logado e injetando, e sem querer (ou intencionalmente do malware), o binário nativo para listar diretórios (o comando "ls") *foi apagado permanentemente* (`rm -rf /bin/ls` ou de `usr/bin/ls`). O Bash funciona. Como listar o que habita dentro da pasta atual de onde o bash se encontra que você está?"
**Resposta Esperada:** No paradigma Linux, as wildcards ou o expansor embutido (builtin) do Shell que interpretam. Então o simples ato do comando nativo universal bash `echo *` preencherá instantaneamente no terminal uma lista contígua de todos os binários, arquivos de texto ou pastas no atual caminho em execução sem a necessidade e invocação binária e sem uso do `ls`. Alternativamente, a expansão cega e mágica pode ser contruída usando um looping for interativo em linha. `for f in *; do echo $f; done` que recria o `ls` na ausência dos binários.
