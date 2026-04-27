# 🏋️ Exercícios - Módulo 1: Fundamentos

## Como fazer os exercícios:
1. Leia o exercício completo
2. Tente resolver SOZINHO primeiro
3. Se travar, olhe a dica
4. Confira com o gabarito

---

## Exercício 1 - Gerar suas chaves SSH
**Objetivo:** Criar par de chaves ED25519

**Tarefa:**
1. Execute o script `01-gerar-chaves-ssh.sh`
2. Verifique se os arquivos foram criados
3. Qual é a diferença entre a chave pública e privada?

**Verifique:**
```bash
ls -la ~/.ssh/rsync_senior_key*
# Deve mostrar dois arquivos:
# rsync_senior_key      (privada, permissão 600)
# rsync_senior_key.pub  (pública, permissão 644)
```

**💡 Dica para entrevista:** 
> "Por que ED25519 e não RSA?"
> ED25519 é mais moderno, chaves menores e mais seguras, algoritmo de curva elíptica.

---

## Exercício 2 - rsync local com dry-run
**Objetivo:** Entender o poder do dry-run

**Tarefa:**
1. Crie uma pasta `/tmp/minha-origem` com 3 arquivos
2. Faça um dry-run para `/tmp/meu-destino`
3. Verifique que `/tmp/meu-destino` ainda está vazio
4. Execute o rsync real
5. Adicione 1 arquivo novo na origem
6. Faça o rsync novamente e observe: só 1 arquivo foi copiado!

```bash
# Crie os arquivos:
mkdir -p /tmp/minha-origem
echo "arquivo 1" > /tmp/minha-origem/a.txt
echo "arquivo 2" > /tmp/minha-origem/b.txt
echo "arquivo 3" > /tmp/minha-origem/c.txt

# Dry-run:
rsync -avn /tmp/minha-origem/ /tmp/meu-destino/

# Execute real:
rsync -av /tmp/minha-origem/ /tmp/meu-destino/

# Adicione arquivo novo:
echo "arquivo novo" > /tmp/minha-origem/novo.txt

# Rsync novamente (só copia o novo!):
rsync -av /tmp/minha-origem/ /tmp/meu-destino/
```

**Responda:** Quantos arquivos foram transferidos na segunda vez?

---

## Exercício 3 - A barra que muda tudo

**Objetivo:** Entender a diferença crítica da barra no rsync

**Tarefa:** Execute os dois comandos e veja a diferença:

```bash
# COM barra na origem:
rsync -av /tmp/minha-origem/  /tmp/teste-com-barra/
ls /tmp/teste-com-barra/      # Mostra: a.txt b.txt c.txt

# SEM barra na origem:
rsync -av /tmp/minha-origem   /tmp/teste-sem-barra/
ls /tmp/teste-sem-barra/      # Mostra: minha-origem/ (a pasta inteira!)
```

**Regra para nunca esquecer:**
- Barra no final = copia o CONTEÚDO da pasta
- Sem barra = copia a PASTA em si

---

## Exercício 4 - Quiz de Entrevista

Responda as perguntas sem olhar o material:

1. O que faz a flag `-a` no rsync?
2. O que é um dry-run e por que é importante?
3. Qual a permissão correta para uma chave SSH privada?
4. Como você verifica se uma conexão SSH está funcionando antes de rodar o rsync?

**Gabarito:**
1. `-a` = archive: preserva permissões, timestamps, links simbólicos, recursivo
2. Dry-run simula sem executar. Importante para evitar erros em produção.
3. `600` (apenas o dono pode ler/escrever)
4. `ssh -o ConnectTimeout=10 -o BatchMode=yes user@host "exit 0"`
