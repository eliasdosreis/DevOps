// ============================================================
// MÓDULO 12 — MONITORAMENTO E OBSERVABILIDADE
// Arquivo: 12-Jenkinsfile-notificacao-email.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Notificações por email com templates HTML e anexos.
// ============================================================

pipeline {
  agent any

  stages {

    stage('Build') {
      steps {
        echo "Build executado"
        sh 'mkdir -p reports && echo "<h1>Relatório de Build</h1>" > reports/build-report.html'
      }
    }

  } // Fecha stages

  post {

    // Email simples — plugin mail padrão
    always {
      mail(
        to:      'time-dev@empresa.com',
        subject: "[Jenkins] ${currentBuild.result ?: 'SUCCESS'} - ${JOB_NAME} #${BUILD_NUMBER}",
        body:    """
Build Status: ${currentBuild.result ?: 'SUCCESS'}
Job: ${JOB_NAME}
Build: #${BUILD_NUMBER}
Branch: ${env.BRANCH_NAME ?: 'N/A'}
Duração: ${currentBuild.durationString}
URL: ${BUILD_URL}

Veja os logs completos em: ${BUILD_URL}console
        """
      )
    }

    // Email HTML avançado — plugin email-ext
    failure {
      emailext(
        to:           'time-dev@empresa.com, devops@empresa.com',
        subject:      "❌ FALHA - ${JOB_NAME} #${BUILD_NUMBER}",
        mimeType:     'text/html',

        // Template HTML embutido
        body:         '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; background: #f4f4f4;">
  <div style="max-width: 600px; margin: 20px auto; background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #e74c3c;">
    <h2 style="color: #e74c3c;">❌ Build Falhou!</h2>
    <table style="width: 100%; border-collapse: collapse;">
      <tr>
        <td style="padding: 8px; font-weight: bold;">Job:</td>
        <td>${JOB_NAME}</td>
      </tr>
      <tr style="background: #f9f9f9;">
        <td style="padding: 8px; font-weight: bold;">Build:</td>
        <td>#${BUILD_NUMBER}</td>
      </tr>
      <tr>
        <td style="padding: 8px; font-weight: bold;">Branch:</td>
        <td>${GIT_BRANCH}</td>
      </tr>
      <tr style="background: #f9f9f9;">
        <td style="padding: 8px; font-weight: bold;">Autor:</td>
        <td>${GIT_AUTHOR_NAME}</td>
      </tr>
      <tr>
        <td style="padding: 8px; font-weight: bold;">Duração:</td>
        <td>${currentBuild.durationString}</td>
      </tr>
    </table>
    <br>
    <a href="${BUILD_URL}console" style="background: #e74c3c; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">
      Ver Log Completo
    </a>
    <br><br>
    <p style="color: gray; font-size: 12px;">Jenkins CI/CD System — ${JENKINS_URL}</p>
  </div>
</body>
</html>
        ''',

        // Destinatários do commit que quebrou o build
        recipientProviders: [
          [$class: 'DevelopersRecipientProvider'],    // Autor do commit
          [$class: 'RequesterRecipientProvider'],     // Quem iniciou o build
          [$class: 'FirstFailingBuildSuspectProvider'] // Suspeito do primeiro build falho
        ],

        // Anexar relatórios ao email
        attachmentsPattern: 'reports/*.html',
        attachLog: true,        // Anexa o log completo do build
        compressLog: true       // Comprime o log antes de anexar
      )
    }

    // Email apenas quando recuperar de falha
    fixed {
      emailext(
        to:      'time-dev@empresa.com',
        subject: "✅ RECUPERADO - ${JOB_NAME} #${BUILD_NUMBER}",
        body:    "Build voltou a funcionar após falha: ${BUILD_URL}"
      )
    }

  } // Fecha post

} // Fecha pipeline
