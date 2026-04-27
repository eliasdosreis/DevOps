// ============================================================
// MÓDULO 3 — VARIÁVEIS, PARÂMETROS E ENVIRONMENT
// Arquivo: 03-Jenkinsfile-environment.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o bloco 'environment' para definir variáveis customizadas:
// - No nível global (pipeline inteiro)
// - No nível de stage (apenas aquele stage)
// - Combinando variáveis
// - Usando variáveis de environment com credenciais
//
// ANALOGIA DO DIA A DIA:
// Variáveis de ambiente são como cartazes numa fábrica:
// "VELOCIDADE MÁXIMA: 15km/h" — todos os setores veem e obedecem.
// Você pode ter cartazes globais (vistos por todos) e locais
// (apenas para um setor específico).
// ============================================================

pipeline {
  agent any

  // ===========================================================
  // ENVIRONMENT GLOBAL: acessível em TODOS os stages
  // Definido no nível do pipeline
  // ===========================================================
  environment {
    // Variáveis simples
    APP_NAME    = 'minha-aplicacao'       // String simples
    APP_VERSION = '2.5.0'                 // String de versão
    APP_PORT    = '8080'                  // Número como string (sempre string no Jenkins)

    // Variáveis derivadas (usando outras variáveis)
    IMAGE_TAG   = "${APP_NAME}:${APP_VERSION}"    // "minha-aplicacao:2.5.0"
    ARTIFACT_ID = "${APP_NAME}-${BUILD_NUMBER}"   // "minha-aplicacao-42"

    // Variável derivada de variável built-in do Jenkins
    BUILD_INFO  = "Build ${BUILD_NUMBER} do job ${JOB_NAME}"

    // Credenciais (ID cadastrado no Credentials Store do Jenkins)
    // O formato varia conforme o tipo de credential:
    // DOCKER_CRED = credentials('docker-hub-creds')
    // → cria automaticamente: DOCKER_CRED_USR e DOCKER_CRED_PSW
  }

  stages {

    stage('Verificar Variáveis Globais') {
      steps {
        echo "=== VARIÁVEIS GLOBAIS ==="
        echo "App:      ${env.APP_NAME}"       // Usando env.VARIAVEL
        echo "Versão:   ${APP_VERSION}"         // Sem env. também funciona (dentro do pipeline)
        echo "Imagem:   ${IMAGE_TAG}"
        echo "Artefato: ${ARTIFACT_ID}"
        echo "Info:     ${BUILD_INFO}"

        sh '''
          # No shell, variáveis de ambiente ficam disponíveis normalmente
          echo "App Name:    $APP_NAME"
          echo "App Version: $APP_VERSION"
          echo "Image Tag:   $IMAGE_TAG"
        '''
      }
    }

    // ===========================================================
    // ENVIRONMENT DE STAGE: acessível apenas NESTE stage
    // Sobrescreve o global se tiver o mesmo nome
    // ===========================================================
    stage('Deploy em Dev') {
      environment {
        AMBIENTE       = 'desenvolvimento'        // Novo no escopo deste stage
        SERVER_URL     = 'http://dev.empresa.com' // URL específica de dev
        APP_VERSION    = '2.5.0-SNAPSHOT'         // SOBRESCREVE o global (apenas aqui)
        REPLICAS       = '1'                      // Dev usa apenas 1 réplica
      }
      steps {
        echo "=== VARIÁVEIS DO STAGE: Deploy Dev ==="
        echo "Ambiente:  ${AMBIENTE}"         // 'desenvolvimento'
        echo "Server:    ${SERVER_URL}"
        echo "Versão:    ${APP_VERSION}"      // '2.5.0-SNAPSHOT' (sobrescrita)
        echo "Réplicas:  ${REPLICAS}"
        echo "App Name:  ${APP_NAME}"         // 'minha-aplicacao' (do global — ainda acessível)

        sh '''
          echo "Deploying to: $SERVER_URL"
          echo "With $REPLICAS replica(s)"
          echo "Version: $APP_VERSION"
        '''
      }
    }

    stage('Deploy em Produção') {
      environment {
        AMBIENTE       = 'producao'
        SERVER_URL     = 'http://prod.empresa.com'
        REPLICAS       = '5'                      // Produção usa 5 réplicas
        // APP_VERSION NÃO sobrescrito aqui → usa o valor global: '2.5.0'
      }
      steps {
        echo "=== VARIÁVEIS DO STAGE: Deploy Prod ==="
        echo "Ambiente:  ${AMBIENTE}"         // 'producao'
        echo "Server:    ${SERVER_URL}"
        echo "Versão:    ${APP_VERSION}"      // '2.5.0' (global — não sobrescrito)
        echo "Réplicas:  ${REPLICAS}"         // '5'
      }
    }

    stage('Boas Práticas de Nomenclatura') {
      steps {
        script {
          // ==================================================
          // CONVENÇÕES DE NOMENCLATURA
          // ==================================================

          // SNAKE_CASE em maiúsculas: padrão para variáveis de ambiente
          // ✅ APP_NAME, BUILD_VERSION, DOCKER_IMAGE_TAG
          // ❌ appName, dockerImageTag, build-version

          // Prefixos por categoria:
          // APP_*       → configurações da aplicação
          // DOCKER_*    → configurações Docker
          // AWS_*       → configurações AWS
          // DB_*        → configurações de banco de dados
          // SLACK_*     → configurações de notificações

          echo "=== CONVENÇÕES DE NOMENCLATURA ==="
          echo "Variáveis de ambiente: SNAKE_CASE_MAIÚSCULAS"
          echo "Variáveis Groovy:      camelCase"

          // Variáveis Groovy (locais ao bloco script)
          def buildTimestamp = new Date().format("yyyy-MM-dd'T'HH:mm:ss")
          def imageFullTag   = "${env.APP_NAME}:${env.APP_VERSION}-${buildTimestamp}"

          echo "Tag completa: ${imageFullTag}"
        }
      }
    }

    stage('Verificar Precedência de Variáveis') {
      steps {
        script {
          // ORDEM DE PRECEDÊNCIA (da maior para a menor):
          // 1. Variáveis definidas com withEnv { } (local ao bloco)
          // 2. Variáveis do bloco environment { } do stage
          // 3. Variáveis do bloco environment { } do pipeline
          // 4. Variáveis de ambiente do sistema operacional
          // 5. Variáveis built-in do Jenkins

          // Uma variável mais específica SEMPRE sobrescreve a mais geral
          echo "Precedência de variáveis verificada nos stages anteriores"

          // Exemplo de verificação com getBinding ou env.getProperty:
          def appName = env.APP_NAME
          echo "APP_NAME atual: ${appName}"
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// DIFERENÇA ENTRE env.VARIAVEL e VARIAVEL dentro do pipeline:
//
// Dentro do Jenkinsfile (Groovy):
//   env.APP_NAME == "${APP_NAME}"  // Ambos funcionam
//
// Dentro do shell (sh '...'):
//   $APP_NAME funciona (export automático pelo Jenkins)
//   ${env.APP_NAME} NÃO funciona (isso é Groovy, não shell)
//
// ATENÇÃO: Variáveis Groovy (def) NÃO ficam disponíveis no shell!
//   def meuValor = 'teste'
//   sh 'echo $meuValor'  // ERRO: meuValor não é variável de ambiente
//
// Para usar uma variável Groovy no shell:
//   def meuValor = 'teste'
//   sh "echo ${meuValor}"   // Interpola ANTES de enviar ao shell
//   // ou
//   withEnv(["MEU_VALOR=${meuValor}"]) {
//     sh 'echo $MEU_VALOR'  // Agora é variável de ambiente
//   }
// ============================================================
