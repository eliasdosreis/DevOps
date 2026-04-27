#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta como programadores experientes fazem a vida
# parecer Java no meio do Shell: Desmembram fluxos num
# "Try Catch", ou usando CallBack e Or/And Chains lógicas
# para lidar com falhas suaves sem quebrar tudo!
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você chama a Ambulância pra ir no lugar X pegar a Vitima.
# Se o script usa `set -e`, e a rua do lugar X estiver cortada, 
# O Script dá "MORTO"! O Script Inteirou comete suicidio na hora, e a vitima morre la 
# pq o script encerrou o processo PAI por conta daquela rua bloqueada.
# - Exception Handler (Try OR False): "Se a rua X der pau. Faça outra Rota. E Sobreviva, Não morra!". Pega a vítima, e finaliza o dia com sorriso no rosto na main process parent.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Handling de Short-circuits Operators C-Language. 
# Quando shellscript pipeline é coberto com modifier options `set -e` (errexit), 
# The Kernel aborts evaluation process e eleva status 1 fatal instantaneamente.
# A imunidade de Erro se dá mascarando o return do eval execution com or/anding list de booleanos logicos primitivos (`||`) protegendo a chamada da árvore condicional de erro matador do set-e.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Excepion Control: Salvando as Pontes ==="

# Arquivo fake
FILE_TARG="/tmp/diretorio_q_nao_existe/log"

echo "1. Mostrando o 'Ou/OR Lógico' como Catch Block"
# Se eu rodar um "cat" num file q N existe: O system explode no bash. Mas...
# Nós colocamos `|| true` A Direita! (Se o cat qbrar, não faça panico, ignore assumindo True e descendo)
cat "$FILE_TARG" 2>/dev/null || echo "   - Capturado/Catch the Cat Error Handler! Ignorei falha de não ter arquivo."

echo ""
echo "2. Encademento Atômico Positivo de Pipeline: The If de UMA LINHA SO"
# Apenas rodará o `echo Sucesso` SE a PRIMEIRA expressão à esq do (AND &&) der OK/ZERO!
# Um sub-comando `mkdir` falso q dá erro, mataria a direita. Mas o `mkdir fake_&& ...`
mkdir /tmp/pasta_falsa_99 2>/dev/null && echo "   - Criamos e já comemoramos tudo numa unica linha de processamento atômico seguro! ($?)"
rm -rf /tmp/pasta_falsa_99

echo ""
echo "3. Criando a Sua Própria Função Customizada 'DIE / THROW' (Como nas Lings High Level)!"
# No Python vc usa 'throw exception'. Aqui o DevOps cria o Throw na mão.
die() {
    # Manda prra saida erro vermelha, loga q falhou, e exita o subshell
    echo "   [FATAL THROW] - $1" >&2
    exit 1
}

# Veja a elegância! Mto mais limpo q "If else if else"! Tenta ler o path falso, se doer/bater, executa nosso 'Die()' do Dev e trava TUDO pq quisemos de propsito.
# Comentado pra não rodar kkk 'cd /bin && die "Não achado"'
echo "   - [Testado a logica do Die em single pipe.. o script sobreviveria ou descia se a var condicional não fosse ativada com um '|| die']"


# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Rodar pra ignorar fatalidades `comandoquequebra -z || true` (Nuca derrubará the O.S Parent script. The Errexit of shell env overlooks fallback conditionals).
# - Fallbacks Default: `NOME=${NOME_USUARIO:-"Visitante"}` (Substituinte C. Se a string de parametro lá for vazia ou undef no pipe local... ele joga 'Visitante' em seu lugar e n engasga).
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao fazer pipagem `cat /file_quebrado_q_n_existe | grep Error > log` o Bash morreu com o set -e! Meu script estourou porque setei o Header global Pipefail dele no start e não vi!
#   O que é: A maldição Pipefail -o! 
#   A solução: Quando pipefail -o é declarad em prod script. Toda linha do cano `a | b | c | d` repassa se tiver erro pro PAI MASTER BASH e morre. A solucao limpa é botar o `|| true` NO FINAL DO OCEA NO PIPE TODO! -> `a | b | c | grep x || true`. A falha que estourou lá no cano fd0 originairo ou fd2 interno desce escorrengando pro True q amortece a valcula global shell, e seu systema bash principal sobrevive limpo sem crachs ou kernel exception dump logs!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe algo parecido com TRY e CATCH real do Java/JS?
# Profissionais Shell scripters usam eval blocks aninhados entre o Grouping Context Engine `{ }` para emular um Catch perfeito.
# ` { ls /arquivo_do_mal_inexistente; bash -c rotinas_loucas; } || { echo "O try inteirinho explodiu pra tras"; exit 1; }  `
# A chaves juntas emulam no Linux um Parenteses gigantesco C context de Memory block isolado sem forkar pid subshells! O Shell agrupa inumeras e colossais linhas  tudo que bater internamente, sera engulido e contido estritamente, sendo devolvido pro CATCH  bloq `|| {}` sem quebrar the Pipeline originario C do Linux. Elegancia suprema e Try catch literal implementado via grouping evaluation control.
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se nós passamos a vida fugindo de falhas... pq a gente quer explicitamente Setar O Error (`set -e`) na CABEÇA DE TODO SCRIPT Bash pra forçar ele a morrer se não soubermos tratar? Não era melhor deixar desligad então desdo inicio?"
# Resposta Sênior: O Default do Bourne shell é prosseguir cegamente processando as próximas linhas de C-code independente das linhas anteocessaras do file terem falhado num erro letal de systema sem retornar status RC 0!. Se a linha 10 faz "Baixar codigo do App do Git" e falhar sem internet (404 Error curl)... A linha 11 q for processada e executar a montagem e compilação do Make Install de um dir vazio, o Linux continuaria cimentando lixo sem avisar ngm, subindo banco de dados mal criados com files e configs default corrompidas de ar instavel! 
# Nós forçamos o `set -e` como filosofia DevOps Universal da engenharia "FAIL FAST OR NOT FAULT" do Agile: É milhões de vezes mais seguro uma Automação qbrar calada no primeito bit de erro e matar process tree instantâneaement (pra um humano ir lá repassar ver a log de pq erro o git), do que o Linux calar o erro pra prosseguir executando deploys cagados as cegas corrompendo a Database da cia e destruindo os Loadbalancers asptics na nuvem. "Se tá errado na ram, pare. Falharápido."
# ============================================================
