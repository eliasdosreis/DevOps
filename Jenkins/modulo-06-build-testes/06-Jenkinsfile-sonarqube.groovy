// ============================================================
// MÓDULO 6 — BUILD E TESTES
// Arquivo: 06-Jenkinsfile-sonarqube.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Análise de qualidade de código com SonarQube + Quality Gate.
// O SonarQube analisa: bugs, code smells, dívida técnica,
// cobertura de código, duplicações e vulnerabilidades de segurança.
//
// ANALOGIA DO DIA A DIA:
// Como uma inspeção veicular: o carro (código) precisa passar
// por uma inspeção (SonarQube) antes de circular (ir para produção).
// O resultado é um LAUDO (Quality Gate): aprovado ou reprovado.
// ============================================================

pipeline {
  agent any

  environment {
    SONAR_HOST_URL = 'http://sonarqube:9000'  // URL do servidor SonarQube
    SONAR_PROJECT_KEY = 'minha-aplicacao'      // ID único do projeto no Sonar
    SONAR_PROJECT_NAME = 'Minha Aplicação'     // Nome exibido no SonarQube
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build e Testes (com cobertura)') {
      steps {
        // O SonarQube precisa do relatório de cobertura para medir cobertura
        sh '''
          mvn clean verify -B \
            -Pcoverage \
            -DskipIntegrationTests
          # verify: compila + testa + verifica
          # Pcoverage: profile que ativa JaCoCo para cobertura
        '''
      }
      post {
        always {
          junit(
            testResults: 'target/surefire-reports/*.xml',
            allowEmptyResults: true
          )
        }
      }
    }

    stage('Análise SonarQube') {
      steps {
        withCredentials([
          string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')
        ]) {
          // Usando o plugin SonarQube Scanner do Jenkins
          withSonarQubeEnv('SonarQube') {
            // 'SonarQube': nome da instalação configurada em Manage Jenkins → Systems
            sh '''
              mvn sonar:sonar -B \
                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                -Dsonar.host.url=${SONAR_HOST_URL} \
                -Dsonar.token=${SONAR_TOKEN} \
                -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                -Dsonar.junit.reportPaths=target/surefire-reports
            '''
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        // Aguarda o SonarQube processar e retornar o resultado
        // Timeout padrão: 1 hora (pode ajustar conforme tamanho do projeto)
        timeout(time: 5, unit: 'MINUTES') {
          script {
            // Aguarda o webhook do SonarQube com o resultado
            // Requer configuração de webhook no SonarQube apontando para Jenkins
            def qualityGate = waitForQualityGate()

            if (qualityGate.status != 'OK') {
              // FAILED ou WARN — falha o build
              error "❌ Quality Gate FALHOU! Status: ${qualityGate.status}\nAcesse o SonarQube para detalhes."
            } else {
              echo "✅ Quality Gate APROVADO! Status: ${qualityGate.status}"
            }
          }
        }
      }
    }

    stage('Relatório de Qualidade') {
      steps {
        script {
          echo """
=== MÉTRICAS SONARQUBE ===
Acesse: ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}

O que o SonarQube analisa:
• Bugs:           Problemas que causarão comportamento inesperado
• Vulnerabilities: Falhas de segurança exploráveis
• Code Smells:    Código difícil de manter (dívida técnica)
• Coverage:       % do código coberto por testes
• Duplications:   Código duplicado em %
• Security Hotspots: Áreas que requerem revisão de segurança

Quality Gate padrão (pode ser customizado):
• Coverage ≥ 80%
• Duplications ≤ 3%
• Maintainability Rating: A
• Reliability Rating: A
• Security Rating: A
          """
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// CONFIGURAR SONARQUBE + JENKINS:
//
// 1. Subir SonarQube via Docker:
//    docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
//
// 2. No SonarQube (http://localhost:9000):
//    - admin/admin inicial
//    - My Account → Security → Generate Token → copie o token
//    - Administration → Configuration → Webhooks → Create:
//      Name: Jenkins
//      URL: http://jenkins:8080/sonarqube-webhook/
//
// 3. No Jenkins:
//    - Instale: SonarQube Scanner for Jenkins
//    - Manage Jenkins → System → SonarQube servers:
//      Name: SonarQube (mesmo nome do withSonarQubeEnv!)
//      URL: http://sonarqube:9000
//      Token: (credential com o token gerado acima)
// ============================================================
