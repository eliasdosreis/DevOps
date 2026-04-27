// ============================================================
// MÓDULO 9 — DEPLOY E ENTREGA CONTÍNUA
// Arquivo: 09-Jenkinsfile-rollback.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra estratégias de rollback automatizado quando
// um deploy detecta problemas em produção.
//
// ANALOGIA DO DIA A DIA:
// Como um elevador com botão de emergência:
// Se o elevador (deploy) vai na direção errada,
// você aperta o botão (rollback) e ele volta ao andar anterior
// sem precisar subir até o topo primeiro.
// ============================================================

pipeline {
  agent any

  environment {
    APP_NAME    = 'minha-app'
    NAMESPACE   = 'producao'
    IMAGE_NAME  = "minha-org/${APP_NAME}"
    // Versão anterior (usada no rollback)
    PREV_IMAGE  = "${IMAGE_NAME}:${BUILD_NUMBER.toInteger() - 1}"
    CURR_IMAGE  = "${IMAGE_NAME}:${BUILD_NUMBER}"
  }

  parameters {
    booleanParam(
      name: 'SIMULAR_FALHA',
      defaultValue: false,
      description: 'Simula uma falha para testar o rollback automático'
    )
  }

  stages {

    stage('Deploy') {
      steps {
        script {
          echo "🚀 Deploying ${CURR_IMAGE}..."

          sh """
            kubectl set image deployment/${APP_NAME} \
              ${APP_NAME}=${CURR_IMAGE} \
              -n ${NAMESPACE}

            kubectl rollout status deployment/${APP_NAME} \
              -n ${NAMESPACE} \
              --timeout=5m
          """

          echo "✅ Deploy concluído. Iniciando verificação de saúde..."
        }
      }
    }

    stage('Verificação de Saúde Pós-Deploy') {
      steps {
        script {
          def falhaSaude = params.SIMULAR_FALHA

          sh """
            echo "Aguardando aplicação estabilizar (60s)..."
            sleep 5  # Reduzido para simulação — use 60 em produção

            echo "Verificando métricas..."
          """

          // Simular verificação de saúde
          if (falhaSaude) {
            echo "❌ Taxa de erro em 38% — acima do threshold de 5%!"
            echo "❌ Score de saúde: REPROVADO"
            env.HEALTH_OK = 'false'
          } else {
            sh '''
              # Em produção: consultas reais ao Prometheus/Datadog
              TAXA_ERRO=$(curl -s "http://prometheus:9090/api/v1/query?query=rate(http_requests_total{status=~'5..'}[1m])" 2>/dev/null | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('data',{}).get('result',[{}])[0].get('value',[None,0])[1])" 2>/dev/null || echo "0")
              echo "Taxa de erro atual: ${TAXA_ERRO}%"
            '''
            echo "✅ Taxa de erro: 0.2% (abaixo do threshold de 5%)"
            echo "✅ P99 latência: 180ms (abaixo de 500ms)"
            echo "✅ Health check: PASSOU"
            env.HEALTH_OK = 'true'
          }
        }
      }
    }

    stage('Rollback Automático se Necessário') {
      when {
        expression { env.HEALTH_OK == 'false' }
      }
      steps {
        script {
          echo """
🚨 FALHA DETECTADA — INICIANDO ROLLBACK AUTOMÁTICO
================================================
Versão atual (com problema): ${CURR_IMAGE}
Revertendo para:             ${PREV_IMAGE}
          """

          // OPÇÃO 1: kubectl rollout undo (mais simples)
          sh """
            echo "Executando rollback kubernetes..."
            kubectl rollout undo deployment/${APP_NAME} -n ${NAMESPACE}
            kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=5m
            echo "✅ Rollback concluído"
          """

          // OPÇÃO 2: kubectl set image com versão anterior (mais explícito)
          // sh """
          //   kubectl set image deployment/${APP_NAME} \
          //     ${APP_NAME}=${PREV_IMAGE} -n ${NAMESPACE}
          //   kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=5m
          // """

          // OPÇÃO 3: Helm rollback (se usando Helm)
          // sh "helm rollback ${APP_NAME} -n ${NAMESPACE}"

          // Marcar build como falho após o rollback
          currentBuild.result = 'FAILURE'
          error "Deploy revertido automaticamente! Investigação necessária."
        }
      }
    }

    stage('Confirmação de Sucesso') {
      when {
        expression { env.HEALTH_OK == 'true' }
      }
      steps {
        script {
          echo """
✅ DEPLOY VALIDADO COM SUCESSO!
================================
Versão: ${CURR_IMAGE}
Build:  ${BUILD_NUMBER}
Status: ESTÁVEL em produção
          """

          // Opcional: criar tag de "deploy confirmado" no Git
          sh """
            echo "git tag -a deploy-prod-${BUILD_NUMBER} -m 'Deploy validado em produção'"
            echo "git push origin deploy-prod-${BUILD_NUMBER}"
          """
        }
      }
    }

  } // Fecha stages

  post {
    failure {
      script {
        if (env.HEALTH_OK == 'false') {
          echo """
🚨 ALERTA DE ROLLBACK - AÇÃO NECESSÁRIA!
Versão problemática: ${CURR_IMAGE}
Rollback aplicado: ${PREV_IMAGE}
Build: ${BUILD_URL}
          """
          // slackSend(channel: '#alertas-prod', color: 'danger', message: "🚨 ROLLBACK em ${APP_NAME}!")
        }
      }
    }
  }

} // Fecha pipeline
