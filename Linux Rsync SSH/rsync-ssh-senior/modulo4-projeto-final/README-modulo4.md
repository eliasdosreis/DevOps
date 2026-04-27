# 🔴 Módulo 4 - Projeto Final Sênior

## O que você vai construir?

Um **Sistema de Migração Enterprise** completo, igual ao que você encontraria
em empresas como Nubank, iFood, Mercado Livre e empresas internacionais.

---

## 🗂️ Arquivos do Projeto Final

```
modulo4-projeto-final/
├── scripts/
│   ├── migrar-enterprise.sh      ← Script principal (ESTUDE ESTE!)
│   └── guia-entrevista-senior.md ← Perguntas + respostas de entrevista
└── configs/
    └── migrar.conf               ← Template de configuração
```

---

## 🚀 Como executar o projeto final

### Passo 1: Configurar
```bash
# Copiar e editar o arquivo de configuração
cp configs/migrar.conf configs/meu-ambiente.conf
nano configs/meu-ambiente.conf
# Preencha: SERVIDOR, USUARIO, CHAVE_SSH, etc.
```

### Passo 2: Testar (sempre dry-run primeiro!)
```bash
chmod +x scripts/migrar-enterprise.sh

# Simulação (NUNCA pule esta etapa em produção!)
./scripts/migrar-enterprise.sh --dry-run --config configs/meu-ambiente.conf
```

### Passo 3: Executar
```bash
# Migração real
./scripts/migrar-enterprise.sh --config configs/meu-ambiente.conf
```

---

## 🎯 O que este projeto demonstra em entrevista

Quando o entrevistador perguntar sobre sua experiência com rsync/SSH,
você pode dizer:

> "Desenvolvi um sistema de migração de dados que incluía:
> verificação de pré-requisitos, autenticação por chave ED25519,
> retry com backoff exponencial, verificação de espaço em disco,
> sistema de logs estruturados, verificação de integridade pós-migração
> com SHA256, e relatório detalhado ao final."

Cada uma dessas palavras é um ponto positivo na entrevista! ✅

---

## 📊 Diagrama do Fluxo do Projeto Final

```
INÍCIO
  │
  ▼
[1] Inicializar Logs
  │
  ▼
[2] Carregar Configurações (migrar.conf)
  │
  ▼
[3] Validar Configurações ──── ERRO? ──→ SAIR (código 1)
  │
  ▼
[4] Verificar Conexão SSH ──── ERRO? ──→ SAIR (código 1)
  │
  ▼
[5] Verificar Espaço em Disco ─ ERRO? ──→ SAIR (código 1)
  │
  ▼
[6] Construir Opções rsync
  │
  ▼
[7] Executar rsync ◄────────────────────────────┐
  │                                             │
  ├── SUCESSO ─────────────────────────────────→│→ PRÓXIMO PASSO
  │                                             │
  └── FALHA ── tentativas < MAX? ──SIM──→ ESPERA (backoff) ─┘
                    │
                   NÃO
                    │
                    ▼
              ERRO DEFINITIVO → SAIR (código ≠ 0)
  │
  ▼
[8] Verificar Integridade (contar arquivos, comparar tamanhos)
  │
  ▼
[9] Gerar Relatório Final
  │
  ▼
FIM (código 0 = sucesso)
```

---

## 🏆 Checklist de Conclusão do Projeto

Antes de considerar o projeto completo, verifique:

- [ ] Consigo explicar o que faz cada flag do rsync (`-avzP`, `--checksum`, etc.)
- [ ] Consigo explicar a diferença entre chave pública e privada
- [ ] Consigo explicar o que é backoff exponencial
- [ ] Consigo explicar como verificar integridade de arquivos
- [ ] Consigo executar o projeto final com `--dry-run`
- [ ] Consigo explicar o projeto para alguém que não é da área
- [ ] Revisei o `guia-entrevista-senior.md` e sei responder as 10 perguntas

Se marcou todos: **você está pronto para entrevistas Sênior!** 🎉
