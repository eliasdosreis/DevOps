// ============================================================
// MÓDULO 10 — SHARED LIBRARIES
// Arquivo: 10-Jenkinsfile-library-versionada.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra como usar versões específicas de uma Shared Library.
// Garante que o pipeline não quebra quando a library é atualizada.
// ============================================================

// Usando versão específica por tag Git
@Library('jenkins-shared-library@v2.1.0') _

// Usando versão por branch (mais flexível, mas menos estável)
// @Library('jenkins-shared-library@main') _

// Usando versão por commit hash (imutável — produção crítica)
// @Library('jenkins-shared-library@a3f9c12b') _

// Múltiplas libraries ao mesmo tempo:
// @Library(['jenkins-shared-library@v2.0', 'security-library@v1.0']) _

pipeline {
  agent any

  stages {

    stage('Usando buildApp da Library') {
      steps {
        // Chama a função 'buildApp' definida em vars/buildApp.groovy
        buildApp(tipo: 'maven', skipTests: true)
      }
    }

    stage('Usando deployApp da Library') {
      steps {
        // Chama 'deployApp' definida em vars/deployApp.groovy
        deployApp(
          ambiente:  'staging',
          imagem:    "minha-app:${BUILD_NUMBER}",
          aprovacao: false   // staging não precisa de aprovação
        )
      }
    }

    stage('Notificação via Library') {
      steps {
        // Chama 'notifySlack' definida em vars/notifySlack.groovy
        notifySlack(
          channel: '#ci-builds',
          mensagem: "Deploy do ${env.JOB_NAME} concluído!"
        )
      }
    }

    stage('Usando src/ da Library (classe Groovy)') {
      steps {
        script {
          // Classes em src/ precisam ser importadas explicitamente
          // def builder = new org.empresa.ci.Builder(this)
          // builder.buildMaven('-DskipTests')
          echo "Classes de src/ são importadas com o nome completo do pacote"
        }
      }
    }

  } // Fecha stages

  post {
    always {
      // notifySlack() sem argumentos auto-detecta o status do build
      notifySlack()
    }
  }

} // Fecha pipeline
