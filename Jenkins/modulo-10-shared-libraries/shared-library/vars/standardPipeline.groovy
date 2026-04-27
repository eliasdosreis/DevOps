// ============================================================
// MÓDULO 10 — SHARED LIBRARIES
// Arquivo: shared-library/vars/standardPipeline.groovy
//
// Pipeline padronizado completo para toda a organização.
// Um único arquivo que define o pipeline corporativo padrão.
// ============================================================

/**
 * Pipeline padrão corporativo.
 * Basta chamar standardPipeline() no Jenkinsfile de qualquer projeto!
 *
 * Uso mínimo no Jenkinsfile do projeto:
 *   @Library('jenkins-shared-library@main') _
 *   standardPipeline(
 *     tipo: 'maven',
 *     appName: 'minha-app',
 *     dockerRepo: 'minha-org/minha-app'
 *   )
 */
def call(Map config = [:]) {
  // Configurações com defaults
  def tipo        = config.tipo       ?: 'maven'
  def appName     = config.appName    ?: env.JOB_BASE_NAME
  def dockerRepo  = config.dockerRepo ?: "minha-org/${appName}"
  def deployEnvs  = config.deployEnvs ?: ['staging']  // Ambientes de deploy
  def sonarScan   = config.sonarScan  != false
  def trivyScan   = config.trivyScan  != false

  pipeline {
    agent { label 'linux && docker' }

    options {
      timeout(time: 45, unit: 'MINUTES')
      buildDiscarder(logRotator(numToKeepStr: '10'))
      timestamps()
      ansiColor('xterm')
    }

    environment {
      APP_NAME    = appName
      DOCKER_REPO = dockerRepo
      IMAGE_TAG   = "${BUILD_NUMBER}-${sh(script: 'git rev-parse --short HEAD 2>/dev/null || echo unkn', returnStdout: true).trim()}"
    }

    stages {
      stage('Checkout') {
        steps {
          checkout scm
          script {
            echo "🔄 Branch: ${env.BRANCH_NAME}"
            echo "🔄 Commit: ${env.GIT_COMMIT?.take(8)}"
          }
        }
      }

      stage('Build') {
        steps {
          buildApp(tipo: tipo)
        }
      }

      stage('Quality Gate') {
        when { expression { sonarScan } }
        steps {
          withSonarQubeEnv('SonarQube') {
            sh "mvn sonar:sonar -Dsonar.projectKey=${appName}"
          }
          timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
          }
        }
      }

      stage('Docker Build e Push') {
        when {
          anyOf { branch 'main'; branch 'develop' }
        }
        steps {
          script {
            docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
              def img = docker.build("${DOCKER_REPO}:${IMAGE_TAG}")
              img.push()
              if (env.BRANCH_NAME == 'main') img.push('latest')
            }
          }
        }
      }

      stage('Security Scan') {
        when { expression { trivyScan } }
        steps {
          sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_REPO}:${IMAGE_TAG}"
        }
      }

      stage('Deploy') {
        when {
          anyOf { branch 'main'; branch 'develop' }
        }
        steps {
          script {
            def targetEnvs = env.BRANCH_NAME == 'main' ? deployEnvs + ['prod'] : deployEnvs
            targetEnvs.each { amb ->
              deployApp(
                ambiente:  amb,
                imagem:    "${DOCKER_REPO}:${IMAGE_TAG}",
                aprovacao: amb == 'prod'
              )
            }
          }
        }
      }
    }

    post {
      always { notifySlack() }
      success { echo "✅ Pipeline ${appName} concluído!" }
      failure { notifySlack(channel: '#alertas-criticos', status: 'failure') }
      cleanup { cleanWs() }
    }
  }
}
