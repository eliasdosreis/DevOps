# AWS KMS e CloudHSM — gerenciamento de chaves

## 1. Analogia do Dia a Dia
KMS é como um cofre digital onde você guarda as chaves de todos os cadeados da empresa. CloudHSM é como contratar um cofre físico exclusivo, só seu, para guardar as chaves mais valiosas.

## 2. O que é (definição técnica oficial AWS)
- AWS Key Management Service (KMS): serviço gerenciado de criação e controle de chaves de criptografia.
- AWS CloudHSM: módulo de segurança de hardware dedicado para gerenciamento de chaves, com controle total pelo cliente.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: KMS e CloudHSM
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- KMS: gerenciamento de chaves gerenciado pela AWS
- CloudHSM: gerenciamento de chaves em hardware dedicado

PALAVRAS-CHAVE NA PROVA:
→ "criptografia gerenciada"
→ "HSM dedicado"
→ "controle total do cliente"

QUANDO USAR:
✅ KMS: maioria dos casos de criptografia
✅ CloudHSM: requisitos de compliance rigorosos

QUANDO NÃO USAR:
❌ CloudHSM para casos simples
❌ Ignorar rotação de chaves

DIFERENCIAIS:
- CloudHSM oferece controle físico total
============================================================

## 4. Questões de Fixação
1. O que faz o AWS KMS?
A) Gerencia chaves de criptografia (correta)
B) Gera relatórios de custos
C) Detecta ameaças
D) Cria backups

Explicação:
- A) Correta: KMS gerencia chaves.
- B), C), D) não são funções do KMS.

Armadilha: confundir KMS com CloudHSM.

2. Quando usar CloudHSM?
A) Para controle total das chaves (correta)
B) Para casos simples de criptografia
C) Para monitorar custos
D) Para backup

Explicação:
- A) Correta: CloudHSM é para controle total.
- B), C), D) não são motivos reais.

Armadilha: achar que CloudHSM é sempre necessário.

## 5. Conceito Senior
- KMS integra com quase todos os serviços AWS.
- CloudHSM é exigido em setores altamente regulados.

## 6. Resumo para Revisão
- KMS = gerenciamento de chaves | CloudHSM = HSM dedicado | KMS cobre maioria dos casos | CloudHSM para compliance rigoroso | integra com serviços AWS