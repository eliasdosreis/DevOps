# Módulo 4 — Redes Docker

Aqui reside o terror de 90% dos currículos. Se um container é isolado (namespace de rede ativado), como a Aplicação Node envia dados pro Banco no Postgres? Como seu Celular na mesma rede Wifi entra nesse site? 

---

### 1. ANALOGIA DO DIA A DIA

**A Central Telefônica**
- **Sua Máquina Local/Wi-Fi (Host)**: É o mundo exterior, as ruas com telefones públicos.
- **Rede Default `bridge` do Docker**: É o sistema de segurança antigo. Quando o container nasce, ele ganha um número de ramal aleatório (IP 172.x.x.x). Se o container Node quiser falar com o Banco, ele precisa saber o número exato do IP-Ramal do BD. E se o Banco cair e reiniciar? Nasce com um novo IP e quebra o site... péssimo.
- **Rede Custom `bridge` (DNS Nativo)**: É o PABX moderno corporativo da firma! O Banco se cadastra como "banco_prod". Se o Node pegar o telefone e gritar "BANCO_PROD", a central do PABX ouve que foi um nome de domínio e descobre na hora e resolve sozinho pro IP daquele minuto!

---

### 2. O QUE É (Definição Técnica Senior)

A abstração de rede atua injetando interfaces virtuais (`veth pair`) entre o Host e o Container. O Docker Engine possui um *CoreDNS* embuditto incrivelmente otimizado.

- **bridge**: Rede criadas default. Containers se falam, mas *apenas por endereço de IP interno mutável*.
- **user-defined bridge**: (A.K.A custom networks). Permite DNS Resolution Name (Você pinga o nome do container e ele acha o brother do outro lado na msma rede).
- **host**: Destrói a ilusão de Namespace de rede. O Container se acopla direto na porta nativa da máquina física real. (Perigoso, mas super rápido, ignora NAT Routing e Port-Forwarding).
- **none**: Loopback only. Uma cela solitária para containers super isolados. Ninguém entra, eles não saem pra internet.
- **overlay**: A rede que viaja pelo ar e conecta Servidor fisíco e Servidor num Datacenter num túnel seguro. (Assunto para o Swarm!).

---

### 3. ARQUIVOS COMENTADOS

Abra e acompanhe:
- `01-default-bridge.sh`: Mostra como na rede Default as coisas são limitadas dependentes de IP.
- `02-custom-bridge-dns.sh`: A criação do DNS que nos livra as amarras de IP estático.
- `03-publish-ports.sh`: O ato formal de `-p` de expor do isolamento pra FORA pra sua máquina pelo Proxy nativo do Daemon.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: Listando Redes**
`docker network ls`
* **O que faz**: Exibe as 3 redes in-deletáveis que vêm instaladas de fábrica (`bridge`, `host`, `none`) e as suas próprias personalizadas.

**Comando 2: Inspecionando Cabos conectados**
`docker network inspect bridge`
* **O que faz**: Entra dentro do switch lógico. Lhe informa o range do DHCP interno (Ex: 172.17.0.0/16) e no bloco "Containers", lista quem tá rodando agora com os cabos de rede atachados nela! O Debug definitivo para Senior.

**Comando 3: Destruindo as lixeiras de Switch**
`docker network prune`
* **O que faz**: Similar a de volumes, toda custom network que criamos e fica com zero cabos ligados é varrida da memória para economizar range de IP do Kernel.

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Coloquei 2 containers rodando em uma Custom Network que criei porem não estão se "pingando" usando o nome um do outro. Por que?
  **Troubleshooting**: Em 99% das vezes é porque faltou atrelar o nome explícito ao inves da hash louca pra registrar no DNS do daemon! Sempre ao subir algo em modo network passe a flag explicitamente com `--name meu_banco`. O DockerDNS só resolve magic names baseando-se unica e exlusivamente pelo aliasing do parametro `--name`. 

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

Se a Docker Network Default (`bridge`) não suporta DNS via network Names (e precisa roletar IPs fixos), por que não podemos apenas habilitar o DNS NELA pra todo os usuários novos inves de forçar eles a "criar uma nova e plugar" sempre?

**R: Legacy e Backward Compatibility.**
No início, o sistema de Docker tentou usar um flag terrível chamada `--link`. Isso era tão estático e ruim que quebrava em sistemas reativos. O Docker arquiteturou as User-Defined-Bridges para resolverem perfeitamente. Contudo, milhares de empresas no planeta criaram infraestruturas baseadas na rede "bridge default" usando scripts shell hardcore manipulando IPTABLES nas origens. Você não pode, nunca, modificar ou "atualizar comportamentos nativos" na base default sem arriscar crash global de retrocompatibildade. Por isso ela funciona hoje identica há 10 anos atrás. E todo dev moderno sabe que a primeira coisa ser feita antes de um `run` complexo é o `docker network create`.

---

### 7. PERGUNTA DE ENTREVISTA

**Pergunta:** Eu digito a URL no Browser... a Porta 80 atende no Host (Meu PC). Na pipeline pra Porta 80 do NGINX no Container, isso vira o inferno. Como o Kernel sabe que tem que enviar a request pro "processo fantasma" do Container se os dois estão em redes e namespaces diferentes?
**Resposta Senior:** Isso se chama `Userland Proxy/IPTABLES` (Docker NATting). Quando passamos a flag de bind ports `-p 8080:80`, o `dockerd` (Daemon) abre um Socket real ouvindo na porta "8080" da sua Placa de REDE Oficial (Loopback/eth0 do Host). Ele joga regras dinâmicas pesadas via ROOT no Firewall interno Linux (IPTables) falando: *"Todo trafego que bater de fora pra dentro na 8080 da porta do meu Desktop físico vai dar routing/NAT traduzindo silenciossanete para o IP 172.17.X.X daquele container na porta 80"* . Isso é complexo mas imperceptível pelo usuário.
