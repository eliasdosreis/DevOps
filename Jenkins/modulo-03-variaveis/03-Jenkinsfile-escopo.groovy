// ============================================================
// MÓDULO 3 — VARIÁVEIS, PARÂMETROS E ENVIRONMENT
// Arquivo: 03-Jenkinsfile-escopo.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o ESCOPO das variáveis no Jenkins:
// - Variáveis globais de environment
// - Variáveis de stage
// - Variáveis Groovy (def) no bloco script
// - Comunicação de valores entre stages
//
// ANALOGIA DO DIA A DIA:
// Como as regras numa empresa:
// - Política global: todo funcionário segue (environment global)
// - Política de departamento: só o dep. de TI segue (environment de stage)
// - Nota de reunião: só quem estava na sala sabe (variável def no script)
// ============================================================

pipeline {
  agent any

  // ===========================================================
  // ESCOPO 1: GLOBAL — acessível em qualquer stage e step
  // ===========================================================
  environment {
    APP_GLOBAL    = 'visivel-em-todo-o-pipeline'    // Qualquer stage pode ler
    AMBIENTE      = 'desenvolvimento'               // Pode ser sobrescrito em stage
  }

  stages {

    stage('Escopo Global') {
      steps {
        // Variáveis globais acessíveis aqui
        echo "APP_GLOBAL:  ${APP_GLOBAL}"            // ✅ Visível
        echo "AMBIENTE:    ${AMBIENTE}"              // ✅ 'desenvolvimento'

        // Variáveis Groovy NÃO são acessíveis fora do bloco script
        // onde foram definidas — escopo local ao bloco
        script {
          def localGroovy = 'apenas-neste-bloco-script'
          echo "localGroovy: ${localGroovy}"         // ✅ Visível aqui
        }
        // echo "${localGroovy}"  // ❌ ERRO: localGroovy fora do escopo
      }
    }

    // ===========================================================
    // ESCOPO 2: DE STAGE — acessível apenas neste stage
    // ===========================================================
    stage('Escopo de Stage') {
      environment {
        AMBIENTE        = 'homologacao'        // Sobrescreve o global APENAS aqui
        STAGE_VAR       = 'apenas-neste-stage'
      }
      steps {
        echo "AMBIENTE:    ${AMBIENTE}"        // ✅ 'homologacao' (sobrescrito)
        echo "APP_GLOBAL:  ${APP_GLOBAL}"      // ✅ 'visivel-em-todo-o-pipeline' (global)
        echo "STAGE_VAR:   ${STAGE_VAR}"       // ✅ 'apenas-neste-stage'
      }
    }

    stage('Confirma: Escopo Global Intacto') {
      steps {
        // O AMBIENTE global não foi alterado — a sobrescrita era apenas no stage anterior
        echo "AMBIENTE:    ${AMBIENTE}"        // ✅ 'desenvolvimento' (global restaurado)
        // echo "STAGE_VAR:   ${STAGE_VAR}"    // ❌ ERRO: STAGE_VAR não existe aqui
      }
    }

    // ===========================================================
    // COMUNICAÇÃO DE VALORES ENTRE STAGES
    // Problema: def no script tem escopo local → como passar valor?
    // ===========================================================
    stage('Comunicação entre Stages') {
      steps {
        script {
          // MÉTODO 1: env.VARIAVEL — define variável de ambiente dinamicamente
          // Esta variável fica disponível em TODOS os stages seguintes
          env.VERSAO_CALCULADA = sh(
            script: 'echo "1.0.${BUILD_NUMBER}"',
            returnStdout: true
          ).trim()

          env.COMMIT_CURTO = sh(
            script: 'git rev-parse --short HEAD 2>/dev/null || echo "abc1234"',
            returnStdout: true
          ).trim()

          echo "Versão calculada: ${env.VERSAO_CALCULADA}"
          echo "Commit curto: ${env.COMMIT_CURTO}"
        }
      }
    }

    stage('Usa Valor do Stage Anterior') {
      steps {
        script {
          // env.VERSAO_CALCULADA foi definida no stage anterior e está disponível aqui
          def tagImagem = "minha-app:${env.VERSAO_CALCULADA}-${env.COMMIT_CURTO}"
          echo "Tag da imagem Docker: ${tagImagem}"

          // MÉTODO 2: currentBuild.description — aparece na interface do Jenkins
          currentBuild.description = "v${env.VERSAO_CALCULADA} (${env.COMMIT_CURTO})"
          // Essa string aparece na lista de builds na UI do Jenkins
        }
      }
    }

    // ===========================================================
    // TIPOS DE VARIÁVEIS E SEUS ESCOPOS
    // ===========================================================
    stage('Resumo de Tipos e Escopos') {
      environment {
        ENV_STAGE = 'sou-do-environment-do-stage'
      }
      steps {
        script {
          // TIPO 1: env.* — variável de ambiente Jenkins
          // Escopo: pipeline inteiro (ou stage se definido no environment do stage)
          // Acesso: ${env.NOME} ou ${NOME} no Jenkinsfile, $NOME no shell
          env.MINHA_ENV = 'defini-dinamicamente-no-script'
          echo "env.MINHA_ENV:  ${env.MINHA_ENV}"

          // TIPO 2: def no script — variável Groovy local
          // Escopo: somente dentro do bloco script { } onde foi definida
          // NÃO acessível no shell via sh '...'
          def groovyLocal = 'apenas-neste-script-block'
          echo "groovyLocal:    ${groovyLocal}"

          // TIPO 3: environment { } block — variável de ambiente declarativa
          // Escopo: pipeline inteiro (global) ou stage atual (stage-level)
          echo "ENV_STAGE:      ${ENV_STAGE}"        // Definido no environment do stage

          // TIPO 4: params.* — parâmetros de entrada do usuário
          // Escopo: pipeline inteiro, somente leitura
          // echo "params:         ${params.ALGUM_PARAM}"

          // TIPO 5: @Field — variável Groovy de nível de script (Scripted Pipeline)
          // Equivalente a variável global no Scripted Pipeline
          // Disponível em todos os blocos do mesmo script Groovy

          echo "\n=== TABELA DE ESCOPOS ==="
          echo "env.*         → pipeline inteiro"
          echo "def no script → apenas o bloco script"
          echo "environment{} → pipeline ou stage (conforme onde está)"
          echo "params.*      → pipeline inteiro (somente leitura)"
          echo "currentBuild  → build atual (leitura/escrita de metadados)"
        }
      }
    }

    stage('Armadilhas Comuns') {
      steps {
        script {
          // ARMADILHA 1: String com aspas simples vs duplas no shell
          def nome = 'Jenkins'

          // ✅ CORRETO: aspas duplas permitem interpolação Groovy
          sh "echo 'Olá, ${nome}!'"        // Saída: Olá, Jenkins!

          // ✅ CORRETO: aspas simples no shell não fazem interpolação Groovy
          sh 'echo "Olá, $BUILD_NUMBER"'   // Saída: Olá, 42 (variável de ambiente)

          // ❌ ERRADO: variável Groovy em aspas simples
          // sh 'echo ${nome}'             // Saída: ${nome} (literal — não interpola!)

          // ARMADILHA 2: env.VARIAVEL vs params.VARIAVEL
          // params.VARIAVEL → imutável, valor dado pelo usuário antes do build
          // env.VARIAVEL   → pode ser sobrescrito durante o pipeline

          // ARMADILHA 3: Boolean em params vs String em env
          // params.MEU_BOOL == true        ✅ (é boolean de verdade)
          // env.MEU_BOOL == 'true'         ✅ (env SEMPRE é String)
          // env.MEU_BOOL == true           ❌ (String != Boolean — cuidado!)

          echo "Armadilhas documentadas e evitadas!"
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline
