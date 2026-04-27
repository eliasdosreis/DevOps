# AWS Shield (Standard vs Advanced) — proteção DDoS

## 1. Analogia do Dia a Dia
AWS Shield é como um segurança na porta de um prédio: o Standard é o porteiro comum, já o Advanced é um time de seguranças especializados, prontos para ataques mais sofisticados.

## 2. O que é (definição técnica oficial AWS)
AWS Shield é um serviço de proteção contra ataques DDoS. O Standard protege automaticamente todos os clientes AWS. O Advanced oferece proteção extra, resposta 24/7 e integração com suporte especializado.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: AWS Shield
DOMÍNIO DO EXAME: Segurança e Conformidade (30%)
============================================================

O QUE É:
- Proteção DDoS automática (Standard)
- Proteção avançada, resposta e suporte (Advanced)

PALAVRAS-CHAVE NA PROVA:
→ "proteção DDoS"
→ "Shield Standard = automático"
→ "Shield Advanced = suporte especializado"

QUANDO USAR:
✅ Sites públicos, APIs expostas
✅ Ambientes críticos (Advanced)

QUANDO NÃO USAR:
❌ Ambientes internos sem exposição externa
❌ Ignorar riscos de DDoS

DIFERENCIAIS:
- Advanced inclui resposta a incidentes e seguro financeiro
============================================================

## 4. Questões de Fixação
1. O que faz o AWS Shield Standard?
A) Protege contra DDoS automaticamente (correta)
B) Cria backups
C) Gera logs
D) Gerencia usuários

Explicação:
- A) Correta: proteção automática.
- B), C), D) não são funções do Shield.

Armadilha: confundir Standard com Advanced.

2. Quando usar o Shield Advanced?
A) Para ambientes críticos e compliance (correta)
B) Para backups
C) Para monitorar custos
D) Para criar buckets S3

Explicação:
- A) Correta: Advanced é para ambientes críticos.
- B), C), D) não são motivos reais.

Armadilha: achar que só o Standard basta para tudo.

## 5. Conceito Senior
- Shield Advanced oferece SLA, resposta a incidentes e integração com WAF.
- Pode ser obrigatório para compliance em setores regulados.

## 6. Resumo para Revisão
- Shield = proteção DDoS | Standard = automático | Advanced = suporte e resposta | ambientes críticos usam Advanced | integra com WAF