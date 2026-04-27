# Amazon S3: conceito, classes, versionamento, lifecycle

## 1. Analogia do Dia a Dia
S3 é como um depósito infinito de caixas: você pode guardar qualquer coisa, pegar de volta quando quiser, escolher caixas mais baratas para itens antigos e até recuperar versões antigas de um documento.

## 2. O que é (definição técnica oficial AWS)
Amazon Simple Storage Service (S3) é um serviço de armazenamento de objetos, altamente durável e escalável, usado para guardar arquivos, backups, imagens, vídeos e dados de aplicações.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon S3
DOMÍNIO DO EXAME: Armazenamento (33%)
============================================================

O QUE É:
- Armazenamento de objetos (arquivos) na nuvem
- Classes: Standard, Standard-IA, Glacier, Intelligent-Tiering
- Versionamento e políticas de ciclo de vida

PALAVRAS-CHAVE NA PROVA:
→ "armazenar arquivos estáticos"
→ "hospedar site estático"
→ "backup de objetos"
→ "durabilidade 11 noves (99,999999999%)"

QUANDO USAR:
✅ Imagens, vídeos, backups, logs
✅ Data Lake
✅ Hospedagem de sites estáticos

QUANDO NÃO USAR:
❌ Banco de dados relacional
❌ Disco de EC2

DIFERENCIAIS:
- Versionamento e ciclo de vida automatizam gestão de dados
============================================================

## 4. Questões de Fixação
1. O que é o Amazon S3?
A) Banco de dados relacional
B) Armazenamento de objetos na nuvem (correta)
C) Disco de EC2
D) CDN

Explicação:
- B) Correta: S3 é armazenamento de objetos.
- A), C), D) não são S3.

Armadilha: confundir S3 com EBS ou RDS.

2. O que faz o versionamento no S3?
A) Cria backups automáticos
B) Mantém versões antigas dos objetos (correta)
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- B) Correta: versionamento mantém versões.
- A), C), D) não são funções do versionamento.

Armadilha: achar que versionamento é backup.

## 5. Conceito Senior
- Políticas de ciclo de vida reduzem custos movendo dados para classes mais baratas.
- Versionamento protege contra deleção acidental.

## 6. Resumo para Revisão
- S3 = armazenamento de objetos | classes: Standard, IA, Glacier | versionamento | ciclo de vida | durabilidade 11 noves