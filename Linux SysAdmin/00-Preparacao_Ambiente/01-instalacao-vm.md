# Aula 00.01: Preparação do Ambiente - Instalando seu Primeiro Servidor

### 1. ANALOGIA DO DIA A DIA
Imagine que o ambiente Linux é uma casa. Antes de começarmos a mobiliar essa casa (instalar softwares, usuários, regras de porta), nós precisamos do terreno e do alicerce. A **Máquina Virtual (VM)** é como comprar um "lote virtual" dentro da sua própria máquina (o Windows). Ao invés de usar um computador novo *só* para instalar o servidor, você pega uma fatia do seu disco, um pedaço da Memória RAM e diz: "Aqui dentro vai morar isoladamente um sistema Linux".

### 2. O QUE É (definição técnica Senior)
Hipervisores do Tipo 2 (como VirtualBox ou VMware Player) permitem executar múltiplos SOs (Sistemas Operacionais) convidados (Guests) sobre um sistema operacional anfitrião (Host). Em infraestruturas corporativas reais, um SysAdmin Sênior não instala Linux num desktop, mas sim em provedores de Cloud (como GCP, AWS EC2) ou em hipervisores Bare-Metal/Tipo 1 (VMware ESXi, Proxmox). 

Para nossos laboratórios práticos, a instalação de uma VM local tem *exatamente o mesmo* shell e kernel de um servidor na nuvem, garantindo fidelidade de 100% no aprendizado a custo zero.

### 3. SCRIPT / CONFIGURAÇÃO
Nesta primeira aula não estamos executando código no Linux pois não temos ele instalado ainda. Nosso foco é baixar as **ISOs** - as imagens "puras" do sistema - e provisionar.

Recomendo o uso do **Ubuntu Server LTS (Long Term Support)** pelo enorme suporte em Cloud e farta documentação. Contudo, em cada aula que divergir entre RHEL (RedHat/CentOS) e Debian/Ubuntu, apresentarei ambas abordagens (requisito essencial como Sênior).

### 4. COMANDOS PASSO A PASSO

**A. Baixando os Requisitos**
1. Acesse `virtualbox.org` e instale a versão Client para seu Windows.
2. Acesse `ubuntu.com/download/server` e faça o download da **ISO Ubuntu Server** (LTS). *Evite sempre as versões Desktop.*

**B. Criando a VM (Provisionamento)**
1. No VirtualBox, clique em **Novo**.
2. **Nome:** `Lab-Linux-SeniorUbuntu` | **Tipo:** Linux | **Versão:** Ubuntu (64-bit).
3. **Memória (RAM):** Aloque `2048 MB` (2 GB). *Servers puramente CLI rodam até com 512MB, mas 2GB dá respiro na compilação de código futuro sem bater de cara em OOM (Out of Memory).*
4. **Disco Rígido (VDI):** `20 GB`, dinamicamente alocado.
5. **Ajuste de Rede:** Vá em *Configurações > Rede*. Mude o *Conectado a* de `NAT` para `Placa em Modo Bridge` (Bridge Adapter). Isso fará a sua VM ganhar um IP direto da sua rede de casa (ex: 192.168.1.50).

**C. Instalando o Sistema Operacional**
1. Inicie a VM. Em "Disco de Boot", selecione a ISO baixada.
2. Ao carregar a instalação, siga:
   - **Idioma:** Sempre `English`. Nunca instale servidores em português. Como Sênior, buscar erros (logs) do sistema traduzidos no StackOverflow vai retornar zero resultados.
   - **Usuário:** Crie um usuário com senha. Memorize, ele terá poder temporário real no OS.
   - **OpenSSH:** Marque `[X] Install OpenSSH server` quando questionado. Fundamental.

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- **Como saber se funcionou?**
  No final, o instalador pedirá "Reboot". Ele ejetará a ISO e aparecerá uma tela preta escrita `Lab-Linux-SeniorUbuntu login:`. Se você digitar seu usuário, teclar Enter, colocar a senha (ela não aparecerá enquanto digita!) e der Enter, você verá o terminal de boas-vindas completo.

- **Erro comum 1:** *Sistema acusa bloqueio na hora de rodar a VM*.
  A funcionalidade `VT-x` (Intel) ou `AMD-V` está desativada. Para consertar, reinicie o Windows da sua máquina física, acesse a BIOS e ative o *Hardware Virtualization*.

- **Erro comum 2:** *Durante a instalação, o instalador não consegue pegar internet*.
  Isso ocorre se a placa "Bridge" selecionou uma placa de VPN/Virtual do seu Windows sem acesso externo. No VirtualBox, mude de Bridge para NAT temporariamente, reinicie a instalação e lide com a rede depois.

### 6. CONCEITO SENIOR (o "porquê" profundo)
Um júnior provisiona servidores usando o mouse no painel da Cloud (ClickOps).
Um **Sênior** sabe que servidores são **voláteis**, como gado de corte (Cattle), e não animais de estimação que devem ser enfaixados e curados dolorosamente se quebrarem (Pets). Na vida real, instanciar a VM que acabamos de criar hoje manualmente leva apenas 1 linha de arquivo YAML com IaC (*Infrastructure As Code*) como o **Terraform**, ou utilizando scripts do **Vagrant**. Contudo, o Sênior só consegue automatizar porque um dia fez manualmente dezenas de vezes e sabe como o sistema arranca. Você faz na mão para entender, mas no futuro irá focar apenas na automação do processo. 

### 7. PERGUNTA DE ENTREVISTA

**Entrevistador:** "Na sua infraestrutura, por que adotamos primariamente versões **LTS (Long Term Support)** de distribuições Linux no lugar das distros rolling release (novidades em tempo real) para nossa camada de servidores Web?"

**Sua Resposta Sênior:** "A adoção de versões LTS visa garantir a estabilidade máxima do ambiente operacional mitigando o risco das quebras inesperadas que o modelo _rolling release_ introduz. Os servidores do tipo LTS recebem atualizações estritas apenas de patches de Segurança (geralmente por 5 anos) sem mudar as grandes versões dos pacotes estabilizados. Em um cenário on-premise, atualizar agressivamente bibliotecas core sem homologação é a causa raiz da maioria das interrupções de serviço de produção. A prioridade de um servidor web real, diferente de um desktop de programador, não é ter a feature mais nova, mas sim ter zero tempo de inatividade e previsibilidade na superfície de ataque (vulnerabilidades documentadas)."
