# AWS Secrets Manager vs Systems Manager Parameter Store

## 1. Analogia do Dia a Dia
Secrets Manager é como um cofre digital para guardar senhas e segredos importantes, com alarme e registro de quem acessa. Parameter Store é como uma gaveta organizada para guardar configurações e valores, com divisórias para segredos e configurações simples.

## 2. O que é (definição técnica oficial AWS)
- AWS Secrets Manager: serviço para armazenar, rotacionar e auditar segredos (senhas, tokens, chaves) com alta segurança.
- AWS Systems Manager Parameter Store: armazena parâmetros de configuração e segredos, com integração nativa ao SSM.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Secrets Manager vs Parameter Store
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Secrets Manager: foco em segredos sensíveis, rotação automática
- Parameter Store: armazena configs e segredos, integração com SSM

PALAVRAS-CHAVE NA PROVA:
→ "rotação automática de segredos"
→ "armazenamento de parâmetros"
→ "integração SSM"

QUANDO USAR:
✅ Secrets Manager: segredos críticos, rotação automática
✅ Parameter Store: configs, segredos menos sensíveis

QUANDO NÃO USAR:
❌ Usar Parameter Store para segredos críticos sem rotação
❌ Armazenar segredos em texto plano

DIFERENCIAIS:
- Secrets Manager tem custo extra, Parameter Store tem camada gratuita
============================================================

## 4. Questões de Fixação
1. Quando usar o Secrets Manager?
A) Para configs simples
B) Para segredos críticos e rotação automática (correta)
C) Para monitorar custos
D) Para backup

Explicação:
- B) Correta: Secrets Manager é para segredos críticos.
- A), C), D) não são motivos reais.

Armadilha: confundir Parameter Store com Secrets Manager.

2. O que o Parameter Store faz?
A) Armazena parâmetros e segredos (correta)
B) Gera relatórios de custos
C) Detecta ameaças
D) Cria backups

Explicação:
- A) Correta: Parameter Store armazena configs e segredos.
- B), C), D) não são funções do Parameter Store.

Armadilha: achar que Parameter Store faz rotação automática.

## 5. Conceito Senior
- Secrets Manager integra com CloudTrail para auditoria.
- Parameter Store é ideal para configs versionadas e integração com SSM.

## 6. Resumo para Revisão
- Secrets Manager = segredos críticos | rotação automática | auditoria | Parameter Store = configs e segredos simples | integração SSM | camada gratuita