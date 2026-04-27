// ============================================================
// MÓDULO 5 — INTEGRAÇÃO COM GIT E SCM
// Arquivo: 05-Jenkinsfile-multibranch.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Jenkinsfile configurado para funcionar corretamente num
// Multibranch Pipeline — onde cada branch tem seu próprio job.
//
// ANALOGIA DO DIA A DIA:
// Uma biblioteca com várias salas de estudos. Cada sala (branch)
// tem suas próprias regras: na sala de produção (main) só entra
// quem tiver aprovação; na sala de desenvolvimento qualquer um
// pode entrar para estudar (build e teste).
// ============================================================

pipeline {
  agent any

  // Variáveis baseadas no branch atual
  environment {
    // BRANCH_NAME é a variável correta para Multibranch (não GIT_BRANCH)
    IS_MAIN_BRANCH     = "${env.BRANCH_NAME == 'main' ? 'true' : 'false'}"
    IS_RELEASE_BRANCH  = "${env.BRANCH_NAME?.startsWith('release/') ? 'true' : 'false'}"
    IS_FEATURE_BRANCH  = "${env.BRANCH_NAME?.startsWith('feature/') ? 'true' : 'false'}"
    IS_PULL_REQUEST    = "${env.CHANGE_ID ? 'true' : 'false'}"

    // Tag única baseada no branch e commit (para imagens Docker)
    DOCKER_TAG = "${env.BRANCH_NAME?.replaceAll('/', '-')}-${env.BUILD_NUMBER}"
  }

  stages {

    stage('Identificar Contexto') {
      steps {
        script {
          echo """
=== CONTEXTO DO BUILD ===
Branch:        ${env.BRANCH_NAME}
É main:        ${env.IS_MAIN_BRANCH}
É release:     ${env.IS_RELEASE_BRANCH}
É feature:     ${env.IS_FEATURE_BRANCH}
É PR:          ${env.IS_PULL_REQUEST}
PR Number:     ${env.CHANGE_ID ?: 'N/A'}
PR Target:     ${env.CHANGE_TARGET ?: 'N/A'}
PR Source:     ${env.CHANGE_BRANCH ?: 'N/A'}
Docker Tag:    ${env.DOCKER_TAG}
          """
        }
      }
    }

    // ---------------------------------------------------------
    // STAGE: Build — executa em TODOS os branches
    // ---------------------------------------------------------
    stage('Build') {
      steps {
        echo "🔨 Build do branch: ${env.BRANCH_NAME}"
        sh 'echo "Build simulado"'
      }
    }

    // ---------------------------------------------------------
    // STAGE: Testes — executa em TODOS os branches
    // ---------------------------------------------------------
    stage('Testes') {
      steps {
        echo "🧪 Testes no branch: ${env.BRANCH_NAME}"
        sh 'echo "Testes simulados: 100% passou"'
      }
    }

    // ---------------------------------------------------------
    // STAGE: Análise de PR — apenas em Pull Requests
    // Executa análise extra quando é um PR
    // ---------------------------------------------------------
    stage('Análise de PR') {
      when {
        changeRequest()  // Só em Pull Requests / Change Requests
      }
      steps {
        echo "🔍 Analisando PR #${env.CHANGE_ID}"
        echo "PR: ${env.CHANGE_BRANCH} → ${env.CHANGE_TARGET}"
        sh 'echo "Checklist de PR: APROVADO"'
        // Aqui ficaria: análise de cobertura, diff de performance, etc.
      }
    }

    // ---------------------------------------------------------
    // STAGE: Docker Build — em main e release branches
    // Feature branches não precisam de imagem Docker
    // ---------------------------------------------------------
    stage('Docker Build') {
      when {
        anyOf {
          branch 'main'
          branch 'develop'
          expression { env.BRANCH_NAME?.startsWith('release/') }
        }
      }
      steps {
        echo "🐳 Building Docker image: minha-app:${DOCKER_TAG}"
        sh "echo 'docker build -t minha-app:${DOCKER_TAG} .'"
      }
    }

    // ---------------------------------------------------------
    // STAGE: Deploy em Staging — apenas no branch develop
    // ---------------------------------------------------------
    stage('Deploy Staging') {
      when {
        branch 'develop'
      }
      steps {
        echo "🚀 Deploy automático em Staging (branch develop)"
        sh 'echo "Deploy em staging concluído"'
      }
    }

    // ---------------------------------------------------------
    // STAGE: Deploy em Produção — apenas no branch main
    // Requer aprovação manual
    // ---------------------------------------------------------
    stage('Deploy Produção') {
      when {
        branch 'main'
      }
      steps {
        echo "⚠️  Aguardando aprovação para deploy em PRODUÇÃO..."
        timeout(time: 24, unit: 'HOURS') {
          input(
            message: "Confirma deploy da versão ${DOCKER_TAG} em PRODUÇÃO?",
            ok: 'Aprovar Deploy',
            submitter: 'admin,tech-lead,release-manager'
          )
        }
        echo "✅ Aprovado! Fazendo deploy em produção..."
        sh 'echo "Deploy em produção concluído"'
      }
    }

    // ---------------------------------------------------------
    // STAGE: Release — apenas em branches release/*
    // ---------------------------------------------------------
    stage('Criar Release') {
      when {
        expression { env.BRANCH_NAME?.startsWith('release/') }
      }
      steps {
        script {
          def versao = env.BRANCH_NAME.replace('release/', '')
          echo "📦 Criando release ${versao}"
          sh "echo 'git tag -a v${versao} -m \"Release ${versao}\"'"
          sh "echo 'git push origin v${versao}'"
        }
      }
    }

  } // Fecha stages

  post {
    success {
      script {
        // Notificação diferente por branch
        if (env.BRANCH_NAME == 'main') {
          echo "🎉 Build de PRODUÇÃO passou! Notificando o time inteiro..."
        } else if (env.CHANGE_ID) {
          echo "✅ PR #${env.CHANGE_ID} aprovado no CI!"
        } else {
          echo "✅ Build do branch ${env.BRANCH_NAME} passou"
        }
      }
    }
    failure {
      script {
        if (env.BRANCH_NAME == 'main') {
          echo "🚨 ALERTA CRÍTICO: build do MAIN falhou! Ação imediata necessária!"
        } else {
          echo "❌ Build do branch ${env.BRANCH_NAME} falhou"
        }
      }
    }
  }

} // Fecha pipeline
