// ============================================================
// MÓDULO 5 — INTEGRAÇÃO COM GIT E SCM
// Arquivo: 05-Jenkinsfile-checkout.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra todas as formas de fazer checkout de repositórios Git.
// O checkout é o primeiro passo de qualquer pipeline real.
//
// ANALOGIA DO DIA A DIA:
// Como buscar os ingredientes no almoxarifado antes de cozinhar.
// O pipeline não tem o código — ele precisa "baixar" do repositório
// antes de poder compilar, testar e fazer deploy.
// ============================================================

pipeline {
  agent any

  environment {
    REPO_URL    = 'https://github.com/sua-org/sua-repo.git'
    BRANCH      = 'main'
  }

  stages {

    // ---------------------------------------------------------
    // MODO 1: checkout scm (automático — recomendado)
    // Usa as configurações do próprio job Jenkins.
    // Quando o job é configurado com "Pipeline script from SCM",
    // o Jenkins sabe qual repo/branch usar e checkout scm faz tudo.
    // ---------------------------------------------------------
    stage('Checkout: automático (scm)') {
      steps {
        echo "=== MODO 1: checkout scm (auto-configurado) ==="
        // checkout scm
        // Simples, limpo. O Jenkins já sabe o repo do Jenkinsfile.
        // Esta é a forma RECOMENDADA para pipelines from SCM.

        echo "Em projetos reais: substitua o checkout manual por: checkout scm"
      }
    }

    // ---------------------------------------------------------
    // MODO 2: git step simplificado
    // Conveniente para repositórios públicos ou com credentials simples
    // ---------------------------------------------------------
    stage('Checkout: git step') {
      steps {
        echo "=== MODO 2: git step (simplificado) ==="
        git(
          url:          'https://github.com/jenkins-docs/simple-java-maven-app.git',  // URL pública
          branch:       'master',
          changelog:    true,   // Registra o changelog na interface do Jenkins
          poll:         false   // Desabilita polling SCM neste step (o job pode ter poll)
        )
      }
    }

    // ---------------------------------------------------------
    // MODO 3: checkout step completo (mais opções)
    // Use quando precisar de configurações avançadas
    // ---------------------------------------------------------
    stage('Checkout: completo com opções') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'github-credentials',
            usernameVariable: 'GIT_USER',
            passwordVariable: 'GIT_PASS'
          )
        ]) {
          checkout([
            $class: 'GitSCM',             // Tipo de SCM (Git)
            branches: [[name: '*/main']], // Branch (aceita globs: */main, */feature/*)

            doGenerateSubmoduleConfigurations: false,  // Não gera configs de submodules

            extensions: [
              // Limpa o workspace antes do checkout (remove arquivos antigos)
              [$class: 'CleanBeforeCheckout'],

              // Checkout raso: baixa apenas os N commits mais recentes
              // Muito mais rápido em repos com histórico longo!
              [$class: 'CloneOption',
                depth: 1,           // Apenas 1 commit de histórico
                noTags: false,      // Inclui tags
                shallow: true       // Modo shallow (faster)
              ],

              // Define o diretório local onde o repo será clonado
              // [$class: 'RelativeTargetDirectory', relativeTargetDir: 'src'],

              // Timeout para operações Git (evita build pendurado)
              [$class: 'CheckoutOption', timeout: 10],
            ],

            submoduleCfg: [],

            userRemoteConfigs: [[
              url:             env.REPO_URL,
              credentialsId:   'github-credentials'  // ID da credential SSH ou HTTPS
            ]]
          ])

          // Após o checkout, variáveis Git ficam disponíveis:
          sh '''
            echo "Branch:  $(git branch --show-current)"
            echo "Commit:  $(git rev-parse --short HEAD)"
            echo "Autor:   $(git log -1 --format='%an')"
            echo "Mensagem: $(git log -1 --format='%s')"
          '''
        }
      }
    }

    // ---------------------------------------------------------
    // MODO 4: Múltiplos repositórios (multi-repo checkout)
    // Útil quando a aplicação depende de código de outros repos
    // ---------------------------------------------------------
    stage('Checkout: múltiplos repositórios') {
      steps {
        echo "=== MODO 4: Múltiplos repositórios ==="

        // Repo principal (aplicação)
        dir('app') {
          git url: 'https://github.com/jenkins-docs/simple-java-maven-app.git',
              branch: 'master'
          echo "App clonado em: ${WORKSPACE}/app"
        }

        // Repo de configuração (infra/config separado)
        dir('config') {
          // Em produção: git url: 'https://github.com/org/infra-config.git'
          sh 'mkdir -p config && echo "Config simulado" > config/app.properties'
          echo "Config clonado em: ${WORKSPACE}/config"
        }

        sh '''
          echo "Estrutura após multi-checkout:"
          ls -la
        '''
      }
    }

    // ---------------------------------------------------------
    // INFORMAÇÕES DO GIT APÓS CHECKOUT
    // ---------------------------------------------------------
    stage('Extrair Informações do Git') {
      steps {
        script {
          // Variáveis automáticas do Jenkins após checkout:
          echo "GIT_BRANCH:  ${env.GIT_BRANCH ?: 'N/A'}"
          echo "GIT_COMMIT:  ${env.GIT_COMMIT ?: 'N/A'}"
          echo "GIT_URL:     ${env.GIT_URL ?: 'N/A'}"

          // Extraindo informações via git CLI:
          def commitHash = sh(script: 'git rev-parse HEAD 2>/dev/null || echo "N/A"', returnStdout: true).trim()
          def commitMsgShort = sh(script: 'git log -1 --format="%s" 2>/dev/null || echo "N/A"', returnStdout: true).trim()
          def commitAuthor = sh(script: 'git log -1 --format="%an" 2>/dev/null || echo "N/A"', returnStdout: true).trim()
          def commitDate = sh(script: 'git log -1 --format="%ci" 2>/dev/null || echo "N/A"', returnStdout: true).trim()

          echo """
=== INFORMAÇÕES DO COMMIT ===
Hash:     ${commitHash.take(8)}
Mensagem: ${commitMsgShort}
Autor:    ${commitAuthor}
Data:     ${commitDate}
          """

          // Guardar para uso posterior
          env.GIT_SHORT_COMMIT = commitHash.take(8)
          env.GIT_COMMIT_MSG   = commitMsgShort
          env.GIT_AUTHOR       = commitAuthor
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline
