# Amazon EBS — disco de EC2

## 1. Analogia do Dia a Dia
EBS é como o HD de um computador: cada servidor (EC2) precisa de um disco para armazenar o sistema operacional e dados temporários.

## 2. O que é (definição técnica oficial AWS)
Amazon Elastic Block Store (EBS) fornece volumes de armazenamento em blocos para instâncias EC2, permitindo alta performance e persistência de dados.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon EBS
DOMÍNIO DO EXAME: Armazenamento (33%)
============================================================

O QUE É:
- Disco de armazenamento em blocos para EC2
- Persistente e de alta performance
- Tipos: SSD, HDD

PALAVRAS-CHAVE NA PROVA:
→ "disco de EC2"
→ "armazenamento em blocos"
→ "persistência de dados"

QUANDO USAR:
✅ Instâncias EC2
✅ Bancos de dados

QUANDO NÃO USAR:
❌ Armazenar arquivos estáticos (use S3)
❌ Compartilhar entre várias instâncias (use EFS)

DIFERENCIAIS:
- Snapshots para backup e recuperação
============================================================

## 4. Questões de Fixação
1. O que é o Amazon EBS?
A) Armazenamento de objetos
B) Disco de EC2 (correta)
C) CDN
D) Banco de dados

Explicação:
- B) Correta: EBS é disco de EC2.
- A), C), D) não são EBS.

Armadilha: confundir EBS com S3.

2. Para que servem os snapshots do EBS?
A) Backup e recuperação de dados (correta)
B) Monitorar custos
C) Gerenciar usuários
D) Criar buckets S3

Explicação:
- A) Correta: snapshots são para backup.
- B), C), D) não são funções dos snapshots.

Armadilha: achar que snapshot é só para logs.

## 5. Conceito Senior
- Snapshots podem ser usados para replicação entre regiões.
- Performance depende do tipo de volume escolhido.

## 6. Resumo para Revisão
- EBS = disco de EC2 | armazenamento em blocos | snapshots para backup | SSD/HDD | persistência de dados