// ============================================================
// MÓDULO 4 — CREDENTIALS E SECRETS
// Arquivo: 04-Jenkinsfile-username-password.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra como usar credentials do tipo "Username with Password"
// — o tipo mais usado para autenticação em registries, APIs, DBs.
//
// Quando você usa este tipo, o Jenkins cria AUTOMATICAMENTE
// duas variáveis: uma para o usuário e outra para a senha.
//
// ANALOGIA DO DIA A DIA:
// Como um cartão de acesso ao prédio: tem o seu nome (username)
// impressso na frente, mas a senha do PIN é secreta (mascarada).
// ============================================================

pipeline {
  agent any

  environment {
    // ===========================================================
    // USERNAME WITH PASSWORD via environment { }
    // O Jenkins cria AUTOMATICAMENTE 3 variáveis:
    //
    // DOCKER_CREDS       → username:password (combinado — raramente usado)
    // DOCKER_CREDS_USR   → apenas o username (seguro de imprimir no log)
    // DOCKER_CREDS_PSW   → apenas a senha (Jenkins MASCARA nos logs)
    //
    // Padrão de nomenclatura: NOME_DA_VAR + _USR / _PSW
    // ===========================================================
    DOCKER_CREDS  = credentials('docker-hub-credentials')
    // docker-hub-credentials: ID cadastrado no Credentials Store
  }

  stages {

    stage('Login no Docker Hub') {
      steps {
        sh '''
          echo "Usuário Docker Hub: $DOCKER_CREDS_USR"
          echo "Senha: *** (mascarada pelo Jenkins)"

          # Login no Docker Hub usando as variáveis automáticas
          echo "$DOCKER_CREDS_PSW" | docker login -u "$DOCKER_CREDS_USR" --password-stdin

          # ✅ CORRETO: --password-stdin evita que a senha apareça no process list
          # ❌ ERRADO: docker login -u user -p $SENHA  (fica visível no ps aux)
        '''
      }
    }

    stage('Username e Password via withCredentials') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'docker-hub-credentials',
            usernameVariable: 'REG_USER',          // Nome da variável do usuário
            passwordVariable: 'REG_PASS'           // Nome da variável da senha
          )
        ]) {
          sh '''
            echo "Usuário do registry: $REG_USER"
            # Senha mascarada automaticamente: $REG_PASS

            # Construindo a URL autenticada (ANTI-PADRÃO — expõe no log de processo)
            # git clone https://$REG_USER:$REG_PASS@github.com/org/repo.git

            # PADRÃO CORRETO: usar arquivo .netrc ou credential helper
            echo "machine github.com login $REG_USER password $REG_PASS" > ~/.netrc
            chmod 600 ~/.netrc
            # git clone https://github.com/org/repo.git  # Usa .netrc automaticamente
            rm -f ~/.netrc  # Limpa imediatamente após uso
          '''
        }
      }
    }

    stage('Acessar Registry Privado') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'docker-hub-credentials',
            usernameVariable: 'REGISTRY_USER',
            passwordVariable: 'REGISTRY_PASS'
          )
        ]) {
          sh '''
            # Login no registry
            echo "$REGISTRY_PASS" | docker login registry.empresa.com \
              -u "$REGISTRY_USER" \
              --password-stdin

            echo "Login realizado com sucesso"

            # Pull de imagem privada
            # docker pull registry.empresa.com/minha-app:latest

            # Logout após uso (boa prática)
            docker logout registry.empresa.com 2>/dev/null || true
          '''
        }
      }
    }

    stage('Acessar Banco de Dados') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'postgres-credentials',
            usernameVariable: 'DB_USER',
            passwordVariable: 'DB_PASS'
          )
        ]) {
          sh '''
            echo "Conectando ao banco de dados..."
            echo "Usuário: $DB_USER"

            # Usando variável PGPASSWORD para não expor na linha de comando
            export PGPASSWORD="$DB_PASS"
            # psql -h db.empresa.com -U "$DB_USER" -d minha_database -c "SELECT 1"
            unset PGPASSWORD   # Remove da memória após uso

            echo "Migração de banco concluída (simulada)"
          '''
        }
      }
    }

  } // Fecha stages

  post {
    always {
      sh 'docker logout 2>/dev/null || true'  // Garante logout do Docker
      sh 'rm -f ~/.netrc 2>/dev/null || true'  // Remove credenciais temporárias
    }
  }

} // Fecha pipeline

// ============================================================
// COMO CADASTRAR USERNAME WITH PASSWORD NO JENKINS:
//
// 1. Manage Jenkins → Credentials → System → Global credentials
// 2. Add Credentials
// 3. Kind: Username with password
// 4. Username: seu-usuario
// 5. Password: sua-senha
// 6. ID: docker-hub-credentials
// 7. Description: Credenciais do Docker Hub (username + password)
// 8. OK
//
// VARIÁVEIS AUTOMÁTICAS GERADAS:
// Se o ID for 'minha-cred':
//   MINHA_CRED     → "username:password" (evite usar)
//   MINHA_CRED_USR → só o username (seguro para logs)
//   MINHA_CRED_PSW → só a senha (mascarada nos logs)
// ============================================================
