# ============================================================
# MÓDULO 11 — SEGURANÇA E GOVERNANÇA
# Arquivo: 11-hardening-checklist.md
# ============================================================

# Checklist de Hardening do Jenkins para Produção

> Use este checklist antes de colocar o Jenkins em produção.
> Marque cada item conforme for implementado.

---

## 🔐 AUTENTICAÇÃO E AUTORIZAÇÃO

- [ ] **Desativar autenticação anônima**
  ```
  Manage Jenkins → Security → Authorization
  → "Logged-in users can do anything" NÃO é produção!
  → Use "Role-Based Strategy" ou "Matrix Authorization Strategy"
  ```

- [ ] **Desativar "Allow users to sign up"**
  ```
  Manage Jenkins → Security → Security Realm
  → Demarque "Allow users to sign up"
  ```

- [ ] **Integrar com LDAP/Active Directory/SSO**
  ```
  Plugins: LDAP, Active Directory, SAML, OpenID Connect
  Centraliza autenticação com o diretório corporativo
  ```

- [ ] **MFA (Multi-Factor Authentication)**
  ```
  Via SSO/SAML — o Jenkins delega para o IdP corporativo
  ```

- [ ] **Senha forte para conta admin local**
  ```
  Mínimo 16 caracteres, armazenada em gerenciador de senhas
  ```

---

## 🌐 REDE E ACESSO

- [ ] **Jenkins atrás de proxy reverso (Nginx/Apache)**
  ```
  Nunca exponha o Tomcat do Jenkins diretamente para a internet
  Use Nginx com SSL/TLS termination
  ```

- [ ] **Forçar HTTPS**
  ```
  Redirecionar todo HTTP para HTTPS
  Certificado válido (Let's Encrypt ou CA corporativa)
  ```

- [ ] **Firewall: bloquear porta 8080 direto**
  ```
  Apenas 443 (HTTPS via proxy) e 50000 (agentes JNLP, interno)
  devem ser acessíveis
  ```

- [ ] **Porta 50000 (agentes JNLP): apenas rede interna**
  ```
  Agentes externos devem usar VPN
  ```

- [ ] **Configurar CSRF Protection**
  ```
  Manage Jenkins → Security → CSRF Protection
  ✅ "Enable proxy compatibility" se estiver atrás de proxy
  ```

---

## 🔑 CREDENTIALS E SECRETS

- [ ] **Nunca usar variáveis de ambiente do sistema para secrets**
  ```
  ❌ DOCKER_TOKEN=abc123 em /etc/environment
  ✅ Credentials Store do Jenkins
  ```

- [ ] **Rotação periódica de credentials (90 dias)**

- [ ] **Usar HashiCorp Vault para secrets dinâmicos** (avançado)

- [ ] **Auditar quem tem acesso ao Credentials Store**
  ```
  Manage Jenkins → Credentials → (verificar permissões)
  ```

- [ ] **Remover credentials não utilizadas**

---

## 🤖 EXECUÇÃO DE BUILDS

- [ ] **Desabilitar executors no Controller (built-in node)**
  ```
  Manage Jenkins → Nodes → Built-In Node → Configure
  Number of executors: 0
  ```

- [ ] **Script Security habilitado**
  ```
  Manage Jenkins → Security → Script Security
  ✅ Habilitado (padrão)
  ```

- [ ] **Revisar scripts aprovados regularmente**
  ```
  Manage Jenkins → In-process Script Approval
  ```

- [ ] **Usar agents efêmeros para builds não confiáveis**
  ```
  PRs de forks devem rodar em agents isolados
  sem acesso a credentials de produção
  ```

---

## 📋 AUDITORIA

- [ ] **Instalar Audit Trail Plugin**
  ```
  Registra: quem fez o quê, quando, no Jenkins
  Logs em arquivo ou syslog centralizado
  ```

- [ ] **Configurar retenção de logs de audit**
  ```
  Mínimo 90 dias (compliance) — 1 ano é recomendado
  ```

- [ ] **Centralizar logs em SIEM** (Splunk, ELK, etc.)

---

## 🔒 SISTEMA OPERACIONAL E CONTAINER

- [ ] **Jenkins rodando como usuário não-root** (se possível)
  ```
  No Docker: user: 1000:1000 (jenkins uid)
  Exceção: se precisar de Docker socket
  ```

- [ ] **Imagem Docker atualizada regularmente**
  ```
  jenkins/jenkins:lts — verificar novas LTS mensalmente
  ```

- [ ] **JENKINS_HOME em volume persistente separado**
  ```
  Dados de build não no mesmo volume que a aplicação
  ```

- [ ] **Backup regular do JENKINS_HOME**
  ```
  Diário, testado mensalmente, retenção mínima de 30 dias
  ```

- [ ] **Scan de CVE na imagem Jenkins periodicamente**
  ```
  trivy image jenkins/jenkins:lts
  ```

---

## 📊 MONITORAMENTO

- [ ] **Health check endpoint disponível**
  ```
  http://jenkins:8080/login → deve retornar 200
  ```

- [ ] **Alertas para falhas do Controller**

- [ ] **Monitorar uso de disco do JENKINS_HOME**
  ```
  Builds acumulam logs e artefatos — configurar política de retenção
  ```

- [ ] **Log de erros do Jenkins monitorado**
  ```
  docker logs jenkins -f | grep -i error
  ```
