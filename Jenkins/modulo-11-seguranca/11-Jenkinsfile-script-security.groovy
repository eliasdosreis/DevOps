// ============================================================
// MÓDULO 11 — SEGURANÇA E GOVERNANÇA
// Arquivo: 11-Jenkinsfile-script-security.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o funcionamento do Script Security Plugin do Jenkins
// e como lidar com aprovações de scripts Groovy.
// ============================================================

pipeline {
  agent any

  stages {

    stage('Script Security: Contexto') {
      steps {
        script {
          echo """
=== SCRIPT SECURITY PLUGIN ===

O Jenkins sandbox analisa cada script Groovy antes de executar.
Scripts não aprovados causam:
  "org.jenkinsci.plugins.scriptsecurity.sandbox.RejectedAccessException"

COMO FUNCIONA:
1. Script é submetido para execução
2. Sandbox verifica cada método/propriedade chamada
3. Se o método não estiver na allowlist → BLOQUEADO
4. Admin pode aprovar manualmente: Manage Jenkins → In-process Script Approval

DOIS MODOS:
• Sandbox (modo padrão): restringe métodos não aprovados
• Aprovação de script inteiro: admin aprova o script completo
          """
        }
      }
    }

    stage('Métodos PERMITIDOS no Sandbox') {
      steps {
        script {
          // Operações básicas — sempre permitidas no sandbox
          def lista = ['a', 'b', 'c']
          def mapa = [chave: 'valor']
          def numero = 42

          // String operations
          echo lista.join(', ')
          echo mapa.chave
          echo numero.toString()

          // Jenkins env (sempre permitido)
          echo env.BUILD_NUMBER
          echo currentBuild.result ?: 'ainda executando'

          // Shell commands (sh é permitido)
          sh 'echo "Shell sempre permitido no sandbox"'

          // Leitura de arquivos (geralmente permitida)
          // def conteudo = readFile('arquivo.txt')

          // JSON parsing (permitido)
          def json = new groovy.json.JsonSlurperClassic()
            .parseText('{"nome": "Jenkins", "versao": 2}')
          echo "JSON: ${json.nome} v${json.versao}"
        }
      }
    }

    stage('Métodos que REQUEREM Aprovação') {
      steps {
        script {
          echo "=== EXEMPLOS QUE REQUEREM APROVAÇÃO DO ADMIN ==="

          // ⚠️  Acesso ao sistema de arquivos
          // new File('/etc/passwd').text  // BLOQUEADO sem aprovação

          // ⚠️  Chamadas de classe Java não-permitidas
          // Runtime.exec('rm -rf /')     // BLOQUEADO

          // ⚠️  Acesso a variáveis de instância privadas
          // jenkins.model.Jenkins.instance  // BLOQUEADO sem aprovação

          // ⚠️  Métodos de rede direta
          // new URL('http://server.com').text  // BLOQUEADO

          // ALTERNATIVAS SEGURAS:
          // Use sh '' para executar comandos do sistema
          sh 'cat /etc/hostname 2>/dev/null || echo "sem permissão"'

          // Use readFile() para ler arquivos (plugin permite)
          // def conteudo = readFile(file: 'config.txt', encoding: 'UTF-8')

          // Use httpRequest plugin para chamadas HTTP
          // def resp = httpRequest url: 'https://api.exemplo.com'

          echo "Use as alternativas seguras em vez dos métodos bloqueados"
        }
      }
    }

    stage('@NonCPS: Serializabilidade') {
      steps {
        script {
          // Pipelines Jenkins precisam que o estado seja serializável
          // (salvo em disco entre stages para resiliência)
          // Certas classes Java não são serializáveis → erro ao suspender

          // @NonCPS marca métodos que NÃO precisam ser serializáveis
          // Use para manipulação de dados que completam rapidamente
          def resultado = processarDados(['a', 'b', 'c'])
          echo "Resultado: ${resultado}"
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline

// Método com @NonCPS: não é checkpointed pelo Jenkins
// Use para: sorting, filtering, data transformation com iteradores Java
@NonCPS
def processarDados(List<String> items) {
  // Iterators Java (como .stream()) precisam de @NonCPS
  return items.collect { it.toUpperCase() }.join(', ')
}
