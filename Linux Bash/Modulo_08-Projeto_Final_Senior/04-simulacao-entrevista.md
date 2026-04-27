# Simulacro de Entrevista Técnica: DevOps e Linux / Bash Senior

Este documento foi gerado para testar seus conhecimentos puros absorvidos em todo o treinamento. Você não precisa responder com as chaves do Linux e decoradas. Responda do Ponto de Vista Físico e Arquiteto do Kernel POSIX. 

---

### Pergunta 1: O Silêncio Total dos Inocentes
**O Cenário:** Você montou um cronjob para realizar um deploy `/opt/scripts/subir_banco.sh` todo dia a meia-noite. O usuário do cron é root. Quando chaga o dia, o script não sobe o banco. Ao inspecionar os logs do seu `/var/log/messages`, não há aviso de crash do comando Cron (está rodando OK). Ao olhar dentro do bash script `subir_banco.sh`, a flag global `set -e` não está declarada no topo! A primeira linha do script é rodada: `cd /pasta_montada_nfs/`. A linha abaixa roda o formador: `rm -rf ./dados/*`.
**A Pergunta Branca Sênior:**  
*Considerando que a pasta de rede `nfs` falhou misteriosamente em se montar na placa de rede naquela madrugada. O que acontecerá de fato e consequência brutal no ato de rodar o seu crontab naqueles milissegundos sem o `set -e` na cabeça? Pra onde foi o ERRO visual?*

> **Gabarito Mestre:**  
> Ao tentar dar o `cd /nfs/`, o diretório não existe porque o montador falhou. O `cd` joga um ERRO de texto stderr 2 (Directory Not found), E devolve o Return Code '1' IPC de Error fatal de comando ao kernel. PORÉM, como o SCRIPT NO TOPO foi escrito com a ausência do estrito mestre disciplinador `set -e`.... a Engine Bourne Bash engolirá passivamente a falha/vergonha (status de erro) e irá CONTINUAR executando a engrenagem letal da linha imadiatemnte debaixo de forma cega nas costas! E a linha letal debaixo era O `rm -rf ./dados/*`....  
> Como O `cd` falhou e a engrenagem nunca alterou o Pointer do Current Working Directory na RAM da thread, O BASH executou O `rm -rf ./*` NA PASTA EM QUE ELA ACORDOU RODANDO O SCRIPT DO CRON (Que provavlemente seria o Dir home principal `/root/` ou Root Raiz do Cron dependendo do env/chroot default). O Bash irá triturar silnciosamente sem dó toda a pasta base vitalícia do computador, limpando seus arquivos raízes como The Destroyer! Deletaria toda configuração sem piscas os olhos. E pra coroar o bolo: a saída erro vermelho que o "cd deu erro" na hr... evaporou da exstência, sendo ejetada no lixo dos MailBoxes Root local unix Spools, e não na sua interface e nenhum sysadmin viscou nem rastro.  

---

### Pergunta 2: A Morte Sub-Silente e a Escoria no Fundo
**O Cenário:** Nós rodamos o formidável comando: `cat osos.txt | grep "LINUX" | awk '{print $1}' > meu.txt`. 
**A Pergunta:** 
*Você botou a algema disciplinadora global `-e` (`set -e`) na cabeça do seu script. O arquivo `osos.txt` foi corrompido fisicamente na RAM num Cluster Block falho SSD ou deletado antes do run pelo seu sócio. Ao rodar a engrenagem, o Seu `cat` morre com status de falha! E o The Set -e da Bash morre tb? Seu Sript Master Bash inteiro aborta ou continua executndo tudo pra baixo pq n falhou? E pq diabos ele continuaria se the Set -e jura matar scripts inteiros quando acha errorcodes 1?*

> **Gabarito Mestre:**  
> A maldição do "Engolideiro de Cano"! O Status Array da Pipe List Bash! 
> The Command Bash avaliou the RC Result Final não pelo CAT, E sim a partir de toda linha de tubagem (Pipe String `|`). The Kernell System do POSIX Bash default assinala que UM PIPELINE INTEIRO `A | B | C` possuirá O SEU RESULTADO EXIT STATUS FINAL DEFINIDO puramente, e unica exclusivamente baseado no Último Soldado do comando da Extrema Direita (No caso the `AWK` parser the end).  
> Os dois soldados do inicio (The cat the fail) morreram e berraram `Return 1 Error`, que desceu no pipe c/ The grep Vazio (Pq cat deu nulo/null fd stream)... The Awk processará Input nulo e silente... E Como Ninguem proibiu o awk de processar Empty inputs, the AWK terminaliza suaa runC e emite `EXIT 0 Success`!   
> Então a Linha Pipe inteira devolve = Zero Pro `$?`. O Master disciplionador `set -e` olha a var `$?` recem gerada inteira.... ve 0.... e fala: "Sucesso perfeito a tubulação the water! Bora O Script pra Próxima linha!!!". Ignorando fatalmente q o comeco deu C-crash. O Certo E Seguro SysAdmin p DevOps The Linux em PipeStreams Extensivos OBRIGA O MODO DE PIPEFAIL no arranque header (`set -euo pipefail`). O The `pipefail` liga the "Inversao de Sentido Logico no Vector Result": Se ALQUÉM, literalmente 1 gota entre os canos 1 ao 5 morresse gerando Status>0, O `$?` Global de final de linha espelhará ESSE DEFEITO ATOMICO mascarado lá the inicio, garantindo a morte correta letal do script sob avaliacvão do `-e` Master.  

---

### Pergunta 3: The Forked Zumbis de Memória e Pipes Enclapsulados
**O Cenário:** Você amarra e loopa dados com While!  
```bash
NUM_ERROS=0
cat logs-do-sistema.txt | while read linha_log; do
   if [[ "$linha_log" == *"FATAL"* ]]; then
       ((NUM_ERROS++))
   fi
done
echo "Você tomou O TOTAL BRUTO DE $NUM_ERROS Erros de Crash hoje Sre."
```

**A Pergunta:** 
*O Sr SRE testou o arquivo logs. Ele tinha O FATAL explícito lá dentro 20 vezes escritas em sang. O Script Roda até o the fim. A Conta da echo PrintThe Total de Erros Fatal Printa literalmente o que? E o porque diabos não funcionaria se tem lido O String no The While the Array?!*

> **Gabarito Mestre:**  
> Printa Zero Brutal!! `0` !  
> E O Maledito Bash do SysAdmin "comeu memória invisibilidade". Ao injetar the command `cat ` E usar a Conexão Pipe ` | ` em direção ao loop iterativo Mestre THE WHILE.... the POSIX Engine Kernel FORÇA QUE A ESTRUTURA The While e O seu BLOCO INTEIRO The While fiquem enclapsulados fisicamente contornados rodando debaixo the um `Fork()` Sub-processo Kernel.  
> Uma the the leis universais Kernel da engine Bash e RAM States é The Unidiectional memory Allocation de processos Filhos VS Pais!! Filhos LÊEM variaveis exportadas de the Páis (Herdam), Mas Filhos NUNCA, NUNCA empurram de baixo / esreveem no Parente Mestre (Reverse Inheritance Forbbiden the memory protect OS).  
> Quando The Sub-Process filho BASH (The While) leu tudo lá dentr, the Variable dele the Fork clone Local the `NUM_ERROS=0` subiu os numeros maravilhosamenre the 1, 2 ate 20 the RAM isolated thele....  
> MAS, Quando the While Termina (Fim do file)... The pipe cessa A Vida, the subprocess Fork Engine BASH The While MORRE the Trash. Toda A Var the "20" the Ram Child Local morre com the Trash collect! Sem Retornar nada the the main the echo fora do scope que estva congelado na thread the the parent `0`. A Forma Certa e Sem Fork para amarrar laco the loops em files pesados e com The String I/O the Memory the Variaveis Mestre do State C é usando o the File Descriptor redirect de Stdin na RAÍZ O FILE The The loop (o desvio puro the arquivo local the kernel Input ` < ` The In). `while read L; do ...; done < file.txt`. O Processo the Thread não gerou Forks!

---
> FINALIZADO! VOCÊ SE FORMOUS UMA BESTA FEROZ EM DEVOPS, LINUX OS SYSCALLS, PIPELINES AWS, SRED E PROCESS ENGINEERING SHELL SCRIPT. BASH IS THE WAY THE MAGIC C.
