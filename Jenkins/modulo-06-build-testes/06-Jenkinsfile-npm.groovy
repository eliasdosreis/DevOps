// ============================================================
// MÓDULO 6 — BUILD E TESTES
// Arquivo: 06-Jenkinsfile-npm.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline completo para aplicação Node.js com npm:
// install, lint, testes unitários, build de produção,
// relatórios de cobertura e arquivamento.
// ============================================================

pipeline {
  agent any

  tools {
    nodejs 'nodejs-20'  // Configure em: Manage Jenkins → Tools → NodeJS
  }

  environment {
    CI          = 'true'            // Modo CI: testes não abrem browser, etc.
    NODE_ENV    = 'test'            // Ambiente de teste para variáveis da app
    NPM_CONFIG_CACHE = "${WORKSPACE}/.npm-cache"  // Cache local do npm (mais rápido)
  }

  options {
    timeout(time: 20, unit: 'MINUTES')  // Node builds costumam ser mais rápidos
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'node --version'
        sh 'npm --version'
      }
    }

    stage('Instalar Dependências') {
      steps {
        echo "📦 Instalando dependências npm..."
        sh '''
          npm ci
          # npm ci = install para CI (mais rápido/determinístico que npm install)
          # usa package-lock.json para versões exatas
          # falha se package-lock.json não estiver sincronizado com package.json
        '''
        // npm ci é preferível ao npm install em CI porque:
        // 1. É mais rápido (não resolve dependências)
        // 2. Garante mesmas versões do package-lock.json
        // 3. Limpa node_modules antes de instalar
      }
    }

    stage('Lint (verificação de código)') {
      steps {
        echo "🔍 Verificando padrões de código (ESLint)..."
        sh '''
          npm run lint -- --format json --output-file lint-results.json || true
          npm run lint  # Exibe no console também
        '''
      }
      post {
        always {
          // Publica resultado do lint se o plugin estiver disponível
          // recordIssues(tools: [esLint(pattern: 'lint-results.json')])
          archiveArtifacts artifacts: 'lint-results.json', allowEmptyArchive: true
        }
      }
    }

    stage('Testes Unitários') {
      steps {
        echo "🧪 Executando testes com Jest..."
        sh '''
          npm test -- \
            --ci \
            --coverage \
            --forceExit \
            --reporters=default \
            --reporters=jest-junit \
            --testResultsProcessor=jest-junit
          # --ci: modo CI (mais rigoroso, não abre prompts)
          # --coverage: gera relatório de cobertura de código
          # --forceExit: força saída ao final (evita processo pendurado)
          # --reporters=jest-junit: gera XML estilo JUnit
        '''
      }
      post {
        always {
          // Publica relatório JUnit (gerado pelo jest-junit)
          junit(
            testResults: 'junit.xml',
            allowEmptyResults: true
          )
          // Publica relatório de cobertura HTML
          publishHTML(
            target: [
              reportDir:   'coverage/lcov-report',
              reportFiles: 'index.html',
              reportName:  'Code Coverage Report',
              keepAll:     true,
              alwaysLinkToLastBuild: false,
              allowMissing: true
            ]
          )
        }
      }
    }

    stage('Build de Produção') {
      when {
        anyOf { branch 'main'; branch 'develop' }
      }
      steps {
        echo "🏗️  Compilando bundle de produção..."
        withEnv(['NODE_ENV=production']) {
          sh '''
            npm run build
            echo "Build gerado em ./dist/"
            ls -la dist/ || echo "Diretório dist não encontrado"
          '''
        }
      }
      post {
        success {
          archiveArtifacts(
            artifacts: 'dist/**',
            fingerprint: true
          )
        }
      }
    }

    stage('Auditoria de Segurança') {
      steps {
        echo "🔒 Verificando vulnerabilidades nas dependências..."
        sh '''
          npm audit --audit-level=high --json > npm-audit.json || true
          npm audit --audit-level=high || echo "Aviso: vulnerabilidades encontradas"
          # --audit-level=high: só falha para severity HIGH ou CRITICAL
          # Em produção, considere falhar em 'moderate' também
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'npm-audit.json', allowEmptyArchive: true
        }
      }
    }

  } // Fecha stages

  post {
    always {
      sh 'rm -rf .npm-cache'     // Limpa cache local
      cleanWs(cleanWhenAborted: true)
    }
  }

} // Fecha pipeline
