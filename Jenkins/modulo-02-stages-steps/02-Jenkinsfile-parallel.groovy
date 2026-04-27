// ============================================================
// MÓDULO 2 — STAGES, STEPS E FLOW CONTROL
// Arquivo: 02-Jenkinsfile-parallel.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra execução paralela de stages com o bloco 'parallel'.
// Reduz drasticamente o tempo de pipeline executando tarefas
// independentes ao mesmo tempo.
//
// ANALOGIA DO DIA A DIA:
// Em vez de fazer a faxina da casa em sequência (sala, depois
// cozinha, depois banheiro), você contrata 3 pessoas que fazem
// tudo AO MESMO TEMPO. O tempo total cai de 3h para 1h.
//
// CUIDADO: Tarefas paralelas só funcionam se forem INDEPENDENTES.
// Não execute em paralelo tarefas que dependem umas das outras.
// ============================================================

pipeline {
  agent any

  stages {

    // ---------------------------------------------------------
    // STAGE 1: Sequencial (executa antes dos paralelos)
    // ---------------------------------------------------------
    stage('Build') {
      steps {
        echo '🔨 Build sequencial — deve terminar antes dos testes'
        sh 'echo "Artefato gerado: app.jar"'
      }
    }

    // ---------------------------------------------------------
    // STAGE 2: PARALLEL — executa múltiplos stages ao mesmo tempo
    // Todos os branches do parallel iniciam simultaneamente
    // O pipeline avança apenas quando TODOS terminam
    // ---------------------------------------------------------
    stage('Testes em Paralelo') {
      parallel {

        // Branch 1: Testes unitários
        stage('Testes Unitários') {
          steps {
            echo '🧪 [PARALELO 1] Iniciando testes unitários...'
            sh '''
              echo "Rodando TestUserService..."
              sleep 3
              echo "✓ 45 testes unitários passaram"
            '''
          }
          post {
            always {
              echo '📊 Publicando relatório de testes unitários'
              // junit 'target/surefire-reports/unit/*.xml'
            }
          }
        }

        // Branch 2: Testes de integração
        stage('Testes de Integração') {
          steps {
            echo '🔗 [PARALELO 2] Iniciando testes de integração...'
            sh '''
              echo "Iniciando banco de dados de teste..."
              sleep 5
              echo "✓ 12 testes de integração passaram"
            '''
          }
          post {
            always {
              echo '📊 Publicando relatório de testes de integração'
              // junit 'target/surefire-reports/integration/*.xml'
            }
          }
        }

        // Branch 3: Análise estática de código
        stage('Análise de Código') {
          steps {
            echo '🔍 [PARALELO 3] Iniciando análise estática...'
            sh '''
              echo "Verificando code style..."
              sleep 2
              echo "✓ Sem violações de estilo"
              echo "✓ 0 vulnerabilidades conhecidas"
            '''
          }
        }

        // Branch 4: Verificação de segurança (em agente diferente)
        stage('Security Scan') {
          // Cada branch pode ter seu próprio agent!
          // agent { label 'security-scanner' }
          steps {
            echo '🔒 [PARALELO 4] Rodando scan de segurança...'
            sh '''
              echo "Analisando dependências..."
              sleep 4
              echo "✓ Sem CVEs críticos encontrados"
            '''
          }
        }

      } // Fecha parallel
    } // Fecha stage 'Testes em Paralelo'

    // ---------------------------------------------------------
    // PARALLEL COM failFast
    // Se qualquer branch falhar, CANCELA os outros imediatamente
    // Bom para economizar tempo — não espera os outros terminarem
    // ---------------------------------------------------------
    stage('Testes de Performance (failFast)') {
      parallel {
        failFast true  // Falha rápida: se um branch falhar, cancela os demais

        stage('Teste de Carga') {
          steps {
            echo '⚡ [failFast] Teste de carga...'
            sh 'sleep 2 && echo "Carga: OK"'
          }
        }

        stage('Teste de Stress') {
          steps {
            echo '💪 [failFast] Teste de stress...'
            sh 'sleep 3 && echo "Stress: OK"'
          }
        }
      }
    }

    // ---------------------------------------------------------
    // PARALLEL DENTRO DE MATRIX (Jenkins 2.x)
    // Executa o mesmo conjunto de steps em múltiplas configurações
    // ---------------------------------------------------------
    stage('Matrix: Compatibilidade') {
      matrix {
        axes {
          axis {
            name 'SISTEMA_OPERACIONAL'
            values 'linux', 'windows', 'macos'
          }
          axis {
            name 'VERSAO_JAVA'
            values '11', '17', '21'
          }
        }
        // Gera: 3 OS × 3 Java = 9 combinações executadas em paralelo

        excludes {
          exclude {
            axis {
              name 'SISTEMA_OPERACIONAL'
              values 'macos'
            }
            axis {
              name 'VERSAO_JAVA'
              values '11'
            }
          }
          // Exclui a combinação macos + Java 11
        }

        stages {
          stage('Compatibilidade Test') {
            steps {
              echo "Testando em ${SISTEMA_OPERACIONAL} com Java ${VERSAO_JAVA}"
              // Em produção, aqui você escolheria o agent correto por OS
            }
          }
        }
      }
    }

    // ---------------------------------------------------------
    // STAGE FINAL: sequencial (aguarda todos os paralelos)
    // ---------------------------------------------------------
    stage('Deploy') {
      steps {
        echo '🚀 Todos os testes passaram — iniciando deploy'
        echo 'Este stage só chega aqui se TODOS os stages paralelos tiverem sucesso'
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// CONCEITO SENIOR: PARALLEL vs MATRIX
//
// PARALLEL: Use quando os branches têm LÓGICAS DIFERENTES
//   parallel {
//     stage('Testes Unitários') { ... }    ← lógica diferente
//     stage('Análise de Código') { ... }   ← lógica diferente
//   }
//
// MATRIX: Use quando a MESMA lógica roda em MÚLTIPLAS configs
//   matrix {
//     axes { axis { name 'OS' values 'linux', 'windows' } }
//     stages { stage('Test') { ... } }     ← mesma lógica, configs diferentes
//   }
//
// PERGUNTAS DE ENTREVISTA:
//
// Q: "Se dois stages paralelos têm tempos de 5min e 8min,
//    qual o tempo total do estágio parallel?"
// A: 8 minutos — o pipeline espera o MAIS LENTO terminar.
//    Com sequential seria 5+8=13 minutos.
//
// Q: "Quando NÃO usar parallel?"
// A: Quando os stages têm dependência de dados entre si,
//    quando o agente tem recursos limitados (CPU/memória),
//    ou quando a ordem de execução importa.
// ============================================================
