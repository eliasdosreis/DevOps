// ============================================================
// MÓDULO 8 — AGENTS E NODES
// Arquivo: 08-Jenkinsfile-agent-label.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra seleção de agentes por labels.
// Labels permitem direcionar stages para agentes específicos.
//
// ANALOGIA DO DIA A DIA:
// Como uma agência de talentos:
// Você pede "preciso de um especialista em solda" (label 'linux')
// A agência manda o profissional correto (agente com esse label).
// Você não precisa saber quem é, só que tem a habilidade necessária.
// ============================================================

pipeline {
  // AGENT GLOBAL: nenhum agent padrão — cada stage define o seu
  agent none

  stages {

    // ---------------------------------------------------------
    // STAGE em agente LINUX específico
    // ---------------------------------------------------------
    stage('Build no Linux') {
      agent {
        label 'linux'   // Executa em qualquer agente com a label 'linux'
        // Se houver 3 agentes Linux disponíveis, Jenkins escolhe o menos ocupado
      }
      steps {
        sh '''
          echo "Executando em agente Linux"
          uname -a
          echo "Node: $NODE_NAME"
        '''
      }
    }

    // ---------------------------------------------------------
    // STAGE em agente WINDOWS específico
    // ---------------------------------------------------------
    stage('Build no Windows') {
      agent {
        label 'windows'   // Agente com label 'windows'
      }
      steps {
        bat '''
          echo Executando em agente Windows
          echo Node: %NODE_NAME%
          systeminfo | findstr /C:"OS Name"
        '''
      }
    }

    // ---------------------------------------------------------
    // AGENT com múltiplas labels (AND lógico)
    // ---------------------------------------------------------
    stage('Stage em agente Linux COM Docker') {
      agent {
        label 'linux && docker'   // Precisa das duas labels
        // Só agentes com AMBAS as labels 'linux' E 'docker' são elegíveis
      }
      steps {
        sh '''
          docker --version
          echo "Agente tem Linux E Docker"
        '''
      }
    }

    // ---------------------------------------------------------
    // AGENT com labels OU (OR lógico)
    // ---------------------------------------------------------
    stage('Stage em qualquer Linux ou Mac') {
      agent {
        label 'linux || macos'   // Qualquer um com linux OU macos
      }
      steps {
        sh 'uname -s'
      }
    }

    // ---------------------------------------------------------
    // AGENT específico por NOME
    // ---------------------------------------------------------
    stage('Stage em agente específico') {
      agent {
        label 'agent-producao-01'   // Agente específico pelo nome
        // Use com cuidado: cria dependência em infra específica
        // Melhor usar labels para flexibilidade
      }
      steps {
        echo "Executando especificamente no agent-producao-01"
        echo "Node: ${env.NODE_NAME}"
      }
    }

    // ---------------------------------------------------------
    // AGENT com node block (para verificações dinâmicas)
    // ---------------------------------------------------------
    stage('Seleção Dinâmica de Agent') {
      agent {
        label "${params.AMBIENTE == 'prod' ? 'producao' : 'staging'}"
        // O label é calculado dinamicamente usando um parâmetro
      }
      steps {
        echo "Executando no agente correto para o ambiente: ${params.AMBIENTE}"
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// COMO CONFIGURAR LABELS NOS AGENTES:
//
// Manage Jenkins → Nodes → Selecionar agente → Configure
// Labels: linux docker maven-3.9 jdk-21
//
// CONVENÇÕES DE LABELS (exemplo de empresa):
// SO:          linux, windows, macos
// Ferramentas: docker, kubectl, maven, nodejs, python
// Ambiente:    producao, staging, desenvolvimento
// Hardware:    gpu, high-memory, ssd
// Região:      us-east, eu-west, ap-southeast
//
// Um agente pode ter múltiplos labels:
// Exemplo: "linux docker kubectl staging us-east maven"
// ============================================================
