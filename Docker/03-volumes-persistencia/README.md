# Módulo 3 — Volumes e Persistência

Até aqui, vimos que quando o processo 1 (PID 1) morre e executamos `docker rm`, tudo que aconteceu na vida daquele container vira pó. Como rodar bancos de dados sem perder clientes? Olá, Volumes de Persistência!

---

### 1. ANALOGIA DO DIA A DIA

**O Pen-drive no Computador Lan-House**
- O **Container Efêmero**: É um computador de Lan-House. Quando você encerra sua sessão de aluguel por 1 hora e reinicia, ele formata o estado para como era de fábrica e deleta os vídeos que você baixou nele.
- O **Volume (Armazenamento Persistente)**: É um Pen-Drive (HD Externo). Você escuta sua música, altera e desliga. O PC da Lan-House apaga sua própria memória e se reinicializa virgem, mas o Pen-Drive guardado no seu bolso guarda o histórico de tudo que você salvou. Você senta em outra máquina noda Lan-House no outro dia (dá *docker run* em outro id), espeta o mesmo pen-drive, e sua música tá salva de onde parou.

---

### 2. O QUE É (Definição Técnica Senior)

A máquina de OverlayFS dos containers trata armazenamento como imutável e volátil. Há 3 modos oficiais para "furar" essa bolha da memória read/write efêmera ligando uma pasta de dentro do container nativamente em uma pasta do seu HD físico da Máquina.

1. **Bind Mounts**: O modo antigo/Raiz. Mapeamento bruto onde informo a pasta ABSOLUTA do Linux host batendo numa pasta de dentro do Container.
2. **Named Volumes (O Ouro)**: Como o nome sugere. Não me importa onde ele fica no meu HD, o próprio **Daemon (Docker)** controla, gerencia o ciclo de vida e onde isso salva no file system físico `/var/lib/docker/volumes/`.
3. **tmpfs Mounts**: Um volume em RAM puramente para super-alta-velocidade que morre na hora que o container desliga, bom pra chaves API que não podem jamas tocar num Disco HD Físico.

---

### 3. ARQUIVOS COMENTADOS

Abra os seguintes arquivos para entender o escopo do código:
- `01-bind-mount.sh`: Injeta código da sua máquina para dentro de uma imagem genéria em runtime (uso excelente pra Desenvolvimento/Live-Reloading).
- `02-volume-nomeado.sh`: Provisionamento robusto no qual a máquina assume a gestão de um banco Postgres.
- `03-bind-vs-volume-compare.txt`: Um cheat-sheet (Cola) rápido comparando comportamentos na visão do arquiteto Sênior para consulta corriqueira futura.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: Listando e Inspecionando**
`docker volume ls`
* **O que faz**: Lista todos os "Named volumes" geridos ativamente pelo Docker no momento que podem ser reusáveis em Containers.

**Comando 2: Criando avulso**
`docker volume create meu_banco_16_prod`
* **O que faz**: Aloca logicamente no `docker info` um recurso passivel de ser *Atachado* no futuro `-v`.

**Comando 3: Destruição (Limpeza)**
`docker volume prune`
* **O que fazer se der erro (HD cheio?):** Com o tempo, as pessoas derrubam containers bancos de dados antigos com o `-rm` mas se esquecem que **Volumes NUNCA morrem automáricamente se o container for apagado**! (É uma feature maravilhosa de segurança). Ele vai largar o "Pen Drive" la na pasta do Daemon comendo o disco para sempre. Esse comando Prune desobstrui o caos em HDs com Warning de 100% matando "todo pen drive que não tem nenhum container vivo espetado nele no momento". 

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Se eu fizer isso vai falhar? `docker run -v .\minhapasta:/app node` ?
  **Troubleshooting Win/Mac**: Quase certeza. Arquiteturas Win/WSL e Mac possuem problemas infernais com `Bind Mounts` absolutos entre o Windows C:// e a virtualização do FileSystem do Linux. Use sempre a expansão da "Pasta atual rodando do terminal" em Bind Mounts: `-v $(pwd):/app` (Linux/Mac) ou `-v ${PWD}:/app` (Powershell). E prefire sempre *Named Volumes* quando for para Banco de Dados para evitar corrupção de File-Locks IOX12 do Kernel cruzado!

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

O que de pior pode acontecer num Banco em Produção usando **Bind Mount**?
*R: Corrupção do BD de Permissões.*
O Bind Mount usa o User/Group Owner do HOST DA MÁQUINA para gerenciar. Mas um container do NGINX internamente está sendo tocado pelo user `www-data` (id numérico 101) e você mapeou sua pasta do desktop root do Ubuntu na pasta `/var/log/nginx`. Se os numerios de IDs de ambos os sistemas (De Dentro do isolation vs Fora da máquina) derem missmatch, ele corrompe, dá access denied, vira read-only e capota as configs todas de chown/chmod da aplicação.
**Named volume** engole as permissões UID do coitadinho do container, resolve a mágica no driver /var/lib do daemon e garante que o postgres 999 escreve com permissão real nele mesmo em host ou AWS, blindando a dores de cabeças clássicas do SysAdmin Sênior.

---

### 7. PERGUNTA DE ENTREVISTA

**Pergunta:** A infra pediu para adicionarmos um parametro de segurança no Nosso Named Volume, informando que a App Web Front só pode "Ler" as pastas que mapeei, se tentar escrever, o docker recusa e blinda o Host de ataques e injection na pasta. Como fica?
**Resposta Sênior:** É só adiconar o suffix `:ro` (Read Only) na sintaxe final da flag de bind.
Exemplo: `docker run -v $PWD/html:/usr/share/nginx/html:ro nginx`. Desta forma, o que estiver rolando lá dentro da engrenagem do Isolation não sofre chance remota de propagar vírus de deleção em cascade na própria máquina host local.
