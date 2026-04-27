#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta ao Desenvolvedor Sênior a obrigatoriedade da 
# existência de Frameworks de Testes Unitários no mundo DevOps.
# Como escrever testos "TDD" para testar Arquivos BASH (.sh).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você construibu a Fábrica (Seu Script 1 a 6 que roda na AWS).
# Mas antes de dar a Ligação do Fogo Pro dono, um INSPETOR DA PREFEITURA
# tem de ir de manhã checar a valvula de gas.
# O framework BATS (Bash automated test system) é o Engenheiro da Prefeitura!
# Ele isola um mundo, executa seu script la dentro, e mede: "A valvula apitou erro 0? O Output cuspiu string XPTO que o Dev disse? Se não, Não passa na vistoria!".
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# BATS ou ShellSpec provêm Unit Test Assertions em um runtime POSIX compliant,
# facilitando emulaçoes e avaliaçoes contínuas de outputs e return calls sem modificar the source-code system files da engine testada; amplamaneet acoplados em CI/CD pipelines p/ Quality Assurance (QA).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO -- SETUP E SINTAXE DE PROVA MOCK-UP
# ============================================================

echo "=== Testes Unitários de Integração (BATS) ==="

echo "1. O Que vc e O framework precisam fazer: "
echo "   Você tem um script real na production com a função `multiplica(A, B)`."
echo "   Mas você modificou ele hoje de tarde. Se subirmos isso quebrando sem testar, a AWS para."

echo "2. O BATS (Exemplo Sintético .bats) é composto por Assertivas Universais em Ingles:"

# Um Script .bats legítimos se escreve OBRIGARTORIAMNETE como esse modelo abaico:
# Mas nos escrevemos no ECHO pra só printar de exenplo, senao os syteman abortaria sem BATS Instaldo haha!

cat << 'EOF' | sed 's/^/   /g'
#!/usr/bin/env bats

# Pre-loading nossa library mestre originaria!
load "03-bibliotecas-source.sh"

@test "A funcao central db_conectar deve retornar Status de sucesso Zero 0 O.K!" {
  run db_conectar "testeUserGCP2"

  # As variaveis de retorno do RUN $status vem automaticas da API bats inject
  [ "$status" -eq 0 ]
  
  # Aqui O Assert garante que O TEXTO ECHOADO PRA TTY possuia e matcheava com a String Conexao do programador do lib na pasta 3!
  [[ "$output" =~ "Conexão efetuada." ]]
}
EOF

echo ""
echo "3. C/ a Ferramenta instalada na Maquina (apt-get install bats)... O DevOps escreve centenas de blocos @tests de assertions em arquivos `test_db.bats` varrendo de ponta a ponta todos os functions do repositório."

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Clone o framework Sincrono oficial no Linux: `git clone https://github.com/bats-core/bats-core.git` e suba no `/usr/local`.
# - Crie os aqurivos extesnão bats (MeuTest.bats) encapsulando os Runs blocks com a var `$output`.
# - Mande A Bala Iniciar Processao: `bats MeuTest.bats` E ele renderizará os `[ Ok  ]` Checkbox verde de Vistoria de sucesso TTY UI Output se todos passarem os asserts test brackets simples `[ $status -eq 0 ]` e validacoes output strings Regex ! No Terminal Jenkins CI.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Tentei rodar O bats no script do meu amigo mas O teste Abriu a conexao com o BANCO NA AWS DE VERDADE E EXCLUIU OS DADOS DA CONTA DELE NA NUVEM?!
#   O que é: Você testou o BATS num Script de Inclusão Global em que a variavel e a conexao era Hardcodada pra a Production Engine (Não usou Parametros CLI, ou Mock/Env variables test-stages!) e você rodou o executavel C!
#   Solução Sênior QA Master : Use E MOCK functions (Interceptadores Dummy Stubbers de framework BATS) ou Suba variveis Fakes Isoladas TTY Envs no header da funcçao do bats (Setup()/Teardown()... setando a var BD_STAGE='localhost') pra seu script rodar contra o bd_SQL Lite temp falso na sua maquina da docker sem encostar nos cloud clusters global da aws! The golden rule of Mocking dependencies.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe na automação de CI (Github actions) do Jenkins um "JUNIT xml file Report"? 
# O DevOps Master e Sr QA Engineeres criam CI Pipeline YAMLs e rodam ao invés de cuspir verdinhos em cores raw: `bats --formatter junit -T testsDir/ > results.xml`. 
# Ferramentas Cloud Providers (CircleCI CI/ SonarQubes / AWS CodeDeploy/Gitlab) Nao entendem textinhos coloridos `OK!` de bash, ELES COMEM nativamente estruturas Universais Puras de arquivos XML de QA CSharp Java JUNIT Reporter Standard.
# Puxam isso pra Dashboard de gráficos gigantes corporativos pra toda Diretoria e C-Level Cloud verem O GRAFICO na Tela: "O Código do Bash Pipeline do João cobriu e passou em 99% Dos testes estáticos e assertions das Bibliotecas da GCP Infra! Parabens". O Arquivo Bash se tornou Enterprise!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu estiver codando para DevOps Unit Tester QA de bash system, qual a dif de testarmos O OUTPUT text TTY e testar a VAR DE SITEMA $status no framework bats no momento q chamo a func `run meu_script.sh`?"
# Resposta Sênior: Retornos status validam Resilencia de Engine IPC Linux Systems. Um script de banco de dado pode retornar O EXIT status de 0 (Sucesso pra ele pq conseguiu bater TCP Handshake e exit C engine limpo), mas O texto TTY q ele Printou foi "Database retornou nulo". O script "Nao quebrou de kernel" (Por isso exit é 0!), então Systemd n saberia ler dor se vc não olhar... Porém O VALOR TEXTUAL é lixo falso na RAM p negocio! 
# Em testes maduros QA SRE System, Assertions Obrigam SEMPRE o par Check duplo: Verifique A Valvula de Vida Kernes (Status -eq zero pra garentir sem syntax kills no pipe), E simultaneamente Check regexes da string gerada na porta I/O (Output matches string 'Rows inserted!') para assinar Embaixo o Business logic Result Data de fato!
# ============================================================
