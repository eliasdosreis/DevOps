// ============================================================
// MÓDULO 1 — FUNDAMENTOS DE PIPELINE
// Arquivo: 01-Jenkinsfile-hello-world.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// O pipeline mais simples possível no Jenkins.
// Apenas um stage com um echo. Objetivo: entender a estrutura
// mínima obrigatória de qualquer pipeline declarativo.
//
// ANALOGIA DO DIA A DIA:
// Como aprender a andar de bicicleta com rodinhas.
// Removemos tudo que não é essencial para focar no básico:
// como o Jenkins entende e executa um arquivo Jenkinsfile.
// ============================================================

pipeline {          // [OBRIGATÓRIO] Palavra-chave raiz de todo pipeline declarativo
                    // Tudo deve estar dentro deste bloco

  agent any         // [OBRIGATÓRIO] Define ONDE o pipeline vai executar
                    // 'any' = use qualquer agent/executor disponível
                    // Alternativas: none, label 'linux', docker { image 'node:18' }

  stages {          // [OBRIGATÓRIO] Container de todos os stages do pipeline
                    // Um pipeline deve ter pelo menos um stage

    stage('Hello') {  // [OBRIGATÓRIO] Define um stage (etapa) do pipeline
                      // O texto entre aspas é o nome exibido na interface
                      // Escolha nomes descritivos: 'Build', 'Test', 'Deploy'

      steps {         // [OBRIGATÓRIO] Bloco com os passos a executar neste stage
                      // Cada step é uma instrução que o Jenkins executa

        echo 'Olá, Jenkins! Meu primeiro pipeline funcionou!'
        // echo imprime uma mensagem no log do build
        // Equivalente a um console.log() ou print()

      }               // Fecha o bloco steps
    }                 // Fecha o bloco stage('Hello')
  }                   // Fecha o bloco stages
}                     // Fecha o bloco pipeline

// ============================================================
// COMO USAR ESTE JENKINSFILE NO JENKINS:
//
// Opção 1 — Pipeline direto na interface:
//   1. New Item → Pipeline
//   2. Aba "Pipeline" → Definition: "Pipeline script"
//   3. Cole este código no campo Script
//   4. Salve e clique em "Build Now"
//
// Opção 2 — Pipeline from SCM (recomendado):
//   1. New Item → Pipeline
//   2. Aba "Pipeline" → Definition: "Pipeline script from SCM"
//   3. SCM: Git, URL do repositório
//   4. Script Path: modulo-01-fundamentos/01-Jenkinsfile-hello-world.groovy
//   5. Salve e clique em "Build Now"
//
// RESULTADO ESPERADO NO LOG:
//   [Pipeline] Start of Pipeline
//   [Pipeline] node
//   [Pipeline] {
//   [Pipeline] stage
//   [Pipeline] { (Hello)
//   [Pipeline] echo
//   Olá, Jenkins! Meu primeiro pipeline funcionou!
//   [Pipeline] }
//   [Pipeline] // stage
//   [Pipeline] }
//   [Pipeline] // node
//   [Pipeline] End of Pipeline
//   Finished: SUCCESS
// ============================================================
