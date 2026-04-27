// ============================================================
// MÓDULO 1 — FUNDAMENTOS DE PIPELINE
// Arquivo: 01-Jenkinsfile-anatomia.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline com TODOS os elementos principais comentados.
// Use como referência e mapa mental da estrutura completa.
//
// ANALOGIA DO DIA A DIA:
// Como o mapa de um metrô: mostra todas as linhas e estações
// possíveis. Você não usa todas de uma vez, mas sabe que existem
// e para que servem.
// ============================================================

pipeline {
  // ===========================================================
  // BLOCO: agent                    [OBRIGATÓRIO no nível raiz]
  // Define ONDE o pipeline inteiro vai executar
  // Pode ser sobrescrito em cada stage individualmente
  // ===========================================================
  agent any
  // Opções de agent:
  //   agent any                          → Qualquer executor disponível
  //   agent none                         → Cada stage define seu próprio agent
  //   agent { label 'linux' }            → Executor com a label 'linux'
  //   agent { docker { image 'node:18' } } → Container Docker
  //   agent { kubernetes { yaml '...' } }  → Pod Kubernetes

  // ===========================================================
  // BLOCO: options                          [OPCIONAL]
  // Configurações globais de comportamento do pipeline
  // ===========================================================
  options {
    timeout(time: 30, unit: 'MINUTES')      // Cancela o build após 30 minutos
    buildDiscarder(logRotator(             // Política de retenção de builds
      numToKeepStr: '10',                  // Mantém apenas os últimos 10 builds
      artifactNumToKeepStr: '3'            // Mantém artefatos dos últimos 3 builds
    ))
    timestamps()                           // Adiciona timestamp em cada linha do log
    disableConcurrentBuilds()              // Impede execução paralela do mesmo pipeline
    retry(2)                               // Reexecuta até 2 vezes em caso de falha
    ansiColor('xterm')                     // Renderiza cores ANSI no console (plugin AnsiColor)
  }

  // ===========================================================
  // BLOCO: triggers                         [OPCIONAL]
  // Define quando o pipeline executa automaticamente
  // ===========================================================
  triggers {
    cron('H 2 * * 1-5')     // Executa todo dia de semana às ~2h (H = horário aleatório para distribuir carga)
    pollSCM('H/5 * * * *')  // Verifica mudanças no Git a cada 5 minutos
    // upstream(upstreamProjects: 'outro-job', threshold: hudson.model.Result.SUCCESS)
    //   → Executa quando outro job termina com sucesso
  }

  // ===========================================================
  // BLOCO: parameters                       [OPCIONAL]
  // Define parâmetros de entrada que o usuário pode fornecer
  // antes de iniciar o build
  // ===========================================================
  parameters {
    string(
      name: 'VERSAO',
      defaultValue: '1.0.0',
      description: 'Versão da aplicação a ser construída'
    )
    booleanParam(
      name: 'EXECUTAR_DEPLOY',
      defaultValue: false,
      description: 'Marque para executar o deploy após o build'
    )
    choice(
      name: 'AMBIENTE',
      choices: ['desenvolvimento', 'homologacao', 'producao'],
      description: 'Ambiente alvo do deploy'
    )
  }

  // ===========================================================
  // BLOCO: environment                      [OPCIONAL]
  // Define variáveis de ambiente acessíveis em todos os stages
  // ===========================================================
  environment {
    APP_NAME    = 'minha-aplicacao'             // Variável customizada simples
    VERSAO_APP  = "${params.VERSAO}"            // Valor vindo de um parâmetro
    BUILD_TAG   = "${APP_NAME}-${BUILD_NUMBER}" // Combina variável custom + variável built-in
    // DOCKER_TOKEN = credentials('docker-hub-token')  // Carrega uma credential (Módulo 4)
  }

  // ===========================================================
  // BLOCO: stages                  [OBRIGATÓRIO]
  // Container de todos os stages. Um pipeline deve ter
  // pelo menos um stage com pelo menos um step.
  // ===========================================================
  stages {

    // =========================================================
    // STAGE: Verificação de Ambiente
    // Boas práticas: primeiro stage imprime contexto do build
    // Facilita debug quando algo dá errado
    // =========================================================
    stage('Verificação de Ambiente') {
      steps {
        // echo imprime texto simples no log
        echo "=== INICIANDO BUILD ==="
        echo "Aplicação:    ${env.APP_NAME}"
        echo "Versão:       ${env.VERSAO_APP}"
        echo "Build Number: ${env.BUILD_NUMBER}"
        echo "Branch:       ${env.GIT_BRANCH ?: 'N/A'}"
        echo "Build Tag:    ${env.BUILD_TAG}"
        echo "Workspace:    ${env.WORKSPACE}"
        echo "Ambiente:     ${params.AMBIENTE}"

        // script { } permite executar código Groovy puro dentro do Declarativo
        script {
          def buildInfo = [
            app: env.APP_NAME,
            version: env.VERSAO_APP,
            build: env.BUILD_NUMBER
          ]
          echo "Build Info: ${buildInfo}"
        }
      }
    }

    // =========================================================
    // STAGE: Build
    // Compilação e empacotamento da aplicação
    // =========================================================
    stage('Build') {
      steps {
        echo "Compilando ${APP_NAME} versão ${VERSAO_APP}..."
        // Em produção, aqui ficaria: sh 'mvn clean package' ou sh 'npm run build'
        sh 'echo "Simulando build..." && sleep 2'
      }
    }

    // =========================================================
    // STAGE: Test
    // Execução de testes automatizados
    // =========================================================
    stage('Test') {
      steps {
        echo 'Executando testes automatizados...'
        sh '''
          echo "Rodando testes unitários..."
          echo "Testes: 42 passaram, 0 falharam"
        '''
        // sh com triple-quote (''') permite scripts multi-linha
        // Cada linha é executada em sequência no mesmo shell
      }
    }

    // =========================================================
    // STAGE: Deploy (condicional)
    // Só executa se o parâmetro EXECUTAR_DEPLOY for true
    // =========================================================
    stage('Deploy') {
      when {                                        // Condição para execução do stage
        expression { params.EXECUTAR_DEPLOY == true }  // Executa apenas se parâmetro for true
      }
      steps {
        echo "Fazendo deploy para ${params.AMBIENTE}..."
        echo "Deploying ${BUILD_TAG}..."
      }
    }

  } // Fecha stages

  // ===========================================================
  // BLOCO: post                             [OPCIONAL]
  // Ações executadas APÓS a conclusão do pipeline
  // Sempre executa, independente de sucesso ou falha
  // ===========================================================
  post {

    always {      // Executa SEMPRE (sucesso, falha, abortado, instável)
      echo "📋 Build ${BUILD_NUMBER} finalizado"
      // cleanWs()  // Limpa o workspace (útil para economizar espaço em disco)
    }

    success {     // Executa apenas quando o build termina com SUCESSO
      echo "✅ Pipeline ${APP_NAME} concluído com sucesso!"
      // emailext(to: 'time@empresa.com', subject: 'Build OK', body: '...')
    }

    failure {     // Executa apenas quando o build FALHA
      echo "❌ Pipeline ${APP_NAME} FALHOU! Verifique os logs."
      // slackSend(channel: '#alertas', message: 'BUILD FALHOU! :x:')
    }

    unstable {    // Executa quando o build é INSTÁVEL (testes falharam, mas build não quebrou)
      echo "⚠️  Pipeline ${APP_NAME} instável (testes com falhas)"
    }

    aborted {     // Executa quando o build foi ABORTADO manualmente
      echo "🚫 Pipeline ${APP_NAME} foi cancelado"
    }

    changed {     // Executa quando o status mudou em relação ao build anterior
      echo "🔄 Status do build mudou em relação ao anterior!"
      // Útil para notificar apenas quando algo muda (não em cada build)
    }

  } // Fecha post

} // Fecha pipeline

// ============================================================
// MAPA MENTAL — HIERARQUIA DO PIPELINE DECLARATIVO:
//
// pipeline {
//   agent { }                ← ONDE executa (obrigatório)
//   options { }              ← COMO executa (opcional)
//   triggers { }             ← QUANDO executa automaticamente (opcional)
//   parameters { }           ← ENTRADA do usuário (opcional)
//   environment { }          ← VARIÁVEIS globais (opcional)
//   stages {                 ← ETAPAS (obrigatório)
//     stage('nome') {        ← Uma etapa
//       agent { }            ← ONDE este stage executa (sobrescreve o global)
//       when { }             ← CONDIÇÃO para executar (opcional)
//       options { }          ← Opções do stage (opcional)
//       environment { }      ← Variáveis do stage (opcional)
//       steps { }            ← O QUE fazer (obrigatório no stage)
//       post { }             ← O que fazer DEPOIS do stage (opcional)
//     }
//   }
//   post { }                 ← O que fazer DEPOIS do pipeline (opcional)
// }
// ============================================================
