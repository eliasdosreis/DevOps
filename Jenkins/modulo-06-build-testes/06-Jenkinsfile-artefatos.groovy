// ============================================================
// MÓDULO 6 — BUILD E TESTES
// Arquivo: 06-Jenkinsfile-artefatos.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o sistema de artefatos do Jenkins:
// - archiveArtifacts: salva arquivos do build
// - fingerprint: gera hash único do artefato
// - stash/unstash: compartilha arquivos entre stages/agentes
// - copyArtifacts: copia artefatos entre jobs
// ============================================================

pipeline {
  agent any

  stages {

    stage('Gerar Artefatos') {
      steps {
        sh '''
          mkdir -p target dist reports
          echo "Versão 1.0.0" > target/app.jar
          echo "Bundle minificado" > dist/app.min.js
          echo "Relatório de testes" > reports/test-report.html
          echo "42 testes passaram" >> reports/test-report.html
        '''
      }
    }

    stage('archiveArtifacts: Salvar no Jenkins') {
      steps {
        // ===========================================================
        // archiveArtifacts: salva arquivos no servidor Jenkins
        // Ficam disponíveis para download na interface web
        // Retidos pela política de retenção configurada no job
        // ===========================================================
        archiveArtifacts(
          artifacts: 'target/*.jar',          // Padrão glob de arquivos
          fingerprint: true,                  // Gera MD5 hash do arquivo (rastreabilidade)
          allowEmptyArchive: false,           // Falha se não encontrar arquivos
          onlyIfSuccessful: false,            // Arquiva mesmo se build falhar
          excludes: 'target/*-sources.jar'   // Exclui source JARs
        )

        // Múltiplos padrões em um único comando:
        archiveArtifacts(
          artifacts: 'dist/**,reports/**',   // Dois padrões separados por vírgula
          fingerprint: true,
          allowEmptyArchive: true
        )
      }
    }

    stage('Fingerprinting: Rastreabilidade') {
      steps {
        // fingerprint registra o MD5 do arquivo e associa a este build
        // Permite rastrear qual build gerou qual artefato
        // Usado em pipelines de promoção (promover artefato de dev para prod)
        fingerprint 'target/*.jar'

        script {
          echo """
=== O QUE É FINGERPRINT? ===
Um fingerprint é um hash MD5 do arquivo.
O Jenkins associa esse hash ao build que gerou o arquivo.

Com fingerprint você pode:
- Saber exatamente qual build gerou um JAR em produção
- Rastrear um JAR do ambiente de dev até prod
- Detectar se um artefato foi modificado após o build

Acesse: Jenkins → Fingerprints → (cole o MD5 do arquivo)
          """
        }
      }
    }

    stage('Stash: Compartilhar entre Stages') {
      steps {
        // ===========================================================
        // stash: salva arquivos temporariamente no Jenkins Controller
        // Disponíveis para unstash em outros stages (mesmo agente diferente)
        // São REMOVIDOS ao final do build (diferente de archiveArtifacts)
        // ===========================================================
        stash(
          name:     'artefatos-build',          // Nome do stash (para unstash)
          includes: 'target/*.jar,dist/**',      // Arquivos a guardar
          excludes: 'target/*.tmp'               // Arquivos a excluir
        )
        echo "Stash 'artefatos-build' criado — disponível para outros stages"
      }
    }

    stage('Unstash: Recuperar em outro Stage') {
      steps {
        // ===========================================================
        // unstash: recupera o stash pelo nome
        // Funciona mesmo em agente diferente do stash
        // ===========================================================
        unstash 'artefatos-build'

        sh '''
          echo "Arquivos recuperados do stash:"
          ls -la target/ dist/ 2>/dev/null || true
        '''
      }
    }

    stage('Publicar HTML Report') {
      steps {
        // ===========================================================
        // publishHTML: publica relatórios HTML na interface do Jenkins
        // Requer plugin "HTML Publisher"
        // ===========================================================
        publishHTML(
          target: [
            allowMissing:         false,
            alwaysLinkToLastBuild: true,
            keepAll:              true,      // Mantém relatório de todos os builds
            reportDir:            'reports',
            reportFiles:          'test-report.html',
            reportName:           'Relatório de Testes',
            reportTitles:         'Test Results'
          ]
        )
      }
    }

    stage('Resumo de Artefatos') {
      steps {
        script {
          echo """
=== COMPARAÇÃO: archiveArtifacts vs stash ===

archiveArtifacts:
  ✓ Salvo permanentemente no Jenkins
  ✓ Download disponível na interface web
  ✓ Retido pela política de retenção do job
  ✓ Suporte a fingerprint
  ✓ Uso: artefatos finais (JARs, ZIPs, relatórios)

stash:
  ✓ Temporário — removido ao final do build
  ✓ Compartilha arquivos entre stages/agentes
  ✓ Mais simples que copyArtifacts
  ✓ Ideal para: passar arquivos compilados para stages de teste/deploy
  ✗ Não disponível para download
  ✗ Não persiste entre builds

copyArtifacts (plugin):
  ✓ Copia artefatos de OUTRO JOB para este
  ✓ Suporte a filtros por fingerprint
  ✓ Uso: pipelines de promoção (pegar artefato do build e promover)
          """
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline
