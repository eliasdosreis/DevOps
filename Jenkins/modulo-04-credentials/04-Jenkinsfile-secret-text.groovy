// ============================================================
// MÓDULO 4 — CREDENTIALS E SECRETS
// Arquivo: 04-Jenkinsfile-secret-text.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra como usar uma credential do tipo "Secret Text"
// no pipeline — o tipo mais simples de credential.
//
// ANALOGIA DO DIA A DIA:
// Imagine que você tem um cofre no banco (Credentials Store).
// Em vez de carregar dinheiro no bolso (hardcode no código),
// você dá ao Jenkins uma CHAVE do cofre (o ID da credential).
// O Jenkins abre o cofre quando precisar, sem você ver o dinheiro.
//
// PRÉ-REQUISITO: Cadastrar a credential antes de executar!
// Veja as instruções no arquivo 04-conceitos.md
// ============================================================

pipeline {
  agent any

  environment {
    // ===========================================================
    // MODO 1: credentials() diretamente no environment
    // O Jenkins injeta o valor da credential como variável de ambiente.
    // O valor NUNCA aparece no log — Jenkins o mascara automaticamente.
    // ===========================================================

    // Sintaxe: credentials('ID_DA_CREDENTIAL_NO_JENKINS')
    // O ID é definido quando você cadastra a credential na UI
    SLACK_TOKEN     = credentials('slack-webhook-token')     // Secret text
    SONAR_TOKEN     = credentials('sonarqube-token')         // Secret text
    // DOCKER_TOKEN = credentials('docker-hub-token')        // Secret text
  }

  stages {

    stage('Usando Secret Text via environment') {
      steps {
        echo "=== MODO 1: Credential via environment {} ==="

        // ✅ CORRETO: reference a variável sem expor o valor
        echo "Slack token carregado: ${SLACK_TOKEN ? '*** (mascarado)' : 'ERRO: não carregado'}"

        // No shell, a variável fica disponível como variável de ambiente
        sh '''
          # ✅ CORRETO: usar a variável no shell
          if [ -n "$SLACK_TOKEN" ]; then
            echo "SLACK_TOKEN: carregado com sucesso (valor mascarado no log)"
          else
            echo "ERRO: SLACK_TOKEN não foi carregado"
          fi

          # ❌ NUNCA FAÇA ISSO:
          # echo "Token: $SLACK_TOKEN"  — Pode vazar em logs ou screenshots!
        '''
      }
    }

    stage('Usando Secret Text via withCredentials') {
      steps {
        echo "=== MODO 2: withCredentials (mais explícito e controlado) ==="

        // ===========================================================
        // MODO 2: withCredentials { }
        // Injeta a credential APENAS dentro do bloco.
        // Fora do bloco, a variável não existe.
        // Mais seguro: escopo limitado.
        // ===========================================================
        withCredentials([
          string(
            credentialsId: 'slack-webhook-token',   // ID cadastrado no Jenkins
            variable: 'MINHA_SLACK_TOKEN'           // Nome da variável no bloco
          )
        ]) {
          sh '''
            echo "Usando token do Slack para enviar notificação..."
            # Simulação — em produção:
            # curl -X POST -H "Authorization: Bearer $MINHA_SLACK_TOKEN" ...
            echo "Notificação enviada (simulada)"
          '''
          // Após o bloco withCredentials, MINHA_SLACK_TOKEN não existe mais
        }

        // Aqui, MINHA_SLACK_TOKEN já não está disponível — mais seguro!
        echo "Fora do bloco withCredentials: variável não está mais disponível"
      }
    }

    stage('Múltiplos Secrets ao mesmo tempo') {
      steps {
        echo "=== MODO 3: Múltiplas credentials juntas ==="

        withCredentials([
          string(credentialsId: 'slack-webhook-token', variable: 'SLACK_TK'),
          string(credentialsId: 'sonarqube-token',     variable: 'SONAR_TK'),
          // string(credentialsId: 'alguma-api-key',   variable: 'API_KEY'),
        ]) {
          sh '''
            echo "Configurando múltiplos serviços..."
            echo "Slack: Configurado"    # Usa $SLACK_TK internamente
            echo "Sonar: Configurado"    # Usa $SONAR_TK internamente
          '''
        }
      }
    }

    stage('Proteção contra Leakage') {
      steps {
        script {
          echo "=== BOAS PRÁTICAS ANTI-LEAKAGE ==="

          // JENKINS MASCARA AUTOMATICAMENTE valores de credentials
          // mas existem formas de vazar acidentalmente:

          // ⚠️  RISCO 1: Imprimir o valor diretamente
          // echo "Token: ${SLACK_TOKEN}"  // Jenkins mascara como ***
          // mas se você dividir o token em partes, pode não ser mascarado!

          // ⚠️  RISCO 2: Passar como argumento de linha de comando
          // sh "git clone https://user:${SLACK_TOKEN}@github.com/..."
          // Ficará no process list (ps aux) — visível para outros processos!

          // ✅ CORRETO: Usar arquivo temporário
          withCredentials([string(credentialsId: 'slack-webhook-token', variable: 'TK')]) {
            sh '''
              # Salva em arquivo temporário (permissão restrita)
              printf '%s' "$TK" > /tmp/token.txt
              chmod 600 /tmp/token.txt
              # Usa o arquivo (sem o token na linha de comando)
              cat /tmp/token.txt | head -c 5 | sed 's/./*/g'  # Exemplo mascarado
              rm -f /tmp/token.txt  # Apaga imediatamente após uso
            '''
          }

          echo "Boas práticas de segurança demonstradas"
        }
      }
    }

  } // Fecha stages

  post {
    always {
      // Limpeza: remove arquivos temporários que podem conter secrets
      sh 'rm -f /tmp/token.txt /tmp/*.key /tmp/*.pem 2>/dev/null || true'
    }
  }

} // Fecha pipeline

// ============================================================
// COMO CADASTRAR UMA SECRET TEXT NO JENKINS:
//
// 1. Manage Jenkins → Credentials → System → Global credentials
// 2. Add Credentials
// 3. Kind: Secret text
// 4. Secret: (cole o valor do token/senha)
// 5. ID: slack-webhook-token  (use o mesmo ID no Jenkinsfile)
// 6. Description: Token do Webhook do Slack  (para identificar)
// 7. OK
//
// IMPORTANTE: O ID é como o "endereço" do cofre.
// Mude o ID e o Jenkinsfile quebra.
// Use IDs descritivos e padronizados na sua organização.
// ============================================================
