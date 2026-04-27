// ============================================================
// MÓDULO 8 — AGENTS E NODES
// Arquivo: 08-Jenkinsfile-multi-agent.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Pipeline que usa múltiplos agentes diferentes em stages distintos.
// Demonstra: agent none + agent por stage + compartilhamento via stash.
// ============================================================

pipeline {
  // 'agent none': NENHUM agente global
  // Cada stage DEVE definir seu próprio agente
  // Esta é a configuração mais granular e eficiente
  agent none

  stages {

    // ---------------------------------------------------------
    // STAGE 1: Compilação — Agente Linux com Maven
    // ---------------------------------------------------------
    stage('Compilar (Linux Maven)') {
      agent {
        label 'linux && maven'
      }
      steps {
        checkout scm
        sh 'mvn clean package -B -DskipTests'
        echo "Compilado no agent: ${env.NODE_NAME}"

        // Salva o artefato para uso em outros agentes
        stash name: 'app-jar', includes: 'target/*.jar'
      }
    }

    // ---------------------------------------------------------
    // STAGE 2: Testes — Agentes em paralelo (Linux e Windows)
    // ---------------------------------------------------------
    stage('Testes em Múltiplos Ambientes') {
      parallel {

        stage('Testes Linux') {
          agent {
            label 'linux'
          }
          steps {
            unstash 'app-jar'  // Recupera o JAR compilado no stage anterior
            sh '''
              echo "Rodando testes no Linux"
              echo "Agent: $NODE_NAME"
              java -jar target/*.jar --test
            '''
          }
        }

        stage('Testes Windows') {
          agent {
            label 'windows'
          }
          steps {
            unstash 'app-jar'  // O mesmo JAR, no agente Windows
            bat '''
              echo Rodando testes no Windows
              echo Agent: %NODE_NAME%
            '''
          }
        }

        stage('Testes macOS') {
          agent {
            label 'macos'
          }
          steps {
            unstash 'app-jar'
            sh 'echo "Testes no macOS no agent: $NODE_NAME"'
          }
        }

      } // Fecha parallel
    }

    // ---------------------------------------------------------
    // STAGE 3: Docker Build — Agente com Docker
    // ---------------------------------------------------------
    stage('Docker Build (Linux Docker)') {
      agent {
        label 'linux && docker'
      }
      steps {
        unstash 'app-jar'  // Recupera o JAR para incluir na imagem Docker
        sh '''
          echo "Building Docker image no agent Docker-enabled"
          echo "Agent: $NODE_NAME"
          docker build -t minha-app:${BUILD_NUMBER} .
        '''
        stash name: 'docker-tag', includes: 'docker-tag.txt'
      }
    }

    // ---------------------------------------------------------
    // STAGE 4: Deploy — Agente de Produção (acesso restrito)
    // ---------------------------------------------------------
    stage('Deploy Prod') {
      agent {
        label 'producao'
        // Este label só existe em agentes configurados especificamente
        // para acesso ao ambiente de produção
        // Garante que o deploy só acontece nesta máquina controlada
      }
      when {
        branch 'main'
      }
      steps {
        unstash 'app-jar'
        sh '''
          echo "Deploy no agente de produção seguro"
          echo "Agent: $NODE_NAME"
          # kubectl apply -f k8s/
        '''
      }
    }

  } // Fecha stages

  post {
    always {
      node('linux') {  // Executar o post em um node Linux genérico
        echo "Limpeza pós-build em: ${env.NODE_NAME}"
        // cleanWs()
      }
    }
  }

} // Fecha pipeline

// ============================================================
// CONCEITO SENIOR: agent none vs agent any
//
// agent any:
//   ✅ Simples para começar
//   ✅ Jenkins escolhe automaticamente
//   ❌ Todos os stages no mesmo agente (ineficiente)
//   ❌ Não aproveita especialização dos agentes
//
// agent none:
//   ✅ Máximo controle e granularidade
//   ✅ Cada stage no agente mais adequado
//   ✅ Paralelos em agentes diferentes simultaneamente
//   ❌ Requer stash/unstash para compartilhar arquivos
//   ❌ Mais verboso
//
// QUANDO USAR agent none:
// - Quando stages precisam de ferramentas diferentes
// - Quando algumas stages devem rodar em ambientes restritos
// - Quando quer maximizar paralelismo em múltiplas máquinas
// - Em pipelines maduros de produção
// ============================================================
