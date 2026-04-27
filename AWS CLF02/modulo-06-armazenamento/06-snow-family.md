# AWS Snow Family: Snowcone, Snowball, Snowmobile

## 1. Analogia do Dia a Dia
A Snow Family é como diferentes tamanhos de caminhões de mudança: Snowcone é uma van pequena, Snowball é um caminhão médio, Snowmobile é uma carreta gigante — todos servem para transportar dados de um lugar para outro.

## 2. O que é (definição técnica oficial AWS)
AWS Snow Family são dispositivos físicos para transferir grandes volumes de dados entre ambientes locais e a nuvem AWS: Snowcone (pequeno), Snowball (médio), Snowmobile (petabytes).

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Snow Family
DOMÍNIO DO EXAME: Armazenamento (33%)
============================================================

O QUE É:
- Dispositivos físicos para migração de dados
- Snowcone: até 8TB, portátil
- Snowball: até 80TB, resistente
- Snowmobile: até 100PB, carreta

PALAVRAS-CHAVE NA PROVA:
→ "migração de dados em larga escala"
→ "dispositivo físico AWS"
→ "Snowcone, Snowball, Snowmobile"

QUANDO USAR:
✅ Migração de grandes volumes de dados
✅ Locais com banda de internet limitada

QUANDO NÃO USAR:
❌ Pequenos volumes de dados (use S3 Transfer)
❌ Ambientes 100% na nuvem

DIFERENCIAIS:
- Suporte a criptografia e rastreamento de dispositivos
============================================================

## 4. Questões de Fixação
1. O que é o AWS Snowball?
A) Serviço de backup
B) Dispositivo físico para migração de dados (correta)
C) Disco de EC2
D) CDN

Explicação:
- B) Correta: Snowball é para migração física.
- A), C), D) não são Snowball.

Armadilha: confundir Snowball com S3.

2. Quando usar o Snowmobile?
A) Para migração de petabytes de dados (correta)
B) Para pequenos arquivos
C) Para backups diários
D) Para CDN

Explicação:
- A) Correta: Snowmobile é para petabytes.
- B), C), D) não são casos de uso de Snowmobile.

Armadilha: achar que Snowmobile é só para backup.

## 5. Conceito Senior
- Snow Family é essencial para migração em ambientes restritos.
- Suporte a criptografia ponta a ponta.

## 6. Resumo para Revisão
- Snow Family = migração física de dados | Snowcone, Snowball, Snowmobile | grandes volumes | uso quando internet é gargalo | criptografia e rastreamento