// ============================================================
// MÓDULO 4 — CREDENTIALS E SECRETS
// Arquivo: 04-Jenkinsfile-ssh-key.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra como usar credenciais SSH (chave privada) no pipeline.
// Usado para: acesso a servidores, clone de repos Git privados,
// deploy remoto sem senha.
//
// ANALOGIA DO DIA A DIA:
// Uma chave SSH é como uma chave física de casa:
// - A CHAVE PRIVADA (fica no Jenkins, nunca sai) = sua chave-cópia
// - A CHAVE PÚBLICA (fica no servidor remoto) = a fechadura da sua porta
// O servidor compara os dois: se combinam, acesso liberado. Sem senha.
// ============================================================

pipeline {
  agent any

  stages {

    stage('SSH: Clone de Repositório Git Privado') {
      steps {
        // ===========================================================
        // sshagent: carrega a chave SSH para o agente ssh-agent
        // Funciona como um "porta-chaves" temporário para o bloco
        // ===========================================================
        sshagent(credentials: ['github-ssh-key']) {
          // 'github-ssh-key': ID da credential SSH no Jenkins

          sh '''
            # Verificar que o agente SSH está ativo
            ssh-add -l 2>/dev/null || echo "Agente SSH ativo"

            # Testar conexão com GitHub (sem senha, via chave SSH)
            ssh -o StrictHostKeyChecking=no -T git@github.com 2>&1 || true
            # Resultado esperado: "Hi username! You've successfully authenticated..."

            # Clone de repositório privado
            # git clone git@github.com:organizacao/repo-privado.git

            echo "Repositório clonado via SSH (simulado)"
          '''
        }
      }
    }

    stage('SSH: Deploy em Servidor Remoto') {
      steps {
        sshagent(credentials: ['servidor-producao-ssh']) {
          // 'servidor-producao-ssh': SSH Key cadastrada para o servidor de produção

          sh '''
            SERVIDOR="exemplo.servidor.com"
            USUARIO="deploy"
            PORTA="22"

            echo "Conectando ao servidor ${SERVIDOR}..."

            # Executar comandos remotos via SSH
            ssh -o StrictHostKeyChecking=no \
                -p ${PORTA} \
                ${USUARIO}@${SERVIDOR} \
                "echo 'Conexão estabelecida' && whoami && uptime"

            # Copiar arquivo para o servidor
            # scp -P ${PORTA} ./target/app.jar ${USUARIO}@${SERVIDOR}:/opt/app/

            # Ou usar rsync (mais eficiente para múltiplos arquivos)
            # rsync -avz -e "ssh -p ${PORTA}" ./target/ ${USUARIO}@${SERVIDOR}:/opt/app/

            echo "Deploy via SSH concluído (simulado)"
          '''
        }
      }
    }

    stage('SSH: Executar Script Remoto') {
      steps {
        withCredentials([
          sshUserPrivateKey(
            credentialsId: 'servidor-producao-ssh',
            keyFileVariable: 'KEY_FILE',        // Caminho para o arquivo temporário da chave
            usernameVariable: 'SSH_USER'        // Username da credencial SSH
          )
        ]) {
          sh '''
            echo "Usando chave SSH de: $KEY_FILE"
            echo "Usuário SSH: $SSH_USER"

            # Definir permissões corretas para o arquivo de chave
            chmod 600 "$KEY_FILE"

            # Executar script de deploy no servidor remoto
            ssh -i "$KEY_FILE" \
                -o StrictHostKeyChecking=no \
                -o BatchMode=yes \
                "${SSH_USER}@servidor.empresa.com" << 'SCRIPT_REMOTO'
              echo "=== Executando no servidor remoto ==="
              cd /opt/minha-app
              git pull origin main
              systemctl restart minha-app
              systemctl status minha-app --no-pager
              echo "=== Deploy concluído ==="
SCRIPT_REMOTO

            echo "Script remoto executado com sucesso"
          '''
        }
      }
    }

    stage('SSH: StrictHostKeyChecking em Produção') {
      steps {
        script {
          echo "=== CONCEITO SENIOR: StrictHostKeyChecking ==="
          echo """
IMPORTANTE SOBRE StrictHostKeyChecking=no:

Em todos os exemplos acima, usamos -o StrictHostKeyChecking=no.
Isso É NECESSÁRIO para automação (sem interação humana),
MAS cria um risco de segurança (man-in-the-middle attack).

SOLUÇÃO SEGURA PARA PRODUÇÃO:
1. Adicione o fingerprint do servidor ao known_hosts:
   ssh-keyscan -H servidor.empresa.com >> ~/.ssh/known_hosts

2. Ou use um arquivo known_hosts pré-configurado:
   ssh -o GlobalKnownHostsFile=/etc/jenkins/known_hosts ...

3. Melhor ainda: use o plugin SSH Agent do Jenkins que
   gerencia isso automaticamente com known_hosts verificado.
          """
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// COMO CADASTRAR SSH KEY NO JENKINS:
//
// 1. Manage Jenkins → Credentials → System → Global credentials
// 2. Add Credentials
// 3. Kind: SSH Username with private key
// 4. Username: git (para GitHub) ou deploy (para servidor)
// 5. Private Key: Enter directly → cole o conteúdo do arquivo id_rsa
//    (inclua o -----BEGIN ... e -----END ... completos)
// 6. Passphrase: (se a chave tiver passphrase — opcional)
// 7. ID: github-ssh-key
// 8. Description: Chave SSH para acesso ao GitHub
// 9. OK
//
// GERAR UM PAR DE CHAVES SSH (na sua máquina):
//   ssh-keygen -t ed25519 -C "jenkins@empresa.com" -f ~/.ssh/jenkins_key
//   → Privada: ~/.ssh/jenkins_key  (coloca no Jenkins)
//   → Pública: ~/.ssh/jenkins_key.pub  (adiciona ao GitHub/servidor)
//
// ADICIONAR CHAVE PÚBLICA AO GITHUB:
//   Settings → SSH and GPG Keys → New SSH Key → cole o conteúdo de .pub
// ============================================================
