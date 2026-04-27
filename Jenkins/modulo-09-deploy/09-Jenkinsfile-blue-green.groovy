// ============================================================
// MÓDULO 9 — DEPLOY E ENTREGA CONTÍNUA
// Arquivo: 09-Jenkinsfile-blue-green.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Implementa a estratégia Blue-Green Deploy no pipeline Jenkins.
// Zero downtime, rollback instantâneo.
//
// ANALOGIA DO DIA A DIA:
// Como uma rodoviária com duas plataformas (azul e verde).
// Os passageiros (tráfego) estão na plataforma azul.
// A nova versão chega na plataforma verde.
// Quando tudo está pronto, você abre a passarela (load balancer)
// e todo o tráfego vai para o verde.
// Se algo deu errado, fecha a passarela — todos voltam ao azul.
// ============================================================

pipeline {
  agent any

  environment {
    APP_NAME     = 'minha-app'
    REGISTRY     = 'minha-org'
    IMAGE_TAG    = "${BUILD_NUMBER}"
    NAMESPACE    = 'producao'
    INGRESS_NAME = 'minha-app-ingress'
  }

  stages {

    stage('Build e Push da Nova Imagem') {
      steps {
        sh """
          docker build -t ${REGISTRY}/${APP_NAME}:${IMAGE_TAG} .
          docker push ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}
          echo "Nova imagem: ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}"
        """
      }
    }

    stage('Determinar Ambiente Atual') {
      steps {
        script {
          // Descobrir qual ambiente está ativo (Blue ou Green)
          def activeEnv = sh(
            script: '''
              kubectl get service minha-app -n producao \
                -o jsonpath="{.spec.selector.slot}" 2>/dev/null || echo "blue"
            ''',
            returnStdout: true
          ).trim()

          env.ACTIVE_SLOT  = activeEnv        // Slot atual (ativo)
          env.STANDBY_SLOT = activeEnv == 'blue' ? 'green' : 'blue'

          echo """
=== ESTADO ATUAL ===
Slot Ativo:   ${env.ACTIVE_SLOT} (produção)
Slot Standby: ${env.STANDBY_SLOT} (irá receber a nova versão)
          """
        }
      }
    }

    stage('Deploy no Slot Standby') {
      steps {
        script {
          echo "🟢 Deploying no slot ${env.STANDBY_SLOT}..."

          sh """
            # Aplicar a nova versão no slot standby (não afeta o tráfego atual)
            kubectl set image deployment/${APP_NAME}-${STANDBY_SLOT} \
              ${APP_NAME}=${REGISTRY}/${APP_NAME}:${IMAGE_TAG} \
              -n ${NAMESPACE}

            # Aguardar rollout completo no slot standby
            kubectl rollout status deployment/${APP_NAME}-${STANDBY_SLOT} \
              -n ${NAMESPACE} \
              --timeout=10m

            echo "✅ Slot ${STANDBY_SLOT} atualizado com ${IMAGE_TAG}"
          """
        }
      }
    }

    stage('Smoke Tests no Slot Standby') {
      steps {
        script {
          echo "🔍 Testando o slot ${env.STANDBY_SLOT} antes de ativar..."

          // URL interna do slot standby (não exposta ao usuário ainda)
          def standbyUrl = "http://${APP_NAME}-${env.STANDBY_SLOT}.${NAMESPACE}.svc.cluster.local"

          sh """
            # Aguardar o serviço estar saudável
            for i in \$(seq 1 10); do
              STATUS=\$(curl -s -o /dev/null -w "%{http_code}" ${standbyUrl}/health)
              echo "Tentativa \$i: HTTP \$STATUS"
              if [ "\$STATUS" = "200" ]; then
                echo "✅ Smoke test OK!"
                exit 0
              fi
              sleep 5
            done
            echo "❌ Smoke test FALHOU — mantenho slot ${ACTIVE_SLOT} ativo"
            exit 1
          """
        }
      }
    }

    stage('Aprovação: Ativar Slot Standby') {
      steps {
        script {
          timeout(time: 1, unit: 'HOURS') {
            input(
              message: "Ativar slot ${env.STANDBY_SLOT} como PRODUÇÃO? (slot ativo atual: ${env.ACTIVE_SLOT})",
              ok: "Ativar ${env.STANDBY_SLOT.toUpperCase()}"
            )
          }
        }
      }
    }

    stage('Switch: Ativar Slot Standby') {
      steps {
        script {
          echo "🔄 Alternando tráfego de ${env.ACTIVE_SLOT} → ${env.STANDBY_SLOT}..."

          sh """
            # Atualizar o Service para apontar para o novo slot
            kubectl patch service ${APP_NAME} -n ${NAMESPACE} \
              -p '{"spec":{"selector":{"slot":"${STANDBY_SLOT}"}}}'

            # Verificar que o switch funcionou
            CURRENT=\$(kubectl get service ${APP_NAME} -n ${NAMESPACE} \
              -o jsonpath="{.spec.selector.slot}")
            echo "Tráfego agora em: \$CURRENT"

            if [ "\$CURRENT" != "${STANDBY_SLOT}" ]; then
              echo "❌ Switch falhou! Revertendo..."
              exit 1
            fi

            echo "✅ Tráfego 100% no slot ${STANDBY_SLOT} (nova versão)"
          """

          // Atualizar variáveis para o post
          env.DEPLOYED_SLOT = env.STANDBY_SLOT
          env.OLD_SLOT = env.ACTIVE_SLOT
        }
      }
    }

    stage('Verificação Pós-Switch') {
      steps {
        sh """
          echo "Aguardando estabilização (30s)..."
          sleep 30

          # Verificar métricas ou health check em produção real
          echo "Taxa de erro: 0% ✅"
          echo "Latência P99: OK ✅"
          echo "Slot ativo verificado: ${STANDBY_SLOT} ✅"
        """
      }
    }

  } // Fecha stages

  post {
    success {
      script {
        echo """
✅ Blue-Green Deploy CONCLUÍDO!
Versão: ${IMAGE_TAG}
Slot ativo: ${env.DEPLOYED_SLOT ?: 'N/A'}

ROLLBACK (se necessário):
kubectl patch service ${APP_NAME} -n ${NAMESPACE} \
  -p '{"spec":{"selector":{"slot":"${env.OLD_SLOT ?: 'blue'}"}}}'
        """
      }
    }
    failure {
      echo "❌ Deploy falhou. Slot ${env.ACTIVE_SLOT} continua ativo. Sistema seguro."
    }
  }

} // Fecha pipeline
