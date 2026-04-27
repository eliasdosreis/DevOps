// ============================================================
// MÓDULO 3 — VARIÁVEIS, PARÂMETROS E ENVIRONMENT
// Arquivo: 03-Jenkinsfile-env-builtin.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra todas as variáveis de ambiente nativas do Jenkins.
// São variáveis que o Jenkins preenche automaticamente em cada build.
//
// ANALOGIA DO DIA A DIA:
// Como as informações automáticas num crachá de empresa:
// nome, cargo, data de entrada são preenchidos automaticamente
// pela RH — você não precisa preencher. O Jenkins faz o mesmo
// com BUILD_NUMBER, JOB_NAME, GIT_BRANCH, etc.
// ============================================================

pipeline {
  agent any

  stages {

    stage('Variáveis Built-in do Jenkins') {
      steps {
        script {
          // ==================================================
          // GRUPO 1: Informações do BUILD
          // ==================================================
          echo "=== INFORMAÇÕES DO BUILD ==="

          echo "BUILD_NUMBER:      ${env.BUILD_NUMBER}"
          // Número sequencial deste build (1, 2, 3, ...)
          // Útil para: versionamento de artefatos, tags Docker

          echo "BUILD_ID:          ${env.BUILD_ID}"
          // Identificador único do build (geralmente = BUILD_NUMBER)

          echo "BUILD_URL:         ${env.BUILD_URL}"
          // URL completa do build na interface web do Jenkins
          // Ex: http://jenkins.empresa.com/job/minha-app/42/
          // Útil para: links em notificações de Slack/email

          echo "BUILD_TAG:         ${env.BUILD_TAG}"
          // Formato: jenkins-<JOB_NAME>-<BUILD_NUMBER>
          // Útil para: tag de imagem Docker, identificação de artefato

          echo "BUILD_DISPLAY_NAME: ${env.BUILD_DISPLAY_NAME}"
          // Nome exibido na interface (geralmente #BUILD_NUMBER)
          // Pode ser customizado com: currentBuild.displayName = 'v2.0.0'

          echo "BUILD_CAUSE:       ${currentBuild.getBuildCauses()[0]?.shortDescription}"
          // O que causou este build: usuário, webhook, cron, etc.

          // ==================================================
          // GRUPO 2: Informações do JOB
          // ==================================================
          echo "\n=== INFORMAÇÕES DO JOB ==="

          echo "JOB_NAME:          ${env.JOB_NAME}"
          // Nome do job (ex: minha-app ou pasta/minha-app)

          echo "JOB_BASE_NAME:     ${env.JOB_BASE_NAME}"
          // Nome do job sem o caminho de pastas

          echo "JOB_URL:           ${env.JOB_URL}"
          // URL do job (sem o número do build)

          // ==================================================
          // GRUPO 3: Informações do AGENTE/NODE
          // ==================================================
          echo "\n=== INFORMAÇÕES DO AGENTE ==="

          echo "NODE_NAME:         ${env.NODE_NAME}"
          // Nome do agente onde este stage está executando
          // 'built-in' = está rodando no Controller (evite em produção!)

          echo "NODE_LABELS:       ${env.NODE_LABELS}"
          // Labels do agente atual (ex: 'linux docker')

          echo "WORKSPACE:         ${env.WORKSPACE}"
          // Caminho absoluto do diretório de trabalho
          // Ex: /var/jenkins_home/workspace/minha-app
          // ATENÇÃO: cada build tem seu próprio WORKSPACE

          echo "EXECUTOR_NUMBER:   ${env.EXECUTOR_NUMBER}"
          // Índice do executor atual (0, 1, 2, ...) — útil para debug

          // ==================================================
          // GRUPO 4: Informações do JENKINS
          // ==================================================
          echo "\n=== INFORMAÇÕES DO JENKINS ==="

          echo "JENKINS_URL:       ${env.JENKINS_URL}"
          // URL base do Jenkins (ex: http://jenkins.empresa.com/)

          echo "JENKINS_HOME:      ${env.JENKINS_HOME}"
          // Diretório home do Jenkins no sistema de arquivos

          // ==================================================
          // GRUPO 5: Informações do GIT (disponíveis após checkout)
          // ==================================================
          echo "\n=== INFORMAÇÕES DO GIT (após checkout) ==="

          // Estas variáveis só existem se o job fez checkout de um repositório Git
          echo "GIT_BRANCH:        ${env.GIT_BRANCH ?: 'N/A (sem checkout)'}"
          // Branch atual (ex: main, develop, feature/auth)
          // No Multibranch Pipeline: BRANCH_NAME é mais confiável

          echo "GIT_COMMIT:        ${env.GIT_COMMIT ?: 'N/A (sem checkout)'}"
          // Hash completo do commit atual (40 caracteres)
          // Use para: tags imutáveis, rastreabilidade de artefatos

          echo "GIT_URL:           ${env.GIT_URL ?: 'N/A (sem checkout)'}"
          // URL do repositório Git

          echo "GIT_AUTHOR_NAME:   ${env.GIT_AUTHOR_NAME ?: 'N/A'}"
          // Autor do último commit

          // ==================================================
          // GRUPO 6: Informações do MULTIBRANCH PIPELINE
          // ==================================================
          echo "\n=== MULTIBRANCH PIPELINE ==="

          echo "BRANCH_NAME:       ${env.BRANCH_NAME ?: 'N/A (não é Multibranch)'}"
          // Branch atual — mais confiável que GIT_BRANCH no Multibranch
          // Disponível apenas em Multibranch Pipeline e Organization Folder

          echo "CHANGE_ID:         ${env.CHANGE_ID ?: 'N/A (não é PR)'}"
          // Número do Pull Request (se aplicável)
          // Ex: 42 (para o PR #42 no GitHub)

          echo "CHANGE_URL:        ${env.CHANGE_URL ?: 'N/A (não é PR)'}"
          // URL do Pull Request no GitHub/GitLab

          echo "CHANGE_TARGET:     ${env.CHANGE_TARGET ?: 'N/A (não é PR)'}"
          // Branch destino do PR (ex: main)
        }

        // ==================================================
        // USO PRÁTICO: construindo uma tag de versão
        // ==================================================
        script {
          def commitShort = env.GIT_COMMIT?.take(8) ?: 'abc12345'  // Primeiros 8 chars do commit
          def tagImagem = "minha-app:${BUILD_NUMBER}-${commitShort}"
          echo "\n=== EXEMPLO PRÁTICO ==="
          echo "Tag Docker gerada: ${tagImagem}"
          // Resultado: minha-app:42-abc12345
          // Esta tag é única, imutável e rastreável
        }

      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// VARIÁVEIS BUILT-IN MAIS USADAS NO DIA A DIA:
//
// ${BUILD_NUMBER}   → número sequencial do build
// ${BUILD_URL}      → link direto para o build (útil em notificações)
// ${JOB_NAME}       → nome do job (para identificar em logs)
// ${NODE_NAME}      → agente que executou (para debug de ambiente)
// ${WORKSPACE}      → onde os arquivos do build ficam
// ${GIT_COMMIT}     → hash do commit (para rastreabilidade)
// ${GIT_BRANCH}     → branch (para condicionais de deploy)
// ${BRANCH_NAME}    → branch no Multibranch (mais confiável)
// ============================================================
