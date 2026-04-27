// ============================================================
// MÓDULO 7 — DOCKER E CONTAINERS NO PIPELINE
// Arquivo: 07-Jenkinsfile-docker-build.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Build de imagem Docker dentro do pipeline Jenkins.
// Demonstra: build simples, build com args, multi-stage,
// boas práticas de nomenclatura de tags.
//
// PRÉ-REQUISITO:
// - Docker instalado no agent Jenkins
// - Jenkins com acesso ao Docker socket (/var/run/docker.sock)
// ============================================================

pipeline {
  agent any

  environment {
    REGISTRY      = 'docker.io'           // Docker Hub (ou seu registry)
    IMAGE_NAME    = 'minha-org/minha-app' // org/nome-da-imagem
    // Tag única: garante que cada build tem uma identidade imutável
    IMAGE_TAG     = "${BUILD_NUMBER}-${sh(script: 'git rev-parse --short HEAD 2>/dev/null || echo unkn', returnStdout: true).trim()}"
    IMAGE_FULL    = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    IMAGE_LATEST  = "${REGISTRY}/${IMAGE_NAME}:latest"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Verificar Docker') {
      steps {
        sh '''
          docker version
          docker info | head -20
          echo "Docker disponível e funcionando"
        '''
      }
    }

    stage('Build Simples') {
      steps {
        echo "🐳 Building: ${IMAGE_FULL}"
        sh """
          docker build \
            --tag ${IMAGE_FULL} \
            --tag ${IMAGE_LATEST} \
            --label "build.number=${BUILD_NUMBER}" \
            --label "git.commit=${env.GIT_COMMIT ?: 'unknown'}" \
            --label "build.url=${BUILD_URL}" \
            .
        """
        // --tag: nome:tag da imagem (pode ter múltiplas tags)
        // --label: metadados da imagem (rastreabilidade)
      }
    }

    stage('Build com Build Args') {
      steps {
        echo "🐳 Build com argumentos customizados"
        sh """
          docker build \
            --tag ${IMAGE_FULL}-custom \
            --build-arg APP_VERSION=${BUILD_NUMBER} \
            --build-arg BUILD_DATE=\$(date -u +%Y-%m-%dT%H:%M:%SZ) \
            --build-arg GIT_COMMIT=${env.GIT_COMMIT ?: 'unknown'} \
            .
          # --build-arg: passa variáveis para o Dockerfile via ARG
          # Exemplo no Dockerfile:
          # ARG APP_VERSION
          # ENV APP_VERSION=\$APP_VERSION
        """
      }
    }

    stage('Build Multi-Stage (otimizado)') {
      steps {
        echo "🐳 Build multi-stage para imagem mínima"
        // Multi-stage build reduz drasticamente o tamanho da imagem final
        // O Dockerfile é o 07-Dockerfile-exemplo neste módulo
        sh """
          docker build \
            --target production \
            --tag ${IMAGE_FULL}-slim \
            --cache-from ${IMAGE_LATEST} \
            --build-arg BUILDKIT_INLINE_CACHE=1 \
            .
          # --target: escolhe o stage final do Dockerfile multi-stage
          # --cache-from: usa imagem existente como cache (mais rápido)
          # BUILDKIT_INLINE_CACHE: incorpora cache na imagem
        """
        // BUILDKIT é mais rápido que o builder clássico
        // Ative com: export DOCKER_BUILDKIT=1 ou use buildx
      }
    }

    stage('Inspecionar Imagem') {
      steps {
        sh """
          echo "=== INFORMAÇÕES DA IMAGEM ==="
          docker image inspect ${IMAGE_FULL} --format '{{json .Config.Labels}}' | python3 -m json.tool
          echo ""
          echo "Tamanho da imagem:"
          docker images ${IMAGE_NAME} --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"
        """
      }
    }

    stage('Testar Imagem Localmente') {
      steps {
        sh """
          echo "=== TESTE BÁSICO DA IMAGEM ==="
          # Rodar o container brevemente para verificar que não quebra na inicialização
          docker run --rm \
            --entrypoint=/bin/sh \
            ${IMAGE_FULL} \
            -c "echo 'Container iniciou com sucesso!'"

          # Teste de health check manual
          CONTAINER_ID=\$(docker run -d -p 18080:8080 ${IMAGE_FULL} 2>/dev/null || echo "skip")
          if [ "\$CONTAINER_ID" != "skip" ]; then
            sleep 5
            curl -f http://localhost:18080/health 2>/dev/null || echo "Health check não disponível"
            docker stop \$CONTAINER_ID
            docker rm \$CONTAINER_ID
          fi
        """
      }
    }

  } // Fecha stages

  post {
    always {
      // Limpeza: remove imagens locais após o build (economiza espaço)
      sh """
        docker rmi ${IMAGE_FULL} ${IMAGE_LATEST} ${IMAGE_FULL}-custom ${IMAGE_FULL}-slim 2>/dev/null || true
        docker system prune -f --filter label=build.number=${BUILD_NUMBER}
      """
    }
  }

} // Fecha pipeline
