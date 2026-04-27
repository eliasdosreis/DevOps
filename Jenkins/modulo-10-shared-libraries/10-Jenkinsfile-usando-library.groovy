// ============================================================
// MÓDULO 10 — SHARED LIBRARIES
// Arquivo: 10-Jenkinsfile-usando-library.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Jenkinsfile que CONSOME a shared library.
// Observe como o Jenkinsfile fica MINÚSCULO — toda lógica está
// na library, reutilizável por todos os projetos.
// ============================================================

// ============================================================
// IMPORTAÇÃO DA SHARED LIBRARY
// Três formas de importar:
//
// 1. Configurada globalmente (Manage Jenkins → System → Global Pipeline Libraries)
//    @Library('minha-library') _      → usa o branch padrão
//    @Library('minha-library@v2.0.0') _ → versão específica
//    @Library('minha-library@develop') _ → branch específico
//
// 2. Implicitamente (sem @Library) se configurada como "Load implicitly"
//
// 3. Via script (dynamic loading):
//    library 'minha-library@main'
// ============================================================

@Library('jenkins-shared-library@main') _
// O underscore '_' é necessário: importa o namespace da library sem criar variável
// Equivalente a: import org.company.* em Java

// ============================================================
// EXEMPLO 1: Usando o standardPipeline (pipeline completo em 1 linha!)
// ============================================================
standardPipeline(
  tipo:       'maven',
  appName:    'user-service',
  dockerRepo: 'minha-org/user-service',
  deployEnvs: ['staging'],
  sonarScan:  true,
  trivyScan:  true
)

// ============================================================
// FIM DO JENKINSFILE! Todo o restante está na shared library.
// Isso é o sonho do DevOps: Jenkinsfile de 10 linhas para
// um pipeline enterprise completo.
// ============================================================
