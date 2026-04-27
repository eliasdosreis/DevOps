# IAM: Users, Groups, Roles, Policies

## 1. Analogia do Dia a Dia
IAM é como o sistema de crachás de uma empresa: cada funcionário (user) tem um crachá, pode pertencer a um departamento (group), pode receber permissões temporárias para tarefas específicas (role) e cada crachá tem regras do que pode ou não fazer (policy).

## 2. O que é (definição técnica oficial AWS)
O AWS Identity and Access Management (IAM) permite gerenciar usuários, grupos, funções e políticas de acesso de forma segura e granular dentro da AWS.

## 3. Ficha de Estudo Comentada
============================================================
TEMA: IAM
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Users: contas individuais
- Groups: conjunto de users
- Roles: permissões temporárias/delegadas
- Policies: regras de acesso (JSON)

PALAVRAS-CHAVE NA PROVA:
→ "least privilege"
→ "role temporária"
→ "policy JSON"
→ "grupo de usuários"

QUANDO USAR:
✅ Para controlar acesso seguro
✅ Delegar permissões temporárias

QUANDO NÃO USAR:
❌ Compartilhar usuário entre pessoas
❌ Usar root user para tarefas diárias

DIFERENCIAIS:
- IAM é global (não depende de região)
============================================================

## 4. Questões de Fixação
1. O que é uma IAM Role?
A) Grupo de usuários
B) Permissão temporária/delegada (correta)
C) Política de acesso
D) Usuário root

Explicação:
- B) Correta: role é permissão temporária.
- A), C), D) não são roles.

Armadilha: confundir role com group.

2. O que é uma IAM Policy?
A) Documento JSON que define permissões (correta)
B) Usuário temporário
C) Grupo de usuários
D) Serviço de rede

Explicação:
- A) Correta: policy é documento JSON.
- B), C), D) não são policies.

Armadilha: achar que policy é só para grupos.

## 5. Conceito Senior
- Sempre aplicar o princípio do menor privilégio.
- Roles são essenciais para integrações seguras entre serviços.

## 6. Resumo para Revisão
- IAM = users, groups, roles, policies | controle de acesso granular | least privilege | roles para permissões temporárias | policies em JSON