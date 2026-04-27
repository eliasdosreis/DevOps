// ============================================================
// MÓDULO 7 — DOCKER E CONTAINERS NO PIPELINE
// Arquivo: 07-Jenkinsfile-docker-agent.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Usa containers Docker como AGENTES do pipeline.
// Cada stage pode rodar dentro de um container diferente,
// garantindo ambiente isolado e reproduzível.
//
// ANALOGIA DO DIA A DIA:
// Em vez de ter uma cozinha fixa com todas as ferramentas,
// você chama um chef especializado (container) para cada prato.
// O chef de sushi (node:18) faz o front, o chef italiano (maven:3.9)
// faz o back. Cada um traz suas próprias facas — sem conflito.
// ============================================================

pipeline {
  // ---------------------------------------------------------
  // AGENT GLOBAL: Docker container com JDK para compile/test
  // Todo stage herda este agent a menos que sobrescreva
  // ---------------------------------------------------------
  agent {
    docker {
      image 'maven:3.9-eclipse-temurin-21'  // Container com Maven + Java 21
      args  '-v /root/.m2:/root/.m2'         // Mount do cache Maven (builds mais rápidos)
      // O container é criado antes do primeiro stage e destruído após o último
    }
  }

  stages {

    stage('Build com Agent Docker Global') {
      steps {
        // Executando dentro do container maven:3.9-eclipse-temurin-21
        sh 'java --version'
        sh 'mvn --version'
        sh 'mvn clean compile -B'
      }
    }

    stage('Testes Java') {
      steps {
        sh 'mvn test -B'
      }
    }

    // ---------------------------------------------------------
    // SOBRESCREVENDO O AGENT em um stage específico
    // Este stage roda em um container Node.js diferente
    // ---------------------------------------------------------
    stage('Build Frontend (Node.js)') {
      agent {
        docker {
          image 'node:20-alpine'             // Container com Node.js 20
          reuseNode true                     // Reutiliza o workspace do stage anterior
          // SEM reuseNode: cria novo workspace vazio
          // COM reuseNode: usa o mesmo workspace (acesso aos arquivos anteriores)
        }
      }
      steps {
        sh 'node --version'
        sh 'npm --version'
        // sh 'cd frontend && npm ci && npm run build'
        echo "Frontend buildado com Node.js em container separado"
      }
    }

    // ---------------------------------------------------------
    // STAGE COM DOCKER-IN-DOCKER (DinD)
    // Rodar Docker DENTRO de um container Docker
    // ---------------------------------------------------------
    stage('Docker Build dentro de Container') {
      agent {
        docker {
          image 'docker:24-dind'           // Container com Docker CLI
          args  '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
          // --privileged: necessário para DinD
          // mount do socket: usa o Docker da máquina host (mais simples que DinD real)
        }
      }
      steps {
        sh 'docker --version'
        sh 'docker ps'    // Lista containers no host
        echo "Docker disponível dentro do container!"
      }
    }

    // ---------------------------------------------------------
    // STAGE COM PYTHON CONTAINER
    // ---------------------------------------------------------
    stage('Análise de Código (Python)') {
      agent {
        docker {
          image 'python:3.12-slim'
          args  '-v /tmp:/tmp'
          reuseNode false  // Novo workspace limpo para este stage
        }
      }
      steps {
        sh 'python3 --version'
        sh 'pip install pylint 2>/dev/null && echo "pylint instalado"'
        echo "Análise Python em container dedicado"
      }
    }

    // ---------------------------------------------------------
    // STAGE USANDO IMAGEM CUSTOMIZADA (sua própria imagem de CI)
    // ---------------------------------------------------------
    stage('Usando Imagem de CI Customizada') {
      agent {
        docker {
          image 'minha-org/ci-toolchain:latest'
          // Imagem customizada com todas as ferramentas necessárias:
          // maven + node + docker + kubectl + helm + aws-cli + etc.
          registryUrl 'https://registry.empresa.com'
          registryCredentialsId 'registry-credentials'
        }
      }
      steps {
        echo "Executando com toolchain customizado"
        // sh 'kubectl version && helm version && aws --version'
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// QUANDO USAR AGENT DOCKER?
//
// ✅ USE quando:
//   - Precisa de uma versão específica de ferramenta (Java 11 E Java 21)
//   - Quer isolamento entre builds
//   - Não quer instalar ferramentas no agente físico
//   - Múltiplos projetos com conflito de versões
//
// ❌ NÃO USE quando:
//   - O projeto precisa de recursos de hardware (GPU, etc.)
//   - Builds muito longos com muito I/O (containers têm overhead)
//   - Agente sem acesso ao Docker (ambientes restritos)
//
// REUSENODE:
//   true  → Mesmo workspace e agente do pipeline principal
//           Use: quando este stage precisa dos arquivos do stage anterior
//   false → Novo workspace vazio, pode ser agente diferente
//           Use: quando este stage é completamente independente
// ============================================================
