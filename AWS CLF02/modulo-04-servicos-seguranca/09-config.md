# AWS Config — conformidade de configurações

## 1. Analogia do Dia a Dia
AWS Config é como um fiscal que verifica se todas as regras do condomínio estão sendo seguidas: ele monitora, registra e alerta se algo estiver fora do padrão.

## 2. O que é (definição técnica oficial AWS)
AWS Config monitora, avalia e registra as configurações dos recursos AWS, permitindo identificar desvios de conformidade e manter histórico de mudanças.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Config
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Monitora e registra configurações de recursos
- Avalia conformidade com regras definidas
- Mantém histórico de mudanças

PALAVRAS-CHAVE NA PROVA:
→ "conformidade de configuração"
→ "auditoria de recursos"
→ "histórico de mudanças"

QUANDO USAR:
✅ Compliance regulatório
✅ Monitorar mudanças em recursos

QUANDO NÃO USAR:
❌ Ignorar desvios de configuração
❌ Ambientes sem requisitos de compliance

DIFERENCIAIS:
- Permite automação de remediação
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Config?
A) Gera relatórios de custos
B) Monitora conformidade de configurações (correta)
C) Cria backups
D) Gerencia usuários

Explicação:
- B) Correta: Config monitora conformidade.
- A), C), D) não são funções do Config.

Armadilha: confundir Config com CloudTrail.

2. Para que serve o histórico do Config?
A) Auditar mudanças em recursos (correta)
B) Monitorar custos
C) Gerenciar contas
D) Criar buckets S3

Explicação:
- A) Correta: histórico para auditoria.
- B), C), D) não são funções do histórico.

Armadilha: achar que Config faz backup.

## 5. Conceito Senior
- Config pode acionar Lambda para remediação automática.
- Ajuda a cumprir normas como PCI DSS, HIPAA.

## 6. Resumo para Revisão
- Config = conformidade de configuração | monitora e audita recursos | histórico de mudanças | automação de remediação | compliance facilitado