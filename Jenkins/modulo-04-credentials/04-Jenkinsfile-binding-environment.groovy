// ============================================================
// MÓDULO 4 — CREDENTIALS E SECRETS
// Arquivo: 04-Jenkinsfile-binding-environment.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra TODOS os tipos de bindings do withCredentials{}
// e as melhores práticas de segurança para uso em produção.
//
// Este é o arquivo de referência completo sobre credentials.
// ============================================================

pipeline {
  agent any

  stages {

    stage('Todos os Tipos de Binding') {
      steps {
        // ===========================================================
        // withCredentials aceita uma LISTA de bindings
        // Você pode misturar qualquer número de tipos
        // ===========================================================
        withCredentials([

          // 1. String (secret text)
          string(
            credentialsId: 'slack-webhook-token',
            variable: 'SLACK_TOKEN'
          ),

          // 2. Username e Password
          usernamePassword(
            credentialsId: 'docker-hub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          ),

          // 3. SSH Username com Chave Privada
          sshUserPrivateKey(
            credentialsId: 'servidor-ssh-key',
            keyFileVariable:  'SSH_KEY_FILE',
            usernameVariable: 'SSH_USER'
          ),

          // 4. Arquivo secreto (certificate, JSON, etc.)
          file(
            credentialsId: 'gcp-service-account-json',
            variable: 'GCP_KEY_FILE'
          ),

          // 5. ZIP de arquivos secretos
          // zip(
          //   credentialsId: 'certificados-bundle',
          //   variable: 'CERTS_ZIP'
          // ),

          // 6. Certificado (X.509)
          // certificate(
          //   credentialsId: 'ssl-certificate',
          //   keystoreVariable: 'KEYSTORE_FILE',
          //   passwordVariable: 'KEYSTORE_PASS'
          // ),

        ]) {
          sh '''
            echo "=== BINDING COMPLETO ==="
            echo "Docker User: $DOCKER_USER"
            echo "SSH User:    $SSH_USER"
            echo "Key File:    $SSH_KEY_FILE"
            echo "GCP Key:     $GCP_KEY_FILE"
            echo "Todos os secrets carregados com sucesso"

            # Verificar que o arquivo GCP existe e tem conteúdo
            if [ -f "$GCP_KEY_FILE" ]; then
              echo "GCP key file: presente"
            fi
          '''
        }
      }
    }

    stage('Credential Scope: Global vs System vs Job') {
      steps {
        script {
          echo """
=== ESCOPOS DE CREDENTIALS NO JENKINS ===

GLOBAL:
  - Visível para TODOS os jobs e pipelines
  - Caminho: Manage Jenkins → Credentials → System → Global
  - Use para: tokens de infraestrutura compartilhada

SYSTEM:
  - Visível apenas para o Jenkins internamente (plugins, configurações)
  - NÃO disponível nos pipelines
  - Use para: credentials do próprio Jenkins (ex: SMTP server)

FOLDER (requer plugin CloudBees Folders):
  - Visível apenas para jobs dentro daquela pasta
  - Use para: ambientes (dev, staging, prod) com segmentos de acesso

JOB:
  - Visível apenas para UM job específico
  - Definido dentro da configuração do job
  - Use para: credentials muito sensíveis e específicas

MULTI-BRANCH:
  - Herda do folder pai
  - Cada branch usa as mesmas credentials

BOA PRÁTICA:
  Organize credentials por escopo e prefixo:
  - 'dev-docker-registry'  → só para ambiente dev
  - 'prod-docker-registry' → só para ambiente prod
  - 'global-slack-token'   → compartilhado por todos
          """
        }
      }
    }

    stage('Rotação de Credentials (Conceito Senior)') {
      steps {
        script {
          echo """
=== ROTAÇÃO DE CREDENTIALS — CONCEITO SENIOR ===

PROBLEMA:
  Credentials raramente expiram sozinhas, mas DEVEM ser rotacionadas
  periodicamente por segurança (a cada 90 dias é padrão comum).

SOLUÇÃO SEM DOWNTIME:
  1. Crie a nova credential com um ID diferente:
     'docker-hub-token-v2'
  2. Atualize os Jenkinsfiles na branch de desenvolvimento
  3. Teste em staging
  4. Faça merge e delete a credential antiga

AUTOMAÇÃO COM VAULT:
  A solução enterprise é usar HashiCorp Vault como backend:
  - Credentials são geradas dinamicamente por pipeline
  - Expiram automaticamente após o build
  - Auditoria completa de quem acessou o quê
  - Plugin: HashiCorp Vault Plugin for Jenkins

EXEMPLO DE CONFIGURAÇÃO VAULT:
  withVault(configuration: [
    vaultUrl: 'https://vault.empresa.com',
    vaultCredentialId: 'vault-jenkins-approle'
  ]) {
    def secrets = [
      [path: 'secret/docker', secretValues: [
        [envVar: 'DOCKER_TOKEN', vaultKey: 'token']
      ]]
    ]
    withVaultSecrets(secrets) {
      sh 'docker login -u jenkins --password-stdin <<< $DOCKER_TOKEN'
    }
  }
          """
        }
      }
    }

    stage('Checklist de Segurança de Credentials') {
      steps {
        script {
          echo """
=== CHECKLIST DE SEGURANÇA ===

✅ NUNCA hardcode secrets no Jenkinsfile:
   ❌ DOCKER_PASS = 'minha-senha-secreta'
   ✅ DOCKER_PASS = credentials('docker-hub-credentials')

✅ NUNCA imprima o valor de uma credential:
   ❌ echo "Token: \${SLACK_TOKEN}"
   ✅ echo "Token status: \${SLACK_TOKEN ? 'carregado' : 'ausente'}"

✅ NUNCA passe credentials em parâmetros de linha de comando:
   ❌ sh "curl -u admin:\${JENKINS_PASS} http://..."
   ✅ sh '''echo "\$JENKINS_PASS" | curl -u admin --password-stdin http://...'''

✅ USE --password-stdin sempre que possível (Docker, curl, etc.)

✅ LIMPE arquivos temporários que contenham secrets:
   sh 'rm -f ~/.netrc /tmp/token.txt'

✅ USE escopos mínimos de credentials (Folder > Global)

✅ AUDITE o uso de credentials regularmente:
   Manage Jenkins → Credentials → (ícone de histórico)

✅ Configure alertas para uso anômalo de credentials

✅ Realize rotação periódica de todas as credentials (90 dias)
          """
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline
