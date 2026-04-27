// ============================================================
// MÓDULO 10 — SHARED LIBRARIES
// Arquivo: shared-library/vars/deployApp.groovy
//
// Função global reutilizável para deploy de aplicações.
// ============================================================

/**
 * Realiza o deploy da aplicação no ambiente especificado.
 *
 * @param config Map com configurações:
 *   - ambiente: 'dev', 'staging', 'prod' (obrigatório)
 *   - imagem: nome:tag da imagem Docker (obrigatório)
 *   - namespace: namespace Kubernetes (default: ambiente)
 *   - replicas: número de réplicas (default: 1 dev, 2 staging, 3 prod)
 *   - estrategia: 'rolling', 'blue-green' (default: 'rolling')
 *   - aprovacao: boolean, exigir aprovação manual (default: true para prod)
 *
 * Uso no Jenkinsfile:
 *   deployApp(ambiente: 'staging', imagem: 'minha-app:42')
 *   deployApp(ambiente: 'prod', imagem: 'minha-app:42', estrategia: 'blue-green')
 */
def call(Map config = [:]) {
  // Validações
  if (!config.ambiente) error "deployApp: 'ambiente' é obrigatório"
  if (!config.imagem)   error "deployApp: 'imagem' é obrigatório"

  def ambiente   = config.ambiente
  def imagem     = config.imagem
  def namespace  = config.namespace  ?: ambiente
  def estrategia = config.estrategia ?: 'rolling'
  def aprovacao  = config.aprovacao  != null ? config.aprovacao : (ambiente == 'prod')

  // Número de réplicas por ambiente
  def replicaMap = [dev: 1, staging: 2, prod: 3]
  def replicas   = config.replicas ?: (replicaMap[ambiente] ?: 1)

  echo """
=== deployApp ===
Ambiente:   ${ambiente}
Imagem:     ${imagem}
Namespace:  ${namespace}
Réplicas:   ${replicas}
Estratégia: ${estrategia}
Aprovação:  ${aprovacao}
  """

  // Aprovação manual se necessário
  if (aprovacao) {
    timeout(time: 24, unit: 'HOURS') {
      input(
        message: "Confirma deploy de ${imagem} em ${ambiente.toUpperCase()}?",
        ok: 'Aprovar Deploy',
        submitter: 'admin,tech-lead'
      )
    }
  }

  // Executar deploy conforme estratégia
  switch (estrategia) {
    case 'rolling':
      _rollingDeploy(namespace, imagem, replicas)
      break
    case 'blue-green':
      _blueGreenDeploy(namespace, imagem)
      break
    default:
      error "deployApp: estratégia '${estrategia}' não suportada"
  }

  echo "✅ [deployApp] Deploy em ${ambiente} concluído!"
}

// Métodos privados (convenção: prefixo _)
private def _rollingDeploy(namespace, imagem, replicas) {
  sh """
    kubectl set image deployment/app app=${imagem} -n ${namespace}
    kubectl scale deployment/app --replicas=${replicas} -n ${namespace}
    kubectl rollout status deployment/app -n ${namespace} --timeout=10m
  """
}

private def _blueGreenDeploy(namespace, imagem) {
  sh """
    # Simplificado — produção teria mais lógica
    kubectl set image deployment/app-green app=${imagem} -n ${namespace}
    kubectl rollout status deployment/app-green -n ${namespace} --timeout=10m
    kubectl patch service app -n ${namespace} -p '{"spec":{"selector":{"slot":"green"}}}'
  """
}
