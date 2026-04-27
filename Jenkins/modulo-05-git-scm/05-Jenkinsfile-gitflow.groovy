// ============================================================
// MÓDULO 5 — INTEGRAÇÃO COM GIT E SCM
// Arquivo: 05-Jenkinsfile-gitflow.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline adaptado para GitFlow — a estratégia de branching
// mais usada em times enterprise.
//
// ESTRATÉGIA GITFLOW:
// main     → produção (sempre estável)
// develop  → integração (próxima versão)
// feature/ → novas funcionalidades
// release/ → preparação de release
// hotfix/  → correção urgente em produção
// ============================================================

pipeline {
  agent any

  environment {
    // Sanitiza o nome do branch para uso em tags Docker
    // Ex: 'feature/auth-login' → 'feature-auth-login'
    SAFE_BRANCH = "${env.BRANCH_NAME?.replaceAll('[^a-zA-Z0-9-]', '-')}"
    APP_NAME    = 'minha-app'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.GIT_SHORT = sh(
            script: 'git rev-parse --short HEAD',
            returnStdout: true
          ).trim()
          echo "Branch: ${env.BRANCH_NAME} | Commit: ${env.GIT_SHORT}"
        }
      }
    }

    stage('Build e Testes') {
      // Executa em TODOS os branches — o CI nunca pula testes
      steps {
        echo "Build e testes para branch: ${env.BRANCH_NAME}"
        sh '''
          echo "Compilando..."
          echo "Testando..."
          echo "Build concluído: OK"
        '''
      }
    }

    // =========================================================
    // FEATURE BRANCHES: CI básico, sem deploy
    // Objetivo: garantir que o código não quebra antes do merge
    // =========================================================
    stage('Feedback de Feature Branch') {
      when {
        expression { env.BRANCH_NAME?.startsWith('feature/') }
      }
      steps {
        echo """
🔧 Feature Branch: ${env.BRANCH_NAME}
✓ Build: OK
✓ Testes: OK
→ Pronto para abrir Pull Request para develop
        """
      }
    }

    // =========================================================
    // DEVELOP: Deploy automático em ambiente de integração
    // =========================================================
    stage('Deploy em Integração (develop)') {
      when {
        branch 'develop'
      }
      steps {
        echo "🔀 Branch develop: deploy automático em integração"
        sh '''
          echo "Deploy em ambiente de integração..."
          echo "URL: http://integration.empresa.com"
        '''
        script {
          def imageTag = "${APP_NAME}:develop-${env.GIT_SHORT}"
          echo "Imagem Docker: ${imageTag}"
        }
      }
    }

    // =========================================================
    // RELEASE: Testes completos + versioning
    // =========================================================
    stage('Preparar Release') {
      when {
        expression { env.BRANCH_NAME?.startsWith('release/') }
      }
      steps {
        script {
          def versao = env.BRANCH_NAME.replace('release/', '')
          echo "📦 Preparando release ${versao}"

          sh """
            echo "Atualizando versão para: ${versao}"
            echo "Rodando testes de regressão completos..."
            echo "Gerando changelog..."
            echo "Release ${versao}: PRONTO para main"
          """

          // Guardar versão para stages seguintes
          env.RELEASE_VERSION = versao
        }
      }
    }

    stage('Deploy em Staging (release)') {
      when {
        expression { env.BRANCH_NAME?.startsWith('release/') }
      }
      steps {
        echo "🧪 Deploy em Staging para validação da release ${env.RELEASE_VERSION}"
        sh 'echo "Deploy em staging: OK"'
      }
    }

    // =========================================================
    // MAIN: Deploy em produção com aprovação
    // =========================================================
    stage('Deploy em Produção (main)') {
      when {
        branch 'main'
      }
      steps {
        script {
          def lastTag = sh(
            script: 'git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0"',
            returnStdout: true
          ).trim()

          echo "🚀 Main branch — deploy em produção"
          echo "Versão: ${lastTag}"

          timeout(time: 2, unit: 'HOURS') {
            input(
              message: "Deploy ${lastTag} em PRODUÇÃO?",
              ok: 'Aprovar',
              submitter: 'admin,release-manager'
            )
          }

          sh "echo 'Deploy ${lastTag} em produção: CONCLUÍDO'"
        }
      }
    }

    // =========================================================
    // HOTFIX: Deploy urgente com aprovação simplificada
    // =========================================================
    stage('Hotfix: Deploy Urgente') {
      when {
        expression { env.BRANCH_NAME?.startsWith('hotfix/') }
      }
      steps {
        script {
          def hotfixId = env.BRANCH_NAME.replace('hotfix/', '')
          echo "🚨 HOTFIX: ${hotfixId}"
          echo "Deploy emergencial após aprovação..."

          timeout(time: 30, unit: 'MINUTES') {
            input(
              message: "HOTFIX ${hotfixId}: Aprovar deploy URGENTE em produção?",
              ok: 'Aprovar Hotfix',
              submitter: 'admin,cto'
            )
          }

          sh "echo 'Hotfix ${hotfixId}: aplicado em produção'"
        }
      }
    }

  } // Fecha stages

  post {
    success {
      script {
        if (env.BRANCH_NAME == 'main') {
          echo "🎉 PRODUÇÃO ATUALIZADA!"
        } else if (env.BRANCH_NAME == 'develop') {
          echo "✅ Integração atualizada — develop OK"
        } else {
          echo "✅ Build OK para ${env.BRANCH_NAME}"
        }
      }
    }
  }

} // Fecha pipeline
