// ============================================================
// MÓDULO 7 — DOCKER E CONTAINERS NO PIPELINE
// Arquivo: 07-Jenkinsfile-trivy-scan.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Scan de vulnerabilidades em imagens Docker com Trivy.
// O Trivy verifica: CVEs no OS, pacotes, dependências de linguagem.
// Integração com qualidade: falha o build se CVEs críticos forem encontrados.
// ============================================================

pipeline {
  agent any

  environment {
    IMAGE_NAME    = 'nginx:latest'              // Imagem a escanear (pode ser a sua)
    TRIVY_SEVERITY = 'CRITICAL,HIGH'            // Níveis que causam falha do build
    TRIVY_EXIT_CODE = '1'                       // Exit code quando vulnerabilidade encontrada
  }

  stages {

    stage('Instalar Trivy') {
      steps {
        sh '''
          # Verificar se Trivy já está instalado
          if command -v trivy &>/dev/null; then
            echo "Trivy já instalado: $(trivy --version)"
          else
            echo "Instalando Trivy..."
            # Download direto (para Linux x64)
            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.50.0
            echo "Trivy instalado: $(trivy --version)"
          fi
        '''
      }
    }

    stage('Pull da Imagem para Scan') {
      steps {
        sh "docker pull ${IMAGE_NAME}"
      }
    }

    stage('Trivy: Scan Completo (informativo)') {
      steps {
        sh """
          trivy image \
            --severity ALL \
            --exit-code 0 \
            --format table \
            ${IMAGE_NAME}
          # --severity ALL: mostra todas as severidades
          # --exit-code 0: não falha — apenas informa (modo informativo)
          # --format table: saída em tabela legível
        """
      }
    }

    stage('Trivy: Scan com Quality Gate') {
      steps {
        sh """
          trivy image \
            --severity ${TRIVY_SEVERITY} \
            --exit-code ${TRIVY_EXIT_CODE} \
            --format table \
            --ignore-unfixed \
            ${IMAGE_NAME}
          # --severity: apenas estas severidades causam exit code != 0
          # --exit-code 1: falha o build se encontrar CVEs das severidades acima
          # --ignore-unfixed: ignora CVEs sem fix disponível (reduz falsos positivos)
        """
        // Se este comando falhar (CVE crítico encontrado), o build FALHA
        // É o "Quality Gate" de segurança equivalente ao SonarQube
      }
    }

    stage('Trivy: Relatório JSON') {
      steps {
        sh """
          trivy image \
            --severity ${TRIVY_SEVERITY} \
            --exit-code 0 \
            --format json \
            --output trivy-report.json \
            ${IMAGE_NAME}
        """
        archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
      }
    }

    stage('Trivy: Relatório SARIF (GitHub/GitLab)') {
      steps {
        sh """
          trivy image \
            --severity ALL \
            --exit-code 0 \
            --format sarif \
            --output trivy-report.sarif \
            ${IMAGE_NAME}
          # SARIF: formato padrão para upload em GitHub Security tab
        """
        archiveArtifacts artifacts: 'trivy-report.sarif', allowEmptyArchive: true
      }
    }

    stage('Trivy: Scan de Filesystem (dependências)') {
      steps {
        sh """
          trivy fs \
            --severity ${TRIVY_SEVERITY} \
            --exit-code 0 \
            .
          # Escaneia o filesystem local (detecta vulnerabilidades em
          # package.json, requirements.txt, pom.xml, go.sum, etc.)
        """
      }
    }

    stage('Resumo de Segurança') {
      steps {
        script {
          def report = readJSON file: 'trivy-report.json'
          def totalVulns = 0
          def criticals = 0
          def highs = 0

          report.Results?.each { result ->
            result.Vulnerabilities?.each { vuln ->
              totalVulns++
              if (vuln.Severity == 'CRITICAL') criticals++
              if (vuln.Severity == 'HIGH') highs++
            }
          }

          echo """
=== SUMÁRIO DE SEGURANÇA ===
Imagem:          ${IMAGE_NAME}
Total CVEs:      ${totalVulns}
Críticos:        ${criticals}
Altos:           ${highs}

Threshold:       ${TRIVY_SEVERITY}
Status:          ${criticals == 0 && highs == 0 ? '✅ APROVADO' : '⚠️  ATENÇÃO'}
          """
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline
