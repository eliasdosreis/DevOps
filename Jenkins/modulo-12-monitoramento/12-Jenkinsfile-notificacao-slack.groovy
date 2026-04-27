// ============================================================
// MÓDULO 12 — MONITORAMENTO E OBSERVABILIDADE
// Arquivo: 12-Jenkinsfile-notificacao-slack.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Notificações ricas no Slack com status do build,
// informações de branch, duração e link direto.
// ============================================================

pipeline {
  agent any

  environment {
    SLACK_CHANNEL = '#ci-builds'
    SLACK_CHANNEL_ALERTAS = '#alertas-producao'
    APP_NAME = 'minha-app'
  }

  stages {

    stage('Build') {
      steps {
        echo "Executando build..."
        sh 'sleep 2'  // Simula trabalho
      }
    }

    stage('Notificação de Início') {
      steps {
        // Notificação ao iniciar (opcional — pode sobrecarregar o canal)
        slackSend(
          channel:  env.SLACK_CHANNEL,
          color:    '#3498db',           // Azul = em andamento
          message:  "🔵 Build iniciado\n*Job:* ${JOB_NAME} #${BUILD_NUMBER}\n*Branch:* ${env.BRANCH_NAME ?: 'N/A'}"
        )
      }
    }

    stage('Testes') {
      steps {
        echo "Executando testes..."
        sh 'sleep 3'
      }
    }

    stage('Deploy') {
      when { branch 'main' }
      steps {
        echo "Deploying..."
        sh 'sleep 2'
      }
    }

  } // Fecha stages

  post {

    // Notificação de SUCESSO
    success {
      slackSend(
        channel: env.SLACK_CHANNEL,
        color:   'good',             // Verde
        blocks: groovy.json.JsonOutput.toJson([
          [
            type: 'section',
            text: [
              type: 'mrkdwn',
              text: "✅ *Build Concluído com Sucesso!*"
            ]
          ],
          [
            type: 'section',
            fields: [
              [type: 'mrkdwn', text: "*Job:*\n${JOB_NAME}"],
              [type: 'mrkdwn', text: "*Build:*\n#${BUILD_NUMBER}"],
              [type: 'mrkdwn', text: "*Branch:*\n${env.BRANCH_NAME ?: 'N/A'}"],
              [type: 'mrkdwn', text: "*Duração:*\n${currentBuild.durationString}"]
            ]
          ],
          [
            type: 'actions',
            elements: [[
              type: 'button',
              text: [type: 'plain_text', text: '🔗 Ver Build'],
              url: env.BUILD_URL
            ]]
          ]
        ])
      )
    }

    // Notificação de FALHA (mais urgente — canal diferente)
    failure {
      slackSend(
        channel: env.SLACK_CHANNEL_ALERTAS,  // Canal de alertas para falhas!
        color:   'danger',                    // Vermelho
        message: """🚨 *BUILD FALHOU!*
*Job:* ${JOB_NAME}
*Build:* #${BUILD_NUMBER}
*Branch:* ${env.BRANCH_NAME ?: 'N/A'}
*Autor:* ${env.GIT_AUTHOR_NAME ?: 'N/A'}
*Link:* ${BUILD_URL}

@channel Ação necessária!"""
      )
    }

    // Notificação de RECUPERAÇÃO (build voltou a funcionar)
    fixed {
      slackSend(
        channel: env.SLACK_CHANNEL_ALERTAS,
        color:   'good',
        message: "🔧 *BUILD RECUPERADO!* ${JOB_NAME} #${BUILD_NUMBER} voltou a funcionar.\n${BUILD_URL}"
      )
    }

    // Notificação de INSTÁVEL
    unstable {
      slackSend(
        channel: env.SLACK_CHANNEL,
        color:   'warning',  // Amarelo
        message: "⚠️ Build INSTÁVEL: ${JOB_NAME} #${BUILD_NUMBER} — testes com falhas\n${BUILD_URL}"
      )
    }

  } // Fecha post

} // Fecha pipeline

// ============================================================
// CONFIGURAR SLACK NO JENKINS:
//
// 1. No Slack:
//    Apps → Add App → Jenkins CI → Add to Slack
//    Escolha o canal padrão → copie o Integration Token
//
// 2. No Jenkins:
//    - Instale o plugin "Slack Notification"
//    - Manage Jenkins → System → Slack
//    - Workspace: nome-do-seu-workspace
//    - Credential: Add → Secret text → cole o token
//    - Default channel: #ci-builds
//    - Test Connection → deve retornar "Success"
//
// 3. No Jenkinsfile:
//    slackSend(channel: '#ci-builds', message: 'Mensagem')
// ============================================================
