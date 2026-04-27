// ============================================================
// MÓDULO 7 — DOCKER E CONTAINERS NO PIPELINE
// Arquivo: 07-Jenkinsfile-docker-push.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline completo: Build → Push → Verificação
// Suporta Docker Hub, AWS ECR, Google GCR e Azure ACR.
// ============================================================

pipeline {
  agent any

  environment {
    IMAGE_NAME    = 'minha-org/minha-app'
    IMAGE_TAG     = "${BUILD_NUMBER}"
    // Tag semântica para releases em main
    SEMANTIC_TAG  = "v1.0.${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout e Build') {
      steps {
        checkout scm
        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
      }
    }

    // ---------------------------------------------------------
    // PUSH PARA DOCKER HUB
    // ---------------------------------------------------------
    stage('Push: Docker Hub') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'docker-hub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )
        ]) {
          sh """
            # Login no Docker Hub
            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin

            # Tag adicional 'latest' apenas no branch main
            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:${SEMANTIC_TAG}

            # Push de todas as tags
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
            docker push ${IMAGE_NAME}:${SEMANTIC_TAG}

            # Push 'latest' apenas no main
            if [ "${BRANCH_NAME}" = "main" ]; then
              docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
              docker push ${IMAGE_NAME}:latest
            fi

            docker logout
          """
        }
      }
    }

    // ---------------------------------------------------------
    // PUSH PARA AWS ECR (Elastic Container Registry)
    // ---------------------------------------------------------
    stage('Push: AWS ECR') {
      when {
        expression { false }  // Habilite quando usar AWS
      }
      environment {
        AWS_REGION     = 'us-east-1'
        ECR_REGISTRY   = "123456789.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPO       = "${ECR_REGISTRY}/minha-app"
      }
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
          )
        ]) {
          sh """
            # Login no ECR via AWS CLI
            aws ecr get-login-password --region ${AWS_REGION} | \
              docker login --username AWS --password-stdin ${ECR_REGISTRY}

            # Tag para ECR
            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}

            # Push
            docker push ${ECR_REPO}:${IMAGE_TAG}

            echo "Imagem disponível em: ${ECR_REPO}:${IMAGE_TAG}"
          """
        }
      }
    }

    // ---------------------------------------------------------
    // USO DO PLUGIN DOCKER PIPELINE (forma Groovy)
    // ---------------------------------------------------------
    stage('Push: usando docker DSL') {
      steps {
        script {
          // Forma mais elegante usando o plugin docker-workflow
          docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            def imagem = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")

            // Push com múltiplas tags
            imagem.push("${IMAGE_TAG}")
            imagem.push("${SEMANTIC_TAG}")

            if (env.BRANCH_NAME == 'main') {
              imagem.push('latest')
            }
          }
        }
      }
    }

    stage('Verificar Push') {
      steps {
        sh """
          echo "=== VERIFICANDO IMAGEM NO REGISTRY ==="
          docker pull ${IMAGE_NAME}:${IMAGE_TAG}
          docker image inspect ${IMAGE_NAME}:${IMAGE_TAG} --format 'Digest: {{.Id}}'
          echo "Push verificado com sucesso!"
        """
      }
    }

  } // Fecha stages

  post {
    always {
      sh """
        docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:${SEMANTIC_TAG} 2>/dev/null || true
        docker logout 2>/dev/null || true
      """
    }
  }

} // Fecha pipeline
