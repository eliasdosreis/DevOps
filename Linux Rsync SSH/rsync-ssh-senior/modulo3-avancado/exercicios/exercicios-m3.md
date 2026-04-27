# 🏋️ Exercícios - Módulo 3: Avançado

## Exercício 1 - Verificação de Integridade

**Objetivo:** Detectar arquivo corrompido após transferência

**Tarefa:**
1. Crie 5 arquivos com conteúdo aleatório em `/tmp/origem-teste`
2. Gere checksums SHA256 de todos eles
3. Copie para `/tmp/destino-teste`
4. Corrompa 1 arquivo no destino: `echo "dados corrompidos" > /tmp/destino-teste/arquivo2.txt`
5. Execute o script `01-verificar-integridade.sh`
6. Ele deve detectar o arquivo corrompido!

```bash
# Criar arquivos de teste:
mkdir -p /tmp/origem-teste
for i in 1 2 3 4 5; do
    dd if=/dev/urandom bs=1K count=10 2>/dev/null | base64 > /tmp/origem-teste/arquivo${i}.txt
done

# Copiar:
cp -r /tmp/origem-teste/* /tmp/destino-teste/ 2>/dev/null || \
  rsync -av /tmp/origem-teste/ /tmp/destino-teste/

# Corromper:
echo "ARQUIVO CORROMPIDO!" > /tmp/destino-teste/arquivo3.txt

# Verificar:
./01-verificar-integridade.sh /tmp/origem-teste /tmp/destino-teste
```

**Resultado esperado:** O script deve reportar `arquivo3.txt` como CORROMPIDO.

---

## Exercício 2 - Monitoramento de Espaço

**Objetivo:** Simular verificação de espaço insuficiente

**Tarefa:**
1. Descubra quanto espaço livre existe em `/tmp`
2. Configure `ESPACO_MARGEM=200` (200% - impossível de ter!)
3. Veja o script falhar com "Espaço INSUFICIENTE"
4. Volte para `ESPACO_MARGEM=20` e veja funcionar

**Reflexão:** Por que verificar espaço ANTES da migração?
> Resposta: Se o espaço acabar no meio, você pode ter dados corrompidos/incompletos
> no destino E ter interrompido o serviço de origem por nada.

---

## Exercício 3 - Auditoria SSH

**Objetivo:** Auditar a segurança SSH do seu ambiente

**Tarefa:**
1. Execute `./03-hardening-ssh.sh`
2. Para cada item "⚠️" encontrado, pesquise como corrigir
3. Verifique seu arquivo `~/.ssh/authorized_keys` (se existir)
4. Existe alguma chave que você não reconhece?

**Comandos úteis:**
```bash
# Ver chaves autorizadas:
cat ~/.ssh/authorized_keys

# Ver tentativas de login falhas:
sudo grep "Failed password" /var/log/auth.log | tail -20

# Ver logins bem sucedidos:
sudo grep "Accepted" /var/log/auth.log | tail -20

# Ver quem está conectado agora:
who
w
```

---

## Exercício 4 - Script de Auditoria Completa

**Objetivo:** Criar um script que une verificação de espaço + integridade

**Tarefa:** Crie `auditoria-completa.sh` que:
1. Recebe ORIGEM e DESTINO como argumentos (`$1` e `$2`)
2. Verifica espaço antes (`02-verificar-espaco.sh`)
3. Se OK, executa rsync
4. Depois verifica integridade (`01-verificar-integridade.sh`)
5. Gera um relatório final com: tempo total, arquivos copiados, resultado

**Template:**
```bash
#!/bin/bash
ORIGEM="${1:-}"
DESTINO="${2:-}"

if [ -z "$ORIGEM" ] || [ -z "$DESTINO" ]; then
    echo "Uso: $0 <origem> <destino>"
    exit 1
fi

echo "=== AUDITORIA COMPLETA ==="
echo "Origem:  $ORIGEM"
echo "Destino: $DESTINO"

# 1. Verificar espaço
# 2. Executar rsync
# 3. Verificar integridade
# 4. Relatório final
```

---

## Quiz Módulo 3

1. O que é SHA256 e por que é melhor que MD5?
2. O que `--checksum` faz no rsync?
3. O que é o princípio do "menor privilégio"?
4. Por que nunca fazer login direto como root?
5. O que um arquivo `authorized_keys` com `command=` faz?

**Gabarito:**
1. SHA256 é um algoritmo de hash criptográfico. É melhor que MD5 porque é resistente a colisões (dois arquivos diferentes gerando o mesmo hash).
2. Compara o conteúdo dos arquivos (hash) em vez de apenas data/tamanho. Detecta corrupção que a comparação padrão não detectaria.
3. Cada usuário/processo deve ter apenas as permissões mínimas necessárias para sua função.
4. Se alguém invadir, já estará como root com acesso total. Com usuário normal, precisaria de uma segunda escalada de privilégio.
5. Restringe o usuário a executar apenas aquele comando específico, ignorando qualquer outro comando enviado.
