// ============================================================
// MÓDULO 3 — VARIÁVEIS, PARÂMETROS E ENVIRONMENT
// Arquivo: 03-Jenkinsfile-parametros.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra TODOS os tipos de parâmetros disponíveis no Jenkins.
// Parâmetros permitem que o usuário forneça entrada ANTES de iniciar
// o build — tornando o pipeline reutilizável e flexível.
//
// ANALOGIA DO DIA A DIA:
// Como um formulário de pedido num restaurante:
// - String: "Mesa número: ___"
// - Boolean: "Sem glúten: [X]"
// - Choice: "Ponto da carne: [bem passado] [ao ponto] [mal passado]"
// - Password: "Código do cartão fidelidade: ****"
// ============================================================

pipeline {
  agent any

  // ===========================================================
  // BLOCO: parameters
  // Define os campos que aparecem na tela "Build with Parameters"
  // O primeiro build NÃO mostrará parâmetros — apenas o segundo.
  // Isso ocorre porque o Jenkins precisa executar o pipeline uma vez
  // para descobrir os parâmetros definidos no Jenkinsfile.
  // ===========================================================
  parameters {

    // ---------------------------------------------------------
    // TIPO 1: string
    // Campo de texto livre de uma linha
    // ---------------------------------------------------------
    string(
      name: 'VERSAO',                   // ID da variável (acesso: params.VERSAO)
      defaultValue: '1.0.0',            // Valor padrão se não for preenchido
      description: 'Versão da aplicação a ser buildada (formato semver: x.y.z)',
      trim: true                         // Remove espaços no início/fim automaticamente
    )

    // ---------------------------------------------------------
    // TIPO 2: text
    // Campo de texto multi-linha (útil para JSON, YAML, scripts)
    // ---------------------------------------------------------
    text(
      name: 'CHANGELOG',
      defaultValue: '- Melhoria de performance\n- Correção de bugs',
      description: 'Changelog desta versão (suporta múltiplas linhas)'
    )

    // ---------------------------------------------------------
    // TIPO 3: booleanParam
    // Checkbox (true/false)
    // ---------------------------------------------------------
    booleanParam(
      name: 'EXECUTAR_TESTES',
      defaultValue: true,
      description: 'Marque para executar os testes automatizados'
    )

    booleanParam(
      name: 'EXECUTAR_DEPLOY',
      defaultValue: false,
      description: 'Marque para fazer deploy após o build'
    )

    booleanParam(
      name: 'MODO_DEBUG',
      defaultValue: false,
      description: 'Ativa logging detalhado para troubleshooting'
    )

    // ---------------------------------------------------------
    // TIPO 4: choice
    // Lista suspensa com opções pré-definidas
    // O PRIMEIRO item da lista é o valor padrão
    // ---------------------------------------------------------
    choice(
      name: 'AMBIENTE',
      choices: ['dev', 'staging', 'prod'],   // O primeiro ('dev') é o padrão
      description: 'Ambiente de destino do deploy'
    )

    choice(
      name: 'ESTRATEGIA_DEPLOY',
      choices: ['rolling', 'blue-green', 'canary'],
      description: 'Estratégia de implantação a ser usada'
    )

    // ---------------------------------------------------------
    // TIPO 5: password
    // Campo de texto mascarado (não aparece nos logs)
    // ATENÇÃO: Use Credentials Store para secrets reais!
    // Este tipo é apenas para entradas ocasionais do usuário.
    // ---------------------------------------------------------
    password(
      name: 'TOKEN_DEPLOY_EMERGENCIA',
      defaultValue: '',
      description: 'Token de autorização para deploy de emergência (use com cautela!)'
    )

    // ---------------------------------------------------------
    // TIPO 6: file (upload de arquivo)
    // Permite que o usuário faça upload de um arquivo antes do build
    // ---------------------------------------------------------
    // file(
    //   name: 'CONFIG_FILE',
    //   description: 'Arquivo de configuração para este build específico'
    // )

    // ---------------------------------------------------------
    // TIPO 7: run (seleção de build)
    // Permite selecionar um build específico de outro job
    // Útil para pipelines de promoção (promover build X para prod)
    // ---------------------------------------------------------
    // run(
    //   name: 'BUILD_ORIGEM',
    //   projectName: 'minha-app-build',
    //   description: 'Build a ser promovido para produção'
    // )

    // ---------------------------------------------------------
    // TIPO 8: Parâmetros de plugins externos
    // (exigem plugins adicionais instalados)
    // ---------------------------------------------------------
    // gitParameter: seleciona branch/tag/commit do Git
    // extendedChoice: listas com múltipla seleção
    // activeChoiceParam: parâmetros dinâmicos que dependem de outros
  }

  stages {

    stage('Exibir Parâmetros Recebidos') {
      steps {
        script {
          echo "=== PARÂMETROS FORNECIDOS PELO USUÁRIO ==="
          echo "Versão:            ${params.VERSAO}"
          echo "Ambiente:          ${params.AMBIENTE}"
          echo "Estratégia Deploy: ${params.ESTRATEGIA_DEPLOY}"
          echo "Executar Testes:   ${params.EXECUTAR_TESTES}"
          echo "Executar Deploy:   ${params.EXECUTAR_DEPLOY}"
          echo "Modo Debug:        ${params.MODO_DEBUG}"
          echo "Changelog:"
          echo "${params.CHANGELOG}"
          // NUNCA imprima params.TOKEN_DEPLOY_EMERGENCIA no log!
          // O Jenkins mascara passwords, mas é boa prática não tentar
        }
      }
    }

    stage('Build') {
      steps {
        script {
          if (params.MODO_DEBUG) {
            echo "🔍 MODO DEBUG ATIVO — logs detalhados habilitados"
            sh 'env | sort'  // Imprime TODAS as variáveis de ambiente (cuidado com secrets!)
          }
          echo "Buildando versão ${params.VERSAO} para ${params.AMBIENTE}..."
        }
      }
    }

    stage('Testes') {
      when {
        expression { params.EXECUTAR_TESTES == true }
        // Este stage é pulado se EXECUTAR_TESTES for false
      }
      steps {
        echo "🧪 Executando testes (podem ser pulados via parâmetro)..."
        sh 'echo "Testes executados com sucesso"'
      }
    }

    stage('Validar Ambiente de Produção') {
      when {
        allOf {
          expression { params.AMBIENTE == 'prod' }
          expression { params.EXECUTAR_DEPLOY == true }
        }
      }
      steps {
        echo "⚠️  Deploy para PRODUÇÃO solicitado!"
        echo "Estratégia: ${params.ESTRATEGIA_DEPLOY}"
        echo "Versão:     ${params.VERSAO}"

        // Validação manual para produção
        input(
          message: "Confirma deploy da versão ${params.VERSAO} em PRODUÇÃO?",
          ok: 'Confirmar Deploy',
          submitter: 'admin,tech-lead'  // Apenas admin e tech-lead podem confirmar
        )
      }
    }

    stage('Deploy') {
      when {
        expression { params.EXECUTAR_DEPLOY == true }
      }
      steps {
        script {
          echo "🚀 Iniciando deploy..."
          echo "Ambiente:   ${params.AMBIENTE}"
          echo "Versão:     ${params.VERSAO}"
          echo "Estratégia: ${params.ESTRATEGIA_DEPLOY}"

          switch (params.ESTRATEGIA_DEPLOY) {
            case 'rolling':
              echo "Executando Rolling Deploy..."
              break
            case 'blue-green':
              echo "Executando Blue-Green Deploy..."
              break
            case 'canary':
              echo "Executando Canary Deploy (10% do tráfego)..."
              break
            default:
              error "Estratégia de deploy desconhecida: ${params.ESTRATEGIA_DEPLOY}"
          }
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// DICA SENIOR: Parâmetros com valores padrão seguros
//
// RUIM (inseguro e frágil):
//   booleanParam(name: 'EXECUTAR_DEPLOY', defaultValue: true)
//   → Um click errado faz deploy em produção!
//
// BOM (seguro por padrão):
//   booleanParam(name: 'EXECUTAR_DEPLOY', defaultValue: false)
//   → O usuário precisa marcar explicitamente para deployar
//
// REGRA: Para ações destrutivas ou irreversíveis,
//        o defaultValue deve ser sempre false/mais seguro.
//
// NOTA SOBRE O PRIMEIRO BUILD:
// Na primeira execução, o Jenkins ainda não "conhece" os parâmetros
// definidos no Jenkinsfile. O primeiro build sempre roda com os
// defaultValues. A partir do segundo build, a tela "Build with
// Parameters" aparece na interface.
// ============================================================
