// ============================================================
// MÓDULO 2 — STAGES, STEPS E FLOW CONTROL
// Arquivo: 02-Jenkinsfile-post.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o bloco 'post' com TODAS as condições disponíveis.
// O post define ações executadas APÓS o pipeline ou stage.
//
// ANALOGIA DO DIA A DIA:
// Como o fechamento de uma cirurgia:
// - always: o médico sempre lava as mãos (independente do resultado)
// - success: o médico comemora se a cirurgia deu certo
// - failure: aciona a equipe de suporte se algo deu errado
// - cleanup: limpa a sala cirúrgica no final (sempre)
// ============================================================

pipeline {
  agent any

  stages {

    stage('Build') {
      steps {
        echo '🔨 Executando build...'
        sh 'echo "Build concluído"'
      }

      // -------------------------------------------------------
      // POST DE STAGE: executa após ESTE stage específico
      // Útil para ações relacionadas a um stage em particular
      // -------------------------------------------------------
      post {
        success {
          echo '✅ Stage Build concluído com sucesso'
          // Aqui você poderia arquivar artefatos do build
          // archiveArtifacts artifacts: 'target/*.jar'
        }
        failure {
          echo '❌ Stage Build falhou — notificando o time'
          // Notificação imediata sobre falha no build
        }
      }
    }

    stage('Test') {
      steps {
        echo '🧪 Executando testes...'
        // Simulando execução de testes
        sh '''
          echo "PASSED: TestA"
          echo "PASSED: TestB"
          echo "PASSED: TestC"
        '''
      }

      post {
        always {
          // JUnit publica relatório de testes SEMPRE
          // Mesmo se alguns testes falharem, o relatório deve ser publicado
          echo 'Publicando relatório de testes...'
          // junit 'target/surefire-reports/*.xml'  // Descomente em projeto real
        }
        unstable {
          echo '⚠️  Alguns testes falharam — build marcado como UNSTABLE'
          // O status UNSTABLE indica: build compilou, mas testes têm falhas
        }
      }
    }

    stage('Deploy') {
      steps {
        echo '🚀 Fazendo deploy...'
        sh 'echo "Deploy simulado"'
      }
    }

  } // Fecha stages

  // ===========================================================
  // POST DO PIPELINE: executa após o pipeline inteiro
  // Ordem de verificação das condições:
  // always → changed → fixed → regression → aborted →
  // failure → success → unstable → unsuccessful → cleanup
  // ===========================================================
  post {

    // -------------------------------------------------------
    // always: SEMPRE executa, independente do resultado
    // Use para: limpeza de workspace, notificação base, métricas
    // -------------------------------------------------------
    always {
      echo '📋 [ALWAYS] Build finalizado — executando ações obrigatórias'
      echo "Status atual: ${currentBuild.result ?: 'SUCCESS'}"
      echo "Duração: ${currentBuild.durationString}"
      // cleanWs()  // Limpa o workspace — bom para economizar disco
    }

    // -------------------------------------------------------
    // success: executa quando o build TERMINA COM SUCESSO
    // -------------------------------------------------------
    success {
      echo '✅ [SUCCESS] Pipeline concluído com sucesso!'
      // emailext(
      //   to: 'time@empresa.com',
      //   subject: "✅ Build ${BUILD_NUMBER} - Sucesso",
      //   body: "O pipeline ${JOB_NAME} foi concluído com sucesso."
      // )
    }

    // -------------------------------------------------------
    // failure: executa quando o build FALHA
    // Prioridade máxima de notificação — alguém precisa agir!
    // -------------------------------------------------------
    failure {
      echo '❌ [FAILURE] Pipeline FALHOU! Ação necessária.'
      // slackSend(
      //   channel: '#alertas-ci',
      //   color: 'danger',
      //   message: "❌ FALHA no build ${BUILD_NUMBER} do job ${JOB_NAME}"
      // )
    }

    // -------------------------------------------------------
    // unstable: executa quando o build é INSTÁVEL
    // Significa: compilou, mas testes falharam ou quality gate não passou
    // -------------------------------------------------------
    unstable {
      echo '⚠️  [UNSTABLE] Build instável — investigate os testes falhos'
    }

    // -------------------------------------------------------
    // aborted: executa quando o build é CANCELADO manualmente
    // -------------------------------------------------------
    aborted {
      echo '🚫 [ABORTED] Build cancelado pelo usuário ou timeout'
    }

    // -------------------------------------------------------
    // changed: executa quando o status MUDOU em relação ao build anterior
    // Muito útil: notifica quando o build VOLTOU a funcionar ou QUEBROU
    // -------------------------------------------------------
    changed {
      echo '🔄 [CHANGED] Status do build mudou em relação ao anterior!'
      script {
        if (currentBuild.result == 'SUCCESS' && currentBuild.previousBuild?.result != 'SUCCESS') {
          echo '🎉 Build RECUPERADO! (estava falhando, agora passou)'
        } else if (currentBuild.result != 'SUCCESS' && currentBuild.previousBuild?.result == 'SUCCESS') {
          echo '💥 Build QUEBROU! (estava passando, agora falhou)'
        }
      }
    }

    // -------------------------------------------------------
    // fixed: executa quando o build VOLTOU A FUNCIONAR
    // (era failure/unstable, agora é success)
    // -------------------------------------------------------
    fixed {
      echo '🔧 [FIXED] Build recuperado! Era falho, agora passou.'
    }

    // -------------------------------------------------------
    // regression: executa quando o build PAROU DE FUNCIONAR
    // (era success, agora é failure/unstable)
    // -------------------------------------------------------
    regression {
      echo '📉 [REGRESSION] Regressão detectada! Build que funcionava, falhou.'
    }

    // -------------------------------------------------------
    // cleanup: SEMPRE executa, mas POR ÚLTIMO
    // Use para limpeza garantida após todas as outras ações
    // -------------------------------------------------------
    cleanup {
      echo '🧹 [CLEANUP] Limpeza final — sempre é o último a executar'
      // cleanWs()  // Limpar workspace aqui garante que acontece sempre
    }

  } // Fecha post do pipeline

} // Fecha pipeline

// ============================================================
// TABELA: CONDIÇÕES DO BLOCO POST
//
// | Condição    | Quando executa                               |
// |-------------|----------------------------------------------|
// | always      | Sempre, independente do resultado            |
// | success     | Apenas quando SUCESSO                        |
// | failure     | Apenas quando FALHA                          |
// | unstable    | Apenas quando INSTÁVEL (testes falhos)       |
// | aborted     | Apenas quando CANCELADO                      |
// | changed     | Quando o status mudou em relação ao anterior |
// | fixed       | Passou de failure/unstable para success      |
// | regression  | Passou de success para failure/unstable      |
// | cleanup     | Sempre, mas DEPOIS de tudo                   |
//
// ORDEM DE EXECUÇÃO DAS CONDIÇÕES:
// always → changed → fixed → regression → aborted →
// failure → success → unstable → unsuccessful → cleanup
// ============================================================
