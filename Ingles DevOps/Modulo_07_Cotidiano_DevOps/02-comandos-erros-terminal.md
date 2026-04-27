# Módulo 7 — Inglês no Cotidiano DevOps
## Aula 02: Comandos Gerais e Erros Padrão de Terminal Unix

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você está roteando terminal num Pair Programming. O Dev sênior fala: "Grep for exactly error inside the var-log directory, don't use the dash R switch". O vocabulário "Dash" (-), "Pipe" (|), "Slash" (/), "Quote" ("") são os dentes e unhas de quem opera Linux por CLI todos os dias. 

**2. O QUE VOCÊ PRECISA SABER (objetivo da aula)**
Comandos, travamentos e letras de argumentos na sintaxe Linux (Bash/Shell) e do Terraform possuem pronúncias puras e nomes gringos que mudam sua usabilidade oral.

**3. OS TERMOS E CARACTERES MAIS DIÁRIOS**
* **Dash ou Hyphen (-):** Em shell arguments se fala MUITO *Dash*. O `-v` a gente fala "Dash V". O `--help` é "Dash Dash Help". 
* **Pipe (`|`):** É o tubo para canalizar outro comando. ("Grep that and **pipe** it to awk").
* **Slash (`/`) e Backslash (`\`):** Para falar diretórios absolutos, fale Slash (`/var/logs`).
* **Star / Wildcard (`*`):** Usa-se pra selecionar de maneira selvagem geral. ("Just assign wildcard star permissions").
* **Hash / Pound (`#`):** Representa root em prompt, ou comentário num yaml.

**ERRORS COMUNS EM INGLÊS EXPLICADOS (MENSAGENS LOGS)**
* **"Permission Denied"**: Erro matador Linux de acessos ou Chmod sem +x. Em inglês vc relata: "I'm getting a permission denied error."
* **"Command not found"**: Erro de path mal setado localmente nas variaveis PATH linux. "The bash complains that NPM is a command not found."
* **"Connection Refused"**: Geralmente a porta bateu lá, mas a máquina encerrou e derrubou pela config de FW/Security Groups.

**4. VOCABULÁRIO TÉCNICO DE ERROS**
| Expressão do bash | Significado Prático | Exemplo de relatar em call |
| :--- | :--- | :--- |
| **It hangs (Hanging)** | Travado/Carregando infinito | "When I run apply, the terminal just **hangs**." |
| **It crashes** | Capota, encerra do nada e devolve pro bash | "The pod keeps **crashing** directly." |
| **To pipeline (Pipe it)**| Tubos lógicos entre comandos | "Just **pipe** the output to a text file." |

**5. MINI DIÁLOGO REAL**
*[Pair programming - Screen Share]*
**Lead Engineer:** Can you check what's inside the Nginx log folder?
*(Pode bater um check dentro dos logs de psta do Nginx?)*

**You:** I tried running `cat` there, but it hangs.
*(Eu tentei rodar um cat lá, ma a tela "pendura/trava infinita").*

**Lead Engineer:** Pass the dash F argument, like `tail dash F`, and pipe it to grep searching for 'error'.
*(Passa o argumento Dash F (-f), assim `tail -f`, e 'encanota / passa no tubo pipe' com grep procurando pro error).*

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"Traço Veh"** (-v) ou **"Menos Erre"** (-r).
✅ **"Dash V"** ou **"Dash R"**. Se for hífen duplo (--), **"Double dash"**. 

❌ **"O sistema travou." (System locked).**
✅ **"The terminal hangs."** (Pendurou infinito no processo da cli sem sair dele). 

**7. FRASES PARA MEMORIZAR HOJE**
🗣️ **"When I run the command with the dash flag, the terminal just hangs."**
*(Quando testo rodar o comando usando a flag do Dash '-' o terminal apenas congela sem retorno).*
