# 📖 Módulo 3 - Teoria: Segurança e Monitoramento

## 🛡️ Por que Segurança é coisa de Sênior?

### Explicação para Criança:
Imagine sua escola com câmeras de segurança, portão com senha,
e um caderno onde o porteiro anota quem entrou e saiu.
Um Sênior faz a mesma coisa nos servidores!

---

## 🔒 Hardening SSH (Deixar o SSH mais seguro)

### O arquivo que controla o SSH: `/etc/ssh/sshd_config`

```bash
# ❌ RUIM (configuração padrão insegura):
PermitRootLogin yes          # Permite login como root = PERIGO!
PasswordAuthentication yes   # Aceita senha = hackers adoram tentar senhas!
Port 22                      # Porta padrão = bots já sabem!

# ✅ BOM (configuração segura para Sênior):
PermitRootLogin no           # Nunca logar como root diretamente
PasswordAuthentication no    # Só aceita chaves SSH
PubkeyAuthentication yes     # Aceita autenticação por chave
Port 2222                    # Porta diferente = menos bots
MaxAuthTries 3               # 3 tentativas erradas = bloqueado
ClientAliveInterval 300      # Desconecta sessão inativa após 5min
ClientAliveCountMax 2        # 2 verificações sem resposta = desconecta
AllowUsers devops backup     # Só estes usuários podem logar
```

---

## 📊 Monitoramento: O que um Sênior monitora?

### Explicação para Criança:
O médico do hospital fica olhando os monitores dos pacientes.
Se algo muda, ele age rápido. Um Sênior faz isso com servidores!

### O que monitorar:
1. **Espaço em disco** → rsync falha sem espaço!
2. **Tempo das transferências** → Ficou muito lento? Algo errado!
3. **Falhas de conexão** → Servidor caiu? Rede com problema?
4. **Integridade dos arquivos** → Os arquivos chegaram corretos?

---

## 🔍 Verificação de Integridade

### O que é um Checksum?
Imagine que você manda 100 balas para um amigo.
Para confirmar que chegaram todas, você conta: 100 balas.
Um checksum faz isso com arquivos, mas com matemática!

```bash
# Gerar checksum de um arquivo:
md5sum arquivo.txt
# Resultado: abc123def456... arquivo.txt

sha256sum arquivo.txt
# Resultado: xyz789... arquivo.txt (mais seguro que MD5)

# Verificar se chegou correto:
sha256sum -c checksums.txt
# arquivo.txt: OK  ← chegou correto!
# foto.jpg: FAILED ← arquivo corrompido!
```

### MD5 vs SHA256:
- **MD5** = rápido, mas pode ter colisões (dois arquivos, mesmo hash)
- **SHA256** = mais lento, mas muito mais seguro
- **Para DevOps:** use SHA256 em produção, MD5 só para verificação rápida

---

## 📈 Métricas que um Sênior acompanha

| Métrica | O que mede | Alerta quando |
|---------|-----------|---------------|
| Throughput | Velocidade da transferência (MB/s) | < 10% da velocidade normal |
| Taxa de erro | % de falhas | > 0% em dias consecutivos |
| Tempo total | Duração do backup | > 2x a duração normal |
| Espaço livre | Disco disponível | < 20% de espaço livre |

---

## 🎯 Pergunta de Entrevista Sênior:

**"Como você garantiria que os dados chegaram íntegros após uma migração de 1TB?"**

**Resposta de Sênior:**
> "Usaria verificação em múltiplas camadas:
> 1. rsync com --checksum para verificar durante a transferência
> 2. Geração de SHA256 de todos os arquivos antes e depois
> 3. Comparação do número de arquivos e tamanho total
> 4. Teste de amostragem: abrir/usar alguns arquivos no destino
> 5. Log de toda a operação para auditoria"
