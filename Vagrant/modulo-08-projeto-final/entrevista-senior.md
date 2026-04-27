# Simulação de Entrevista Técnica Senior — Vagrant

Este questionário cobre os cenários e conceitos mais desafiadores que você pode encontrar em entrevistas de infraestrutura focadas em Vagrant / Automação / IaC.

---

## 🏗️ 1. Arquitetura e Ciclo de Vida

**P1: Como o Vagrant se difere do Chef, Ansible ou Terraform? Pode substituir um pelo outro?**
> **R:** O Vagrant não substitui Terraform, Ansible ou Chef, ele é complementar. O Vagrant é primariamente um orquestrador de máquinas virtuais para desenvolvimento local. Ele foca no fluxo de trabalho do desenvolvedor (up, halt, destroy). O Terraform orquestra infraestrutura na nuvem/produção. Ansible/Chef são ferramentas de *provisionamento* (gerenciamento de configuração do SO e aplicações). Na arquitetura ideal: Terraform provisiona a nuvem infra-as-code, Ansible configura os servidores lá dentro, e Vagrant cria a "cópia local" das VMs usando as mesmas roles do Ansible que vão para produção.

**P2: O que acontece exatamente por baixo dos panos quando você executa um `vagrant up` e a box não existe localmente?**
> **R:**
> 1. O Vagrant faz parsing e valida o `Vagrantfile`.
> 2. Lê a propriedade `config.vm.box` e consulta a Vagrant Cloud (ou URL configurada em `box_url`).
> 3. Baixa o arquivo `.box` tarball contendo os discos virtuais (ex: `.vmdk`), metadata e Vagrantfile padrão da imagem.
> 4. Expande a box no diretório de cache (`~/.vagrant.d/boxes/`).
> 5. Pede ao provider (VirtualBox, etc) para importar esse disco base como um *Linked Clone* (para economizar disco) ou *Full Clone*.
> 6. O provider cria a VM. O Vagrant configura a rede, shared folders e mac_address no provider correspondente.
> 7. A VM faz o boot.
> 8. Vagrant aguarda a VM responder na rede SSH com sua "insecure private key" nativa.
> 9. Troca a "insecure key" provisória por um par único para esta VM específica.
> 10. Executa os Provisioners seguindo a ordem declarada e suas restrições de ciclo de vida (`once`, `always`).

---

## 🌐 2. Rede (Networking)

**P3: Você tem um ambiente corporativo com restrições rígidas de VPN. Quando a VPN da empresa conecta, sua Private Network do Vagrant cai e o vagrant ssh/synced folders quebram. Como diagnosticar e resolver?**
> **R:** Muitas vezes, o software de VPN corporativo sequestra o tráfego da placa bridge/host-only do VirtualBox manipulando tabelas de rotas do host. As medidas adotadas seriam:
> 1. Inspecionar as rotas (no host): `route print` ou `netstat -rn` no Windows.
> 2. Mudança de subnet: O IP hardcoded (ex. `192.168.0.x`) pode colidir com a subnet roteada da VPN. Trocar no `Vagrantfile` para um range mais obscuro (ex: `10.250.x.x` ou subnet `172.x.x.x` privada não usada na empresa).
> 3. Em vez de redes nativas que sofrem interferência, utilizar puramente `Forwarded Ports` pelo adaptador NAT (`localhost`), já que as VPNs geralmente permitem roteamento pelo adaptador `loopback/127.0.0.1`.

**P4: Qual a implicação de segurança em omitir a cláusula `host_ip: "127.0.0.1"` numa declaração de `forwarded_port` do Vagrant num laptop físico (ex: um Mac)?**
> **R:** Omittir `host_ip` faz o Vagrant instruir o provider a fazer bypass nativo ou *port proxy* abrindo a `host_port` (ex: 8080) em **todas** as interfaces de rede do seu notebook (`0.0.0.0`). Isso significa que quando estiver num café com Wi-Fi público e sua VM rodando, qualquer dispositivo naquele Wi-Fi com seu IP da placa Wireless, vai poder acessar sua aplicação local pela porta 8080, potencialmente alcançando credenciais de testes e abrindo vetores na host machine ou até mesmo invadindo suas aplicações em modo debugger.

---

## 📦 3. Provisionamento e Ansible (Integração)

**P5: O vagrant sobe VMs em paralelo e não garante por padrão uma dependência estrita (ex: 'DB' precisa subir antes de 'Web'). Se formos provisionar com Vagrant + Ansible, como o Senior resolve essa condição de corrida?**
> **R:** O Vagrant de fato não possui abstração de "depends_on" built-in de forma madura. Um Senior resolve através de duas estratégias combinadas:
> 1. Vagrantfile: Pode-se rodar sequencialmente especificando o target (`vagrant up db && vagrant up web`).
> 2. Ansible Playbook: Usando o módulo do ansible `wait_for` que é idempotente. Na role do `web_server`, adicionamos algo como:
>    `- name: "Aguardar banco subir na porta 3306"\n  wait_for:\n    host: "{{ db_ip }}"\n    port: 3306\n    state: started\n    timeout: 300`
> Isso faz com que, mesmo que as VMs subam em paralelo, e o Ansible seja acionado parelelamente, a execução pare nas tasks e espere garantido.

**P6: Qual a diferença entre `type: ansible` e `type: ansible_local` no Vagrantfile e em que caso usaríamos um sobre o outro?**
> **R:**
> * `ansible`: (Ansible Remote) Roda o `ansible-playbook` diretamente a partir da sua **máquina local (host)** e conecta na sua VM via SSH para instalar. Vantagem: menos overhead, VM fica mais limpa. Problema Crítico: Obriga seu host da sua estação a ter Ansible instalado (um tormento crônico no desenvolvimento em Windows, já que Ansible puro não roda nativo exceto via WSL/Cygwin).
> * `ansible_local`: O Vagrant injeta/sincroniza seus YAMLs dentro da própria VM através de Shared Folders, a própria VM baixa os arquivos vitais do Python+Ansible (`apt-get install ansible`), e então o script provision executa de **dentro pra dentro da máquina via ssh iterativo local**. A maior e esmagadora vantagem é a transparência em ambientes em times multiplataforma. Quem desenvolve em Mac, Linux e nativo de Windows usa exatamente isso do mesmo jeito porque tudo passa a depender unicamente do Linux rodando empacotado dentro do VirtualBox, garantindo **imediatez e homogeneidade em multi-OS teams.**

---

## 🗃️ 4. Versionamento de Boxes, Sincronização e Idempotência

**P7: Suponha que temos o código usando NFS (`type: nfs`) na máquina desenvolvedora A (Mac/Linux), mas quando outro dev tenta dar vagrant up a partir do Windows, o comando falha completamente. Como projetar o Vagrantfile de forma a funcionar multi-plataforma com alta performance?**
> **R:** O Vagrantfile é Ruby puro. Em vez de declarar strict dependencies, inspeciona-se dinamicamente a plataforma do HOST em tempo de execução:
> ```ruby
> Vagrant.configure("2") do |config|
>    if Vagrant::Util::Platform.windows?
>       config.vm.synced_folder ".", "/vagrant", type: "rsync",
>            rsync__exclude: [".git/", "node_modules/"]
>    else
>       # No Linux/Mac roda o veloz NFS
>       config.vm.synced_folder ".", "/vagrant", type: "nfs",
>            mount_options: ["nolock", "vers=4", "udp", "noatime"]
>    end
> end
> ```
> Nós também não usamos as Shared Folders do VBOX nativo de jeito nenhum nestes casos por causa da terrível penalidade de file cache locks (onde arquivos estáticos recusam alteração na memória/editor até o webserver fazer reboot ou o disco virtual fazer buffer re-sync local).

**P8: Seu provisionador de script de bash possui: `git clone https://... && npm install && npm start`. Qual o problema grave se o usuário der um `vagrant provision` dias após instalar?**
> **R:** O script feriu o princípio basilar da **idempotência de provisionadores**. Quando for chamado duas vezes pela pipeline contínua ou no reboot de reprovision local (`vagrant reload --provision`), ele vai tentar fazer o clone de repo por cima do diretório que o clone já existe, vai jogar a pasta inteira num stderr (Operation directory already exists) resultando num Shell error não-código-zero parando todo o deployment process prematuramente. Uma forma de fixar usando `bash` sem o Ansible seria checar a pré-condição `if [ ! -d "/app/.git" ]`.
