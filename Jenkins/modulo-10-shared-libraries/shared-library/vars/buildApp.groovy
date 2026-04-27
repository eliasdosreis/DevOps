// ============================================================
// MÓDULO 10 — SHARED LIBRARIES
// Arquivo: shared-library/vars/buildApp.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Função global reutilizável para build de aplicações.
// Pode ser chamada diretamente no Jenkinsfile: buildApp(...)
//
// ANALOGIA DO DIA A DIA:
// Como uma receita padronizada numa rede de restaurantes.
// Em vez de cada restaurante (pipeline) inventar sua própria receita
// de bolo, todos usam a receita central (shared library).
// Se a receita muda, todos os restaurantes são atualizados.
// ============================================================

// vars/buildApp.groovy
// Funções em vars/ são chamadas DIRETAMENTE no Jenkinsfile (sem import)

/**
 * Realiza o build da aplicação com a ferramenta correta.
 *
 * @param config Map com configurações:
 *   - tipo: 'maven', 'npm', 'python', 'docker' (obrigatório)
 *   - versao: versão da ferramenta (opcional)
 *   - skipTests: boolean, pular testes no build (default: false)
 *   - args: argumentos adicionais para a ferramenta (opcional)
 *
 * Uso no Jenkinsfile:
 *   buildApp(tipo: 'maven', skipTests: true)
 *   buildApp(tipo: 'npm')
 */
def call(Map config = [:]) {
  // Validação de parâmetros obrigatórios
  if (!config.tipo) {
    error "buildApp: parâmetro 'tipo' é obrigatório (maven, npm, python, docker)"
  }

  def tipo      = config.tipo
  def skipTests = config.skipTests ?: false
  def args      = config.args ?: ''

  echo "🔨 [buildApp] Iniciando build tipo: ${tipo}"
  echo "🔨 [buildApp] Skip tests: ${skipTests}"

  switch (tipo) {
    case 'maven':
      def mavenArgs = "-B ${skipTests ? '-DskipTests' : ''} ${args}"
      sh "mvn clean package ${mavenArgs}"
      break

    case 'npm':
      sh 'npm ci'
      if (!skipTests) {
        sh 'npm test'
      }
      sh 'npm run build'
      break

    case 'python':
      sh '''
        python3 -m venv .venv
        . .venv/bin/activate
        pip install -r requirements.txt
      '''
      if (!skipTests) {
        sh '. .venv/bin/activate && pytest tests/'
      }
      break

    case 'gradle':
      sh "./gradlew build ${skipTests ? '-x test' : ''} ${args}"
      break

    default:
      error "buildApp: tipo '${tipo}' não suportado. Use: maven, npm, python, gradle"
  }

  echo "✅ [buildApp] Build concluído com sucesso!"
}

// Sobrecarga: chamada simples apenas com o tipo
def call(String tipo) {
  call(tipo: tipo)
}
