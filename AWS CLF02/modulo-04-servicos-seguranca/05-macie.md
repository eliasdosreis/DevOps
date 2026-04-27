# AWS Macie — descoberta de dados sensíveis (PII) no S3

## 1. Analogia do Dia a Dia
Macie é como um detetive que vasculha todos os arquivos de um escritório procurando por documentos confidenciais, como RG, CPF ou cartões de crédito, para garantir que estejam protegidos.

## 2. O que é (definição técnica oficial AWS)
AWS Macie é um serviço que usa machine learning para identificar, classificar e proteger dados sensíveis (PII) armazenados no Amazon S3.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Macie
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Descoberta e classificação de dados sensíveis
- Foco em PII (informações pessoais)
- Scans automáticos em buckets S3

PALAVRAS-CHAVE NA PROVA:
→ "PII"
→ "dados sensíveis S3"
→ "machine learning"

QUANDO USAR:
✅ Compliance (LGPD, GDPR)
✅ Proteger dados pessoais em S3

QUANDO NÃO USAR:
❌ Buckets sem dados sensíveis
❌ Ignorar findings

DIFERENCIAIS:
- Automatiza descoberta de PII em larga escala
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Macie?
A) Detecta ameaças em tempo real
B) Descobre dados sensíveis em S3 (correta)
C) Gera relatórios de custos
D) Gerencia usuários

Explicação:
- B) Correta: Macie descobre dados sensíveis.
- A), C), D) não são funções do Macie.

Armadilha: confundir Macie com GuardDuty.

2. O que é PII?
A) Informação pessoal identificável (correta)
B) Política de acesso
C) Grupo de usuários
D) Backup

Explicação:
- A) Correta: PII = dados pessoais.
- B), C), D) não são PII.

Armadilha: achar que PII é só senha.

## 5. Conceito Senior
- Macie ajuda a cumprir LGPD/GDPR.
- Pode automatizar alertas e remediação via Lambda.

## 6. Resumo para Revisão
- Macie = descoberta de PII | S3 | machine learning | compliance LGPD/GDPR | findings automáticos