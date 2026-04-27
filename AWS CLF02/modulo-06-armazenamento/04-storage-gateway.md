# AWS Storage Gateway — híbrido on-premises + nuvem

## 1. Analogia do Dia a Dia
Storage Gateway é como um elevador de carga entre o escritório e o depósito externo: permite transferir arquivos entre o local físico e o armazenamento na nuvem, de forma transparente.

## 2. O que é (definição técnica oficial AWS)
AWS Storage Gateway conecta ambientes locais (on-premises) à nuvem AWS, permitindo backup, arquivamento e acesso híbrido a dados.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Storage Gateway
DOMÍNIO DO EXAME: Armazenamento (33%)
============================================================

O QUE É:
- Integração de ambientes locais com a nuvem
- Backup, arquivamento e acesso híbrido
- Modos: File, Volume, Tape Gateway

PALAVRAS-CHAVE NA PROVA:
→ "híbrido on-premises"
→ "backup na nuvem"
→ "gateway de armazenamento"

QUANDO USAR:
✅ Empresas com datacenter local
✅ Migração gradual para nuvem

QUANDO NÃO USAR:
❌ Ambientes 100% na nuvem
❌ Sem necessidade de integração local

DIFERENCIAIS:
- Suporta múltiplos modos de operação
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Storage Gateway?
A) Cria backups locais
B) Integra ambientes locais com a nuvem (correta)
C) Gerencia usuários
D) Gera relatórios de custos

Explicação:
- B) Correta: Storage Gateway faz integração híbrida.
- A), C), D) não são funções do Storage Gateway.

Armadilha: confundir Storage Gateway com S3.

2. Quando usar Storage Gateway?
A) Para ambientes 100% na nuvem
B) Para integração híbrida (correta)
C) Para banco de dados relacional
D) Para CDN

Explicação:
- B) Correta: Storage Gateway é para integração híbrida.
- A), C), D) não são casos de uso de Storage Gateway.

Armadilha: achar que Storage Gateway é só para backup.

## 5. Conceito Senior
- Storage Gateway facilita compliance e recuperação de desastres.
- Pode ser usado para migração de grandes volumes de dados.

## 6. Resumo para Revisão
- Storage Gateway = integração híbrida | backup/arquivamento | múltiplos modos | conecta on-premises à nuvem | facilita migração