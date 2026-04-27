// ============================================================
// MÓDULO 6 — BUILD E TESTES
// Arquivo: 06-Jenkinsfile-maven.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline completo de build Java com Apache Maven:
// compilação, testes unitários, testes de integração,
// publicação de relatórios e arquivamento de artefatos.
// ============================================================

pipeline {
  agent any

  tools {
    // Jenkins pode gerenciar instalações de ferramentas automaticamente
    // Configure em: Manage Jenkins → Tools → Maven installations
    maven 'maven-3.9'    // Nome configurado no Jenkins
    jdk   'jdk-21'       // Nome da instalação do JDK
  }

  environment {
    MAVEN_OPTS = '-Xms256m -Xmx1024m'  // Memória JVM para Maven
    APP_VERSION = sh(
      script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2>/dev/null || echo "1.0.0"',
      returnStdout: true
    ).trim()
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'mvn --version'   // Confirma que Maven está disponível
        sh 'java --version'  // Confirma que Java está disponível
      }
    }

    stage('Compilar (mvn compile)') {
      steps {
        echo "🔨 Compilando com Maven ${env.APP_VERSION}"
        sh 'mvn clean compile -B'
        // -B = batch mode (sem cores/progressbars — melhor para logs CI)
        // clean = remove target/ antes de compilar
        // compile = compila o código fonte
      }
    }

    stage('Testes Unitários (mvn test)') {
      steps {
        sh '''
          mvn test -B \
            -Dsurefire.failIfNoSpecifiedTests=false
          # -B: batch mode
          # failIfNoSpecifiedTests=false: não falha se não houver testes
        '''
      }
      post {
        always {
          // Publica relatório JUnit na interface do Jenkins
          junit(
            testResults: 'target/surefire-reports/*.xml',
            allowEmptyResults: true  // Não falha se não houver relatório
          )
          // Agora acesse: Build → Test Result para ver os testes
        }
        unstable {
          echo "⚠️  Alguns testes falharam — build marcado como UNSTABLE"
        }
      }
    }

    stage('Testes de Integração (mvn verify)') {
      steps {
        sh '''
          mvn verify -B \
            -DskipUnitTests        \
            -Pfailsafe             \
            -Dfailsafe.failIfNoSpecifiedTests=false
          # verify: compila, testa, verifica (roda Failsafe para IT)
          # skipUnitTests: pula unitários (já foram executados)
          # Pfailsafe: ativa profile de testes de integração
        '''
      }
      post {
        always {
          junit(
            testResults: 'target/failsafe-reports/*.xml',
            allowEmptyResults: true
          )
        }
      }
    }

    stage('Empacotar (mvn package)') {
      steps {
        sh 'mvn package -B -DskipTests'
        // package: compila e empacota em JAR/WAR
        // DskipTests: pula testes (já foram executados nos stages anteriores)
      }
      post {
        success {
          // Arquiva o JAR gerado para download na interface
          archiveArtifacts(
            artifacts: 'target/*.jar',
            fingerprint: true,          // Gera fingerprint único do artefato
            allowEmptyArchive: false    // Falha se não encontrar o arquivo
          )
        }
      }
    }

    stage('Publicar no Nexus/Maven Repo') {
      when {
        branch 'main'
      }
      steps {
        // Publicar artefato no repositório Maven corporativo
        withCredentials([
          usernamePassword(
            credentialsId: 'nexus-credentials',
            usernameVariable: 'NEXUS_USER',
            passwordVariable: 'NEXUS_PASS'
          )
        ]) {
          sh '''
            mvn deploy -B -DskipTests \
              -DaltDeploymentRepository=nexus::default::https://nexus.empresa.com/repository/maven-releases/ \
              -Drepository.username=$NEXUS_USER \
              -Drepository.password=$NEXUS_PASS
          '''
        }
      }
    }

  } // Fecha stages

  post {
    always {
      cleanWs()  // Limpa o workspace ao final de cada build
    }
    failure {
      echo "❌ Build Maven falhou. Verifique os testes acima."
    }
  }

} // Fecha pipeline
