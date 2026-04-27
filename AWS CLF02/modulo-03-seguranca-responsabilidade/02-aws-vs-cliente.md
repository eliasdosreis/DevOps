# O que é responsabilidade DA AWS vs DO CLIENTE

## 1. Analogia do Dia a Dia
É como um condomínio: o síndico cuida da estrutura, mas cada morador é responsável pelo seu apartamento. Se você deixa a porta aberta, o problema é seu!

## 2. O que é (definição técnica oficial AWS)
A AWS é responsável pela segurança da infraestrutura global (hardware, software, redes, instalações). O cliente é responsável por tudo que ele coloca e configura na nuvem (dados, permissões, criptografia, firewalls, etc).

## 3. Ficha de Estudo Comentada
============================================================
TEMA: Responsabilidade AWS vs Cliente
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- AWS: infraestrutura física e virtual
- Cliente: dados, apps, configurações, permissões

PALAVRAS-CHAVE NA PROVA:
→ "segurança física = AWS"
→ "dados e permissões = cliente"
→ "firewall de aplicação = cliente"

QUANDO USAR:
✅ Para entender limites de responsabilidade
✅ Configurar recursos na AWS

QUANDO NÃO USAR:
❌ Assumir que AWS protege dados do cliente
❌ Ignorar configuração de segurança

DIFERENCIAIS:
- Mudança de responsabilidade conforme serviço (IaaS, PaaS, SaaS)
============================================================

## 4. Questões de Fixação
1. Quem é responsável por configurar criptografia de dados na AWS?
A) AWS
B) Cliente (correta)
C) Parceiro AWS
D) Usuário final

Explicação:
- B) Correta: cliente configura criptografia.
- A), C), D) não são responsáveis.

Armadilha: achar que AWS faz tudo automaticamente.

2. Quem protege a infraestrutura física dos datacenters?
A) Cliente
B) AWS (correta)
C) Usuário final
D) Parceiro AWS

Explicação:
- B) Correta: AWS protege infraestrutura.
- A), C), D) não são responsáveis.

Armadilha: confundir responsabilidade física e lógica.

## 5. Conceito Senior
- Em serviços gerenciados (SaaS), a responsabilidade do cliente é menor.
- Sempre revisar políticas de acesso e logs.

## 6. Resumo para Revisão
- AWS = infraestrutura física | Cliente = dados, apps, permissões | responsabilidade muda por serviço | atenção à configuração de segurança