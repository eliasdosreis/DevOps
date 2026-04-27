# MFA, Password Policy, Least Privilege

## 1. Analogia do Dia a Dia
MFA é como ter duas chaves para abrir um cofre: mesmo que alguém descubra uma, precisa da outra. Password Policy é como exigir senha forte para entrar em um sistema. Least Privilege é como dar só a chave do que a pessoa realmente precisa acessar.

## 2. O que é (definição técnica oficial AWS)
- MFA (Multi-Factor Authentication): exige dois fatores para login (senha + token/app)
- Password Policy: regras para senhas fortes (tamanho, complexidade, expiração)
- Least Privilege: conceder apenas as permissões mínimas necessárias para cada usuário/tarefa

## 3. Ficha de Estudo Comentada
============================================================
TEMA: MFA, Password Policy, Least Privilege
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- MFA: segurança extra no login
- Password Policy: força e renovação de senhas
- Least Privilege: acesso mínimo necessário

PALAVRAS-CHAVE NA PROVA:
→ "MFA obrigatório"
→ "senha forte"
→ "menor privilégio"

QUANDO USAR:
✅ Para proteger contas críticas
✅ Reduzir riscos de acesso indevido

QUANDO NÃO USAR:
❌ Permitir acesso amplo sem necessidade
❌ Usar senhas fracas

DIFERENCIAIS:
- MFA pode ser app, SMS ou hardware
============================================================

## 4. Questões de Fixação
1. O que é o princípio do menor privilégio?
A) Dar todas as permissões a todos
B) Conceder apenas o acesso necessário (correta)
C) Exigir senha fraca
D) Permitir login sem MFA

Explicação:
- B) Correta: menor privilégio = acesso mínimo.
- A), C), D) são opostos.

Armadilha: achar que permissões amplas são mais fáceis.

2. O que é MFA?
A) Autenticação com dois fatores (correta)
B) Política de senha
C) Grupo de usuários
D) Serviço de rede

Explicação:
- A) Correta: MFA = dois fatores.
- B), C), D) não são MFA.

Armadilha: confundir MFA com senha forte.

## 5. Conceito Senior
- MFA deve ser obrigatório para root user e contas críticas.
- Revisar permissões periodicamente reduz riscos.

## 6. Resumo para Revisão
- MFA = dois fatores | Password Policy = senha forte | Least Privilege = acesso mínimo | segurança reforçada | revisar permissões sempre