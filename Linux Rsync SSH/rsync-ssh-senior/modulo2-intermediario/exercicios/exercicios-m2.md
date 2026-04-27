# 🏋️ Exercícios - Módulo 2: Intermediário

## Exercício 1 - Arquivo de Configuração

**Objetivo:** Criar seu próprio arquivo de configuração

**Tarefa:**
1. Copie o arquivo `rsync.conf` para `meu-rsync.conf`
2. Edite com seus dados de servidor
3. Modifique o script `01-rsync-com-config.sh` para carregar seu arquivo
4. Teste com `--dry-run`

**Dica:**
```bash
cp rsync.conf meu-rsync.conf
nano meu-rsync.conf
```

**Perguntas para reflexão:**
- Por que nunca commitar o `.conf` no Git?
- Como você passaria o arquivo de config via variável de ambiente?

---

## Exercício 2 - Sistema de Logs

**Objetivo:** Criar um sistema de log personalizado

**Tarefa:** Escreva uma função de log que:
1. Adicione timestamp em cada linha
2. Use cores diferentes por nível (INFO=azul, ERRO=vermelho)
3. Salve em arquivo E exiba na tela ao mesmo tempo
4. Crie um arquivo de log por dia (nome inclua a data)

**Template para começar:**
```bash
#!/bin/bash
PASTA_LOGS="/tmp/meus-logs"
mkdir -p "$PASTA_LOGS"
ARQUIVO_LOG="$PASTA_LOGS/$(date '+%Y-%m-%d').log"

log() {
    local NIVEL="$1"
    local MSG="$2"
    # Seu código aqui!
}

log "INFO" "Iniciando script..."
log "ERRO" "Simulando um erro"
log "OK"   "Operação bem sucedida"
```

---

## Exercício 3 - Retry Simples

**Objetivo:** Criar um loop de retry sem usar o script pronto

**Tarefa:** Escreva um script que:
1. Tente executar um comando (pode ser um `ping`)
2. Se falhar, tente mais 2 vezes
3. Entre cada tentativa, espere 5 segundos
4. No final, informe se teve sucesso ou falhou em todas

**Template:**
```bash
#!/bin/bash
MAX=3
TENTATIVA=1

while [ $TENTATIVA -le $MAX ]; do
    echo "Tentativa $TENTATIVA de $MAX..."
    
    # Coloque aqui o comando que pode falhar
    ping -c1 -W2 servidor-inexistente.local
    
    if [ $? -eq 0 ]; then
        echo "✅ Sucesso!"
        exit 0
    fi
    
    ((TENTATIVA++))
    [ $TENTATIVA -le $MAX ] && sleep 5
done

echo "❌ Todas as tentativas falharam!"
exit 1
```

---

## Exercício 4 - Crontab

**Objetivo:** Agendar uma tarefa simples

**Tarefa:**
1. Crie um script que escreve a data/hora atual em `/tmp/teste-cron.log`
2. Agende para rodar a cada minuto: `* * * * * /caminho/script.sh`
3. Espere 3 minutos e verifique se o arquivo foi atualizado
4. Remova a tarefa depois: `crontab -r` (cuidado: remove TUDO) ou `crontab -e`

**Script do teste:**
```bash
#!/bin/bash
echo "$(date '+%Y-%m-%d %H:%M:%S') - Cron rodou!" >> /tmp/teste-cron.log
```

**Verificar:**
```bash
tail -f /tmp/teste-cron.log   # Acompanhar em tempo real
```

---

## Quiz Módulo 2

1. O que faz `source arquivo.conf`?
2. O que é backoff exponencial? Por que usar?
3. Como o cron sabe onde está seu script?
4. O que `2>&1` faz num comando de cron?
5. Por que usar `local` em variáveis dentro de funções?

**Gabarito:**
1. Executa o arquivo no contexto atual do shell (as variáveis ficam disponíveis)
2. Aumenta exponencialmente o tempo entre tentativas. Evita sobrecarregar serviços em recuperação.
3. Cron não usa PATH do usuário. Você DEVE usar caminhos absolutos!
4. Redireciona erros (stderr) para o mesmo destino que a saída normal (stdout)
5. Variáveis locais não "vazam" para fora da função, evitando bugs difíceis de encontrar
