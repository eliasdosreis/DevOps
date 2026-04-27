// ============================================================
// MÓDULO 2 — STAGES, STEPS E FLOW CONTROL
// Arquivo: 02-Jenkinsfile-when.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra a diretiva 'when' para controle condicional de stages.
// Cada stage só executa se a condição for verdadeira.
//
// ANALOGIA DO DIA A DIA:
// Como um semáforo inteligente: o stage só "passa" se as condições
// certas estiverem presentes. Deploy só vai para produção se:
// - O branch for 'main' (não uma feature branch)
// - O build anterior tiver funcionado
// - O time tiver aprovado
// ============================================================

pipeline {
  agent any

  environment {
    DEPLOY_APROVADO = 'true'   // Simula uma aprovação de deploy
    VERSAO = '2.0.0'
  }

  parameters {
    choice(
      name: 'AMBIENTE',
      choices: ['dev', 'staging', 'prod'],
      description: 'Ambiente de deploy'
    )
    booleanParam(
      name: 'FORCAR_DEPLOY',
      defaultValue: false,
      description: 'Forçar deploy mesmo com testes falhos'
    )
  }

  stages {

    // ---------------------------------------------------------
    // CONDIÇÃO: branch
    // Executa apenas quando o branch atual é o especificado
    // Caso de uso: deploy para produção apenas do branch 'main'
    // ---------------------------------------------------------
    stage('Deploy Produção (só no main)') {
      when {
        branch 'main'  // Executa apenas se GIT_BRANCH == 'main'
        // Alternativas:
        // branch pattern: 'release/*', comparator: 'GLOB'  → branches release/*
        // branch pattern: '^feature/.+', comparator: 'REGEXP'  → branches feature/
      }
      steps {
        echo '🚀 Deploy em produção — estamos no branch main!'
      }
    }

    // ---------------------------------------------------------
    // CONDIÇÃO: expression
    // Condição em Groovy (a mais flexível de todas)
    // Retorna true/false para controlar a execução
    // ---------------------------------------------------------
    stage('Deploy Condicional') {
      when {
        expression {
          // Qualquer código Groovy que retorne true/false
          return params.AMBIENTE == 'prod' && env.DEPLOY_APROVADO == 'true'
        }
      }
      steps {
        echo "Deploy aprovado para ${params.AMBIENTE}!"
      }
    }

    // ---------------------------------------------------------
    // CONDIÇÃO: environment
    // Executa se uma variável de ambiente tiver o valor especificado
    // ---------------------------------------------------------
    stage('Notificação de Versão Nova') {
      when {
        environment name: 'VERSAO', value: '2.0.0'
        // Executa apenas se a variável VERSAO for exatamente '2.0.0'
      }
      steps {
        echo "🎉 Nova versão maior detectada: ${VERSAO}"
      }
    }

    // ---------------------------------------------------------
    // CONDIÇÃO: equals
    // Compara dois valores para igualdade
    // ---------------------------------------------------------
    stage('Deploy Para Staging') {
      when {
        equals expected: 'staging', actual: params.AMBIENTE
      }
      steps {
        echo '🧪 Deploy em ambiente de staging'
      }
    }

    // ---------------------------------------------------------
    // CONDIÇÃO: not
    // Inverte outra condição (negação lógica)
    // ---------------------------------------------------------
    stage('Build Não-Produção') {
      when {
        not {
          branch 'main'  // Executa em qualquer branch EXCETO 'main'
        }
      }
      steps {
        echo 'Build em branch de desenvolvimento (não é main)'
      }
    }

    // ---------------------------------------------------------
    // CONDIÇÕES COMBINADAS: allOf (AND lógico)
    // Executa apenas se TODAS as condições forem verdadeiras
    // ---------------------------------------------------------
    stage('Deploy Aprovado') {
      when {
        allOf {
          expression { params.AMBIENTE == 'prod' }           // É produção?
          expression { env.DEPLOY_APROVADO == 'true' }       // Foi aprovado?
          expression { currentBuild.number > 1 }             // Não é o primeiro build?
        }
      }
      steps {
        echo '✅ Todas as condições satisfeitas — deploy autorizado!'
      }
    }

    // ---------------------------------------------------------
    // CONDIÇÕES COMBINADAS: anyOf (OR lógico)
    // Executa se QUALQUER uma das condições for verdadeira
    // ---------------------------------------------------------
    stage('Notificação Urgente') {
      when {
        anyOf {
          expression { params.AMBIENTE == 'prod' }            // É produção OU
          expression { params.FORCAR_DEPLOY == true }         // É deploy forçado OU
          expression { env.VERSAO.startsWith('3.') }          // É versão major 3.x
        }
      }
      steps {
        echo '🔔 Notificação urgente enviada ao Slack!'
      }
    }

    // ---------------------------------------------------------
    // COMPORTAMENTO: beforeAgent
    // Por padrão, o Jenkins aloca o agent ANTES de avaliar o 'when'.
    // Com beforeAgent: true, avalia o 'when' ANTES de alocar o agent.
    // Economiza recursos em casos onde o stage não vai executar.
    // ---------------------------------------------------------
    stage('Stage Custoso (beforeAgent)') {
      agent {
        docker { image 'ubuntu:22.04' }  // Agent Docker (caro de alocar)
      }
      when {
        beforeAgent true               // Avalia a condição ANTES de alocar o Docker
        expression { false }           // Nunca executa neste exemplo
      }
      steps {
        echo 'Este stage só aloca o Docker se a condição for verdadeira'
      }
    }

    // ---------------------------------------------------------
    // ESTÁGIO SEMPRE EXECUTADO (sem when = executa sempre)
    // ---------------------------------------------------------
    stage('Relatório Final') {
      steps {
        echo '📊 Gerando relatório final...'
        echo "Branch: ${env.GIT_BRANCH ?: 'N/A'}"
        echo "Ambiente: ${params.AMBIENTE}"
        echo "Versão: ${VERSAO}"
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// TABELA: CONDIÇÕES DO WHEN
//
// | Condição        | Descrição                              |
// |-----------------|----------------------------------------|
// | branch          | Branch Git específico                  |
// | tag             | Tag Git específica                     |
// | buildingTag     | Se está buildando uma tag              |
// | environment     | Variável de ambiente = valor           |
// | equals          | A == B                                 |
// | expression      | Código Groovy retornando true/false    |
// | changeRequest   | É um Pull Request / Change Request     |
// | not { }         | Negação de outra condição              |
// | allOf { }       | AND: todas as condições verdadeiras    |
// | anyOf { }       | OR: alguma condição verdadeira         |
// | beforeAgent     | Avalia when antes de alocar o agent   |
// ============================================================
