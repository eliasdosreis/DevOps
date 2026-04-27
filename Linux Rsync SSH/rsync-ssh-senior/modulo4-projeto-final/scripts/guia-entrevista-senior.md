# 🎯 Guia de Entrevista Técnica Sênior
## rsync + SSH + Linux | Alex DevOps Coach

---

## As 10 Perguntas Mais Comuns em Entrevistas

---

### 1. "Qual a diferença entre `rsync` e `scp`?"

**Resposta Sênior:**
> "O `scp` é simples: copia tudo, sempre. O `rsync` é inteligente: analisa
> a diferença entre origem e destino e transfere apenas o que mudou.
> Para migração de dados em produção, sempre prefiro `rsync` pois:
> - É muito mais rápido em sincronizações repetidas
> - Permite continuar de onde parou se a conexão cair (`--partial`)
> - Tem verificação de integridade (`--checksum`)
> - Permite simulação antes de executar (`--dry-run`)"

---

### 2. "Como você garantiria uma migração segura de 500GB em produção?"

**Resposta Sênior:**
> "Seguiria um processo em etapas:
> 1. **Planejamento**: mapear todos os dados, calcular espaço necessário
> 2. **Dry-run**: simular para validar exclusões e estimar tempo
> 3. **Pré-sync**: sincronizar enquanto o sistema ainda está rodando (reduz downtime)
> 4. **Janela de manutenção**: parar aplicação, fazer sync final das diferenças
> 5. **Verificação**: comparar checksums SHA256 de amostragem
> 6. **Rollback plan**: manter origem intacta por 30 dias"

---

### 3. "O que é backoff exponencial e quando usar?"

**Resposta Sênior:**
> "Backoff exponencial é uma estratégia onde o tempo de espera entre
> tentativas cresce exponencialmente: 30s, 60s, 120s, 240s...
> Uso quando tenho retries automáticos para não sobrecarregar um
> servidor que pode estar em dificuldades. Se eu tentasse a cada 5
> segundos, pioraria a situação. O backoff dá tempo para recuperação."

---

### 4. "Como você monitoraria transferências rsync em produção?"

**Resposta Sênior:**
> "Múltiplas camadas:
> - **Logs estruturados** com timestamp e métricas em cada execução
> - **Alertas** se a transferência demorar mais que o baseline histórico
> - **Espaço em disco** monitorado antes e durante (Prometheus + Grafana)
> - **Checksums** para verificar integridade pós-transferência
> - **Dashboard** no Grafana com throughput, erros e duração histórica"

---

### 5. "O que o `--checksum` faz no rsync?"

**Resposta Sênior:**
> "Por padrão, rsync compara arquivos por tamanho e data de modificação.
> Com `--checksum`, ele calcula o hash MD4 do conteúdo e compara isso.
> É mais lento mas muito mais confiável — detecta corrupção de dados
> que a comparação por data não detectaria. Uso em migrações críticas."

---

### 6. "Como você securizaria o SSH para um usuário de rsync?"

**Resposta Sênior:**
```
# No authorized_keys do servidor, restringir o que o usuário pode fazer:
command="rsync --server --sender -avz . /backup/",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAA... devops@empresa.com
```
> "Isso cria um usuário de rsync read-only que SÓ pode executar rsync,
> não pode fazer login normal, não pode tunelar portas.
> É o princípio do menor privilégio aplicado ao SSH."

---

### 7. "O que faz o `set -o pipefail` no bash?"

**Resposta Sênior:**
> "Sem pipefail, em `comando1 | tee arquivo`, o código de saída é sempre
> o do último comando (tee). Se `comando1` falhar, você não sabe!
> Com pipefail, o código de saída do pipe é o do PRIMEIRO comando que
> falhou. É essencial em scripts de produção para detectar erros reais."

---

### 8. "Como você faria um rsync apenas das diferenças (incremental)?"

**Resposta Sênior:**
> "Rsync é incremental por padrão — só copia o que mudou.
> Para backup com histórico, uso `--link-dest` que cria hard links
> para arquivos não modificados, economizando espaço:
> ```bash
> rsync -av --link-dest=/backup/ontem/ /dados/ /backup/hoje/
> ```
> Isso cria uma 'foto' completa de cada dia, mas cada arquivo sem mudança
> ocupa espaço zero adicional (hard link aponta para o mesmo bloco no disco)."

---

### 9. "O que você verificaria se o rsync estiver muito lento?"

**Resposta Sênior:**
> "Investigaria em camadas:
> 1. **Rede**: `iperf3` para medir bandwidth real entre os servidores
> 2. **Disco**: `iostat` para ver se o I/O do disco está saturado
> 3. **Compressão**: `-z` pode ser mais lento em rede rápida (CPU overhead)
> 4. **Checksum**: `--checksum` é mais lento, usar só quando necessário
> 5. **Muitos arquivos pequenos**: rsync overhead por arquivo é alto.
>    Para muitos arquivos pequenos, considerar `tar` antes do rsync"

---

### 10. "Qual a diferença entre stderr e stdout?"

**Resposta Sênior:**
> "stdout (fd 1) = saída normal do programa
> stderr (fd 2) = mensagens de erro
> Isso importa em scripts porque:
> - `2>/dev/null` silencia erros sem suprimir a saída normal
> - `2>&1` redireciona erros para o mesmo lugar que a saída
> - Em logs, separo: stdout vai para o log, stderr vai para o log de erros
> O rsync envia estatísticas e erros para destinos diferentes,
> então preciso capturar ambos corretamente em scripts de produção."

---

## 🏆 Dicas Finais do Alex DevOps Coach

1. **Sempre faça dry-run antes de executar em produção**
2. **Logs são sua melhor amiga em incidentes**
3. **Princípio do menor privilégio em tudo** (SSH, usuários, permissões)
4. **Automatize, mas entenda o que está automatizando**
5. **Documente o porquê, não o quê** (o código já mostra o quê)
6. **Tenha sempre um plano de rollback**
7. **Teste seus backups** (backup que nunca foi restaurado não é backup!)

---

> 💼 **Com este projeto você está preparado para:**
> - Entrevistas em startups e grandes empresas brasileiras
> - Empresas internacionais (metodologia é universal)
> - Posições de DevOps Engineer, SRE, Platform Engineer
> - Salários de R$12k a R$25k+ (Sênior no Brasil em 2024)
