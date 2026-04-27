// ============================================================
// MÓDULO 9 — DEPLOY E ENTREGA CONTÍNUA
// Arquivo: 09-Jenkinsfile-input-aprovacao.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o step 'input' para implementar aprovação manual
// antes de estágios críticos (produção).
//
// ANALOGIA DO DIA A DIA:
// Como assinar um cheque de alto valor —
// o sistema prepara tudo, mas uma pessoa específica precisa
// assinar (aprovar) antes do dinheiro sair.
// Jenkins prepara o deploy, mas o tech lead precisa apertar OK.
// ============================================================

pipeline {
  agent any

  parameters {
    choice(
      name: 'AMBIENTE',
      choices: ['staging', 'prod'],
      description: 'Ambiente de deploy'
    )
    string(name: 'VERSAO', defaultValue: '1.0.0', description: 'Versão')
  }

  stages {

    stage('Build e Testes') {
      steps {
        echo "✅ Build e testes da versão ${params.VERSAO} concluídos"
      }
    }

    stage('Deploy em Staging') {
      when {
        anyOf {
          expression { params.AMBIENTE == 'staging' }
          expression { params.AMBIENTE == 'prod' }
        }
      }
      steps {
        echo "🧪 Deploy automático em Staging..."
        sh 'echo "Deploy staging: OK"'
      }
    }

    stage('Testes de Aceitação') {
      steps {
        echo "🔍 Executando testes de aceitação em staging..."
        sh 'echo "Todos os testes E2E passaram"'
      }
    }

    // ---------------------------------------------------------
    // INPUT BÁSICO: aprovação simples
    // O pipeline PAUSA aqui e aguarda confirmação humana
    // ---------------------------------------------------------
    stage('Aprovação: Deploy em Produção') {
      when {
        expression { params.AMBIENTE == 'prod' }
      }
      steps {
        script {
          echo "⏳ Aguardando aprovação para deploy em PRODUÇÃO..."

          // ===========================================================
          // STEP: input
          // Pausa o pipeline e aguarda ação humana
          // O pipeline fica no status "PAUSED" até aprovação/rejeição
          // ===========================================================
          def aprovacao = input(
            message: "Aprovar deploy da versão ${params.VERSAO} em PRODUÇÃO?",
            ok: 'Aprovar Deploy',           // Texto do botão de aprovação
            submitter: 'admin,tech-lead,release-manager', // Quem pode aprovar
            // submitterParameter: 'APROVADO_POR',  // Salva nome do aprovador numa variável

            parameters: [
              // Parâmetros coletados na hora da aprovação
              choice(
                name: 'ESTRATEGIA',
                choices: ['rolling', 'blue-green'],
                description: 'Estratégia de deploy'
              ),
              booleanParam(
                name: 'NOTIFICAR_EQUIPE',
                defaultValue: true,
                description: 'Notificar equipe no Slack sobre o deploy?'
              ),
              text(
                name: 'COMENTARIO',
                defaultValue: '',
                description: 'Comentário/justificativa do deploy (opcional)'
              )
            ]
          )

          // 'aprovacao' contém os valores dos parâmetros coletados
          env.ESTRATEGIA_DEPLOY = aprovacao.ESTRATEGIA
          env.COMENTARIO = aprovacao.COMENTARIO

          echo """
=== DEPLOY APROVADO ===
Estratégia: ${env.ESTRATEGIA_DEPLOY}
Comentário: ${env.COMENTARIO ?: 'Nenhum'}
          """
        }
      }
    }

    // ---------------------------------------------------------
    // INPUT COM TIMEOUT: rejeita automaticamente se não houver resposta
    // ---------------------------------------------------------
    stage('Aprovação com Timeout') {
      when {
        expression { false }  // Desabilitado — exemplo de referência
      }
      steps {
        script {
          try {
            timeout(time: 24, unit: 'HOURS') {
              // Se não houver aprovação em 24h, o timeout lança exceção
              input(
                message: "Deploy urgente — aprovação expira em 24h!",
                ok: 'Aprovar'
              )
            }
          } catch (err) {
            // Se timeout ou abortado → abortar o build
            def usuario = err.getMessage().contains('Rejected') ? 'usuário' : 'timeout'
            echo "🚫 Deploy cancelado por: ${usuario}"
            currentBuild.result = 'ABORTED'
            error "Deploy não aprovado a tempo"
          }
        }
      }
    }

    stage('Deploy em Produção') {
      when {
        expression { params.AMBIENTE == 'prod' }
      }
      steps {
        script {
          echo "🚀 Iniciando deploy com estratégia: ${env.ESTRATEGIA_DEPLOY}"

          switch (env.ESTRATEGIA_DEPLOY) {
            case 'rolling':
              echo "Rolling deploy: substituindo pods gradualmente..."
              sh '''
                echo "kubectl set image deployment/app app=minha-app:${BUILD_NUMBER}"
                echo "kubectl rollout status deployment/app"
              '''
              break
            case 'blue-green':
              echo "Blue-Green deploy: criando ambiente verde..."
              sh 'echo "Alternando tráfego blue → green"'
              break
          }

          echo "✅ Deploy concluído!"
        }
      }
    }

  } // Fecha stages

  post {
    success {
      echo "✅ Pipeline concluído com sucesso!"
    }
    aborted {
      echo "🚫 Pipeline cancelado (aprovação não dada)"
    }
  }

} // Fecha pipeline
