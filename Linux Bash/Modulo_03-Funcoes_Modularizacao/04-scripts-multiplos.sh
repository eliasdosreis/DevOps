#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Age como o "File Principal" (Entrypoint).
# Aprenderemos a importar as funções que fizemos na biblioteca 
# (Script 03) usando dinamicamente "source", demonstrando um 
# sistema em múltiplos arquivos.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# A Fábrica de Carros da Volvo (Nosso Master Script 04).
# O funcionário da montadora precisa pintar o capô, mas ele não sabe como!
# Ele corre lá na sala do gerente (Script 03), rouba a lista de procedimentos "logger e bd", traz debaixo do braço, decora tudo num minuto. Agora a Montadora Mestre consegue fazer login em banco e imprimir logs coloridos e a gente não precisou escrever o cógido do BD aqui duas vezes!
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Entrypoint Scripts centralizam Core Architecture Flow.
# Eles utilizam 'DOT INCLUSION PATH' no preâmbulo global para dar fetch, read e evaluate
# das instâncias da camada abstrata via PATH relacional dinâmico.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Múltiplas Partes: A Montagem ==="

# Como descobrimos onde DIABOS esse arquivo (04-scripts) atual 
# está morando no pc do Usuário agora? Puxamos a pasta mãe baseada no comando original ($0)
DIR_ATUAL=$(dirname "$0")

# Definimos estaticamente o FilePath do nosso amigo Script 3.
LIB_FILE="${DIR_ATUAL}/03-bibliotecas-source.sh"

# Verificação Sênior: Se o fulano "deletou" o arquivo 3 achando que era atalho 
# na lixeira do windows... nós não deixamos explodir no terminal crú: Testamos antes (-f)
if [[ ! -f "$LIB_FILE" ]]; then
    echo "ERRO CRÍTICO: Não encontrei a bilioteca Base $LIB_FILE!"
    # Exita em Panic.
    exit 1
fi

# =========================================
# MAGIC MOMENT: O IMPORT EM AÇÃO!
# =========================================
echo "1. Carregando e empacotando os recursos externos na memória do script atual..."
source "$LIB_FILE" # ou `. "$LIB_FILE"`
echo ""

# A partir dessa linha (16), TODAS AS FUNÇÕES do Lib File 3 acordam
# das trevas e existem de fato na shell!

# Invocamos diretamente "logger_info" (Ela não existe na raiz desse arquivo, preste atenção! ela é 100% Importada)
logger_info "Inicializando Pipeline de Dados Modular."
logger_info "Conectamos no Banco Central..."

# Invocamos "db_conectar" que repousava importada tbm
db_conectar "admin_production"

logger_info "Finalizando Deploy. O sistema executado do arquivo 4 funcionou com o corpo do 3 limpo em código."

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Ao rodar `./04-scripts-multiplos.sh` a mágica do bash une os dois códigos e processa tudo de forma limpa. 
# - Modularidade no ápice: Você pode ter 1 `file.sh` de configs e chamar em 20 crons avulsos, mudou a config do db, aplica a todos instantâneo nos deploys diários!
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - O script rodou e achou o module, mas reclamou que no module o `set -e` não funciona.
#   O `set -e` no Pai protege o Pai e todos os imports inclusos abaixo. Você não deve declarar no Filho/Lib.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um design-pattern chamado `main() hook idiomatico` do bash puro.
# Como o Bash não tem de fato "Ponto Único de Entrada do Kernel" como a lingauga C (O C procura o main void func int encarrascado). 
# Em bash a gente sempre define variáveis constantes e sources CÁ NO TOPO. Mas executáveis soltos... lá no final... a gente centraliza TODA lógica isolada num def global `main()` gigantesco e chama 1 só vez `main "$@"` na última fatídica linha do arquivo de topo. O Shell primeiro lê todo DOM, carrega todo mundo, e só no 1% de rodapé trigga a engrenagem, garantindo Load Seguríssimo e debuggability monstra para Unit Tests via shellspecs/bats (já que em test você usa source, e o source não dispara main() sozinho se testares no bats).
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu tiver um arquivo de configurações `vars.env` (.env/yaml lite paramêtros) e eu chamar o source `source config.env` sabendo que esse .env pode ser manipulado num painel por usuários inocentes/Hackers... como mitigar de dar Source em algo desonesto?"
# Resposta Sênior: Péssima Ideia dar SOURCE e dot-evaluations em templates de strings criados por humanos em Web forms ou configs soltas não-repos! O source é um Eval de CÓDIGO BASH PURO (RCE Vulnerable)! 
# Se um estagiário na variável de Host botar `HOST="ip; rm -rf /"` no txt. Seu Source vai rodar rm fatal com privilégio alto e deletar o file-system! O ideal é usar `grep/awk` regex para extrair variáveis limpas com chaveamento, ou rodar comandos parseadores `.env` (ex: `read -r / mapfile` restritivo) sem invocar subshells com permissões de kernel.
# ============================================================
