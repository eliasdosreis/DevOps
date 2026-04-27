# AWS Organizations e SCPs

## 1. Analogia do Dia a Dia
AWS Organizations é como uma empresa com várias filiais: a matriz (organização) define regras gerais (SCPs) que todas as filiais (contas) devem seguir, mesmo que cada filial tenha sua própria equipe e operações.

## 2. O que é (definição técnica oficial AWS)
AWS Organizations permite gerenciar múltiplas contas AWS de forma centralizada. Service Control Policies (SCPs) são regras que limitam permissões máximas das contas dentro da organização.

## 3. Ficha de Estudo Comentada
============================================================
TEMA: AWS Organizations e SCPs
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Organizations: gestão centralizada de contas
- SCPs: políticas que limitam permissões máximas

PALAVRAS-CHAVE NA PROVA:
→ "multi-account"
→ "SCP limita permissões"
→ "gestão centralizada"

QUANDO USAR:
✅ Empresas com várias contas AWS
✅ Governança e compliance

QUANDO NÃO USAR:
❌ Ambientes pequenos com uma só conta
❌ Ignorar políticas de segurança

DIFERENCIAIS:
- SCPs não concedem permissões, só limitam
============================================================

## 4. Questões de Fixação
1. O que faz uma SCP em AWS Organizations?
A) Concede permissões
B) Limita permissões máximas (correta)
C) Cria usuários
D) Gera relatórios de custos

Explicação:
- B) Correta: SCP limita permissões.
- A), C), D) não são funções de SCP.

Armadilha: achar que SCP concede acesso.

2. Quando usar AWS Organizations?
A) Para gerenciar múltiplas contas (correta)
B) Para criar buckets S3
C) Para monitorar logs
D) Para backup local

Explicação:
- A) Correta: Organizations é para multi-account.
- B), C), D) não são funções principais.

Armadilha: confundir Organizations com serviços individuais.

## 5. Conceito Senior
- SCPs ajudam a garantir compliance em ambientes complexos.
- Permite aplicar políticas de segurança em toda a organização.

## 6. Resumo para Revisão
- Organizations = gestão multi-account | SCP = limita permissões máximas | governança centralizada | não concede permissões | compliance facilitado