// ============================================================
// MÓDULO 10 — SHARED LIBRARIES
// Arquivo: shared-library/vars/notifySlack.groovy
//
// Função de notificação Slack reutilizável.
// ============================================================

/**
 * Envia notificação no Slack com informações do build.
 *
 * @param config Map com:
 *   - channel: canal Slack (default: '#ci-builds')
 *   - mensagem: mensagem customizada (opcional)
 *   - status: 'success', 'failure', 'warning' (default: auto pelo build)
 *   - includeBuildInfo: boolean (default: true)
 *
 * Uso:
 *   notifySlack()  // Auto-detecta status do build
 *   notifySlack(channel: '#alertas', mensagem: 'Deploy concluído!')
 *   notifySlack(status: 'failure', channel: '#alertas-criticos')
 */
def call(Map config = [:]) {
  def channel     = config.channel ?: '#ci-builds'
  def mensagem    = config.mensagem ?: ''
  def status      = config.status ?: _detectarStatus()
  def buildInfo   = config.includeBuildInfo != false

  def colorMap = [
    success: 'good',      // Verde
    failure: 'danger',    // Vermelho
    warning: 'warning',   // Amarelo
    aborted: '#808080'    // Cinza
  ]

  def emojiMap = [
    success: '✅',
    failure: '❌',
    warning: '⚠️',
    aborted: '🚫'
  ]

  def cor   = colorMap[status] ?: '#808080'
  def emoji = emojiMap[status] ?: '🔔'

  def textoBase = mensagem ?: "${emoji} Build ${currentBuild.displayName} — ${status.toUpperCase()}"

  def attachment = [
    color: cor,
    text: textoBase,
  ]

  if (buildInfo) {
    attachment.fields = [
      [title: 'Job', value: env.JOB_NAME, short: true],
      [title: 'Build', value: "#${env.BUILD_NUMBER}", short: true],
      [title: 'Branch', value: env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'N/A', short: true],
      [title: 'Duração', value: currentBuild.durationString, short: true],
    ]
    attachment.footer = env.BUILD_URL
  }

  // Enviar via plugin Slack do Jenkins
  slackSend(
    channel: channel,
    color: cor,
    message: textoBase,
    attachments: groovy.json.JsonOutput.toJson([attachment])
  )
}

// Versão simples: apenas canal e mensagem
def call(String mensagem) {
  call(mensagem: mensagem)
}

// Detecta status automaticamente pelo resultado do build atual
private String _detectarStatus() {
  def resultado = currentBuild.result ?: 'SUCCESS'
  def mapa = [SUCCESS: 'success', FAILURE: 'failure', UNSTABLE: 'warning', ABORTED: 'aborted']
  return mapa[resultado] ?: 'warning'
}
