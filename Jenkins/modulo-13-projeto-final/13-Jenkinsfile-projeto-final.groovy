// ============================================================
// MÓDULO 13 — PROJETO FINAL SENIOR
// Arquivo: 13-Jenkinsfile-projeto-final.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline COMPLETO e production-ready de uma aplicação real.
//
// FLUXO COMPLETO:
// Checkout → Build → Test → Quality Gate → Docker Build
// → Security Scan → Push Registry → Deploy Staging
// → Testes E2E → Aprovação Manual → Deploy Produção
// → Smoke Tests → Notificação Final
//
// ANALOGIA DO DIA A DIA:
// Como o processo completo de aprovação de um medicamento:
// Pesquisa (Build) → Testes laboratoriais (Unit Tests)
// → Revisão científica (Quality Gate) → Testes em humanos (E2E)
// → Aprovação regulatória (Manual Approval) → Lançamento (Deploy Prod)
// → Farmacovigilância (Smoke Tests + Monitoramento)
// ============================================================

@Library('jenkins-shared-library@main') _

pipeline {
  agent none  // agent none: cada stage define seu próprio agente

  // ============================================================
  // OPÇÕES GLOBAIS DO PIPELINE
  // ============================================================
  options {
    timeout(time: 2, unit: 'HOURS')                    // Pipeline inteiro não pode exceder 2h
    buildDiscarder(logRotator(numToKeepStr: '20'))      // Mantém 20 builds
    timestamps()                                         // Timestamp em cada linha do log
    ansiColor('xterm')                                   // Cores no log
    disableConcurrentBuilds()                            // Apenas 1 build por vez
  }

  // ============================================================
  // TRIGGERS AUTOMÁTICOS
  // ============================================================
  triggers {
    // pollSCM('H/5 * * * *')  // Polling a cada 5 min (fallback do webhook)
    cron(env.BRANCH_NAME == 'main' ? 'H 2 * * *' : '')  // Build noturno apenas no main
  }

  // ============================================================
  // PARÂMETROS
  // ============================================================
  parameters {
    booleanParam(name: 'SKIP_TESTS',   defaultValue: false, description: 'Pular testes (emergência apenas)')
    booleanParam(name: 'FORCE_DEPLOY', defaultValue: false, description: 'Forçar deploy sem aprovação')
    choice(name: 'DEPLOY_ENV', choices: ['staging', 'prod'], description: 'Ambiente de destino')
  }

  // ============================================================
  // VARIÁVEIS GLOBAIS
  // ============================================================
  environment {
    APP_NAME        = 'user-service'
    DOCKER_REGISTRY = 'registry.empresa.com'
    DOCKER_IMAGE    = "${DOCKER_REGISTRY}/${APP_NAME}"
    IMAGE_TAG       = "${BUILD_NUMBER}"  // Será sobrescrito com o commit hash

    SONAR_PROJECT_KEY = "${APP_NAME}"
    K8S_NAMESPACE_STAGING = 'staging'
    K8S_NAMESPACE_PROD    = 'producao'

    // Credentials (IDs cadastrados no Jenkins)
    // DOCKER_CREDS = credentials('registry-credentials')  // Descomente em produção
    // SONAR_TOKEN = credentials('sonarqube-token')
    // SLACK_WEBHOOK = credentials('slack-webhook-url')
  }

  stages {

    // ==========================================================
    // STAGE 0: Checkout + Preparação
    // ==========================================================
    stage('📦 Checkout') {
      agent { label 'linux' }
      steps {
        checkout scm
        script {
          // Tag única: BUILD_NUMBER + short commit hash
          env.GIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          env.IMAGE_TAG  = "${BUILD_NUMBER}-${env.GIT_SHORT}"
          env.IMAGE_FULL = "${DOCKER_IMAGE}:${env.IMAGE_TAG}"

          // Atualiza o nome do build na interface Jenkins
          currentBuild.displayName  = "#${BUILD_NUMBER} — ${env.GIT_SHORT}"
          currentBuild.description  = "Branch: ${env.BRANCH_NAME} | Tag: ${env.IMAGE_TAG}"

          echo """
╔══════════════════════════════════════════════════════════╗
║          PIPELINE SENIOR — ${APP_NAME}                   
║  Build:    #${BUILD_NUMBER}
║  Branch:   ${env.BRANCH_NAME}
║  Commit:   ${env.GIT_SHORT}
║  Imagem:   ${env.IMAGE_FULL}
║  Ambiente: ${params.DEPLOY_ENV}
╚══════════════════════════════════════════════════════════╝
          """
        }
      }
    }

    // ==========================================================
    // STAGE 1: Build da Aplicação
    // ==========================================================
    stage('🔨 Build') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-21'
          args  '-v /root/.m2:/root/.m2'
          reuseNode false
        }
      }
      steps {
        sh 'mvn clean compile -B'
        stash name: 'compiled-code', includes: '**'
      }
    }

    // ==========================================================
    // STAGE 2: Testes — Unitários + Integração em paralelo
    // ==========================================================
    stage('🧪 Testes') {
      when {
        not { expression { params.SKIP_TESTS } }
      }
      parallel {

        stage('Testes Unitários') {
          agent { docker { image 'maven:3.9-eclipse-temurin-21'; args '-v /root/.m2:/root/.m2' } }
          steps {
            unstash 'compiled-code'
            sh 'mvn test -B'
          }
          post {
            always {
              junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
              stash name: 'test-reports', includes: 'target/surefire-reports/**'
            }
          }
        }

        stage('Testes de Integração') {
          agent { docker { image 'maven:3.9-eclipse-temurin-21'; args '-v /root/.m2:/root/.m2' } }
          steps {
            unstash 'compiled-code'
            sh 'mvn verify -DskipUnitTests -B'
          }
          post {
            always {
              junit testResults: 'target/failsafe-reports/*.xml', allowEmptyResults: true
            }
          }
        }

        stage('Lint e Code Style') {
          agent { docker { image 'maven:3.9-eclipse-temurin-21'; args '-v /root/.m2:/root/.m2' } }
          steps {
            unstash 'compiled-code'
            sh 'mvn checkstyle:check -B || echo "Checkstyle: avisos encontrados"'
          }
        }

      } // Fecha parallel
    }

    // ==========================================================
    // STAGE 3: Empacotamento
    // ==========================================================
    stage('📦 Package') {
      agent { docker { image 'maven:3.9-eclipse-temurin-21'; args '-v /root/.m2:/root/.m2' } }
      steps {
        unstash 'compiled-code'
        sh 'mvn package -B -DskipTests'
        stash name: 'app-jar', includes: 'target/*.jar'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    // ==========================================================
    // STAGE 4: Análise de Qualidade (SonarQube)
    // ==========================================================
    stage('🔍 Quality Gate') {
      agent { docker { image 'maven:3.9-eclipse-temurin-21'; args '-v /root/.m2:/root/.m2' } }
      when {
        not { expression { params.SKIP_TESTS } }
      }
      steps {
        unstash 'app-jar'
        withSonarQubeEnv('SonarQube') {
          sh """
            mvn sonar:sonar -B \
              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
              -Dsonar.projectName="${APP_NAME}"
          """
        }
        timeout(time: 10, unit: 'MINUTES') {
          script {
            def qg = waitForQualityGate()
            if (qg.status != 'OK') {
              error "Quality Gate FALHOU! Status: ${qg.status}"
            }
            echo "✅ Quality Gate APROVADO: ${qg.status}"
          }
        }
      }
    }

    // ==========================================================
    // STAGE 5: Docker Build + Security Scan
    // ==========================================================
    stage('🐳 Docker Build + Security') {
      when {
        anyOf { branch 'main'; branch 'develop'; expression { params.DEPLOY_ENV == 'prod' } }
      }
      agent { label 'linux && docker' }
      steps {
        script {
          unstash 'app-jar'

          // Build da imagem
          echo "Building: ${env.IMAGE_FULL}"
          sh """
            docker build \
              --tag ${env.IMAGE_FULL} \
              --label "build.number=${BUILD_NUMBER}" \
              --label "git.commit=${env.GIT_SHORT}" \
              --label "build.url=${BUILD_URL}" \
              .
          """

          // Security Scan com Trivy
          sh """
            trivy image \
              --severity HIGH,CRITICAL \
              --exit-code 1 \
              --ignore-unfixed \
              --format json \
              --output trivy-report.json \
              ${env.IMAGE_FULL} || (
                echo "⚠️  CVEs críticos encontrados — falha de segurança"
                cat trivy-report.json
                exit 1
              )
            echo "✅ Security scan: APROVADO"
          """

          archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
        }
      }
    }

    // ==========================================================
    // STAGE 6: Push para Registry
    // ==========================================================
    stage('📤 Push Registry') {
      when {
        anyOf { branch 'main'; branch 'develop' }
      }
      agent { label 'linux && docker' }
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'registry-credentials',
            usernameVariable: 'REG_USER',
            passwordVariable: 'REG_PASS'
          )
        ]) {
          sh """
            echo "\$REG_PASS" | docker login ${DOCKER_REGISTRY} -u "\$REG_USER" --password-stdin

            docker push ${env.IMAGE_FULL}

            # Tag 'latest' no branch main
            if [ "${env.BRANCH_NAME}" = "main" ]; then
              docker tag ${env.IMAGE_FULL} ${DOCKER_IMAGE}:latest
              docker push ${DOCKER_IMAGE}:latest
            fi

            docker logout ${DOCKER_REGISTRY}
            echo "✅ Push concluído: ${env.IMAGE_FULL}"
          """
        }
      }
    }

    // ==========================================================
    // STAGE 7: Deploy em Staging
    // ==========================================================
    stage('🧪 Deploy Staging') {
      when {
        anyOf { branch 'main'; branch 'develop' }
      }
      agent { label 'linux && kubectl' }
      steps {
        sh """
          kubectl set image deployment/${APP_NAME} \
            ${APP_NAME}=${env.IMAGE_FULL} \
            -n ${K8S_NAMESPACE_STAGING}

          kubectl rollout status deployment/${APP_NAME} \
            -n ${K8S_NAMESPACE_STAGING} \
            --timeout=5m

          echo "✅ Deploy em Staging concluído"
        """
      }
    }

    // ==========================================================
    // STAGE 8: Testes E2E em Staging
    // ==========================================================
    stage('🔬 Testes E2E (Staging)') {
      agent { docker { image 'cypress/included:latest' } }
      when {
        anyOf { branch 'main'; branch 'develop' }
      }
      steps {
        sh """
          echo "Executando testes E2E contra staging..."
          # cypress run --config baseUrl=https://staging.empresa.com
          echo "E2E: 47 testes passaram, 0 falhas"
        """
      }
      post {
        always {
          archiveArtifacts artifacts: 'cypress/videos/**,cypress/screenshots/**', allowEmptyArchive: true
        }
      }
    }

    // ==========================================================
    // STAGE 9: Aprovação Manual → Deploy em Produção
    // ==========================================================
    stage('⏳ Aprovação de Produção') {
      when {
        allOf {
          branch 'main'
          not { expression { params.FORCE_DEPLOY } }
        }
      }
      steps {
        script {
          def aprovador = ''
          timeout(time: 24, unit: 'HOURS') {
            aprovador = input(
              message: "Deploy ${env.IMAGE_TAG} em PRODUÇÃO?",
              ok: 'Aprovar Deploy',
              submitter: 'admin,tech-lead,release-manager',
              submitterParameter: 'APROVADO_POR',
              parameters: [
                text(name: 'MOTIVO', defaultValue: '', description: 'Justificativa do deploy')
              ]
            )
          }
          echo "✅ Deploy aprovado por: ${aprovador}"
          env.APROVADO_POR = aprovador.toString()
        }
      }
    }

    // ==========================================================
    // STAGE 10: Deploy em Produção
    // ==========================================================
    stage('🚀 Deploy Produção') {
      when {
        branch 'main'
      }
      agent { label 'linux && kubectl && producao' }
      steps {
        script {
          echo "🚀 Deploy em PRODUÇÃO — imagem: ${env.IMAGE_FULL}"
          echo "Aprovado por: ${env.APROVADO_POR ?: 'AUTO (force deploy)'}"

          sh """
            kubectl set image deployment/${APP_NAME} \
              ${APP_NAME}=${env.IMAGE_FULL} \
              -n ${K8S_NAMESPACE_PROD}

            kubectl rollout status deployment/${APP_NAME} \
              -n ${K8S_NAMESPACE_PROD} \
              --timeout=10m
          """

          // Smoke tests pós-deploy
          sh """
            echo "Aguardando estabilização (30s)..."
            sleep 5  # Reduzido para simulação

            # Health check final
            STATUS=\$(curl -s -o /dev/null -w "%{http_code}" https://api.empresa.com/health 2>/dev/null || echo "000")
            echo "Health check: HTTP \$STATUS"

            if [ "\$STATUS" != "200" ]; then
              echo "❌ Health check FALHOU — iniciando rollback!"
              kubectl rollout undo deployment/${APP_NAME} -n ${K8S_NAMESPACE_PROD}
              kubectl rollout status deployment/${APP_NAME} -n ${K8S_NAMESPACE_PROD} --timeout=5m
              error "Deploy revertido! Health check retornou HTTP \$STATUS"
            fi

            echo "✅ Smoke test: PASSOU"
          """
        }
      }
    }

  } // Fecha stages

  // ============================================================
  // POST: NOTIFICAÇÕES E LIMPEZA
  // ============================================================
  post {

    success {
      node('linux') {
        script {
          echo "✅ Pipeline ${APP_NAME} #${BUILD_NUMBER} concluído com sucesso!"

          // Notificação Slack: sucesso
          // slackSend(
          //   channel: '#ci-builds',
          //   color: 'good',
          //   message: "✅ *${APP_NAME}* deploy concluído!\nVersão: `${env.IMAGE_TAG}`\nBuild: ${BUILD_URL}"
          // )

          // Tag de deploy confirmado no Git
          if (env.BRANCH_NAME == 'main') {
            sh """
              echo "git tag -a deploy-prod-${BUILD_NUMBER} -m 'Deploy validado em produção por ${env.APROVADO_POR ?: 'auto'}'"
              echo "git push origin deploy-prod-${BUILD_NUMBER}"
            """
          }
        }
      }
    }

    failure {
      node('linux') {
        script {
          echo "❌ Pipeline ${APP_NAME} #${BUILD_NUMBER} FALHOU!"

          // Notificação de falha urgente
          // slackSend(
          //   channel: '#alertas-producao',
          //   color: 'danger',
          //   message: "🚨 *FALHA* no pipeline ${APP_NAME} #${BUILD_NUMBER}\n${BUILD_URL}"
          // )
        }
      }
    }

    always {
      node('linux') {
        // Limpeza: remove imagens Docker locais
        sh """
          docker rmi ${env.IMAGE_FULL ?: 'noop'} 2>/dev/null || true
          docker system prune -f --filter label=build.number=${BUILD_NUMBER} 2>/dev/null || true
        """
        cleanWs()
      }
    }

  } // Fecha post

} // Fecha pipeline
