// ============================================================
// MÓDULO 2 — STAGES, STEPS E FLOW CONTROL
// Arquivo: 02-Jenkinsfile-multi-stages.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra um pipeline com múltiplos stages em sequência.
// Mostra a ordem de execução e como o Jenkins exibe o progresso.
//
// ANALOGIA DO DIA A DIA:
// Como uma linha de produção de chocolate:
// 1. Misturar ingredientes (Build)
// 2. Moldar no formato (Test)
// 3. Refrigerar (Quality Check)
// 4. Empacotar (Package)
// 5. Enviar para a loja (Deploy)
// Cada etapa só começa APÓS a anterior ser concluída com sucesso.
// ============================================================

pipeline {
  agent any

  stages {

    // ---------------------------------------------------------
    // STAGE 1: Checkout
    // Primeiro stage: sempre baixa o código do repositório
    // Em pipelines reais, usa: checkout scm (automático)
    // ---------------------------------------------------------
    stage('Checkout') {
      steps {
        echo '📥 Baixando código do repositório...'
        // Em produção: checkout scm
        // ou: git url: 'https://github.com/org/repo.git', branch: 'main'
      }
    }

    // ---------------------------------------------------------
    // STAGE 2: Build
    // Compilação e empacotamento da aplicação
    // Se este stage falhar, os próximos NÃO executam (por padrão)
    // ---------------------------------------------------------
    stage('Build') {
      steps {
        echo '🔨 Compilando a aplicação...'
        sh '''
          echo "Verificando versão do Java..."
          java -version 2>&1 || echo "Java não disponível neste ambiente"
          echo "Build simulado concluído"
        '''
      }
    }

    // ---------------------------------------------------------
    // STAGE 3: Unit Tests
    // Executa testes unitários
    // Se falhar, o pipeline falha (status: FAILURE)
    // ---------------------------------------------------------
    stage('Unit Tests') {
      steps {
        echo '🧪 Executando testes unitários...'
        sh '''
          echo "Rodando suite de testes unitários..."
          echo "✓ TestUserService       PASSED"
          echo "✓ TestOrderService      PASSED"
          echo "✓ TestPaymentService    PASSED"
          echo "Total: 3 testes, 0 falhas"
        '''
      }
    }

    // ---------------------------------------------------------
    // STAGE 4: Quality Check
    // Análise estática de código (lint, vulnerabilidades)
    // ---------------------------------------------------------
    stage('Quality Check') {
      steps {
        echo '🔍 Verificando qualidade do código...'
        sh 'echo "Análise de qualidade: SEM violações críticas"'
      }
    }

    // ---------------------------------------------------------
    // STAGE 5: Package
    // Empacota o artefato final (JAR, WAR, ZIP, imagem Docker, etc.)
    // ---------------------------------------------------------
    stage('Package') {
      steps {
        echo '📦 Empacotando artefato...'
        sh 'echo "minha-app-1.0.0.jar criado com sucesso"'
      }
    }

    // ---------------------------------------------------------
    // STAGE 6: Deploy
    // Implantação no ambiente alvo
    // ---------------------------------------------------------
    stage('Deploy') {
      steps {
        echo '🚀 Fazendo deploy...'
        sh 'echo "Deploy realizado no ambiente de desenvolvimento"'
      }
    }

  } // Fecha stages

  post {
    success {
      echo '''
        ╔══════════════════════════════════╗
        ║  ✅ PIPELINE CONCLUÍDO!          ║
        ║  Todos os 6 stages passaram      ║
        ╚══════════════════════════════════╝
      '''
    }
    failure {
      echo '❌ Pipeline falhou. Verifique o stage em vermelho.'
    }
  }

} // Fecha pipeline

// ============================================================
// CONCEITO SENIOR — ORDER OF EXECUTION
//
// Stages executam em SEQUÊNCIA por padrão.
// Se um stage falha, os subsequentes SÃO PULADOS (não executam),
// mas o bloco 'post' sempre executa.
//
// Para executar stages em PARALELO, use o bloco 'parallel'
// dentro de um stage (veja 02-Jenkinsfile-parallel.groovy).
//
// Para continuar após falha de um stage, use:
//   catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
//     sh 'comando que pode falhar'
//   }
// ============================================================
