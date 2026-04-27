# ============================================================
# MÓDULO 8 — AGENTS E NODES
# Arquivo: 08-agente-ssh-setup.md
# ============================================================

# Configurando Agente Jenkins via SSH

---

## 1. ANALOGIA

Configurar um agente SSH é como **dar uma chave de casa para um assistente**.
O Jenkins (gerente) manda comandos para o agente (assistente)
usando a chave SSH. O assistente executa os trabalhos e manda
os resultados de volta.

---

## 2. PRÉ-REQUISITOS

- Máquina remota (Linux) com SSH habilitado
- Java instalado na máquina remota (mesma versão major do Controller)
- Usuário `jenkins` criado na máquina remota
- Par de chaves SSH gerado

---

## 3. PASSO A PASSO

### Passo 1: Criar usuário no agente remoto

```bash
# Na máquina do agente:
sudo useradd -m -s /bin/bash jenkins
sudo mkdir -p /home/jenkins/.ssh
sudo chmod 700 /home/jenkins/.ssh
```

### Passo 2: Gerar par de chaves SSH (no Controller ou localmente)

```bash
ssh-keygen -t ed25519 -C "jenkins-agent" -f ~/.ssh/jenkins_agent_key -N ""
# Gera:
#   ~/.ssh/jenkins_agent_key     (chave PRIVADA → vai para o Jenkins)
#   ~/.ssh/jenkins_agent_key.pub (chave PÚBLICA → vai para o agente)
```

### Passo 3: Autorizar a chave pública no agente

```bash
# Na máquina do agente:
sudo cat /dev/stdin >> /home/jenkins/.ssh/authorized_keys
# (cole o conteúdo de jenkins_agent_key.pub)

sudo chown -R jenkins:jenkins /home/jenkins/.ssh
sudo chmod 600 /home/jenkins/.ssh/authorized_keys
```

### Passo 4: Instalar Java no agente

```bash
# Ubuntu/Debian:
sudo apt-get update && sudo apt-get install -y openjdk-21-jdk

# CentOS/RHEL:
sudo dnf install -y java-21-openjdk

# Verificar:
java --version
```

### Passo 5: Criar diretório de trabalho do Jenkins

```bash
sudo mkdir -p /var/jenkins_home
sudo chown jenkins:jenkins /var/jenkins_home
```

### Passo 6: Cadastrar a chave privada no Jenkins

1. Manage Jenkins → Credentials → System → Global
2. Add Credentials → SSH Username with private key
3. ID: `agente-linux-01-ssh`
4. Username: `jenkins`
5. Private Key: Enter directly → cole o conteúdo de `jenkins_agent_key`
6. Create

### Passo 7: Adicionar o agente no Jenkins

1. Manage Jenkins → Nodes → New Node
2. Nome: `agente-linux-01`
3. Tipo: Permanent Agent
4. Configure:
   - Remote root directory: `/var/jenkins_home`
   - Labels: `linux docker maven`
   - Launch method: Launch agents via SSH
   - Host: `IP ou hostname do agente`
   - Credentials: `agente-linux-01-ssh`
   - Host Key Verification: Known hosts file (ou Non verifying para teste)
5. Save

### Passo 8: Conectar e verificar

Clique em "Launch agent" ou aguarde a reconexão automática.
O log deve mostrar: `Agent successfully connected and online`

---

## 4. TROUBLESHOOTING

### Erro: "Connection refused"
- Verifique se SSH está ativo: `systemctl status sshd`
- Verifique firewall: `ufw allow 22`

### Erro: "Permission denied (publickey)"
- Arquivo authorized_keys tem permissão 600?
- Pasta .ssh tem permissão 700?
- Usuário `jenkins` é dono dos arquivos?

### Erro: "Java not found"
- Java instalado no agente? `which java`
- Configure o Java path no Jenkins: `Manage Jenkins → Nodes → agente → Configure → JVM`

---

## 5. VERIFICAR LABELS DO AGENTE

```groovy
// No pipeline, verificar em qual agente está rodando:
stage('Verificar Agent') {
  steps {
    echo "Node: ${env.NODE_NAME}"
    echo "Labels: ${env.NODE_LABELS}"
    sh 'java --version'
    sh 'docker --version || echo "Docker não disponível"'
  }
}
```

---

## 6. AGENTE VIA JNLP (Java Web Start)

Para agentes que não podem receber SSH (firewall):

```bash
# No agente, execute o comando mostrado em:
# Manage Jenkins → Nodes → <agente> → Status
java -jar agent.jar \
  -jnlpUrl http://jenkins:8080/computer/meu-agente/jenkins-agent.jnlp \
  -secret <SECRET_TOKEN> \
  -workDir /var/jenkins_home
```

O agente inicia a conexão (saída), sem precisar de SSH de entrada.
