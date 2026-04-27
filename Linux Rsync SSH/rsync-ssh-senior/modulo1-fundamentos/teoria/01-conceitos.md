# 📖 Módulo 1 - Teoria: O que é SSH e rsync?

## 🔑 SSH - A Chave Secreta

### Explicação para Criança:
Imagine que você quer entrar na casa do seu amigo de forma segura.
Você precisa de uma CHAVE. O SSH funciona assim:
- Você tem uma chave PRIVADA (fica só com você, nunca compartilhe!)
- O servidor tem a FECHADURA (chave pública)
- Só sua chave abre aquela fechadura

### Explicação Técnica:
SSH (Secure Shell) é um protocolo criptográfico que permite:
- Conexão remota segura entre computadores
- Autenticação por par de chaves (pública/privada)
- Transferência segura de dados (criptografados)
- Porta padrão: 22

---

## 📦 rsync - O Caminhão Inteligente

### Explicação para Criança:
Imagine que você já levou 100 livros para a casa nova.
Agora só precisa levar os 5 livros novos que comprou.
O rsync é tão inteligente que ele só leva os livros NOVOS, não os 100 de novo!

### Explicação Técnica:
rsync (Remote Sync) é uma ferramenta que:
- Sincroniza arquivos entre diretórios (local ou remoto)
- Transfere APENAS o que mudou (delta transfer)
- Preserva permissões, datas e links simbólicos
- Comprime dados durante a transferência
- Funciona sobre SSH (transferência segura)

---

## 🔄 Como SSH + rsync trabalham juntos?

```
SEU COMPUTADOR                    SERVIDOR REMOTO
     |                                  |
     |------ SSH (túnel seguro) ------->|
     |                                  |
     |------ rsync (arquivos) --------->|
     |        (dentro do túnel SSH)     |
     |                                  |
```

---

## 📝 Comandos Essenciais para Memorizar

### SSH Básico:
```bash
ssh usuario@servidor           # Conectar ao servidor
ssh -p 2222 usuario@servidor   # Conectar em porta diferente
ssh -i chave.pem usuario@servidor  # Usar chave específica
```

### rsync Básico:
```bash
rsync origem destino           # Sincronizar local
rsync -av origem/ usuario@servidor:/destino/  # Sincronizar remoto
```

### As FLAGS mais importantes do rsync:
| Flag | Significado | Analogia |
|------|-------------|---------|
| -a   | archive (preserva tudo) | Guardar caixa com tudo dentro |
| -v   | verbose (mostra o que faz) | Caminhoneiro te conta o que carrega |
| -z   | comprime dados | Espremer roupa antes de guardar |
| -n   | dry-run (simula sem fazer) | Ensaio antes da apresentação |
| -P   | progresso + continua de onde parou | Barra de progresso do download |
| --delete | apaga no destino o que não existe na origem | Limpeza automática |

---

## ⚠️ O que um Sênior sabe sobre SSH:

1. **Nunca use senha** → Use sempre par de chaves
2. **Desative root login** → Crie usuário específico
3. **Mude a porta padrão** → Evita ataques automáticos
4. **Use fail2ban** → Bloqueia tentativas de invasão
5. **Monitore os logs** → /var/log/auth.log

---

## 🎯 Pontos para Entrevista Técnica:

**Pergunta comum:** "Como você garante segurança em transferências rsync?"

**Resposta Sênior:**
> "Uso rsync sobre SSH com autenticação por chave pública/privada,
> desativo autenticação por senha no sshd_config, uso usuário
> dedicado com permissões mínimas (princípio do menor privilégio),
> e monitoro os logs de acesso regularmente."
