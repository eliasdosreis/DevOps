# Amazon EFS — sistema de arquivos compartilhado

## 1. Analogia do Dia a Dia
EFS é como um drive compartilhado na empresa: vários funcionários podem acessar, ler e gravar arquivos ao mesmo tempo, de diferentes computadores.

## 2. O que é (definição técnica oficial AWS)
Amazon Elastic File System (EFS) é um sistema de arquivos compartilhado, escalável e gerenciado, acessível por múltiplas instâncias EC2 simultaneamente.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon EFS
DOMÍNIO DO EXAME: Armazenamento (33%)
============================================================

O QUE É:
- Sistema de arquivos compartilhado (NFS)
- Escalável e elástico
- Acesso simultâneo por várias EC2

PALAVRAS-CHAVE NA PROVA:
→ "sistema de arquivos compartilhado"
→ "NFS gerenciado"
→ "acesso simultâneo"

QUANDO USAR:
✅ Workloads que exigem acesso compartilhado
✅ Ambientes de machine learning, web servers

QUANDO NÃO USAR:
❌ Armazenar objetos (use S3)
❌ Workloads que não precisam de compartilhamento

DIFERENCIAIS:
- Paga pelo uso, escala automaticamente
============================================================

## 4. Questões de Fixação
1. O que é o Amazon EFS?
A) Armazenamento de objetos
B) Sistema de arquivos compartilhado (correta)
C) Disco de EC2
D) CDN

Explicação:
- B) Correta: EFS é sistema de arquivos compartilhado.
- A), C), D) não são EFS.

Armadilha: confundir EFS com S3 ou EBS.

2. Quando usar EFS?
A) Para acesso simultâneo por várias EC2 (correta)
B) Para backups
C) Para banco de dados relacional
D) Para CDN

Explicação:
- A) Correta: EFS é para acesso compartilhado.
- B), C), D) não são casos de uso de EFS.

Armadilha: achar que EFS é igual a S3.

## 5. Conceito Senior
- EFS pode ser montado em múltiplas AZs para alta disponibilidade.
- Performance ajustável conforme workload.

## 6. Resumo para Revisão
- EFS = sistema de arquivos compartilhado | NFS gerenciado | acesso simultâneo | escala automática | ideal para múltiplas EC2