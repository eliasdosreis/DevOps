// ============================================================
// MÓDULO 2 — STAGES, STEPS E FLOW CONTROL
// Arquivo: 02-Jenkinsfile-steps-essenciais.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra os steps mais usados no dia a dia de um Jenkins Senior:
// echo, sh, bat, script, dir, withEnv, timeout, retry, sleep, error
//
// ANALOGIA DO DIA A DIA:
// Se o pipeline é uma fábrica, os STEPS são as FERRAMENTAS dos
// operários: furadeira (sh), martelo (echo), trena (timeout), etc.
// Cada ferramenta tem uma finalidade específica.
// ============================================================

pipeline {
  agent any

  stages {

    // ---------------------------------------------------------
    // STEP: echo
    // Imprime texto no log do build
    // Uso: debug, separadores visuais, informações de contexto
    // ---------------------------------------------------------
    stage('Step: echo') {
      steps {
        echo 'Mensagem simples com texto fixo'
        echo "Mensagem com variável: Build #${BUILD_NUMBER}"  // Interpolação com double-quotes
        echo '''
          Bloco de texto multi-linha
          com single-quotes triplas
          NÃO faz interpolação de variáveis
        '''
      }
    }

    // ---------------------------------------------------------
    // STEP: sh (shell command)
    // Executa comandos no shell do sistema operacional
    // Funciona em Linux e macOS
    // ---------------------------------------------------------
    stage('Step: sh') {
      steps {
        // sh simples: executa uma linha
        sh 'echo "Comando shell simples"'

        // sh com captura de saída
        script {
          def resultado = sh(
            script: 'echo "valor_retornado"',
            returnStdout: true  // Captura a saída em vez de imprimir
          ).trim()              // .trim() remove espaços e quebras de linha
          echo "Saída capturada: ${resultado}"
        }

        // sh com verificação de exit code
        script {
          def exitCode = sh(
            script: 'exit 0',   // Exit 0 = sucesso, Exit 1+ = falha
            returnStatus: true  // Retorna o exit code em vez de lançar exceção
          )
          echo "Exit code: ${exitCode}"
          if (exitCode != 0) {
            error "Comando falhou com exit code ${exitCode}"
          }
        }

        // sh multi-linha com triple-quotes
        sh '''
          echo "Passo 1: verificando ambiente"
          echo "Passo 2: listando arquivos"
          ls -la .
          echo "Passo 3: verificando variáveis"
          echo "BUILD_NUMBER=${BUILD_NUMBER}"
        '''
      }
    }

    // ---------------------------------------------------------
    // STEP: bat (batch command)
    // Executa comandos no Windows Command Prompt (cmd.exe)
    // Use em agentes Windows
    // ---------------------------------------------------------
    stage('Step: bat (Windows)') {
      when {
        // Este stage só executa em ambientes Windows
        // Remova o 'when' se estiver rodando em Windows nativo
        expression { false }  // Desabilitado para rodar em Linux
      }
      steps {
        bat 'echo Comando Windows CMD'
        bat '''
          echo Bloco multi-linha Windows
          dir
          echo %BUILD_NUMBER%
        '''
      }
    }

    // ---------------------------------------------------------
    // STEP: script { }
    // Executa código Groovy puro dentro do Declarativo
    // Use quando precisar de lógica (if/else, loops, variáveis)
    // ---------------------------------------------------------
    stage('Step: script') {
      steps {
        script {
          // Variáveis Groovy (escopo dentro deste script block)
          def meuNome = "Jenkins"
          def versao = 2025

          // Lógica condicional
          if (versao > 2020) {
            echo "Usando ${meuNome} versão recente: ${versao}"
          } else {
            echo "Versão antiga!"
          }

          // Loop
          def ambientes = ['dev', 'staging', 'prod']
          ambientes.each { ambiente ->
            echo "Verificando ambiente: ${ambiente}"
          }

          // Map (dicionário)
          def config = [
            app: 'minha-app',
            port: 8080,
            replicas: 3
          ]
          echo "App: ${config.app} rodando na porta ${config.port}"
        }
      }
    }

    // ---------------------------------------------------------
    // STEP: dir { }
    // Muda o diretório de trabalho para executar comandos
    // O workspace padrão é: /var/jenkins_home/workspace/<job-name>
    // ---------------------------------------------------------
    stage('Step: dir') {
      steps {
        echo "Diretório atual: ${WORKSPACE}"

        dir('subpasta') {          // Cria e entra na subpasta 'subpasta'
          sh 'pwd'                 // Mostra: /var/jenkins_home/workspace/<job>/subpasta
          sh 'touch arquivo.txt'   // Cria arquivo dentro da subpasta
          sh 'ls -la'
        }
        // Após o bloco dir { }, volta ao diretório original automaticamente
      }
    }

    // ---------------------------------------------------------
    // STEP: withEnv { }
    // Define variáveis de ambiente temporárias para um bloco
    // Escopo limitado — não vaza para fora do bloco
    // ---------------------------------------------------------
    stage('Step: withEnv') {
      steps {
        withEnv(['MINHA_VAR=valor_temporario', 'OUTRA_VAR=outro_valor']) {
          sh 'echo "MINHA_VAR=$MINHA_VAR"'
          sh 'echo "OUTRA_VAR=$OUTRA_VAR"'
        }
        // Fora do withEnv, as variáveis não existem mais
        sh 'echo "MINHA_VAR=${MINHA_VAR:-NÃO_DEFINIDA}"'
      }
    }

    // ---------------------------------------------------------
    // STEP: timeout { }
    // Cancela o step se ultrapassar o tempo limite
    // Protege contra builds que travam infinitamente
    // ---------------------------------------------------------
    stage('Step: timeout') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {  // Cancela após 5 minutos
          sh 'echo "Este comando tem 5 minutos para terminar"'
          // Em produção: sh 'mvn test' — builds longos precisam de timeout
        }
      }
    }

    // ---------------------------------------------------------
    // STEP: retry { }
    // Reexecuta o bloco N vezes em caso de falha
    // Útil para operações de rede instáveis (pull de imagem, deploy)
    // ---------------------------------------------------------
    stage('Step: retry') {
      steps {
        retry(3) {  // Tenta até 3 vezes
          echo 'Tentando operação que pode falhar (ex: pull de imagem Docker)...'
          sh 'echo "Tentativa bem-sucedida"'
          // Em produção: docker.image('minha-imagem').pull()
        }
      }
    }

    // ---------------------------------------------------------
    // STEP: sleep { }
    // Pausa a execução por um tempo
    // Útil para aguardar recursos ficarem disponíveis
    // ---------------------------------------------------------
    stage('Step: sleep') {
      steps {
        echo 'Aguardando 2 segundos para o serviço inicializar...'
        sleep(time: 2, unit: 'SECONDS')  // Aguarda 2 segundos
        echo 'Continuando execução...'
      }
    }

    // ---------------------------------------------------------
    // STEP: error { }
    // Força a falha do pipeline com uma mensagem personalizada
    // Útil para validações de entrada e condições de parada
    // ---------------------------------------------------------
    stage('Step: error (comentado)') {
      steps {
        script {
          def statusCode = 200  // Simula um status HTTP

          if (statusCode != 200) {
            // error "Health check falhou! Status: ${statusCode}"
            // A linha acima interromperia o pipeline com mensagem de erro
            echo "EXEMPLIFICAÇÃO: error seria chamado aqui se statusCode != 200"
          } else {
            echo "✅ Health check OK: status ${statusCode}"
          }
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline
