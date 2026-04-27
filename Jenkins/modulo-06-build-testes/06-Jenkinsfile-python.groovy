// ============================================================
// MÓDULO 6 — BUILD E TESTES
// Arquivo: 06-Jenkinsfile-python.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline completo para projeto Python:
// virtualenv, instalação de deps, lint, testes com pytest,
// cobertura, e empacotamento.
// ============================================================

pipeline {
  agent any

  environment {
    PYTHONPATH    = "${WORKSPACE}"
    VENV_DIR      = "${WORKSPACE}/.venv"          // Virtualenv isolado
    PIP_CACHE_DIR = "${WORKSPACE}/.pip-cache"     // Cache do pip
  }

  stages {

    stage('Preparar Ambiente Python') {
      steps {
        sh '''
          python3 --version
          pip3 --version

          # Criar ambiente virtual isolado
          python3 -m venv $VENV_DIR

          # Ativar e atualizar pip
          . $VENV_DIR/bin/activate
          pip install --upgrade pip
          echo "Ambiente virtual criado em: $VENV_DIR"
        '''
      }
    }

    stage('Instalar Dependências') {
      steps {
        sh '''
          . $VENV_DIR/bin/activate

          # Instalar dependências de produção
          pip install -r requirements.txt

          # Instalar dependências de teste (se arquivo existir)
          if [ -f requirements-dev.txt ]; then
            pip install -r requirements-dev.txt
          fi

          # Instalar ferramentas de CI
          pip install pytest pytest-cov pytest-html flake8 pylint
        '''
      }
    }

    stage('Lint (flake8 + pylint)') {
      parallel {
        stage('flake8') {
          steps {
            sh '''
              . $VENV_DIR/bin/activate
              flake8 . \
                --max-line-length=120 \
                --exclude=.venv,migrations \
                --format=default \
                --output-file=flake8-report.txt || true
              cat flake8-report.txt
            '''
          }
          post {
            always {
              archiveArtifacts artifacts: 'flake8-report.txt', allowEmptyArchive: true
            }
          }
        }
        stage('pylint') {
          steps {
            sh '''
              . $VENV_DIR/bin/activate
              pylint **/*.py --output-format=text > pylint-report.txt 2>&1 || true
              cat pylint-report.txt
            '''
          }
          post {
            always {
              archiveArtifacts artifacts: 'pylint-report.txt', allowEmptyArchive: true
            }
          }
        }
      }
    }

    stage('Testes com Pytest') {
      steps {
        sh '''
          . $VENV_DIR/bin/activate

          pytest tests/ \
            --verbose \
            --tb=short \
            --junitxml=pytest-results.xml \
            --cov=. \
            --cov-report=xml:coverage.xml \
            --cov-report=html:coverage-html \
            --cov-report=term-missing \
            --html=pytest-report.html \
            --self-contained-html
          # --junitxml: relatório no formato JUnit para Jenkins
          # --cov: mede cobertura de código
          # --cov-report=html: relatório visual de cobertura
          # --html: relatório HTML do pytest
        '''
      }
      post {
        always {
          junit(
            testResults: 'pytest-results.xml',
            allowEmptyResults: true
          )
          publishHTML(
            target: [
              reportDir:   'pytest-report.html',
              reportFiles: '.',
              reportName:  'Pytest Report'
            ]
          )
          publishHTML(
            target: [
              reportDir:   'coverage-html',
              reportFiles: 'index.html',
              reportName:  'Coverage Report'
            ]
          )
          // Verificar cobertura mínima (quality gate manual)
          script {
            def coverage = sh(
              script: '''. $VENV_DIR/bin/activate && \
                python3 -c "import xml.etree.ElementTree as ET; \
                  tree = ET.parse('coverage.xml'); \
                  root = tree.getroot(); \
                  print(root.get('line-rate', '0'))" 2>/dev/null || echo "0"''',
              returnStdout: true
            ).trim().toFloat() * 100

            echo "Cobertura de código: ${coverage.round(1)}%"
            if (coverage < 80) {
              unstable("⚠️  Cobertura ${coverage.round(1)}% abaixo do mínimo (80%)")
            }
          }
        }
      }
    }

    stage('Build do Pacote') {
      when {
        branch 'main'
      }
      steps {
        sh '''
          . $VENV_DIR/bin/activate
          pip install build
          python3 -m build  # Gera wheel (.whl) e source dist (.tar.gz)
          ls -la dist/
        '''
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

  } // Fecha stages

  post {
    always {
      sh 'rm -rf $VENV_DIR $PIP_CACHE_DIR'  // Limpa virtualenv
      cleanWs()
    }
  }

} // Fecha pipeline
