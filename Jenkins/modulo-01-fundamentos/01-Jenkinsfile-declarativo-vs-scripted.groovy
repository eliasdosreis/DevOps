// ============================================================
// MÓDULO 1 — FUNDAMENTOS DE PIPELINE
// Arquivo: 01-Jenkinsfile-declarativo-vs-scripted.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra lado a lado os dois estilos de pipeline:
// Declarativo e Scripted. O mesmo resultado, duas abordagens.
//
// ANALOGIA DO DIA A DIA:
// Declarativo é como usar um formulário estruturado (preencha
// os campos: nome, endereço, telefone). Scripted é como escrever
// uma carta livre — mais poder, mais responsabilidade.
// ============================================================

// ============================================================
// ESTILO 1: PIPELINE DECLARATIVO
// ============================================================
// Características:
// - Introduzido no Jenkins 2.x como padrão moderno
// - Estrutura rígida e pré-definida (pipeline, agent, stages, steps)
// - Validação de sintaxe ANTES de executar (detecta erros cedo)
// - Suporte nativo a: post, when, parallel, options, triggers, environment
// - RECOMENDADO para a maioria dos casos de uso
// ============================================================

pipeline {
  agent any

  // O bloco 'options' só existe no Declarativo:
  options {
    timeout(time: 10, unit: 'MINUTES')  // Build seja cancela após 10 min
    buildDiscarder(logRotator(numToKeepStr: '5'))  // Guarda apenas últimos 5 builds
    timestamps()  // Adiciona timestamp em cada linha do log
  }

  // O bloco 'environment' só existe no Declarativo:
  environment {
    VERSAO = '1.0.0'
    AMBIENTE = 'desenvolvimento'
  }

  stages {
    stage('Build') {
      steps {
        echo "Construindo versão ${VERSAO} para ${AMBIENTE}"
      }
    }

    stage('Test') {
      steps {
        echo 'Executando testes...'
      }
    }
  }

  // O bloco 'post' só existe no Declarativo:
  post {
    always {
      echo 'Pipeline concluído (sucesso ou falha)'
    }
    success {
      echo 'Pipeline concluído com SUCESSO!'
    }
    failure {
      echo 'Pipeline FALHOU!'
    }
  }
}

// ============================================================
// ESTILO 2: PIPELINE SCRIPTED (para referência)
// ============================================================
// Características:
// - Estilo original do Jenkins Pipeline
// - É basicamente código Groovy puro
// - Estrutura livre: qualquer código Groovy é válido
// - Mais poderoso, porém mais difícil de manter
// - Não tem validação prévia de sintaxe
// - Não tem suporte nativo a opções declarativas (post, when, etc.)
// - USE APENAS quando o Declarativo não for suficiente
// ============================================================

/*
node {                          // 'node' no Scripted = 'pipeline + agent' no Declarativo
  def versao = '1.0.0'          // Variáveis definidas diretamente em Groovy
  def ambiente = 'desenvolvimento'

  try {                         // Tratamento de erro manual (no Declarativo, use 'post')
    stage('Build') {
      echo "Construindo versão ${versao} para ${ambiente}"
    }

    stage('Test') {
      echo 'Executando testes...'
    }

    currentBuild.result = 'SUCCESS'  // Define o resultado manualmente

  } catch (e) {                 // Catch de qualquer exceção durante o pipeline
    currentBuild.result = 'FAILURE'
    throw e                     // Relança para que o Jenkins marque o build como falho

  } finally {                   // Equivalente ao 'post { always }' do Declarativo
    echo "Pipeline concluído. Resultado: ${currentBuild.result}"
  }
}
*/

// ============================================================
// RESUMO: QUANDO USAR CADA UM?
//
// USE DECLARATIVO quando:
//   ✅ Criando novos pipelines (padrão da indústria)
//   ✅ Time com diferentes níveis de experiência
//   ✅ Quer validação de sintaxe antes da execução
//   ✅ Quer suporte nativo a post, when, parallel
//
// USE SCRIPTED quando:
//   ⚠️  Precisa de lógica complexa impossível no Declarativo
//   ⚠️  Migrando pipelines legados muito antigos
//   ⚠️  Criando Shared Libraries (funções reutilizáveis)
//
// REGRA SENIOR: Sempre inicie com Declarativo.
// Use o bloco 'script { }' dentro do Declarativo para
// código Groovy puro quando necessário — melhor dos dois mundos.
// ============================================================
